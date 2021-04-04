#!/usr/bin/env bash
# usage:
#   $0 serve
#   $0 gulp
#   $0 nocmd bash

set -e
export SC=$(readlink -f "$0")
export DSC=$(dirname "$SC")
export TAG=${TAG:-makinacorpus/sysdoc}
. "$DSC/common" || exit 1
cd "${W}"
vv () { echo "$@">&2; "${@}"; }
if [[ -z $NO_BUILD ]];then
    export DOCKERFILE="themes/$(basename $THEME)/Dockerfile"
    cat $DOCKERFILE | docker build --cache-from=$TAG -f - -t ${TAG} .
fi
main() {
    local cmd=/s/bin/control.sh
    if [[ "$1" == "nocmd" ]];then
        cmd=""
        shift
    fi
    local args=${@:-serve}
    case ${args} in
        serve*)
            dargs="-p ${LIVERELOAD_PORT:-35729}:35729 -p ${HUGOPORT:-1313}:1313"
            ;;
        *)
            dargs=""
            ;;
    esac
    vv exec docker run --rm -ti \
        $(echo $dargs) \
        -v "$W/content:/s/content" \
        -v "$W/data:/s/data" \
        -v "$W/i18n:/s/i18n" \
        -v "$W/layouts:/s/layouts" \
        -v "$W/public:/s/public" \
        -v "$W/static:/s/static" \
        -v "$W/themes:/s/themes" \
        -v "$W/.git:/s/.git" \
        "$TAG" ${cmd} ${args}
}
main "${@}"
# vim:set et sts=4 ts=4 tw=80:
