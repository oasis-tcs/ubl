"""Write a .drawio file the way draw.io's own editor writes it, so that a text diff of
a drawing against the same drawing saved from the editor shows only what differs.

    python3 tools/drawio_format.py <file.drawio> ...           rewrite the files in that form
    python3 tools/drawio_format.py --check <file.drawio> ...   list the files that are not in it (exit 1)
    python3 tools/drawio_format.py --diff <file.drawio> <saved.drawio>
                                                               text diff of the first, in the editor's form,
                                                               against a file saved from the editor

The form (found 2026-10-05 by opening and saving all 85 drawings in draw.io 32.1.0/32.2.0,
tools/drawio_editor_roundtrip.js, and matching the files byte for byte):

  - pretty-printed, two spaces an indent, <x ... /> for an empty element, a newline at the end;
  - the cells one after another in <root>, each cell before its children (the order of the model, not
    of the file it was written as), the children of a parent in the order they had;
  - attributes: an <mxCell>'s id first, the others in alphabetical order; an <mxGeometry>'s and an
    <mxPoint>'s alphabetical, `as` last; an <object>'s `label`, then its own, then `id`;
  - the children of an <mxGeometry> in the order offset, points, sourcePoint, targetPoint;
  - x="0" and y="0" of an <mxGeometry> or <mxPoint> left out, a number written as JavaScript writes it
    (554.30 as 554.3, 12.0 as 12);
  - the <mxfile> with host and agent only (no type);
  - in an attribute: & < > " and ' written as &amp; &lt; &gt; &quot; &#39;.

Not the editor's, and kept as they are: <mxfile host> (the editor writes its own: "embed.diagrams.net",
"app.diagrams.net", "Electron") and the window size dx and dy of <mxGraphModel> (the editor writes its
window's; some of our files have none); --diff leaves them out. The file is read as XML, so a comment in it would be lost: there are none.
"""
import difflib, re, sys
import xml.etree.ElementTree as ET

NUMERIC = {'mxGeometry': ('x', 'y', 'width', 'height'), 'mxPoint': ('x', 'y')}
ZERO_OMITTED = ('x', 'y')


def num(v):
    """A number as JavaScript writes it: the shortest that reads back the same, no trailing .0."""
    try:
        f = float(v)
    except ValueError:
        return v
    s = repr(f)
    if s.endswith('.0'):
        s = s[:-2]
    return '0' if s == '-0' else s


def esc(v):
    return (v.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
             .replace('"', '&quot;').replace("'", '&#39;').replace('\n', '&#xa;'))


def attrs(el):
    items = list(el.attrib.items())
    if el.tag in NUMERIC:
        items = [(k, num(v) if k in NUMERIC[el.tag] else v) for k, v in items
                 if not (k in ZERO_OMITTED and float(v) == 0)]
    if el.tag in ('mxCell', 'mxGeometry', 'mxPoint'):
        first = [i for i in items if i[0] == 'id']
        last = [i for i in items if i[0] == 'as']
        items = first + sorted(i for i in items if i[0] not in ('id', 'as')) + last
    elif el.tag == 'object':
        items = [i for i in items if i[0] != 'id'] + [i for i in items if i[0] == 'id']
    elif el.tag == 'mxfile':
        items = [i for i in items if i[0] != 'type']
    return items


def dump(el, depth, out):
    pad = '  ' * depth
    a = ''.join(' %s="%s"' % (k, esc(v)) for k, v in attrs(el))
    kids = list(el)
    if el.tag == 'mxGeometry':
        kids.sort(key=lambda k: k.get('as', ''))
    if not kids:
        out.append('%s<%s%s />' % (pad, el.tag, a))
        return
    out.append('%s<%s%s>' % (pad, el.tag, a))
    for k in kids:
        dump(k, depth + 1, out)
    out.append('%s</%s>' % (pad, el.tag))


def in_model_order(root):
    """The cells of <root> as the model has them: each cell, then its children, depth first."""
    def cell(el):
        return el if el.tag == 'mxCell' else el.find('mxCell')
    def cid(el):
        return el.get('id') if el.tag == 'mxCell' else el.get('id')
    kids = {}
    for el in list(root):
        kids.setdefault(cell(el).get('parent'), []).append(el)
    out = []
    def walk(parent):
        for el in kids.get(parent, []):
            out.append(el); walk(cid(el))
    walk(None)
    if len(out) != len(list(root)):
        raise ValueError('cells whose parent is not in the file')
    return out


def format_text(text):
    top = ET.fromstring(text)
    for root in top.iter('root'):
        cells = in_model_order(root)
        for el in list(root):
            root.remove(el)
        root.extend(cells)
    out = []
    dump(top, 0, out)
    return '\n'.join(out) + '\n'


def neutral(text):
    """The text with what the editor decides itself left out: the host and the window size, and the
    stamps of an older save that it drops (modified, etag, version: the TC's files of Group A carry them)."""
    text = re.sub(r'(<mxfile )host="[^"]*"', r'\1host=""', text)
    text = re.sub(r'<mxfile [^>]*>', lambda m: re.sub(r' (?:modified|etag|version)="[^"]*"', '', m.group(0)), text, count=1)
    return re.sub(r'(<mxGraphModel) dx="[^"]*" dy="[^"]*"', r'\1', text)


def main(a):
    if a[:1] == ['--diff'] and len(a) == 3:
        ours, theirs = format_text(open(a[1], encoding='utf8').read()), open(a[2], encoding='utf8').read()
        d = list(difflib.unified_diff(neutral(ours).splitlines(), neutral(theirs).splitlines(), a[1], a[2], lineterm='', n=1))
        print('\n'.join(d) if d else 'no difference (but what the editor decides itself: the host, the window size, the stamps of an older save)')
        return 1 if d else 0
    check = a[:1] == ['--check']
    files = a[1:] if check else a
    if not files:
        sys.exit(__doc__)
    bad = []
    for f in files:
        old = open(f, encoding='utf8').read()
        new = format_text(old)
        if new != old:
            bad.append(f)
            if not check:
                open(f, 'w', encoding='utf8').write(new)
    for f in bad:
        print(('not in the editor\'s form: ' if check else 'rewritten: ') + f)
    print('%d of %d files %s' % (len(bad), len(files), 'not in the editor\'s form' if check else 'rewritten'))
    return 1 if (check and bad) else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
