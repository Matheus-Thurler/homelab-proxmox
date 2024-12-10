resource "proxmox_vm_qemu" "vscode-server" {
  count = local.masters.count

  target_node = local.proxmox_node
  vmid        = local.masters.vmid_prefix + count.index
  name = format(
    "%s-%s",
    local.masters.name_prefix,
    count.index
  )

  onboot = local.onboot
  clone  = local.template
  agent  = local.agent

  cores   = local.masters.cores
  sockets = local.masters.sockets
  memory  = local.masters.memory

  ciuser  = local.cloud_init.user
  sshkeys = local.cloud_init.ssh_public_key
  ipconfig0 = format(
    "ip=%s/24,gw=%s",
    cidrhost(
      local.cidr,
      local.masters.network_last_octect + count.index
    ),
    cidrhost(local.cidr, 1)
  )

  network {
    id     = 0
    bridge = local.bridge.interface
    model  = local.bridge.model
  }

  scsihw = local.scsihw

  serial {
    id   = local.serial.id
    type = local.serial.type
  }

  disk {
    backup  = local.disks.cloudinit.backup
    format  = local.disks.cloudinit.format
    type    = local.disks.cloudinit.type
    storage = local.disks.cloudinit.storage
    slot    = local.disks.cloudinit.slot
  }

  disk {
    backup  = local.disks.main.backup
    format  = local.disks.main.format
    type    = local.disks.main.type
    storage = local.disks.main.storage
    size    = local.masters.disk_size
    slot    = local.disks.main.slot
    discard = local.disks.main.discard
  }

  tags = local.masters.tags

  connection {
    type        = "ssh"
    user        = local.cloud_init.user
    private_key = local.cloud_init.ssh_private_key
    host = cidrhost(
      local.cidr,
      local.masters.network_last_octect + count.index
    )
  }
  lifecycle {
    ignore_changes = [disk]
  }

  provisioner "remote-exec" {
    inline = [
      # "for i in {1..60}; do cloud-init status --wait && break || sleep 10; done",
      # "curl -fsSL https://get.docker.com -o get-docker.sh",
      # "sh get-docker.sh",
      # "sudo usermod -aG docker ${local.cloud_init.user}",
      # "sudo apt install docker-compose -y",
      # "mkdir -p /home/${local.cloud_init.user}/app",
      # "echo '${file("${path.cwd}/modules/pi-hole/docker/docker-compose.yml")}' > /home/${local.cloud_init.user}/app/docker-compose.yml",
      # "sudo systemctl stop systemd-resolved",
      # "sudo systemctl disable systemd-resolved",
      # "sudo systemctl restart docker",
      # "cd /home/${local.cloud_init.user}/app && sudo docker-compose up -d"
      # Aguardar o cloud-init terminar
    "for i in {1..60}; do cloud-init status --wait && break || sleep 10; done",

    # Instalar o Docker
    "curl -fsSL https://get.docker.com -o get-docker.sh",
    "sh get-docker.sh",
    "sudo usermod -aG docker ${local.cloud_init.user}",

    # Instalar o Docker Compose
    "sudo apt install docker-compose -y",

    # Criar diretório e configurar docker-compose.yml
    "mkdir -p /home/${local.cloud_init.user}/app",
    "echo '${file("${path.cwd}/modules/vscode-server/docker/docker-compose.yml")}' > /home/${local.cloud_init.user}/app/docker-compose.yml",
    "echo '${file("${path.cwd}/modules/vscode-server/docker/nginx.conf")}' > /home/${local.cloud_init.user}/app/nginx.conf",
    # Parar e desabilitar o systemd-resolved
    # "sudo systemctl stop systemd-resolved",
    # "sudo systemctl disable systemd-resolved",
    #
    # # Adicionar configuração DNS para Docker
    # "echo '{ \"dns\": [\"8.8.8.8\", \"8.8.4.4\"] }' | sudo tee /etc/docker/daemon.json",
    #
    # # Atualizar /etc/resolv.conf para usar DNS público
    # "echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' | sudo tee /etc/resolv.conf",

    # Reiniciar o Docker para aplicar as novas configurações
    # "sudo systemctl restart docker",

    # Subir os containers com Docker Compose
    "cd /home/${local.cloud_init.user}/app && sudo docker-compose up -d"
    ]
  }
}