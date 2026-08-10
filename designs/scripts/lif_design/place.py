"""Placement: where blocks go, in terms the PDK can justify.

Every distance this module produces is either read from a design rule or
derived from the routes that have to fit -- never a tuning factor. That is the
whole point: `9 * util_max_metal_seperation()` places a transistor just as
well as the right number does, right up until someone changes the device size
and the layout silently stops being minimal, or silently stops being legal.

Three facts about glayout make this possible without generating and measuring:

  * `evaluate_bbox(comp)` gives the size of a generated cell,
  * the `well_N/S/E/W` ports give the well outline *and its layer*, and
  * the component's own polygons say how far up the stack it reaches.

On a gf180 FET the first two coincide -- the cell bounding box is the well --
so the clearance between two adjacent blocks is a well-to-well rule, not a
metal one. That distinction is not academic: on the LIF neuron the binding
constraint is NW.2b (nwell to nwell, 1.4 um) between neighbouring pfets, while
the metal separation is 0.3 um. Spacing blocks by the metal rule produces a
layout that looks generous and still fails DRC.

Routing does *not* enter the gap. A wire does not need a corridor between two
blocks; it needs a layer that is free above the blocks it crosses. gf180 FETs
stop at met2, so anything on met3 flies straight over them and the gap never
hears about it. That is why the block dimension dominates: gaps are a
well-clearance question and nothing else.

What routing does decide is whether a net is routable at all. A net stuck on a
layer that one of the blocks under it already occupies has to climb or detour
-- and a detour costs row height, not gap. `clearances()` reports that, so the
choice is visible instead of being discovered as a short.

Typical use:

    p = Cell.from_component("pfet", pmos(pdk, ...), pdk)
    n = Cell.from_component("nfet", nmos(pdk, ...), pdk)
    inv = pair(p, n, pdk)
    row = plan_row([inv.as_cell()] * 3, nets, pdk)
    for c in clearances(nets, [inv.as_cell()] * 3, pdk):
        print(c)

Nothing here writes layout. It returns coordinates; the generator applies them.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional, Sequence

# glayer name for each well layer a cell might carry. Kept as a mapping rather
# than a lookup on the pdk because a cell reports the *layer* of its well port
# and the rules are keyed by glayer name.
_WELL_GLAYERS = ("nwell", "pwell", "dnwell")

# Routing layers, bottom to top. A net can fly over a block when its layer sits
# strictly above everything the block occupies.
_STACK = ("met1", "met2", "met3", "met4", "met5")


def _level(glayer: Optional[str]) -> int:
    """Height of a glayer in the metal stack; -1 for anything below met1."""
    return _STACK.index(glayer) if glayer in _STACK else -1


# --------------------------------------------------------------------------
# what a placeable thing is
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Cell:
    """A generated block: its size, and which well its outline is.

    `well` is the glayer name ("nwell", "pwell") or None for a block with no
    well of its own -- a mimcap, say. Blocks without a well have no well
    clearance to anything, so their spacing comes from routing alone.
    """
    name: str
    width: float
    height: float
    wells: tuple = ()                 # (glayer, inset from this cell's side edge)
    layers: frozenset = frozenset()   # every glayer the block's geometry uses

    @property
    def well(self) -> Optional[str]:
        """The outermost well, for reporting."""
        if not self.wells:
            return None
        return min(self.wells, key=lambda w: w[1])[0]

    @property
    def top_layer(self) -> Optional[str]:
        """Highest routing layer the block reaches; None if it has no metal."""
        metals = [l for l in self.layers if l in _STACK]
        return max(metals, key=_level) if metals else None

    @classmethod
    def from_component(cls, name: str, comp, pdk) -> "Cell":
        """Read size, wells and occupied layers off a generated Component."""
        from glayout.util.comp_utils import evaluate_bbox

        w, h = evaluate_bbox(comp)
        found = _well_of(comp, pdk)
        return cls(name=name, width=float(w), height=float(h),
                   wells=((found, 0.0),) if found else (),
                   layers=_layers_of(comp, pdk))


def _polygons(comp):
    """Every polygon in a Component, on either glayout backend.

    gdsfactory exposes get_polygons(); the gdstk shim keeps them on the
    underlying cell. Both are tried rather than picking one, so a cell built
    under either backend reads the same.
    """
    getter = getattr(comp, "get_polygons", None)
    if callable(getter):
        got = getter()
        if got:
            return got
    cell = getattr(comp, "_cell", None)
    if cell is not None:
        return cell.get_polygons()
    return []


def _layers_of(comp, pdk) -> frozenset:
    """Every glayer the block's own geometry occupies.

    The whole set, not just the highest: two blocks that share a layer owe
    each other that layer's separation even when neither has a well. The
    highest one alone decides what can fly over.
    """
    out = set()
    for poly in _polygons(comp):
        try:
            out.add(pdk.layer_to_glayer((poly.layer, poly.datatype)))
        except Exception:
            continue
    return frozenset(out - {None})


def _well_of(comp, pdk) -> Optional[str]:
    """The glayer name of the cell's well, from its well_* ports."""
    layers = {tuple(p.layer) for nm, p in comp.ports.items()
              if nm.startswith("well_")}
    if not layers:
        return None
    for glayer in _WELL_GLAYERS:
        try:
            if tuple(pdk.get_glayer(glayer)) in layers:
                return glayer
        except (KeyError, ValueError):
            continue
    return None


