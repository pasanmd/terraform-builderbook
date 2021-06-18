provider "aws" {
        version    = "~> 2.0"
        access_key = var.access_key
        secret_key = var.secret_key
        region     = var.region
}
# create an instance
resource "aws_instance" "linux_instance" {
  ami             = lookup(var.amis, var.region)
  subnet_id       = var.subnet
  security_groups = var.securityGroups
  key_name        = var.keyName
  instance_type   = var.instanceType
  # Let's create and attach an ebs volume
  ebs_block_device {
    device_name = "/dev/xvdb"
    volume_type = "gp2"
    volume_size = 8
  }
  # Name the instance
  tags = {
    Name = var.instanceName
  }

  volume_tags = {
    Name = var.instanceName
  }
  # Copy in the bash script we want to execute.
  provisioner "file" {
    source      = "~/setup-builderbook"
    destination = "/tmp/setup-builderbook"
  }
  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-builderbook",
      "sudo /tmp/setup-builderbook",
    ]
  }
  # Login to the ec2-user with the aws key.
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = ""
    private_key = file(var.keyPath)
    host        = self.public_ip
  }
}
