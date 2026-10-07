// Export draw.io drawings to what the UBL repository publishes: per figure,
//
//   <out>/images/<figure>.drawio    the drawing itself (the source)
//   <out>/images/<figure>.svg       the vector picture: the revisable file for ISO
//   <out>/art/<figure>.png          print: 600 dpi, black and white (an illustration, or a drawing
//                                   marked ubl-art="grey": greyscale),
//                                   at most 3425 px (5.7 in) wide
//   <out>/htmlart/<figure>.png      web: greyscale (smooth edges), at most 750 px wide
//
// and, with --report, a JSON file (not in <out>: it is not for the UBL
// repository), per figure: its natural size, the scale it is fitted to the
// page at, and the size its text prints at.
//
//   node tools/export_drawio.js [--report <file.json>] <out dir> <figure.drawio | figure.svg> ...
//
// In the UBL repository, where the drawings are images/<figure>.drawio (utilities/artwork/render.sh
// exports into a scratch folder, checks, and copies; with <out dir> . the export goes beside the drawings):
//   node utilities/artwork/export_drawio.js <out dir> images/<figure>.drawio ...
//
// A figure whose source is an SVG (none now; Ordering's was, its bpmn-js SVG, until 2026-10-06:
// history/group-a/README.md) is not drawn again: images/<figure>.svg is the SVG as it is, byte for byte,
// and the PNGs are rendered from it, at the page's width as for the others.
//
// Needs Node with playwright (a global install is found through NODE_PATH, see
// tools/drawio_baseline.py) and Chromium: CHROMIUM_PATH, this environment's, or playwright's own.
//
// The picture is drawn by draw.io's own code: its viewer, of the release pinned
// in DRAWIO_VERSION, fetched once from that release's tag into
// DRAWIO_VIEWER_CACHE (default ~/.cache/ubl-drawio-viewer). draw.io writes each
// label as HTML in a <foreignObject>, which is not SVG text; the export lets
// the browser lay the label out as draw.io does, reads where each line of it
// lands, and writes those lines as SVG <text> in its place. The rest of the
// picture is draw.io's, cleaned of what only draw.io's editor needs (dark-mode
// colours, the "Text is not SVG" notice, pointer events).
//
// An illustration (its frame of ubl-kind "illustration": the Fulfilment and
// the CPFR step figures) differs: its pictures, SVG parts embedded as images, are put in the
// SVG as the SVGs they are (nested <svg>, their ids their own), so it stays
// vector only; its page is its frame (to the frame line's outer edge, as the
// UBL PNG it was matched to); and art/ is 8 bit grey, as its pictures are.
//
// Both PNGs are renders of that SVG, as an image, so they show what the SVG
// shows. Scale: the page is 5.7 in wide, 548 px at 96 px/in; a figure wider is
// fitted to it, a narrower one kept at its natural size (README, "The export's
// rules").
const { chromium } = require('playwright');
const fs = require('fs'), path = require('path'), os = require('os'), https = require('https');

// the pin: tools/drawio-version.json (DRAWIO_VERSION in the environment overrides it, for a trial)
const DRAWIO_VERSION = process.env.DRAWIO_VERSION || require('./drawio-version.json').version;
// the picture of a drawing, where it starts and how large: one definition, the render's too (drawio_picture.js)
const PICTURE = require('./drawio_picture.js').source;
const VIEWER_URL = 'https://raw.githubusercontent.com/jgraph/drawio/v' + DRAWIO_VERSION +
                   '/src/main/webapp/js/viewer-static.min.js';
// the browser: CHROMIUM_PATH, or the Chromium of this environment where it is there, or else playwright's own
// (as on a GitHub runner, after `playwright install chromium`)
const PINNED_CHROME = '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';
const CHROME = process.env.CHROMIUM_PATH || (fs.existsSync(PINNED_CHROME) ? PINNED_CHROME : undefined);

const PAGE_PX = 548;             // 5.7 in at 96 px/in: the width of the page
const ART_DPI = 600, ART_MAX = 3425, HTML_MAX = 750;
const FONT = "Helvetica, Arial, 'Liberation Sans', sans-serif";

