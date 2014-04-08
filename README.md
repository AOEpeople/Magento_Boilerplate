Magento Demo Project
====================

Prerequisites
-------------
* Database user "demo" (with password "demo") that is allowed to create a database called "demo"
```mysql
CREATE USER 'demo'@'localhost' IDENTIFIED BY 'demo'; 
GRANT USAGE ON *.* TO 'demo'@'localhost' IDENTIFIED BY 'demo'; GRANT ALL PRIVILEGES ON `demo`.* TO 'demo'@'localhost';
FLUSH PRIVILEGES;
```
* Configure webserver. (Webroot: /var/www/demo/htdocs, Url: http://www.demo.local)

Installation
------------
```bash
git clone git@github.com:AOEpeople/Magento_SampleProject.git /var/www/demo && /var/www/demo/install.sh
```