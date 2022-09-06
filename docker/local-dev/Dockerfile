# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM python:3.10-buster

RUN apt-get update

RUN apt-get install -y \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        iputils-ping \
        vim

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# copy configuration
COPY arcrc .arcrc
COPY hgrc .hgrc
COPY gitconfig .gitconfig
COPY moz-phab-config .moz-phab-config
COPY initfile.sh ./
COPY clone_repositories.sh ./
COPY generate_revision.sh ./

RUN pip install --upgrade pip
RUN pip install setuptools --upgrade
RUN pip install wheel --upgrade
RUN pip install mots --upgrade

RUN pip install mercurial==6.1.1
RUN pip install requests
RUN pip install simplejson
RUN pip install hg-evolve
RUN pip install MozPhab

# Install git-cinnabar
RUN git clone https://github.com/glandium/git-cinnabar.git --branch release --single-branch /home/phab/git-cinnabar && cd /home/phab/git-cinnabar && make

RUN echo "[ui]" > ~/.hgrc
RUN echo "username = lando" >> ~/.hgrc

ENV PATH="${PATH}:/home/phab/git-cinnabar"
ENTRYPOINT /bin/bash /initfile.sh && /bin/bash
