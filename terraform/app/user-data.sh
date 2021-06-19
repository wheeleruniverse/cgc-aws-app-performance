#!/bin/bash

# ___________________________________________________________
# variables
CACHE_URL=cache
DB_HOST=host
DB_NAME=name
DB_PASS=pass
DB_USER=user

# ___________________________________________________________
# update
sudo yum update -y

# ___________________________________________________________
# install
sudo amazon-linux-extras install -y epel
sudo amazon-linux-extras install -y nginx1
sudo amazon-linux-extras install -y postgresql11
sudo amazon-linux-extras install -y python3.8
sudo amazon-linux-extras install -y redis6

sudo yum install -y gcc
sudo yum install -y git
sudo yum install -y libpq-dev
sudo yum install -y postgresql-devel
sudo yum install -y python3-devel
sudo yum install -y python3-pip
sudo yum install -y python3-setuptools

# ___________________________________________________________
# clone app
sudo git clone https://github.com/wheelers-websites/CloudGuruChallenge_21.06.git /opt/cgc/

# ___________________________________________________________
# database ini conf

echo "[postgres]" > /opt/cgc/app/config/database.ini
echo "database=${DB_NAME}" >> /opt/cgc/app/config/database.ini
echo "host=${DB_HOST}" >> /opt/cgc/app/config/database.ini
echo "password=${DB_PASS}" >> /opt/cgc/app/config/database.ini
echo "user=${DB_USER}" >> /opt/cgc/app/config/database.ini
echo "" >> /opt/cgc/app/config/database.ini
echo "[redis]" >> /opt/cgc/app/config/database.ini
echo "url=${CACHE_URL}" >> /opt/cgc/app/config/database.ini

# ___________________________________________________________
# nginx conf
sudo cp /opt/cgc/app/config/wheeler-cgc2106-nginx.conf /etc/nginx/conf.d
sudo service nginx start

# ___________________________________________________________
# postgres conf
PGPASSWORD=${DB_PASS} psql -h ${DB_HOST} -U ${DB_USER} -f /opt/cgc/app/install.sql ${DB_NAME}

# ___________________________________________________________
# python conf
sudo pip3 install -r /opt/cgc/app/requirements.txt
