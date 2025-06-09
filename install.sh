#!/bin/bash
function home-bin() {
  while read -r -d ':' item; do
    if [[ "${item}" == "${HOME}/.local/bin" \
      || "${item}" == "${HOME}/bin" \
      || "${item}" == "${HOME}/.bin"
    ]]; then
      echo "${item}";
      return 0;
    fi
  done < <(echo "${PATH}")
  mkdir -p "${HOME}/.local/bin"
  echo "${HOME}/.local/bin"
  echo "PATH=\"${HOME}/.local/bin:\$PATH\"" >> "${HOME}/.bashrc"
  export PATH="${HOME}/.local/bin:${PATH}"
  echo "Warning: No local user bin directory; created ${HOME}/.local/bin and added to PATH"
}

if [[ "$0" == "bash" ]]; then
  mkdir -p "${HOME}/.local/lib"
  if [[ ! -d "${HOME}/.local/lib/docks" ]]; then
    git clone "https://github.com/Fordi/docks" "${HOME}/.local/lib/docks"
    # shellcheck disable=SC1091
    . "${HOME}/.local/lib/docks/install.sh"
    exit
  fi
fi
REAL_BASH_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
HERE="$(dirname "${REAL_BASH_SOURCE}")";
HOME_BIN="$(home-bin)"
ln -s "${HERE}/docks.sh" "${HOME_BIN}/docks"
