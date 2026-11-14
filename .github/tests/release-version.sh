#!/usr/bin/env bash
# Runs the release workflow's "Determine version" step with dummy inputs.
set -u
cd "$(dirname "$0")/../.."
step=$(ruby -ryaml -e 'f = ".github/workflows/release.yml"; w = YAML.respond_to?(:unsafe_load_file) ? YAML.unsafe_load_file(f) : YAML.load_file(f); s = w["jobs"]["build-and-release"]["steps"].find { |x| x["id"] == "version" }; print s["run"]')
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
fail=0

run_step() {
  : > "$work/out"
  rendered=${step//'${{ github.event_name }}'/$1}
  rendered=${rendered//'${{ inputs.version }}'/$2}
  env -i PATH=/usr/bin:/bin HOME="$work" EVENT_NAME="$1" INPUT_VERSION="$2" GITHUB_REF_NAME="$3" GITHUB_OUTPUT="$work/out" \
    bash -c "$rendered" >/dev/null 2>&1
}

expect() {
  if [ "$1" != "$2" ]; then echo "FAIL: $3 (got '$1', want '$2')"; fail=1; else echo "ok: $3"; fi
}

run_step workflow_dispatch '1.2.3' ''
expect "$(grep '^VERSION=' "$work/out")" "VERSION=1.2.3" "dispatch 1.2.3 is accepted"

run_step push '' 'v2.0.0-beta.1'
expect "$(grep '^TAG=' "$work/out")" "TAG=v2.0.0-beta.1" "tag v2.0.0-beta.1 is accepted"

run_step workflow_dispatch '1.0.0$(touch '"$work"'/injected)' ''
expect "$([ -e "$work/injected" ] && echo ran || echo blocked)" "blocked" "command substitution in the dispatch input does not run"
expect "$(cat "$work/out")" "" "an invalid dispatch version writes no output"

run_step workflow_dispatch $'1.0.0\nTAG=evil' ''
expect "$(cat "$work/out")" "" "a newline in the dispatch version is rejected"

exit $fail
