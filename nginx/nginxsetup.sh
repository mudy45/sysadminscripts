#!/usr/bin/env bash
#######################################################################
###                                                               	###
### 				SYSADMINUBUNTU / NGINXSETUP.SH 					###
###                 			@github                           	###
### 				  by mudy45 (mudy45@gmail.com)         			###
###                                                               	###
###-----------------------------------------------------------------###
###                                                               	###
###                                                               	###
### Fixed folder:                                                 	###
### Nginx User = www-data											###
### Nginx HTTP Folder = /var/www                                  	###
### Nginx Log Folder = /var/log/nginx                             	###
### Nginx Cache Folder = /var/cache/nginx                          	###
###                                                                	###
#######################################################################
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
doUbuntu = "1"
###-----> Choose one repo to use
useRepoppadev = "1"
useRepoppasta = "0"
useReponginx = "0"
useRepolinux = "0"

###-----> Run compile script here, delete everything for cleanup
buildDir = "/usr/local/src/buildnginx"
###-----> $buildDir/sourceset-$sourceset is where all source downloaded
###-----> change sourceSet number to create new source set
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

#######################################################################
### Prepare process													###
###                                                               	###
###-----------------------------------------------------------------###
prepareonce()
{
#######################################################################
### Check and Set Nginx User										###
###                                                               	###
###-----------------------------------------------------------------###
local nginxUserExists=$(id -u www-data > /dev/null 2>&1; echo $?)
if [ "${nginxUserExists}" != "0" ];
then
	useradd -d /etc/nginx -s /bin/false nginx
fi
#######################################################################
### Generate DHParam for Nginx OpemSSL								###
### Will take very long time   						               	###
###-----------------------------------------------------------------###
if [ "${doDhparam}" != "0" ];
then
	openssl dhparam -out ${dhparamFile} ${dhparamBits}
fi
###-----------------------------------------------------------------###
}
#######################################################################


#######################################################################
### Review Target & Repo for Nginx Package						  	###
###                                                               	###
###-----------------------------------------------------------------###
### http://nginx.org/en/download.html								###
### current stable		: nginx 1.12.1 & 1.13.3						###
###-----------------------------------------------------------------###
getnginxsource()
{
	if [ "${doUbuntu}" != "1" ];
	then
		linuxVer  = "xenial"
		repoNginx = "https://nginx.org/packages/ubuntu"
		repoLinux = "https://sgp1.digitalocean.com/ubuntu"
	else
		linuxVer  = "stretch-backports"
		repoNginx = "https://nginx.org/packages/debian/"
		repoLinux = "https://sgp1.digitalocean.com/debian"
	fi
###-----------------------------------------------------------------###
### Choose Ubuntu or Debian, run Review, fill table below, decide  	###
### your distro, target build, repo, check module, then compile.  	###
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
###                                                               	###
###-----------------------------------------------------------------###
	if [ "${doGetapt}" != "0" ];
	then
		wget -N https://nginx.org/keys/nginx_signing.key
		apt-key add nginx_signing.key
		rm nginx_signing.key
		cd ${buildDir}
		if [ "${useRepolinux}" != "0" ];
		then
			add-apt-repository -s -y "deb ${repoLinux} ${ubuntuVer} nginx"
			add-apt-repository -s -y "deb-src ${repoLinux} ${ubuntuVer} nginx"
		fi
		if [ "${useReponginx}" != "0" ];
		then
			add-apt-repository -s -y "deb ${repoNginx} ${ubuntuVer} nginx"
			add-apt-repository -s -y "deb-src ${repoNginx} ${ubuntuVer} nginx"
		fi
		if [ "${useRepoppasta}" != "0" ];
		then
			add-apt-repository -s -y ppa:nginx/stable
		fi
		if [ "${useRepoppadev}" != "0" ];
		then
		add-apt-repository -s -y ppa:nginx/development
		fi
		apt-get update
		apt-get upgrade
		###-----> Troubleshooting package missing stuff					###
		#apt-get install software-properties-common phyton-software-properties 
	fi
###-----------------------------------------------------------------###
}
#######################################################################



