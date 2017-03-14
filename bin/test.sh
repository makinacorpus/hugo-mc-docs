#!/usr/bin/env bash
CLEANUP=${CLEANUP-}
DIR=$(dirname $(readlink  -f "$0"))
vv () { echo "$@">&2; "${@}"; }
cd $DIR/..
W=$(pwd)
TW=$(dirname $W)
TP=$TW/doctestproject
cleanup() {
    if [[ -n "${CLEANUP}" ]];then
        if [ -e "$TP" ];then
            vv rm -rf "$TP"
        fi
    else
        echo "Skip cleanup"
    fi
    if [ ! -e "$TP" ];then mkdir -pv "$TP";fi
    vv rm -rf "$TP/public"
}
refresh_project() {
    cd "$TP" &&\
        if [ ! -e themes ];then
            vv mkdir -p themes
        fi &&\
            rm -f ./themes/hugo-mc-docs &&\
            ln -sf "$W" ./themes/hugo-mc-docs &&\
            vv sed -i -r \
     -e 's|baseURL: .*|baseURL: "/"|g' \
     -e 's|gitlab.foo.net|github.com|g' \
     -e 's|doc/umentation|makinacorpus/hugo-mc-docs|g' \
     -e 's|edit/master|edit/master/exampleSite|g' \
         config.yaml &&\
        cd -
}
cleanup && \
    vv rsync -azv "$W/exampleSite/" "$TP/" &&\
    refresh_project &&\
    ( export W=$TP &&\
      vv $TP/themes/*/bin/control.sh install &&\
      vv $TP/themes/*/bin/control.sh gulp ${@:-serve})
ret=$?
cleanup
if [ "x$ret" != "x0" ];then
	echo "Test failed"
	exit 1
fi
exit $ret
# vim:set et sts=4 ts=4 tw=80:
