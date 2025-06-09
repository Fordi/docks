#!/bin/bash
HERE="$(dirname "$BASH_SOURCE")";
. "${HERE}/prereqs.sh"
. "${HERE}/env.sh"
. "${HERE}/utils.sh"

if [[ "$1" == "kill" ]]; then
  shift;
  if [[ "${#}" == 0 ]]; then
    while read -r line; do
      SCREEN="$(echo "${line}" | cut -d \" -f 2)"
      endScreen "${SCREEN}"
    done < <(
      jq -r '.screens | to_entries[] | "\"\(.key)\" \"\(.value)\""' "${DOCKER_ROOT}/.screens" \
      || echo "Nothing in ${DOCKER_ROOT}/.screens" || true \
    )
    exit 0
  fi
  for name in "$@"; do
    endScreen "${name}"
  done
  exit 0
fi

if [[ "$1" == "lsc" ]]; then
  shift;
  PATTERN="${1:-^${PREFIX}}"
  while read -r line; do
    SCREEN="$(echo "${line}" | cut -d \" -f 2)"
    echo "${PREFIX}${SCREEN}"
  done < <(
    jq -r '.screens | to_entries[] | "\"\(.key)\" \"\(.value)\""' "${DOCKER_ROOT}/.screens" \
    || echo "Nothing in ${DOCKER_ROOT}/.screens" || true \
  ) | grep -E "${PATTERN}"
  exit 0
fi
if [[ "$1" == "lsr" ]]; then
  shift;
  PATTERN="${1:-.${PREFIX}}"
  screen -ls | grep -E "${PATTERN}" | cut -d '.' -f 2 | cut -f 1
  exit 0
fi
if [[ "$1" == "go" ]]; then
  shift;
  if [[ "${#}" == 0 ]]; then
    echo "You must specify a screen"
    exit 1
  fi
  screen -x "$1"
  exit 0
fi
if [[ "$1" == "start" ]]; then
  shift;
  SCREENS=("${@}")
  while read -r line; do
    SCREEN="$(echo "${line}" | cut -d \" -f 2)"
    if [[ "${#}" == 0 ]] || containsElement "${SCREEN}" "${SCREENS[@]}"; then
      IFS=" " read -r -a CMD <<< "$(echo "${line}" | cut -d \" -f 4 || true)"
      startScreen "${SCREEN}" "${CMD[@]}"
    fi
  done < <(
    jq -r '.screens | to_entries[] | "\"\(.key)\" \"\(.value)\""' "${DOCKER_ROOT}/.screens" \
    || echo "Nothing in ${DOCKER_ROOT}/.screens" || true \
  )
  exit 0
fi
echo "$0 [-r {path}] [command] [...args]"
echo "  -r {path}        Set root to {path}" >&2
echo "  start            Start all screens" >&2
echo "  start {names...} Start the screens named {names...}" >&2
echo "  go {name}        Connect interactively with {name}" >&2
echo "  kill             Kill all screens" >&2
echo "  kill {names...}  Kill screens {names...}" >&2
echo "  lsr              List running screens" >&2
echo "  lsr {pattern}    List running screens matching {pattern} (egrep)" >&2
echo "  lsc              List configured screens" >&2
echo "  lsc {pattern}    List configured screens matching {pattern}" >&2
echo "Logs are stored in \`${DOCKER_ROOT}/{name}.log\`" >&2
echo "Screens are configured in \`${DOCKER_ROOT}\`/.screens" >&2
if [[ -n "$1" ]]; then
  echo "--- Unknown command: $1" >&2
  exit 1
fi
