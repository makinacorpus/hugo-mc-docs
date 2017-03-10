---
title: Installation de la documentation
tags: [contribute, tutorial]
menu:
  main:
    parent: contribute
---

Installer & tester des modifications sur la documentation
=========================================================

- Cette doc est basée sur le système [hugo](https://gohugo.io/),
  il est très simple de l'installer.
- Le format pour écrire les documents est le [Markdown](https://guides.github.com/features/mastering-markdown)
- [Pointeur vers la doc de hugo](https://gohugo.io/content/example/)
- Je me suis inspiré de [MkDocs/material](https://github.com/squidfunk/mkdocs-material) & [rdwatters/hugo-docs-concept](https://github.com/rdwatters/hugo-docs-concept)

Editer en ligne (non developpeur)
---------------------------------

Pour des modifications plus ou moins simple, surtout si vous n'êtes pas
développeurs, vous pouvez éditer la documentation directement depuis
gitlab:

- Aller sur [gitlab/tation](https://gitlab.foo.net/docu/tation/tree/master/source)
  ou cliquer sur le stylo en haut à gauche de la page que vous souhaitez éditer.
- Choisir le fichier à éditer
- L'éditer
- **ATTENTION** En bas, dans "target branch", choisir un petit nom,
  et bien vérifier que la case "start merge..." soit cochée
- Valider la merge request (le bouton vert, en bas)
- Cela démarre le processus de validation et bientôt votre modif
  sera en ligne

Editer sur sa machine
---------------------

La procédure de build est la suivate:
- build des static css/js avec gulp
- build hugo

### Installation sans docker

#### Prerequis

```sh
sudo apt-get install -y sqlite3 liblcms2-2 liblcms2-dev libcairomm-1.0-dev \
    libcairo2-dev libsqlite3-dev apache2-utils autoconf automake build-essential \
    bzip2 gettext git groff libbz2-dev libcurl4-openssl-dev libdb-dev libgdbm-dev \
    libreadline-dev libfreetype6-dev libsigc++-2.0-dev libsqlite0-dev \
    libsqlite3-dev libtiff5 libtiff5-dev libwebp5 libwebp-dev libyaml-dev\
    libssl-dev libtool libxml2-dev libxslt1-dev libopenjpeg-dev m4 \
    man-db pkg-config poppler-utils python-dev python-imaging python-setuptools \
    tcl8.4 tcl8.4-dev tcl8.5 tcl8.5-dev tk8.5-dev cython python-numpy zlib1g-dev
```

#### Installation

``` sh
git clone https://gitlab.foo.net/docu/tation
cd tation
themes/hugo-mc-docs/bin/control.sh intall
```

### Installation avec docker

- L'install à proprement parler, fait partie du build, après le
  téléchargement passez à l'étape suivante.

    ```sh
    git clone --recursive https://gitlab.makina-corpus.net/docu/tation
    cd tation
    themes/hugo-mc-docs/bin/docker.sh
    ```

### Reconstuire la documentation
#### Sans docker
- Après installation, pour construire la documentation

    ```sh
    bin/control.sh serve
    ```

#### Avec docker

- Construire la documentation

    ```sh
    bin/docker.sh serve
    ```

### Tester & envoyer ses modications
- Editer la construction & la reconstuire
- Regarder [http://localhost:1313](http://localhost:1313)
- Une fois toutes les modifications faites, vous pouvez soumettre, au
  travers de gitlab, une merge request:

     ```sh
     git add
     git commit -am "ma modif"
     git push origin HEAD:feature-mydocmodif
     ```

- Se connecter sur gitlab, et demander une merge request.
- Une fois la merge request acceptée, votre modif apparaitra
  rapidement sur [cette doc](/)

