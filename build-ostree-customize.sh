#!/bin/sh

ROOTDIR=$1
env
export DEBIAN_FRONTEND=noninteractive

# Chown so all users can access the directory
chmod a+rx ${ROOTDIR}

echo Acquire::Retries "20"\;  > ${ROOTDIR}/etc/apt/apt.conf.d/99-retry-lots.conf

systemd-nspawn -D ${ROOTDIR} ln -sf /lib/systemd/resolv.conf /etc/resolv.conf
systemd-nspawn -D ${ROOTDIR} apt-get -qy update

mkdir -p ${ROOTDIR}/etc/dracut.conf.d/
cat << EOF > ${ROOTDIR}/etc/dracut.conf.d/20-build.conf
hostonly=no
EOF

# If proc isn't mounted dracut noobs installing kernel modules even if not in
# hostonly mode
mount -t proc none ${ROOTDIR}/proc

chroot ${ROOTDIR} apt-get -qy --no-install-recommends   install \
		    dracut \
		    ostree 

cp -vr extra-debs ${ROOTDIR}
chroot ${ROOTDIR} bash -c "dpkg -i /extra-debs/*.deb"
rm -rf ${ROOTDIR}/extra-debs

chroot ${ROOTDIR} /var/lib/dpkg/info/dracut.postinst

umount ${ROOTDIR}/proc

