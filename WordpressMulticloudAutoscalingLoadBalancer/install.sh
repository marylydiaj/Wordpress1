 #!/bin/bash
 if [ "$(whoami)" != "root" ]
then
    sudo su -s "$0"
    exit
fi
sleep 5
sudo amazon-linux-extras install epel -y
sudo yum install epel-release -y
sudo yum install git -y
sudo yum update -y
sudo yum install ufw -y
sudo yum install python-django -y
sudo yum -y install mariadb-server -y
sudo yum groupinstall 'Development Tools' -y
sudo wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
sudo yum install mysql57-community-release-el7-9.noarch.rpm -y
sudo yum install mysql-community-server mysql-community-devel -y 
sudo yum install python-pip -y
pip install mysqlclient
echo yes | ufw enable
ufw allow 3306
ufw allow 22
ufw allow 8000
sudo systemctl start mysqld
sudo systemctl enable mysqld
cd /home/ec2-user
git clone -b branchPy https://github.com/GodsonSibreyan/Godsontf.git
cd /home/ec2-user/Godsontf


endpoint=`aws rds --region us-east-1 describe-db-instances --query "DBInstances[*].Endpoint.Address"`
echo >file $endpoint
sed -i 's/[][]//g' /home/ec2-user/Godsontf/file
sed -i 's/"//g' /home/ec2-user/Godsontf/file
sed -i 's/ //g' /home/ec2-user/Godsontf/file
endpoint=$(<file)
echo $endpoint

sed -i "s/localhost/$endpoint/g" /home/ec2-user/Godsontf/python_webapp_django/settings.py
mysql --defaults-extra-file=mysql -h $endpoint zippyops < zippyops.sql
chmod 755 manage.py
python manage.py migrate
nohup ./manage.py runserver 0.0.0.0:8000 &
