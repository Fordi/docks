#shellcheck shell=bash
if [[ "$1" == '-r' ]]; then
  shift
  pushd "$1" > /dev/null 2>&1 || exit 1
  shift
  DOCKER_ROOT="${PWD}"
else
  pushd . > /dev/null 2>&1
  while [[ "${PWD}" != "/" && ! -f ".docks.yml" ]]; do
    cd ..
  done
  if [[ "${PWD}" == "/" && ! -f ".docks.yml" ]]; then
    echo "No .docks.yml found; exiting"
    exit 1
  fi
  DOCKER_ROOT="${PWD}"
fi
popd > /dev/null 2>&1 || exit 1

CONFIG="${DOCKER_ROOT}/.docks"

if [[ ! -f "${CONFIG}" ]]; then
  echo "You must create a JSON config file in ${CONFIG}" >&2
  exit 1
fi

export DOCKER_ROOT
export CONFIG
