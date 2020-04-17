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
chown -R $APP_USER:$APP_USER config storage public/cpresources

$APP_DIR/scripts/wait-for-it.sh $DATABASE_HOST:$DATABASE_PORT

export DATABASE_TYPE=${DATABASE_TYPE:-mysql}
export DB_DSN=${DB_DSN:-"$DATABASE_TYPE:host=$DATABASE_HOST;port=$DATABASE_PORT;dbname=$DATABASE_NAME"}
export DB_USER=${DB_USER:-$DATABASE_USER}
export DB_PASSWORD=${DB_PASSWORD:-$DATABASE_PASS}
export ENVIRONMENT=${ENVIRONMENT:-$APP_ENV}
export SECURITY_KEY=${SECURITY_KEY:-$APP_KEY}

if [[ "$SECURITY_KEY" == "" ]];then
  warn "Missing env var: SECURITY_KEY"

  if [[ -f $APP_DIR/.key ]]; then
    log "Using saved key: $APP_DIR/.key ..."
    export SECURITY_KEY=$(cat $APP_DIR/.key)
  else
    log "Generating new key ..."
    export SECURITY_KEY=$(echo "$ENVIRONMENT-$(date)" | sha256sum | sed -r 's/[^a-z0-9]//g')
    log "Saving new key: $APP_DIR/.key ..."
    echo $SECURITY_KEY > $APP_DIR/.key
  fi
fi

exec "$@"