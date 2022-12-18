#!/bin/sh

. $(dirname $0)/rmcommon.sh

dr() {
  if test -z "$DRYRUN" ; then
    "$@"
  else
    echo "$@"
  fi
}

DRYRUN=''
while test -n "$1" ; do
  case "$1" in
    --dry-run) DRYRUN='--dry-run' ;;
  esac
  shift
done

set -e -x

rmcheck

while ! rmssh.sh -o "ConnectTimeout=3" "$RM_SSH" /bin/true ; do
  rmecho -n .
  sleep 1
done

rsync -i -avP $DRYRUN -e "rmssh.sh" "$RM_SSH:/home/root/.local/share/remarkable/xochitl/" "${RM_XOCHITL}/"
rsync -i -avP $DRYRUN --no-owner --no-group -e "rmssh.sh" "${RM_XOCHITL}/" "$RM_SSH:/home/root/.local/share/remarkable/xochitl/"
dr rmssh.sh "$RM_SSH" systemctl restart xochitl
