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
