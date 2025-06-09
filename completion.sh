#shellcheck shell=bash
REAL_BASH_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
# shellcheck source-path=SCRIPTDIR
HERE="$(dirname "${REAL_BASH_SOURCE}")";

function complete_docks() {
  if [[ "$3" == "docks" ]]; then
    COMPREPLY=("--help" "-r" "in" "start" "go" "lsr" "lsc" "stop" "update")
  fi

  if [[ "$3" == "start" ]]; then
    source "${HERE}/env.sh"
    source "${HERE}/utils.sh"
    PREFIX="$(getConfig prefix "")"
    COMPREPLY=()
    while read line; do
      if [[ "${PREFIX}${line}" == "$2"* ]]; then
        COMPREPLY+=("${PREFIX}${line}")
      fi
    done < <(yq -r '.screens | to_entries[] | "\(.key)"' "${CONFIG}" 2>/dev/null | sort)
  fi

  if [[ "$3" == "stop" || "$3" == "go" ]]; then
    source "${HERE}/env.sh"
    source "${HERE}/utils.sh"
    PREFIX="$(getConfig prefix "")"
    COMPREPLY=()
    while read line; do
      if [[ "${line}" == "$2"* ]]; then
        COMPREPLY+=("${line}")
      fi
    done < <(screen -ls | grep -E "${PATTERN}" | cut -d '.' -f 2 | cut -f 1 | sort)
  fi

  if [[ "$3" == "-r" ]]; then
    COMPREPLY=($(ls "${2:-.}"))
  fi
}
complete -F complete_docks docks "${HOME}/.local/lib/docks/docks.sh"
