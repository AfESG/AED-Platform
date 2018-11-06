#!/bin/bash

# 2018-10-18
# This script will walk you through creating a new application on the Dokku server.

# Get input
input(){
  echo 1>&2 $1
  read input
  echo $input
}

DOKKU_HOME=/home/dokku
DOKKU_VHOSTNAME=`cat ${DOKKU_HOME}/VHOST`


###################################################################################################
# Install Dependencies
###################################################################################################

if [[ ! $(which aws) ]]; then
  echo ""
  echo "==> Installing: awscli"
  apt install -y awscli
fi

clear

###################################################################################################
# Application
###################################################################################################
echo ""
echo "APPLICATION"
echo ""

APPNAME=$( input "=> Enter a name for the new application (e.g., production, staging):" )

echo ""
echo "==> Creating application: ${APPNAME}"
dokku apps:create "${APPNAME}"

# Set the app's directory so it can be used elsewhere in the script.
APP_DIR="${DOKKU_HOME}/${APPNAME}"

DEFAULT_FULL_DOMAIN="${APPNAME}.${DOKKU_VHOSTNAME}"
echo ""
Q=$( input "=> Will this application respond to URLs other than: ${DEFAULT_FULL_DOMAIN} [y/n]:" )
while [ "${Q}" = "y" ]
do

  echo ""
  ALT_URL=$( input "=> Enter alternate domain:" )
  if [ -n ${ALT_URL} ]; then
    echo ""
    echo "==> Adding domain: ${ALT_URL} to application: ${APPNAME}"
    dokku domains:add "${APPNAME}" "${ALT_URL}"
  fi

  echo ""
  Q=$( input "=> Add another domain? [y/n]:" )

done

# Add the default full domain if it's not already set.
if [[ ! $(dokku domains:report ${APPNAME} | grep ${DEFAULT_FULL_DOMAIN}) ]]; then
  echo ""
  dokku domains:add "${APPNAME}" "${DEFAULT_FULL_DOMAIN}"
fi

###################################################################################################
# Environment Variables
###################################################################################################
echo ""
echo "ENVIRONMENT VARIABLES"
echo ""

DOMAIN=$( input "=> Enter the full domain of the application (default: ${DEFAULT_FULL_DOMAIN}):" )
if [ -z $DOMAIN ]; then DOMAIN=${DEFAULT_FULL_DOMAIN}; fi

AWS_ACCESS_KEY_ID=$( input "=> Enter your AWS_ACCESS_KEY_ID:" )
AWS_SECRET_ACCESS_KEY=$( input "=> Enter your AWS_SECRET_ACCESS_KEY:" )
AWS_DEFAULT_REGION=$( input "=> Enter your AWS_DEFAULT_REGION (default: eu-central-1):" )
if [ -z $AWS_DEFAULT_REGION ]; then AWS_DEFAULT_REGION="eu-central-1"; fi

REQUEST_FORM_SUBMITTED_TO_EMAIL=$( input "=> Enter your REQUEST_FORM_SUBMITTED_TO_EMAIL:" )
REQUEST_FORM_SUBMITTED_BCC_EMAIL=$( input "=> Enter your REQUEST_FORM_SUBMITTED_BCC_EMAIL:" )
REQUEST_FORM_THANKS_BCC_EMAIL=$( input "=> Enter your REQUEST_FORM_THANKS_BCC_EMAIL:" )
GOOGLE_ANALYTICS_TRACKING_ID=$( input "=> Enter your GOOGLE_ANALYTICS_TRACKING_ID:" )

echo ""
dokku config:set "${APPNAME}" DOMAIN="${DOMAIN}" AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" REQUEST_FORM_SUBMITTED_TO_EMAIL="${REQUEST_FORM_SUBMITTED_TO_EMAIL}" REQUEST_FORM_SUBMITTED_BCC_EMAIL="${REQUEST_FORM_SUBMITTED_BCC_EMAIL}" REQUEST_FORM_THANKS_BCC_EMAIL="${REQUEST_FORM_THANKS_BCC_EMAIL}" GOOGLE_ANALYTICS_TRACKING_ID="${GOOGLE_ANALYTICS_TRACKING_ID}"

###################################################################################################
# Database
###################################################################################################
echo ""
echo "DATABASE"
echo ""

if [ ! -d "/var/lib/dokku/plugins/available/postgres" ]; then
  echo "==> Installing PostgreSQL plugin"
  dokku plugin:install https://github.com/dokku/dokku-postgres.git
fi

DBNAME=`echo "${APPNAME}" | sed -e "s/-/_/g"`

export POSTGRES_IMAGE="mdillon/postgis"
export POSTGRES_IMAGE_VERSION="9.6"

echo ""
echo "==> Creating Database: ${DBNAME}"
dokku postgres:create "${DBNAME}"

echo ""
echo "==> Linking Database to Application"
dokku postgres:link "${DBNAME}" "${APPNAME}"

