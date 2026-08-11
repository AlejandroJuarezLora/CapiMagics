"""Generation: turn a placement plan into glayout geometry.

Kept apart from `place.py` on purpose. Placement is arithmetic over design
rules and can be exercised without generating anything; this module is where
the glayout dependency, the port names and the ordering of routing calls all
live. Mixing them means a spacing calculation cannot be checked without
building a layout.

The flow inside generation runs in two passes, which reads like an inversion
but is not: primitives have to exist before their size and wells can be read,
so it goes

    generate primitives  ->  plan (place.py)  ->  assemble at the planned x

Power rails are drawn here rather than left to the caller. A cell that exposes
VDD and VSS as ports and never connects them looks finished and is not -- the
LIF neuron reached DRC-clean in that state, which is exactly how the omission
survived.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Optional
from warnings import warn

from .place import Cell, Rails, Stack, pair, plan_row

# Ports a glayout FET offers that this module relies on.
GATE = "multiplier_0_gate_{side}"
DRAIN = "multiplier_0_drain_{side}"
SOURCE = "multiplier_0_source_{side}"
# The tie has ports on comp and on the top metal. Routing from the comp one
# drops a full via stack in the middle of the tie's own contact row -- 0.18 um
# between contacts where the rule wants 0.25. The narrow top-metal port on the
# side avoids both that and the wide N/S port, which is broad enough to merge
# with whatever it passes.
TIE = "tie_{end}_top_met_E"


@dataclass
class Inverter:
    """One placed inverter and the ports the row needs from it."""
    ref_p: object
    ref_n: object
    stack: Stack

    @property
    def vdd_port(self):
        return self.ref_p.ports[SOURCE.format(side="N")]

    @property
    def vss_port(self):
        return self.ref_n.ports[SOURCE.format(side="S")]

    @property
    def in_port(self):
        return self.ref_n.ports[GATE.format(side="E")]

    @property
    def out_port(self):
        return self.ref_n.ports[DRAIN.format(side="W")]

    @property
    def vdd_tie(self):
        return self.ref_p.ports[TIE.format(end="N")]

    @property
    def vss_tie(self):
        return self.ref_n.ports[TIE.format(end="S")]


def _into_metal(port, distance: float) -> float:
    """How far to step in y so a via lands on the port's metal, not past it.

    A port marks the edge of its shape and faces *away* from it: a south
    facing port has its metal to the north. Centring a via on the port leaves
    half of it hanging over whatever is on the other side -- on a glayout FET
    that is the tie ring, a few tens of nanometres away. Ports on a vertical
    edge (east, west) need no y step at all.
    """
    angle = (port.orientation or 0) % 360
    if 45 < angle < 135:          # faces north -> metal is south
        return -distance
    if 225 < angle < 315:         # faces south -> metal is north
        return +distance
    return 0.0


def _merge_columns(points, width: float, sep: float) -> list[list]:
    """Group drop positions that are too close to stand as separate shapes.

    Two rectangles of `width` centred less than `width + sep` apart leave a
    gap the spacing rule rejects. Since every drop on one rail carries the
    same net, the fix is to draw them as one rectangle rather than to shove
    them apart -- shoving would walk the via off the metal it has to land on.

    `points` must be sorted by x.
    """
    groups: list[list] = []
    for point in points:
        if groups and point[0] - groups[-1][-1][0] < width + sep:
            groups[-1].append(point)
        else:
            groups.append([point])
    return groups


def _center_on(ref, x: float, y: float):
    """Move a reference so its centre lands on (x, y).

    `move(destination=...)` is a plain translation in gdsfactory -- origin
    defaults to (0, 0), not to the reference centre -- so placing by centre
    has to be written as an explicit delta.
    """
    cx, cy = ref.center
    ref.movex(float(x) - float(cx)).movey(float(y) - float(cy))
    return ref


def inverter_row(pdk, nmos_params: dict, pmos_params: dict, count: int = 3,
                 pair_gap: float = 0.95, rails: Optional[Rails] = None,
                 stages: Optional[list] = None, chain: bool = False,
                 channel_tracks: int = 2):
    """A row of inverters with VDD and VSS rails, wired to both.

    `chain` wires stage i to stage i+1, turning the row into a chain
    instead of three independent inverters.

    `stages` gives per-inverter sizing as [(nmos_params, pmos_params), ...] and
    overrides `count`. The row is not uniform in practice: in a LIF cell the
    threshold inverter sets the trip point the characterisation was fitted
    around and must not move, while the output inverter is sized for whatever
    it drives. Sizing them all alike is the special case, not the rule.

    Returns (Component, [Inverter]). Spacing comes from place.plan_row, so the
    only distance decided here is `pair_gap` -- the room the gate and drain
    links need to turn between the two devices, which no well rule constrains
    because gf180 lets nwell and pwell abut.
    """
    from glayout.backend import Component, rectangle
    from glayout.primitives.fet import nmos, pmos
    from glayout.routing.c_route import c_route
    from glayout.routing.L_route import L_route
    from glayout.routing.straight_route import straight_route

    if any(p.get("multipliers", 1) > 1
           for stage in (stages or [(nmos_params, pmos_params)]) for p in stage):
        warn("multipliers > 1 doubles the device height, and the rail drops "
             "then run the full way down it alongside the gate and drain "
             "links; they end up 0.10 um apart where met3 wants 0.30. The "
             "cell is still correctly connected -- only the spacing fails -- "
             "but placing the drops clear of the routing needs a router that "
             "knows where the routes are. Use fingers instead: they widen the "
             "device without making it taller, and come out DRC clean.")

    if stages is None:
        stages = [(nmos_params, pmos_params)] * count

    devices, stacks, blocks = [], [], []
    for i, (nparams, pparams) in enumerate(stages):
        pfet = pmos(pdk, **pparams)
        nfet = nmos(pdk, **nparams)
        stack = pair(Cell.from_component("pfet", pfet, pdk),
                     Cell.from_component("nfet", nfet, pdk),
                     pdk, minimum=pair_gap, name=f"inv{i}")
        as_cell = stack.as_cell()
        devices.append((pfet, nfet))
        stacks.append(stack)
        blocks.append(Cell(f"inv{i}", stack.width, stack.height,
                           as_cell.wells, as_cell.layers))

    # One layer above whatever the blocks reach, so the straps fly over. The
    # tallest stage sets the rail height for the whole row: shorter ones sit
    # inside it rather than each getting its own pair of rails.
    tallest = max(blocks, key=lambda b: b.height)
    # One track of channel per chained link; an unchained row needs none.
    rails = rails or Rails.above(pdk, blocks,
                                 tracks=channel_tracks if chain else 0)
    plan = plan_row(blocks, [], pdk, rails=rails)

    top = Component(name="inverter_row")
    invs: list[Inverter] = []

    for i, (stack, (pfet, nfet)) in enumerate(zip(stacks, devices)):
        cx = plan.x[i] + stack.width / 2
        offsets = stack.offsets()
        ref_p = top << pfet
        ref_n = top << nfet
        # Stages of different height share one pair of rails, so they are
        # placed against the rails rather than centred on the row: the source
        # of a small inverter has to reach the same strap as a big one.
        _center_on(ref_p, cx + offsets["pfet"][0], offsets["pfet"][1])
        _center_on(ref_n, cx + offsets["nfet"][0], offsets["nfet"][1])
        ref_p.name, ref_n.name = f"pfet_{i}", f"nfet_{i}"

        # gate to gate and drain to drain: the two links that make it an
        # inverter, and the reason the pair needs any vertical gap at all.
        top << c_route(pdk, ref_p.ports[GATE.format(side="W")],
                       ref_n.ports[GATE.format(side="W")])
        top << c_route(pdk, ref_p.ports[DRAIN.format(side="E")],
                       ref_n.ports[DRAIN.format(side="E")])
        # The body ties are not wired to their source here. Doing so needs a
        # met2 run from the tie, at the device edge, to the source port, which
        # sits inside the device -- and that run crosses the gate on the way,
        # shorting input to source. Both belong on the same rail anyway, so
        # each is taken up to it separately and meets there.
        invs.append(Inverter(ref_p, ref_n, stack))

    if chain:
        # Stage i drives stage i+1. The output leaves on the west (the drain's
        # east port is taken by the pfet-to-nfet link) and the input arrives on
        # the east (the west gate port is taken by the gate-to-gate link), so
        # the signal runs east to west and the chain is laid out right to left:
        # driving left to right would send every hop back across two blocks.
        # Pairing runs right to left: the driver is the eastern stage, whose
        # west-facing drain then points straight at the load's east-facing
        # gate. Driving the other way leaves the two ports back to back, which
        # is why straight_route silently fails to join them -- the same shape
        # Abrahan's neuron has, where the OUT-to-IN links never connected.
        # The link leaves both stages southward and runs across in the channel
        # reserved under the row. `extension` is what puts it there: left at
        # its default the crossing segment lands 0.5 um below the ports, which
        # is still inside the device, and the route merges with the tie ring
        # and the rail instead of connecting anything. Reserving the channel
        # is necessary but not sufficient -- the router has to be aimed at it.
        # The drain's south port sits at the *top* of the device and merely
        # faces south, so a route leaving through it runs down across the
        # device's own source and tie ring on the way out -- which is how the
        # link kept shorting to VSS no matter how wide the channel got. It has
        # to leave sideways instead. drain_W is horizontal and gate_S is
        # vertical, so the corner between them is an L.
        for driver, load in zip(invs[1:], invs):
            top << L_route(pdk, driver.out_port,
                           load.ref_n.ports[GATE.format(side="S")])

    _add_rails(pdk, top, invs, tallest.height, plan, rails, rectangle)
    # Signal enters at the eastern end and leaves at the western one.
    top.add_port(name="IN", port=invs[-1].in_port if chain else invs[0].in_port)
    top.add_port(name="OUT", port=invs[0].out_port if chain else invs[-1].out_port)
    return top, invs


def _add_rails(pdk, top, invs, row_height: float, plan, rails: Rails, rectangle):
    """Draw VDD above and VSS below, then tie every inverter to both.

    The rails sit one layer above the blocks. That is not a preference: a
    glayout FET occupies met2 out to its own tie ring, and its source port
    sits *inside* that ring rather than on the boundary, so a met2 drop from
    the source to a rail crosses the tie on the way out and shorts the two
    together -- which is what a first attempt here did, taking every net in
    the row with it. On met3 the strap flies over the ring untouched and only
    comes down, through a via stack, exactly on the source.

    The straps span the full row width so abutting rows can share them.
    """
    from glayout.primitives.via_gen import via_stack

    rail_layer = pdk.get_glayer(rails.glayer)
    # The rails clear the tallest stage, so every stage reaches the same
    # strap regardless of its own height.
    half = row_height / 2
    # band, not clearance: the rail sits beyond the routing channel too.
    y_vdd = pdk.snap_to_2xgrid(half + rails.band - rails.width / 2)
    y_vss = -y_vdd

    for y in (y_vdd, y_vss):
        strap = top << rectangle(
            size=pdk.snap_to_2xgrid([plan.width, rails.width]),
            layer=rail_layer, centered=True)
        _center_on(strap, pdk.snap_to_2xgrid(plan.width / 2), y)

    from glayout.util.comp_utils import evaluate_bbox

    climb = via_stack(pdk, "met2", rails.glayer)
    via_h = evaluate_bbox(climb)[1]

    # First place every via, then draw the straps: which drops can share one
    # rectangle is a property of the whole row, not of one inverter.
    via_w = evaluate_bbox(climb)[0]
    clear = via_w + float(pdk.get_grule(rails.glayer)["min_separation"])

    landings: dict[float, list[tuple[float, float]]] = {y_vdd: [], y_vss: []}
    for inv in invs:
        for source, tie, y_rail in ((inv.vdd_port, inv.vdd_tie, y_vdd),
                                    (inv.vss_port, inv.vss_tie, y_vss)):
            # The tie is the eastern port, so it lands where it is. The source
            # then has to sit east of the device midline -- the gate runs up
            # the middle and a via on it overlaps, a short no spacing rule
            # reports because the shapes touch rather than crowd -- but not so
            # far east that it crowds the tie's own via. A quarter of the port
            # width is the natural offset and works until the port is wide,
            # which is what a second multiplier does: the offset grows with
            # the port and walks the via to 0.10 um of the tie's, where met3
            # wants 0.30. Via stacks cannot be merged away like the straps
            # above them, so the offset is capped instead.
            x_tie = pdk.snap_to_2xgrid(float(tie.center[0]) + tie.width / 4)
            wanted = float(source.center[0]) + source.width / 4
            x_src = pdk.snap_to_2xgrid(min(wanted, x_tie - clear))
            if x_src <= float(source.center[0]):
                warn(f"no room east of the gate for the {y_rail:+.2f} drop on "
                     f"{source.name}; leaving it at {wanted:.3f} and expecting "
                     f"a spacing violation against the body tie")
                x_src = pdk.snap_to_2xgrid(wanted)
            for port, x in ((source, x_src), (tie, x_tie)):
                # A port marks the *edge* of its metal, not the middle:
                # centring a via on it leaves half the stack hanging off the
                # source and into whatever sits beyond -- on a glayout FET,
                # the tie ring a few tens of nm away. Step in by half a stack.
                y_via = pdk.snap_to_2xgrid(
                    float(port.center[1]) + _into_metal(port, via_h / 2))
                _center_on(top << climb, x, y_via)
                landings[y_rail].append((x, y_via))

    # Drops are minimum width, not the port's: at port width the source and
    # tie of one device sit 0.10 um apart where met3 wants 0.30, and they
    # carry the same net, so widening them buys nothing a wider rail would
    # not. Two drops that still end up closer than the rule share a single
    # rectangle instead -- same net, so merging is free, and it is the only
    # way out when the crowding comes from two different devices.
    sep = float(pdk.get_grule(rails.glayer)["min_separation"])
    for y_rail, points in landings.items():
        for group in _merge_columns(sorted(points), rails.width, sep):
            xs = [p[0] for p in group]
            left, right = min(xs) - rails.width / 2, max(xs) + rails.width / 2
            deepest = max((p[1] for p in group), key=lambda y: abs(y_rail - y))
            drop = top << rectangle(
                size=pdk.snap_to_2xgrid([right - left, abs(y_rail - deepest)]),
                layer=rail_layer, centered=True)
            _center_on(drop, pdk.snap_to_2xgrid((left + right) / 2),
                       pdk.snap_to_2xgrid((y_rail + deepest) / 2))

    top.add_port(name="VDD", port=invs[0].vdd_port)
    top.add_port(name="VSS", port=invs[0].vss_port)


# --------------------------------------------------------------------------
# the LIF cell
# --------------------------------------------------------------------------

# Ports the routing relies on, and why each side rather than another.
_GATE_MID = "multiplier_0_gate_{side}"
_DRAIN_MID = "multiplier_0_drain_{side}"


def lif_cell(pdk, inverter: dict, m5: dict, cap_size: float = 5.0,
             supply_width: float = 1.0, name: str = "lif"):
    """A LIF neuron: three inverters, the reset device and the membrane cap.

    Laid out in bands rather than as a row of inverters. Grouping by device
    type is what makes it compact: the pfets share one band, the nfets another,
    and the strip beside the long reset device -- 45% dead area in a single
    row -- holds the capacitors.

        pfets            <- top
        M5 (reset)       <- spans the full width; its length IS the cell width
        nfets + caps     <- bottom

    That puts M5 between the two halves of every inverter, so the gate and
    drain links cross it. They can, because M5 stops at met2 and met3 is free
    over the whole band. The rails then go to met4, since the capacitors reach
    met3. Nobody designed that assignment -- it falls out of asking, at each
    step, which layer is free above what has to be crossed.

    Returns (Component, dict of references).
    """
    from glayout.backend import Component, rectangle
    from glayout.primitives.fet import nmos, pmos
    from glayout.primitives.mimcap import mimcap
    from glayout.primitives.via_gen import via_stack
    from glayout.routing.c_route import c_route
    from glayout.routing.straight_route import straight_route
    from glayout.util.comp_utils import evaluate_bbox

    from .place import Band, plan_bands

    pfet_c = pmos(pdk, **inverter)
    nfet_c = nmos(pdk, with_dnwell=False, **inverter)
    m5_c = nmos(pdk, with_dnwell=False, **m5)
    cap_c = mimcap(pdk, size=(cap_size, cap_size))

    pfet = Cell.from_component("pfet", pfet_c, pdk)
    nfet = Cell.from_component("nfet", nfet_c, pdk)
    m5_cell = Cell.from_component("M5", m5_c, pdk)
    cap = Cell.from_component("cap", cap_c, pdk)

    def clones(cell, n, prefix):
        return [Cell(f"{prefix}{i}", cell.width, cell.height,
                     cell.wells, cell.layers) for i in range(n)]

    plan = plan_bands([Band("bottom", clones(nfet, 3, "nf") + clones(cap, 3, "cap")),
                       Band("m5", [m5_cell]),
                       Band("top", clones(pfet, 3, "pf"))], pdk)
    lower, middle, upper = plan.bands

    top = Component(name=name)
    nfets, pfets, caps = [], [], []
    for i in range(3):
        nfets.append(_center_on(top << nfet_c,
                                lower.plan.x[i] + nfet.width / 2, lower.y))
    for i in range(3):
        caps.append(_center_on(top << cap_c,
                               lower.plan.x[3 + i] + cap.width / 2, lower.y))
    m5_ref = _center_on(top << m5_c, middle.plan.x[0] + m5_cell.width / 2, middle.y)
    for i in range(3):
        pfets.append(_center_on(top << pfet_c,
                                upper.plan.x[i] + pfet.width / 2, upper.y))

    # --- each inverter: gate to gate, drain to drain -----------------------
    # The two links must not share a column. gate_S and drain_S both sit at
    # x=0 of the device, so routing both from there overlays them and leaves
    # every inverter diode-connected -- with the gate and drain on one net,
    # which still looks like a correctly paired inverter to a careless check.
    drain_routes = []
    for p, n in zip(pfets, nfets):
        top << straight_route(pdk, p.ports[_GATE_MID.format(side="S")],
                              n.ports[_GATE_MID.format(side="N")], glayer1="met3")
        drain_routes.append(top << c_route(
            pdk, p.ports[_DRAIN_MID.format(side="E")],
            n.ports[_DRAIN_MID.format(side="E")], cglayer="met3"))

    _wire_lif(pdk, top, nfets, caps, m5_ref, drain_routes, plan,
              via_stack, rectangle, evaluate_bbox)
    rails_y = _rails_bands(pdk, top, pfets, nfets, plan, via_stack, rectangle,
                           evaluate_bbox, supply_width, m5_ref, caps)

    top.add_port(name="IN", port=nfets[0].ports[_GATE_MID.format(side="W")])
    top.add_port(name="OUT", port=nfets[2].ports[_DRAIN_MID.format(side="W")])
    return top, {"nfets": nfets, "pfets": pfets, "caps": caps, "m5": m5_ref,
                 "rails": rails_y,
                 "plan": plan}


def _wire_lif(pdk, top, nfets, caps, m5_ref, drain_routes, plan,
              via_stack, rectangle, evaluate_bbox):
    """Fan-out and membrane node, both on met4.

    met3 is taken end to end by the per-inverter columns, so a horizontal run
    there would touch every one of them. met4 carries only the rails, at the
    very top and bottom, and is free in between.
    """
    m4 = pdk.get_glayer("met4")
    width = float(pdk.get_grule("met4")["min_width"])
    climb = via_stack(pdk, "met3", "met4")
    vw, vh = evaluate_bbox(climb)

    def strip(a, b):
        rect = top << rectangle(
            size=pdk.snap_to_2xgrid([abs(b[0] - a[0]) + width,
                                     abs(b[1] - a[1]) + width]),
            layer=m4, centered=True)
        _center_on(rect, pdk.snap_to_2xgrid((a[0] + b[0]) / 2),
                   pdk.snap_to_2xgrid((a[1] + b[1]) / 2))

    def land(x, y):
        _center_on(top << climb, pdk.snap_to_2xgrid(x), pdk.snap_to_2xgrid(y))
        return (pdk.snap_to_2xgrid(x), pdk.snap_to_2xgrid(y))

    # Both inter-band nets run in the gap between the bottom band and M5,
    # on separate tracks. Routing the fan-out down at gate level instead --
    # the obvious choice, since that is where the gate ports are -- puts a
    # met4 line straight across the nfets, exactly where their sources have
    # to drop to VSS. The met3 column of a gate spans the whole cell height,
    # so it can be tapped up here just as well.
    lower, middle, upper = plan.bands
    gap_lo = lower.y + lower.height / 2
    gap_hi = middle.y - middle.height / 2
    # El paso lo fija la PILA DE VIAS, no la pista: los cuadrados de 0.5 um
    # de cada aterrizaje son lo que se acerca entre pistas vecinas, no los
    # 0.28 del conductor. Dimensionarlo con el ancho de pista deja 0.18 um
    # donde met4 pide 0.30.
    pitch = vh + float(pdk.get_grule("met4")["min_separation"])
    y_fan = pdk.snap_to_2xgrid(gap_lo + (gap_hi - gap_lo) / 2 - pitch / 2)
    y_mem = pdk.snap_to_2xgrid(gap_lo + (gap_hi - gap_lo) / 2 + pitch / 2)

    # --- fan-out: inv0 drives inv1 and inv2 --------------------------------
    # The drain's met3 column is NOT above its port -- c_route leaves eastward
    # before climbing -- so its x comes from the route's own bbox. A gate's
    # column does sit on its port, because that link is a straight run up the
    # device centre.
    src = land(float(drain_routes[0].xmax) - width / 2, y_fan)
    loads = [land(float(nfets[i].ports[_GATE_MID.format(side="S")].center[0]), y_fan)
             for i in (1, 2)]
    strip(src, loads[-1])

    # --- membrane: M5 drain, inv0 gate, cap top plates ---------------------
    # inv0's gate column already crosses the M5 band on met3, and M5's drain
    # is met2 directly under it, so one via joins them with no route at all.
    gate_x = float(nfets[0].ports[_GATE_MID.format(side="S")].center[0])
    drain_n = m5_ref.ports[_DRAIN_MID.format(side="N")]
    bridge = via_stack(pdk, "met2", "met3")
    _center_on(top << bridge, pdk.snap_to_2xgrid(gate_x),
               pdk.snap_to_2xgrid(float(drain_n.center[1])
                                  - evaluate_bbox(bridge)[1] / 2))

    # --- feedback: inv1's output drives M5's gate --------------------------
    # M5's gate is a met2 strip running the length of the device, and inv1's
    # drain column crosses it on met3 on its way between the bands. So this
    # needs one via and no route at all, same as the membrane bridge above.
    # inv0 and inv2 cross it too; only inv1 gets a via.
    gate_m5 = m5_ref.ports[_GATE_MID.format(side="W")]
    tap = via_stack(pdk, "met2", "met3")
    _center_on(top << tap,
               pdk.snap_to_2xgrid(float(drain_routes[1].xmax) - width / 2),
               pdk.snap_to_2xgrid(float(gate_m5.center[1])))

    y_cap = float(caps[0].ports["top_met_E"].center[1])
    a = land(gate_x, y_mem)
    plates = [land(float(r.center[0]), y_cap) for r in caps]
    strip(a, (plates[0][0], y_mem))
    strip((plates[0][0], y_mem), plates[0])
    strip(plates[0], plates[-1])


def _into_metal_xy(port, w, h):
    """Offset so a via stack lands on the port's metal rather than past it."""
    angle = (port.orientation or 0) % 360
    if 45 < angle < 135:
        return (0.0, -h / 2)
    if 225 < angle < 315:
        return (0.0, +h / 2)
    if 135 <= angle <= 225:
        return (+w / 2, 0.0)
    return (-w / 2, 0.0)


