#!/bin/bash

# ___________________________________________________________
# variables
AWS_ACCESS_KEY="aws-access-key"
AWS_SECRET_KEY="aws-secret-key"
DB_PASS="password"
PREFIX="wheeler-cgc2106-"

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
sudo yum install -y jq
sudo yum install -y libpq-dev
sudo yum install -y postgresql-devel
sudo yum install -y python3-devel
sudo yum install -y python3-pip
sudo yum install -y python3-setuptools

# ___________________________________________________________
# aws cli
aws configure set aws_access_key_id ${AWS_ACCESS_KEY}
aws configure set aws_secret_access_key ${AWS_SECRET_KEY}

CACHE_URL=$(aws elasticache describe-cache-clusters \
--region us-east-1 \
--cache-cluster-id "${PREFIX}cache" \
--show-cache-node-info \
--query "CacheClusters[*].CacheNodes[0].Endpoint.Address" \
--output json | jq --raw-output .[])

RDS=$(aws rds describe-db-instances \
--region us-east-1 \
--db-instance-identifier "${PREFIX}db" \
--query "DBInstances[*].{host: Endpoint.Address, name: DBName, user: MasterUsername}" \
--output json | jq .[])

DB_HOST=$(echo ${RDS} | jq --raw-output .host)
DB_NAME=$(echo ${RDS} | jq --raw-output .name)
DB_USER=$(echo ${RDS} | jq --raw-output .user)

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
echo "url=redis://${CACHE_URL}" >> /opt/cgc/app/config/database.ini

# ___________________________________________________________
# nginx conf
sudo cp "/opt/cgc/app/config/${PREFIX}nginx.conf" "/etc/nginx/conf.d/"
sudo service nginx start
sudo service nginx status

# ___________________________________________________________
# postgres conf
PGPASSWORD="${DB_PASS}" psql -h "${DB_HOST}" -U "${DB_USER}" -f /opt/cgc/app/install.sql "${DB_NAME}"

# ___________________________________________________________
# python conf
sudo pip3 install -r /opt/cgc/app/requirements.txt

# ___________________________________________________________
# run app
cd /opt/cgc/app/
gunicorn -D app:app
