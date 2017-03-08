#!/usr/bin/env bash
set -e
export SC=$(readlink -f "$0")
export DSC=$(dirname "$SC")
. "$DSC/common" || exit 1
cd "$W"
export NODE_INSTALL=${NODE_INSTALL:-y}
export NPM_CONFIG_LOGLEVEL=${NPM_CONFIG_LOGLEVEL:-info}
export NODE_VERSION=${NODE_VERSION:-7.7.1}
export YARN_VERSION=${YARN_VERSION:-0.21.3}
export KEYSERVER=${KEYSERVER:-keyserver.ubuntu.com}
export KEYSERVER=${KEYSERVER:-ha.pool.sks-keyservers.net}
if [ "x$(whoami)" = "xroot" ];then
    DEFAULT_NODE_PATH=/srv/apps/nodejs
else
    DEFAULT_NODE_PATH=${W}/var/nodejs
fi
export NODEPATH=${NODEPATH:-${DEFAULT_NODE_PATH}}
set -ex
if [ ! -e ${NODEPATH} ];then mkdir -p ${NODEPATH};fi
cd $NODEPATH
# node
for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do gpg --keyserver "$KEYSERVER" --recv-keys "$key"
done
curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz"
curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c -
tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" --strip-components=1
rm SHASUMS256.txt
# yarn
for key in 6A010C5166006599AA17F08146C2130DFD2497F5; do
    gpg --keyserver "$KEYSERVER" --recv-keys "$key"
done
curl -fSL -o yarn.js "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js"
curl -fSL -o yarn.js.asc "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-legacy-$YARN_VERSION.js.asc"
gpg --batch --verify yarn.js.asc yarn.js
# INSTALL
node_candidate="$(ls -1 "${NODEPATH}"/bin/node "${NODEPATH}"/bin/nodejs 2>/dev/null|sort -V|head -n 1)"
npm_candidate="$(ls -1 "${NODEPATH}"/bin/npm 2>/dev/null|sort -V|head -n 1)"
yarn_candidate="$(ls -1 "${NODEPATH}"/yarn.js 2>/dev/null|sort -V|head -n 1)"
for i in "${node_candidate}" "${yarn_candidate}" "${npm_candidate}";do
    test -f "${i}"
done
chmod +x "${node_candidate}" "${yarn_candidate}" "${npm_candidate}"
if [[ -n $NODE_INSTALL ]];then
    for i in "${W}/bin" "${W}/venv/bin";do
        if [ -e "${i}" ];then
            ln -fs "${node_candidate}" "${i}/node"
            ln -fs "${node_candidate}" "${i}/nodejs"
            ln -fs "${npm_candidate}"  "${i}/npm"
            ln -fs "${yarn_candidate}" "${i}/yarn"
        fi
    done
fi
# vim:set et sts=4 ts=4 tw=80:
