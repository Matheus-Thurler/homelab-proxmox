#!/bin/bash

cd /tmp || exit || return
# Path to the ISO file
ISO_PATH="/tmp/noble-server-cloudimg-amd64.img"
STORAGE="local-lvm"

# Check if the ISO has already been downloaded
if [ ! -f "$ISO_PATH" ]; then
  echo "The ISO was not found. Downloading..."
  wget -O "$ISO_PATH" https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
else
  echo "The ISO has already been downloaded."
fi

# Install necessary dependencies
echo "Installing dependencies..."
apt-get update && apt-get install -y libguestfs-tools

# Customize the image
echo "Customizing the image with qemu-guest-agent..."
virt-customize --add "$ISO_PATH" --install qemu-guest-agent

# Create the VM with initial configurations
echo "Creating the VM..."
qm create 9001 --name ubuntu-2404-cloud-init --numa 0 --ostype l26 --cpu cputype=host --cores 2 --sockets 1 --memory 2048 --net0 virtio,bridge=vmbr0

# Import the disk to the $STORAGE storage
echo "Importing the disk to $STORAGE storage..."
qm importdisk 9001 "$ISO_PATH" $STORAGE

# Get the name of the imported disk
DISK_NAME="$STORAGE:vm-9001-disk-0"

# Attach the disk to the VM
echo "Attaching the disk to the VM..."
qm set 9001 --scsihw virtio-scsi-pci --scsi0 "$DISK_NAME"

# Add a pause to ensure the configuration is applied
sleep 5

# Verify if the disk was attached before resizing
if qm config 9001 | grep -q "scsi0"; then
  echo "Disk successfully attached. Resizing to +30GB..."
  qm disk resize 9001 scsi0 +30G
else
  echo "Error: The disk was not attached correctly. Please check the import process."
  exit 1
fi

# Additional configurations
echo "Applying additional configurations..."
qm set 9001 --ide2 $STORAGE:cloudinit,media=cdrom
qm set 9001 --boot c --bootdisk scsi0
qm set 9001 --serial0 socket --vga serial0
qm set 9001 --agent enabled=1
qm set 9001 --ipconfig0 ip=dhcp
qm set 9001 --ciuser ubuntu --cipassword ubuntu
qm set 9001 --sshkey ./id_rsa.pub


# Convert the VM to a template
echo "Converting the VM to a template..."
qm template 9001

echo "Template successfully created with DHCP enabled! ID: 9001"
