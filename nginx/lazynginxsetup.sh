#!/usr/bin/env  bash
###############################################################################
### 	                                                         	    ###
###                   LAZYSERVERADMIN / LASYNGINXSETUP.SH 	            ###
###                             by mudy45@github                            ###
###                                                                 	    ###
### Why bother compiling. They wouldn't know any way, only for installing   ###
### wordpress. Lazy admin will use this script to prevent typing more than  ###
### necessary.                                                              ###
###                                                                         ###
###-------------------------------------------------------------------------###
###                                                                         ###
### License	    : GNU General Public License version 3        	    ###
### Copyright   : Mudy Situmorang (mudy45@gmail.com)                        ###
### Tested OS	: Ubuntu 16.04.3 LTS Xenial                                 ###
### Github      : https://github.com/mudy45/sysadminscripts    	            ###
### Version     : 0.1 alpha --> WARNING: DO NOT USE !!!!                    ###
### File        : /nginx/lazynginxsetup.sh                                  ###
### Release	: Not Available   	                                    ###
### Update      : 20170920                                                  ###
###                                                                         ###
###############################################################################
#gpg --keyserver keyserver.ubuntu.com --recv-keys 005E81F4
#gpg --no-default-keyring -a --export 005E81F4 | gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import -

#apt-get install dpkg-dev unzip
#apt-get update
#apt-cache policy nginx
echo "NGINX"

builddir="/home/dom/lazybuildnginx"
rm -rf ${builddir}
mkdir ${builddir}
cd ${builddir}
apt-get source nginx
cd nginx-*/
nginxdir=${PWD##*/}
echo "nginxdir: $nginxdir"
vernginx=`echo $nginxdir|grep -Eo '[0-9]+.[0-9]+.[0-9]+'`
modulesdir="$builddir/$nginxdir/debian/modules"
echo "vernginx: $vernginx"
echo "builddir: $builddir"
echo "modulesdir: $modulesdir"
echo "PAGESPEED"
verpagespeed="1.11.33.4-beta"
verpsol="1.11.33.4"
# verpagespeed=`wget -qO- --no-check-certificate https://github.com/pagespeed/ngx_pagespeed/releases | \
# sed -n 's|.*/archive/\(.*\).tar.gz.*|\1|p' | awk '{ print $1; exit }'`
# verpsol=`echo ${verpagespeed} | sed 's/[[:alpha:]|(|[:space:]]//g' | \
# awk -F- '{print $1}'`
echo "PageSpeed $verpagespeed || PSOL: $verpsol"
wget https://github.com/pagespeed/ngx_pagespeed/archive/v${verpagespeed}.tar.gz -O ngx_pagespeed-${verpagespeed}.tar.gz \
&& mkdir ${modulesdir}/ngx_pagespeed \
&& tar -xzf ngx_pagespeed-${verpagespeed}.tar.gz --strip-components=1 -C ${modulesdir}/ngx_pagespeed
###-----> get psol
wget https://dl.google.com/dl/page-speed/psol/${verpsol}.tar.gz -O psol-${verpsol}.tar.gz \
&& tar -xzf psol-${verpsol}.tar.gz -C ${modulesdir}/ngx_pagespeed

#psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
#echo $psol_url
#---> insert pagespeed build in rules
#"		--add-module=$(MODULESDIR)/ngx_pagespeed"
###-----> Naxsi vernaxsi = 0.55.3 
echo "NAXSI" 
vernaxsi=`wget -qO- --no-check-certificate https://github.com/nbs-system/naxsi/releases | sed -n 's|.*/archive/\(.*\).tar.gz.*|\1|p' | awk '{ print $1; exit}'`
echo -e "NAXSI module version: ${vernaxsi} should be 0.55.3"
wget --no-check-certificate https://github.com/nbs-system/naxsi/archive/${vernaxsi}.tar.gz -O naxsi-${vernaxsi}.tar.gz \
&& mkdir ${modulesdir}/naxsi \
&& tar -xzf naxsi-${vernaxsi}.tar.gz --strip-components=1 -C ${modulesdir}/naxsi 


#---> insert naxsi build in rules " --add-module=$(MODULESDIR)/naxsi"




#apt-get install nginx

### EOF
