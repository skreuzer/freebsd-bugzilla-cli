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

# Usage
bz help

All subcommands support -h for help

# Supported Commands
- bz init
- bz login
- bz submit
- bz search
- bz take
- bz inprog
- bz comment
- bz get
- bz patch
- bz close

- bz overto
- bz timeout
- bz top

# Future
- bz blocks
- bz depends
- bz duplicates
