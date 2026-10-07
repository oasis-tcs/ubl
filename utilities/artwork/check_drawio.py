#!/usr/bin/env python3
"""Check a UBL figure's draw.io drawing, the figure's source of truth.

    python3 tools/check_drawio.py <figure>.drawio ...            conventions
    python3 tools/check_drawio.py --against <dir> <figure>.drawio ...
                                  and the model it holds against <dir>/<figure>/<figure>-diagram.json

The drawing holds the whole model: every lane, node, flow, text, off-page
flow, mark and phase is an element with the model's id and its kind
(`ubl-kind`), and what the drawing does not show by itself is kept on the
element as custom properties (`ubl-...`, draw.io's Edit Data). This reads the
model back out of the drawing.

Conventions checked (after an edit in draw.io, too):
  - every element has a known `ubl-kind`, and ids are unique;
  - the frame is the pool, and the lanes are its children;
  - every node stands in a lane (a child of one);
  - a flow is attached at both ends, to nodes; a flow leaving the page at
    exactly one;
  - a flow's guard names a text of its own, and no text is used twice;
  - the file is in the form draw.io's editor writes (tools/drawio_format.py): so that a
    text diff against a drawing saved from the editor shows only what differs; it
    is checked for illustrations too. Rewrite with `python3 tools/drawio_format.py <file>`.

Warned about (not a fault, but the model is poorer without it): a flow
without its kind (ubl-flow), a document across a lane divider without the
parties it passes between (ubl-between), an arrow shorter than 3 times its
head (the stretch after its last bend).

A figure of another notation (Groups A, B, C: a BPMN drawing, a phase map, an overview, a reference
figure; history/group-*, marked by ubl-notation) has no pool of lanes: it is checked for unique ids,
attached flows, a kind on every element (where the drawing has kinds) and, in a BPMN drawing that has
them (Ordering), a BPMN type on every element (ubl-bpmn-type). A drawing of the TC's own, adopted as it
is (history/group-a), has no kinds at all: said as a warning, not a finding.

An illustration (its frame of ubl-kind "illustration": the Fulfilment and the
CPFR step figures, history/illustrations) is not a UML diagram and holds no
model: it is not checked, and said so.

With --against, the model read from the drawing must equal the diagram JSON,
field for field - all but what records how the PNG was read (a flow's
direction, the figure's source PNG). Exit status 1 on any finding.
"""
import html, json, os, re, sys
import xml.etree.ElementTree as ET

NODE_KINDS = {"initial", "final", "action", "object", "decision", "fork", "note"}
KINDS = NODE_KINDS | {"frame", "lane", "flow", "off-page-flow", "text", "mark", "phase-boundary",
                      "band-divider", "band-title", "lane-divider"}
NOT_KEPT = {"flows": {"direction"}}


def field(prop):
    """ubl-linked-process -> linkedProcess"""
    parts = prop[4:].split("-")
    return parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:])


def value(v):
    try:
        return json.loads(v)
    except ValueError:
        return v


def words(label):
    """a label's words, a newline where the drawing breaks the line"""
    t = re.sub(r"<br\s*/?>", "\n", label or "")
    return html.unescape(re.sub(r"<[^>]+>", "", t))


def read(path):
    root = ET.parse(path).getroot()
    graph = root.find(".//mxGraphModel/root")
    if graph is None:
        raise ValueError("no uncompressed mxGraphModel")
    cells, order = {}, []
    for el in graph:
        c = el if el.tag == "mxCell" else el.find("mxCell")
        ident = el.get("id")
        if ident in cells:
            raise ValueError("duplicate id %s" % ident)
        attrs = dict(el.attrib) if el.tag == "object" else {}
        cells[ident] = dict(id=ident, kind=attrs.get("ubl-kind"), label=attrs.get("label", el.get("value", "")),
                            attrs=attrs, parent=c.get("parent") if c is not None else None,
                            source=c.get("source") if c is not None else None,
                            target=c.get("target") if c is not None else None,
                            edge=c is not None and c.get("edge") == "1",
                            style=c.get("style", "") if c is not None else "",
                            geo=c.find("mxGeometry") if c is not None else None)
        order.append(ident)
    return cells, order


def own(cell):
    """an element's own words: its label, or where that shows another text, ubl-label"""
    return cell["attrs"]["ubl-label"] if "ubl-label" in cell["attrs"] else words(cell["label"])


