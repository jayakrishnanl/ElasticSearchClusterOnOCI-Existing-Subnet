output "BastionPublicIPs" {
  value = ["${module.create_bastion.ComputePublicIPs}"]
}

output "ESMasterNodePrivateIPs" {
  value = ["${module.create_ES_master.ComputePrivateIPs}"]
}

output "ESDataNodePrivateIPs" {
  value = ["${module.create_ES_data.ComputePrivateIPs}"]
}
