#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

GREEN='\033[0;32m'
NC='\033[0m'

set -e

if [ -d "/repos" ]
then
  rm -rf /repos
fi

mkdir /repos
cd /repos

hg clone http://hg.test/first-repo
hg clone http://hg.test/second-repo
hg clone http://hg.test/third-repo
hg clone http://hg.test/test-repo

git clone hg::http://hg.test/first-repo test-repo-cinnabar

git clone http://git.test/test-repo test-repo-git

for REPO in /repos/*; do
  pushd "${REPO}"
  echo -e "api-lefsv24henzsbzpw337bhizawuyh\n" | moz-phab install-certificate
  popd
done

echo
echo -e "${GREEN}Test repositories are available in /repos${NC}" >&2
echo -e "${GREEN}You can generate test revisions with /generate_revision.sh [REPO-NAME]${NC}" >&2
echo
