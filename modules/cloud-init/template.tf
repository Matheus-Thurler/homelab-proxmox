resource "null_resource" "ssh_exec" {
  connection {
    type        = "ssh"
    host        = "192.168.0.10"
    user        = "root"
    password = "matheus"
  }

  provisioner "remote-exec" {
    script = "${path.module}/cloud-image.sh"
  }
}