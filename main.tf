
module "pi-hole" {
  source = "./modules/pi-hole"
}

module "vscode-server" {
  source = "./modules/vscode-server"
}

module "kubernetes" {
  source = "./modules/kubernetes"
}