
ReMarkable2 links
-----------------

### General

* RemarkableWiki https://remarkablewiki.com/tips/start
* reHackable https://github.com/reHackable/awesome-reMarkable
* Reddit
  - https://www.reddit.com/r/RemarkableTablet/comments/ickcu5/we_need_split_screen_for_the_rm2/

### Topics

* SSH access and backups https://remarkablewiki.com/tech/ssh#ssh_access
* Entware https://github.com/evidlo/remarkable_entware
* `Rm_tools` https://github.com/lschwetlick/maxio/tree/master/rm_tools

* Some nix expressions https://github.com/siraben/nix-remarkable

* remarkable mouse
  - https://github.com/evidlo/remarkable_mouse
  - https://github.com/kevinconway/remouseable

* Sync approaches:
  - https://github.com/simonschllng/rm-sync
    + Seems to be a local script, incomplete
  - https://github.com/lschwetlick/rMsync
    + Another script, this time in Python
    + Needs `rm_tools`
  - https://github.com/nick8325/remarkable-fs
    + FUSE, Seems to work without the cloud
  - https://github.com/rschroll/rmfuse
    + Fuse between local folder and the cloud
    + Requires `rmcl` and `rmrl`
  - Syncthing https://github.com/evidlo/remarkable_syncthing
    + Requires Entware


Issues
------

* https://github.com/rschroll/rmcl/issues/1


Shell hints
-----------

### Nix-shell

```
$ nix-shell -A shell
```

### RMfuse

```
$ mkdir _remarkable
$ rmfuse -v _remarkable
```


