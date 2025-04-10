#!/bin/bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

if [ -n "${1}" ]; then
  cd /repos/"${1}"
fi
echo "hello world" > "$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1)"
if  git status --porcelain >/dev/null 2>&1; then
  git add .
  git commit -m "automatically generated commit"
else
  hg addremove
  hg commit -m "automatically generated commit"
fi
moz-phab -s --no-bug --no-wip
