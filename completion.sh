#shellcheck shell=bash
REAL_BASH_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
# shellcheck source-path=SCRIPTDIR
HERE="$(dirname "${REAL_BASH_SOURCE}")";

function complete_docks() {
  local entry="$2";
  local last="$3";
  case "${last}" in
    start)
      source "${HERE}/env.sh"
      source "${HERE}/utils.sh"
      PREFIX="$(getConfig prefix "")"
      COMPREPLY=()
      while read -r line; do
        COMPREPLY+=("${line}")
      done < <(yq -r '.screens | to_entries[] | "'"${PREFIX}"'\(.key)"' "${CONFIG}" 2>/dev/null | grep "${entry}" | sort)
    ;;
    stop|go|restart)
      source "${HERE}/env.sh"
      source "${HERE}/utils.sh"
      PREFIX="$(getConfig prefix "")"
      COMPREPLY=()
      while read -r line; do
        COMPREPLY+=("${line}")
      done < <(screen -ls | grep -E ".${PREFIX}" | cut -d '.' -f 2 | cut -f 1 | grep "${entry}" | sort)
    ;;
    -r|--root)
      COMPREPLY=("$(compgen -d -- "${entry}")")
    ;;
    in)
      COMPREPLY=("--screen")
      while read -r line; do
        COMPREPLY+=("${line}")
      done < <(compgen -c -- "${entry}")
    ;;
    -S|--screen)
      COMPREPLY=()
    ;;
    *)
      COMPREPLY=();
      while read -r line; do
        COMPREPLY+=("${line}")
      done < <(compgen -W "help --root --screen in start stop restart go lsr lsc update" -- "${entry}")
    ;;
  esac
}
complete -F complete_docks docks "${HOME}/.local/lib/docks/docks.sh"
