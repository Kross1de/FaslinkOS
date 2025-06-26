#!/bin/sh

set -ex
qemu-system-i386 -drive file=disk.img,format=raw