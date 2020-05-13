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
sudo yum install python-django -y
sudo yum -y install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql -e "CREATE DATABASE zippyops"
sudo mysql -e "CREATE USER zippyops@localhost IDENTIFIED BY 'zippyops';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zippyops.* TO 'zippyops'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

sudo yum groupinstall 'Development Tools' -y
sudo wget http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
sudo yum install mysql57-community-release-el7-9.noarch.rpm -y
sudo yum install mysql-community-server mysql-community-devel -y 
sudo yum install python-pip -y
pip install mysqlclient
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlvu4zNd+Ng4K5twKW3iaxvxXXD4pZ8iehQ8h+fDoDdEQIjV6pTfmTmFdYY1Ilt54ETvpvGSZkM3aPbqBX1HEmt3sc/JF8EjdQ63L0phhGnjulLeUIGCydNANZSedTfmcQ+llbaFIrhYNiKMOwkAARj8Sb3E1Y6ZsoUCGekPkDw8s1OlJEhIudxKT3Y7SsvCuP8aWgposC4DGBbBIIq+UipqBI0l6kOFB+fp8hPDY3x4AnrpxqeAgXKpTPYGP53z3vJF25l2K4s3+53mfy+c5c2NcoGxbE0hB1E5fWyaBun9vpRwtwGYBcmH+s0dDIWxR5P+5TsgJl7eO+kSLvDdPp jenkins@jenkins-cloud.novalocal" > /home/ec2-user/.ssh/authorized_keys
chmod 700 /home/ec2-user/.ssh
chmod 640 /home/ec2-user/.ssh/authorized_keys
 

