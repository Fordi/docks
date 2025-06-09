#shellcheck shell=bash

if [[ -n "$CONTAINER" ]]; then
  CONTAINER=" (current: ${CONTAINER})"
fi

DEFAULT_ROOT="$(seekAbove "$PWD")"
if [[ -z "$DEFAULT_ROOT" ]]; then
  DEFAULT_ROOT="pwd"
fi

echo "$(basename "$0") -h | --help | [-r {project root}] {command} <...args>"
echo "  -r {project root}  Set project root (defaults to ${DEFAULT_ROOT}) or whatever" >&2
echo "                     folder above contains '.docks.yml' (must be first arg if present)" >&2
echo "  start              Start all screens" >&2
echo "  start {names...}   Start the screens named {names...}" >&2
echo "  go {name}          Connect interactively with {name}" >&2
echo "  in {command}       Run a command inside the configured container${CONTAINER}" >&2
echo "  kill               Kill all screens" >&2
echo "  kill {names...}    Kill screens {names...}" >&2
echo "  lsr                List running screens" >&2
echo "  lsr {pattern}      List running screens matching {pattern} (egrep)" >&2
echo "  lsc                List configured screens" >&2
echo "  lsc {pattern}      List configured screens matching {pattern}" >&2
echo "  update             Check for updates" >&2
echo "Logs are stored in \`${DOCKER_ROOT}/{name}.log\`" >&2
echo "Screens are configured in \`${DOCKER_ROOT}/.docks.yml\`" >&2

if [[ -n "$1" ]]; then
  echo "--- Unknown command: $1" >&2
  exit 1
fi

exit