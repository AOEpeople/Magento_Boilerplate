#!/bin/bash

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

# Run composer
cd ${SOURCE_DIR} && tools/composer.phar install || (echo "Composer failed"; exit 1)

# Run modman
cd ${SOURCE_DIR} && tools/modman deploy-all --force || (echo "Modman failed"; exit 1)

# Importing systemstorage
MASTER_SYSTEM="demo"

## Database
# This requires the local.xml already to have all correct parameter. But this happens later in 'Run EnvSettingsTool'. That again requires the db to already be in place
# cd ${SOURCE_DIR}/htdocs && ../tools/n98-magerun.phar db:import --compression=gzip ../systemstorage/demo/database/combined_dump.sql.gz
# That's why we do it like this for now (and might introduce a way to set the local.xml stuff only via EnvSettings before doing this in the future)
DB_HOST=`${SOURCE_DIR}/tools/value.php ${ENVIRONMENT} ${SOURCE_DIR}/Configuration/settings.csv Est_Handler_XmlFile app/etc/local.xml /config/global/resources/default_setup/connection/host`
DB_DBNAME=`${SOURCE_DIR}/tools/value.php ${ENVIRONMENT} ${SOURCE_DIR}/Configuration/settings.csv Est_Handler_XmlFile app/etc/local.xml /config/global/resources/default_setup/connection/dbname`
DB_USERNAME=`${SOURCE_DIR}/tools/value.php ${ENVIRONMENT} ${SOURCE_DIR}/Configuration/settings.csv Est_Handler_XmlFile app/etc/local.xml /config/global/resources/default_setup/connection/username`
DB_PASSWORD=`${SOURCE_DIR}/tools/value.php ${ENVIRONMENT} ${SOURCE_DIR}/Configuration/settings.csv Est_Handler_XmlFile app/etc/local.xml /config/global/resources/default_setup/connection/password`
        
mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOST} -BNe "show tables" "${DB_DBNAME}" | tr '\n' ',' | sed -e 's/,$//' | awk '{print "SET FOREIGN_KEY_CHECKS = 0;DROP TABLE IF EXISTS " $1 ";SET FOREIGN_KEY_CHECKS = 1;"}' | mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOST} "${DB_DBNAME}"

gunzip < "${SOURCE_DIR}/systemstorage/${MASTER_SYSTEM}/database/combined_dump.sql.gz" | sed -e 's/\/\*[^*]*DEFINER=[^*]*\*\///' | mysql -u${DB_USERNAME} -p${DB_PASSWORD} -h${DB_HOST} ${DB_DBNAME} || exit 1


## Files
rsync --force --no-o --no-p --no-g --omit-dir-times --ignore-errors --archive --partial \
    --exclude=/catalog/product/cache/ --exclude=/tmp/ --exclude=.svn/ --exclude=*/.svn/ --exclude=.git/ --exclude=*/.git/ \
    "${SOURCE_DIR}/systemstorage/${MASTER_SYSTEM}/files/" "${SOURCE_DIR}/htdocs/media/"

# Run EnvSettingsTool
cd ${SOURCE_DIR}/htdocs && ../tools/apply.php devbox ../Configuration/settings.csv || (echo "EnvSettingsTool failed"; exit 1)

echo
echo "------------------------"
echo "Installation successful!"
echo "------------------------"
echo
