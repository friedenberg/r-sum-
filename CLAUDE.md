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

The Makefile reads personal metadata (`NAME`, `EMAIL`, `PHONE`, `GITHUB_URL`) from a single **gitignored** `.env` file in the repo root. Values must be **double-quoted** (e.g. `NAME="Sasha Friedenberg"`) so that `. ./.env` from bash (release.sh, `just test`) handles values with spaces correctly; the Makefile strips the quotes via `$(subst ",,…)` when importing via `include .env`. Each user creates their own `.env` before running `make`. `VERSION` remains a separate **tracked** single-line file (tied to release.sh / git tags). Values are passed to `resume-builder` as template variables.

A thin `justfile` lives alongside the Makefile (see issue #3 for the broader migration question — not done yet). Recipes:

- `just build` — invokes `make`.
- `just test` — smoke test. Stubs any missing metadata files (so the recipe also works from a clean checkout / CI), runs `make clean && make`, and asserts `build/<name>_resume.{html,txt,pdf}` all exist non-empty and the PDF has valid magic. Writes the build output to stdout/stderr as-is.

`sweatfile` at the repo root wires `just test` as a `[hooks]` `pre-merge` for `sc merge` (spinclass). The hook runs via `sh -c` from the worktree cwd after rebase but before fast-forward; non-zero exit aborts the merge. No `nix develop` wrapping — `just` is expected to be on the invoker's ambient PATH.

## Release

```sh
bin/release.sh    # Bumps VERSION, commits, pushes, builds, creates GitHub release
```

Uses the `gh` CLI with auth managed by `gh auth login` (keyring-backed). No env-var token needed. Preflight checks (`test -s .env`, `test -s VERSION`) run before the irreversible version-bump / push / release-create sequence.

## CI

`.github/workflows/nix.yml`:
- **build** job: matrix over `ubuntu-22.04` / `x86_64-linux` and `macos-15` / `aarch64-darwin`; runs `nix develop -c true` to verify the dev shell evaluates. The flake exposes no default package, so CI uses `nix develop` rather than `nix build`.
- **flakehub-publish** job: on pushes to `master`, publishes to FlakeHub as `friedenberg/r-sum-` (rolling, public).

## Environment

- **Nix flake** with `direnv` (`source_up` + `use flake`) provides the dev shell.
- Flake inputs that contribute tooling: `resume-builder` (brings Pandoc transitively), `chrest` (brings its own headless Firefox in-closure), plus `nixpkgs.just`. (`devenv-pandoc` was removed — do not re-add it.)
- PDF generation defaults to `chrest capture --format pdf --browser firefox` (headless Firefox). Override with `make PDF_RENDERER=html-to-pdf` to use the legacy renderer — but note `html-to-pdf` is not currently provided by this flake and must be on PATH separately.

## Architecture

Build pipeline: `resume.md` → copy to `build/` → `resume-builder` generates output formats → final files renamed to `sasha_friedenberg_resume.*`.

Output formats:
- **HTML embedded**: deployed by the Makefile to `~/eng2/site-linenisgreat/public/resume.html` as a side-effect of the `build/%.html` rule.
- **HTML standalone**: intermediate for PDF (`build/%.pdf.html`).
- **PDF**: generated from standalone HTML via the renderer selected by `PDF_RENDERER` (`chrest` by default, `html-to-pdf` as opt-in).
- **TXT**: plain-text resume via `resume-builder txt`.
- **docx**: available via `resume-builder docx`, not part of the default `all` target.

## Resume Markdown Format

The resume uses Pandoc's fenced div syntax (`::: {.class}`) extensively for layout. Key patterns:
- `position-flex` divs wrap each job entry with company, title, leader dots, and dates.
- CSS classes like `.table-leader`, `.padding-bottom`, `.no-padding-top` control layout.
- `.skill-*` span classes tag skills (e.g., `.skill-interviews`).
- HTML comments are embedded via Pandoc raw HTML syntax for commented-out content.

## Sensitive / Secret Files

- `.env` (gitignored) contains `NAME`, `EMAIL`, `PHONE`, `GITHUB_URL`. `PHONE` is a real phone number — do not expose it in output, logs, or commits. `build/` is also gitignored, which matters because the rendered `build/*_resume.{html,txt,pdf}` outputs embed these values.
- `just test` and `make` print metadata on stdout/stderr as part of resume-builder's command-line echo. CI doesn't run `just test` and no log file is written — so the PII only lives in local terminal scrollback and in the gitignored build outputs. Still, **don't pipe test output to a file you'll share**, and don't paste the scrollback into issues/PRs.
- There's no long-lived GitHub token in this repo — `bin/release.sh` relies on `gh`'s keyring auth. The repo used to ship a `git-secret`-encrypted `secrets.env.secret` for a `GITHUB_TOKEN`; that has been removed.

There is a TODO in `bin/release.sh` to migrate the release flow to `site-linenisgreat` and add support for historical objects; preserve the current script unless explicitly asked to migrate.