# Import a database backup
echo ""
DBBACKUP_DEFAULT=$( ls | grep .dump | head -n 1 )
if [ -z ${DBBACKUP_DEFAULT} ]; then DBBACKUP_DEFAULT="aed.dump"; fi

DBBACKUP=$( input "=> Enter the full path of the database backup file (default: ${DBBACKUP_DEFAULT}):" )
if [ -z ${DBBACKUP} ]; then DBBACKUP=${DBBACKUP_DEFAULT}; fi

if [ -n "${DBBACKUP}" ]; then
  echo ""
  echo "==> Importing Database Backup"

  if [[ $(file "${DBBACKUP}" | grep "PostgreSQL") ]]; then
    dokku postgres:import "${DBNAME}" < "${DBBACKUP}"
  else
    dokku postgres:connect "${DBNAME}" < "${DBBACKUP}"
  fi

fi

###################################################################################################
# Import Local Data
###################################################################################################
echo ""
echo "IMPORT DATA"
echo ""

STORAGE_DIR="/var/lib/dokku/data/storage/${APPNAME}"
VOLUMES_DIR="${STORAGE_DIR}/volumes"

PUBLIC_SYSTEMS_DIR="${VOLUMES_DIR}/public/system"
echo ""
echo "==> Creating public/systems directory: ${PUBLIC_SYSTEMS_DIR}"
mkdir -p "${PUBLIC_SYSTEMS_DIR}"

echo ""
echo "==> Linking application to public/systems directory"
dokku storage:mount "${APPNAME}" ${PUBLIC_SYSTEMS_DIR}:/app/public/system

# Import the population_submission_attachments data
echo ""
POP_SUB_ATT_DIR=$( input "=> Enter the full path to the extracted 'population_submission_attachments' directory (default: population_submission_attachments):" )
if [ -z ${POP_SUB_ATT_DIR} ]; then POP_SUB_ATT_DIR="population_submission_attachments"; fi

if [ -n ${POP_SUB_ATT_DIR} ]; then
  echo ""
  echo "==> Copying ${POP_SUB_ATT_DIR} to ${PUBLIC_SYSTEMS_DIR}"
  cp -r "${POP_SUB_ATT_DIR}" "${PUBLIC_SYSTEMS_DIR}/"
fi


PUBLIC_UPLOADS_SHEETS_DIR="${VOLUMES_DIR}/public/uploads/spreadsheets"
echo ""
echo "==> Creating public/uploads/spreadsheets directory: ${PUBLIC_UPLOADS_SHEETS_DIR}"
mkdir -p "${PUBLIC_UPLOADS_SHEETS_DIR}"

echo ""
echo "==> Linking application to public/uploads/spreadsheets"
dokku storage:mount "${APPNAME}" ${PUBLIC_UPLOADS_SHEETS_DIR}:/app/public/uploads/spreadsheets


# This is the buildpack user
# http://dokku.viewdocs.io/dokku~v0.12.13/advanced-usage/persistent-storage/#usage
chown -R 32767:32767 "${VOLUMES_DIR}"

###################################################################################################
# Memcached
###################################################################################################
echo ""
echo "MEMCACHED"
echo ""

if [ ! -d "/var/lib/dokku/plugins/available/memcached" ]; then
  echo "==> Installing Memcached plugin"
  dokku plugin:install https://github.com/dokku/dokku-memcached.git memcached
fi

echo ""
echo "==> Creating Memcached service"
MEMCACHEDNAME="${APPNAME}-memcached"
dokku memcached:create "${MEMCACHEDNAME}"

echo ""
echo "==> Linking Memcached service to application"
dokku memcached:link "${MEMCACHEDNAME}" "${APPNAME}"

###################################################################################################
# Dokku, nginx Configuration
###################################################################################################
echo ""
echo "ADDITIONAL CONFIGURATION"
echo ""

# Kill "run" containers after you exit them.
echo "==> Setting DOKKU_RM_CONTAINER=1"
dokku config:set --global DOKKU_RM_CONTAINER=1

# Restart all apps every day at midnight.
RESTART_CRON_FILE="/etc/cron.d/restart-${APPNAME}"
echo ""
echo "==> Scheduling automatic restart in CRON: ${RESTART_CRON_FILE}"
echo "0 0 * * * dokku /usr/bin/dokku ps:restart ${APPNAME}" > "${RESTART_CRON_FILE}"

# Only load applications via URL if they actually exist.
DEFAULT_VHOST_FILE="/etc/nginx/conf.d/00-default-vhost.conf"

if [ ! -f ${DEFAULT_VHOST_FILE} ]; then
  echo ""
  echo "==> Writing custom nginx configuration: ${DEFAULT_VHOST_FILE}"

  cat > "${DEFAULT_VHOST_FILE}" <<EOT
