USER=${USER:-git}
BACKUP=gogs-backup.zip
BACKUP_DIR=/data/
BACKUP_FILE=${BACKUP_DIR}${BACKUP}
RESTORE_TMPDIR=/data/backup-restore-tmp


export USER BACKUP BACKUP_DIR BACKUP_FILE RESTORE_TMPDIR

log()
{
  echo "${0}: ${*}" >&2
}

gogs_logs_setup()
{
  log "Creating log files with correct permissions ..."
  mkdir -p /app/gogs/log
  for LOG in xorm.log gorm.log; do
    touch /app/gogs/log/${LOG}
    chown ${USER} /app/gogs/log/${LOG}
  done
}

gogs_backup() 
{
  gosu "${USER}" ./gogs backup --target "${BACKUP_DIR}" --archive-name "${BACKUP}"

  echo
  echo "Backup complete in ${BACKUP_FILE}."
  echo "You can copy it out of the container with \`docker cp $(hostname):${BACKUP_FILE} docker/gogs\`"
  echo "It will be automatically restored when running the gogs-init container, if present"
  echo
}

gogs_restore()
{
  mkdir -p "${RESTORE_TMPDIR}"
  chown "${USER}" "${RESTORE_TMPDIR}"
  # Workaround [0]: restore DB, then manually extract repositories
  # [0] https://github.com/gogs/gogs/issues/7840
  gosu "${USER}" ./gogs restore --tempdir "${RESTORE_TMPDIR}" --from ${BACKUP_FILE} --database-only

  # shellcheck disable=SC2164
  cd "${RESTORE_TMPDIR}"
  unzip ${BACKUP_FILE} gogs-backup/repositories.zip

  # shellcheck disable=SC2164
  cd /data/git
  unzip "${RESTORE_TMPDIR}/gogs-backup/repositories.zip"
  chown -R "${USER}" .

  rm -rf "${RESTORE_TMPDIR}"
}
