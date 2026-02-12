# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Markdown-based resume that builds into HTML, PDF, and plaintext formats using Pandoc and the `resume-builder` tool (from `github:friedenberg/resume-builder`). The resume content lives in `resume.md` (primary, with flexbox-based layout) and `resume-no-columns.md` (simpler table-based layout).

## Build Commands

```sh
make              # Build all formats (HTML, PDF, TXT) into build/
make clean        # Remove build directory
```

The Makefile reads metadata from single-line files: `NAME`, `EMAIL`, `PHONE`, `GITHUB_URL`, `VERSION`. These are passed to `resume-builder` as variables.

## Release

```sh
bin/release.sh    # Bumps VERSION, commits, pushes, builds, creates GitHub release
```

Uses `hub` CLI with a GitHub token from `secrets.env` (via direnv).

## Environment

- **Nix flake** with `direnv` (`source_up` + `use flake`) provides the dev shell
- Dev shell includes `resume-builder` and Pandoc (via `devenv-pandoc`)
- PDF generation uses `html-to-pdf` (Chrome headless)

## Architecture

The build pipeline is: `resume.md` → copy to `build/` → `resume-builder` generates output formats → final files renamed to `sasha_friedenberg_resume.*`.

Output formats:
- **HTML embedded**: deployed to `~/eng2/site-linenisgreat/public/resume.html`
- **HTML standalone**: used as intermediate for PDF
- **PDF**: generated from standalone HTML via `html-to-pdf`
- **TXT**: uses `figlet` for the name header

## Resume Markdown Format

The resume uses Pandoc's fenced div syntax (`::: {.class}`) extensively for layout. Key patterns:
- `position-flex` divs wrap each job entry with company, title, leader dots, and dates
- CSS classes like `.table-leader`, `.padding-bottom`, `.no-padding-top` control layout
- `.skill-*` span classes tag skills (e.g., `.skill-interviews`)
- HTML comments are embedded via Pandoc raw HTML syntax for commented-out content

## Sensitive Files

- `secrets.env` / `secrets.env.secret` contain GitHub tokens — never commit changes to these
- `PHONE` contains a phone number — do not expose
