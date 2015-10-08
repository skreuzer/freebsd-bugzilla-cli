# Description:
CLI utilities and wrappers for FreeBSD's bugzilla instance
with emphasis on ports.

Provides a consistent API which can have pluggable backends.

Note, this is meant for developers and committers, though
its possible a non techie might be able to use it.

# Installation
```sh
sudo pkg install freebsd-bugzilla-cli
```
or

```sh
cd ports-mgmt/freebsd-bugzilla-cli
sudo make install clean
```

# Run from git
```sh
git clone git@github.com:pgollucci/freebsd-bugzilla-cli.git
cd freebsd-bugzilla-cli
./autogen.sh
```

# Usage
- bz init
- bz help
- bz help $cmd or bz $cmd -h

All subcommands support -h for help

# Supported Commands
- bz init
- bz login
- bz port_submit
- bz src_submit
- bz search
- bz take
- bz inprog
- bz show
- bz comment
- bz edit
- bz get
- bz patch
- bz port_commit
- bz close
- bz overto
- bz timeout
- bz top
- bz claim

# Future
- bz blocks
- bz depends
- bz duplicates
- bz stalk

# Implementing a New Backend
```sh
cp -R share/bz/pybugz share/bz/$backend
```
- edit all files and replace $bugz calls with something else
- send a GitHub Pull Request

As of v0.5.0 we will follow Versionsing Rules for the API
so backends can be stable.
http://apr.apache.org/versioning.html

