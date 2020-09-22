variable "profile" {
  	description = "Virtual Server Instance Profile"
  	#default = "cc1-2x4"
  	default = "bx2-2x8"
}

variable "resource_group_name" {
	description = "To organize your account resources in customizable groupings"
        default = "default"
}

variable "vpc_name" {
	description = "VPC Name"
        default = "tf-vpc2-ocp43-vpc-auto2"
}

variable "basename" {
  	description = "Prefix used for all resource names"
  	default = "tf-vpc2-ocp43-auto2"
}

variable "subnet_zone" {
	description = "Prefix used for all resource names"
 	default = "eu-de-1"
	#default = "us-south-1"
}

variable "region" {
	description = "Region to deploy VPC"
 	default = "eu-de"
}

variable "ssh_keyname" {
	description = "SSH Keyname to allow access to VSI"
  	default = "ssh-key-ocp43"
}

variable "image" {
        description = "VSI Image"
	default = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable "volume_name" {
	description = "Block Storage"
}

variable "ocp43-domain-name" {
	description = "ENTER Domain Name"
	}

variable "ocp43-cluster-name" {
	description = "ENTER Cluster Name"
	}

variable "ssh_public_key" {
        description = "SSH public key"
        default = "ssh-key-ocp43-auto"
}

