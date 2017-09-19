#!/usr/bin/env  bash

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
