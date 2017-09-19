#!/usr/bin/env bash

swappinessNum = "30"
###----> Create swap 2x RAM
swapSize = "1024k"
###----> Change this SSH port number
customSshport = "22222"

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

###----> Install MariaDB/MySQLd at version, no need to enter root password
/mysql/lazymariasetup.sh

###----> Install Nginx
/nginx/lazynginxsetup.sh

###----> Install PHP
/php/lazyphpsetup.sh

###----> Install PHP
/nodejs/lazynodejssetup.sh

###----> CSF
/csf/lazycsfsetup.sh

###----> Munin
/munin/lazymuninsetup.sh

###----> Nagios
/nagios/lazynagiossetup.sh

###----> Wordpress
/wp/lazywpsetup.sh

###----> Lazy Server
/lazyserver/stats.sh
/lazyserver/bksy.sh

###----> Restart server
sudo reboot
### sudo 

###EOF
