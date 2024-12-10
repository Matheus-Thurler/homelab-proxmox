module "base-template" {
  source = "./modules/cloud-init"
}

module "pi-hole" {
  source = "./modules/pi-hole"
}

module "vscode-server" {
  source = "./modules/vscode-server"
}