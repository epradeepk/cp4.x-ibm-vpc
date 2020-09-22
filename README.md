# Single Virtual Server Instance deployment of OCP 4.x on IBM Cloud VPC-GEN 2 
(Terraform + Ansible)


## Overview

Use this automation to install OpenShift Container Platform (OCP) 4.x on Virtual Private Cloud (VPC) Infrastructure Gen2 in IBM Cloud using Terraform CLI.  The OCP 4.x will be installed and configured with security groups, on a single large Virtual Server Instance (VSI) with multiple Virtual Machine(VM) partitions.

Refer to `Usage` section below for more details about the installation information.

**NOTE** 
Use ONLY for the purpose of Proof of Concept(PoC) or as your Development environment. It does not support High Availability, hence - is not recommended for Production environment usage. 

## Architecture

A VPC, VSI (referred to as `base VSI`), Subnets, Floating-IP on `VPC-Gen 2` is provisioned with the required [resource configurations](https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html#minimum-resource-requirements_installing-bare-metal) as illustrated in the figure, for installing OCP 4.x. 
In addition, a Block Storage is provisioned and attached to the `base VSI`.

![reference solution](https://github.com/epradeepk/ocp4.x-ibm-vpc/blob/master/diagrams/overall_design.png) <br>
(the text in `orange` color is used as resource-names in the terraform / ansible template)

Refer to [OpenShift Container Platform 4.5](https://docs.openshift.com/container-platform/4.5/welcome/index.html) for more details about the OCP 4.x infrastructure design.

### ocp4.x-vsi (base VSI) design
Multiple VMs (refered to as `ocp VMs`) are provisioned in the `base VSI` to deploy the OCP bootstrap, masters and workers.  The automation is configured to provision 
* one temporary bootstrap 
* three masters, and 
* two workers. 

![reference solution](https://github.com/epradeepk/ocp4.x-ibm-vpc/blob/master/diagrams/basevm.png)

Additional components deployed in the `base VSI` are as follows:

| Component         | Description                                                       |
|-------------------|-------------------------------------------------------------------|
| KVM               | Kernel Based Virtual Machine, the virtualization layer technolgy used to provide the VMs on the bare metal host.   <br> Reponsible for managing the `ocp VMs` |
| DNSMasq           | Combines a DNS forwarder, DHCP server and network boot features that enable new VMs to obtain IP addresses, and load operating systems from a PXE server, and provide DNS services to external and internal addresses. 
| iPXE              | Implementation of the Preboot eXecution Environment that allows operating systems to be installed via the network.  <br> Used to create the `ocp VMs`               |
| Matchbox          | A service that matches machine profiles to network boot configurations. This is how a new VM request knows which OS to request the ignition and other setup resources.              |
| HAProxy         | A load balancer |


---

## Prerequisites

* Ansible version 2.9.9
* jsbeautifier
* Red Hat subscription to [download the pull secret](https://cloud.redhat.com/openshift/install/metal)
* [IBM Cloud account](https://cloud.ibm.com) (to provision resources on IBM Cloud VPC Gen2)
* Using terraform to provision `base VSI`
  1. IBM Cloud provider [plugin for Terraform](https://github.com/IBM-Cloud/terraform-provider-ibm/releases)
  2. Terraform Command Line Interface (CLI) (Refer to Annexure section for detailed installation steps)
* Domain registration and configuration in IBM Cloud
  1. [Registering a new domain](https://cloud.ibm.com/docs/dns?topic=dns-register-a-new-domain)
     Or an existing domain can be used
  2. [Configuring DNS records](https://cloud.ibm.com/docs/cis?topic=cis-set-up-your-dns-for-cis)

      | Record Type | Host Value         |  Points to             |
      |-------------|--------------------|------------------------|
      | A           | mycluster          | xxx.xxx.xxx.xxx        |
      | CNAME       | *.apps.mycluster   | mycluster.example.com  |
      | CNAME       | api.mycluster      | mycluster.example.com  |
      | CNAME       | api-int.mycluster  | mycluster.example.com  |


## Usage

The OCP 4.x installation on `IBM Cloud VPC Gen2` includes below steps <br>
1. Set up `base VSI` 
2. Install OCP 4.x on `base VSI`

### 1. Set up `base VSI` 
Install the prerequisites, clone this GitHub Repo to your local system (directory: `<BASE-DIRECTORY>/ocp4.x-ibm-vpc`) and create a `base VSI` using below steps. As an alternative, if you want to use an existing `base VSI`, you can move to `Annexure` - `Install OCP 4.x on an existing base VSI` section for the installation steps.

#### Inputs

When you are creating the `base VSI`, you must enter the following values as inputs:

  * `ssh_public_key` : Enter a public ssh key (that you want use to access your `base VSI`) in `ssh_public_key` file
  * `ibmcloud_api_key:` Enter the API key to access IBM Cloud VPC Gen2 infrastructure using command
    ```export IC_API_KEY=<API-KEY-VALUE>``` on command line interface terminal
    For more information for how to create an API key and retrieve it, see [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/iam?topic=iam-classic_keys)
  * `Volume name`: Enter the desired Block Storage Volume name
  * `Cluster name`: Enter the desired Cluster name 
  * `Domain name`: Enter the desired Domain name
  * `Pull Secret`: Enter Pull Secret key in `pull_secret` file. Get it from Red Hat website as explained in Prerequisites
  
You can also choose to customize the default settings for your `base VSI`:

| Name               | Description                         | Default Value |
| -------------------| ------------------------------------|----------------
| region             | Region to deploy VPC                | eu-de
| subnet zone        | Zone name where OCP 4.x will be deployed| eu-de-1
| resource group name | To organize your account resources in customizable groupings | default
| vpc_name           | VPC Name                            | ocp4.x-vpc
| basename           | Prefix used for all resource names  | ocp4.x-vpc-basename
| ssh_keyname        | SSH Keyname to allow access to `base VSI` | ssh-key-name

The `base VSI` profile is set to bx2-32x128 as per the [OCP4.x infrastructure requirments]https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html)

#### Execution 

Run the following Terraform commands from `<BASE-DIRECTORY>/ocp4.x-ibm-vpc/terraform` directory on your local system, to provision the infrastructure on IBM Cloud VPC Gen2 with `base VSI`. 

  ```
  terraform init
  terraform plan
  terraform apply
  ```

#### Output
The `base VSI` resources can be seen using below command

  ```
  terraform show
  ```

### 2. Install OCP 4.x on `base VSI`
Run Ansible commands to install OCP 4.x on `base VSI` that is created using above step #1 `Set up base VSI`.

#### Input
Run `fdisk -l` on `base VSI`, get the block storage disk path (example: /dev/vdd) and assign it to the variable `block_storage` in`<BASE-DIRECTORY>/ocp4.x-ibm-vpc/ansible/group_vars/all` file. By default its been set to /dev/vdd.

#### Execution 
Run the following Ansible commands from `<BASE-DIRECTORY>/ocp4.x-ibm-vpc/ansible` directory on your local system, to install OCP 4.x on `base VSI`. 

  ```
  ansible-playbook -i hosts ocp4xinstall.yaml
  ```

#### Output
The output of above Ansible command will provide the link to OCP 4.x website along with user name and password. Using this information user can login to OCP 4.x.

Example output where the OCP 4.x access information is provided: <br>
  ```
  .......
  .......
  INFO Access the OpenShift web-console here: https://console-openshift-console.apps.ocp43vm.alchemy-ocp-test.com 
  INFO Login to the console with user: kubeadmin, password: AVtx-C8CsL-LL6E-EDX 
  ```

## OCP 4.x Console
---
![reference solution](https://github.com/epradeepk/ocp4.x-ibm-vpc/blob/master/diagrams/OCP4.5_Console.png)


---
 
## OCP 4.x Dashboard
---
![reference solution](https://github.com/epradeepk/ocp4.x-ibm-vpc/blob/master/diagrams/OCP4.5_Dashboard.png)

---

## Troubleshooting

### Known Issues

1. The OCP 4.x Console not accessible <br>
Try: Restart dnsmasq using `systemctl restart dnsmasq` from `base VSI`

2. All `ocp VMs` are not up and running: master/worker types <br>
Try: Run the command `oc get csr` to get a list of pending resources and approve them by running `oc adm certificate approve`


## Destroying the deployed Infrastructure and OCP 4.x

#### Using Terraform CLI
Using below command the provisioned `base VSI` can be destroyed

  ```terraform destroy```

## References

https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html

## Annexure

### Terrform CLI Installation
* Download and install [Terraform for your system](https://learn.hashicorp.com/terraform/getting-started/install.html)
* Unzip the release archive to extract the plugin binary (terraform-provider-ibm_vX.Y.Z).
* Move the binary into the Terraform plugins directory for the platform.
    * Linux/Unix/OS X: ~/.terraform.d/plugins

### Install OCP 4.x on an existing `base VSI`
The existing `base VSI` should have been created as per the [OCP 4.x configuration requirements](https://docs.openshift.com/container-platform/4.5/installing/installing_bare_metal/installing-bare-metal.html) in `IBM VPC Gen2`. 

#### Inputs
- Add floating IP of the `base VSI` to `<BASE-DIRECTORY>/ocp4.x-ibm-vpc/ansible/hosts` file. <br>
- Assign Cluster name, Domain name, Pull Secret and SSH Public Key values to the corresponding variable names in`<BASE-DIRECTORY>/ocp4.x-ibm-vpc/ansible/group_vars/all` file
- Run `fdisk -l` on `base VSI`, get the block storage disk path (example: /dev/vdb) and assign it to the variable `block_storage` in`<BASE-DIRECTORY>/ocp4.x-ibm-vpc/ansible/group_vars/all` file.


#### Execution 
Run the following Ansible commands from `<BASE-DIRECTORY>/ocp4.x-ibm-vpc/ansible` directory on your local system, to install OCP 4.x on `base VSI` 

  ```
  ansible-playbook -i hosts ocp4xinstall.yaml
  ```

#### Output
The output of above Ansible command will provide the link to OCP 4.x website along with user name and password. Using this information user can login to OCP 4.x.

Example output where the OCP 4.x access information is provided: <br>
  ```
  .......
  .......
  INFO Access the OpenShift web-console here: https://console-openshift-console.apps.ocp43vm.alchemy-ocp-test.com 
  INFO Login to the console with user: kubeadmin, password: AVtx-C8CsL-LL6E-EDX 
  ```





