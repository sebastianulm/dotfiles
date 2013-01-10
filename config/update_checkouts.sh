#!/bin/bash -e

username="nmerritt"
password="bl1gHt3d4wn"
base="/home/nathan/tr"
branches=("src-MAINLINE" "src-PRERELEASE" "-data" "-genpages")
LOG="/home/nathan/config/checkout_log"

TRTOP=/home/nathan/trsrc-MAINLINE
export TRTOP

echo "update started at `date`" >> $LOG

for i in "${branches[@]}"
do
  checkout_dir=${base}${i}
  echo "svntr up $checkout_dir"
  svntr up $checkout_dir --script
  echo "  $checkout_dir update finished at `date`" >> $LOG
done

## update locales next
$TRTOP/scripts/i18n-dump-to-bundles.csh

echo "  translations update finished at `date`" >> $LOG

## TODO: FBRS
## echo "  FBRS rsync finished at `date`" >> $LOG
