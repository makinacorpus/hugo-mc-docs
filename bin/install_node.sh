#!/usr/bin/env bash
set -e
W=${W:-$(pwd)}
cd "$W"
vv () { echo "$@">&2; "${@}"; }
shaverify() { echo "$1 $2" | sha256sum -c - >/dev/null 2>&1; }
shafverify() { grep " $1" "$2" 2>/dev/null| sha256sum -c - >/dev/null 2>&1; }
v() { shafverify node-v$NODE_VERSION-linux-x64.tar.xz SHASUMS256.txt.asc; }
jv() { gpg -q --batch --verify yarn.js.asc yarn.js 2>/dev/null; }
export NODE_INSTALL=${NODE_INSTALL:-y}
export NPM_CONFIG_LOGLEVEL=${NPM_CONFIG_LOGLEVEL:-info}
export NODE_VERSION=${NODE_VERSION:-7.7.1}
export YARN_VERSION=${YARN_VERSION:-0.21.3}
export KEYSERVER=${KEYSERVER:-keyserver.ubuntu.com}
export KEYSERVER=${KEYSERVER:-ha.pool.sks-keyservers.net}
export NODEPATH=${NODEPATH:-${W}/var/nodejs}
if [ ! -e ${NODEPATH} ];then mkdir -p ${NODEPATH};fi
cd $NODEPATH
keys="\
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
# node
if ! v;then
    vv curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
    vv curl -SLO -C - \
        "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz"
fi
v
tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" --strip-components=1
# yarn
if ! jv;then
    vv curl -fSL -o yarn.js.asc \
        "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js.asc"
    vv curl -fSL -C - -o yarn.js \
        "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js"
fi
jv
# INSTALL
NODEBINS="${NODEPATH}/bin/node ${NODEPATH}/bin/nodejs"
node_candidate="$(ls -1  $NODEBINS 2>/dev/null|sort -V|head -n 1)"
npm_candidate="$(ls -1 "${NODEPATH}"/bin/npm 2>/dev/null|sort -V|head -n 1)"
yarn_candidate="$(ls -1 "${NODEPATH}"/yarn.js 2>/dev/null|sort -V|head -n 1)"
for i in "${node_candidate}" "${yarn_candidate}" "${npm_candidate}";do
    test -f "${i}"
done
for n in $NODEBINS;do
    if [  -e "${node_candidate}" ] && [ "x${n}" != "x${node_candidate}" ];then
        ln -sf "${node_candidate}" "${n}"
    fi
done
chmod +x "${node_candidate}" "${yarn_candidate}" "${npm_candidate}"
ls -1 "${node_candidate}" "${yarn_candidate}" "${npm_candidate}"
# vim:set et sts=4 ts=4 tw=0:
