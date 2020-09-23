variable "profile" {
  	description = "Virtual Server Instance Profile"
  	default = "bx2-32x128"
}

variable "resource_group_name" {
	description = "To organize your account resources in customizable groupings"
        default = "default"
}

variable "vpc_name" {
	description = "VPC Name"
        default = "ocp45-vpc-gen2"
}

variable "basename" {
  	description = "Prefix used for all resource names"
  	default = "ocp45-vpc-gen2-basename"
}

variable "subnet_zone" {
	description = "Prefix used for all resource names"
 	default = "eu-de-1"
}

variable "region" {
	description = "Region to deploy VPC"
 	default = "eu-de"
}

variable "ssh_keyname" {
	description = "SSH Keyname to allow access to VSI"
  	default = "ssh-key-ocp45-name"
}

variable "image" {
        description = "VSI Image"
	default = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

variable "volume_name" {
	description = "OCP4.5 Block Storage"
}

variable "ocp43-domain-name" {
	description = "ENTER Domain Name"
	}

variable "ocp43-cluster-name" {
	description = "ENTER Cluster Name"
	}

variable "ssh_public_key" {
        description = "SSH public key"
        default = "ssh-key-ocp45"
}

