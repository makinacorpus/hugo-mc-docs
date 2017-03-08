#!/usr/bin/env bash
set -e
export SC=$(readlink -f "$0")
export DSC=$(dirname "$SC")
. "$DSC/common" || exit 1
cd "$W"
if ! (hash -r virtualenv);then
    echo "install virtualenv please !"
    exit 1
fi
if [ ! -e venv/bin/activate ];then
    virtualenv --no-site-packages venv
fi
. venv/bin/activate
pip install --upgrade -r requirements.txt
# vim:set et sts=4 ts=4 tw=80:
