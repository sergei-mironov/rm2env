#!/bin/sh

. $(dirname $0)/rmcommon.sh

set -e -x

rmcheck
rmlist.sh "$RM_XOCHITL"
