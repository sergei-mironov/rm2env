
rmset() {
  if eval "test -z \"\$$1\"" ; then
    eval "$1='$2'"
  fi
}

RM_NOUSER="<INVALID_USER>"
RM_NOIP="<INVALID_IP>"

rmset RM_SSH remarkable
rmset RM_XOCHITL $HOME/.xochitl
rmset RM_VPSIP "$RM_NOIP"
rmset RM_VPSUSER "$RM_NOUSER"
rmset RM_VPSPORT 2222
rmset RM_VPSRPORT 4349
rmset RM_VPSSSH vps

rmecho() {
  echo "$@"
}
rmwarn() {
  echo "$@"
}

rmdie() {
  echo "$@" >&2
  exit 1
}

rmcheck() {
  if test -d "$RME_XOCHITL" ; then
    rmdie "RM_XOCHITL($RM_XOCHITL) is not a dir"
  fi
}
