#!/usr/bin/env bash
set -e
export SC=$(readlink -f "$0")
export DSC=$(dirname "$SC")
. "$DSC/common" || exit 1

call_gulp() {
    cd themes/hugo-mc-docs/pipeline
    export PATH=$(pwd)/node_modules/.bin:$PATH
    for i in gulp bower grunt;do
        if ! hash -r $i >/dev/null 2>&1; then
            npm install $i
        fi
    done
    for i in gulp-server-livereload gulp-cli;do
        if [ ! -e node_modules/$i ];then
            npm install $i
        fi
    done
    if [ ! -e node_modules/gulp-babel ];then
        npm install
    fi
    if [[ -n $FORCE_NPM ]];then npm install;fi
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
            echo "Will restart in 15sec, interrupt with <C-C> or ENTER to restart"
            read -t 15 || /bin/true
        else
            break
        fi
    done
    return ${ret}
}
infest() {
    cd "$W"
    if [ ! -e bin ];then mkdir bin;fi
    for i in "${W}/bin" "${W}/venv/bin";do
        ln -fvs ../themes/hugo-mc-docs/bin/control.sh "${i}"
        ln -fvs ../themes/hugo-mc-docs/bin/docker.sh  "${i}"
        ln -fs "$W/var/node/bin/node"   "${i}"
        ln -fs "$W/var/node/bin/nodejs" "${i}"
        ln -fs "$W/var/node/bin/npm"    "${i}"
        ln -fs "$W/var/node/bin/yarn"   "${i}"
        ln -fs "$W/var/hugo/hugo"       "${i}"
    done

}
install() {
    cd "$W"
    infest
    for sc in \
        $THEME/bin/install_venv.sh \
        $THEME/bin/install_node.sh \
        $THEME/bin/install_hugo.sh;do
        echo "Running $sc" >&2
        if ! ( $sc );then
            echo "$sc failed"
            exit 1
        fi
    done
    pip install --upgrade -r $THEME/requirements.txt
    echo "Install success"
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
            cd "$W"
            shift
            ( call_gulp $@; )
            ;;
        "watch"*)
            cd "$W"
            shift
            ( call_gulp watch $@; )
            ;;
        "serve"*)
            cd "$W"
            shift
            ( call_gulp serve $@; )
            ;;
        "hugo_server")
            cd "$W"
            shift
            hugo server -v -w --bind=0.0.0.0 --forceSyncStatic $@
            ;;
        "build")
            # hugo is called from gulp itself
            cd "$W"
            ( call_gulp; )
            ;;
        "hugo "*)
            cd "$W"
            $@
            ;;
        *)
            echo "$0 build|serve|install|infest|hugo_server|gulp"
            exit 1
            ;;
    esac
}
main "${@}"
# vim:set et sts=4 ts=4 tw=80:
