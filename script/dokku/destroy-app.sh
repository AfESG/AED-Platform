#!/bin/bash

# Get input
input(){
  echo 1>&2 $1
  read input
  echo $input
}

echo "APPS:"
dokku apps:list
echo ""

echo "POSTGRES:"
dokku postgres:list
echo ""

echo "MEMCACHED:"
dokku memcached:list
echo ""

echo "STORAGE:"
ls --format=single-column /var/lib/dokku/data/storage
echo ""

echo "CRON:"
ls --format=single-column /etc/cron.d
echo ""

APPNAME=$( input "=> Enter the name of the application to destroy:" )
if [ -z ${APPNAME} ]; then exit; fi

DBNAME=`echo $APPNAME | sed -e "s/-/_/g"`
MEMCACHEDNAME="${APPNAME}-memcached"

dokku apps:destroy $APPNAME --force
dokku postgres:destroy $DBNAME --force
dokku memcached:destroy $MEMCACHEDNAME --force

# Clean up storage
STORAGE_DIR="/var/lib/dokku/data/storage/${APPNAME}"
if [ -d "${STORAGE_DIR}" ]; then
  echo "==> Removing ${STORAGE_DIR}"
  rm -rf "${STORAGE_DIR}"
fi

# Clean up CRON
rm /etc/cron.d/restart-${APPNAME}
rm /etc/cron.d/storage-backup-${APPNAME}
rm /etc/cron.d/dokku-postgres-${APPNAME}
