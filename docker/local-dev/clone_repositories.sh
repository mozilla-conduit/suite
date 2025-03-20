#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

GREEN='\033[0;32m'
BLUE='\033[0;34m'
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

git clone http://git.test/unified-cinnabar \
  || echo -e "${BLUE}no unified-cinnabar repo present; this is expected if the git_hg_sync logic is not running${NC}" >&2

for REPO in /repos/*; do
  pushd "${REPO}"
  echo "api-lefsv24henzsbzpw337bhizawuyh" | moz-phab install-certificate
  popd
done

echo
echo -e "${GREEN}Test repositories are available in /repos${NC}" >&2
echo -e "${GREEN}You can generate test revisions with /generate_revision.sh [REPO-NAME]${NC}" >&2
echo
