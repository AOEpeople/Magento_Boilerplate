#!/bin/bash

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

# Run composer
cd ${SOURCE_DIR} && tools/composer.phar install || (echo "Composer failed"; exit 1)

# Run modman
cd ${SOURCE_DIR} && tools/modman deploy-all --force || (echo "Modman failed"; exit 1)

# Importing systemstorage
    MASTER_SYSTEM="devbox"

    # Run EnvSettingsTool (processing only rows tagged with 'db')
    cd ${SOURCE_DIR}/htdocs && ../tools/apply.php devbox ../Configuration/settings.csv --groups db || (echo "EnvSettingsTool failed"; exit 1)

    ## Database
    cd ${SOURCE_DIR}/htdocs && ../tools/n98-magerun.phar db:import --compression=gzip ../systemstorage/devbox/database/combined_dump.sql.gz

    ## Files
    rsync --force --no-o --no-p --no-g --omit-dir-times --ignore-errors --archive --partial \
        --exclude=/catalog/product/cache/ --exclude=/tmp/ --exclude=.svn/ --exclude=*/.svn/ --exclude=.git/ --exclude=*/.git/ \
        "${SOURCE_DIR}/systemstorage/${MASTER_SYSTEM}/files/" "${SOURCE_DIR}/htdocs/media/"

# Run EnvSettingsTool (processing all)
cd ${SOURCE_DIR}/htdocs && ../tools/apply.php devbox ../Configuration/settings.csv || (echo "EnvSettingsTool failed"; exit 1)

echo
echo "------------------------"
echo "Installation successful!"
echo "------------------------"
echo
