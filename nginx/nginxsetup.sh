#!/usr/bin/env bash
###############################################################################
###                                                               	        ###
###                   LAZYSERVERADMIN / NGINXSETUP.SH	 	         	    ###
###                             by mudy45@github                            ###
###                                                                 	    ###
###                                                                     	###
### Maintaining a proper Nginx production webserver will be easier and   	###
### fun with this script. The technology develop so fast, adds so many      ###
### point of failure, some force sysadmin to recompile, other causing 	    ###
### compile errors. Dynamic modules still not the first choice for now.     ###
###                                                                     	###
### This script allows easy generation of custom Nginx apt package for      ###
### GNU Linux (dpkg) that can be installed on another GNU Linux. 			###
###                                                                      	###
### Included external modules are:											###
### PageSpeed + psol, NAXSI, PCRE, OpenSSL, VTS, Brotli                    	###
###                                                                      	###
###-------------------------------------------------------------------------###
###                                                                         ###
### License	    : GNU General Public License version 3        	            ###
### Copyright   : Mudy Situmorang (mudy45@gmail.com)                        ###
### Tested OS	: Ubuntu 16.04.3 LTS Xenial                                 ###
### Github      : https://github.com/mudy45/sysadminubuntu     	            ###
### Version     : 0.1 alpha --> WARNING: DO NOT USE !!!!                    ###
### File        : /nginx/nginxsetup.sh                                      ###
### Release		: Not Available                                             ###
### Update      : 20170917                                                  ###
###                                                                         ###
###############################################################################

###############################################################################
### Review Nginx Version and Modules                                        ###
### Choose Ubuntu or Debian, run Review, fill table below, decide your   	###
### distro, target build, repo, check module, then compile.		  	   		###
### Last update: 20170917                                              	    ###
###-------------------------------------------------------------------------###
### http://nginx.org/en/download.html					                	###
### Nginx Mainline	: 1.13.5							               		###
### Nginx Stable	: 1.12.1							               		###
###-------------------------------------------------------------------------###
###	Debian GIT		: https://anonscm.debian.org/cgit/pkg-nginx/nginx.git   ###
###					: 1.13.5 (20170905)                               	    ###
###					  Add RTMP video streaming server                  	    ###
###-------------------------------------------------------------------------###
###		    Ubuntu                                                     	    ###
###-------------------------------------------------------------------------###
### 		Ubuntu 16.04 LTS Xenial					           		        ###
### Ubuntu Repo		: nginx 1.10.3-0ubuntu0.16.04.2		       	    	    ###
### PPA Dev Repo	: nginx 1.13.3-0+xenial1	   	        	            ###
### PPA Stab Repo	: nginx 1.12.1				   	        	            ###
### Nginx Repo		: nginx 1.12.1				   	    	                ###
### 		Ubuntu 16.10 Yaketty						                    ###
### Ubuntu Repo	 	: nginx 1.10.1-0ubuntu1.3			   	                ###
### PPA Dev Repo 	: 							                            ###
### PPA Stab Repo 	: 							                            ###
### Nginx Repo	 	:				         		                        ###
###-------------------------------------------------------------------------###
###		    Debian                                                     	    ###
###-------------------------------------------------------------------------###
### 		Debian 8 Jessie                                       	    	###
### Debian Repo		: nginx (1.6.2-5+deb8u5)			            	    ###
### 		Debian 8 Jessie Backports                           	   	    ###
### Debian Repo		: nginx (1.10.3-1+deb9u1~bpo8+2)	    	            ###
### 		Debian 9 Stretch                            	                ###
### Debian Repo 	: nginx (1.10.3-1+deb9u1)				                ###
###			Debian 9 stretch Backports                 	               		###
### Debian Repo		: nginx (1.13.3-1~bpo9+1)		                	    ###
### PPA Repo		: nginx 1.13.4				   	            	        ###
### Nginx Repo		:                                        	 	        ###
###-------------------------------------------------------------------------###
###		                                                               	    ###
#---> TODO: function to automate distro and code name loading run here                                                             		
			linuxDistro		= "Ubuntu"       # Ubuntu or Debian
			linuxCodename  	= "xenial"       # Release Name
