mkdir -p /var/cache/nginx && chown -cR nginx:root /var/cache/nginx

 perl -00 -ple 's{$}{ \\\n\t\t\t--add-module=\$(MODULESDIR)/ngx_pagespeed} if m/common_configure_flags :=/' rules > nu
 
 sed -r '
    # when the line ends with a backslash
    # add the new line with a backslash
    /\$\(common_configure_flags\)[[:blank:]]*\\$/ a\
                    --add-module=$(MODULESDIR)/ngx_pagespeed \\

    # when the line does not end with a backslash,
    # add a backslash, then
    # add the new line without a backslash
    /\$\(common_configure_flags\)[[:blank:]]*$/ {
            s/$/ \\/
            a\
                    --add-module=$(MODULESDIR)/ngx_pagespeed
    }
' file

sed '/_configure_flags *:=/ a\
                    --add-module=$(MODULESDIR)/ngx_pagespeed \\
' file

sed -i '/fastcgi_read_timeout 60;/ a\
include /etc/nginx/sites-directives/*.conf;' /etc/nginx/sites-available/VIRTUALSERVER_DOM

sed -i -e '/## START UPSTREAM/,/## END UPSTREAM/{//!d;/## START UPSTREAM/r /etc/nginx/upstream.conf' -e '}' /etc/nginx/nginx.conf
