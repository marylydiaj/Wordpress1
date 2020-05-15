#!/bin/bash
#usermod -a -G root ec2-user
sudo /bin/su - root
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git -y
sudo yum install wget -y
sudo yum install httpd -y
sudo systemctl start httpd && sudo systemctl enable httpd
sudo setenforce 0
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
sudo yum install php70w php70w-opcache php70w-mbstring php70w-gd php70w-xml php70w-pear php70w-fpm php70w-mysql php70w-pdo -y

sudo yum -y install mariadb-server
sudo systemctl start mariadb && sudo systemctl enable mariadb

#MySQL Consider changing values from drupaldb, drupaluser, and password
sudo echo "CREATE DATABASE zippyopsdb CHARACTER SET utf8 COLLATE utf8_general_ci;;" | mysql
sudo echo "CREATE USER 'zippyops'@'localhost' IDENTIFIED BY 'zippyops';" | mysql
sudo echo "GRANT ALL PRIVILEGES ON zippyopsdb.* TO 'zippyops'@'localhost';" | mysql
sudo echo "FLUSH PRIVILEGES;" | mysql
cd /root/
sudo git clone https://github.com/Ragu3492/wp-config.git

sudo cd /var/www/html

sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

sudo php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
sudo wp --info


cd /var/www/html
wp core download --allow-root
#wp config create --dbname=wordpress --dbuser=wordpress --dbpass=password --locale=ro_RO --allow-root
sudo cp /root/wp-config/wp-config.php /var/www/html/
ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
wp core install --url=$ip --title=zippyops --admin_user=zippyops --admin_password=zippyops --admin_email=admin@zippyops.com --allow-root
sudo chown -R apache /var/www/html
wp theme install Consulting --allow-root
wp theme activate consulting --allow-root

sudo systemctl restart httpd
