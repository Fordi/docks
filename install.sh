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

if [[ "$0" != "${BASH_SOURCE[0]}" ]]; then
  mkdir -p "${HOME}/.local/lib"
  if [[ -d "${HOME}/.local/lib/docks" && ! -d "${HOME}/.local/lib/docks/.git" ]]; then
    rm -rf "${HOME}/.local/lib/docks"
  fi
  if [[ ! -d "${HOME}/.local/lib/docks" ]]; then
    git clone "https://github.com/Fordi/docks" "${HOME}/.local/lib/docks"
  else
    pushd "${HOME}/.local/lib/docks" > /dev/null 2>&1 || true
    git pull
    popd > /dev/null 2>&1 || true
  fi
  # shellcheck disable=SC1091
  bash "${HOME}/.local/lib/docks/install.sh"
  exit
fi

REAL_BASH_SOURCE="$(readlink -f "$0")"
HERE="$(dirname "${REAL_BASH_SOURCE}")";
echo "Installed to ${HERE}"
source "${HERE}/prereqs.sh"
HOME_BIN="$(home-bin)"
if [[ -L "${HOME_BIN}/docks" ]]; then
  rm "${HOME_BIN}/docks"
fi
ln -s "${HERE}/docks.sh" "${HOME_BIN}/docks" && echo "Symlinked to ${HOME_BIN}/docks"
