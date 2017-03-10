#!/usr/bin/env bash
set -e
W=${W:-$(pwd)}
cd "$W"
export VENV_PATH=${VENV_PATH:-${W}/var/venv}
if ! (hash -r virtualenv);then
    echo "install virtualenv please !"
    exit 1
fi
if [ ! -e "${VENV_PATH}"/bin/activate ];then
    virtualenv --no-site-packages "${VENV_PATH}"
fi
. "${VENV_PATH}"/bin/activate
ls -1 "${VENV_PATH}/bin/python"
# vim:set et sts=4 ts=4 tw=80:
