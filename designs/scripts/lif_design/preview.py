"""Render a generated cell to PNG, with its DRC violations marked.

Numbers say a rule failed; a picture says which side of the device is already
occupied. Working from the report alone cost two full sweeps to learn that the
gate route leaves by the west and nothing else fits there -- one look at the
layout would have said so.

    python preview.py out.png cell.gds[:cell.lyrdb] [more.gds[:more.lyrdb] ...]

Several inputs are laid out as a contact sheet, which is the useful form when
comparing what one parameter did across a sweep.
"""
from __future__ import annotations

import io
import re
import sys
from collections import Counter

import gdstk
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.patches import Polygon as MplPoly

# (layer, datatype) -> colour, label, alpha. Ordered bottom of the stack up, so
# later layers paint over earlier ones the way a cross-section reads.
LAYERS = [
    ((21, 0),  "#9e9e4a", "nwell",   0.20),
    ((204, 0), "#c9a0dc", "lvpwell", 0.16),
    ((12, 0),  "#8a6d3b", "dnwell",  0.14),
    ((22, 0),  "#7ac97a", "comp",    0.45),
    ((30, 0),  "#cc3333", "poly2",   0.60),
    ((31, 0),  "#e6b800", "pplus",   0.14),
    ((32, 0),  "#5b9bd5", "nplus",   0.14),
    ((33, 0),  "#000000", "contact", 0.85),
    ((34, 0),  "#3b6fd4", "met1",    0.45),
    ((35, 0),  "#111111", "via1",    0.85),
    ((36, 0),  "#d45f3b", "met2",    0.45),
    ((38, 0),  "#222222", "via2",    0.85),
    ((42, 0),  "#2e9e57", "met3",    0.55),
    ((40, 0),  "#333333", "via3",    0.85),
    ((46, 0),  "#8e44ad", "met4",    0.60),
    ((41, 0),  "#333333", "via4",    0.85),
    ((81, 0),  "#e07b39", "met5",    0.60),
    ((75, 0),  "#c026d3", "fusetop", 0.70),
    ((117, 5), "#7a7a7a", "CAP_MK",  0.16),
]


def violations(report: str):
    """Centres and per-rule counts from a KLayout lyrdb report.

    Coordinates come as `x1,y1;x2,y2;...` and sometimes as exact fractions,
    so the numeric part is taken before any '/'.
    """
    points, rules = [], Counter()
    try:
        text = io.open(report, encoding="utf-8", errors="ignore").read()
    except OSError:
        return points, rules
    for chunk in text.split("<item>")[1:]:
        rule = re.search(r"<category>'?([^<']+)'?</category>", chunk)
        vals = re.search(r"<values>(.*?)</values>", chunk, re.S)
        if not rule:
            continue
        rules[rule.group(1)] += 1
        if not vals:
            continue
        nums = re.findall(r"(-?\d+(?:\.\d+)?)(?:/\d+)?", vals.group(1))
        xs = [float(n) for n in nums[0::2]]
        ys = [float(n) for n in nums[1::2]]
        if xs and ys:
            points.append((sum(xs) / len(xs), sum(ys) / len(ys)))
    return points, rules


def draw(ax, gds: str, report: str | None, title: str | None = None) -> None:
    cell = gdstk.read_gds(gds).top_level()[0]
    polys = cell.get_polygons()
    for key, colour, _name, alpha in LAYERS:
        for poly in polys:
            if (poly.layer, poly.datatype) == key:
                ax.add_patch(MplPoly(poly.points, closed=True, facecolor=colour,
                                     edgecolor="none", alpha=alpha, linewidth=0))

    points, rules = violations(report) if report else ([], Counter())
    for cx, cy in points:
        ax.plot(cx, cy, "o", ms=10, mfc="none", mec="red", mew=1.6, zorder=5)

    box = cell.bounding_box()
    w, h = box[1][0] - box[0][0], box[1][1] - box[0][1]
    ax.set_xlim(box[0][0] - 1, box[1][0] + 1)
    ax.set_ylim(box[0][1] - 1, box[1][1] + 1)
    ax.set_aspect("equal")
    ax.grid(alpha=0.15, lw=0.4)
    detail = "  ".join(f"{k} x{v}" for k, v in rules.most_common(3))
    ax.set_title(f"{title or cell.name}\n{w:.2f} x {h:.2f} um = {w * h:.0f} um2"
                 f"   DRC {sum(rules.values())}\n{detail or 'sin violaciones'}",
                 fontsize=9)


def main(out: str, specs: list[str]) -> None:
    cols = min(3, len(specs))
    rows = (len(specs) + cols - 1) // cols
    fig, axes = plt.subplots(rows, cols, figsize=(6.5 * cols, 6.0 * rows),
                             squeeze=False)
    flat = [ax for row in axes for ax in row]

    for ax, spec in zip(flat, specs):
        gds, _, report = spec.partition(":")
        label = gds.rsplit("/", 1)[-1].rsplit(".", 1)[0]
        draw(ax, gds, report or None, label)
    for ax in flat[len(specs):]:
        ax.axis("off")

    handles = [Line2D([0], [0], marker="s", color="none", markersize=10,
                      markerfacecolor=c, alpha=min(1, a + 0.3), label=n)
               for _, c, n, a in LAYERS]
    handles.append(Line2D([0], [0], marker="o", color="none", markersize=9,
                          markerfacecolor="none", markeredgecolor="red",
                          label="violacion DRC"))
    flat[0].legend(handles=handles, loc="upper left",
                   bbox_to_anchor=(1.01, 1.0) if len(specs) == 1 else (0, -0.08),
                   ncol=1 if len(specs) == 1 else 8,
                   fontsize=8, frameon=False)

    plt.tight_layout()
    plt.savefig(out, dpi=140, bbox_inches="tight", facecolor="white")
    print(f"escrito {out}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    main(sys.argv[1], sys.argv[2:])
