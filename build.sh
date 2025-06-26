#!/bin/sh

fasm boot.asm
cat boot.bin > disk.img
