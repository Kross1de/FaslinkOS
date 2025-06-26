#!/bin/sh

set -ex
fasm boot.asm
cat boot.bin > disk.img
