FROM ubuntu
RUN bash -c "\
    apt-get update -qq &&\
    apt-get install -y sqlite3 liblcms2-2 liblcms2-dev libcairomm-1.0-dev \
        libcairo2-dev libsqlite3-dev apache2-utils autoconf automake build-essential \
        bzip2 gettext git groff libbz2-dev libcurl4-openssl-dev libdb-dev libgdbm-dev \
        libreadline-dev libfreetype6-dev libsigc++-2.0-dev libsqlite0-dev \
        libsqlite3-dev libtiff5 libtiff5-dev libwebp5 libwebp-dev \
        libssl-dev libtool libxml2-dev libxslt1-dev libopenjpeg-dev m4 \
        man-db pkg-config poppler-utils python-dev python-imaging python-setuptools \
        tcl8.4 tcl8.4-dev tcl8.5 tcl8.5-dev tk8.5-dev cython python-numpy zlib1g-dev" &&\
    bash -c "apt-get install -y virtualenv || apt-get install -y python-virtualenv"
ENV HUGO_THEME hugo-mc-docs
ENV W /s
ENV HUGO_THEME_DIR themes/hugo-mc-docs
ADD ${HUGO_THEME_DIR}/requirements.txt ${W}/${HUGO_THEME_DIR}/requirements.txt
ADD \
    ${HUGO_THEME_DIR}/bin/install_venv.sh \
    ${HUGO_THEME_DIR}/bin/install_node.sh \
    ${HUGO_THEME_DIR}/bin/install_hugo.sh \
    ${HUGO_THEME_DIR}/bin/install.sh \
    ${W}/${HUGO_THEME_DIR}/bin/
RUN ${W}/${HUGO_THEME_DIR}/bin/install.sh
# All later adds will not trigger a reinstall accelerating docker builds
ADD config.yaml                      ${W}/config.yaml
ADD content                          ${W}/content
ADD i18n                             ${W}/i18n
ADD data                             ${W}/data
ADD layouts                          ${W}/layouts
ADD static                           ${W}/static
ADD themes                           ${W}/themes
ADD ${HUGO_THEME_DIR}/bin/control.sh ${W}/${HUGO_THEME_DIR}/bin
RUN ${W}/${HUGO_THEME_DIR}/bin/control.sh infest
