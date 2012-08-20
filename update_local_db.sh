#!/bin/bash

# Best use case is to create a file "update_local_db.sh" in your project folder and then     
# call the command with bash update_local_db

# Follow me: @jackkinsella

function LastBackupName () { 
  heroku pgbackups | tail -n 1 | cut -d"|" -f 1
}

# This part assumes you have a low limit on no. of backups allowed
#old_backup=$(LastBackupName)
#heroku pgbackups:destroy $old_backup 

heroku pgbackups:capture 
new_backup=$(LastBackupName)
curl $(heroku pgbackups:url $new_backup) > temporary_backup.dump
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d joslink_development temporary_backup.dump 
rm -f temporary_backup.dump
