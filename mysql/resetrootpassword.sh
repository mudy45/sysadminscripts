#!/usr/bin/env  bash
###############################################################################
###                                                               	        ###
###            LAZYSERVERADMIN / MYSQL / RESETROOTPASSWORD.SH	      	    ###
###                           by mudy45@github                              ###
###                                                                 	    ###
### Reset MySQL / MariaDB root password and maintain /root/.my.cnf          ###
###                                                                        	###
###-------------------------------------------------------------------------###
###                                                                        	###
### Version requirement                                                   	###
### Op System		: Ubuntu 16.04.03 Xenial LTS                            ###
### RDBMS			: MariaDB 10.1                                          ###
###                                                                        	###
###-------------------------------------------------------------------------###
###                                                                         ###
### License	    : GNU General Public License version 3        	            ###
### Copyright   : Mudy Situmorang (mudy45@gmail.com)                        ###
### Tested OS	: Ubuntu 16.04.3 LTS Xenial                                 ###
### Github      : https://github.com/mudy45/sysadminscripts    	            ###
### Version     : 0.1 alpha --> WARNING: DO NOT USE !!!!                    ###
### File        : /mysql/resetrootpassword.sh		                        ###
### Release		: Not Available                                             ###
### Update      : 20170920                                                  ###
###                                                                         ###
###############################################################################

###############################################################################
### help()                                                             	    ###
### show usage info                                                    	    ###
###-------------------------------------------------------------------------###
###                                                                  	    ###
help() {
	[[ -n ${1} ]] && echo -e "** ${1}\n"
  	cat <<EOU
Reset MySQL / MariaDB root password without knowing old password 
or using .my.cnf file.

Usage: 	resetrootpassword.sh
		resetrootpassword.sh newrootpassword
		-h | --help     	This message.

	EOU
 	exit
}
###                                                                         ###
###############################################################################



systemctl stop mysql
mysqld_safe --skip-grant-tables --skip-networking &
mysql -u root -D mysql -bse "UPDATE user SET password=PASSWORD("$1") WHERE user='root'; FLUSH PRIVILEGES; EXIT;"
rm /root/.my.cnf
echo "#
[client]
user=root
pass=$1" > /root/.my.cnf
systemctl start mysql
systemctl status mysql

### EOF
