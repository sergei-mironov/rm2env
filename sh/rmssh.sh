#!/bin/sh

. $(dirname $0)/rmcommon.sh

exec ssh -o "ProxyCommand ssh $RM_VPSSSH nc -w 5 127.0.0.1 $RM_VPSRPORT" "$@"