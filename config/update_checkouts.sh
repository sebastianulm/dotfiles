#!/bin/bash -e

username="nmerritt"
password="bl1gHt3d4wn"
base="/home/nathan/tr"
branches=("src-MAINLINE" "src-PRERELEASE" "-data" "-genpages")

TRTOP=/home/nathan/trsrc-MAINLINE
export TRTOP

for i in "${branches[@]}"
do
  cd "${base}${i}"
  echo "svntr up --username $username --password $password"
  svntr up --username $username --password $password
done

## update locales next
$TRTOP/scripts/i18n-dump-to-bundles.csh

echo "update finished at `date`" >> /home/nathan/config/checkout_log
