#!/usr/bin/env bash
###############################################################################
###                                                               	        ###
###                    SYSADMINUBUNTU / NGINXSETUP.SH    	         	    ###
###                              by mudy45@github                           ###
###                                                                 	    ###
###                                                                     	###
### Maintaining a proper production Nginx webserver will be easier and   	###
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
### help()                                                             	    ###
### show usage info                                                    	    ###
###-------------------------------------------------------------------------###
###                                                                  	    ###
help() {
	[[ -n ${1} ]] && echo -e "** ${1}\n"
  	cat <<EOU
Compile Custom Nginx on ${buildDir}, save downloaded packages on 
${buildDir}/sourceset- ${sourceSet). COfiguration in the script.
-h | --help     	This message.
-9 | --view9		View all repo, add all repository then show available
					Nginx version. Usefull to decide which one to use.
					Remove added repo using -0.
-5 | --repo4		Compile using Nginx repo
-4 | --repo3		Compile using PPA stable repo
-3 | --repo3		Compile using PPA stable repo
-2 | --repo2		Compile using this backports repo
-1 | --repo1		Compile using this Linux repo (standard src)
-0 | --view0		Remove all Nginx repo, view, not compile, not upgrade.

-c | --compile		Configure compiled Nginx.
-f | --fastcomp 	Fast re-compile, not doing dhparam, no apt-get.
-e | --erase		Erase before compile.
-i | --intearctive	Interactive, sets of pause and questions
-r | --remove		Remove newly installed Nginx.
-u | --uninstall	Uninstall existing web servers.
-b | --backupset	Backup current source set to compile later.
-s | --compileset	Compile an existing backup set

Setup folder:                                                 	  
Nginx User & Group = www-data				                      
Nginx HTTP Folder  = /var/www                                  	  
Nginx Log Folder   = /var/log/nginx                           	  
Nginx Cache Folder = /var/cache/nginx                         	  

	EOU
 	exit
}

