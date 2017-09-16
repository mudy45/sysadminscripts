#!/usr/bin/env bash
#######################################################################
### Sysadminubuntu/nginx by mudy45@github (mudy45@gmail.com)      	###
###-----------------------------------------------------------------###
###                                                               	###
###                                                               	###
###                                                               	###
###                                                               	###
#######################################################################
#-----> Only review versions, to choose target versions & repo
doReviewonly = "0"
#-----> Disable on re-compile, no more apt-get
doGetapt = "1"
doDhparam = "0"
doCompile = "1"
doCleanup = "0"
#-----> Choose one repo to use
useRepoppadev = "1"
useRepoppasta = "0"
useReponginx = "0"
useRepolinux = "0"

if [ "$1" == "--review" -o "$1" == "-r" ]; then
	doReviewonly = "1"
	doDhparam = "0"
	doCompile = "0"
	doCleanup = "0"
	#---> Open use all repo to compare versions
	useRepoppadev = "1"
	useRepoppasta = "1"
	useReponginx = "1"
	useRepolinux = "1"
fi


#######################################################################
### Review Target & Repo for Nginx Package						  	###
###                                                               	###
###-----------------------------------------------------------------###
### http://nginx.org/en/download.html								###
### current stable		: nginx 1.12.1 & 1.13.3						###
###-----------------------------------------------------------------###
###-----> Linux version here: Ubuntu								###
linuxVer = "xenial"
repoNginx = "https://nginx.org/packages/ubuntu"
repoLinux = "https://sgp1.digitalocean.com/"
###-----> Linux version here: Debian								###
#linuxVer = "stretch-backports"
#repoNginx = "https://nginx.org/packages/debian/"
#repoLinux = "https://sgp1.digitalocean.com/"
###-----------------------------------------------------------------###
### Choose Ubuntu or Debian, run Review, fill table below, decide  	###
### your target build and repo, then compile.                      	###
###-----------------------------------------------------------------###
### 		Ubuntu 16.04 LTS Xenial					   				###
### Ubuntu Repo		: nginx 1.10.3-0ubuntu0.16.04.2					###
### PPA Repo		: nginx 1.13.4				   					###
### Nginx Repo		: nginx 1.12.1				   					###
### 		Ubuntu 16.10 Yaketty									###
### Ubuntu Repo	 	: nginx 1.10.1-0ubuntu1.3		   				###
### PPA Repo	 	: 							   					###
### Nginx Repo	 	:								   				###
###-----------------------------------------------------------------###
### 		Debian 8 Jessie                                       	###
### Debian Repo		: nginx (1.6.2-5+deb8u5)						###
### 		Debian 8 Jessie Backports                              	###
### Debian Repo		: nginx (1.10.3-1+deb9u1~bpo8+2)	 			###
### 		9 stretch                                               ###
### Debian Repo 	: nginx (1.10.3-1+deb9u1)						###
###			9 stretch Backports	                                	###
### Debian Repo		: nginx (1.13.3-1~bpo9+1)						###
### PPA Repo		: nginx 1.13.4				   					###
### Nginx Repo		:                                         		###
###-----------------------------------------------------------------###


#######################################################################
### APT Repository												 	###
###-----------------------------------------------------------------###
if [ "${doGetapt}" != "0" ];
then
	wget -N https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	rm nginx_signing.key
	add-apt-repository "deb ${nginxRepo} ${ubuntuVer} nginx"
	add-apt-repository "deb-src ${nginxRepo} ${ubuntuVer} nginx"
	add-apt-repository ppa:nginx/stable
	if [ "${useRepoppadev}" != "0" ];
	then
		add-apt-repository ppa:nginx/development
	fi
	apt-get update
	apt-get upgrade
#-----> Troubleshooting package missing stuff						###
###	apt-get install software-properties-common phyton-software-properties 

fi




