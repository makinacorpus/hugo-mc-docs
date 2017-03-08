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

# Pÿgment
ADD requirements.txt /s/requirements.txt
ADD bin/install_venv.sh /s/bin/install_venv.sh
RUN /s/bin/install_venv.sh

# Hugo
ADD bin/install_hugo.sh /s/bin/install_hugo.sh
RUN /s/bin/install_hugo.sh

# Nodejs
ADD bin/install_node.sh /s/bin/install_node.sh
RUN /s/bin/install_node.sh

# Theme
ADD config.yaml /s/config.yaml
ADD content /s/content
ADD i18n /s/i18n
ADD data /s/data
ADD layouts /s/layouts
ADD static /s/static
ADD themes /s/themes
ADD bin/control.sh /s/bin
