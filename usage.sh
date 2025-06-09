#shellcheck shell=bash

echo "$(basename "$0") -h | --help | [-r {project root}] {command} <...args>"
echo "  -r {project root}  Set project root (defaults to pwd) or whatever" >&2
echo "                     folder above contains '.docks.yml'" >&2
echo "  start              Start all screens" >&2
echo "  start {names...}   Start the screens named {names...}" >&2
echo "  go {name}          Connect interactively with {name}" >&2
echo "  kill               Kill all screens" >&2
echo "  kill {names...}    Kill screens {names...}" >&2
echo "  lsr                List running screens" >&2
echo "  lsr {pattern}      List running screens matching {pattern} (egrep)" >&2
echo "  lsc                List configured screens" >&2
echo "  lsc {pattern}      List configured screens matching {pattern}" >&2
echo "Logs are stored in \`${DOCKER_ROOT:-{project root}}/{name}.log\`" >&2
echo "Screens are configured in \`${DOCKER_ROOT:-{project root}}\`/.docks.yml" >&2

if [[ -n "$1" ]]; then
  echo "--- Unknown command: $1" >&2
  exit 1
fi

exit