# --------------------------------------------------------------------------
# the two distances
# --------------------------------------------------------------------------

def well_clearance(pdk, a: Cell, b: Cell) -> float:
    """Space the wells demand between two blocks placed side by side.

    Every well of one block is checked against every well of the other, and
    each pair's requirement is reduced by how far those wells sit inside their
    own block. A stacked pair is the case that needs this: its pfet is
    narrower than its nfet, so the nwell starts further in and two neighbouring
    pairs can stand closer than the raw nwell rule suggests. Collapsing a
    stack to a single well throws that away and, when the two well rules
    differ, gets the answer wrong in the unsafe direction.
    """
    worst = 0.0
    for well_a, inset_a in a.wells:
        for well_b, inset_b in b.wells:
            try:
                rule = pdk.get_grule(well_a, well_b) or {}
            except (KeyError, ValueError):
                continue
            need = float(rule.get("min_separation", 0.0)) - inset_a - inset_b
            worst = max(worst, need)
    return worst


def pitch(pdk, glayer: str = "met2") -> float:
    """Centre-to-centre spacing of two wires on `glayer`.

    Not used for gaps -- gaps are a well question. This is for sizing a track
    budget when a net really does have to run alongside others on one layer.
    """
    rule = pdk.get_grule(glayer)
    return float(rule["min_width"]) + float(rule["min_separation"])


def shared_clearance(pdk, a: Cell, b: Cell) -> tuple[float, Optional[str]]:
    """Widest separation demanded by a layer both blocks occupy.

    Two blocks facing each other on the same layer owe that layer's spacing
    even when neither has a well -- a mimcap has no well at all and still
    cannot sit flush against a transistor's met2.
    """
    worst, which = 0.0, None
    for glayer in a.layers & b.layers:
        try:
            sep = float((pdk.get_grule(glayer) or {}).get("min_separation", 0.0))
        except (KeyError, ValueError):
            continue
        if sep > worst:
            worst, which = sep, glayer
    return worst, which


def gap_between(pdk, a: Cell, b: Cell, minimum: float = 0.0) -> float:
    """The gap two neighbouring blocks need.

    The wells and the layers they share set this; routes do not, because they
    cross above the blocks rather than through the space between them.
    `minimum` is an explicit floor for the caller who wants one -- a seal
    ring, a keep-out -- not a fudge factor.
    """
    return max(well_clearance(pdk, a, b), shared_clearance(pdk, a, b)[0], minimum)


