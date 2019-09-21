#! /bin/bash -e

${EDITOR:-${VISUAL:-vi}} ./VERSION
git add ./VERSION
git diff --exit-code -s ./VERSION || (echo "version wasn't changed" && exit 1)
git commit -m "bumped version to $(cat ./VERSION)"
git push origin master

version="v$(cat ./VERSION)"

cp build/resume.pdf build/sasha_friedenberg_resume.pdf

git diff --exit-code -s || (echo "unstaged changes, refusing to release" && exit 1)
hub release create \
  -a build/sasha_friedenberg_resume.pdf \
  -m "$version" \
  "$version"