def _free_x(obstacles, lo, hi, need):
    """Widest window in [lo, hi] that no obstacle x-interval covers.

    The VSS drop from M5 has to cross the bottom band, so where it can go
    depends on what is placed there -- which moves when the caller changes
    M5's length or the cap size. Compute the corridor, do not hardcode it.
    """
    best, cur = None, lo
    for a, b in sorted(obstacles):
        if a - cur >= need and (best is None or a - cur > best[1] - best[0]):
            best = (cur, a)
        cur = max(cur, b)
    if hi - cur >= need and (best is None or hi - cur > best[1] - best[0]):
        best = (cur, hi)
    return best


def _rails_bands(pdk, top, pfets, nfets, plan, via_stack, rectangle,
                 evaluate_bbox, supply_width=1.0, m5_ref=None, caps=()):
    """VDD over the pfet band, VSS under the nfet band, on met4.

    The drops are short because the bands are ordered so each device type
    faces its own rail: a pfet's source_N points up at VDD, an nfet's
    source_S down at VSS. That ordering is not free -- it is why M5 sits
    between the two halves of every inverter -- but it makes the supply
    trivial, which is most of the wiring in the cell.
    """
    # Supply runs carry the whole cell's current, so they are sized rather
    # than left at minimum width -- both the rails and the drops that feed
    # them. Minimum-width metal is for signals.
    rails = plan.rails
    layer = pdk.get_glayer(rails.glayer)
    width = max(supply_width, float(pdk.get_grule(rails.glayer)["min_width"]))

    lower, _, upper = plan.bands
    # rails.band was sized for a minimum-width rail. Keep the clearance it
    # asked for and push the wider rail outward, rather than letting the extra
    # width eat into the gap to the band.
    grow = width - rails.width
    y_vdd = pdk.snap_to_2xgrid(upper.y + upper.height / 2 + rails.band + grow
                               - width / 2)
    y_vss = pdk.snap_to_2xgrid(lower.y - lower.height / 2 - rails.band - grow
                               + width / 2)
    for y in (y_vdd, y_vss):
        strap = top << rectangle(
            size=pdk.snap_to_2xgrid([plan.width, width]),
            layer=layer, centered=True)
        _center_on(strap, pdk.snap_to_2xgrid(plan.width / 2), y)

    from glayout.routing.straight_route import straight_route

    tie_top = "met2"
    clear = float(pdk.get_grule(rails.glayer)["min_separation"]) + width / 2

    def tie_to_rail(ref, y_rail, end):
        """Source -> guard ring -> rail.

        Not source -> rail directly. The ring sits immediately west of the
        device and its west face is one port 4.1 um tall, so reaching it is a
        short straight run across ground nobody else uses -- the gate column
        goes up the middle and the drain column east of it. Dropping from the
        source instead means threading a met4 line down the height of the
        cell, which is what crossed the fan-out and membrane tracks and merged
        them into the supply.

        """
        src = ref.ports[SOURCE.format(side="W")]
        ring_in = ref.ports["tie_W_top_met_E"]
        top << straight_route(pdk, src, ring_in)

        out = ref.ports[f"tie_{end}_top_met_{end}"]
        # From met2, not met1. tie_layers=(horizontal, vertical) puts the
        # ring's N and S edges on the first layer, so climbing from met1 here
        # would add a via1 alongside the one the ring already has -- they land
        # 0.258um apart and V1.2a wants 0.26.
        climb1 = via_stack(pdk, tie_top, rails.glayer)
        w1, h1 = evaluate_bbox(climb1)
        dx, dy = _into_metal_xy(out, w1, h1)
        x = pdk.snap_to_2xgrid(float(out.center[0]) + dx)
        y = pdk.snap_to_2xgrid(float(out.center[1]) + dy)
        _center_on(top << climb1, x, y)
        rect = top << rectangle(
            size=pdk.snap_to_2xgrid([width, abs(y_rail - y)]),
            layer=layer, centered=True)
        _center_on(rect, x, pdk.snap_to_2xgrid((y_rail + y) / 2))

    def drop(port, y_rail, x=None, reach_first=False):
        """Climb from a met2 edge to the rail layer and run a wide strap down.

        reach_first keeps the strap on met2 all the way to the rail and climbs
        there instead. Use it where the climb would otherwise sit inside a
        block: at a mimcap the stack's met3 passes 0.09um from the top plate,
        which is the membrane -- a short waiting to happen, not just M3.2a.
        """
        climb = via_stack(pdk, "met2", rails.glayer)
        w, h = evaluate_bbox(climb)
        dx, dy = _into_metal_xy(port, w, h)
        px = pdk.snap_to_2xgrid(float(port.center[0]) + dx if x is None else x)
        py = pdk.snap_to_2xgrid(float(port.center[1]) + dy)
        if reach_first:
            strap = top << rectangle(
                size=pdk.snap_to_2xgrid([width, abs(y_rail - py) + h]),
                layer=pdk.get_glayer("met2"), centered=True)
            _center_on(strap, px, pdk.snap_to_2xgrid((y_rail + py) / 2))
            py = y_rail
        _center_on(top << climb, px, py)
        rect = top << rectangle(size=pdk.snap_to_2xgrid([width, abs(y_rail - py) + h]),
                                layer=layer, centered=True)
        _center_on(rect, px, pdk.snap_to_2xgrid((y_rail + py) / 2))

    if m5_ref is not None:
        # M5 sits in the middle band but its source and bulk belong to VSS at
        # the bottom, so this drop has to cross the bottom band. Send it down
        # the widest gap between the blocks placed there.
        top << straight_route(pdk, m5_ref.ports[SOURCE.format(side="W")],
                              m5_ref.ports["tie_W_top_met_E"])
        blocked = [(float(r.bbox[0][0]) - clear, float(r.bbox[1][0]) + clear)
                   for r in list(nfets) + list(caps)]
        ring = m5_ref.ports["tie_S_top_met_S"]
        lo = float(ring.center[0]) - ring.width / 2 + width / 2
        hi = float(ring.center[0]) + ring.width / 2 - width / 2
        window = _free_x(blocked, lo, hi, width)
        if window is not None:
            drop(ring, y_vss, x=(window[0] + window[1]) / 2)
        else:
            # No corridor -- a short M5 shrinks the cell until the bottom band
            # fills it. Hop to the nfet's ring instead: both are pwell taps on
            # VSS, that ring is already strapped to the rail, and it sits
            # directly below by construction, so this route always exists.
            # Longer electrically than going straight to the rail, which is
            # why it is the fallback and not the rule.
            near = min(nfets, key=lambda r: abs(float(r.center[0])
                                                - float(ring.center[0])))
            up = near.ports["tie_N_top_met_N"]
            x = pdk.snap_to_2xgrid(float(up.center[0]))
            y0, y1 = float(up.center[1]), float(ring.center[1])
            hop = top << rectangle(
                size=pdk.snap_to_2xgrid([width, abs(y1 - y0)]),
                layer=pdk.get_glayer("met2"), centered=True)
            _center_on(hop, x, pdk.snap_to_2xgrid((y0 + y1) / 2))

    for ref in caps:
        # bottom plate to VSS; the top plate is already on the membrane
        drop(ref.ports["bottom_met_S"], y_vss, reach_first=True)

    for ref in pfets:
        tie_to_rail(ref, y_vdd, "N")
    for ref in nfets:
        tie_to_rail(ref, y_vss, "S")

    return {"vdd": y_vdd, "vss": y_vss, "width": width,
            "glayer": rails.glayer}
