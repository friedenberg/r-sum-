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
- The only flake input that contributes tooling is `resume-builder`; Pandoc comes transitively through it. (`devenv-pandoc` was removed — do not re-add it.)
- PDF generation uses `html-to-pdf` (Chrome headless), which is provided by `resume-builder`.

## Architecture

Build pipeline: `resume.md` → copy to `build/` → `resume-builder` generates output formats → final files renamed to `sasha_friedenberg_resume.*`.

Output formats:
- **HTML embedded**: deployed by the Makefile to `~/eng2/site-linenisgreat/public/resume.html` as a side-effect of the `build/%.html` rule.
- **HTML standalone**: intermediate for PDF (`build/%.pdf.html`).
- **PDF**: generated from standalone HTML via `html-to-pdf`.
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

There is a TODO in `bin/release.sh` to migrate the release flow to `site-linenisgreat` and add support for historical objects; preserve the current script unless explicitly asked to migrate.
