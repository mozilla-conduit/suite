# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM debian:jessie-slim

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
        php5-common \
        php5-cli \
        php5-curl \
        php5-json \
        python \
        python-pip \
        python-dev \
        vim
RUN pip install \
        mercurial==$HG_RELEASE \
        simplejson

# add a non-privileged user
RUN addgroup --gid 1000 phab \
 && adduser --uid 1000 --ingroup phab --shell /bin/bash phab

WORKDIR /home/phab

COPY arcrc .arcrc
RUN chmod 600 .arcrc
COPY hgrc .hgrc
COPY gitconfig .gitconfig
RUN chown -R phab:phab /home/phab

USER phab

RUN hg clone https://hg.mozilla.org/hgcustom/version-control-tools -r $VCT_VERSION
COPY arcconfig version-control-tools/.arcconfig

# Install git cinnabar
# TODO Change the next line after `release` branch will show up.
RUN git clone https://github.com/glandium/git-cinnabar.git --branch master --single-branch
ENV PATH="${PATH}:/home/phab/git-cinnabar"
RUN git cinnabar download

RUN git clone hg::https://hg.mozilla.org/hgcustom/version-control-tools vct-cinnabar
COPY arcconfig vct-cinnabar/.arcconfig

# Install vanilla and modified Arcanist
RUN mkdir -p phabricator \
 && cd phabricator \
 && git clone https://github.com/phacility/libphutil.git \
 && git clone https://github.com/phacility/arcanist.git \
 && git clone https://github.com/mozilla-conduit/arcanist.git cinnabarc

RUN echo "export PATH=/home/phab/phabricator/arcanist/bin:/home/phab/git-cinnabar:\$PATH" >> .bash_profile \
 && echo "export EDITOR=vi" >> .bash_profile \
 && echo "alias cinnabarc=/home/phab/phabricator/cinnabarc/bin/arc" >> .bash_profile

CMD ["/bin/bash", "-l"]