function fetch(url, dest) {
  return new Promise((ok, fail) => {
    https.get(url, res => {
      if (res.statusCode !== 200) return fail(new Error(url + ': HTTP ' + res.statusCode));
      const out = fs.createWriteStream(dest + '.part');
      res.pipe(out);
      out.on('finish', () => { out.close(); fs.renameSync(dest + '.part', dest); ok(dest); });
    }).on('error', fail);
  });
}

// a source copied into <out>/images/, but where it is already there (the UBL repository: images/ is both)
function copy(src, dest) {
  if (path.resolve(src) !== path.resolve(dest)) fs.copyFileSync(src, dest);
}

async function viewer() {
  const dir = process.env.DRAWIO_VIEWER_CACHE || path.join(os.homedir(), '.cache', 'ubl-drawio-viewer');
  fs.mkdirSync(dir, { recursive: true });
  const file = path.join(dir, 'viewer-' + DRAWIO_VERSION + '.min.js');
  if (!fs.existsSync(file)) await fetch(VIEWER_URL, file);
  return file;
}

// Runs in the page: the drawing's SVG, drawn by draw.io, its labels made SVG text.
function toSvg([xml, name, font, drawioVersion]) {
  const doc = mxUtils.parseXml(xml);
  // a drawing that is not well-formed (cut short, say) is drawn as far as it goes: refused, not drawn in part
  const error = doc.getElementsByTagName('parsererror')[0];
  if (error) throw new Error(name + ': the drawing is not well-formed XML: ' + error.textContent.replace(/^\s*This page contains the following errors:\s*/, '').trim().split('\n')[0]);
  if (!doc.getElementsByTagName('mxGraphModel')[0]) throw new Error(name + ': the drawing has no mxGraphModel');
  // each drawing on a clean page: what an earlier drawing left in the container (its graph's DOM)
  // moves the page's layout, and the labels' measured places with it (by 0.01 px)
  const box = document.getElementById('g');
  box.innerHTML = ''; window.scrollTo(0, 0);
  const graph = new Graph(box);
  new mxCodec(doc).decode(doc.getElementsByTagName('mxGraphModel')[0], graph.getModel());
  // draw.io's SVG, cropped to the picture (drawio_picture.js: draw.io's export crop; an illustration's: its frame)
  const svg = drawioPicture(graph, doc).svg;
  document.body.appendChild(svg);            // laid out, so the labels can be measured
  const NS = 'http://www.w3.org/2000/svg';

  // an illustration (not a UML diagram: its frame says so) has pictures, SVG
  // parts embedded as images (illustrations/parts/). Each is put in as the SVG
  // it is, a nested <svg> where the picture is, its ids made its own; so the
  // SVG stays vector only, and each part in it can still be edited. draw.io
  // writes a picture as an <image> in a <symbol> (in <defs>) and a <use> of it
  // where each is: each <use> gets the part, and the symbol goes.
  const illustration = !!doc.querySelector('object[ubl-kind="illustration"]');
  let parts = 0;
  const hrefOf = e => e.getAttribute('xlink:href') || e.getAttribute('href') || '';
  function partOf(img, at) {                       // the part of an <image>, at `at`'s place and size
    const m = hrefOf(img).match(/^data:image\/svg\+xml(;base64)?,(.*)$/s);
    if (!m) return null;
    const text = m[1] ? decodeURIComponent(escape(atob(m[2]))) : decodeURIComponent(m[2]);
    const part = new DOMParser().parseFromString(text, 'image/svg+xml').documentElement;
    if (part.localName !== 'svg') throw new Error(name + ': an embedded image that is not SVG');
    const pre = 'p' + (++parts) + '-';
    for (const e of part.querySelectorAll('[id]')) e.setAttribute('id', pre + e.getAttribute('id'));
    for (const e of [part, ...part.querySelectorAll('*')])
      for (const a of [...e.attributes]) {
        if (/url\(#/.test(a.value)) e.setAttribute(a.name, a.value.replace(/url\(#/g, 'url(#' + pre));
        if ((a.localName === 'href') && a.value.startsWith('#')) e.setAttributeNS(a.namespaceURI, a.name, '#' + pre + a.value.slice(1));
      }
    expandUses(part);
    const box = document.importNode(part, true);
    for (const a of ['x', 'y', 'width', 'height'])
      box.setAttribute(a, at.getAttribute(a) !== null ? at.getAttribute(a) : img.getAttribute(a) || '0');
    box.setAttribute('preserveAspectRatio', img.getAttribute('preserveAspectRatio') || 'none');
    if (at.getAttribute('transform')) box.setAttribute('transform', at.getAttribute('transform'));
    return box;
  }
  // a part may have <use>s of its own (a clone made in Inkscape, a figure repeated): each is
  // made a copy of what it uses, in a <g> at its place, as the SVG check allows no <use>. A
  // <symbol> used becomes a nested <svg> with the symbol's viewBox, sized as the <use> is.
  function expandUses(part) {
    for (let round = 0; round < 10; round++) {
      const uses = [...part.querySelectorAll('use')];
      if (!uses.length) return;
      for (const u of uses) {
        const ref = hrefOf(u);
        const t = ref.startsWith('#') && part.querySelector('[id="' + CSS.escape(ref.slice(1)) + '"]');
        if (!t) throw new Error(name + ': a part has a <use> of ' + ref + ', which it does not hold');
        const NSs = 'http://www.w3.org/2000/svg';
        const g = part.ownerDocument.createElementNS(NSs, 'g');
        for (const a of [...u.attributes])
          if (!['x', 'y', 'width', 'height', 'href', 'xlink:href', 'transform', 'id'].includes(a.name)) g.setAttribute(a.name, a.value);
        const x = +(u.getAttribute('x') || 0), y = +(u.getAttribute('y') || 0);
        g.setAttribute('transform', ((u.getAttribute('transform') || '') + ((x || y) ? ' translate(' + x + ',' + y + ')' : '')).trim());
        let copy;
        if (t.localName === 'symbol') {
          copy = part.ownerDocument.createElementNS(NSs, 'svg');
          for (const a of ['viewBox', 'preserveAspectRatio']) if (t.getAttribute(a)) copy.setAttribute(a, t.getAttribute(a));
          copy.setAttribute('width', u.getAttribute('width') || '100%'); copy.setAttribute('height', u.getAttribute('height') || '100%');
          for (const c of t.childNodes) copy.appendChild(c.cloneNode(true));
        } else copy = t.cloneNode(true);
        for (const e of [copy, ...copy.querySelectorAll('[id]')]) e.removeAttribute('id');     // ids stay the original's
        g.appendChild(copy);
        u.parentNode.replaceChild(g, u);
      }
    }
    throw new Error(name + ': a part\'s <use>s go too deep (or round in a circle)');
  }
  const used = new Set();
  for (const use of [...svg.querySelectorAll('use')]) {
    const ref = hrefOf(use);
    let target = ref.startsWith('#') && svg.querySelector('[id="' + ref.slice(1) + '"]');
    const img = target && (target.localName === 'image' ? target : target.localName === 'symbol' ? target.querySelector('image') : null);
    if (!img) continue;
    const box = partOf(img, use);
    if (box) { use.parentNode.replaceChild(box, use); used.add(target); }
  }
  for (const t of used) {                                               // its uses have it now
    const defs = t.closest('defs');
    if (!defs) continue;
    t.remove();
    if (!defs.children.length) defs.remove();
  }
  for (const img of [...svg.querySelectorAll('image')]) {
    const box = partOf(img, img);
    if (box) img.parentNode.replaceChild(box, img);
  }
  const W = +svg.getAttribute('viewBox').split(' ')[2], H = +svg.getAttribute('viewBox').split(' ')[3];

  const hex = c => '#' + c.match(/\d+/g).slice(0, 3).map(v => (+v).toString(16).padStart(2, '0')).join('');
  const ascent = {};
  const ctx = document.createElement('canvas').getContext('2d');
  function fontAscent(cs) {
    const f = cs.fontStyle + ' ' + cs.fontWeight + ' ' + cs.fontSize + ' ' + cs.fontFamily;
    if (!(f in ascent)) { ctx.font = f; ascent[f] = ctx.measureText('Hg').fontBoundingBoxAscent; }
    return ascent[f];
  }
  // a run of text in one style: what an SVG <tspan> carries
  function styleOf(el, root) {
    const cs = getComputedStyle(el);
    let underline = false;
    for (let e = el; e && e !== root.parentNode; e = e.parentNode)
      if (e.nodeType === 1 && /underline/.test(getComputedStyle(e).textDecorationLine)) underline = true;
    return { weight: +cs.fontWeight >= 600 ? 'bold' : null, italic: cs.fontStyle === 'italic' ? 'italic' : null,
             underline, size: parseFloat(cs.fontSize), fill: hex(cs.color), cs };
  }
  const same = (a, b) => a.weight === b.weight && a.italic === b.italic && a.underline === b.underline &&
                         a.size === b.size && a.fill === b.fill;

  // one label: its lines, each a list of runs, in the coordinates of `local`
  function lines(root, local) {
    const inv = local.getScreenCTM().inverse();
    const pt = svg.createSVGPoint();
    const at = (x, y) => { pt.x = x; pt.y = y; return pt.matrixTransform(inv); };
    const out = [];
    let line = null;
    const range = document.createRange();
    const walk = node => {
      if (node.nodeType === 1 && node.localName === 'br') { line = null; return; }
      if (node.nodeType === 3) {
        const st = styleOf(node.parentNode, root);
        for (let i = 0; i < node.data.length; i++) {
          const ch = node.data[i];
          range.setStart(node, i); range.setEnd(node, i + 1);
          const r = [...range.getClientRects()].find(r => r.width > 0);
          if (/\s/.test(ch)) { if (line) line.chars.push({ ch: ' ', r, st }); continue; }
          if (!r) continue;
          if (!line || r.top > line.top + r.height / 2) { line = { top: r.top, chars: [] }; out.push(line); }
          line.chars.push({ ch, r, st });
        }
        return;
      }
      for (const c of node.childNodes) walk(c);
    };
    walk(root);
    return out.map(l => {
      const ink = l.chars.filter(c => c.ch !== ' ');
      const first = ink[0];
      const left = Math.min(...ink.map(c => c.r.left)), right = Math.max(...ink.map(c => c.r.right));
      const baseline = first.r.top + fontAscent(first.st.cs);
      // spaces: one between words, none at either end
      let s = l.chars.slice(l.chars.indexOf(first), l.chars.lastIndexOf(ink[ink.length - 1]) + 1);
      s = s.filter((c, i) => c.ch !== ' ' || s[i - 1].ch !== ' ');
      const runs = [];
      for (const c of s) {
        const last = runs[runs.length - 1];
        if (last && same(last.st, c.st)) last.text += c.ch; else runs.push({ text: c.ch, st: c.st });
      }
      const p0 = at(left, baseline), p1 = at(right, baseline);
      return { left: p0.x, right: p1.x, baseline: p0.y, runs };
    });
  }

  const report = { labels: 0, lines: 0 };
  for (const sw of [...svg.querySelectorAll('switch')]) {
    const fo = sw.querySelector('foreignObject');
    if (!fo) continue;
    const local = sw.parentNode;
    // measure a turned label unturned: take its turns off, put them back after
    const turned = [];
    for (let e = local; e !== svg; e = e.parentNode) {
      const t = e.getAttribute('transform');
      if (t && /rotate/.test(t)) {
        if (!/^\s*rotate\([^)]*\)\s*$/.test(t)) throw new Error(name + ': a label under ' + t);
        turned.push([e, t]); e.removeAttribute('transform');
      }
    }
    const block = fo.querySelector('div div div') || fo.querySelector('div div') || fo.firstElementChild;
    const align = getComputedStyle(block).textAlign;
    const ls = lines(block, local);
    for (const [e, t] of turned) e.setAttribute('transform', t);
    const words = block.textContent.replace(/\s+/g, ' ').trim();
    const got = ls.map(l => l.runs.map(r => r.text).join('')).join(' ').replace(/\s+/g, ' ').trim();
    if (words.replace(/ /g, '') !== got.replace(/ /g, ''))
      throw new Error(name + ': label "' + words + '" measured as "' + got + '"');
    const g = document.createElementNS(NS, 'g');
    for (const l of ls) {
      const text = document.createElementNS(NS, 'text');
      const anchor = align === 'center' ? 'middle' : (align === 'right' || align === 'end') ? 'end' : 'start';
      const x = anchor === 'middle' ? (l.left + l.right) / 2 : anchor === 'end' ? l.right : l.left;
      const r2 = v => String(Math.round(v * 100) / 100);
      text.setAttribute('x', r2(x));
      text.setAttribute('y', r2(l.baseline));
      text.setAttribute('font-family', font);
      if (anchor !== 'start') text.setAttribute('text-anchor', anchor);
      const base = l.runs[0].st;
      text.setAttribute('font-size', String(base.size));
      text.setAttribute('fill', base.fill);
      const put = (el, st) => {
        if (st.weight) el.setAttribute('font-weight', st.weight);
        if (st.italic) el.setAttribute('font-style', st.italic);
        if (st.underline) el.setAttribute('text-decoration', 'underline');
      };
      if (l.runs.length === 1) { put(text, base); text.textContent = l.runs[0].text; }
      else for (const r of l.runs) {
        const span = document.createElementNS(NS, 'tspan');
        put(span, r.st);
        if (r.st.size !== base.size) span.setAttribute('font-size', String(r.st.size));
        if (r.st.fill !== base.fill) span.setAttribute('fill', r.st.fill);
        span.textContent = r.text;
        text.appendChild(span);
      }
      g.appendChild(text);
      report.lines++;
    }
    sw.parentNode.replaceChild(g, sw);
    report.labels++;
  }

  // what only draw.io's editor needs
  svg.querySelectorAll('style, a, switch, foreignObject').forEach(e => e.remove());
  for (const e of [svg, ...svg.querySelectorAll('*')]) {
    e.removeAttribute('pointer-events');
    const st = e.getAttribute('style');
    if (st !== null) {
      const keep = st.split(';').map(s => s.trim()).filter(s => s && !/light-dark|^background/.test(s));
      if (keep.length) e.setAttribute('style', keep.join('; ')); else e.removeAttribute('style');
    }
    if (e.localName === 'text' && e.getAttribute('font-family') !== font) e.setAttribute('font-family', font);
  }
  svg.removeAttribute('id');
  const bg = svg.querySelector('rect');
  const vb = svg.getAttribute('viewBox').split(' ');
  if (+vb[0] || +vb[1]) { bg.setAttribute('x', vb[0]); bg.setAttribute('y', vb[1]); }   // an illustration's page
  bg.setAttribute('width', String(W)); bg.setAttribute('height', String(H));

  // the page: fitted to 5.7 in, in millimetres
  const scale = Math.min(1, 548 / W);
  const mm = v => String(Math.round(v * scale * 25.4 / 96 * 1000) / 1000) + 'mm';
  svg.setAttribute('width', mm(W));
  svg.setAttribute('height', mm(H));
  const title = document.createElementNS(NS, 'title');
  title.textContent = name;
  svg.insertBefore(title, svg.firstChild);
  svg.insertBefore(document.createComment(
    ' Generated from ' + name + '.drawio by tools/export_drawio.js (draw.io ' + drawioVersion +
    '). Edit ' + name + '.drawio, not this file. '), svg.firstChild);
  const text = '<?xml version="1.0" encoding="UTF-8"?>\n' + new XMLSerializer().serializeToString(svg) + '\n';
  document.body.removeChild(svg);
  graph.destroy(); box.innerHTML = '';
  return { svg: text, width: W, height: H, scale, illustration, parts, ...report };
}

// A greyscale PNG, its resolution recorded (pHYs), as the print tools size an
// image by it: 8 bit, or with bits 1 black and white only, a pixel black where
// the drawing covers at least half of it (as drawn without antialiasing). Each
// row is filtered as PNG's encoders do: the filter that leaves the smallest sum
// of differences.
function greyPng(grey, w, h, dpi, bits) {
  const zlib = require('zlib');
  const chunk = (type, data) => {
    const c = Buffer.alloc(12 + data.length);
    c.writeUInt32BE(data.length, 0); c.write(type, 4, 'latin1'); data.copy(c, 8);
    c.writeUInt32BE(zlib.crc32(c.subarray(4, 8 + data.length)) >>> 0, 8 + data.length);
    return c;
  };
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4); ihdr[8] = bits; ihdr[9] = 0;   // grey
  if (bits === 1) {                                 // 8 pixels a byte, white is 1
    const rowBytes = Math.ceil(w / 8), packed = Buffer.alloc(rowBytes * h);
    for (let y = 0; y < h; y++)
      for (let x = 0; x < w; x++)
        if (grey[y * w + x] >= 128) packed[y * rowBytes + (x >> 3)] |= 0x80 >> (x & 7);
    grey = packed; w = rowBytes;
  }
  const phys = Buffer.alloc(9);
  const ppm = Math.round(dpi / 0.0254);
  phys.writeUInt32BE(ppm, 0); phys.writeUInt32BE(ppm, 4); phys[8] = 1;
  const raw = Buffer.alloc((w + 1) * h), cand = [0, 1, 2, 3, 4].map(() => Buffer.alloc(w));
  const zero = Buffer.alloc(w);
  for (let y = 0; y < h; y++) {
    const cur = grey.subarray(y * w, y * w + w), up = y ? grey.subarray((y - 1) * w, y * w) : zero;
    let best = 0, bestSum = Infinity;
    for (let f = 0; f < 5; f++) {
      const o = cand[f];
      let sum = 0;
      for (let x = 0; x < w; x++) {
        const a = x ? cur[x - 1] : 0, b = up[x], c = x ? up[x - 1] : 0;
        let pred = 0;
        if (f === 1) pred = a; else if (f === 2) pred = b; else if (f === 3) pred = (a + b) >> 1;
        else if (f === 4) { const p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c);
                            pred = pa <= pb && pa <= pc ? a : pb <= pc ? b : c; }
        const v = (cur[x] - pred) & 255;
        o[x] = v; sum += v < 128 ? v : 256 - v;
      }
      if (sum < bestSum) { bestSum = sum; best = f; }
    }
    raw[y * (w + 1)] = best; cand[best].copy(raw, y * (w + 1) + 1);
  }
  return Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), chunk('IHDR', ihdr), chunk('pHYs', phys),
                        chunk('IDAT', zlib.deflateSync(raw, { level: 9 })), chunk('IEND', Buffer.alloc(0))]);
}

