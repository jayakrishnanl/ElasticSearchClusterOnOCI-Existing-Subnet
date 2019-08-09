
# Deploy ElasticSearch Cluster On your existing Regional Private Subnet on OCI

This module deploys ElastiSearch Cluster on your existing Regional Private Subnet. The nodes will be deployed across the available ADs. You can specifiy the required number of Master and Data nodes. 

## Acknowledgement: 
Folks who contributed with code, feedback, ideas, testing etc:
-  Jeet Jagasia

## Pre-requisites
1. [Download and install Terraform](https://www.terraform.io/downloads.html) (v0.11.8 or later v0.11.X versions)

2. Export OCI credentials using guidance at [Export Credentials](https://www.terraform.io/docs/providers/oci/index.html).
You must use an Admin User account to launch this terraform environment. You may update the credentials in env-vars.sh file and run it to set environment variables for this setup.

3. The tenancy used for provisoning must have service limits increased to accomodate the build. 

Refer the link [here](https://github.com/oracle/oci-quickstart-prerequisites) for detailed instructions on setting up terraform.

4. Create or chose existing Regional Public Subnet where Bastion and Regional Private Subnet where ES Master and Data nodes are to be launched. 

5. Tag (freeform-tag) the Regional Public and Private Subnets then update the corresponding variables on terraform.tfvars file:
This module automatically finds the Subnets using the free-form tags you specified on the subnets.

```
# Free Form tags set on your Regional Subnets
RegionalPrivateKey = "<Key>"
RegionalPrivateValue = "<Value>"
RegionalPublicKey = "<Key>"
RegionalPublicValue = "<Value>"
```

Refer: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcetags.htm#workingtags

## Update env-var.sh file with OCI credentials
```
export TF_VAR_tenancy_ocid=
export TF_VAR_user_ocid=
export TF_VAR_compartment_ocid=

### OCI API keys
export TF_VAR_private_key_path=/
export TF_VAR_fingerprint=

### Region and Availability Domain
export TF_VAR_region=
export TF_VAR_availability_domain=1

### Public/Private keys used on the instance
### Replace with your key paths
export TF_VAR_ssh_public_key=$(cat /path/to/pubKey)
export TF_VAR_ssh_private_key=$(cat /path/to/privatekey)
```

## Update terraform.tfvars 

This is where you setup values to the customizable variables for this deployment.

| Argument                   | Description                                                                                                                                                                                                                                                                                                                                                       |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |                                                                                                                                                                                                            
| AD                         | Availability Domain for deployment. Setting AD = ["1"] deploys infrastructure in single availability domain (Availabilty domain 1 of the tenancy in this case) and AD = ["1","2"] deploys infrastructure in multiple ADs (Avilability domains 1 and 2 of the tenancy in this case). |
| vcn_id                     | OCID of the VCN where you want to deploy the ElasticSearch cluster.                                                                                                                                                                                                      
| vcn_dns_label              | DNS Label of the VCN (Virtual Cloud Network) to be created.                                                                                                                                                                                                       
| vcn_display_name           | Name of the VCN (Virtual Cloud Network) to be created                    

| timezone                   | Timezone of compute instances.
   
| compute_boot_volume_size_in_gb              | Size of Boot volume (in gb) to be attached to the nodes.

| compute_block_volume_size_in_gb             | Size of Block volume (in gb) to be attached to the ES Datanodes for data and Logs.

| compute_bv_mount_path              | Mount point for ElasticSearch Data and Logs.

| ES_instance_shape             	 | ElasticSeach instance shape.
                                                                                                                                      
| ES_master_hostname_prefix          | Hostname prefix to define hostname for ElasticSearch Master nodes.                                                                                                                                                                                                       
| ES_data_hostname_prefix            | Hostname prefix to define hostname for ElasticSearch Data nodes.                                                                                                                                                                                                 
| ES_master_instance_count           | Number of ElasticSearch Master nodes to be created.                                                                                                                                                                                                       
| ES_data_instance_count             | Number of ElasticSearch Data nodes to be created.                                                                                                                                                                                                   
| bastion_instance_shape             | Bastion instance shape. 
                                                                                                                          
| bastion_user             			 | Bastion OS user.
                                                                                                                          
| RegionalPrivateKey             | Free Form tag Key set on your Private Regional Subnet.
                                                                                                                          
| RegionalPrivateValue           | Free Form tag Value set on your Private Regional Subnet.
                                                                                                                          
| RegionalPublicKey              | Free Form tag Key set on your Public Regional Subnet.
                                                                                                                          
| RegionalPublicValue            | Free Form tag Value set on your Public Regional Subnet. 


## Sample terraform.tfvar file 

```hcl
# AD (Availability Domain to use for creating infrastructure) 
AD = ["1","2","3"]

# OCID of the VCN
vcn_id = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

# Timezone of compute instance
timezone = "GMT"

# Size of volume (in gb) of the instances
compute_boot_volume_size_in_gb = "50"
compute_block_volume_size_in_gb = "200"

# Block Volume mount path
compute_bv_mount_path = "/elasticsearch"

# Hostname prefix to define hostname for ElasticSearch nodes
ES_master_hostname_prefix = "esmaster"
ES_data_hostname_prefix = "esdata"

# Number of ElasticSearch nodes to be created
ES_master_instance_count = "3"
ES_data_instance_count = "3"

# Bastion instance shape
bastion_instance_shape = "VM.Standard2.1"

# ElastiSearch instance shape
ES_instance_shape = "VM.Standard2.2"

# OS user
bastion_user = "opc"
compute_instance_user = "opc"

# Free Form tags specified to your Regional Subnets
RegionalPrivateKey = "subnet"
RegionalPrivateValue = "private-regional"
RegionalPublicKey = "subnet"
RegionalPublicValue = "public-regional"
```

### How to use this module

1) Download or clone the modules to your local machine and go to the module directory.

  ```
  cd ElasticSearchClusterOnOCI-Existing-Subnet
  ```

2) Update **env-vars.sh** with the required information. This file defines environment variables with credentials for your Oracle Cloud Infrastructure tenancy.

3) Update **terraform.tfvars** with the inputs for the architecture that you want to build. A working sample of this file is available in previous section and can be copied to launch an environment.

4) Set environment variables by running **source env-vars.sh** on your UNIX system or by running **env-vars.ps1** on your Windows system.

  ```
  $ source env-vars.sh
  ```
5) Initialize Terraform. This will also download the latest terraform oci provider.

  ```
  $ terraform init
  ```

6) Run terraform apply to create the infrastructure:

  ```
  $ terraform apply
  ```

When you’re prompted to confirm the action, enter **yes**.

When all components have been created, Terraform displays a completion message. For example: Apply complete! Resources: 28 added, 0 changed, 0 destroyed.

7) If you want to delete the infrastructure, run:

  ```
  $ terraform destroy
  ```

When you’re prompted to confirm the action, enter **yes**.



