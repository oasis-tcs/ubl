"""Check an export of the drawings (tools/export_drawio.js) before it goes to the
UBL repository.

    python3 tools/check_svg.py <out dir>

For every images/<figure>.svg in <out dir>, the SVG and the two PNGs made
from it are checked against what the UBL repository publishes (its README,
"Artwork") and what ISO accepts as a revisable file (vector, text as text):

the SVG
  - is well-formed XML, one <svg> with a viewBox and a width and height in mm,
    no wider than the page (3425 px at 600 dpi: 5.7 in, 144.99 mm);
  - is vector only: no <foreignObject> (HTML), no <image> (a bitmap), no
    <script>, no <switch>, no link; no draw.io drawing inside it (content=);
  - has its text as <text>, each with words in it and the font named;
  - has no dark-mode colours (light-dark), and a white background: a white
    <rect> first, covering the whole picture;
  - names the drawing it was made from, in a comment, and that drawing is there,
    well-formed, the same, byte for byte, as its source in diagrams/ (else: export again; in
    the UBL repository, utilities/artwork/check_svg.py, the drawing is the source).
art/<figure>.png
  - 600 dpi, black and white (1 bit; greyscale, 8 bit, for an illustration, whose
    pictures are grey, and for a drawing marked ubl-art="grey"), at most 3425 px
    wide, the SVG's width at 600 dpi (to a pixel);
  - opaque, on white (the page round the drawing: its outer band, 2 % of the width).
htmlart/<figure>.png
  - greyscale (8 bit), at most 750 px wide, the art's width scaled by 750/3425
    (to a pixel);
  - opaque, on white.

Prints one line per figure, "ok" or what is wrong. Exits 1 when any is wrong.
"""
import os, re, sys
import xml.etree.ElementTree as ET
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SVG = '{http://www.w3.org/2000/svg}'
PAGE_MM = 3425 / 600 * 25.4   # 5.7 in, as the UBL README rounds it: 144.99 mm
ART_DPI, ART_MAX, HTML_MAX = 600, 3425, 750
FORBIDDEN = ('foreignObject', 'image', 'script', 'switch', 'a', 'iframe', 'use')


def check_png(path, max_w, dpi, want_w, mode, out):
    if not os.path.exists(path):
        return out.append('missing ' + path)
    im = Image.open(path)
    name = os.path.join(os.path.basename(os.path.dirname(path)), os.path.basename(path))
    if im.mode != mode:
        out.append('%s: %s, not %s' % (name, {'1': 'black and white', 'L': 'greyscale'}.get(im.mode, im.mode),
                                           {'1': 'black and white', 'L': 'greyscale'}[mode]))
    if im.width > max_w:
        out.append('%s: %d px wide, more than %d' % (name, im.width, max_w))
    if abs(im.width - want_w) > 1:
        out.append('%s: %d px wide, the SVG makes %d' % (name, im.width, want_w))
    got = im.info.get('dpi')
    if dpi and (not got or abs(got[0] - dpi) > 0.5):
        out.append('%s: %s dpi, not %d' % (name, got and round(got[0], 1), dpi))
    if im.mode in ('RGBA', 'LA', 'P') and im.convert('RGBA').getchannel('A').getextrema()[0] < 255:
        out.append(name + ': transparent')
    # on white: the page round the drawing is white - its outer band (2 % of the width), where only the
    # frame and the margin are; not the whole picture, which may be mostly grey (the CPFR step panels)
    g = im.convert('L'); w, h = g.size; b = max(2, round(0.02 * w))
    band = [g.crop(box).histogram() for box in ((0, 0, w, b), (0, h - b, w, h), (0, b, b, h - b), (w - b, b, w, h - b))]
    grey = [sum(v) for v in zip(*band)]
    if grey.index(max(grey)) < 250:
        out.append(name + ': not on white')


def check_original(out_dir, name, text):
    """a figure whose source is an SVG (none now; Ordering's was until 2026-10-06, history/group-a): the SVG as it is, which
    must be the source in diagrams/ byte for byte, vector and with its words as text; the PNGs from it"""
    out = []
    src = os.path.join(ROOT, 'diagrams', name, name + '.svg')
    if not os.path.exists(src) or open(src, 'rb').read() != text.encode('utf-8'):
        out.append('images/%s.svg is not diagrams/%s/%s.svg: export again' % (name, name, name))
    try:
        root = ET.fromstring(text.encode('utf-8'))
    except ET.ParseError as e:
        return out + ['not XML: %s' % e]
    w = float(root.get('width', '0').replace('px', ''))
    for tag in sorted({e.tag.replace(SVG, '') for e in root.iter() if isinstance(e.tag, str)} & set(FORBIDDEN)):
        out.append('<%s> in the SVG' % tag)
    if not list(root.iter(SVG + 'text')):
        out.append('no <text>: the words are not text')
    art_w = round(w * min(1, 548 / w) * ART_DPI / 96)
    check_png(os.path.join(out_dir, 'art', name + '.png'), ART_MAX, ART_DPI, art_w, '1', out)
    check_png(os.path.join(out_dir, 'htmlart', name + '.png'), HTML_MAX, None, round(art_w * HTML_MAX / ART_MAX), 'L', out)
    return out


