#!/bin/sh
# Region in Which instance is running
EC2_REGION='eu-west-1'
MAX_WAIT=3

#Instance ID captured through Instance meta data
InstanceID=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)

#Elastic IP captured through the EIP instance tag
#Elastic_IP=$(aws ec2 describe-addresses --region eu-west-1 --filters "Name=tag:Name,Values=bastion-eip" --output text | head -1 | cut -f10)

Elastic_IP=__ELASTIC_IP_BASTION__
Allocate_ID=$(aws ec2 describe-addresses --region eu-west-1 --filters "Name=tag:Name,Values=bastion-eip" --output text | head -1 | cut -f2)
ISFREE=$(aws ec2 describe-addresses --allocation-ids "$Allocate_ID" --query Addresses[].InstanceId --output text --region $EC2_REGION)
STARTWAIT=$(date +%s)

if [ ! -z "$ISFREE" ]; then
    #Disassociate Elastic IP
    aws ec2 disassociate-address --public-ip "$Elastic_IP" --region $EC2_REGION
fi

while [ ! -z "$ISFREE" ]; do
    if [ "$(($(date +%s) - $STARTWAIT))" -gt $MAX_WAIT ]; then
        echo "WARNING: We waited 30 seconds, we're forcing it now."
        ISFREE=""
    else
        echo "Waiting for EIP with Allocate_ID [$Allocate_ID] to become free...."
        sleep 3
        ISFREE=$(aws ec2 describe-addresses --allocation-ids "$Allocate_ID" --query Addresses[].InstanceId --output text --region $EC2_REGION)
    fi
done

echo "Assigning EIP to Instance"
#Assigning Elastic IP to Instance
aws ec2 associate-address --instance-id "$InstanceID" --allocation-id "$Allocate_ID" --region $EC2_REGION