// the SVG drawn as an image at exactly pxW x pxH pixels, on white, and read back
// as grey (the drawings are black on white; the browser draws with grey edges,
// not the coloured ones of LCD text, see --disable-lcd-text)
async function png(browser, svgText, pxW, pxH, dpi, bits, out) {
  const page = await browser.newPage({ viewport: { width: 64, height: 64 }, deviceScaleFactor: 1 });
  await page.setContent('<!doctype html><html><body><img></body></html>');
  const b64 = await page.evaluate(async ([src, w, h]) => {
    const img = document.images[0];
    img.src = src;
    await img.decode();
    const canvas = document.createElement('canvas');
    canvas.width = w; canvas.height = h;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#ffffff'; ctx.fillRect(0, 0, w, h);
    ctx.drawImage(img, 0, 0, w, h);
    const px = ctx.getImageData(0, 0, w, h).data, grey = new Uint8Array(w * h);
    for (let i = 0; i < grey.length; i++)
      grey[i] = Math.round(0.299 * px[4 * i] + 0.587 * px[4 * i + 1] + 0.114 * px[4 * i + 2]);
    let s = '';
    for (let i = 0; i < grey.length; i += 0x8000) s += String.fromCharCode.apply(null, grey.subarray(i, i + 0x8000));
    return btoa(s);
  }, ['data:image/svg+xml;base64,' + Buffer.from(svgText).toString('base64'), pxW, pxH]);
  await page.close();
  fs.writeFileSync(out, greyPng(Buffer.from(b64, 'base64'), pxW, pxH, dpi, bits));
}