###		                                                               	    ###
###-------------------------------------------------------------------------###
### Module Versions                       									###
### Check each version latest, fallback to known good version          		###
###		                                                               	    ###
###-------------------------------------------------------------------------###
### Release Specific Modules                                      	    	###
###-------------------------------------------------------------------------###
###                                                                	    	###
### Module 		  : OpenSSL - HTTPS support									###
### Check version : https://openssl.org/source								###
### Known good	  : 1.0.2l 													###
			verOpenssl    = "1.0.2l"
### Module 		  : PageSpeed - Some Google stuff							###
### Check version : https://www.modpagespeed.com/doc/release_notes			###
### Known good	  : 1.12.34.2-stable										###
			verPagespeed  = "1.12.34.2-stable"
### Module 		  : PCRE - 													###
### Check version : https://ftp.pcre.org/pub/pcre/							###
### Known good	  : 8.41 													###
			verPcre      = "8.41"
### Module 		  : Zlib - Compression library								###
### Check version : https://zlib.net/										###
### Known good	  : 1.2.11 													###
			verZlib      = "1.2.11"
### Module 		  : Naxsi - Nginx Anti Injection							###
### Check version : https://github.com/nbs-system/naxsi/releases			###
### Known good	  : 0.55.3													###
			verNaxsi    = "0.55.3"
###                                                                	    	###
###-------------------------------------------------------------------------###
### Modules Using Latest Github Master Branch (regardless of version)      	###
###-------------------------------------------------------------------------###
### Module 		  : ngx_devel_kit											###
### Github		  : https://github.com/simpl/ngx_devel_kit.git 				###
### Module 		  : headers-more-nginx-module								###
### Github		  : https://github.com/openresty/headers-more-nginx-module.git	###
### Module 		  : set-misc-nginx-module									###
### Github		  : https://github.com/openresty/set-misc-nginx-module.git	###
### Module 		  : nginx-module-vts										###
### Github		  : https://github.com/vozlt/nginx-module-vts.git 			###
### Module 		  : Brotli - brotli.git										###
### Github		  : https://github.com/google/brotli.git 					###
### Module 		  : Brotli - libbrotli										###
### Github		  : https://github.com/bagder/libbrotli			 			###
### Module 		  : Brotli - ngx_brotli										###
### Github		  : https://github.com/google/ngx_brotli		 			###
###                                                                	    	###
###############################################################################
### Parameters, configurations, and variables                     	    	###
###                                                                	    	###
###-------------------------------------------------------------------------###
### 	                                                               	    ###
cpuCount=$(nproc --all)
currentPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
###-----> Dhparam generation bits
dhparamFile = "/etc/nginx/ssl/dhparam.pem"
dhparamBits = "4096"
###-----> Only review versions, to choose target versions & repo			
doReviewonly = "0"
###-----> Disable on re-compile, no more apt-get
doGetapt = "1"
doDhparam = "0"
doCompile = "1"
doCleanup = "0"
###-----> Choose one repo to use
useRepoppadev = "1"
useRepoppasta = "0"
useReponginx = "0"
useRepolinux = "0"
###-----> Run compile script here, delete everything for cleanup
buildDir = "/usr/local/src/buildnginx"
###-----> Store sourceset
homeDir = "/root"
###-----> $homeDir/sourceset-$sourceset is where all source downloaded
###-----> change $sourceSet number to create new source set
###-----> backup entire folder to recompile exactly same package
sourceSet = "1"

###-----> -R Review Only, -C Standard Compile
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
elif [ "$1" == "--compile" -o "$1" == "-c" ]; then
	doReviewonly = "0"
	doCompile = "1"
	doCleanup = "0"
fi
###                                         	                      	    ###
###-------------------------------------------------------------------------###
### End of params & configs                   	                      	    ###
###############################################################################

###############################################################################
### Fsetrepolinux()	             							             	###
### using repo Ubuntu or Debian		                                       	###
###-------------------------------------------------------------------------###
###                                     	                          	    ###
Fsetrepolinux()	{
	if [ "${doLinux}" != "Ubuntu" ];
	then
		repoNginx = "https://nginx.org/packages/ubuntu"
		repoLinux = "https://sgp1.digitalocean.com/ubuntu"
	else
		repoNginx = "https://nginx.org/packages/debian/"
		repoLinux = "https://sgp1.digitalocean.com/debian"
	fi
}
###                                         	                      	    ###
###############################################################################


