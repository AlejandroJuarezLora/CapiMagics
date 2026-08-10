"""Spacing between blocks in a row, from the nets that cross each gap.

The gap between two adjacent blocks is not a constant: it has to hold the
routes that pass *through* it. A net between neighbours needs no channel, but
one that reaches over an intermediate block does, and so does one that runs
backwards. Sizing every gap the same way either wastes area or leaves the
router without room.

    gaps = plan_row(blocks, nets, pdk)

Blocks keep the order they are given -- this only computes spacing. It also
does not place anything: it returns the numbers, and the layout code applies
them.
"""
from __future__ import annotations

from dataclasses import dataclass, field


@dataclass(frozen=True)
class Block:
    """A placed cell: its name and how wide it is."""
    name: str
    width: float          # um
    height: float = 0.0   # um, only used for the row height


@dataclass(frozen=True)
class Net:
    """A connection between block ports, as `block.port`."""
    name: str
    endpoints: tuple[str, ...]

    def blocks(self) -> set[str]:
        return {e.split(".", 1)[0] for e in self.endpoints}


@dataclass
class RowPlan:
    """What plan_row worked out."""
    order: list[str]
    gaps: list[float] = field(default_factory=list)      # len == len(order)-1
    x: list[float] = field(default_factory=list)         # left edge of each block
    width: float = 0.0
    tracks: list[int] = field(default_factory=list)      # nets crossing each gap
    notes: list[str] = field(default_factory=list)

    def report(self) -> str:
        lines = [f"row: {self.width:.2f} um wide"]
        for i, name in enumerate(self.order):
            lines.append(f"  x={self.x[i]:8.2f}  {name}")
            if i < len(self.gaps):
                lines.append(f"  {'gap':>9} {self.gaps[i]:6.2f} um "
                             f"({self.tracks[i]} net{'s' if self.tracks[i] != 1 else ''} crossing)")
        lines.extend(f"  note: {n}" for n in self.notes)
        return "\n".join(lines)


def _crossings(nets, order, gap_index):
    """Nets that span the gap between order[gap_index] and order[gap_index+1].

    A net crosses if it touches a block on each side. Neighbour-to-neighbour
    connections do touch both sides, but they terminate at the gap rather than
    running through it, so they are not counted as needing a channel.
    """
    left = set(order[:gap_index + 1])
    right = set(order[gap_index + 1:])
    out = []
    for net in nets:
        touched = net.blocks()
        if not (touched & left and touched & right):
            continue
        # only the two blocks flanking the gap -> it terminates here
        if touched <= {order[gap_index], order[gap_index + 1]}:
            continue
        out.append(net)
    return out


def plan_row(blocks: list[Block], nets: list[Net], pdk,
             glayer: str = "met2", min_gap: float | None = None) -> RowPlan:
    """Lay blocks left to right, sizing each gap for the nets crossing it.

    blocks keep their given order. min_gap defaults to the PDK's metal
    separation, which is the floor even where nothing crosses.
    """
    order = [b.name for b in blocks]
    plan = RowPlan(order=order)

    rule = pdk.get_grule(glayer)
    pitch = rule["min_width"] + rule["min_separation"]
    floor = min_gap if min_gap is not None else pdk.util_max_metal_seperation()

    unknown = {e.split(".", 1)[0] for n in nets for e in n.endpoints} - set(order)
    if unknown:
        plan.notes.append(
            f"nets reference blocks that are not in the row: {sorted(unknown)}")

    for i in range(len(blocks) - 1):
        crossing = _crossings(nets, order, i)
        needed = len(crossing) * pitch
        gap = max(floor, needed)
        plan.tracks.append(len(crossing))
        plan.gaps.append(gap)
        if crossing:
            plan.notes.append(
                f"gap {order[i]}->{order[i+1]}: {len(crossing)} x {pitch:.3f} um "
                f"for {', '.join(n.name for n in crossing)}")

    x = 0.0
    for i, b in enumerate(blocks):
        plan.x.append(x)
        x += b.width
        if i < len(plan.gaps):
            x += plan.gaps[i]
    plan.width = x
    return plan
