#!/bin/bash
REAL_BASH_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
# shellcheck source-path=SCRIPTDIR
HERE="$(dirname "${REAL_BASH_SOURCE}")";

if [[ "$1" == "update" ]]; then
  bash "${HERE}/install.sh"
  exit
fi

source "${HERE}/prereqs.sh"
source "${HERE}/env.sh"
source "${HERE}/utils.sh"


PREFIX="$(getConfig prefix "")"
CONTAINER="$(getConfig container dev)"

if isHelp "$@"; then
  shift
  source "${HERE}/usage.sh"
fi

if [[ "$1" == "in" ]]; then
  shift;
  inDocker "$@"
  exit
fi

if [[ "$1" == "kill" ]]; then
  shift;
  if [[ "${#}" == 0 ]]; then
    while read -r line; do
      SCREEN="$(echo "${line}" | cut -d \" -f 2)"
      endScreen "${SCREEN}"
    done < <(getScreens || true)
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
  while read -r line || true; do
    SCREEN="$(echo "${line}" | (cut -d \" -f 2 || true))"
    echo "${PREFIX}${SCREEN}"
  done < <(getScreens || true) | grep -E "${PATTERN}"
  exit 0
fi
if [[ "$1" == "lsr" ]]; then
  shift;
  PATTERN="${1:-.${PREFIX}}"
  # shellcheck disable=SC2312
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
  done < <(getScreens || true)
  exit 0
fi

source "${HERE}/usage.sh"
