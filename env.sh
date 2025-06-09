#shellcheck shell=bash

function isHelp() {
  while [[ "$#" != "0" ]]; do
    if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "-?" || "$1" == "help" ]]; then
      return 0
    fi
  done
  return 1
}

function seekAbove() {
  local start="$1"; shift
  pushd "$start" > /dev/null 2>&1 || exit 1
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

if [[ "$1" == '-r' ]]; then
  shift
  pushd "$1" > /dev/null 2>&1 || exit 1
  shift
  DOCKER_ROOT="${PWD}"
else
  pushd . > /dev/null 2>&1
  DOCKER_ROOT="$(seekAbove "${PWD}")"
  if [[ -z "$DOCKER_ROOT" ]]; then
    if isHelp "$@"; then
      DOCKER_ROOT="{project root}"
    else
      echo "No .docks.yml found; exiting"
      exit 1
    fi
  fi 
fi
popd > /dev/null 2>&1 || exit 1

CONFIG="${DOCKER_ROOT}/.docks.yml"

if [[ ! -f "${CONFIG}" ]] && ! isHelp "$@"; then
  echo "You must create a YAML config file in ${CONFIG}" >&2
  exit 1
fi

export DOCKER_ROOT
export CONFIG
