locals {
  # global configurations
  agent        = 1
  cidr         = "192.168.0.100/24"
  onboot       = true
  proxmox_node = "homelab"
  scsihw       = "virtio-scsi-pci"
  template     = "ubuntu-2404-cloud-init"

  bridge = {
    interface = "vmbr0"
    model     = "virtio"
  }
  disks = {
    main = {
      backup  = true
      format  = "raw"
      type    = "disk"
      storage = "local-lvm"
      slot    = "scsi0"
      discard = true
    }
    cloudinit = {
      backup  = true
      format  = "raw"
      type    = "cloudinit"
      storage = "local-lvm"
      slot    = "ide2"
    }
  }
  # serial is needed to connect via WebGUI console
  serial = {
    id   = 0
    type = "socket"
  }

  # cloud init information to be injected
  cloud_init = {
    user           = "ubuntu"
    password       = "ubuntu"
    ssh_public_key = file("/home/matheus/.ssh/matheus/id_rsa.pub")
    ssh_private_key = file("/home/matheus/.ssh/matheus/id_rsa")
  }

  masters = {
    # how many nodes?
    count = 1

    name_prefix = "k8s-master-youtube"
    vmid_prefix = 400

    # hardware info
    cores     = 2
    disk_size = "50G"
    memory    = 2048
    sockets   = 1

    # 192.168.0.7x and so on...
    network_last_octect = 130
    tags                = "masters"
  }

  # worker specific configuration
  workers = {
    count = 1

    name_prefix = "k8s-worker-youtube"
    vmid_prefix = 500

    cores     = 1
    disk_size = "50G"
    memory    = 2048
    sockets   = 1

    network_last_octect = 140
    tags                = "workers"
  }
}