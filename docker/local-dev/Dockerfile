# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM debian:stable-slim

ENV HG_RELEASE=4.6 \
    VCT_VERSION=tip

# Build/install dependencies
RUN apt-get update \
 && apt-get install -y \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        php-common \
        php-cli \
        php-curl \
        php-json \
        python \
        python-pip \
        python-dev \
        vim
RUN pip install \
        mercurial==$HG_RELEASE \
        requests \
        simplejson \
        hg-evolve

# add a non-privileged user
RUN addgroup --gid 1000 phab \
 && adduser --uid 1000 --ingroup phab --shell /bin/bash phab

WORKDIR /home/phab

COPY arcrc .arcrc
RUN chmod 600 .arcrc
COPY hgrc .hgrc
COPY gitconfig .gitconfig

COPY clone_repositories.sh ./

RUN chown -R phab:phab /home/phab \
 && ln -fs /home/phab/phabricator/cinnabarc/bin/arc /usr/local/bin/cinnabarc

USER phab

# Install git cinnabar
# TODO Change the next line after `release` branch will show up.
ENV PATH="${PATH}:/home/phab/git-cinnabar"
RUN git clone https://github.com/glandium/git-cinnabar.git --branch release --single-branch \
 && git cinnabar download

# Install vanilla and modified Arcanist
RUN mkdir -p phabricator \
 && cd phabricator \
 && git clone https://github.com/phacility/libphutil.git \
 && git clone https://github.com/phacility/arcanist.git \
 && git clone https://github.com/mozilla-conduit/arcanist.git cinnabarc

# Install ARC Wrapper
RUN git clone https://github.com/mozilla-conduit/review.git \
 && chmod a+x review/moz-phab \
 && echo "export PATH=/home/phab/phabricator/arcanist/bin:/home/phab/git-cinnabar:/home/phab/review:\$PATH" >> .bash_profile \
 && echo "export EDITOR=vi" >> .bash_profile

CMD ["/bin/bash", "-l"]