###############################################################################
### Fhelp()		                                                      	    ###
### show help and usage info                                                    	    ###
###-------------------------------------------------------------------------###
###                                                                  	    ###
### 0 delrepoAll, 1 addrepoLinux, 2 addrepoBackports, 						###
### 3 addrepoPpasta, 4 addrepoPpadev, 5 addrepoNginx, 6 gitdebian			###
### 7 gitnginx, 9 addrepoReview												###
###                                                                  	    ###
Fhelp()	{
  	cat << EOU
echo -e "Usage:
		sudo su
		${0} [-options -options -options ...]
Compile Custom Nginx on ${buildDir}, save downloaded packages on 
${buildDir}/sourceset-${sourceSet). Must be run as root.\n
Options:
-h | --help     	This message.
-9 | --allrepo		View all repo, add all repository, show available
					version and exit. Usefull to decide which one to use.
					Remove added repo using -0.
-7 | --gitngx		Set source from Nginx Git
-6 | --gitdeb		Set source from Debian Git					
-5 | --repongx		Set Nginx repo
-4 | --repodev		Set PPA development repo
-3 | --reposta		Set PPA stable repo
-2 | --repobck		Set backports repo
-1 | --repolinux	Set Linux Nginx repo
-0 | --resetrepo	Reset repo to distro's default, remove all nginx repo
If multiple repo selected, last repo will be chosen.\n
-c | --compile		Compile package
-u | --uninstall	Uninstall existing web servers
-e | --erase		Erase before compile
-i | --install		Install & configure after compile
-d | --dry-run		Simulate, dry run only
-p | --pause		Interactive, sets of pause and questions
-b | --backupset	Backup current source set to compile later
-l | --listset		List backup source set
-g | --gendhparam	Generate dhparam
-s | --useset		Mark backup source set num to use\n
Setup folder:                                                 	  
Nginx User & Group 	= www-data				                      
Nginx HTTP Folder  	= /var/www                                  	  
Nginx Log Folder   	= /var/log/nginx                           	  
Nginx Cache Folder 	= /var/cache/nginx
Backup source set	= /root/backup/nginx/sourceset-{$num}"
	EOU
 	exit
}

###-------------------------------------------------------------------------###
### Standard must root - call Fhelp()                              		    ###
###                                         	                      	    ###
if [[ $(whoami) != 'root']] && echo -e "Must be root to run $0\n"; then Fhelp; fi
###                                         	                      	    ###
###############################################################################


###############################################################################
### Fprepareonce()						                 	            	###
### one time preparation, dhparam took long time            	         	###
###-------------------------------------------------------------------------###
###                                                               		    ###
Fprepareonce()	{
###-------------------------------------------------------------------------###
### Check and Set Nginx User							                    ###
###-------------------------------------------------------------------------###
    local nginxUserExists=$(id -u www-data > /dev/null 2>&1; echo $?)
    if [[ -z "${nginxUserExists}" ]];
    then
	useradd -d /etc/nginx -s /bin/false nginx
    fi
###-------------------------------------------------------------------------###
### Generate DHParam for Nginx OpemSSL      	        					###
###-------------------------------------------------------------------------###
    if [[ "${doDhparam}" ]];
    then
	    openssl dhparam -out ${dhparamFile} ${dhparamBits}
    fi
###                                                     	          	    ###
###-------------------------------------------------------------------------###
}
###                                                         	      	    ###
###############################################################################


