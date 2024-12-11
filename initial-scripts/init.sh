#!/usr/bin/bash

#YOUR PROXMOX IP
IP=192.168.0.10

#MY RANGE IP TO CREATE NEW VM
# 192.168.0.100
JENKINS_MINIO_IP=192.168.0.108
GW=192.168.0.1
VM_NAME="jenkins-minio"

SSH_KEY="/home/matheus/.ssh/matheus/id_rsa"
PROXMOX_PASS="matheus"



sshpass -p 'matheus' scp -i $SSH_KEY cloud-init.sh root@$IP:/tmp
sshpass -p 'matheus' scp -i $SSH_KEY id_rsa.pub root@$IP:/tmp
sshpass -p 'matheus' ssh -i $SSH_KEY root@$IP "cd /tmp && chmod +x ./cloud-init.sh && ./cloud-init.sh"

sshpass -p 'matheus' ssh -i $SSH_KEY root@$IP "qm clone 9001 100 --name $VM_NAME && qm set 100 --net0 virtio,bridge=vmbr0 && qm set 100 --ipconfig0 ip=192.168.0.108/24,gw=192.168.0.1 && qm start 100"

sleep 180

# CREATING VM JENKINS MINIO
./jenkins-minio.sh
