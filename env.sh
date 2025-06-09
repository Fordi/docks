#shellcheck shell=bash
if [[ "$1" == '-r' ]]; then
  shift
  pushd "$1" > /dev/null 2>&1 || exit 1
  shift
  DOCKER_ROOT="${PWD}"
else
  pushd . > /dev/null 2>&1
  while [[ "${PWD}" != "/" && ! -f "./docker-compose.yml" ]]; do
    cd ..
  done
  if [[ "${PWD}" == "/" && ! -f "./docker-compose.yml" ]]; then
    echo "No docker compose found; exiting"
    exit 1
  fi
  DOCKER_ROOT="${PWD}"
fi
popd > /dev/null 2>&1 || exit 1

CONFIG="${DOCKER_ROOT}/.screens"

if [[ ! -f "${CONFIG}" ]]; then
  echo "You must create a JSON config file in ${CONFIG}" >&2
  exit 1
fi

export DOCKER_ROOT
export CONFIG
