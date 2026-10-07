# Artwork: the figures' drawings

The figures of the specification are drawn in [draw.io](https://www.drawio.com):
**`images/<figure>.drawio` is each figure's source.** Every build renders them, before it
packages the specification (`render.sh`, called by `build-common.sh`), into

- `images/<figure>.svg`: the picture as real vector (text as text), the revisable file ISO asks for;
- `art/<figure>.png`: for print, 600 dpi, at most 3425 px (5.7 in) wide, black and white (grey for
  the illustrations and the few figures with a grey fill);
- `htmlart/<figure>.png`: for the web, at most 750 px wide;

and the build goes on as before: `UBL.xml` points at `art/<figure>.png`. The rendered files are
committed too, so that the repository shows them; render again after an edit, and commit them with
the drawing. Do not edit them by hand: the next build renders them from the drawing anyway.

Rendered are the figures `UBL.xml` shows (`art/<figure>.png`) that have a drawing: a new figure is a
new `images/<figure>.drawio` and its `art/<figure>.png` in `UBL.xml`. Another drawing in `images/` is
left as it is.

## Editing a figure

1. Open `images/<figure>.drawio` in draw.io (the desktop app, or [diagrams.net](https://app.diagrams.net)),
   edit, and save it back.
2. **The UML activity diagrams** (most figures): open the UBL shape library once,
   `utilities/artwork/ubl-library.xml` (*File › Open Library*; on diagrams.net *File › Open Library
   from › Device*), and draw new elements from it, not from draw.io's own palettes: its shapes carry
   their kind (`ubl-kind`). Keep the figures' conventions:
   - the frame is a pool, each party a lane in it, every node standing in its lane;
   - flows attached to their elements at both ends; a guard is the flow's own label;
   - whole pixels, line weights 1 (2 for documents and the frame), one arrowhead (UML's open head,
     10 px), every arrow at least 3 times its head long (make room with Ctrl+Shift+drag);
   - one text size, draw.io's own 12 pt (no font size set).

   What the drawing cannot show goes in *Edit Data* (Ctrl+M) on the element: for a document on a
   lane divider, the parties it passes between (`ubl-between`, e.g. `["lane-buyer", "lane-seller"]`);
   for a flow that is neither a control nor an object flow, its kind (`ubl-flow`).
3. **The Ordering Process** is a BPMN drawing: edit it with draw.io's BPMN palette (*More Shapes ›
   BPMN*), put a new element in its pool, attach a flow at both ends, and give the new element, in
   *Edit Data*, its `ubl-kind` (`task`, `gateway`, `event`, `flow`, `message-flow`) and its BPMN type
   (`ubl-bpmn-type`: `task`, `exclusiveGateway`, `startEvent`, `endEvent`, `sequenceFlow`, `messageFlow`).
4. **The illustrations** (the Fulfilment and the CPFR step figures) are made of pictures, kept as
   SVG files in `utilities/artwork/parts/`. To change a picture, edit its file with an SVG editor
   (Inkscape, say), then put it into every drawing that uses it:
   `python3 utilities/artwork/embed_parts.py`.
5. Check the drawing: `python3 utilities/artwork/check_drawio.py images/<figure>.drawio` (the
   conventions above, and that the file is in the form draw.io writes; after a script wrote one:
   `python3 utilities/artwork/drawio_format.py <file>`).
6. Render and check: `bash utilities/artwork/render.sh` (it needs what the build installs, below).
   Commit the drawing with its rendered files, `images/<figure>.drawio`, `images/<figure>.svg`,
   `art/<figure>.png` and `htmlart/<figure>.png`, and only those: on another machine than the last
   render's, the other figures' PNGs come out a fraction of a pixel apart (their text), which is not
   a change (add yours by name, `git add images/<figure>.* art/<figure>.png htmlart/<figure>.png`;
   then `git restore art htmlart` drops the rest).

## The build

`render.sh` renders the figures into a scratch folder and checks the result (`check_svg.py`: the
drawing well-formed, the SVG real vector with its text as text, the PNGs' sizes and depth). Only a
render that passes replaces the committed `images/*.svg`, `art/` and `htmlart/`; where the tools
are missing, or the render fails (a drawing that is not well-formed, cut short, say, is refused, not
drawn in part), the committed files are used, and the run says so (on GitHub, an annotation). Where
a committed SVG is not what its drawing gives, the run says that too: render again and commit. (The
PNGs are not compared: their text is rasterised a fraction of a pixel apart from one machine to
another.) It never fails the build. It takes about 2 minutes for the 96 figures.

**Each problem is also reported in the package**, as the build reports its own
(`INTEGRITY-PROBLEMS.txt`): `ARTWORK-PROBLEMS.txt`, at the top of the package beside the
specification's PDF, says what happened (the tools missing, the render or its check failed, a
committed SVG out of date) and which files the build used. No problem, no file: a package without
it was rendered from the drawings.

It is wired into the build in two places:

- `build-common.sh`: before the Ant build, `bash utilities/artwork/render.sh "$artworkProblems"`
  (a scratch file, from `mktemp`); after it, that file, if not empty, becomes `ARTWORK-PROBLEMS.txt`
  in the package. It is put there after Ant has finished, because a `.txt` file at the top of the
  package before then would make Ant skip its consistency check.
- `.github/workflows/build.yml`, in the job `build`, between the steps `Dependencies` and `Build`;
  `continue-on-error`, so that a failed install still builds the specification, from the committed
  files, and says so in `ARTWORK-PROBLEMS.txt`:

  ```yaml
      - name: Set up Node
        continue-on-error: true
        uses: actions/setup-node@v7
        with:
          node-version: 22

      - name: Artwork tools
        continue-on-error: true
        run: |
          npm install -g playwright@1.56.1
          playwright install --with-deps chromium
          sudo apt install -y fonts-liberation python3-pil
  ```

(`build.py`, the Python build, does not render: it uses the committed files. To render there too:
`subprocess.run(["bash", "utilities/artwork/render.sh"])` before its Ant build, and the same steps in
the job `build-py`, with `pip install pillow` in place of `python3-pil`: that job's Python is
`actions/setup-python`'s.)

To render on your own machine: Node with `playwright@1.56.1` (`npm install -g playwright@1.56.1`,
then `playwright install chromium`), Python 3 with Pillow, and a Helvetica, Arial or Liberation Sans
font. The pinned draw.io viewer is fetched from GitHub once, into `~/.cache/ubl-drawio-viewer`.

## draw.io

The render draws with the viewer of one draw.io release, pinned in `drawio-version.json`, so that a
render can be made again the same. draw.io's code is Apache 2.0 and its source public at that
release ([jgraph/drawio](https://github.com/jgraph/drawio)); the drawings are plain XML, and every
figure is also a standard SVG.

How the drawings were made (from the PNGs of UBL 2.5 CSD03), the tools to move the pin to a newer
draw.io and to hold every drawing against a baseline, and the record of the decisions taken with the
TC are kept in the repository the drawings were made in:
[kduvekot/ubl-work-on-svg-images](https://github.com/kduvekot/ubl-work-on-svg-images).
