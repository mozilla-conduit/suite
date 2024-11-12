#!/bin/sh -eu

. "$(dirname "${0}")/utils.sh"

STAMP=/data/conduit-inited
# USER is set in the container's start.sh script

if [ -e ${STAMP} ]; then
  log "${STAMP} found, skipping initialisation"
  exit 0
fi

gogs_logs_setup

if [ -f "${BACKUP_FILE}" ]; then
  # Create a backup from a running container with
  #     docker compose exec git.test /scripts/gogs-backup.sh
  log "Found backup data at ${BACKUP_FILE}, restoring ..."

  gogs_restore

else
  log "No backup found at ${BACKUP_FILE}, performing bootstrap setup ..."
  log "Creating users ..."
  gosu "${USER}" /app/gogs/gogs admin create-user --name git-admin --password 'password123456789!' --email admin@git.test --admin
  gosu "${USER}" /app/gogs/gogs admin create-user --name conduit --password 'password123456789!' --email conduit@mozilla.bugs
  gosu "${USER}" /app/gogs/gogs admin create-user --name lando --password 'password123456789!' --email lando@mozilla.bugs

  log "You will have to manually add the SSH_PUBLIC_KEY for the lando user at http://git.test/user/settings/ssh"

  log "You will have to manually create the test test-repo-git git repo at http://git.test/user/settings/ssh"
fi

date > ${STAMP}
