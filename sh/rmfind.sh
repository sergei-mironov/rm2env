#!/bin/sh

. $(dirname $0)/rmcommon.sh

F=
CACHE=
while test -n "$1" ; do
  case "$1" in
    *)
    if test -z "$F" ; then
      F="$1"
    else
      CACHE="$F"
      F="$1"
    fi
    ;;
  esac
  shift
done

set -e -x

if ! test -f "$CACHE" ; then
  CACHE=/tmp/rmfind_$UID.txt
fi

test -f "$F"
rmcheck
rmls.sh >$CACHE

FN=$(basename "$F" .pdf)
grep --fixed-strings "$FN" "$CACHE" | awk '{print $1}'
