#!/usr/bin/env bash
set -e
W=${W:-$(pwd)}
cd "$W"
vv () { echo "$@">&2; "${@}"; }
export HUGO_INSTALL=${HUGO_INSTALL:-1}
export HUGO_VERSION=${HUGO_VERSION:-0.19}
export HUGO_DOWNLOAD_URL=${HUGO_DOWNLOAD_URL:-https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz}
export HUGO_DOWNLOAD_SHA256=${HUGO_DOWNLOAD_SHA256:-f5edfa4275a5011ea92e1a79dc9023f5d801f8ad52fcf05afabd1ce644dcf954}
export HUGOPATH=${HUGOPATH:-${W}/var/hugo}
shaverify() { echo "$2 $1" | sha256sum -c - >/dev/null 2>&1; }
if [ ! -e ${HUGOPATH} ];then mkdir -p ${HUGOPATH};fi
cd $HUGOPATH
if ! (shaverify HUGO.tar.gz $HUGO_DOWNLOAD_SHA256);then
    vv curl -fsSL -o HUGO.tar.gz -C - "$HUGO_DOWNLOAD_URL"
fi
shaverify HUGO.tar.gz $HUGO_DOWNLOAD_SHA256
tar -xzf HUGO.tar.gz --strip-component=1
candidate="$(ls -1 "${HUGOPATH}"/hugo*linux*\
             |sort -V|head -n 1)"
test -f "${candidate}"
ln -fs "${candidate}" "${HUGOPATH}/hugo"
ls -1 "${HUGOPATH}/hugo"
# vim:set et sts=4 ts=4 tw=80:
