#!/bin/bash

sudo apt update
sudo apt install apache2 -y
sudo apt install expect -y

sudo ufw allow in "Apache Full"
sudo ufw allow in "OpenSSH"

ufw_status=$(echo $(sudo ufw status | grep Status))
if [ "$ufw_status" = "Status: inactive" ]
then
  echo "y" | sudo ufw enable
else
  echo "ufw enabled already"
fi

sudo apt install mariadb-server -y


SECURE_MYSQL=$(expect -c "
set timeout 2
spawn sudo mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Set root password?\"
send \"n\r\" 
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

sudo apt remove expect -y

sudo apt install php libapache2-mod-php php-mysql -y
sudo cp /etc/apache2/mods-enabled/dir.conf /etc/apache2/mods-en
abled/dir.conf.bak

sudo chmod 777 /etc/apache2/mods-available/dir.conf
sudo echo '<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet' > /etc/apache2/mods-available/dir.conf
sudo chmod 644 /etc/apache2/mods-available/dir.conf

export httpRuleName="http-server"

gcloud compute instances add-tags $instanceName \
--zone $zoneName \
--tags $httpRuleName
