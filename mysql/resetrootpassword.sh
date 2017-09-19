#!/usr/bin/env  bash

systemctl stop mysql

mysqld_safe --skip-grant-tables &

MariaDB [(none)]> use mysql;
MariaDB [mysql]> UPDATE user SET password=PASSWORD("new_password") WHERE User='root';
MariaDB [mysql]> FLUSH PRIVILEGES;
MariaDB [mysql]> quit;




