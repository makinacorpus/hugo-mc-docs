# MakinaCorpus documentation Theme for hugo

## install/usage

```sh
mkdir hugoproject
cd hugoproject
git submodule add https://github.com/makinacorpus/hugo-mc-docs.git themes/hugo-mc-docs
# non docker
themes/hugo-mc-docs/bin/control.sh install
# or via docker (this start the gulp development server after build)
themes/hugo-mc-docs/bin/docker.sh
```
Create a content
```sh
./bin/control.sh hugo new content/doc.md
```

## Notes
- This theme install its own hugo, node & virtualenv flavors
    on local folders along the project (./var).
- Livesearch is enabled throrough lunr.js and a special crafted (via hugo at build time) JSON file.