###############################################################################
### Choose Ubuntu or Debian, run Review, fill table below, decide  	    	###
### your distro, target build, repo, check module, then compile.  	   		###
###-------------------------------------------------------------------------###
### http://nginx.org/en/download.html					                	###
### current stable	: nginx 1.12.1 & 1.13.3				               		###
###-------------------------------------------------------------------------###
### 		Ubuntu 16.04 LTS Xenial					           		        ###
### Ubuntu Repo		: nginx 1.10.3-0ubuntu0.16.04.2		       	    	    ###
### PPA Repo		: nginx 1.13.4				   	        	            ###
### Nginx Repo		: nginx 1.12.1				   	    	                ###
### 		Ubuntu 16.10 Yaketty						                    ###
### Ubuntu Repo	 	: nginx 1.10.1-0ubuntu1.3			   	                ###
### PPA Repo	 	: 							                            ###
### Nginx Repo	 	:				         		                        ###
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
#---> TODO: function to automate distro name loading run here                                                             		
			doLinux       = "Ubuntu"       # Ubuntu or Debian
			linuxVer      = "xenial"       # Release Name
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
###                                                                 		###
### Module 		  : ngx_devel_kit											###
### Github		  : https://github.com/simpl/ngx_devel_kit.git 				###
###                                                                 		###
### Module 		  : headers-more-nginx-module								###
### Github		  : https://github.com/openresty/headers-more-nginx-module.git	###
###                                                                 		###
### Module 		  : set-misc-nginx-module									###
### Github		  : https://github.com/openresty/set-misc-nginx-module.git	###
###                                                                 		###
### Module 		  : nginx-module-vts										###
### Github		  : https://github.com/vozlt/nginx-module-vts.git 			###
###                                                                 		###
### Module 		  : Brotli - brotli.git										###
### Github		  : https://github.com/google/brotli.git 					###
###                                                                 		###
### Module 		  : Brotli - libbrotli										###
### Github		  : https://github.com/bagder/libbrotli			 			###
###                                                                 		###
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
### setRepolinux()	             							             	###
### using repo Ubuntu or Debian		                                       	###
###-------------------------------------------------------------------------###
###                                     	                          	    ###
setRepolinux()	{
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
### prepareOnce()						                 	            	###
### one time preparation, dhparam took long time            	         	###
###-------------------------------------------------------------------------###
###                                                               		    ###
prepareOnce()	{
###-------------------------------------------------------------------------###
### Check and Set Nginx User							                    ###
###-------------------------------------------------------------------------###
    local nginxUserExists=$(id -u www-data > /dev/null 2>&1; echo $?)
    if [ "${nginxUserExists}" != "0" ];
    then
	useradd -d /etc/nginx -s /bin/false nginx
    fi
###-------------------------------------------------------------------------###
### Generate DHParam for Nginx OpemSSL      	        					###
###-------------------------------------------------------------------------###
    if [ "${doDhparam}" != "0" ];
    then
	    openssl dhparam -out ${dhparamFile} ${dhparamBits}
    fi
###                                                     	          	    ###
###-------------------------------------------------------------------------###
}
###                                                         	      	    ###
###############################################################################


###############################################################################
### aptnginx()											               		###
### Nginx repo management                                          	  	    ###
###-------------------------------------------------------------------------###
###                                                               		    ###
aptnginx()	{
	wget -N https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	rm nginx_signing.key
	
	case "$1" in 
		addrepoLinux)
				add-apt-repository -s -y -u "deb ${repoLinux} ${ubuntuVer}-nginx" ;;
	addrepoBackports)
				add-apt-repository -s -y -u "deb ${repoLinux} ${ubuntuVer}-backports nginx" ;;
		addrepoNginx)
				add-apt-repository -s -y -u "deb ${repoNginx} ${ubuntuVer} nginx" ;;
       addrepoPpasta)
				add-apt-repository -s -y -u ppa:nginx/stable ;;
	   addrepoPpadev)
				add-apt-repository -s -y -u ppa:nginx/development ;;
 	   addrepoReview)
				add-apt-repository -y "deb ${repoLinux} ${ubuntuVer} nginx" \
				&& add-apt-repository -y "deb ${repoLinux} ${ubuntuVer}-backports nginx" \
				&& add-apt-repository -y "deb ${repoNginx} ${ubuntuVer} nginx" \
				&& add-apt-repository -y ppa:nginx/stable \
				&& add-apt-repository -y ppa:nginx/development \
				&& apt-get update
				apt-cache show nginx
				apt-cache policy nginx
				echo "Remove the repo using -0"
				exit 1 ;;
		  delrepoAll)
				add-apt-repository -r -y "deb ${repoLinux} ${ubuntuVer} nginx" \
				&& add-apt-repository -r -y "deb ${repoLinux} ${ubuntuVer}-backports nginx" \
				&& add-apt-repository -r -y "deb ${repoNginx} ${ubuntuVer} nginx" \
				&& add-apt-repository -r -y ppa:nginx/stable \
				&& add-apt-repository -r -y ppa:nginx/development \
				&& apt-get update ;;
	esac		  
###                                                               		    ###
###-----> Troubleshooting package missing stuff		           				###
	#apt-get install software-properties-common phyton-software-properties 
}
###                                                               		    ###
###############################################################################



