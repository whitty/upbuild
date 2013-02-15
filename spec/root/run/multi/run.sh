#!/bin/sh

echo $1
if [ -f "$1" ]; then
  exit 1
fi
exit 0
