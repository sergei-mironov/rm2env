#!/bin/sh

. $(dirname $0)/rmcommon

set -e -x

if test -z "$RM_VPSSSH" ; then
  rmdie "RM_VPSSSH should be set and working"
fi
if test "$RM_VPSIP" = "$RM_NOIP"; then
  RM_VPSIP=$(ssh -G "$RM_VPSSSH" | awk '/^hostname / {print $2}')
  if test -z "$RM_VPSIP" ; then
    rmdie "Could not deduce RM_VPSIP from '$RM_VPSSSH'"
  fi
fi
if test "$RM_VPSUSER" = "$RM_NOUSER"; then
  RM_VPSUSER=$(ssh -G "$RM_VPSSSH" | awk '/^user / {print $2}')
  if test -z "$RM_VPSUSER" ; then
    RM_VPSUSER="$USER"
  fi
  rmwarn "Deduced RM_VPSUSER is '$RM_VPSUSER'"
fi
if test "$RM_VPSPORT" = "$RM_NOPORT"; then
  RM_VPSPORT=$(ssh -G "$RM_VPSSSH" | awk '/^port / {print $2}')
  if test -z "$RM_VPSPORT" ; then
    RM_VPSPORT=22
  fi
  rmwarn "Deduced RM_VPPORT is '$RM_VPSPORT'"
fi
if test "$RM_VPSRPORT" = "$RM_NOPORT"; then
  rmdie "RM_VPSRPORT is not set"
fi

ssh $RM_SSH mkdir .ssh || true
ssh $RM_SSH rm .ssh/id_dropbear || true
ssh $RM_SSH /usr/sbin/dropbearkey -t rsa -f .ssh/id_dropbear | grep ssh-rsa > _id_rsa-remarkable.pub

ssh $RM_VPSSSH mkdir .ssh || true
scp ./_id_rsa-remarkable.pub $RM_VPSSSH:.ssh/id_rsa-remarkable.pub
ssh $RM_VPSSSH 'cat .ssh/authorized_keys | grep -v root@remarkable > .ssh/authorized_keys.new'
ssh $RM_VPSSSH 'cat .ssh/id_rsa-remarkable.pub >> .ssh/authorized_keys.new'
ssh $RM_VPSSSH 'mv --backup=numbered .ssh/authorized_keys.new .ssh/authorized_keys'

cat >_sshR.service <<EOF
[Unit]
Description=Keep SSH reverse-proxy connection to a personal VPS
Conflicts=shutdown.target
After=systemd-udevd.service network-pre.target systemd-sysusers.service systemd-sysctl.service
Wants=network.target

[Service]
Environment="HOME=/home/root"
ExecStart=/usr/bin/ssh -y -y -K 3 -o "ExitOnForwardFailure=yes" -p$RM_VPSPORT -R$RM_VPSRPORT:127.0.0.1:22  $RM_VPSUSER@$RM_VPSIP -N
Restart=on-failure
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

scp ./_sshR.service $RM_SSH:/etc/systemd/system/sshR.service
ssh $RM_SSH 'systemctl daemon-reload && systemctl start sshR.service'

# scp ./remarkabot root@"$1":/opt/remarkabot/remarkabot
# scp ./scripts/run root@"$1":/opt/remarkabot/run
# scp ./systemd/remarkabot.service root@"$1":/etc/systemd/system/remarkabot.service
# scp ./systemd/remarkabot.timer root@"$1":/etc/systemd/system/remarkabot.timer
# scp ./systemd/.env root@"$1":/home/root/.config/remarkabot/.env
# ssh root@"$1" 'systemctl daemon-reload && systemctl enable --now remarkabot.timer'

