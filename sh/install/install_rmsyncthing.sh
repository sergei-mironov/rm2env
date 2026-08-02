#!/bin/sh

. rmcommon

while test -n "$1" ; do
  case "$1" in
    -D) RM_DEVICE=$2 ; shift ;;
    -h|--help)
      echo "rmsyncthing-install.sh [-D (A|B)]" >&2;
      exit 1
      ;;
  esac
  shift
done

set -e -x


rmssh $RM_SSH '
  wget -O - http://raw.githubusercontent.com/Evidlo/remarkable_entware/master/install.sh | sh;
  export PATH=/opt/bin:/opt/sbin:$PATH;
  opkg install syncthing
'

cat >_syncthing.service <<EOF
[Unit]
Description=syncthing

[Service]
Environment="HOME=/home/root"
ExecStart=/opt/bin/syncthing serve --no-browser --no-restart --gui-address "http://0.0.0.0:8888"
Restart=unless-stopped

[Install]
WantedBy=multi-user.target
EOF

rmscp ./_syncthing.service $RM_SSH:/etc/systemd/system/syncthing.service
rmssh $RM_SSH '
  systemctl daemon-reload &&
  systemctl enable syncthing &&
  systemctl restart syncthing
'

echo "Configuration page: https://10.11.99.1:8888"
