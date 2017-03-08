#!/usr/bin/env bash
set -e
export SC=$(readlink -f "$0")
export DSC=$(dirname "$SC")
. "$DSC/common" || exit 1
cd "$W"
export HUGO_INSTALL=${HUGO_INSTALL:-1}
export HUGO_VERSION=${HUGO_VERSION:-0.19}
export HUGO_DOWNLOAD_URL=${HUGO_DOWNLOAD_URL:-https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz}
export HUGO_DOWNLOAD_SHA256=${HUGO_DOWNLOAD_SHA256:-f5edfa4275a5011ea92e1a79dc9023f5d801f8ad52fcf05afabd1ce644dcf954}
if [ "x$(whoami)" = "xroot" ];then
    DEFAULT_HUGO_PATH=/srv/apps/hugo
else
    DEFAULT_HUGO_PATH=${W}/var/hugo
fi
export HUGOPATH=${HUGOPATH:-${DEFAULT_HUGO_PATH}}
set -ex
if [ ! -e ${HUGOPATH} ];then mkdir -p ${HUGOPATH};fi
cd $HUGOPATH
curl -fsSL "$HUGO_DOWNLOAD_URL" -o HUGO.tar.gz
if ! (echo "$HUGO_DOWNLOAD_SHA256 HUGO.tar.gz" \
        | sha256sum -w -c -);then
    sha256sum HUGO.tar.gz;exit 1
fi
tar -xzf HUGO.tar.gz --strip-component=1
candidate="$(ls -1 "${HUGOPATH}"/hugo*linux*\
             |sort -V|head -n 1)"
test -f "${candidate}"
if [[ -n $HUGO_INSTALL ]];then
    for i in "${W}/bin" "${W}/venv/bin";do
        if [ -e "${i}" ];then
            ln -fs "${candidate}" "${i}/hugo"
        fi
    done
fi
# vim:set et sts=4 ts=4 tw=80:
