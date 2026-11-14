#!/usr/bin/env bash
# Fails when a workflow uses a third-party action by tag or branch instead of a full commit SHA.
set -u
cd "$(dirname "$0")/../.."
bad=$(grep -rhnE '^\s*-?\s*uses:\s*[^./][^@ ]+@' .github/workflows | grep -vE '@[0-9a-f]{40}(\s|$)')
if [ -n "$bad" ]; then
  echo "Actions not pinned to a commit SHA:"
  echo "$bad"
  exit 1
fi
echo "ok: every action is pinned to a commit SHA"
