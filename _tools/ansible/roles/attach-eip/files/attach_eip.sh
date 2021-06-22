#!/bin/sh
# Region in Which instance is running
EC2_REGION=${1:-'eu-west-1'}
MAX_WAIT=3

#Instance ID captured through Instance meta data
INSTANCEID=$(/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id)

#Elastic IP captured through the EIP instance tag
#ELASTIC_IP=$(aws ec2 describe-addresses --region eu-west-1 --filters "Name=tag:Name,Values=bastion-eip" --output text | head -1 | cut -f10)

ELASTIC_IP=__ELASTIC_IP_BASTION__
ALLOCATE_ID=$(aws ec2 describe-addresses --region ${EC2_REGION} --filters "Name=tag:Name,Values=bastion-eip" --output text | head -1 | cut -f2)
ISFREE=$(aws ec2 describe-addresses --allocation-ids "${ALLOCATE_ID}" --query Addresses[].INSTANCEID --output text --region $EC2_REGION)
STARTWAIT=$(date +%s)

if [ ! -z "$ISFREE" ]; then
    #Disassociate Elastic IP
    aws ec2 disassociate-address --public-ip "$ELASTIC_IP" --region ${EC2_REGION}
fi

while [ ! -z "$ISFREE" ]; do
    if [ "$(($(date +%s) - $STARTWAIT))" -gt $MAX_WAIT ]; then
        echo "WARNING: We waited 30 seconds, we're forcing it now."
        ISFREE=""
    else
        echo "Waiting for EIP with ALLOCATE_ID [$ALLOCATE_ID] to become free...."
        sleep 3
        ISFREE=$(aws ec2 describe-addresses --allocation-ids "$ALLOCATE_ID" --query Addresses[].INSTANCEID --output text --region $EC2_REGION)
    fi
done

echo "Assigning EIP to Instance"
#Assigning Elastic IP to Instance
aws ec2 associate-address --instance-id "$INSTANCEID" --allocation-id "$ALLOCATE_ID" --region ${EC2_REGION}