def check(out_dir, name):
    out = []
    svg_path = os.path.join(out_dir, 'images', name + '.svg')
    text = open(svg_path, encoding='utf-8').read()
    if not os.path.exists(os.path.join(out_dir, 'images', name + '.drawio')):
        return check_original(out_dir, name, text)
    try:
        root = ET.fromstring(text.encode('utf-8'))
    except ET.ParseError as e:
        return ['not XML: %s' % e]
    if root.tag != SVG + 'svg':
        return ['not an SVG']
    vb = root.get('viewBox', '').split()
    w, h = root.get('width', ''), root.get('height', '')
    if len(vb) != 4 or not w.endswith('mm') or not h.endswith('mm'):
        return ['no viewBox, or width and height not in mm']
    wmm, hmm = float(w[:-2]), float(h[:-2])
    if wmm > PAGE_MM + 0.01:
        out.append('%.2f mm wide, more than the page (%.2f mm)' % (wmm, PAGE_MM))
    vw, vh = float(vb[2]), float(vb[3])
    if abs(wmm / vw - hmm / vh) > 1e-3 * wmm / vw:
        out.append('width and height not in the viewBox\'s proportion')
    if root.get('content') is not None:
        out.append('carries a draw.io drawing (content=)')
    counts = {}
    for e in root.iter():
        tag = e.tag.replace(SVG, '') if isinstance(e.tag, str) else None
        if tag in FORBIDDEN:
            counts[tag] = counts.get(tag, 0) + 1
    for tag, n in sorted(counts.items()):
        out.append('%d <%s>' % (n, tag))
    if 'light-dark' in text:
        out.append('dark-mode colours (light-dark)')
    texts = list(root.iter(SVG + 'text'))
    if not texts:
        out.append('no <text>: the words are not text')
    for t in texts:
        if not ''.join(t.itertext()).strip():
            out.append('an empty <text> at %s,%s' % (t.get('x'), t.get('y')))
        if 'Helvetica' not in (t.get('font-family') or ''):
            out.append('a <text> without the font: ' + ''.join(t.itertext()).strip())
    first = next((e for e in root if e.tag not in (SVG + 'title', SVG + 'defs', SVG + 'desc')), None)
    if first is None or first.tag != SVG + 'rect' or first.get('fill', '').lower() not in ('#ffffff', '#fff', 'white') \
            or (float(first.get('width', 0)), float(first.get('height', 0))) != (vw, vh):
        out.append('no white background covering the picture')
    m = re.search(r'<!--\s*Generated from (\S+?\.drawio)', text)
    if not m or m.group(1) != name + '.drawio':
        out.append('does not name its drawing (%s.drawio) in a comment' % name)
    elif not os.path.exists(os.path.join(out_dir, 'images', m.group(1))):
        out.append('its drawing is not there: images/' + m.group(1))
    else:
        try:
            if ET.parse(os.path.join(out_dir, 'images', m.group(1))).find('.//mxGraphModel') is None:
                out.append('images/%s has no mxGraphModel' % m.group(1))
        except ET.ParseError as e:
            out.append('images/%s is not well-formed XML (%s)' % (m.group(1), e))
        src = os.path.join(ROOT, 'diagrams', name, name + '.drawio')
        if not os.path.isdir(os.path.join(ROOT, 'diagrams')):
            pass        # the UBL repository: images/<figure>.drawio is the source itself
        elif not os.path.exists(src):
            out.append('no source for it in diagrams/')
        elif open(src, 'rb').read() != open(os.path.join(out_dir, 'images', m.group(1)), 'rb').read():
            out.append('images/%s.drawio is not diagrams/%s/%s.drawio: export again' % (name, name, name))

    art_w = round(wmm / 25.4 * ART_DPI)
    drawing = os.path.join(out_dir, 'images', name + '.drawio')
    illustration = os.path.exists(drawing) and ('ubl-kind="illustration"' in open(drawing, encoding='utf-8').read()
                                                or 'ubl-art="grey"' in open(drawing, encoding='utf-8').read())   # grey print on purpose
    check_png(os.path.join(out_dir, 'art', name + '.png'), ART_MAX, ART_DPI, art_w, 'L' if illustration else '1', out)
    check_png(os.path.join(out_dir, 'htmlart', name + '.png'), HTML_MAX, None, round(art_w * HTML_MAX / ART_MAX), 'L', out)
    return out


# the tools the UBL repository gets (utilities/artwork/: README.md, "In the UBL repository: the build
# renders the drawings"), copies of this repository's
COPIED = ['export_drawio.js', 'drawio_picture.js', 'check_svg.py', 'drawio-version.json', 'check_drawio.py', 'drawio_format.py',
          'ubl-library.xml', 'embed_parts.py']


def check_copies(out_dir):
    """in this repository, an export's utilities/artwork/: the tools and parts as they are here"""
    copies, out = os.path.join(out_dir, 'utilities', 'artwork'), []
    if not os.path.isdir(copies) or not os.path.isdir(os.path.join(ROOT, 'diagrams')):
        return out
    pairs = [(os.path.join(copies, f), os.path.join(ROOT, 'tools', f)) for f in COPIED]
    parts = os.path.join(ROOT, 'illustrations', 'parts')
    pairs += [(os.path.join(copies, 'parts', f), os.path.join(parts, f)) for f in sorted(os.listdir(parts))]
    for copy, src in pairs:
        if not os.path.exists(copy) or open(copy, 'rb').read() != open(src, 'rb').read():
            out.append('utilities/artwork/%s is not %s: copy it again' % (os.path.relpath(copy, copies), os.path.relpath(src, ROOT)))
    return out


def main(argv):
    if len(argv) != 1:
        print(__doc__.strip().split('\n\n')[1])
        return 2
    out_dir = argv[0]
    names = sorted(f[:-4] for f in os.listdir(os.path.join(out_dir, 'images')) if f.endswith('.svg'))
    bad = 0
    for name in names:
        found = check(out_dir, name)
        bad += bool(found)
        print(name + ': ' + ('ok' if not found else '\n  ' + '\n  '.join(found)))
    print('%d of %d ok' % (len(names) - bad, len(names)))
    copies = check_copies(out_dir)
    for c in copies:
        print(c)
    return 1 if bad or copies else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
