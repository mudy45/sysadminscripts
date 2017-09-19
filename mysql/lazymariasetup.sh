#!/usr/bin/env bash

###############################################################################
###                                                               	        ###
###                   LAZYSERVERADMIN / LAZYMARIASETUP.SH 	         	    ###
###                             by mudy45@github                            ###
###                                                                 	    ###
###                                                                        	###
###-------------------------------------------------------------------------###
###                                                                        	###
### RDBMS			: MariaDB 10.1                                          ###
###                                                                        	###
###-------------------------------------------------------------------------###
###                                                                         ###
### License	    : GNU General Public License version 3        	            ###
### Copyright   : Mudy Situmorang (mudy45@gmail.com)                        ###
### Tested OS	: Ubuntu 16.04.3 LTS Xenial                                 ###
### Github      : https://github.com/mudy45/sysadminscripts    	            ###
### Version     : 0.1 alpha --> WARNING: DO NOT USE !!!!                    ###
### File        : /mysql/lazymariasetup.sh		                            ###
### Release		: Not Available                                             ###
### Update      : 20170920                                                  ###
###                                                                         ###
###############################################################################

###----> Mariadb vars
mirrorRepo = "sgp1.mirrors.digitalocean.com"
ubuntuKeyserver = "0xF1656F24C74CD1D8"
linuxCodename = "xenial"
linuxDistro = "ubuntu"
typeMysql = "mariadb"
verMysql = "10.1"
mysqlRootpass = openssl rand -base64 12
mysqlSu = "mysqlsu"
mysqlRootpass = openssl rand -base64 12


###----> Install MariaDB/MySQLd at version, no need to enter root password
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 ${ubuntuKeyserver}
add-apt-repository -u 'deb [arch=amd64] http://${mirrorRepo}/${typeMysql}/repo/${verMysql}/${linuxDistro} ${linuxCodename} main'
apt-cache policy ${typeMysql}-server
Fwaitfor
read -rsp 'Do not enter password, will be replaced by auto generated.' key
apt-get -y install ${typeMysql}-server ${typeMysql}-client
bash ./mysql/securemysqlinstallation.sh
###----> Update password
mysql -u root -bse "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysqlRootpass}';"
###----> Create root/.my.cnf
echo "#
[client]
user=root
pass=${mysqlRootpass}" > /root/.my.cnf
###----> Create ~/.my.cnf and root/.my.cnf
echo "#
[client]
user=${mysqlSu}
pass=${mysqlSupass}" > /home/${mysqlSu}/.my.cnf
systemctl status mysql
echo "Password on /root/.my.cnf and /home/${mysqlSu}/.my.cnf"
echo "Use ${mysqlSu} instead of root"

###-----> Optimize MariaDB
