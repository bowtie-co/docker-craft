#!/usr/bin/env bash

# set -e

# COLORS! :)
red='\033[0;31m'
cyan='\033[0;36m'
blue='\033[0;34m'
yellow='\033[0;33m'
nocolor='\033[0m'

error() {
  prefix="[ERROR] "
  echo
  echo -e "${red}${prefix}${1}${nocolor}"
  echo
}

warn() {
  prefix="[WARNING] "
  echo
  echo -e "${yellow}${prefix}${1}${nocolor}"
  echo
}

log() {
  prefix="[INFO] "
  echo
  echo -e "${cyan}${prefix}${1}${nocolor}"
  echo
}

log "Ensure required filesystem permissions ..."
chown -R $APP_USER:$APP_USER storage vendor web/cpresources

$APP_DIR/scripts/wait-for-it.sh $DATABASE_HOST:$DATABASE_PORT

export DB_DSN=${DB_DSN:-"mysql:host=$DATABASE_HOST;port=$DATABASE_PORT;dbname=$DATABASE_NAME"}
export DB_USER=${DB_USER:-$DATABASE_USER}
export DB_PASSWORD=${DB_PASSWORD:-$DATABASE_PASS}

# if [[ "$APP_ENV" == "local" ]]; then
#   table_dumps_dir=/var/www/database/dumps/tables

#   log "Running local env, setting up database ..."

#   mysql -h ${DATABASE_HOST} -u ${DATABASE_USER} -p${DATABASE_PASS} -e "set @@global.sql_mode = '';"

#   log "Creating database: ${DATABASE_NAME} ..."

#   mysql -h ${DATABASE_HOST} -u ${DATABASE_USER} -p${DATABASE_PASS} -e "create database ${DATABASE_NAME}"

#   if [[ "$?" != "0" ]]; then
#     error "Failed to create database: ${DATABASE_NAME}"
#   fi

#   for table in $table_dumps_dir/*; do
#     table_dump=$table/data.sql

#     if [ -f $table_dump ]; then
#       log "Importing data from table: $table ..."

#       mysql -h ${DATABASE_HOST} -u ${DATABASE_USER} -p${DATABASE_PASS} ${DATABASE_NAME} < $table_dump || error "Failed importing table: $table from dump: $table_dump"
#     else
#       warn "No data dump found for table: $table ($table_dump)"
#     fi
#   done

#   log "Finished importing data"
# fi

APP_ENV=${APP_ENV:-local}
INI_PATH=/usr/local/etc/php
INI_MAIN=$INI_PATH/php.ini
INI_ENV=$INI_PATH/php-$APP_ENV.ini

if [ -f $INI_ENV ]; then
  log "Using php.ini for APP_ENV=$APP_ENV ($INI_ENV)"
  cp $INI_ENV $INI_MAIN
fi

nginx -t

log "Saving environment variables for cronjobs: /root/env.sh"

# Filter current ENV variables to only expected keywords and save to file to be used for injecting ENV into cron jobs
# TODO: Better way to maintain a "whitelist" for desired ENV vars to include for cron jobs?
env | grep -E "AWS|APP|LOG|CORS|SHOPIFY|AIRBRAKE|DATABASE|REDIS|QUEUE|DRIVER|SESSION|INTERNAL|PERMITTING|MEMBERSHIP|USAC" | sed 's/^\(.*\)$/export \1/g' > /root/env.sh

exec "$@"