###############################################################################
### Faptnginx()											               		###
### Nginx repo management, add all nginx repo for review, add chosen repo,  ###
### add preferences file for selected repo, remove all nginx repo.		    ###
###-------------------------------------------------------------------------###
###                                                               		    ###
Faptnginx()	{
	wget -N https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	rm nginx_signing.key
	
	case "$1" in 
		addrepoLinux)
				add-apt-repository -s -y -u "deb ${repoLinux} ${linuxVer}-nginx" ;;
				cp ${scriptDir}/src/etc/apt/preferences.d/nginx-linux /etc/apt/preferences.d 
				apt-get update ;;
				#-----> add current linux (ubuntu or debian) repo (stable) for nginx
	addrepoBackports)
				add-apt-repository -s -y -u "deb ${repoLinux} ${linuxVer}-backports nginx" ;;
				cp ${scriptDir}/src/etc/apt/preferences.d/nginx-linux-backports /etc/apt/preferences.d 
				apt-get update ;;
				#-----> add linux-backports (ubuntu or debian) repo for nginx
				#-----> TODO: catch error when bacports repo not exist
		addrepoNginx)
				add-apt-repository -s -y -u "deb ${repoNginx} ${ubuntuVer} nginx" ;;
				cp ${scriptDir}/src/etc/apt/preferences.d/nginx-repo /etc/apt/preferences.d 
				apt-get update ;;
				#-----> add nginx repo (mainline) for current linux (ubuntu or debian)
       addrepoPpasta)
				add-apt-repository -s -y -u ppa:nginx/stable ;;
				cp ${scriptDir}/src/etc/apt/preferences.d/nginx-ppa-stable /etc/apt/preferences.d 
				apt-get update ;;
				#-----> add ppa repo stable for nginx
	   addrepoPpadev)
				add-apt-repository -s -y ppa:nginx/development 
				cp ${scriptDir}/src/etc/apt/preferences.d/nginx-ppa-development /etc/apt/preferences.d 
				apt-get update ;;
				#-----> add ppa repo development (mainline) for nginx
 	   addrepoReview)
				add-apt-repository -y "deb ${repoLinux} ${ubuntuVer} nginx" \
				&& add-apt-repository -y "deb ${repoLinux} ${ubuntuVer}-backports nginx" \
				&& add-apt-repository -y "deb ${repoNginx} ${ubuntuVer} nginx" \
				&& add-apt-repository -y ppa:nginx/stable \
				&& add-apt-repository -y ppa:nginx/development \
				&& apt-get update
				apt-cache show nginx
				apt-cache policy nginx
				echo "Remove Nginx repos using -0"
				exit 1 ;;
				#-----> exit to review all nginx repo version policy
		  delrepoAll)
				add-apt-repository -r -y "deb ${repoLinux} ${ubuntuVer} nginx" \
				&& add-apt-repository -r -y "deb ${repoLinux} ${ubuntuVer}-backports nginx" \
				&& add-apt-repository -r -y "deb ${repoNginx} ${ubuntuVer} nginx" \
				&& add-apt-repository -r -y ppa:nginx/stable \
				&& add-apt-repository -r -y ppa:nginx/development
				rm /etc/apt/preferences.d/nginx*
				apt-get update ;;
				#-----> remove all nginx repo
	esac		  
###                                                               		    ###
###-----> Troubleshooting package missing stuff		           				###
	#apt-get install software-properties-common phyton-software-properties 
}

###-------------------------------------------------------------------------###
### Fgetgitsrc()											    	    	###
### Get git source, not using repository, delete all nginx* folder  		###
###-------------------------------------------------------------------------###
FgetGitsrc()	{
	cd ${buildDir}
	rm nginx*
	case "$1" in
		gitdebian)
					git clone https://anonscm.debian.org/cgit/pkg-nginx/nginx.git ;;
		 gitnginx)
					git clone https://github.com/nginx/nginx ;;
	esac
}
###-------------------------------------------------------------------------###
### Fgetaptsrc()												    	    	###
### Get git source, not using repository, delete all nginx* folder  		###
###-------------------------------------------------------------------------###
Fgetaptsrc()	{
	cd ${buildDir}
	rm nginx*
	apt-get source nginx
}

###                                                               		    ###
###############################################################################



