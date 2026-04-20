# r-sum-

A series of [Pandoc][pandoc] templates that convert a single Markdown resume into HTML, PDF, and plaintext.

## Usage

1. Clone or fork. The [Nix][nix] flake devshell (`nix develop`, or direnv `use flake`) provides the build tooling: Pandoc, `resume-builder`, [`chrest`][chrest] with a headless Firefox for PDF, and `just`.
1. Edit `resume.md` (primary, flexbox layout) or `resume-no-columns.md` (simpler table-based alt; toggle via `WHICH_RESUME` in the `Makefile`).
1. Create single-line text files `NAME`, `EMAIL`, `PHONE`, `GITHUB_URL`, and `VERSION` (all gitignored, per-user).
1. `just build` (wraps `make`). Outputs land in `build/`.

`just test` runs a clean smoke build and verifies all three outputs exist. The same recipe is wired as a `sc merge` pre-merge hook via `sweatfile`.

## Considerations

Rendering HTML+CSS to PDF through a real browser sidesteps the common case where dedicated HTML-to-PDF tools (wkhtmltopdf, WeasyPrint, and others listed at <https://print-css.rocks/>) don't properly support Flexbox — which this layout relies on. The default renderer drives a headless Firefox via `chrest`; override with `make PDF_RENDERER=html-to-pdf` to use Chrome's `--headless --print-to-pdf` if you have that binary on PATH.

## Inspiration

- <https://mszep.github.io/pandoc_resume/>
- <https://resume.chmd.fr/>

[pandoc]: <https://pandoc.org/>
[nix]: <https://nixos.org/>
[chrest]: <https://github.com/amarbel-llc/chrest>