# --------------------------------------------------------------------------
# a complementary pair, stacked
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Stack:
    """Two blocks one above the other, centred on the same vertical axis.

    Centre alignment is not a stylistic choice here -- it is the invariant the
    LIF inverters already hold (measured: 0.000 um offset across all three),
    and holding it keeps the gate and drain links vertical, which is what lets
    the gap be one channel wide instead of a detour.
    """
    name: str
    top: Cell
    bottom: Cell
    gap: float

    @property
    def width(self) -> float:
        return max(self.top.width, self.bottom.width)

    @property
    def height(self) -> float:
        return self.top.height + self.gap + self.bottom.height

    def as_cell(self) -> Cell:
        """Treat the stack as one block for row planning.

        Both members' wells are carried through, each with the inset that its
        own width gives it against the stack's side. Nothing is collapsed:
        which well ends up binding is left to the spacing rules.
        """
        wells = []
        for member in (self.top, self.bottom):
            inset = (self.width - member.width) / 2
            wells.extend((name, base + inset) for name, base in member.wells)
        return Cell(self.name, self.width, self.height, tuple(wells),
                    self.top.layers | self.bottom.layers)

    def offsets(self) -> dict[str, tuple[float, float]]:
        """Centre of each member relative to the stack centre."""
        half = self.height / 2
        return {
            self.top.name: (0.0, half - self.top.height / 2),
            self.bottom.name: (0.0, self.bottom.height / 2 - half),
        }


def pair(top: Cell, bottom: Cell, pdk, minimum: float = 0.0,
         name: Optional[str] = None) -> Stack:
    """Stack two blocks, centre-aligned, with the gap the wells require.

    On gf180 nwell and pwell may abut, so a complementary pair has no
    well-driven gap at all and `minimum` is what keeps them apart -- measured
    on the LIF inverter, 0.950 um is enough for the gate and drain links to
    turn.
    """
    return Stack(name=name or f"{top.name}_{bottom.name}",
                 top=top, bottom=bottom,
                 gap=gap_between(pdk, top, bottom, minimum))


# --------------------------------------------------------------------------
# power rails
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Rails:
    """The VDD and VSS bands that bound a row.

    Rails are declared up front rather than routed afterwards because they set
    the row height and the orientation of everything in it. A placement that
    ignores them has to be redone once they arrive -- which is how the LIF
    neuron ended up with VDD and VSS exposed as ports and connected to
    nothing.
    """
    glayer: str = "met2"
    width: float = 0.0        # rail conductor width, um
    clearance: float = 0.0    # rail to nearest block, um

    @classmethod
    def minimum(cls, pdk, glayer: str = "met2", width: Optional[float] = None) -> "Rails":
        rule = pdk.get_grule(glayer)
        return cls(glayer=glayer,
                   width=float(width if width is not None else rule["min_width"]),
                   clearance=float(rule["min_separation"]))

    @classmethod
    def above(cls, pdk, block: Cell, width: Optional[float] = None) -> "Rails":
        """Rails on the first layer the block leaves free.

        A rail on a layer the block already uses has to weave around its
        contents; one layer up it crosses them without touching. Same rule
        that decides whether a net can fly over -- rails are just nets that
        every cell in the row connects to.
        """
        level = _level(block.top_layer) + 1
        if level >= len(_STACK):
            raise ValueError(
                f"{block.name} reaches {block.top_layer}, the top of the "
                f"stack -- no free layer left for rails")
        return cls.minimum(pdk, _STACK[level], width)

    @property
    def band(self) -> float:
        """Vertical space one rail costs the row."""
        return self.width + self.clearance


# --------------------------------------------------------------------------
# a row of blocks
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class Net:
    """A connection between block ports, written as `block.port`."""
    name: str
    endpoints: tuple[str, ...]

    def blocks(self) -> set[str]:
        return {e.split(".", 1)[0] for e in self.endpoints}


@dataclass(frozen=True)
class Clearance:
    """Whether a net can cross the blocks between its endpoints.

    `layer` is the lowest one that clears them all; None means every routing
    layer is occupied somewhere along the way and the net has to go around.
    """
    net: str
    spans: tuple[str, ...]        # blocks it passes over
    blocked_by: tuple[str, ...]   # blocks reaching the top of the stack
    layer: Optional[str]

    def __str__(self) -> str:
        if not self.spans:
            return f"{self.net}: adjacent, nothing to cross"
        over = ", ".join(self.spans)
        if self.layer:
            return f"{self.net}: flies over {over} on {self.layer}"
        return (f"{self.net}: no free layer over {over} "
                f"(blocked by {', '.join(self.blocked_by)}) -- must detour")


