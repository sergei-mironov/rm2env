ReMarkable 2 environment
========================

This ia a [Nix-shell](http://www.nixos.org) environment which contains Nix build
rules for various software, related to the [Remarkable2 tablet
device](https://remarkable.com/store/remarkable-2).

Contents
--------

1. [Contents](#contents)
2. [Usage](#usage)
   * [Entering the Environment](#entering-the-environment)
   * [Linking the pointer with the Host mouse](#linking-the-pointer-with-the-host-mouse)
   * [Synchronizin using RMfuse (Broken)](#synchronizin-using-rmfuse-(broken))
3. [Low-level actions](#low-level-actions)
   * [Enabling the support of older SSH key formats](#enabling-the-support-of-older-ssh-key-formats)
   * [Setting the Host IP to connect via USB cable](#setting-the-host-ip-to-connect-via-usb-cable)
   * [Calling resync (deprecated)](#calling-resync-(deprecated))
   * [Syncing the xochitl](#syncing-the-xochitl)
4. [Resources](#resources)
   * [General](#general)
   * [Synchronization](#synchronization)
   * [Screen sharing](#screen-sharing)
   * [Other projects](#other-projects)

Usage
-----

### Entering the Environment

```sh
$ nix-shell -A shell
```

### Linking the pointer with the Host mouse

Connect the device to Host and do the following

```sh
$ echo 'password' >_pass.txt
$ ./runmouse.sh
```

Issues:

* ~~https://github.com/Evidlo/remarkable_mouse/issues/63~~
  + Specifying --password seems to have no effect (Fixed)

### Synchronizin using RMfuse (Broken)

Broken due to

* ~~https://github.com/rschroll/rmcl/issues/1~~
* https://github.com/rschroll/rmfuse/issues/42
* etc.

Used to work as follows:

```sh
$ nix-build -A rmfuse
$ mkdir _remarkable
$ ./result/bin/rmfuse -v _remarkable
```


Low-level actions
-----------------


### Enabling the support of older SSH key formats

In the Host Nix config:

```nix
programs.ssh = let
  algos = ["rsa-sha2-256" "rsa-sha2-512" "ssh-ed25519" "ssh-rsa" "ssh-dss"];
in {
  hostKeyAlgorithms = algos;
  pubkeyAcceptedKeyTypes = algos;
};
```

### Setting the Host IP to connect via USB cable

```sh
$ sudo ifconfig enp3s0u1 10.11.99.2 netmask 255.255.255.0
```

.. or set up NetworkManager to automatically assign IP address


### Calling resync (deprecated)

```sh
$ resync.py -r remarkable -v  backup  -o _rm2sync
```


### Syncing the xochitl

```sh
rsync -avP -e ssh remarkable:/home/root/.local/share/remarkable/xochitl _xochitl
```

Resources
---------

### General

* RemarkableWiki https://remarkablewiki.com/tips/start
  - SSH key issues https://remarkablewiki.com/tech/ssh on modern hardware
* reHackable https://github.com/reHackable/awesome-reMarkable
* Reddit
  - https://www.reddit.com/r/RemarkableTablet/comments/ickcu5/we_need_split_screen_for_the_rm2/
* reMarkable directory structure
  - https://remarkablewiki.com/tech/filesystem

### Synchronization

- Remarkable CLI tooling https://github.com/cherti/remarkable-cli-tooling
  + Could be up-to-date; More or less works
  + Can't remove file from remarkable
  + Sent Pull request and filed an issue
    * https://github.com/cherti/remarkable-cli-tooling/issues/5
- Prof. Fraga's page on remarkable with lots of useful scripts
  https://www.ucl.ac.uk/~ucecesf/remarkable/
  + [rm2pdf.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/pdf2rm.sh)
  + [rmlist.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/rmlist.sh)
  + [rmconvert.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/rmconvert.sh)
  + Author e-mail `e.fraga@ucl.ac.uk`
- https://github.com/simonschllng/rm-sync
  + Written in pure Shell curl calls are commented-out
  + Seems to be a local script, incomplete
- https://github.com/lschwetlick/rMsync
  + Another script, this time in Python
  + Needs `rm_tools`
  + Needs deprecated scripts
- https://github.com/nick8325/remarkable-fs
  + FUSE, Seems to work without the cloud
  + 5 years old
- https://github.com/rschroll/rmfuse
  + Fuse between local folder and the cloud
  + Requires `rmcl` and `rmrl`
  + Not working anymore
- Syncthing https://github.com/evidlo/remarkable_syncthing
  + Requires Entware
- https://github.com/codetist/remarkable2-cloudsync
  + A script which uses `Rclone` binary.
- Remi https://github.com/bordaigorl/remy
  + GUI, Not outdated
  + I didn't check it

### Screen sharing

* reMarkable mouse
  - https://github.com/evidlo/remarkable_mouse
  - https://github.com/kevinconway/remouseable
* reStream https://github.com/rien/reStream

### Other projects

* SSH access and backups https://remarkablewiki.com/tech/ssh#ssh_access
* Entware https://github.com/evidlo/remarkable_entware
* `Rm_tools` https://github.com/lschwetlick/maxio/tree/master/rm_tools
* Some nix expressions https://github.com/siraben/nix-remarkable
* Receive files from Telegram https://github.com/Davide95/remarkaBot
  - Needs rebooting after the file is received
