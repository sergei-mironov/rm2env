#!/bin/sh

. $(dirname $0)/rmcommon.sh

DRYRUN=''
while test -n "$1" ; do
  case "$1" in
    --dry-run) DRYRUN='--dry-run' ;;
  esac
  shift
done

set -e -x

mkdir "$RM_XOCHITL" || true
rsync -i -avP $DRYRUN --delete -e "rmssh.sh" "$RM_SSH:/home/root/.local/share/remarkable/xochitl/" "${RM_XOCHITL}/"
