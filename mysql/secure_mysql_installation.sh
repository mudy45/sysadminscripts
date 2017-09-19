#!/bin/bash

mysql -bse "DELETE FROM mysql.user WHERE User='';"
mysql -bse "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -bse "DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';"
#mysqladmin -bp -u root password
mysql -bse "FLUSH PRIVILEGES"

