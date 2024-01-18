ReMarkable 2 tools
==================

This is a umbrella project containing author's [Nix](http://www.nixos.org) build
expressions for various [Remarkable2 tablet](https://remarkable.com/store/remarkable-2) software.

What works and what doesn't
---------------------------

* [x] SSH connectivity systemd service.
* [x] Host-device library folder synchronisation using `rsync`.
* [x] Importing PDF documents to the library.
* [ ] Exporting documents from the library (`rm2svg` seems to be broken)
* [x] RM2 stylus capturing using `remarkable_mouse`.

Contents
--------

<!-- vim-markdown-toc GFM -->

* [Usage](#usage)
  * [Nix development shell](#nix-development-shell)
  * [Establishing wireless SSH connection](#establishing-wireless-ssh-connection)
* [Sub-projects](#sub-projects)
  * [Rmsynctools](#rmsynctools)
  * [Remouse](#remouse)
* [Various low-level actions](#various-low-level-actions)
  * [Enabling the older SSH key format support.](#enabling-the-older-ssh-key-format-support)
  * [Setting up the Host IP to connect via the USB cable](#setting-up-the-host-ip-to-connect-via-the-usb-cable)
  * [Manually syncing the xochitl](#manually-syncing-the-xochitl)
* [Resources](#resources)
  * [General](#general)
  * [Synchronization](#synchronization)
  * [Screen sharing](#screen-sharing)
  * [Other projects](#other-projects)

<!-- vim-markdown-toc -->

Usage
-----

### Nix development shell

We use [Nix](https://nixos.org/nix) to track the library dependencies. Main expressions
are defined in [default.nix](./default.nix). [flake.nix](./flake.nix) describes
the relationships to other Nix repositories, inclding the main Nixpkgs repo.

To run the development shell, type:

```sh
$ export NIXPKGS_ALLOW_INSECURE=1 # needed to allow the buggy xpdf dependency
$ nix develop --impure # Impure is needed for Nix to notice the above variable
```

To build a specific Nix expression (e.g. `rmsynctools_def`):

```sh
$ nix build '.#rmsynctools_def' --impure
```

To enable the specific configuration without installing scripts, link it into
the `./_rmconfig` file in the current directory and source `./sh/rmcommon`.

``` sh
$ ln -s ./sh/nixconfig.sh _rmconfig
$ . ./sh/rmcommon # Optionally
```

Then you could run `./sh/rm*` in-place scripts wihtout installing them into the
system.

### Establishing wireless SSH connection

To enable SSH access to the Remarkable tablet we rely on a third-party server
with a public IP address (the VPS). We use
[rmssh-install](./sh/rmssh-install.sh) to setup a Systemd service on the device
and to send the necessary SSH keys to the VPS. The tablet then maintains a
connection to the VPS by keeping certain ports opened so the users can establish
a wireless connection to the tablet using VPS as a relay.

Given the successful installation, one can run the `rmssh` script in order to
reach the tablet without connecting its USB cable.

```sh
$ rmssh remarkable
```

Sub-projects
------------

### Rmsynctools

Rmsynctools is a set of shell scripts for synchronizing document trees between
the Host and RM2 device. Our approach is inspired by
[Dr Fraga's](https://www.ucl.ac.uk/~ucecesf/remarkable/) work. In contrast to
it, we use `rsync` rather then `sshfuse` to manage the actual data transfer.

The workflow:

1. Adjust the [rmcommon](./sh/rmcommon) that defines the main configuration
   environment variables.
2. Optionally run the [rmssh-install](./sh/rmssh-install.sh) to install the
   systemd service rule to the RM2 device. Provided with the VPS requisites, the
   script will install the RM2 systemd running the reverse SSH tunnel from VPS
   host to RM2 device.  allowing the wireless access to RM2 device.
   [rmssh](./sh/rmssh) script can be used to connect to the device using this
   tunnel.
3. Run the [rmpull](./sh/rmpull) to pull the `xochitl` tree from RM2 device to
   Host.  Pass `--delete` argument to also remove Host files that don't present
   on the tablet.
4. View or modify the Host copy of `xochitl` using one of the
   following scripts:
   - [rmls](./sh/rmls) Lists the folder's content
   - [rmfind](./sh/rmfind) Gets the document UUID by name
   - [rmconvert](./sh/rmconvert) of Dr.Fraga builds the annotated PDF by UUID.
     + Currently, getting annotaded documents doesn't rely on the Remarkable
       web-server.  Unfortunately, `rmconvert` is pretty slow and has some
       issues with SVG graphics in PDF documents.
   - [rmadd](./sh/rmadd) adds new document to the file tree
5. Run [rmpush](./sh/rmpush) to push the modified `xochitl` tree back to the
   RM2 device. `rmpush` doesn't remove anything from the tablet.

All transport scripts support accessing up to two RM2 devices using the reverse
SSH tunnel. See `-D (A|B)` command line argument.

### Remouse

To link the RM2 stylus with the Host mouse, do

```sh
$ echo 'password' >_pass.txt # RM2 root password
$ ./runmouse.sh
```

Issues:

* ~~https://github.com/Evidlo/remarkable_mouse/issues/63~~
  + ~~Specifying --password seems to have no effect~~ (Fixed)

Various low-level actions
-------------------------

### Enabling the older SSH key format support.

In the Host's Nix configuration:

```nix
{
#...
  programs.ssh = let
    algos = ["+ssh-rsa"];
  in {
    hostKeyAlgorithms = algos;
    pubkeyAcceptedKeyTypes = algos;
  };
#...
}
```

### Setting up the Host IP to connect via the USB cable

```sh
$ sudo ifconfig enp3s0u1 10.11.99.2 netmask 255.255.255.0
```

.. or set up NetworkManager to automatically assign IP address


### Manually syncing the xochitl

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

- Prof. Fraga's page on remarkable with lots of useful scripts
  https://www.ucl.ac.uk/~ucecesf/remarkable/
  + Last seen modification date: 2022-09-28
  + [rm2pdf.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/pdf2rm.sh)
  + [rmlist.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/rmlist.sh)
  + [rmconvert.sh](https://www.ucl.ac.uk/~ucecesf/remarkable/rmconvert.sh)
- [Remarkable CLI tooling](https://github.com/cherti/remarkable-cli-tooling)
  + Could be up-to-date; More or less works
  + Couldn't remove file from remarkable
  + Sent Pull request and filed an issue
    * https://github.com/cherti/remarkable-cli-tooling/issues/5
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
  + GUI, seems to be up to date.
  + Not checked.

### Screen sharing

* reMarkable mouse
  - https://github.com/evidlo/remarkable_mouse
  - https://github.com/kevinconway/remouseable
* [reStream](https://github.com/rien/reStream)

### Other projects

* [SSH access and backups](https://remarkablewiki.com/tech/ssh#ssh_access)
* [Entware](https://github.com/evidlo/remarkable_entware)
* `Rm_tools` https://github.com/lschwetlick/maxio/tree/master/rm_tools
* [Some nix expressions](https://github.com/siraben/nix-remarkable)
* [Receive files from Telegram](https://github.com/Davide95/remarkaBot)
  - Needs rebooting after the file is received
* [ddvk/remarkable-hacks](https://github.com/ddvk/remarkable-hacks)
  - Lots of RM2 GUI hacks
  - Does not support newer versions (mine is `>3.0`), see the related
    [issue](https://github.com/ddvk/remarkable-hacks/issues/496).
* [rmscene](https://github.com/ricklupton/rmscene) .RM files converter
* [Codexctl](https://github.com/Jayy001/codexctl) CLI for update server


