#!/bin/bash

# Exit script if any command fails
set -e

CONTAINER_NAME="wordpress-db"
DB_NAME=$MYSQL_DATABASE
DB_USER=$MYSQL_USER
DB_PASSWORD=$MYSQL_PASSWORD
S3_BUCKET="s3://wordpress-backup-ayomide-oluwole-2026"


# Generate timestamp for backup file
TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
BACKUP_FILE="backup-$TIMESTAMP.sql"

# Create backup using mysqldump
echo "Creating MySQL backup."

docker exec $CONTAINER_NAME \
  mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE

# Upload backup to S3
echo "Uploading backup to S3."

aws s3 cp $BACKUP_FILE $S3_BUCKET/

# Confirm success
echo "Backup successful!"
echo "File: $BACKUP_FILE"
echo "Uploaded to: $S3_BUCKET/$BACKUP_FILE"