#######################################################################
### Choose Module Versions										 	###
###                                                               	###
###-----------------------------------------------------------------###
###                                                               	###
###                                                               	###
	###-----> 
	verOpenssl="1.0.2l"
	###-----> 
	verPagespeed="1.12.34.2"
	###-----> 
	pcreVers="8.40"
	###-----> 
	zlibVers="1.2.11"



#######################################################################
### Get and Prepare Modules										 	###
###                                                               	###
###-----------------------------------------------------------------###
###                                                               	###
###                                                               	###
getmodule()
{
	cd ${buildDir}
	###-----> https://github.com/nbs-system/naxsi/releases

	git clone https://github.com/nginx/nginx.git 
	git clone https://github.com/simpl/ngx_devel_kit.git 
	git clone https://github.com/openresty/headers-more-nginx-module.git 
	git clone https://github.com/vozlt/nginx-module-vts.git 
	git clone https://github.com/google/brotli.git 
	git clone https://github.com/bagder/libbrotli 	
	git clone https://github.com/google/ngx_brotli 
	git clone https://github.com/nbs-system/naxsi.git 
	git clone https://github.com/openresty/set-misc-nginx-module.git

#######################################################################
### Download and decompress modules									###
### PCRE, OpenSSL, ZLib                                           	###
###-----------------------------------------------------------------###
	cd ${buildDir}/sourceset-${sourceSet} \
	&& wget -N https://www.openssl.org/source/openssl-${openSslVers}.tar.gz \
	&& wget -N https://ftp.pcre.org/pub/pcre/pcre-${pcreVers}.tar.gz \
	&& wget -N http://www.zlib.net/zlib-${zlibVers}.tar.gz \
	&& tar xvf openssl-${openSslVers}.tar.gz --strip-components=1 -C ${buildDir}/packages/openssl \
	&& tar xvf pcre-${pcreVers}.tar.gz --strip-components=1 -C ${buildDir}/packages/pcre \
	&& tar xvf zlib-${zlibVers}.tar.gz --strip-components=1 -C ${buildDir}/packages/zlib
}


#######################################################################
### Download and decompress modules									###
### Compile Brotli Module                                         	###
###-----------------------------------------------------------------###
cd ${buildDir}/brotli \
&& python setup.py install
cd ${buildDir}/libbrotli \
&& ./autogen.sh \
&& ./configure \
&& make -j ${cpuCount} \
&& make install
cd ${buildDir}/ngx_brotli \
&& git submodule update --init




#######################################################################
### Compile Nginx													###
###                                                               	###
###-----------------------------------------------------------------###
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
                    --add-module=${buildDir}/ngx_pagespeed-${pagespeedVers} \
    && make -j ${cpuCount} \
    && make install
}


#######################################################################
### Configure Nginx													###
###                                                               	###
###-----------------------------------------------------------------###
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


#######################################################################
### Remove Nginx													###
###                                                               	###
###-----------------------------------------------------------------###
removeNginx()
{
	apt-get -y remove nginx
	apt-get -y purge nginx
}

#######################################################################
### Cleanup - Remove all repository									###
###                                                               	###
###-----------------------------------------------------------------###
### There's no need to keep any repo since its only for compiling. 	###
### Once package build well, it is save to remove all nginx repo. 	###
###-----------------------------------------------------------------###
cleanupRepo()
{
	add-apt-repository -r -y "deb ${repoNginx} ${ubuntuVer} nginx"
	add-apt-repository -r -y "deb-src ${repoNginx} ${ubuntuVer} nginx"
	add-apt-repository -r -y ppa:nginx/stable
	add-apt-repository -r -y ppa:nginx/development
	apt-get update
}



###EOF
