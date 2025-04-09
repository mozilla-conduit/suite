#!/bin/sh

REPO_URL=https://github.com/mozilla-conduit/test-repo
REPO_PATH=/opt/git/test-repo.git

test -d "${REPO_PATH}" && exit 0

PARENT="$(dirname "${REPO_PATH}")"
mkdir -p "${PARENT}"
git clone --bare https://github.com/mozilla-conduit/test-repo "${REPO_PATH}"
echo "Test repo from ${REPO_URL}" > "${REPO_PATH}/description"