def props(cell, skip=()):
    return {field(k): value(v) for k, v in cell["attrs"].items()
            if k.startswith("ubl-") and k not in skip and not k.startswith("ubl-text")}


def conventions(cells):
    out = []
    lanes = {i for i, c in cells.items() if c["kind"] == "lane"}
    for i, c in cells.items():
        if i in ("0", "1"):
            continue
        if c["kind"] not in KINDS:
            out.append("%s: no known ubl-kind (%r): take the element from tools/ubl-library.xml, "
                       "or give it one in Edit Data" % (i, c["kind"]))
    if "frame" not in cells or "childLayout=stackLayout" not in cells["frame"]["style"]:
        out.append("frame: missing, or not a pool")
    for i in lanes:
        if cells[i]["parent"] != "frame":
            out.append("%s: a lane outside the pool" % i)
    for i, c in cells.items():
        if c["kind"] in NODE_KINDS and c["parent"] not in lanes:
            out.append("%s: a node outside the lanes" % i)
        if c["kind"] == "flow":
            for end in ("source", "target"):
                t = cells.get(c[end])
                if t is None or t["kind"] not in NODE_KINDS:
                    out.append("%s: %s not attached to a node" % (i, end))
        if c["kind"] == "off-page-flow" and bool(c["source"]) == bool(c["target"]):
            out.append("%s: a flow leaving the page must be attached at exactly one end" % i)
    guards = [c["attrs"].get("ubl-guard") for c in cells.values() if c["attrs"].get("ubl-guard")]
    for g in {g for g in guards if guards.count(g) > 1}:
        out.append("text %s: the guard of more than one flow" % g)
    return out


def warnings(cells):
    """model facts an edit may have left out: not wrong in the drawing, but the
    model is poorer without them"""
    out = []
    lanes = {i: c for i, c in cells.items() if c["kind"] == "lane"}
    for i, c in cells.items():
        if c["kind"] == "flow" and not c["attrs"].get("ubl-flow") and not c["attrs"].get("ubl-draws"):
            out.append("%s: a flow without its kind (ubl-flow: control, object, ...)" % i)
        if c["kind"] == "object" and c["parent"] in lanes and not c["attrs"].get("ubl-between"):
            g, lg = c["geo"], lanes[c["parent"]]["geo"]
            x, w, lw = float(g.get("x", 0)), float(g.get("width", 0)), float(lg.get("width", 0))
            if x < 0 or x + w > lw:
                out.append("%s: a document across a lane divider without the parties it passes between "
                           "(ubl-between: [\"lane-...\", \"lane-...\"])" % i)
    # an arrow at least 3 times its head long: the stretch after its last bend
    def at(i):
        c = cells[i]; x = y = 0.0
        while c is not None and c["geo"] is not None and c["geo"].get("relative") != "1" and not c["edge"]:
            x += float(c["geo"].get("x", 0)); y += float(c["geo"].get("y", 0)); c = cells.get(c["parent"])
        return x, y
    for i, c in cells.items():
        if not c["edge"] or not c["target"] or c["target"] not in cells:
            continue
        st = dict(p.split("=", 1) for p in c["style"].split(";") if "=" in p)
        if st.get("endArrow") in (None, "none") or "entryX" not in st:
            continue
        t = cells[c["target"]]; tx, ty = at(c["target"])
        q = (tx + float(st["entryX"]) * float(t["geo"].get("width")), ty + float(st["entryY"]) * float(t["geo"].get("height")))
        pts = c["geo"].find("Array")
        if pts is not None and len(pts):
            ox, oy = at(c["parent"]) if c["parent"] in cells and not cells[c["parent"]]["edge"] else (0.0, 0.0)
            m = pts.findall("mxPoint")[-1]; p = (float(m.get("x", 0)) + ox, float(m.get("y", 0)) + oy)
        elif c["source"] in cells and "exitX" in st:
            s_ = cells[c["source"]]; sx, sy = at(c["source"])
            p = (sx + float(st["exitX"]) * float(s_["geo"].get("width")), sy + float(st["exitY"]) * float(s_["geo"].get("height")))
        else:
            continue
        head = float(st.get("endSize", 6))
        if ((p[0] - q[0]) ** 2 + (p[1] - q[1]) ** 2) ** 0.5 + 0.01 < 3 * head:
            out.append("%s: an arrow shorter than 3 times its head (%d px): make room in draw.io by Ctrl+Shift+dragging on the background (insert space)"
                       % (i, 3 * head))
    return out


