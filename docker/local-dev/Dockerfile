# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM debian:stable-slim

# Build/install dependencies

RUN apt-get clean \
 && apt-get update \
 && apt-get install -y apt-utils

RUN apt-get install -y locales \
 && sed --in-place '/en_US.UTF-8/s/^#//' /etc/locale.gen \
 && locale-gen en_US.UTF-8

ENV HG_RELEASE=4.6 \
    VCT_VERSION=tip \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    VIRTUAL_ENV=/opt/mozphab \
    HG_VIRTUAL_ENV=/opt/mercurial \
    EDITOR=vi

RUN apt-get install -y \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        httpie \
        iputils-ping \
        php-common \
        php-cli \
        php-curl \
        php-json \
        python \
        python-pip \
        python-dev \
        python3 \
        python3-pip \
        python3-dev \
        vim

RUN pip install virtualenv \
 && pip3 install virtualenv \
 && python3 -m virtualenv $VIRTUAL_ENV \
 && python -m virtualenv $HG_VIRTUAL_ENV

# Install Mercurial in virtualenv
ENV OLDPATH=$PATH \
    PATH=$HG_VIRTUAL_ENV/bin:$PATH
RUN pip install \
        mercurial==$HG_RELEASE \
        requests \
        simplejson \
        hg-evolve \
 && ln $HG_VIRTUAL_ENV/bin/hg /usr/bin/hg
ENV PATH=$OLDPATH

# Add a non-privileged user
RUN addgroup --gid 1000 phab \
 && adduser --uid 1000 --ingroup phab --shell /bin/bash phab

WORKDIR /home/phab

# Install Rust so Glean (required by MozPhab) can be installed
USER phab
RUN curl https://sh.rustup.rs -sSf > /tmp/rustup.sh
RUN chmod 755 /tmp/rustup.sh
RUN /tmp/rustup.sh -y
RUN rm /tmp/rustup.sh
ENV PATH="/home/phab/.cargo/bin:$PATH"
USER root

# copy configuration
COPY arcrc .arcrc
RUN chmod 600 .arcrc
COPY hgrc .hgrc
COPY gitconfig .gitconfig
COPY moz-phab-config .moz-phab-config
COPY initfile.sh .initfile.sh
COPY clone_repositories.sh ./
RUN chown -R phab:phab /home/phab \
 && ln -fs /home/phab/phabricator/cinnabarc/bin/arc /usr/local/bin/cinnabarc
USER phab

# Install git cinnabar
ENV PATH="${PATH}:/home/phab/git-cinnabar"

RUN git clone https://github.com/glandium/git-cinnabar.git --branch release --single-branch \
 && git cinnabar download

# Install vanilla and modified Arcanist
RUN mkdir -p phabricator \
 && cd phabricator \
 && git clone https://github.com/phacility/libphutil.git \
 && git clone https://github.com/phacility/arcanist.git \
 && git clone https://github.com/mozilla-conduit/arcanist.git cinnabarc

# Install moz-phab
RUN pip3 install MozPhab \
 && echo "export PATH=$VIRTUAL_ENV/bin:/home/phab/phabricator/arcanist/bin:/home/phab/git-cinnabar:/home/phab/review:/home/phab/.local/bin:\$PATH" >> .bashrc

CMD ["/bin/bash", "-c", "exec bash --init-file <(cat /etc/profile ~/.bashrc .initfile.sh)"]
