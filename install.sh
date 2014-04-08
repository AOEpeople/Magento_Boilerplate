#!/bin/bash

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

cd ${SOURCE_DIR} 

# Run composer
tools/composer.phar install || (echo "Composer failed"; exit 1)

# Run modman
tools/modman deploy-all --force || (echo "Modman failed"; exit 1)

# Run EnvSettingsTool
cd htdocs || (echo "Changing directory to 'htdocs/' failed"; exit 1)
../tools/apply.php devbox ../Configuration/settings.csv || (echo "EnvSettingsTool failed"; exit 1)

echo
echo "------------------------"
echo "Installation successful!"
echo "------------------------"
echo
