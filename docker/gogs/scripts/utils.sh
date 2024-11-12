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
  gosu "${USER}" ./gogs restore --tempdir "${RESTORE_TMPDIR}" --from ${BACKUP_FILE}

}
