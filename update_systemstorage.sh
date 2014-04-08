#!/bin/bash -e

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

ENVIRONMENT="demo"

PROJECT_WEBROOT="${SOURCE_DIR}/htdocs"

SYSTEMSTORAGE_LOCAL="${SOURCE_DIR}/systemstorage/${ENVIRONMENT}/"

# Create database dump
touch "${PROJECT_WEBROOT}/var/db_dump_in_progress.lock"
/usr/bin/php -d apc.enable_cli=0 ${SOURCE_DIR}/tools/n98-magerun.phar \
        --root-dir=${PROJECT_WEBROOT} \
        -q \
        db:dump \
        --compression=gzip \
        --strip="@stripped report_event log* report_compared_product_index report_viewed_product_index index_event index_process_event catalog_product_flat_* asynccache* enterprise_logging_event* core_cache core_cache_tag" \
        ${SYSTEMSTORAGE_LOCAL}database/combined_dump.sql
date +%s > ${SYSTEMSTORAGE_LOCAL}database/created.txt
rm "${PROJECT_WEBROOT}/var/db_dump_in_progress.lock"

# Backup files
rsync \
--no-o --no-p --no-g \
--force \
--omit-dir-times \
--ignore-errors \
--archive \
--partial \
--delete-after \
--delete-excluded \
--exclude=/catalog/product/cache/ \
--exclude=/catalog/product_*/ \
--exclude=/catalog/product/product/ \
--exclude=/export/ \
--exclude=/css/ \
--exclude=/js/ \
--exclude=/tmp/ \
--exclude=.svn/ \
--exclude=*/.svn/ \
--exclude=.git/ \
--exclude=*/.git/ \
"${PROJECT_WEBROOT}/media/" "${SYSTEMSTORAGE_LOCAL}files/"

date +%s > ${SYSTEMSTORAGE_LOCAL}files/created.txt