###############################################################################
### Fgetmodules		 										    	   		###
###	Download Modules                                                  	    ###
###-------------------------------------------------------------------------###
###                                                                  		###
Fgetmodules()
{
###-------------------------------------------------------------------------###
### Get Github Modules (development, non-release version)              		###
###-------------------------------------------------------------------------###
###                                                               		    ###
	cd ${buildDir}
	git clone https://github.com/simpl/ngx_devel_kit.git 
	git clone https://github.com/openresty/headers-more-nginx-module.git 
	git clone https://github.com/openresty/set-misc-nginx-module.git
	git clone https://github.com/vozlt/nginx-module-vts.git 
	git clone https://github.com/google/brotli.git 
	git clone https://github.com/bagder/libbrotli 	
	git clone https://github.com/google/ngx_brotli 
###-------------------------------------------------------------------------###
### Get Release Version,  										    		###
### Pagespeed, OpenSSL, PCRE, Zlib                                 	    	###
###-------------------------------------------------------------------------###
###         	                                                      	    ###
    cd ${buildDir}/sourceset-${sourceSet}
    wget -N https://github.com/pagespeed/ngx_pagespeed/archive/v${verPagespeed}.zip
    wget -N https://www.openssl.org/source/openssl-${verOpenssl}.tar.gz
	wget -N https://ftp.pcre.org/pub/pcre/pcre-${verPcre}.tar.gz
	wget -N https://www.zlib.net/zlib-${verZlib}.tar.gz 
    wget -N https://github.com/nbs-system/naxsi/archive/${verNaxsi}.tar.gz
###-------------------------------------------------------------------------###
### Download and decompress modules										    ###
### PCRE, OpenSSL, ZLib, Pagespeed, Naxsi	                         	    ###
###-------------------------------------------------------------------------###
###                                             	                  	    ###
	cd ${buildDir}/sourceset-${sourceSet}
	tar xvf openssl-${verOpenssl}.tar.gz --strip-components=1 -C ${buildDir}/packages/openssl
	tar xvf pcre-${verPcre}.tar.gz --strip-components=1 -C ${buildDir}/packages/pcre
	tar xvf zlib-${verZlib}.tar.gz --strip-components=1 -C ${buildDir}/packages/zlib
	tar xvf zlib-${verNaxsi}.tar.gz --strip-components=1 -C ${buildDir}/packages/naxsi
    unzip -o v${verPagespeed}.zip -d ${buildDir}
###                                                 	              	    ###
###-------------------------------------------------------------------------###
}
###                                                         	      	    ###
###############################################################################


###############################################################################
### Process Modules  										    	    	###
###                                                               	    	###
###-------------------------------------------------------------------------###
###                                                                  		###
processModules()
{
###-------------------------------------------------------------------------###
### Process and prepare modules									        	###
### Compile Brotli Module                                         	    	###
###-------------------------------------------------------------------------###
###                                                               	    	###
    cd ${buildDir}/brotli \
    python setup.py install
    cd ${buildDir}/libbrotli \
    ./autogen.sh \
    ./configure \
    make -j ${cpuCount} \
    make install
    cd ${buildDir}/ngx_brotli
    git submodule update --init
###-------------------------------------------------------------------------###
### Download and decompress modules										    ###
### Compile Pagespeed and PSOL Module   	                         	    ###
###-------------------------------------------------------------------------###
###                                             	                  	    ###
    cd ${buildDir}/
    cd ngx_pagespeed-${verPagespeed}
    export psol_url=https://dl.google.com/dl/page-speed/psol/${verPsol}.tar.gz
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
    wget ${psol_url}
    tar -xzvf $(basename ${psol_url})
###                                                 	              	    ###
###-------------------------------------------------------------------------###
}
###                                                         	      	    ###
###############################################################################


###############################################################################
### Fnginxcompile()  														###
### Compile Nginx                                                     		###
###-------------------------------------------------------------------------###
Fnginxcompile()
{
	cd ${buildDir}/nginx 
	apt-get build-dep nginx
#	dpkg-buildpackage -b
#	dpkg-buildpackage -uc -b
}
###                                                                   		###
###-------------------------------------------------------------------------###
###############################################################################


