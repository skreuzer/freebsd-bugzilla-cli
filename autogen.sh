#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

pkg query -x "%n" "pybugz" >/dev/null
if [ $rc -ne 0 ]; then
  echo "py34-bugz not installed"
  echo "Run sudo pkg install py34-bugz"
fi
