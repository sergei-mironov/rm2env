ReMarkable 2 environment
========================

This ia a [Nix-shell](http://www.nixos.org) environment which contains Nix build
rules for various software, related to [Remarkable2 tablet](https://remarkable.com/store/remarkable-2).

Contents
--------

1. [Contents](#contents)
2. [Usage](#usage)
   * [Entering the Environment](#entering-the-environment)
   * [Synchronizing through SSH](#synchronizing-through-ssh)
   * [Linking the pointer with the Host mouse cursor](#linking-the-pointer-with-the-host-mouse-cursor)
3. [Low-level actions](#low-level-actions)
   * [Accessing Remarkable from Host via third-party Server using SSH forwarding](#accessing-remarkable-from-host-via-third-party-server-using-ssh-forwarding)
   * [Enabling the support of older SSH key formats](#enabling-the-support-of-older-ssh-key-formats)
   * [Setting the Host IP to connect via USB cable](#setting-the-host-ip-to-connect-via-usb-cable)
   * [Calling resync DEPRECATED](#calling-resync-deprecated)
   * [Syncing the xochitl](#syncing-the-xochitl)
4. [Resources](#resources)
   * [General](#general)
   * [Synchronization](#synchronization)
   * [Screen sharing](#screen-sharing)
   * [Other projects](#other-projects)

Usage
-----

### Entering the Environment

The scripts depend on a number of third-party tools for PDF editing. Entering
the environment means to install all the required tools and open the shell where
they are available.

```sh
$ nix-shell -A shell
```

### Synchronizing through SSH

This repository includes a set of shell-scripts inspired by [Dr Fraga's
approach](https://www.ucl.ac.uk/~ucecesf/remarkable/). In contrast to Dr. Fraga,
I use `rsync` rather then `fuse` mounts. My scripts are also compatible with a
[systemd rule for SSH proxying](./sh/install-sshR) which relies on
a thirdparty server with a public IP address.

From the user's point of view, the overall process works as follows:

1. [rmcommon](./sh/rmcommon) controls the configuration environment
   variables.
2. [install-sshR](./sh/install-sshR) (Optional) installs the systemd
   rule to the remarkable device and the SSH key to a third-party server with
   public IP as configured by configuration variables. If you don't have one,
   you can still use the default USB wire to get a direct SSH connection. This
   step typically has to be performed once after every remarkable update.
3. [rmpull](./sh/rmpull) pulls the whole `xochitl`
   folder from Remarkable device to the host using the `rsync` tool. `rmpull`
   removes all extra files on the Host that don't present on the tablet.
4. Modify the Host-version of `xochitl`, such as:
   - [rmls](./sh/rmls) Lists the folder's content
   - [rmfind](./sh/rmfind) Gets the document UUID by name
   - [rmconvert](./3rdparty/fraga/rmconvert) of Dr.Fraga builds the
     annotated PDF by UUID.
     + Currently, getting annotaded documents doesn't rely on the Remarkable
       web-server.  Unfortunately, `rmconvert` is pretty slow and has some
       issues with SVG graphics in PDF documents.
   - [rmadd](./sh/rmadd) adds new document
5. [rmpush](./sh/rmpush) pushes Host's `xochitl` back to the
   device. `rmpush` doesn't remove anything from the table. Use the tablet
   GUI for the removal.


### Linking the pointer with the Host mouse cursor

Connect the device to Host and do the following

```sh
$ echo 'password' >_pass.txt
$ ./runmouse.sh
```

Issues:

* ~~https://github.com/Evidlo/remarkable_mouse/issues/63~~
  + Specifying --password seems to have no effect (Fixed)

Low-level actions
-----------------

### Accessing Remarkable from Host via third-party Server using SSH forwarding

We need a third-party Server where SSH is controlled. Lets say its
`~/.ssh/config` credentials has name `vps`. 4349 is a free port to listen on
`vps`.

```sh
RM $ ssh -R0.0.0.0:4349:127.0.0.1:22 vps
```
```sh
HOST $ ssh -o "ProxyCommand ssh vps nc 127.0.0.1 4349" remarkable
```

<!-- * Current IP `192.168.6.91` -->
<!-- * Wiki page on WiFi issues https://remarkablewiki.com/tips/wifi -->


### Enabling the support of older SSH key formats

In the Host Nix config:

```nix
programs.ssh = let
  algos = ["+ssh-rsa"];
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


### Calling resync DEPRECATED

```sh
$ resync.py -r remarkable -v  backup  -o _rm2sync
```


### Syncing the xochitl

Remarkable->Host transfer with deletion (remove --dry-run)

```sh
$ rsync -i -avP --dry-run --delete -e ssh remarkable:/home/root/.local/share/remarkable/xochitl/ _xochitl/
```

Host->Remarkable transfer without deletion (remove --dry-run)

```sh
$ rsync -i -avP --no-owner --no-group --dry-run -e ssh _xochitl/ remarkable:/home/root/.local/share/remarkable/xochitl/
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

