#!/bin/bash

PREFIX="wheeler-cgc2106-"
VPC_ID=$(aws ec2 describe-vpcs \
--region us-east-1 \
--filter "Name=tag:Name,Values=${PREFIX}vpc" \
--query Vpcs[].VpcId \
--output text)

PRIVATE_SGS=$(aws ec2 describe-security-groups \
--region us-east-1 \
--filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${PREFIX}private*" \
--query "SecurityGroups[*].GroupId" \
--output json | jq -c .)

PUBLIC_SGS=$(aws ec2 describe-security-groups \
--region us-east-1 \
--filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${PREFIX}public*" \
--query "SecurityGroups[*].GroupId" \
--output json | jq -c .)

PRIVATE_SUBNETS=$(aws ec2 describe-subnets \
--region us-east-1 \
--filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${PREFIX}private*" \
--query "Subnets[*].SubnetId" \
--output json | jq -c .)

PUBLIC_SUBNETS=$(aws ec2 describe-subnets \
--region us-east-1 \
--filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${PREFIX}public*" \
--query "Subnets[*].SubnetId" \
--output json | jq -c .)

echo "sg = {"
echo "  private = ${PRIVATE_SGS}"
echo "  public  = ${PUBLIC_SGS}"
echo "}"
echo "subnet = {"
echo "  private = ${PRIVATE_SUBNETS}"
echo "  public  = ${PUBLIC_SUBNETS}"
echo "}"
