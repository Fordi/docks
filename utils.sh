#!/bin/bash

function startScreen() {
  local name="$1"; shift
  local cmd=("${@}");
  local fullName;
  if [[ "${name}" == "${PREFIX}"* ]]; then
    fullName="${name}"
  else
    fullName="${PREFIX}${name}"
  fi
  pushd "${DOCKER_ROOT}" || return 1 > /dev/null 2>&1
  if screen -ls "${fullName}" > /dev/null 2>&1; then
    echo "${fullName} already running"
  else
    echo "Starting ${fullName}; output in ${DOCKER_ROOT}/${fullName}.log"
    USER_ID="$(id -u)"; export USER_ID
    GROUP_ID="$(id -g)"; export GROUP_ID
    screen -S "${fullName}" -L -Logfile "${DOCKER_ROOT}/${fullName}.log" -dm docker compose exec "${CONTAINER}" "${cmd[@]}"
    local sockets=("/run/screen/S-${USER}/"*".${fullName}");
    local socket="${sockets[0]}"
    if [[ ! -S "${socket}" ]]; then
      echo "Failed to start ${fullName}:"
      pr -to 2 < "${DOCKER_ROOT}/${fullName}.log"
      rm "${DOCKER_ROOT}/${fullName}.log"
    fi

  fi
  popd  > /dev/null 2>&1 || return 1
}

function endScreen() {
  local name="$1"; shift
  local fullName;
  if [[ "${name}" == "${PREFIX}"* ]]; then
    fullName="${name}"
  else
    fullName="${PREFIX}${name}"
  fi
  pushd "${DOCKER_ROOT}" > /dev/null 2>&1 || return 1
  if screen -ls "${fullName}" > /dev/null 2>&1; then
    echo "Terminating ${fullName}"
    screen -XS "${fullName}" quit
  else
    echo "${fullName} not running"
  fi
  popd > /dev/null 2>&1 || return 1
}

function containsElement() {
  local item=$1; shift;
  local e;
  for e; do [[ "${e}" == "${item}" ]] && return 0; done
  return 1;
}
