#!/bin/bash
REAL_BASH_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
# shellcheck source-path=SCRIPTDIR
HERE="$(dirname "${REAL_BASH_SOURCE}")";
source "${HERE}/prereqs.sh"
source "${HERE}/env.sh"
source "${HERE}/utils.sh"

case "${CMD}" in
  help)
    source "${HERE}/usage.sh"
  ;;
  update)
    bash "${HERE}/install.sh"
    exit
  ;;
  in)
    inDocker "${ARGS[@]}"
    exit
  ;;
  stop)
    if [[ "${#ARGS[@]}" == 0 ]]; then
      # shellcheck disable=SC2312
      while read -r line; do
        SCREEN="$(echo "${line}" | cut -d \" -f 2)"
        endScreen "${SCREEN}"
      done < <(getScreens)
      exit 0
    fi
    for name in "${ARGS[@]}"; do
      endScreen "${name}"
    done
    exit 0
  ;;
  start)
    PREFIX="$(getConfig prefix "")"
    # shellcheck disable=SC2312
    while read -r line; do
      SCREEN="${PREFIX}$(echo "${line}" | cut -d \" -f 2)"
      if [[ "${#ARGS[@]}" == 0 ]] || containsElement "${SCREEN}" "${ARGS[@]}"; then
        IFS=" " read -r -a SCREEN_CMD <<< "$(echo "${line}" | cut -d \" -f 4 || true)"
        startScreen "${SCREEN}" "${SCREEN_CMD[@]}"
      fi
    done < <(getScreens)
    exit 0
  ;;
  restart)
    "${HERE}/docks.sh" -r "${DOCKER_ROOT}" stop "${ARGS[@]}"
    "${HERE}/docks.sh" -r "${DOCKER_ROOT}" start "${ARGS[@]}"
    exit 0
  ;;
  lsc)
    PREFIX="$(getConfig prefix "")"
    PATTERN="${ARGS[0]:-^${PREFIX}}"
    # shellcheck disable=SC2312
    while read -r line; do
      SCREEN="$(echo "${line}" | cut -d \" -f 2)"
      echo "${PREFIX}${SCREEN}"
    done < <(getScreens) | grep -E "${PATTERN}"
    exit 0
  ;;
  lsr)
    PREFIX="$(getConfig prefix "")"
    PATTERN="${ARGS[0]:-.${PREFIX}}"
    # shellcheck disable=SC2312
    screen -ls | grep -E "${PATTERN}" | cut -d '.' -f 2 | cut -f 1
    exit 0
  ;;
  go)
    if [[ "${#ARGS[@]}" == 0 ]]; then
      ERROR="You must specify a screen"
      source "${HERE}/usage.sh"
    fi
    screen -x "${ARGS[0]}"
    exit 0
  ;;
  "")
    source "${HERE}/usage.sh"
  ;;
  *)
    ERROR="---- Unrecognized command: ${CMD}"
    source "${HERE}/usage.sh"
  ;;
esac
