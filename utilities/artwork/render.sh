#!/bin/bash
# Render the figures from their drawings, before the build packages art/ and htmlart/ (build-common.sh):
#
#   images/<figure>.drawio  ->  images/<figure>.svg, art/<figure>.png, htmlart/<figure>.png
#
# for every figure UBL.xml shows (art/<figure>.png) that has a drawing.
#
# The drawings are the source. The rendered files are committed too, and rendered again here, so that
# a build publishes what the drawings say. Rendered into a scratch folder and checked (check_svg.py)
# first: only a render that passes replaces the committed files. Where it cannot be done (a local
# build without the tools below, or a render that fails), the committed files are used, and it says
# so (on GitHub as an annotation of the run). Where a committed SVG is not what its drawing gives, it
# says that too: render again and commit (README.md here). It never fails the build.
#
# Given a file, it also writes each problem there, for the package: build-common.sh puts it at the top
# of the package as ARTWORK-PROBLEMS.txt, as the build reports its own (INTEGRITY-PROBLEMS.txt). No
# problem, no file.
#
# Needs Node with playwright 1.56.1 and its Chromium, Python 3 with Pillow, and the Liberation fonts;
# the build's workflow installs them (.github/workflows/build.yml, step "Artwork tools"). Fetches the
# pinned draw.io viewer (drawio-version.json) from GitHub once per machine.
#
#   bash utilities/artwork/render.sh [<problems file>]    from the repository's root, as build-common.sh does

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
report="${1:+$(cd "$(dirname "$1")" && pwd)/$(basename "$1")}"
cd "$root" || exit 0

say() { echo "Artwork: $1"; }
annotate() { [ -n "$GITHUB_ACTIONS" ] && echo "::$1 title=Artwork::$2"; }
problem() { [ -n "$report" ] && printf '%s\n' "$1" >> "$report"; }

export NODE_PATH="${NODE_PATH:+$NODE_PATH:}$(npm root -g 2>/dev/null)"
if ! command -v node >/dev/null 2>&1 || ! node -e "require('playwright')" >/dev/null 2>&1 \
   || ! python3 -c "import PIL" >/dev/null 2>&1; then
  say "not rendered (Node with playwright, or Python 3 with Pillow, is missing): the committed images/*.svg, art/ and htmlart/ are used"
  annotate warning "not rendered: the committed artwork is used (the tools are missing)"
  problem "The figures were not rendered from their drawings: Node with playwright, or Python 3 with
Pillow, is missing. This build used the committed images/*.svg, art/ and htmlart/."
  exit 0
fi

# the figures the specification shows (UBL.xml: art/<figure>.png) that are drawn (images/<figure>.drawio);
# another drawing in images/ is not rendered (an older source, a figure UBL does not show)
figures=()
for name in $(grep -o 'fileref="art/[^"]*\.png"' UBL.xml | sed 's/^fileref="art\///; s/\.png"$//' | sort -u); do
  [ -f "images/$name.drawio" ] && figures+=("images/$name.drawio")
done
if [ ${#figures[@]} -eq 0 ]; then
  say "no drawing of a figure of UBL.xml in images/: nothing rendered"
  problem "No figure of UBL.xml has a drawing in images/: nothing was rendered."
  exit 0
fi
for f in images/*.drawio; do
  case " ${figures[*]} " in *" $f "*) ;; *) [ -f "$f" ] && say "$f: not a figure of UBL.xml, not rendered" ;; esac
done

out="$(mktemp -d)"
trap 'rm -rf "$out" "$out.log" "$out.check"' EXIT
say "rendering the ${#figures[@]} figures of UBL.xml from their drawings (images/<figure>.drawio) ..."
if ! node "$here/export_drawio.js" "$out" "${figures[@]}" > "$out.log" 2>&1; then
  tail -20 "$out.log"
  say "the render failed: the committed artwork is used"
  annotate error "the render failed: the committed artwork is used (see the log of this step)"
  problem "The figures were not rendered from their drawings: the render failed. This build used the
committed images/*.svg, art/ and htmlart/. The end of the render's log:"
  problem "$(tail -20 "$out.log")"
  exit 0
fi
if ! python3 "$here/check_svg.py" "$out" > "$out.check" 2>&1; then
  cat "$out.check"
  say "the rendered artwork did not pass its check: the committed artwork is used"
  annotate error "the rendered artwork did not pass its check: the committed artwork is used"
  problem "The figures rendered from their drawings did not pass their check (check_svg.py). This
build used the committed images/*.svg, art/ and htmlart/. The check found:"
  problem "$(grep -v ': ok$' "$out.check")"
  exit 0
fi
cat "$out.check"

cp "$out"/images/*.svg images/
cp "$out"/art/*.png art/
cp "$out"/htmlart/*.png htmlart/
say "rendered and checked: images/*.svg, art/ and htmlart/ are this build's"

# the committed SVGs should be what the drawings give (the PNGs are not compared: their text is
# rasterised a fraction of a pixel apart from one machine to another)
if git rev-parse --git-dir >/dev/null 2>&1; then
  stale="$(git diff --name-only -- 'images/*.svg')"
  if [ -n "$stale" ]; then
    say "the committed SVG of these figures is not what their drawing gives (render again and commit):"
    echo "$stale" | sed 's/^/  /'
    echo "$stale" | while read -r f; do annotate warning "$f is not what its drawing gives: render again and commit"; done
    problem "The committed SVG of these figures is not what their drawing gives. This build used its own
render, but the repository is out of date: render again and commit (utilities/artwork/README.md):"
    problem "$(echo "$stale" | sed 's/^/  /')"
  fi
fi
exit 0
