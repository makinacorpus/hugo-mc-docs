#!/usr/bin/env bash
set -e
W=${W:-$(pwd)}
#export HUGO_VERSION=${HUGO_VERSION:-0.19}
export HUGO_VERSION=${HUGO_VERSION:-0.36}
export HUGO_DOWNLOAD_URL=${HUGO_DOWNLOAD_URL:-https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz}
case $HUGO_VERSION in
    0.19)DEFAULT_HUGO_DOWNLOAD_SHA256=f5edfa4275a5011ea92e1a79dc9023f5d801f8ad52fcf05afabd1ce644dcf954;;
    0.36)DEFAULT_HUGO_DOWNLOAD_SHA256=dc373a46487422f35ddedf4a4d3a490019d6aa4789db2bdf7475ef675bdfdff7;;
    *)
        DEFAULT_HUGO_DOWNLOAD_SHA256=;;
esac
export HUGO_DOWNLOAD_SHA256=${HUGO_DOWNLOAD_SHA256:-$DEFAULT_HUGO_DOWNLOAD_SHA256}
export HUGOPATH=${HUGOPATH:-${W}/var/hugo}
TAR=$(basename $HUGO_DOWNLOAD_URL)
cd "$W"
vv () { echo "$@">&2; "${@}"; }
shaverify() {
    if [[ -n $2 ]];then
        if ! echo "$2 $1" | sha256sum -c - >/dev/null 2>&1;then
            if [ -e $1 ];then
                echo "sha256 mismatch: $(sha256sum $1) != $2"
            else
                return 1
            fi
        fi
    fi
}
if [ ! -e ${HUGOPATH}/$HUGO_VERSION ];then mkdir -p ${HUGOPATH}/$HUGO_VERSION;fi
cd $HUGOPATH
if ! (shaverify $TAR $HUGO_DOWNLOAD_SHA256);then
    vv curl -fsSL -o $TAR "$HUGO_DOWNLOAD_URL"
fi
shaverify $TAR $HUGO_DOWNLOAD_SHA256
if tar -tf $TAR | grep -q "/";then
    tar -xvzf $TAR --strip-component=1 -C $HUGO_VERSION
else
    tar -xvzf $TAR -C $HUGO_VERSION
fi
candidate="$(ls -1 \
            "${HUGOPATH}/$HUGO_VERSION"/hugo \
            "${HUGOPATH}/$HUGO_VERSION"/hugo*linux* 2>/dev/null\
        |sort -V|head -n 1)"
set -x
test -f "${candidate}"
ln -fs "${candidate}" "${HUGOPATH}/hugo"
ls -1 "${HUGOPATH}/hugo"
# vim:set et sts=4 ts=4 tw=80:
