#!/usr/bin/env bash
set -e
export SC=$(readlink -f "$0")
export DSC=$(dirname "$SC")
. "$DSC/common" || exit 1
if [[ -z $NO_BUILD ]];then
    set -x
    # handle pb with node_modules that is too heavy
    # and still uploaded to context despite being ignored
    # by dockerignore
    tar -cf - .\
        --exclude={venv,.git,var,build,themes/*/*/node_modules} \
        | docker build -t makinacorpus/sysdoc -
    # docker build -t makinacorpus/sysdoc .
    set +x
fi
BMODE=${BMODE:-${@:-hugo_server}}
case $BMODE in
    gulp) bcommand="gulp";;
    hugo_build) bcommand="hugo_build";;
    *|hugo_server) bcommand="hugo_server";;
esac
set -ex
echo $bcommand
case $bcommand in
    gulp*)dargs="";;
    *)dargs="-p ${LIVERELOAD_PORT:-35729}:35729 -p ${HUGOPORT:-1313}:1313";;
esac
exec docker run --rm -ti\
    $(echo $dargs)\
    -v "$W/build:/s/build" \
    -v "$W/docs:/s/docs" \
    -v "$W/themes:/s/themes" \
    -v "$W/Makefile:/s/Makefile" \
    makinacorpus/sysdoc "/s/bin/control.sh" ${bcommand}
# vim:set et sts=4 ts=4 tw=80:
