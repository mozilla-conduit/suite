# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

FROM alpine:3.3

ENV HG_RELEASE=4.1 \
    VCT_VERSION=tip

WORKDIR /root


# Install Mercurial
# Runtime dependencies
RUN apk --no-cache add python ca-certificates curl
# Build/install dependencies
RUN apk --no-cache add --virtual build-dependencies \
      build-base \
      python-dev \
      py-pip \
    && pip install --no-cache simplejson \
    && pip install --no-cache mercurial==$HG_RELEASE \
    && apk del build-dependencies

RUN hg clone https://hg.mozilla.org/hgcustom/version-control-tools -r $VCT_VERSION /root/version-control-tools

COPY hgrc /root/.hgrc

# Install Arcanist
# Runtime dependencies
RUN apk --no-cache add bash php-cli php-curl php-json
# Build/install dependencies
RUN apk --no-cache add --virtual arc-install-deps \
        git \
    && mkdir -p phabricator \
    && cd phabricator \
    && git clone https://github.com/phacility/libphutil.git \
    && git clone https://github.com/phacility/arcanist.git \
    && apk del arc-install-deps

COPY arcrc /root/.arcrc
RUN chmod 600 /root/.arcrc

ENV PATH=/root/phabricator/arcanist/bin:$PATH
ENV EDITOR=vi

CMD /bin/bash