def model_of(cells, order):
    """the model the drawing holds, as tools/schema/diagram.schema.json has it"""
    frame = cells.get("frame", {"attrs": {}})
    lanes = sorted((c for c in cells.values() if c["kind"] == "lane"), key=lambda c: float(c["geo"].get("x", 0)))
    lane_ids = {c["id"] for c in lanes}

    def lane_of(c):
        while c is not None:
            if c["parent"] in lane_ids:
                return c["parent"]
            c = cells.get(c["parent"])
        return None
    m = {"lanes": [], "nodes": [], "flows": [], "texts": [], "offPage": [], "marks": [], "phases": []}
    for k, c in enumerate(lanes):
        m["lanes"].append(dict(id=c["id"], axis="column", index=k, title=own(c), **props(c, {"ubl-kind", "ubl-label"})))
    for i in order:
        c = cells[i]
        if c["kind"] in NODE_KINDS:
            p = props(c, {"ubl-kind", "ubl-lane", "ubl-label"})
            lane = value(c["attrs"]["ubl-lane"]) if "ubl-lane" in c["attrs"] else lane_of(c)
            m["nodes"].append(dict(id=i, kind=c["kind"], label=own(c), lane=lane, **p))
        elif c["kind"] == "flow" and "ubl-draws" in c["attrs"]:
            # one line drawn for several flows: the flows it stands for
            m["flows"].extend(value(c["attrs"]["ubl-draws"]))
        elif c["kind"] == "flow":
            p = props(c, {"ubl-kind", "ubl-guard", "ubl-flow"})
            f = dict(id=i, **{"from": c["source"], "to": c["target"]}, kind=c["attrs"].get("ubl-flow"), **p)
            if c["attrs"].get("ubl-guard"):
                f["guard"] = c["attrs"]["ubl-guard"]
            m["flows"].append(f)
        elif c["kind"] == "off-page-flow":
            a = c["attrs"]
            o = dict(id=i, node=c["source"] or c["target"], direction=a.get("ubl-direction"),
                     arrow="endArrow=none" not in c["style"], continues=a.get("ubl-continues"),
                     port=int(a["ubl-port"]) if a.get("ubl-port") else None, counterpart=a.get("ubl-counterpart"))
            if a.get("ubl-guard"):
                o["guard"] = a["ubl-guard"]
            m["offPage"].append(o)
        elif c["kind"] == "mark":
            m["marks"].append(dict(id=i, kind=c["attrs"].get("ubl-mark"), **props(c, {"ubl-kind", "ubl-mark"})))
        if "ubl-members" in c["attrs"]:
            m["phases"].append(dict(id=i, title=own(c), **props(c, {"ubl-kind", "ubl-label"})))
        # texts: an element of their own, or the label of the element they sit on
        if c["kind"] == "text":
            m["texts"].append(dict(id=i, text=c["attrs"].get("ubl-text-" + i, words(c["label"])), **props(c, {"ubl-kind"})))
        for n, t in enumerate((c["attrs"].get("ubl-text") or "").split()):
            words_of = c["attrs"].get("ubl-text-" + t, words(c["label"]) if n == 0 else "")
            extra = {k[len("ubl-text-%s-" % t):]: value(v) for k, v in c["attrs"].items()
                     if k.startswith("ubl-text-%s-" % t)}
            m["texts"].append(dict(id=t, text=words_of, **extra))
    if "ubl-unstated" in frame["attrs"]:
        m["figure"] = {"unstated": value(frame["attrs"]["ubl-unstated"])}
    if "ubl-segments" in frame["attrs"]:
        m["segments"] = value(frame["attrs"]["ubl-segments"])
    return m


def compare(have, want):
    """the model read from the drawing against the diagram JSON"""
    out = []
    for group in ("lanes", "nodes", "flows", "texts", "offPage", "marks", "phases"):
        h = {x["id"]: x for x in have.get(group, [])}
        for w in want.get(group, []):
            x = h.pop(w["id"], None)
            if x is None:
                out.append("%s %s: not in the drawing" % (group, w["id"]))
                continue
            for k, v in w.items():
                if k in NOT_KEPT.get(group, ()):
                    continue
                if x.get(k) != v:
                    out.append("%s %s: %s is %r in the JSON, %r in the drawing" % (group, w["id"], k, v, x.get(k)))
            for k in set(x) - set(w):
                if x[k] is not None:
                    out.append("%s %s: %s = %r only in the drawing" % (group, w["id"], k, x[k]))
        for i in h:
            out.append("%s %s: only in the drawing" % (group, i))
    if want.get("figure", {}).get("unstated") != have.get("figure", {}).get("unstated"):
        out.append("figure: unstated differs")
    if want.get("segments") != have.get("segments"):
        out.append("segments differ")
    return out


