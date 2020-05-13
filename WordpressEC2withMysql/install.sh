#!/bin/bash
#usermod -a -G root ec2-user
if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi
sleep 5
sudo amazon-linux-extras install epel -y
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
cd
git clone https://github.com/Ragu3492/wp-config.git
cd /var/www/html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp --info
cd /var/www/html
wp core download --allow-root
#wp config create --dbname=zippyopsdb --dbuser=zippyops --dbpass=zippyops --locale=ro_RO --allow-root
cp /root/wp-config/wp-config.php /var/www/html/
ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
wp core install --url=$ip --title=zippyops --admin_user=zippyops --admin_password=zippyops --admin_email=admin@zippyops.com(opens in new tab)(opens in new tab) --allow-root
sudo chown -R apache /var/www/html
#wp theme install Consulting --allow-root
#wp theme activate consulting --allow-root
wp plugin install wordpress-importer --activate --allow-root
cd
endpoint=`aws rds --region us-east-1 describe-db-instances --query "DBInstances[*].Endpoint.Address"`
echo >file $endpoint
sed -i 's/[][]//g' /root/file
sed -i 's/"//g' /root/file
sed -i 's/ //g' /root/file
endpoint=$(<file)
echo $endpoint
git clone -b deploy --single-branch https://github.com/marylydiaj/zippyops_wordpress.git
sudo cp /root/zippyops_wordpress/zippyopssite.wordpress.2020-04-22.000.xml /var/www/html/
cd /var/www/html
wp theme install Consulting --allow-root
wp theme activate consulting --allow-root
wp import zippyopssite.wordpress.2020-04-22.000.xml --authors=create --allow-root
mysql -u zippyops -pzippyops -h $endpoint --database zippyops < wordpressdb.sql
systemctl restart httpd
