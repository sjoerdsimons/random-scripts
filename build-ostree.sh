#!/bin/bash
export TMPDIR=$(pwd)/tmp

export ROOTDIR=$(pwd)/tmp/rootdir-$(date +'%Y%m%d-%H%M')

~sjoerd/source/vmdebootstrap/bin/vmdebootstrap \
  --rootdir=${ROOTDIR} \
  --mirror=http://ftp.nl.debian.org/debian \
  --root-password=root \
  --user=user/user \
  --sudo \
  --sparse \
  --debootstrapopts=merged-usr \
  --debootstrapopts=verbose \
  --debootstrapopts=unpack-tarball=$(pwd)/debs.tar \
  --distribution=stretch \
  --verbose --log=stderr \
  --customize=$(pwd)/build-ostree-customize.sh

echo ${ROOTDIR}

./mangle-into-ostree ${ROOTDIR}

ostree commit \
  --verbose \
  --repo=$(pwd)/repo \
  -s test \
  --branch=debian/amd64/stretch \
   ${ROOTDIR}

