#!/bin/bash

read -p $'\e[1;44m请输入域名: （例如：www.abc.com，就输入abc.com）\e[0m' domainName
read -p $'\e[1;44m请输入电子邮箱: \e[0m' emailAddress

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

sudo apt install php libapache2-mod-php php-mysql -y
sudo cp /etc/apache2/mods-enabled/dir.conf /etc/apache2/mods-en
abled/dir.conf.bak

sudo chmod 777 /etc/apache2/mods-available/dir.conf
sudo echo '<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet' > /etc/apache2/mods-available/dir.conf
sudo chmod 644 /etc/apache2/mods-available/dir.conf

sudo mkdir /var/www/$domainName
sudo chown -R $USER:$USER /var/www/$domainName
sudo chmod -R 755 /var/www/$domainName


#sudo echo "<html>
#    <head>
#        <title>Welcome to $domainName\!</title>
#    </head>
#    <body>
#        <h1>Success\!  The $domainName server block is working\!</h1>
#    </body>
#</html>" > /var/www/$domainName/index.html


sudo chmod 777 /etc/apache2/sites-available
sudo echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $domainName
    ServerAlias www.$domainName
    DocumentRoot /var/www/$domainName
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/$domainName.conf
sudo chmod 755 /etc/apache2/sites-available

sudo a2ensite $domainName.conf

sudo add-apt-repository ppa:certbot/certbot -y
sudo apt install python-certbot-apache -y

START_CERBOT=$(expect -c "
set timeout 20
spawn sudo certbot --apache -d $domainName -d www.$domainName
expect \"Enter email address (used for urgent renewal and security notices) (Enter 'c' to
cancel):\"
send \"$emailAddress\r\"
expect \"(A)gree/(C)ancel:\"
send \"a\r\" 
expect \"(Y)es/(N)o:\"
send \"y\r\"
expect \"Select the appropriate number \[1-2\] then \[enter\] (press 'c' to cancel):\"
send \"2\r\"
expect eof
")

echo "$START_CERBOT"
