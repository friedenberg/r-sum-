#! /bin/bash -e

${EDITOR:-${VISUAL:-vi}} ./VERSION
git add ./VERSION
git diff --exit-code -s ./VERSION || (echo "version wasn't changed" && exit 1)
git commit -m "bumped version to $(cat ./VERSION)"
git push origin master

version="v$(cat ./VERSION)"

git diff --exit-code -s || (echo "unstaged changes, refusing to release" && exit 1)
hub release create \
  -a build/resume.pdf \
  -m "$version" \
  "$version"

