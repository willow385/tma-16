#!/usr/bin/bash
# Shell script for cleaning out `.tmx` files.

mv no_asm.tmx ._tmp; # ensure that this file doesn't get clobbered
rm *.tmx;
mv ._tmp no_asm.tmx;
