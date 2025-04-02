#!/bin/sh -eux

cd /opt/git || exit 1

REPOS="first-repo second-repo third-repo test-repo"
CLONE_DIR=/opt/git/unified-cinnabar.git
CGIT_CACHE_DIR=/opt/cgit/cache

test -d "${CLONE_DIR}" && exit

git init --bare "${CLONE_DIR}"
echo "git-cinnabar clone of ${REPOS}" > "${CLONE_DIR}/description"

for r in $REPOS; do
  git --git-dir ${CLONE_DIR} remote add "${r}" "hg::http://hg.test/${r}"
  git --git-dir ${CLONE_DIR} fetch "${r}"
  git --git-dir ${CLONE_DIR} branch "${r}" "${r}/branches/default/tip"
  git --git-dir ${CLONE_DIR} branch -u "${r}/branches/default/tip" "${r}"
done

echo 'ref: refs/heads/first-repo' > ${CLONE_DIR}/HEAD

rm -rf ${CGIT_CACHE_DIR:?}/*