###########################################################################
### Download Modules										    	    ###
###                                                               	    ###
###---------------------------------------------------------------------###
###                                                                  	###
getModules()
{
###---------------------------------------------------------------------###
### Get Github Modules (development, non-release version)               ###
###---------------------------------------------------------------------###
###                                                               	    ###
	cd ${buildDir}
	git clone https://github.com/simpl/ngx_devel_kit.git 
	git clone https://github.com/openresty/headers-more-nginx-module.git 
	git clone https://github.com/openresty/set-misc-nginx-module.git
	git clone https://github.com/vozlt/nginx-module-vts.git 
	git clone https://github.com/google/brotli.git 
	git clone https://github.com/bagder/libbrotli 	
	git clone https://github.com/google/ngx_brotli 
###---------------------------------------------------------------------###
### Get Release Version,  										    	###
### Pagespeed, OpenSSL, PCRE, Zlib                                 	    ###
###---------------------------------------------------------------------###
###                                                               	    ###
    cd ${buildDir}/sourceset-${sourceSet}
    wget -N https://github.com/pagespeed/ngx_pagespeed/archive/v${verPagespeed}.zip
    wget -N https://www.openssl.org/source/openssl-${openSslVers}.tar.gz
	wget -N https://ftp.pcre.org/pub/pcre/pcre-${pcreVers}.tar.gz
	wget -N http://www.zlib.net/zlib-${zlibVers}.tar.gz 
    wget -N https://github.com/nbs-system/naxsi/archive/${verNaxsi}.tar.gz
###---------------------------------------------------------------------###
### Download and decompress modules									    ###
### PCRE, OpenSSL, ZLib, Pagespeed, Naxsi                         	    ###
###---------------------------------------------------------------------###
###                                                               	    ###
	cd ${buildDir}/sourceset-${sourceSet}
	tar xvf openssl-${verOpenssl}.tar.gz --strip-components=1 -C ${buildDir}/packages/openssl
	tar xvf pcre-${verPcre}.tar.gz --strip-components=1 -C ${buildDir}/packages/pcre
	tar xvf zlib-${verZlib}.tar.gz --strip-components=1 -C ${buildDir}/packages/zlib
	tar xvf zlib-${verNaxsi}.tar.gz --strip-components=1 -C ${buildDir}/packages/naxsi
    unzip -o v${verPagespeed}.zip -d ${buildDir}
###                                                               	    ###
###---------------------------------------------------------------------###
}
###                                                               	    ###
###########################################################################


