#shellcheck shell=bash
function seekAbove() {
  local start="$1"; shift
  pushd "${start}" > /dev/null 2>&1 || exit 1
  while [[ "${PWD}" != "/" && ! -f ".docks.yml" ]]; do
    cd ..
  done
  local ROOT=""
  if [[ -f ".docks.yml" ]]; then
    ROOT="${PWD}"
  fi
  popd > /dev/null 2>&1 || exit 1
  echo "${ROOT}"
}

ARGS=()
DOCKER_ROOT=
HELP=0

while [[ $# != 0 ]]; do
  ARG="$1"
  shift;
  case "${ARG}" in
    -h|--help|-\?|help)
      HELP=1
    ;;
    -r|--root)
      DOCKER_ROOT="$1"
      shift
    ;;
    --)
      while [[ $# != 0 ]]; do
        ARGS+=("$1")
        shift
      done
    ;;
    -?)
      export ERROR="---- Unrecognized option: ${ARG}"
      source "${HERE}/usage.sh"
    ;;
    *)
      ARGS+=("${ARG}")
    ;;
  esac
done

case "${ARGS[0]}" in
  stop|start|in|restart|lsc|lsr|go|update)
    CMD="${ARGS[0]}"
    ARGS=( "${ARGS[@]:1}" )
  ;;
  "");;
  *)
    CMD=in
  ;;
esac

if [[ "${HELP}" == "1" ]]; then
  CMD=help
fi

if [[ -z "${DOCKER_ROOT}" ]]; then
  pushd . > /dev/null 2>&1
  DOCKER_ROOT="$(seekAbove "${PWD}")"
  if [[ -z "${DOCKER_ROOT}" ]]; then
    if [[ "${CMD}" == "help" ]]; then
      DOCKER_ROOT="{project root}"
    fi
  fi
  popd > /dev/null 2>&1 || exit 1
fi

export DOCKER_ROOT
export CONFIG
export CMD
export ARGS
