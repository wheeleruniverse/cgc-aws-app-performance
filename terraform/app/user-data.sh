#!/bin/bash

# ___________________________________________________________
# update
sudo yum update -y

# ___________________________________________________________
# install
sudo amazon-linux-extras install -y nginx1
sudo amazon-linux-extras install -y postgresql11
sudo amazon-linux-extras install -y python3.8
sudo amazon-linux-extras install -y redis6

sudo yum install -y git

# ___________________________________________________________
# clone app
sudo git clone https://github.com/wheelers-websites/CloudGuruChallenge_21.06.git /opt/cgc/

# ___________________________________________________________
# nginx conf
sudo cp /opt/cgc/app/config/nginx-app.conf /etc/nginx/conf.d
sudo service nginx start

# ___________________________________________________________
# postgres conf
PGPASSWORD=<password> psql -h <hostname> -U <username> -f /opt/cgc/app/install.sql postgres

# ___________________________________________________________
# python conf
sudo pip3 install -r /opt/cgc/app/requirements.txt
