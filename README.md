# MakinaCorpus documentation Theme for hugo
## initialize a new project based on this theme

```sh
mkdir hugoproject
cd hugoproject
git init
mkdir content data layouts i18n public static
git submodule add https://github.com/makinacorpus/hugo-mc-docs.git themes/hugo-mc-docs
cd themes/hugo-mc-docs/exampleSite
cp -r ../.gitignore * ../../..
cd ../../..
git add .
$EDITOR config.yaml
git commit -am init
```

## install/usage

- non docker

    ```sh
    themes/hugo-mc-docs/bin/control.sh install
    # This start the gulp development server after build)
    themes/hugo-mc-docs/bin/control.sh serve
    ```

- Via docker, note that the script will start the gulp development server after build

    ```sh
    themes/hugo-mc-docs/bin/docker.sh
    ```
- Create a content

    ```sh
    ./bin/control.sh hugo new content/doc.md
    ```

## Notes
- This theme install its own hugo, node & virtualenv flavors
    on local folders along the project (./var).
- naviguation is inspired from Material themes
- Livesearch is enabled throrough lunr.js and a special crafted (via hugo at build time) JSON file.
