/*
locals {
  public_subnets  = "${compact(list("${lookup(data.oci_core_subnets.public-AD1.subnets[0], "id")}", "${lookup(data.oci_core_subnets.public-AD2.subnets[0], "id")}", "${lookup(data.oci_core_subnets.public-AD3.subnets[0], "id")}"))}"
  private_subnets = "${compact(list("${lookup(data.oci_core_subnets.private-AD1.subnets[0], "id")}", "${lookup(data.oci_core_subnets.private-AD2.subnets[0], "id")}", "${lookup(data.oci_core_subnets.private-AD3.subnets[0], "id")}"))}"
}
*/

locals {
  public_subnets  = "${compact(list("${lookup(data.oci_core_subnets.public-regional.subnets[0], "id")}"))}"
  private_subnets = "${compact(list("${lookup(data.oci_core_subnets.private-regional.subnets[0], "id")}"))}"
}

# Create ElasticSearch Node

module "create_bastion" {
  source                          = "./modules/compute"
  compartment_ocid                = "${var.compartment_ocid}"
  AD                              = "${var.AD}"
  availability_domain             = ["${data.template_file.deployment_ad.*.rendered}"]
  fault_domain                    = ["${sort(data.template_file.deployment_fd.*.rendered)}"]
  compute_subnet                  = ["${local.public_subnets}"]
  compute_instance_count          = "1"
  compute_hostname_prefix         = "bastion-${substr(var.region, 3, 3)}"
  compute_boot_volume_size_in_gb  = "${var.compute_boot_volume_size_in_gb}"
  compute_block_volume_size_in_gb = "0"
  compute_bv_mount_path           = ""
  compute_assign_public_ip        = "true"
  compute_image                   = "${var.instance_image_ocid[var.region]}"
  compute_instance_shape          = "${var.bastion_instance_shape}"
  compute_ssh_public_key          = "${var.ssh_public_key}"
  compute_ssh_private_key         = "${var.ssh_private_key}"
  bastion_ssh_private_key         = "${var.ssh_private_key}"
  bastion_user                    = ""
  bastion_public_ip               = ""
  timezone                        = "${var.timezone}"
  user_data                       = "./userdata/bootstrap_bastion.tpl"
}

module "create_ES_master" {
  source                          = "./modules/compute"
  compartment_ocid                = "${var.compartment_ocid}"
  AD                              = "${var.AD}"
  availability_domain             = ["${data.template_file.deployment_ad.*.rendered}"]
  fault_domain                    = ["${sort(data.template_file.deployment_fd.*.rendered)}"]
  compute_subnet                  = ["${local.private_subnets}"]
  compute_instance_count          = "${var.ES_master_instance_count}"
  compute_hostname_prefix         = "${var.ES_master_hostname_prefix}${substr(var.region, 3, 3)}"
  compute_boot_volume_size_in_gb  = "${var.compute_boot_volume_size_in_gb}"
  compute_block_volume_size_in_gb = "0"
  compute_bv_mount_path           = "${var.compute_bv_mount_path}"
  compute_assign_public_ip        = "false"
  compute_image                   = "${var.instance_image_ocid[var.region]}"
  compute_instance_shape          = "${var.ES_instance_shape}"
  compute_ssh_public_key          = "${var.ssh_public_key}"
  compute_ssh_private_key         = "${var.ssh_private_key}"
  bastion_ssh_private_key         = "${var.ssh_private_key}"
  bastion_public_ip               = "${module.create_bastion.ComputePublicIPs[0]}"
  bastion_user                    = "${var.bastion_user}"
  timezone                        = "${var.timezone}"
  user_data                       = "${data.template_file.bootstrap_ES_master.rendered}"
}

module "create_ES_data" {
  source                          = "./modules/compute"
  compartment_ocid                = "${var.compartment_ocid}"
  AD                              = "${var.AD}"
  availability_domain             = ["${data.template_file.deployment_ad.*.rendered}"]
  fault_domain                    = ["${sort(data.template_file.deployment_fd.*.rendered)}"]
  compute_subnet                  = ["${local.private_subnets}"]
  compute_instance_count          = "${var.ES_data_instance_count}"
  compute_hostname_prefix         = "${var.ES_data_hostname_prefix}${substr(var.region, 3, 3)}"
  compute_boot_volume_size_in_gb  = "${var.compute_boot_volume_size_in_gb}"
  compute_block_volume_size_in_gb = "${var.compute_block_volume_size_in_gb}"
  compute_bv_mount_path           = "${var.compute_bv_mount_path}"
  compute_assign_public_ip        = "false"
  compute_image                   = "${var.instance_image_ocid[var.region]}"
  compute_instance_shape          = "${var.ES_instance_shape}"
  compute_ssh_public_key          = "${var.ssh_public_key}"
  compute_ssh_private_key         = "${var.ssh_private_key}"
  bastion_ssh_private_key         = "${var.ssh_private_key}"
  bastion_public_ip               = "${module.create_bastion.ComputePublicIPs[0]}"
  bastion_user                    = "${var.bastion_user}"
  timezone                        = "${var.timezone}"
  user_data                       = "${data.template_file.bootstrap_ES_data.rendered}"
}
