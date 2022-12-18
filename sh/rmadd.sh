#!/bin/sh

. $(dirname $0)/rmcommon.sh

set -e -x

CACHE=/tmp/rmfind_$UID.txt
LOG=/tmp/rmadd_$UID.txt
rmlist.sh "$RM_XOCHITL" >$CACHE

N=0
OK=0
echo >$LOG
for pdf in "$@" ; do
  if test -f "$pdf" ; then
    UUID=$(rmfind.sh "$CACHE" "$pdf")
    if test -z "$UUID" ; then
      if bash $(dirname $0)/rmadd1.sh "$pdf" ; then
        OK=$(expr $OK '+' 1)
      fi
    else
      echo "File '$pdf' already exists on RM2 as $UUID" | tee -a $LOG
    fi
  else
    echo "File '$pdf' does not exist" | tee -a $LOG
  fi
  N=$(expr $N '+' 1)
done

if test "$OK" = "$N" ; then
  rmpush.sh
else
  echo "$(expr $N - $OK) errors found. Run rmpush.sh explicitly" | tee -a $LOG
  rmwarn "$(cat $LOG)"
  exit 1
fi


