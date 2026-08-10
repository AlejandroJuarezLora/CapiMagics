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
                 pair_gap: float = 0.95, rails: Optional[Rails] = None):
    """A row of `count` inverters with VDD and VSS rails, wired to both.

    Returns (Component, [Inverter]). Spacing comes from place.plan_row, so the
    only distance decided here is `pair_gap` -- the room the gate and drain
    links need to turn between the two devices, which no well rule constrains
    because gf180 lets nwell and pwell abut.
    """
    from glayout.backend import Component, rectangle
    from glayout.primitives.fet import nmos, pmos
    from glayout.routing.c_route import c_route
    from glayout.routing.straight_route import straight_route

    if max(nmos_params.get("multipliers", 1), pmos_params.get("multipliers", 1)) > 1:
        warn("multipliers > 1 doubles the device height, and the rail drops "
             "then run the full way down it alongside the gate and drain "
             "links; they end up 0.10 um apart where met3 wants 0.30. The "
             "cell is still correctly connected -- only the spacing fails -- "
             "but placing the drops clear of the routing needs a router that "
             "knows where the routes are. Use fingers instead: they widen the "
             "device without making it taller, and come out DRC clean.")

    pfet = pmos(pdk, **pmos_params)
    nfet = nmos(pdk, **nmos_params)

    cell_p = Cell.from_component("pfet", pfet, pdk)
    cell_n = Cell.from_component("nfet", nfet, pdk)
    stack = pair(cell_p, cell_n, pdk, minimum=pair_gap, name="inv")

    blocks = [Cell(f"inv{i}", stack.width, stack.height,
                   stack.as_cell().wells, stack.as_cell().layers)
              for i in range(count)]
    # One layer above whatever the blocks reach, so the straps fly over.
    rails = rails or Rails.above(pdk, stack.as_cell())
    plan = plan_row(blocks, [], pdk, rails=rails)

    top = Component(name="inverter_row")
    offsets = stack.offsets()
    invs: list[Inverter] = []

    for i in range(count):
        cx = plan.x[i] + stack.width / 2
        ref_p = top << pfet
        ref_n = top << nfet
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

    _add_rails(pdk, top, invs, stack, plan, rails, rectangle)
    top.add_port(name="IN", port=invs[0].in_port)
    top.add_port(name="OUT", port=invs[-1].out_port)
    return top, invs


def _add_rails(pdk, top, invs, stack, plan, rails: Rails, rectangle):
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
    half = stack.height / 2
    y_vdd = pdk.snap_to_2xgrid(half + rails.clearance + rails.width / 2)
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
