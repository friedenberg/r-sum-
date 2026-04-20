# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Markdown-based resume that builds into HTML, PDF, and plaintext formats using Pandoc and the `resume-builder` tool (from `github:friedenberg/resume-builder`). The resume content lives in `resume.md` (primary, with flexbox-based layout) and `resume-no-columns.md` (simpler table-based layout). Which one is built is controlled by `WHICH_RESUME` in the `Makefile`.

## Build Commands

```sh
make              # Build HTML, PDF, and TXT into build/ (docx is buildable but not in `all`)
make clean        # Remove build directory
make build/sasha_friedenberg_resume.docx  # Opt-in docx build
```

The Makefile reads metadata from single-line files: `NAME`, `EMAIL`, `PHONE`, `GITHUB_URL`, `VERSION`. All of these except `VERSION` are **gitignored** — each user creates their own before running `make`. Values are passed to `resume-builder` as template variables.

There is a TODO in the `Makefile` header to migrate the build to a justfile; preserve the Makefile unless explicitly asked to migrate.

A thin `justfile` lives alongside the Makefile (see issue #3 for the broader migration question — not done yet). Recipes:

- `just build` — invokes `make`.
- `just test` — smoke test. Stubs any missing metadata files (so the recipe also works from a clean checkout / CI), runs `make clean && make`, and asserts `build/<name>_resume.{html,txt,pdf}` all exist non-empty and the PDF has valid magic. Writes the build output to stdout/stderr as-is.

`sweatfile` at the repo root wires `just test` as a `[hooks]` `pre-merge` for `sc merge` (spinclass). The hook runs via `sh -c` from the worktree cwd after rebase but before fast-forward; non-zero exit aborts the merge. No `nix develop` wrapping — `just` is expected to be on the invoker's ambient PATH.

## Release

```sh
bin/release.sh    # Bumps VERSION, commits, pushes, builds, creates GitHub release
```

Uses the `hub` CLI with a GitHub token loaded via `direnv dotenv bash secrets.env`.

## CI

`.github/workflows/nix.yml`:
- **build** job: matrix over `ubuntu-22.04` / `x86_64-linux` and `macos-15` / `aarch64-darwin`; runs `nix develop -c true` to verify the dev shell evaluates. The flake exposes no default package, so CI uses `nix develop` rather than `nix build`.
- **flakehub-publish** job: on pushes to `master`, publishes to FlakeHub as `friedenberg/r-sum-` (rolling, public).

## Environment

- **Nix flake** with `direnv` (`source_up` + `use flake`) provides the dev shell.
- Flake inputs that contribute tooling: `resume-builder` (brings Pandoc transitively), `chrest` (brings its own headless Firefox in-closure), plus `nixpkgs.figlet` and `nixpkgs.just`. (`devenv-pandoc` was removed — do not re-add it.)
- PDF generation defaults to `chrest capture --format pdf --browser firefox` (headless Firefox). Override with `make PDF_RENDERER=html-to-pdf` to use the legacy renderer — but note `html-to-pdf` is not currently provided by this flake and must be on PATH separately.

## Architecture

Build pipeline: `resume.md` → copy to `build/` → `resume-builder` generates output formats → final files renamed to `sasha_friedenberg_resume.*`.

Output formats:
- **HTML embedded**: deployed by the Makefile to `~/eng2/site-linenisgreat/public/resume.html` as a side-effect of the `build/%.html` rule.
- **HTML standalone**: intermediate for PDF (`build/%.pdf.html`).
- **PDF**: generated from standalone HTML via the renderer selected by `PDF_RENDERER` (`chrest` by default, `html-to-pdf` as opt-in).
- **TXT**: uses `figlet` (font `smslant`) to render the name header.
- **docx**: available via `resume-builder docx`, not part of the default `all` target.

## Resume Markdown Format

The resume uses Pandoc's fenced div syntax (`::: {.class}`) extensively for layout. Key patterns:
- `position-flex` divs wrap each job entry with company, title, leader dots, and dates.
- CSS classes like `.table-leader`, `.padding-bottom`, `.no-padding-top` control layout.
- `.skill-*` span classes tag skills (e.g., `.skill-interviews`).
- HTML comments are embedded via Pandoc raw HTML syntax for commented-out content.

## Sensitive / Secret Files

Secrets are managed with [`git-secret`](https://git-secret.io):
- `secrets.env.secret` is the encrypted blob checked into the repo.
- `secrets.env` is the decrypted plaintext; it is **gitignored** and should never be committed. `bin/release.sh` sources it via `direnv dotenv bash secrets.env` at release time.
- `.gitsecret/keys/random_seed` is also gitignored.
- `PHONE` contains a phone number — do not expose it in output, logs, or commits.
- `just test` (and `make` in general) prints `PHONE`, `EMAIL`, and other metadata as part of resume-builder's command-line echo, and the rendered `build/*_resume.{html,txt,pdf}` outputs also contain them. Both the metadata inputs (`NAME`/`EMAIL`/`PHONE`/`GITHUB_URL`) and `build/` are gitignored, CI doesn't run `just test`, and no log file is written — so the PII only lives in local terminal scrollback and in the gitignored build outputs. Still, **don't pipe test output to a file you'll share**, and don't paste the scrollback into issues/PRs.

There is a TODO in `bin/release.sh` to migrate the release flow to `site-linenisgreat` and add support for historical objects; preserve the current script unless explicitly asked to migrate.
