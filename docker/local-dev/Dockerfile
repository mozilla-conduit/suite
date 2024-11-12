# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM python:3.10-buster

RUN apt-get update \
 && apt-get install -y \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        iputils-ping \
        less \
        vim \
        && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip \
 setuptools \
 wheel \
 mots \
 mercurial \
 requests \
 simplejson \
 hg-evolve \
 MozPhab

# Install git-cinnabar
ENV PATH="/root/.cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y  \
  && git clone --branch release --single-branch \
  https://github.com/glandium/git-cinnabar.git /home/phab/git-cinnabar \
  && cd /home/phab/git-cinnabar \
  && make
ENV PATH="${PATH}:/home/phab/git-cinnabar"

# copy configuration
COPY arcrc .arcrc
COPY hgrc .hgrc
COPY gitconfig .gitconfig
COPY moz-phab-config .moz-phab-config
COPY initfile.sh ./
COPY clone_repositories.sh ./
COPY generate_revision.sh ./

RUN echo "[ui]\nusername = Lando <lando@mozilla.bugs" >> ~/.hgrc

ENTRYPOINT /bin/bash /initfile.sh && /bin/bash
