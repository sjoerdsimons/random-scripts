#!/bin/bash
set -v

IMG=$(pwd)/ostree-img
mount /dev/loop0p2 ostree-img
mount /dev/loop0p1 ostree-img/boot/efi

ostree \
  --repo=${IMG}/ostree/repo \
  pull-local --remote=origin \
  $(pwd)/repo debian/amd64/stretch

ostree admin --sysroot=${IMG} deploy \
  --os=debian \
  --karg="rw" \
  origin:debian/amd64/stretch

rm -rf ${IMG}/boot/efi/ostree
cp -r ${IMG}/boot/ostree ${IMG}/boot/efi

rm -rf ${IMG}/boot/efi/loader
mkdir -p ${IMG}/boot/efi/loader
cp -r $(realpath ${IMG}/boot/loader)/* ${IMG}/boot/efi/loader
echo timeout 3 > ${IMG}/boot/efi/loader/loader.conf

#umount -l /dev/loop0p*
