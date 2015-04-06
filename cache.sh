#!/bin/sh

#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

ROOT_DIR="$(dirname $(readlink -fn $0))"
CACHE_DIR="${ROOT_DIR}/cache"

# SQL Server 2008 R2 SP2 - Express Edition
#
# http://www.microsoft.com/en-gb/download/details.aspx?id=30438
SQL_SERVER_2008_R2_ADV_64=http://download.microsoft.com/download/0/4/B/04BE03CD-EAF3-4797-9D8D-2E08E316C998/SQLEXPRADV_x64_ENU.exe

if [ ! -f "${CACHE_DIR}/SQLEXPRADV_x64_ENU.exe" ]; then
    curl --output "${CACHE_DIR}/SQLEXPRADV_x64_ENU.exe" "$SQL_SERVER_2008_R2_ADV_64"
fi