def clearances(nets: Sequence[Net], blocks: Sequence[Cell], pdk=None
               ) -> list[Clearance]:
    """For each net, the lowest layer that clears the blocks it spans.

    Blocks keep the order given; a net spans everything strictly between its
    leftmost and rightmost endpoint. A net whose endpoints are neighbours
    crosses nothing and is always routable.
    """
    order = [b.name for b in blocks]
    index = {name: i for i, name in enumerate(order)}
    by_name = {b.name: b for b in blocks}
    out = []

    for net in nets:
        touched = sorted((index[b] for b in net.blocks() if b in index))
        if len(touched) < 2:
            out.append(Clearance(net.name, (), (), _STACK[0]))
            continue
        spanned = [order[i] for i in range(touched[0] + 1, touched[-1])]
        if not spanned:
            out.append(Clearance(net.name, (), (), _STACK[0]))
            continue
        highest = max(_level(by_name[n].top_layer) for n in spanned)
        layer = _STACK[highest + 1] if highest + 1 < len(_STACK) else None
        blocked = tuple(n for n in spanned
                        if _level(by_name[n].top_layer) == highest) if layer is None else ()
        out.append(Clearance(net.name, tuple(spanned), blocked, layer))
    return out


@dataclass
class RowPlan:
    """Coordinates and the reasoning behind them."""
    order: list[str]
    x: list[float] = field(default_factory=list)       # left edge of each block
    gaps: list[float] = field(default_factory=list)    # len == len(order) - 1
    binding: list[str] = field(default_factory=list)   # what set each gap
    width: float = 0.0
    height: float = 0.0
    rails: Optional[Rails] = None
    notes: list[str] = field(default_factory=list)

    def report(self) -> str:
        out = [f"row {self.width:.3f} x {self.height:.3f} um"]
        if self.rails:
            out.append(f"  rails on {self.rails.glayer}: "
                       f"{self.rails.width:.3f} um wide, "
                       f"{self.rails.band:.3f} um per band")
        for i, name in enumerate(self.order):
            out.append(f"  x={self.x[i]:8.3f}  {name}")
            if i < len(self.gaps):
                out.append(f"  {'gap':>9} {self.gaps[i]:6.3f} um  "
                           f"(set by {self.binding[i]})")
        out.extend(f"  note: {n}" for n in self.notes)
        return "\n".join(out)


def plan_row(blocks: Sequence[Cell], nets: Sequence[Net], pdk,
             rails: Optional[Rails] = None, minimum: float = 0.0) -> RowPlan:
    """Place blocks left to right in the order given.

    Gaps come from the wells. Nets are read only to report which of them have
    to detour -- they never widen the row, because they cross above it.
    """
    order = [b.name for b in blocks]
    plan = RowPlan(order=order, rails=rails)

    dupes = {n for n in order if order.count(n) > 1}
    if dupes:
        plan.notes.append(f"repeated block names, gaps may be misattributed: "
                          f"{sorted(dupes)}")

    unknown = {e.split('.', 1)[0] for n in nets for e in n.endpoints} - set(order)
    if unknown:
        plan.notes.append(f"nets reference blocks not in the row: {sorted(unknown)}")

    for i in range(len(blocks) - 1):
        by_well = well_clearance(pdk, blocks[i], blocks[i + 1])
        by_layer, layer = shared_clearance(pdk, blocks[i], blocks[i + 1])
        plan.gaps.append(max(by_well, by_layer, minimum))
        if by_well >= max(by_layer, minimum):
            plan.binding.append(
                f"wells ({blocks[i].well}/{blocks[i + 1].well})"
                if by_well > 0 else "nothing -- blocks may abut")
        elif by_layer >= minimum:
            plan.binding.append(f"shared {layer}")
        else:
            plan.binding.append("caller minimum")

    for c in clearances(nets, blocks, pdk):
        if c.spans and c.layer is None:
            plan.notes.append(str(c))

    x = 0.0
    for i, b in enumerate(blocks):
        plan.x.append(x)
        x += b.width
        if i < len(plan.gaps):
            x += plan.gaps[i]

    plan.width = x
    tall = max((b.height for b in blocks), default=0.0)
    plan.height = tall + (2 * rails.band if rails else 0.0)
    return plan
