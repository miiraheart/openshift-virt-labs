hostnamectl set-hostname ocp4-bastion.cnv.example.com
dnf install qemu-img jq git httpd squid dhcp-server xinetd net-tools nano bind bind-utils haproxy wget syslinux libvirt-libs -y
dnf install tftp-server syslinux-tftpboot -y
dnf update -y
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
dnf install firewalld -y
systemctl enable --now firewalld
firewall-cmd --add-service=dhcp --permanent
firewall-cmd --add-service=dns --permanent
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --add-service=squid --permanent
firewall-cmd --add-service=tftp --permanent
firewall-cmd --add-service={nfs3,mountd,rpc-bind} --permanent
firewall-cmd --add-service=nfs --permanent
firewall-cmd --permanent --add-port 6443/tcp
firewall-cmd --permanent --add-port 8443/tcp
firewall-cmd --permanent --add-port 22623/tcp
firewall-cmd --permanent --add-port 81/tcp
firewall-cmd --reload
setsebool -P haproxy_connect_any=1
mkdir -p /nfs/pv1
mkdir -p /nfs/pv2
mkdir -p /nfs/fc31
chmod -R 777 /nfs
echo -e "/nfs *(rw,no_root_squash)" > /etc/exports
# we may have to do something about setting /etc/nfs.conf to v4 only
systemctl enable httpd
systemctl enable named
systemctl enable squid
systemctl enable dhcpd
systemctl enable rpcbind
systemctl enable nfs-server
mkdir -p /var/lib/tftpboot/pxelinux/pxelinux.cfg/
cp -f /tftpboot/pxelinux.0 /var/lib/tftpboot/pxelinux
cp -f /tftpboot/ldlinux.c32 /var/lib/tftpboot/pxelinux
cp -f /tftpboot/vesamenu.c32 /var/lib/tftpboot/pxelinux
sed -i 's/Listen 80/Listen 81/g' /etc/httpd/conf/httpd.conf
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.6/openshift-install-linux.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.6/openshift-client-linux.tar.gz
tar -zxvf openshift-client*
tar -zxvf openshift-install*
cp oc kubectl /usr/bin/
rm -f oc kubectl
chmod a+x /usr/bin/oc
chmod a+x /usr/bin/kubectl
mkdir -p /root/ocp-install/
growpart /dev/vda 1
xfs_growfs /
	systemctl enable xinetd
	systemctl enable tftp
	systemctl enable haproxy
	wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/latest/rhcos-metal.x86_64.raw.gz
	wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/latest/rhcos-live-kernel-x86_64
	wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/latest/rhcos-live-initramfs.x86_64.img
	wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/latest/rhcos-live-rootfs.x86_64.img
	mv rhcos* /var/www/html
	mv /var/www/html/*raw* /var/www/html/rhcos.raw.gz
	mv /var/www/html/*kernel* /var/www/html/rhcos.kernel
	mv /var/www/html/*initramfs* /var/www/html/rhcos.initramfs
	mv /var/www/html/*rootfs* /var/www/html/rhcos.rootfs
	chmod -R 777 /var/www/html
	restorecon -Rv /var/www/html
