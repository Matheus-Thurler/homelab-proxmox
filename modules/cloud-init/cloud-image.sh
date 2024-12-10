#!/bin/bash

# Caminho do arquivo ISO
ISO_PATH="/tmp/noble-server-cloudimg-amd64.img"

# Verifica se a ISO já foi baixada
if [ ! -f "$ISO_PATH" ]; then
  echo "A ISO não foi encontrada. Baixando..."
  wget -O "$ISO_PATH" https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
else
  echo "A ISO já foi baixada."
fi

# Instalar dependências necessárias
echo "Instalando dependências..."
apt-get update && apt-get install -y libguestfs-tools

# Customização da imagem
echo "Customizando a imagem com o qemu-guest-agent..."
virt-customize --add "$ISO_PATH" --install qemu-guest-agent

# Criar a VM com as configurações iniciais
echo "Criando a VM..."
qm create 9001 --name ubuntu-2404-cloud-init --numa 0 --ostype l26 --cpu cputype=host --cores 2 --sockets 1 --memory 2048 --net0 virtio,bridge=vmbr0

# Importar o disco para o armazenamento local-lvm
echo "Importando o disco para o armazenamento local-lvm..."
qm importdisk 9001 "$ISO_PATH" local-lvm

# Obter o nome do disco importado
DISK_NAME="local-lvm:vm-9001-disk-0"

# Associar o disco à VM
echo "Associando o disco à VM..."
qm set 9001 --scsihw virtio-scsi-pci --scsi0 "$DISK_NAME"

# Adicionar uma pausa para garantir que a configuração seja aplicada
sleep 5

# Verificar se o disco foi associado antes de redimensionar
if qm config 9001 | grep -q "scsi0"; then
  echo "Disco associado com sucesso. Redimensionando para +30GB..."
  qm disk resize 9001 scsi0 +30G
else
  echo "Erro: o disco não foi associado corretamente. Verifique o processo de importação."
  exit 1
fi

# Configurações adicionais
echo "Aplicando configurações adicionais..."
qm set 9001 --ide2 local-lvm:cloudinit,media=cdrom
qm set 9001 --boot c --bootdisk scsi0
qm set 9001 --serial0 socket --vga serial0
qm set 9001 --agent enabled=1

# Criar a VM como template
echo "Convertendo a VM para template..."
qm template 9001

echo "Template criado com sucesso! ID: 9001"
