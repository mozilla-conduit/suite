#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

if [ -d "repos" ]
then
  rm -rf repos
fi

if [ -d "test-repo-cinnabar" ]
then
  rm -rf test-repo-cinnabar
fi

mkdir repos
cd repos
hg clone http://hg.test/first-repo
hg clone http://hg.test/second-repo
hg clone http://hg.test/third-repo
hg clone http://hg.test/test-repo

cd first-repo
echo -e "api-lefsv24henzsbzpw337bhizawuyh\n" | moz-phab install-certificate
cd ..

cd second-repo
echo -e "api-lefsv24henzsbzpw337bhizawuyh\n" | moz-phab install-certificate
cd ..

cd third-repo
echo -e "api-lefsv24henzsbzpw337bhizawuyh\n" | moz-phab install-certificate
cd ..

cd third-repo
echo -e "api-lefsv24henzsbzpw337bhizawuyh\n" | moz-phab install-certificate
cd ..

git clone hg::http://hg.test/first-repo test-repo-cinnabar