(async () => {
  const args = process.argv.slice(2);
  let reportFile = null;
  if (args[0] === '--report') { reportFile = args[1]; args.splice(0, 2); }
  const [outDir, ...files] = args;
  if (!outDir || !files.length) {
    console.error('usage: node tools/export_drawio.js [--report <file.json>] <out dir> <figure.drawio> ...');
    process.exit(2);
  }
  for (const d of ['images', 'art', 'htmlart']) fs.mkdirSync(path.join(outDir, d), { recursive: true });
  const js = await viewer();
  const browser = await chromium.launch({ executablePath: CHROME, args: ['--disable-lcd-text'] });
  const draw = await browser.newPage();
  await draw.setContent('<!doctype html><html><body><div id="g"></div></body></html>');
  await draw.addScriptTag({ path: js });
  await draw.addScriptTag({ content: PICTURE });
  const version = await draw.evaluate(() => (typeof EditorUi !== 'undefined' && EditorUi.VERSION) || mxClient.VERSION);
  if (version !== DRAWIO_VERSION) throw new Error('draw.io ' + version + ', expected ' + DRAWIO_VERSION);
  const report = reportFile && fs.existsSync(reportFile) ? JSON.parse(fs.readFileSync(reportFile, 'utf8')) : {};

  for (const file of files) {
    const name = path.basename(file).replace(/\.(drawio|svg)$/, '');
    let r;
    if (file.endsWith('.svg')) {
      const text = fs.readFileSync(file, 'utf8');
      const W = +text.match(/<svg[^>]*\swidth="([\d.]+)"/)[1], H = +text.match(/<svg[^>]*\sheight="([\d.]+)"/)[1];
      r = { svg: text, width: W, height: H, scale: Math.min(1, PAGE_PX / W), illustration: false, labels: 0, lines: 0 };
      copy(file, path.join(outDir, 'images', name + '.svg'));
    } else {
      r = await draw.evaluate(toSvg, [fs.readFileSync(file, 'utf8'), name, FONT, version]);
      copy(file, path.join(outDir, 'images', name + '.drawio'));
      fs.writeFileSync(path.join(outDir, 'images', name + '.svg'), r.svg);
    }
    const artW = Math.round(r.width * r.scale * ART_DPI / 96);   // 3425 at the page's width
    const htmlW = Math.round(artW * HTML_MAX / ART_MAX);          // 750 at the page's width
    const tall = w => Math.round(w * r.height / r.width);
    // print: black and white, as line art is printed; an illustration's pictures, in grey
    // (a figure whose drawing says ubl-art="grey", as an illustration, has greyscale print: its grey is meant)
    const grey = r.illustration || (!file.endsWith('.svg') && /ubl-art="grey"/.test(fs.readFileSync(file, 'utf8')));
    await png(browser, r.svg, artW, tall(artW), ART_DPI, grey ? 8 : 1, path.join(outDir, 'art', name + '.png'));
    await png(browser, r.svg, htmlW, tall(htmlW), 96, 8, path.join(outDir, 'htmlart', name + '.png'));
    const textPt = Math.round(12 * r.scale * 72 / 96 * 10) / 10;   // the drawings' one text size (12 px)
    report[name] = { width: r.width, height: r.height, scale: Math.round(r.scale * 1000) / 1000,
                     ...(r.illustration ? { illustration: true, parts: r.parts } : { textPt }),
                     labels: r.labels, lines: r.lines, art: [artW, tall(artW)], htmlart: [htmlW, tall(htmlW)], drawio: version };
    console.log(name + ': ' + r.width + 'x' + r.height + ' px, scale ' + report[name].scale +
                (r.illustration ? ', an illustration, ' + r.parts + ' pictures' : ', text ' + textPt + ' pt') +
                ', ' + r.labels + ' labels in ' + r.lines + ' lines');
  }
  if (reportFile) fs.writeFileSync(reportFile, JSON.stringify(report, null, 1) + '\n');
  await browser.close();
})().catch(e => { console.error(e.message || e); process.exit(1); });
