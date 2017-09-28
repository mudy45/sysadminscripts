mkdir -p /var/cache/nginx && chown -cR nginx:root /var/cache/nginx

 perl -00 -ple 's{$}{ \\\n\t\t\t--add-module=\$(MODULESDIR)/ngx_pagespeed} if m/common_configure_flags :=/' rules > nu
