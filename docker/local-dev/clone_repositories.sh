#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

if [ -d "test-repo" ]
then
  rm -rf test-repo
fi

if [ -d "test-repo-cinnabar" ]
then
  rm -rf test-repo-cinnabar
fi

hg clone http://hg.test/test-repo test-repo
git clone hg::http://hg.test/test-repo test-repo-cinnabar
