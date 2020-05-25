# AutoLAMP
Auto deploy LAMP on server.

## Brief Introduction
I am a primary school computer teacher and a part-time developer.
I often show my students how to use cloud, Google Cloud is my first choice.
For work reasons, I often build instance and setup LAMP.
The steps are too many.
I decided to write a script to help me.
After one day work, I wrote 2 scripts, one for building Google Cloud instance, another for installing LAMP environment.

## How to use?
In initialisation.sh, there are two parts.
Copy the first part and paste into Google Cloud Shell, CreateGoogleCloudInstance.sh will be downloaded and be executed. It will guide you to select PROJECT, REGION, ZONE, type in NAME, so to build an instance. 
HTTP and HTTPS ports will be opened.

SSH the instance, copy the second part and paste into it, ubuntu_18.04.sh will download and be executed. It will ask you type in your Domain Name, and Email Address for CerBot (which will make your domain be visited only through Port 443 in HTTPS way.)

## What dose this make happened?
It will auto install:
1. Apache2
1. MariaDB
1. PHP7
1. expect
1. CerBot

It will also:
1. allow Apache Full and OpenSSH into ufw
1. execute mysql_secure_installation
1. move index.php to the 1st in /etc/apache2/mods-available/dir.conf
1. build a virtual host for your domain
1. secure Apache with Cerbot

## How to use?

## Hope you like it!