###########################################################################
### Process Modules  										    	    ###
###                                                               	    ###
###---------------------------------------------------------------------###
###                                                                  	###
processModules()
{
###---------------------------------------------------------------------###
### Process and prepare modules									        ###
### Compile Brotli Module                                         	    ###
###---------------------------------------------------------------------###
###                                                               	    ###
    cd ${buildDir}/brotli \
    python setup.py install
    cd ${buildDir}/libbrotli \
    ./autogen.sh \
    ./configure \
    make -j ${cpuCount} \
    make install
    cd ${buildDir}/ngx_brotli
    git submodule update --init
###---------------------------------------------------------------------###
### Download and decompress modules									    ###
### Compile Pagespeed and PSOL Module                            	    ###
###---------------------------------------------------------------------###
###                                                               	    ###
    cd ${buildDir}/
    cd ngx_pagespeed-${verPagespeed}
    export psol_url=https://dl.google.com/dl/page-speed/psol/${verPsol}.tar.gz
    [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
    wget ${psol_url}
    tar -xzvf $(basename ${psol_url})
###                                                               	    ###
###---------------------------------------------------------------------###
}
###                                                               	    ###
###########################################################################


###########################################################################
### Compile Nginx    													###
###                                                                   	###
###---------------------------------------------------------------------###
nginxCompile()
{
cd ${buildDir}/nginx \
&& ./auto/configure --prefix=/etc/nginx \
                    --sbin-path=/usr/sbin/nginx \
                    --conf-path=/etc/nginx/nginx.conf \
                    --lock-path=/etc/nginx/lock/nginx.lock \
                    --pid-path=/etc/nginx/pid/nginx.pid \
                    --error-log-path=/var/log/nginx/error.log \
                    --http-log-path=/var/log/nginx/access.log \
                    --http-client-body-temp-path=/var/cache/nginx/client \
                    --http-proxy-temp-path=/var/cache/nginx/proxy \
                    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi \
                    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi \
                    --http-scgi-temp-path=/var/cache/nginx/scgi \
                    --user=www-data \
                    --group=www-data \
                    --with-poll_module \
                    --with-threads \
                    --with-file-aio \
                    --with-http_ssl_module \
                    --with-http_v2_module \
                    --with-http_realip_module \
                    --with-http_addition_module \
                    --with-http_xslt_module \
                    --with-http_image_filter_module \
                    --with-http_sub_module \
                    --with-http_dav_module \
                    --with-http_flv_module \
                    --with-http_mp4_module \
                    --with-http_gunzip_module \
                    --with-http_gzip_static_module \
                    --with-http_auth_request_module \
                    --with-http_random_index_module \
                    --with-http_secure_link_module \
                    --with-http_degradation_module \
                    --with-http_slice_module \
                    --with-http_stub_status_module \
                    --with-stream \
                    --with-stream_ssl_module \
                    --with-stream_realip_module \
                    --with-stream_geoip_module \
                    --with-stream_ssl_preread_module \
                    --with-google_perftools_module \
                    --with-pcre=${buildDir}/packages/pcre \
                    --with-pcre-jit \
                    --with-zlib=${buildDir}/packages/zlib \
                    --with-openssl==${buildDir}/packages/openssl \
                    --add-module==${buildDir}/naxsi/naxsi_src \
                    --add-module==${buildDir}/ngx_devel_kit \
                    --add-module==${buildDir}/nginx-module-vts \
                    --add-module==${buildDir}/ngx_brotli \
                    --add-module==${buildDir}/headers-more-nginx-module \
                    --add-module==${buildDir}/set-misc-nginx-module \
                    --add-module=${buildDir}/ngx_pagespeed-${pagespeedVers}
#    make -j ${cpuCount}
	cd ${buildDir}/nginx
	apt-get source nginx
	apt-get build-dep nginx
	dpkg-buildpackage -b
	dpkg-buildpackage -uc -b
}
###                                                                   	###
###---------------------------------------------------------------------###
###########################################################################


###########################################################################
### Configure Nginx			     										###
###                                                                  	###
###---------------------------------------------------------------------###
###                                                                  	###
nginxConfigure()
{
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
###                                                                   	###
###---------------------------------------------------------------------###
###########################################################################
dpkg --install nginx_1.11.2-1~xenial_amd64.deb
apt-mark hold nginx
dpkg --install nginx-module-geoip_1.11.2-1~xenial_amd64.deb
apt-mark hold nginx-module-geoip

###########################################################################
### Remove Nginx													    ###
###                                                               	    ###
###---------------------------------------------------------------------###
removeNginx()
{
	apt-get -y remove nginx
	apt-get -y purge nginx
}
###                                                                   	###
###---------------------------------------------------------------------###
###########################################################################

###########################################################################
### Cleanup - Remove all repository									    ###
###                                                               	    ###
###---------------------------------------------------------------------###
### There's no need to keep any repo since its only for compiling.     	###
### Once package build well, it is save to remove all nginx repo. 	    ###
###---------------------------------------------------------------------###
cleanup()
{
    mv ${buildDir}/sourceset-${sourceSet} ${homeDir}
    rm -rf ${buildDir}
    add-apt-repository -r -y "deb ${repoNginx} ${ubuntuVer} nginx"
	add-apt-repository -r -y "deb-src ${repoNginx} ${ubuntuVer} nginx"
	add-apt-repository -r -y ppa:nginx/stable
	add-apt-repository -r -y ppa:nginx/development
	apt-get update
}
###                                                                   	###
###---------------------------------------------------------------------###
###########################################################################

###########################################################################
### Main program													    ###
###                                                               	    ###
###---------------------------------------------------------------------###
### 															     	###
### 															 	    ###
###---------------------------------------------------------------------###
setRepolinux
prepareOnce
###---------------------------------------------------------------------###
### 0 delrepoAll, 1 addrepoLinux, 2 addrepoBackports, 					###
### 3 addrepoPpasta, 4 addrepoPpadev, 5 addrepoNginx, 9 addrepoReview	###
case $1 in
	"-0") aptnginx delrepoAll ;;
	"-1") aptnginx addrepoLinux ;;
	"-2") aptnginx addrepoBackports ;;
	"-3") aptnginx addrepoPpasta ;;
	"-4") aptnginx addrepoPpadev ;;
	"-5") aptnginx addrepoNginx ;;
	"-9") aptnginx addrepoReview ;;
esac
###---------------------------------------------------------------------###
getModules
processModules
nginxCompile
nginxConfigure
cleanup
### 															 	    ###
###---------------------------------------------------------------------###
###########################################################################


###EOF
