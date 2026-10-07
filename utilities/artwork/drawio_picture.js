// The picture of a drawing: where it starts and how large it is. One definition for every picture made of
// a drawing: the export (tools/export_drawio.js: the SVG, and the PNGs rendered from it) and every render
// (history/drawio-writer/render-drawio.js: the baselines, the upgrade check, the comparison decks).
//
// It is draw.io's own export crop, read from draw.io and not worked out again: the SVG of getSvg, called as
// the export calls it, which takes the drawing's bounds (every shape with its line, every label) and rounds
// their corner down to a whole unit. An illustration's picture is its frame, to the frame line's outer
// edge (as the PNG it was matched to: its border).
//
// Until 2026-10-06 the render placed a drawing by a rule of its own (the frame's ubl-offset, or the page's
// corner), so a render and the export of one drawing were a unit or more apart, by an amount that differed
// from drawing to drawing (README, "In the UBL repository"; history/README.md).
//
// Runs in the page, with draw.io's viewer loaded; a Node script puts it there:
//   await page.addScriptTag({ content: require('<this file>').source });
// drawioPicture(graph, doc) -> { svg, view, x, y, width, height }:
//   svg     the SVG as getSvg makes it (the export goes on from it), its viewBox set to view
//   view    [x, y, width, height] in the SVG's own units (getSvg draws the model shifted by its crop)
//   x, y    the picture's corner in the drawing's units; width, height: its size
function drawioPicture(graph, doc) {
  let canvas;
  const make = graph.createSvgCanvas;
  graph.createSvgCanvas = function () { return (canvas = make.apply(this, arguments)); };
  let svg;
  try {
    svg = graph.getSvg('#ffffff', 1, 0, false, null, true);
  } finally {
    graph.createSvgCanvas = make;
  }
  const dx = canvas.state.dx, dy = canvas.state.dy;
  let view = svg.getAttribute('viewBox').split(' ').map(Number);
  const frame = doc.querySelector('object[ubl-kind="illustration"]') && svg.querySelector('g[data-cell-id="frame"] rect');
  if (frame) {
    const sw = +(frame.getAttribute('stroke-width') || 1), r2 = v => Math.round(v * 100) / 100;
    view = [+frame.getAttribute('x') - sw / 2, +frame.getAttribute('y') - sw / 2,
            +frame.getAttribute('width') + sw, +frame.getAttribute('height') + sw].map(r2);
  }
  svg.setAttribute('viewBox', view.join(' '));
  return { svg, view, x: view[0] - dx, y: view[1] - dy, width: view[2], height: view[3] };
}

if (typeof module !== 'undefined') module.exports = { source: drawioPicture.toString() };
