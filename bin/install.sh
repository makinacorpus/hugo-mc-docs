#!/usr/bin/env bash
set -e
W=${W:-$(pwd)}
echo "Installing to $W" >&2
cd $(dirname $0)/..
vv () { echo "$@">&2; "${@}"; }
for sc in \
    bin/install_venv.sh \
    bin/install_node.sh \
    bin/install_hugo.sh;do
    if ! ( vv $sc );then
        echo "$sc failed"
        exit 1
    fi
done
. ${W}/var/venv/bin/activate
vv pip install --upgrade -r "$(dirname $(readlink -f $0))/../requirements.txt"
echo "Install success"
# vim:set et sts=4 ts=4 tw=80:
