#!/bin/bash
sudo /bin/su - root
cd 
sudo git clone https://github.com/Ragu3492/xml.git
sudo cp /root/xml/zippyopssite.wordpress.2020-04-22.000.xml /var/www/html/
cd /var/www/html
wp import zippyopssite.wordpress.2020-04-22.000.xml --authors=create --allow-root

sudo systemctl restart httpd