# By default, Dokku will route any received request with an unknown HOST header value to the lexicographically
# first site in the nginx config stack.
# The below configuration will cause nginx to return a 444 code if the specific URL/application doesn't exist.
# http://dokku.viewdocs.io/dokku~v0.12.13/configuration/domains/#default-site

server {
    listen 80 default_server;
    server_name _;
    access_log off;
    return 444;
}

# To handle HTTPS requests, you can uncomment the following section.
#
# Please note that in order to let this work as expected, you need a valid
# SSL certificate for any domains being served. Browsers will show SSL
# errors in all other cases.
#
# Note that the key and certificate files in the below example need to
# be copied into /etc/nginx/ssl/ folder.
#
# server {
#     listen 443 ssl;
#     server_name _;
#     ssl_certificate /etc/nginx/ssl/cert.crt;
#     ssl_certificate_key /etc/nginx/ssl/cert.key;
#     access_log off;
#     return 444;
# }
EOT

  echo ""
  echo "==> Restarting nginx"
  service nginx reload
fi

###################################################################################################
# Backups
###################################################################################################
echo ""
echo "BACKUPS"
echo ""

# The name of the S3 bucket this app will backup to.
BACKUPS_BUCKET_NAME="aed-server-backups/${APPNAME}"

# CRON_SCHEDULE is a crontab expression, eg. "0 3 * * *" for each day at 3am
CRON_SCHEDULE="0 3 * * *"

echo ""
Q=$( input "=> Do you want to setup automatic application data backups? [y/n]:" )
if [ "${Q}" == "y" ]; then
  echo ""
  echo "==> Configuring application data backups."

  BACKUPS_DIR=${APP_DIR}/backups
  mkdir -p ${BACKUPS_DIR}

  # Create the backup script
  BACKUP_SCRIPT=${APP_DIR}/storage_backup.sh

  echo ""
  echo "==> Writing backup script: ${BACKUP_SCRIPT}"

  cat > ${BACKUP_SCRIPT} <<EOT
. "${APP_DIR}/ENV"
export AWS_ACCESS_KEY_ID="\${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="\${AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="\${AWS_DEFAULT_REGION}"

TIMESTAMP=\$(date +"%F-%H-%M-%S")
BACKUP_TAR_FILE="${BACKUPS_DIR}/storage-backup-${APPNAME}-\${TIMESTAMP}.tgz"

tar czf "\${BACKUP_TAR_FILE}" "${STORAGE_DIR}"

aws s3 sync "${BACKUPS_DIR}" "s3://${BACKUPS_BUCKET_NAME}" --exclude "*" --include "storage-backup-*.tgz"
if [ \$? -eq 0 ]; then
  echo "S3 Sync was Successful. Removing local backup files."
  rm ${BACKUPS_DIR}/storage-backup-*.tgz
else
  echo "S3 Sync failed."
fi

EOT
  chmod +x ${BACKUP_SCRIPT}

  # Schedule the backups in CRON
  BACKUP_CRON_FILE="/etc/cron.d/storage-backup-${APPNAME}"
  echo ""
  echo "==> Scheduling backup in CRON: ${BACKUP_CRON_FILE}"
  echo "${CRON_SCHEDULE} root ${BACKUP_SCRIPT}" > "${BACKUP_CRON_FILE}"

  # Test the backup
  echo ""
  Q=$( input "=> Do you want to test the backup script? [y/n]:" )
  if [ "${Q}" == "y" ]; then
    echo ""
    echo "==> Performing backup to validate configuration..."
    ${BACKUP_SCRIPT}
  fi
fi

echo ""
Q=$( input "=> Do you want to setup automatic database backups? [y/n]:" )
if [ "${Q}" == "y" ]; then
  echo ""
  echo "==> Setting automatic database backup.."
  dokku postgres:backup-auth ${APPNAME} "${AWS_ACCESS_KEY_ID}" "${AWS_SECRET_ACCESS_KEY}"

  echo ""
  dokku postgres:backup-schedule ${APPNAME} "${CRON_SCHEDULE}" "${BACKUPS_BUCKET_NAME}"

  # Show to cron schedule.
  echo ""
  dokku postgres:backup-schedule-cat ${APPNAME}

  # Test the backup
  echo ""
  Q=$( input "=> Do you want to test the backup process? [y/n]:" )
  if [ "${Q}" == "y" ]; then
    echo ""
    echo "==> Performing backup to validate configuration..."
    dokku postgres:backup ${APPNAME} "${BACKUPS_BUCKET_NAME}"
  fi

fi

###################################################################################################
# Additional Configuration
###################################################################################################

# Make sure everything is owned by the dokku user.
chown -R dokku:dokku "${APP_DIR}"

###################################################################################################
# Additional Information
###################################################################################################
echo ""
echo "ADDITIONAL INFORMATION"
echo ""

echo "==> Git Remote Command: git remote add ${APPNAME} dokku@${DOKKU_VHOSTNAME}:${APPNAME}"

echo ""
echo "==> Done"