###############################################################################
### Fnginxconfigure()		     											###
### Configure Nginx                                                    		###
###-------------------------------------------------------------------------###
###                                                                  		###
Fnginxconfigure()
{
	dpkg --install nginx_1.11.2-1~xenial_amd64.deb
	apt-mark hold nginx
	dpkg --install nginx-module-geoip_1.11.2-1~xenial_amd64.deb
	apt-mark hold nginx-module-geoip
	
	rm -rf /etc/nginx/config/*.default
    rm /etc/nginx/nginx.conf
    rm /etc/nginx/fastcgi.conf
    rm /etc/nginx/fastcgi_params

	cp -R ${currentPath}/html/index.html /var/www/index.html
    cp -R ${currentPath}/nginx/* /etc/nginx
    cp -R ${currentPath}/systemd/nginx.service /lib/systemd/system/nginx.service
    chown -R www-data:www-data /var/www
	chown -R www-data:www-data /var/cache/nginx
	chown -R www-data:www-data /var/log/nginx
	
    systemctl enable nginx
    systemctl start nginx
}
###                                                                   		###
###-------------------------------------------------------------------------###
###############################################################################

###############################################################################
### Fremovenginx()													  	 	###
### Remove Nginx                                                   	    	###
###-------------------------------------------------------------------------###
Fremovenginx()	{
	apt-get -y remove nginx
	apt-get -y purge nginx
}
###                                                                   		###
###-------------------------------------------------------------------------###
###############################################################################

###############################################################################
### Fcleanup()					 									    	###
### Cleanup - Remove all repository                                	    	###
###-------------------------------------------------------------------------###
### There's no need to keep any repo since its only for compiling.     		###
### Once package build well, it is save to remove all nginx repo. 	    	###
###-------------------------------------------------------------------------###
Fcleanup()	{
    mv ${buildDir}/sourceset-${sourceSet} ${homeDir}
    rm -rf ${buildDir}
    add-apt-repository -r -y "deb ${repoNginx} ${linuxVer} nginx"
	add-apt-repository -r -y "deb-src ${repoNginx} ${linuxVer} nginx"
	add-apt-repository -r -y ppa:nginx/stable
	add-apt-repository -r -y ppa:nginx/development
	rm /etc/apt/preferences.d/nginx*
	apt-get update
}
###                                                                   		###
###-------------------------------------------------------------------------###
###############################################################################



###############################################################################
### Main program													    	###
###                                                               	    	###
###-------------------------------------------------------------------------###
### nginxsetup																###
### 															 	    	###
### 															 	    	###
###-------------------------------------------------------------------------###
### 0 delrepoAll, 1 addrepoLinux, 2 addrepoBackports, 						###
### 3 addrepoPpasta, 4 addrepoPpadev, 5 addrepoNginx, 6 gitdebian			###
### 7 gitnginx, 9 addrepoReview												###
###
#1	Choose action:
#	1) Download all repo, exit to review
#	2) Choose a repo, continue
#2 	Select Nginx repo to set:
#	1) Repo this Linux
#	2) Repo this Linux for Nginx
#	3) Repo Backports for Nginx
#	4) Repo PPA Nginx Stable
#	5) Repo PPA Nginx Development
#	6) Git Debian/Ubuntu for Nginx (no pkg, compile only)
#	7) Git Nginx for Debian/Ubuntu (no pkg, compile only)
#3	Choose action:
#	1) Install existing package, exit
#	2) Compile package, continue
#4	Select additional modules:
#	1) Add PageSpeed?
#	2) Add Brotli?
#	3) Add Naxsi?
#	4) Remove RTMP?
#cat rules, option to abort
#Next to compile
#	Save sourceset for backup?
#	Restore Repo?
#	Send package?
####### configurenginx -f
#	Uninstall all web server
#	Install nginx
#	Configure nginx?
# 	Install PHP?
#	Install Letsencrypt


while [ $# -gt 0 ]; do
  case "$1" in
	-h | --help     	This message.
	
	"-0") 	aptNginx delrepoAll
			apt-cache policy nginx
			exit 1	;;
	"-1") 	aptNginx addrepoLinux
			getAptsrc ;;
	"-2") 	aptNginx addrepoBackports
			getAptsrc ;;
	"-3") 	aptNginx addrepoPpasta
			getAptsrc ;;
	"-4") 	aptNginx addrepoPpadev
			getAptsrc ;;
	"-5") 	aptNginx addrepoNginx
			getAptsrc ;;
	"-6") 	aptNginx delrepoAll
			getGitsrc gitdebian ;;
	"-7") 	aptNginx delrepoAll
			getGitsrc gitnginx ;;
	"-9") 	aptNginx addrepoReview ;;
			#-----> always exit to view result.
-c | --compile		Compile package
-u | --uninstall	Uninstall existing web servers
-e | --erase		Erase before compile
-i | --install		Install & configure after compile
-d | --dry-run		Simulate, dry run only
-p | --pause		Interactive, sets of pause and questions
-b | --backupset	Backup current source set to compile later
-l | --listset		List backup source set
-g | --gendhparam	Generate dhparam
-s | --useset		Mark backup source set num to use\n
    -c|--conf)
              CONFFILE="$2"
              shift
              if [ ! -f $CONFFILE ]; then
                echo "Error: Supplied file doesn't exist!"
                exit $E_CONFFILE     # File not found error.
              fi
              ;;
			  

  esac
  shift       # Check next set of parameters.
done

setRepolinux
prepareOnce
###-------------------------------------------------------------------------###
getModules
processModules
nginxCompile
nginxConfigure
cleanup
### 															 	    	###
###-------------------------------------------------------------------------###
###############################################################################


###EOF
