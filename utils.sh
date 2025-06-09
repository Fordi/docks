#shellcheck shell=bash
function inDocker() {
  USER_ID="$(id -u)"; export USER_ID
  GROUP_ID="$(id -g)"; export GROUP_ID
  docker compose exec "${CONTAINER}" "$@"
}

function startScreen() {
  local name="$1"; shift
  local cmd=("${@}");
  local fullName;
  if [[ "${name}" == "${PREFIX}"* ]]; then
    fullName="${name}"
  else
    fullName="${PREFIX}${name}"
  fi
  if screen -ls "${fullName}" > /dev/null 2>&1; then
    echo "${fullName} already running"
  else
    pushd "${DOCKER_ROOT}" > /dev/null 2>&1 || return 1
    echo "Starting ${fullName}; output in ${PWD}/${fullName}.log"
    USER_ID="$(id -u)"; export USER_ID
    GROUP_ID="$(id -g)"; export GROUP_ID
    screen -S "${fullName}" -L -Logfile "${fullName}.log" -dm docker compose exec "${CONTAINER}" "${cmd[@]}"
    local sockets=("/run/screen/S-${USER}/"*".${fullName}");
    local socket="${sockets[0]}"
    if [[ ! -S "${socket}" ]]; then
      echo "Failed to start ${fullName}:"
      pr -to 2 < "${fullName}.log"
      rm "${fullName}.log"
    fi
    popd  > /dev/null 2>&1 || return 1
  fi
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
    screen -S "${fullName}" -X at 0 stuff '^C'
    screen -S "${fullName}" -X at 0 stuff "exit\n"
    
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

CONFIG="${DOCKER_ROOT}/.docks.yml"

function getScreens() {
  yq -r '.screens | to_entries[] | "\"\(.key)\" \"\(.value)\""' "${CONFIG}" 2>/dev/null || \
    echo "Nothing in ${CONFIG}" >&2
}

function getConfig() {
  yq -r '.["'"$1"'"] // "'"$2"'"' "${CONFIG}" 2>/dev/null
}