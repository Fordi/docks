#shellcheck shell=bash
function inDocker() {
  USER_ID="$(id -u)"; export USER_ID
  GROUP_ID="$(id -g)"; export GROUP_ID
  local args=()
  local session=
  while [[ $# != 0 ]]; do
    local arg="$1"; shift
    case "${arg}" in
      -S|--screen)
        session="$1"; shift
      ;;
      *)
        args+=("${arg}")
      ;;
    esac
  done

  local container;
  if [[ -z "${DOCKER_ROOT}" || ! -f "${CONFIG}" ]]; then
    if [[ -z "${session}" ]]; then
      echo "Asked to run '${args[*]}' inside a container, but no .docks.yml could be found from ${PWD}" >&2
    else
      echo "Asked to run '${args[*]}' inside a container as screen \"${session}\", but no .docks.yml could be found from ${PWD}" >&2
    fi
    exit 1
  fi
  container="$(getConfig container dev)"
  local docker=( docker compose exec "${container}" "${args[@]}" )
  if [[ -z "${session}" ]]; then
    "${docker[@]}"
  else
    echo "Starting ${fullName}; output in ${PWD}/${fullName}.log"
    rm "${session}.log" 2>/dev/null
    screen -S "${session}" -L -Logfile "${session}.log" -dm "${docker[@]}"
    
    local sockets=("/run/screen/S-${USER}/"*".${fullName}");
    local socket="${sockets[0]}"
    sleep 0.5
    if [[ ! -S "${socket}" ]]; then
      echo "Failed to start ${fullName}:"
      pr -to 2 < "${fullName}.log"
      rm "${fullName}.log"
    fi
  fi
}

function startScreen() {
  local name="$1"; shift
  local cmd=("${@}");
  local fullName;
  PREFIX="$(getConfig prefix "")"
  if [[ "${name}" == "${PREFIX}"* ]]; then
    fullName="${name}"
  else
    fullName="${PREFIX}${name}"
  fi
  if screen -ls "${fullName}" > /dev/null 2>&1; then
    echo "${fullName} already running"
  else
    pushd "${DOCKER_ROOT}" > /dev/null 2>&1 || return 1
    inDocker -S "${fullName}" "${cmd[@]}"
    popd  > /dev/null 2>&1 || return 1
  fi
}

function endScreen() {
  local name="$1"; shift
  local fullName;
  PREFIX="$(getConfig prefix "")"
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
  if [[ -z "${DOCKER_ROOT}" || ! -f "${CONFIG}" ]]; then
    echo "No .docks.yml found" >&2
    exit 1
  fi
  yq -r '.screens | to_entries[] | "\"\(.key)\" \"\(.value)\""' "${CONFIG}" 2>/dev/null || \
    echo "Nothing in ${CONFIG}" >&2
}

function getConfig() {
  if [[ -z "${DOCKER_ROOT}" || ! -f "${CONFIG}" ]]; then
    echo "No .docks.yml found" >&2
    exit 1
  fi
  yq -r '.["'"$1"'"] // "'"$2"'"' "${CONFIG}" 2>/dev/null
}