def is_illustration(path):
    """an illustration: a picture for the reader, not a UML diagram (its frame says so)"""
    return 'ubl-kind="illustration"' in open(path, encoding="utf-8").read()


def notation(path):
    """the notation of a figure that is not a UML activity diagram (BPMN, a phase map: history/group-a),
    which says so on one element (ubl-notation), or None"""
    m = re.search(r'ubl-notation="([^"]*)"', open(path, encoding="utf-8").read())
    return m.group(1) if m else None


def other_notation(cells):
    """the conventions of a figure that is not a UML diagram with a pool of lanes: ids are unique; in a
    drawing that has kinds (all but the TC's own, adopted as they are), every element has its kind, and
    in a BPMN drawing that has BPMN types (Ordering), every element its `ubl-bpmn-type`; a flow is
    attached at both ends (a dashed line round a list of documents, a `bracket`, is not a flow), and
    what a text or a bracket is for is an element"""
    out = []
    els = {i: c for i, c in cells.items() if i not in ("0", "1")}
    kinds, bpmn = any(c["kind"] for c in els.values()), any("ubl-bpmn-type" in c["attrs"] for c in els.values())
    for i, c in els.items():
        if kinds and not c["kind"]:
            out.append("%s: no ubl-kind (draw it from the drawing's own kinds, Edit Data)" % i)
        if bpmn and "ubl-bpmn-type" not in c["attrs"]:
            out.append("%s: no ubl-bpmn-type (its BPMN type, Edit Data: README, \"Editing a drawing\")" % i)
        if c["kind"] in ("flow", "message-flow"):
            for end in ("source", "target"):
                if not c[end] or c[end] not in cells:
                    out.append("%s: %s not attached to an element" % (i, end))
        for k in ("ubl-for", "ubl-steps"):
            for ref in (json.loads(c["attrs"][k]) if k == "ubl-steps" else [c["attrs"][k]]) if k in c["attrs"] else []:
                if ref not in cells:
                    out.append("%s: %s names %s, which is not in the drawing" % (i, k, ref))
    return out


def in_editor_form(path):
    sys.dont_write_bytecode = True      # no __pycache__ by the tools (the UBL repository does not ignore one)
    import drawio_format
    text = open(path, encoding="utf-8").read()
    try:
        return drawio_format.format_text(text) == text
    except (ValueError, ET.ParseError):
        return True        # not readable: said by the other checks


def main(argv):
    against = None
    if argv[:1] == ["--against"]:
        against, argv = argv[1], argv[2:]
    bad = 0
    for path in argv:
        name = os.path.basename(path)[:-len(".drawio")]
        form = [] if in_editor_form(path) else ["not in the form draw.io's editor writes: python3 tools/drawio_format.py " + path]
        if is_illustration(path):
            print("%-55s illustration, not checked" % name + ("" if not form else ", %d finding(s)" % len(form)))
            for f in form:
                print("    " + f)
            bad += bool(form)
            continue
        warned = []
        try:
            cells, order = read(path)
            if notation(path):
                found, warned = other_notation(cells), []
                if not any(x["kind"] for x in cells.values()):
                    warned = ["the TC's own drawing, as it is: its elements have no ubl-kind (the model is not in it)"]
            else:
                found = conventions(cells)
                warned = warnings(cells)
            if against and not notation(path):
                want = json.load(open(os.path.join(against, name, name + "-diagram.json")))
                found += compare(model_of(cells, order), want)
        except (ValueError, ET.ParseError) as e:
            found = [str(e)]
        found += form
        bad += bool(found)
        print("%-55s %s" % (name, "ok" if not found else "%d finding(s)" % len(found)) + (" (%s)" % notation(path) if notation(path) else "")
              + (", %d warning(s)" % len(warned) if warned else ""))
        for f in found:
            print("    " + f)
        for w in warned:
            print("    warning: " + w)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
