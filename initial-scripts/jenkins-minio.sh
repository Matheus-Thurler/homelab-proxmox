#!/bin/bash

IP=192.168.0.108
SSH_KEY="/home/matheus/.ssh/matheus/id_rsa"
TERRAFORM="../../homelab-proxmox/"

#zip -r homelab.zip $TERRAFORM

scp -i $SSH_KEY ./Dockerfile ubuntu@$IP:/home/ubuntu/
scp -i $SSH_KEY ./docker-compose.yml ubuntu@$IP:/home/ubuntu/
#scp -i $SSH_KEY ./homelab.zip ubuntu@$IP:/home/ubuntu/



#scp -i $SSH_KEY homelab.zip ubuntu@$IP:/home/ubuntu/

ssh -i $SSH_KEY ubuntu@$IP "sudo apt install unzip docker.io docker-compose -y"
ssh -i $SSH_KEY ubuntu@$IP "unzip homelab.zip"
ssh -i $SSH_KEY ubuntu@$IP "sudo docker-compose up -d"
ssh -i $SSH_KEY ubuntu@$IP "sleep 10"
ssh -i $SSH_KEY ubuntu@$IP "echo 'Retrive jenkins password' && sudo docker exec -i jenkins cat /var/jenkins_home/secrets/initialAdminPassword"

