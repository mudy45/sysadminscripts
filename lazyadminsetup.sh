#!/usr/bin/env bash

swappinessNum = "30"
###----> Create swap 2x RAM
swapSize = "1024k"
###----> Change this SSH port number
customSshport = "22222"
###----> Mariadb vars
mirrorRepo = "sgp1.mirrors.digitalocean.com"
ubuntuKeyserver = "0xF1656F24C74CD1D8"
linuxCodename = "xenial"
linuxDistro = "ubuntu"
verMariadb = "10.1"

###----> Functions
Fwaitfor()	{
	read -rsp -t5 'Press Ctrl-C to abort script...' key
}

###----> Update server time
timedatectl set-timezone Asia/Jakarta
timedatectl 
Fwaitfor

###----> Update server
apt-get update && apt-get upgrade -y && apt-get dist-upgrade && apt-get autoremove && apt-get clean
Fwaitfor

###----> Create swap
touch /var/swap.img
chmod 600 /var/swap.img
dd if=/dev/zero of=/var/swap.img bs=${swapSize} count=1000
mkswap /var/swap.img
swapon /var/swap.img
echo "/var/swap.img    none    swap    sw    0    0" >> /etc/fstab
sysctl -w vm.swappiness=${swappinessNUM}
sysctl -a | grep vm.swappiness
vmstat
free
Fwaitfor

###-----> ufw
sed -i 's/^#?IPV6=.*/IPV6=yes/' /etc/default/ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ${customSshport}
sudo ufw allow 
sudo ufw status verbose
Fwaitfor

###----> Secure SSH port
sed -i 's/^#?Port .*/Port ${customSshport}/' /etc/ssh/sshd_config
sed -i 's/^#?PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
servicectl restart sshd
Fwaitfor

###----> Install other apps
apt-get install mc

###----> Install MariaDB at version
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 ${ubuntuKeyserver}
add-apt-repository -u 'deb [arch=amd64] http://${mirrorRepo}/mariadb/repo/${verMariadb}/${linuxDistro} ${linuxCodename} main'
apt-cache policy mariadb-server
Fwaitfor
apt-get -y install mariadb-server
mysql_secure_installation
systemctl status mysql

###----> Install Nginx


###----> Install PHP



###----> Restart server
sudo reboot
### sudo 

###EOF

