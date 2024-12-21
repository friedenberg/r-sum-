#! /usr/bin/env just --working-directory . --justfile

html markdown template css=resume.css:
  pandoc \
    --from markdown \
    --section-div \
    --shift-heading-level-by=1 \
    -c '{{css}}' \
    -V "version={{VERSION}}" \
    -V "email={{EMAIL}}" \
    -V "phone={{PHONE}}" \
    -V "name={{NAME}}" \
    -V "build-date={{DATE}}" \
    -V "github-url={{GITHUB_URL}}" \
    --embed-resources \
    --standalone \
    --metadata "title={{NAME}}'s Resume" \
    --template '{{template}}' \
    '{{markdown}}' -o '{{markdown}}.html'

text markdown:
  pandoc \
    --from markdown \
    --section-div \
    --shift-heading-level-by=1 \
    -c resume.css \
    -V "version={{VERSION}}" \
    -V "email={{EMAIL}}" \
    -V "phone={{PHONE}}" \
    -V "name={{NAME}}" \
    -V "build-date={{DATE}}" \
    -V "github-url={{GITHUB_URL}}" \
    --metadata "title={{NAME}}'s Resume" \
    --template 'pandoc-template-txt.txt' \
    --embed-resources \
    --standalone \
    --reference-links \
    --columns 80 \
    --lua-filter pandoc-lua-filter-txt.lua \
    --to markdown \
    '{{markdown}}' -o '{{markdown}}.txt'

html-embedded markdown: (html markdown "pandoc-template-html-embedded.html")
html-standalone markdown: (html markdown "pandoc-tempalte-html-standalone.html")

pdf html:
  html-to-pdf '{{html}}'
