#!/bin/bash

read -p $'\e[1;44m Type in your domain name: （e.g. www.abc.com, then type in abc.com）\e[0m' domainName
read -p $'\e[1;43m Type in your email address: \e[0m' emailAddress

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

php_config_file_folder="/etc/php/7.2/apache2"
php_config_file_path="/etc/php/7.2/apache2/php.ini"

sudo apt install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-mysql php7.2-gmp php7.2-curl php7.2-intl php7.2-mbstring php7.2-xmlrpc php7.2-gd php7.2-bcmath php7.2-soap php7.2-ldap php7.2-imap php7.2-xml php7.2-cli php7.2-zip -y

sudo chmod -R 777 $php_config_file_folder
sed -i "s/file_uploads =.*/file_uploads = On/" $php_config_file_path
sed -i "s/allow_url_fopen =.*/allow_url_fopen = On/" $php_config_file_path
sed -i "s/short_open_tag =.*/short_open_tag = On/" $php_config_file_path
sed -i "s/memory_limit =.*/memory_limit = 256M/" $php_config_file_path
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 100M/" $php_config_file_path
sed -i "s/max_execution_time =.*/max_execution_time = 360/" $php_config_file_path
sed -i "s/date.timezone =.*/date.timezone = Hong Kong/" $php_config_file_path
sudo chmod -R 755 $php_config_file_folder

sudo systemctl restart apache2.service


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
