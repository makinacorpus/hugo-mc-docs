#!/usr/bin/env bash
if [[ -n $DEBUG ]];then set -x;fi
W=${W:-$(pwd)}
export NAME=nodejs
export APP_VERSION=${APP_VERSION:-7.7.1}
export YARN_VERSION=${YARN_VERSION:-0.22.0}
export YARN_ARCHIVE=yarn-v$YARN_VERSION.tar.gz
export APP_ARCHIVE=node-v$APP_VERSION-linux-x64.tar.xz
export KEYSERVER=${KEYSERVER:-keyserver.ubuntu.com}
export APP_PATH=${APP_PATH:-${W}/var/${NAME}}
cd "$W"
vv () { echo "$@">&2; "${@}"; }
die_in_error_() { if [ "x${1-$?}" != "x0" ];then echo "FAILED: $@">&2; exit 1; fi }
die_in_error() { die_in_error_ $? $@; }
shafverify() { grep " $1" "$2" 2>/dev/null| sha256sum -c - >/dev/null 2>&1; }
shaverify() { echo "$2 $1" | sha256sum -c - >/dev/null 2>&1; }
v() { shafverify $APP_ARCHIVE SHASUMS256.txt.asc; }
jv() { gpg -q --batch --verify $YARN_ARCHIVE.asc $YARN_ARCHIVE 2>/dev/null; }
if [ ! -e ${APP_PATH} ];then mkdir -p ${APP_PATH};fi
cd $APP_PATH
yarn_gpg=9D41F3C3
keys="\
$yarn_gpg \
6A010C5166006599AA17F08146C2130DFD2497F5 \
9554F04D7259F04124DE6B476D5A82AC7E37093B \
94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
FD3A5288F042B6850C66B31F09FE44734EB7990E \
71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
B9AE9905FFD7803F25714661B63B535A4C206CA9 \
C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
56730D5401028683275BD23C23EFEFE93C4CFFFE"
gpg -q --keyserver "$KEYSERVER" --recv-keys "$keys" 2>/dev/null
die_in_error gpg keys
# node
if ! v;then
    vv curl -SLO "https://nodejs.org/dist/v$APP_VERSION/SHASUMS256.txt.asc" &&\
    vv curl -SLO "https://nodejs.org/dist/v$APP_VERSION/$APP_ARCHIVE"
    die_in_error ${NAME} download
fi
v
die_in_error ${NAME} integrity
tar -xJf "node-v$APP_VERSION-linux-x64.tar.xz" --strip-components=1
die_in_error ${NAME} unpack
# yarn
if ! jv;then
    vv curl -fSL -O \
        "https://yarnpkg.com/downloads/$YARN_VERSION/$YARN_ARCHIVE.asc" &&\
    vv curl -fSL -O "https://yarnpkg.com/downloads/$YARN_VERSION/$YARN_ARCHIVE"
    die_in_error yarn download
fi
jv
die_in_error yarn integrity
tar -xzf "$YARN_ARCHIVE" --strip-components=1
die_in_error yarn unpack
# INSTALL
NODEBINS="${APP_PATH}/bin/node ${APP_PATH}/bin/${NAME}"
node_candidate="$(ls -1  $NODEBINS 2>/dev/null|sort -V|head -n 1)"
npm_candidate="$(ls -1 "${APP_PATH}"/bin/npm 2>/dev/null|sort -V|head -n 1)"
for i in "${node_candidate}" "${yarn_candidate}" "${npm_candidate}";do
    test -f "${i}"
done
for n in $NODEBINS;do
    if [  -e "${node_candidate}" ] && [ "x${n}" != "x${node_candidate}" ];then
        ln -sf "${node_candidate}" "${n}"
        die_in_error candidate $n link
    fi
done
chmod +x "${node_candidate}" "${APP_PATH}"/bin/yarn* "${npm_candidate}"
ls -1 "${APP_PATH}/bin/"{node,nodejs} "${APP_PATH}/bin/"npm*  "${APP_PATH}/bin/"yarn*
# vim:set et sts=4 ts=4 tw=0:
