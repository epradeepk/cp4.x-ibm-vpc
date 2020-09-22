provider "ibm" {
  generation       = 2
  region = "${var.region}"
}

# Module to create Infrastructure
module ocp43 {
  source              = "modules/"
  basename            = "${var.basename}"
  resource_group_name = "${var.resource_group_name}"
  vpc_name = "${var.vpc_name}"
  subnet_zone = "${var.subnet_zone}"
  ssh_keyname = "${var.ssh_keyname}"
  image		= "${var.image}"
  profile	= "${var.profile}",
  volume_name = "${var.volume_name}",
  ocp43-domain-name = "${var.ocp43-domain-name}",
  ssh_public_key = "${file("ssh_public_key")}"
}

output "ocp4x-base-vm" {
 value = "${module.ocp43.floating_ip_address}"
}

output "ocp4x-cluster-name" {
 value = "${var.ocp43-cluster-name}"
}

output "ocp4x-domain-name" {
 value = "${var.ocp43-domain-name}"
}

output "ocp4x-pull-secret" {
 value = "${file("pull_secret")}"
}

output "ocp4x-ssh-public-key" {
 value = "${file("ssh_public_key")}"
}

