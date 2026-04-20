#! /bin/bash -xe

# TODO migrate to site-linenisgreat and add support for historical objects

# Validate prerequisites before any irreversible action (commit / push / release).
test -s ./.env       || { echo ".env is missing or empty; create it before releasing" >&2; exit 1; }
test -s ./VERSION    || { echo "VERSION is missing or empty" >&2; exit 1; }
test -s ./secrets.env || { echo "secrets.env is missing (decrypt it with git-secret)" >&2; exit 1; }

${EDITOR:-${VISUAL:-vi}} ./VERSION
git add ./VERSION
git diff --exit-code -s ./VERSION || (echo "version wasn't changed" && exit 1)
git commit -m "bumped version to $(cat ./VERSION)"
git push origin master

version="v$(cat ./VERSION)"

make

# shellcheck disable=SC1091
. ./.env
str_snake_case="$(echo "$NAME" | tr "[:upper:]" "[:lower:]" | tr " " "_")"
file_out_base="build/${str_snake_case}_resume"

git diff --exit-code -s || (echo "unstaged changes, refusing to release" && exit 1)

function run_with_gh_token() {
  set +x
  echo "+ $*"
  eval "$(direnv dotenv bash secrets.env)"
  "$@"
}

run_with_gh_token gh release create "$version" \
  --title "$version" \
  --notes "$version" \
  "$file_out_base.html" \
  "$file_out_base.txt" \
  "$file_out_base.pdf"
