#!/usr/bin/env bash
NO_CLEANUP=${NO_CLEANUP-1}
PAGES_CHANGESET=""
DIR=$(dirname $(readlink  -f "$0"))
vv () { echo "$@">&2; "${@}"; }
cd $DIR/..
W=$(pwd)
CHANGESET=$(git log -n1 HEAD|awk '{print $2}'|head -n1)
if [[ $(git status -s) ]];then
    echo "The working directory is dirty ($W)."
	echo "Please commit any pending changes."
    exit 1
fi

cleanup() {
    cd "$W" && \
        if [[ -z "${NO_CLEANUP}" ]];then
            vv rm -rf hugoproject
        else
            echo "Skip cleanup"
        fi
}

refresh_project() {
    if [ ! -e themes/hugo-mc-docs ];then
        vv mkdir -p themes/hugo-mc-docs
    fi &&\
        vv rsync -azv ../ ./themes/hugo-mc-docs/ \
            --exclude=hugoproject \
            --exclude=node_modules \
            --exclude=public &&\
        vv sed -i -r \
 -e 's|baseURL: .*|baseURL: "https://makinacorpus.github.io/hugo-mc-docs/"|g' \
 -e 's|gitlab.foo.net|github.com|g' \
 -e 's|doc/umentation|makinacorpus/hugo-mc-docs|g' \
 -e 's|edit/master|edit/master/exampleSite|g' \
            config.yaml
}


echo "Deleting old publication"
rm -rf public

echo "Generating site"
cd "$W" && cleanup && \
	vv rsync -azv exampleSite/ ./hugoproject/ &&\
	vv cd hugoproject &&\
    refresh_project &&\
	vv themes/*/bin/control.sh install &&\
	vv themes/*/bin/control.sh gulp &&\
	vv rsync -azv public/ ../public/ --delete
ret=$?
cleanup
if [ "x$ret" != "x0" ];then
	echo "Gen failed"
	exit 1
fi
echo "Updating gh-pages branch"
    cd public && \
    vv rm -rf .git &&\
    vv git init &&\
    vv git add -f --all . && \
    vv git commit -am "Publishing pages (publish.sh)" &&\
    PAGES_CHANGESET=$(git log -n1 HEAD|awk '{print $2}'|head -n1)

if [[ -n ${PAGES_CHANGESET} ]];then
    URL=$(cd $W && git config --get remote.origin.url)
    vv git push --force "$URL" ${PAGES_CHANGESET}:refs/heads/gh-pages
else
    echo "Failed to build pages"
fi
exit $ret
# vim:set et sts=4 ts=4 tw=80:
