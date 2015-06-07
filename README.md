Magento Boilerplate
===================

Prerequisites (for default example settings)
-------------
* Database user "demo" (with password "demo") that is allowed to create a database called "demo"

```mysql
CREATE USER 'demo'@'localhost' IDENTIFIED BY 'demo'; 
GRANT USAGE ON *.* TO 'demo'@'localhost' IDENTIFIED BY 'demo'; GRANT ALL PRIVILEGES ON `demo`.* TO 'demo'@'localhost';
FLUSH PRIVILEGES;
```

* Configure webserver. (Webroot: /var/www/demo/htdocs, Url: http://www.demo.local)

Getting started manually
------------------------

This is how to set up a new Magento project:
```bash
git clone git@github.com:AOEpeople/Magento_Boilerplate.git /var/www/demo
cd /var/www/demo
tool/composer.phar install
sudo chown -R www-data:www-data /var/www/demo ; sudo chmod -R ug+rw /var/www/demo
# - Complete the installer in the frontend: http://www.demo.local (unless you already have a working database and app/etc/local.xml)
# - Go and insert the correct settings in Configuration/settings.csv now
# - Double check Boilerplate_Base/app/etc/local.xml.template (you might want to replace this file with your existing local.xml)
cd /var/www/demo/htdocs
../tools/modman deploy-all
../tools/apply.php devbox ../Configuration/settings.csv
```
