#shellcheck shell=bash
if ! command -v jq > /dev/null 2>&1; then
  echo "jq is required; please install it" >&2
  exit 1
fi
if ! command -v pr > /dev/null 2>&1; then
  echo "pr is required; please install coreutils" >&2
  exit 1
fi
if ! command -v pushd > /dev/null 2>&1; then
  echo "pushd and popd are required; please use bash, zsh, or something more competent than sh" >&2
  exit 1
fi
if ! command -v docker > /dev/null 2>&1; then
  echo "docker is required; please install it" >&2
  exit 1
fi
if ! command -v docker-compose > /dev/null 2>&1; then
  echo "docker-compose is required; please install it" >&2
  exit 1
fi
if ! command -v screen > /dev/null 2>&1; then
  echo "GNU screen is required; please install it" >&2
  exit 1
fi
