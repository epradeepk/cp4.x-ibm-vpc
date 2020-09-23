resource "ibm_is_public_gateway" "ocp43pgw" {
  count = "1"
  vpc   = "${ibm_is_vpc.ocp43vpc.id}"
  name  = "${var.basename}-${var.subnet_zone}-pubgw"
  zone  = "${var.subnet_zone}"
}

resource "ibm_is_volume" "ocp43vol2" {
  name     = "${var.volume_name}"
  profile  = "custom"
  zone     = "${var.subnet_zone}"
  iops     = 1000
  capacity = 1000
}

resource "ibm_is_subnet" "ocp43subnet" {
  name                     = "${var.basename}-subnet"
  vpc                      = "${ibm_is_vpc.ocp43vpc.id}"
  zone                     = "${var.subnet_zone}"
  public_gateway           = "${join("", ibm_is_public_gateway.ocp43pgw.*.id)}"
  total_ipv4_address_count = 256
}

data "ibm_resource_group" "group" {
  name = "${var.resource_group_name}"
}

data ibm_is_image "image1" {
 name = "${var.image}" 
}

resource "ibm_is_vpc" "ocp43vpc" {
  name = "${var.vpc_name}"
  resource_group = "${data.ibm_resource_group.group.id}"
}

resource "ibm_is_ssh_key" "sshkey" {
    name = "${var.ssh_keyname}"
    public_key = "${file("ssh_public_key")}"
}

resource ibm_is_security_group "ocp43sg" {
  name = "${var.basename}-ocp43sg"
  vpc  = "${ibm_is_vpc.ocp43vpc.id}"
}

resource ibm_is_instance "ocp43vsi" {
  name           = "${var.basename}-ocp43vsi"
  vpc            = "${ibm_is_vpc.ocp43vpc.id}"
  zone           = "${var.subnet_zone}"
  keys           = ["${ibm_is_ssh_key.sshkey.id}"]
  image          = "${data.ibm_is_image.image1.id}"
  profile        = "${var.profile}"
  volumes 	 = ["${ibm_is_volume.ocp43vol2.id}"]
  resource_group = "${data.ibm_resource_group.group.id}"

  primary_network_interface = {
    subnet          = "${ibm_is_subnet.ocp43subnet.id}"
    security_groups = ["${ibm_is_security_group.ocp43sg.id}"]
  }
}

resource ibm_is_floating_ip "ocp43fip" {
  name   = "${var.basename}-ocp43fip"
  target = "${ibm_is_instance.ocp43vsi.primary_network_interface.0.id}"
}

output sshcommand {
  value = "ssh root@${ibm_is_floating_ip.ocp43fip.address}"
}

resource "ibm_is_security_group_rule" "ocp45_ingress_rule" {
  group     = "${ibm_is_security_group.ocp43sg.id}"
  direction = "inbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_security_group_rule" "ocp45_outgress_rule" {
  group     = "${ibm_is_security_group.ocp43sg.id}"
  direction = "outbound"
  remote    = "0.0.0.0/0"
}
