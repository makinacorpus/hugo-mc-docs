#!/usr/bin/env bash
set -e
export SC=$(readlink -f "$0")
export DSC=$(dirname "$SC")
. "$DSC/common" || exit 1
cd "${W}"
vv () { echo "$@">&2; "${@}"; }
call_gulp() {
    export PATH=${THEME}/pipeline/node_modules/.bin:$PATH
    . ${VENV_PATH}/bin/activate
    cd $THEME/pipeline
    for i in gulp bower grunt;do
        if ! hash -r $i >/dev/null 2>&1; then
            yarn add $i
        fi
    done
    for i in gulp-sass gulp-babel gulp-server-livereload gulp-cli file-exists;do
        if [ ! -e node_modules/$i ];then
            yarn install
        fi
    done
    if [[ -n $FORCE_NPM ]];then yarn install;fi
    retry=""
    case $@ in
        "watch"*|"serve"*) retry=1;;
        *) retry="";;
    esac
    ret=0
    while true;do
        gulp $@ || /bin/true
        ret=$?
        if [[ -n "${retry}" ]];then
            echo "Will restart in 15sec, interrupt with <C-C>" \
                " or ENTER to restart"
            read -t 15 || /bin/true
        else
            break
        fi
    done
    return ${ret}
}
infest() {
    if [ ! -e bin ];then mkdir bin;fi
    for i in "${W}/bin" "${VENV_PATH}/bin";do
        ln -fvs $THEME/bin/control.sh   "${i}"
        ln -fvs $THEME/bin/docker.sh    "${i}"
        ln -fs "$W/var/nodejs/bin/node"   "${i}"
        ln -fs "$W/var/nodejs/bin/nodejs" "${i}"
        ln -fs "$W/var/nodejs/bin/npm"    "${i}"
        ln -fs "$W/var/nodejs/bin/yarn"   "${i}"
        ln -fs "$W/var/hugo/hugo"       "${i}"
    done
}
install() {
    "$THEME/bin/install.sh"
    infest
}
vactivate() {
    . "$W/var/venv/bin/activate"
}
main() {
    case $@ in
        "install")
            install
            ;;
        "infest")
            infest
            ;;
        "gulp"*)
            shift
            ( call_gulp $@; )
            ;;
        "watch"*)
            shift
            ( call_gulp watch $@; )
            ;;
        "serve"*)
            shift
            ( call_gulp serve $@; )
            ;;
        "hugo"*)
            ( vactivate && $@ ;)
            ;;
        *)
            echo "$0 gulp|serve|watch|install|infest|hugo"
            exit 1
            ;;
    esac
}
main "${@}"
# vim:set et sts=4 ts=4 tw=80:
