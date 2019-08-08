# Get list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Get name of Availability Domains
data "template_file" "deployment_ad" {
  count    = "${length(var.AD)}"
  template = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD[count.index] - 1], "name")}"
}

# Get list of Fault Domains
data "oci_identity_fault_domains" "fds" {
  count               = "${length(var.AD)}"
  availability_domain = "${element(data.template_file.deployment_ad.*.rendered, count.index)}"
  compartment_id      = "${var.compartment_ocid}"
}

locals {
  fds                 = "${flatten(concat(data.oci_identity_fault_domains.fds.*.fault_domains))}"
  faultdomains_per_ad = 3
}

# Get name of Fault Domains
data "template_file" "deployment_fd" {
  template = "$${name}"
  count    = "${length(var.AD) * (local.faultdomains_per_ad) }"

  vars = {
    name = "${lookup(local.fds[count.index], "name")}"
  }
}

# Datasources for computing home region for IAM resources
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = "${var.tenancy_ocid}"
}

data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}

# Find the Public and Private Subnets in the VCN specified
data "oci_core_subnets" "public-AD1" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

  filter {
    name   = "freeform_tags.subnet"
    values = ["public-AD1"]
  }
}

data "oci_core_subnets" "public-AD2" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

  filter {
    name   = "freeform_tags.subnet"
    values = ["public-AD2"]
  }
}

data "oci_core_subnets" "public-AD3" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

  filter {
    name   = "freeform_tags.subnet"
    values = ["public-AD3"]
  }
}

data "oci_core_subnets" "private-AD1" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

  filter {
    name   = "freeform_tags.subnet"
    values = ["private-AD1"]
  }
}

data "oci_core_subnets" "private-AD2" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

  filter {
    name   = "freeform_tags.subnet"
    values = ["private-AD2"]
  }
}

data "oci_core_subnets" "private-AD3" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

  filter {
    name   = "freeform_tags.subnet"
    values = ["private-AD3"]
  }
}

# ES Master node data sources and temlate generation
# Get a list of VNIC attachments on the ES Master Nodes
data "oci_core_vnic_attachments" "MasterInstanceVnicAttachments" {
  count               = "${var.ES_master_instance_count}"
  availability_domain = "${element(data.template_file.deployment_ad.*.rendered, count.index)}"
  compartment_id      = "${var.compartment_ocid}"
  instance_id         = "${element(module.create_ES_master.ComputeOcids, count.index)}"
}

locals {
  vnics_master = "${flatten(concat(data.oci_core_vnic_attachments.MasterInstanceVnicAttachments.*.vnic_attachments))}"
}

# Get OCIDs of the Vnics
data "template_file" "ES_master_vnic_ocids" {
  template = "$${name}"
  count    = "${var.ES_master_instance_count}"

  vars = {
    name = "${lookup(local.vnics_master[count.index], "vnic_id")}"
  }
}

data "oci_core_private_ips" "ES_master_privateIpId" {
  depends_on = ["data.template_file.ES_master_vnic_ocids"]

  # count      = "${length(data.template_file.vnic_ocids.*.rendered)}"
  count   = "${var.ES_master_instance_count}"
  vnic_id = "${element(data.template_file.ES_master_vnic_ocids.*.rendered, count.index)}"

  filter {
    name   = "is_primary"
    values = ["true"]
  }
}

locals {
  ES_master_privateIpId = "${flatten(concat(data.oci_core_private_ips.ES_master_privateIpId.*.private_ips))}"
}

data "template_file" "ES_master_privateIp_ocid" {
  template = "$${name}"
  count    = "${var.ES_master_instance_count}"

  vars = {
    name = "${lookup(local.ES_master_privateIpId[count.index], "id")}"
  }
}

data "template_file" "ES_master_hostname_label" {
  template = "$${name}"
  count    = "${var.ES_master_instance_count}"

  vars {
    name = "${lookup(local.ES_master_privateIpId[count.index], "hostname_label")}"
  }
}

# Render ElasticSearch Master node configuration file
data "template_file" "EsMasterCfg" {
  count    = "${var.ES_master_instance_count}"
  template = "${file("${path.module}/userdata/es_master_cfg.tpl")}"

  vars {
    host_label = "${element(data.template_file.ES_master_hostname_label.*.rendered, count.index)}"
    ip         = "${element(module.create_ES_master.ComputePrivateIPs, count.index)}"
    data_ips   = "${join(", ", module.create_ES_data.ComputePrivateIPs)}"
    master_ips = "${join(", ", module.create_ES_master.ComputePrivateIPs)}"

    #minimum_master_nodes = "${floor(var.ES_master_instance_count / 2 + 1)}"
    minimum_master_nodes = "1"
  }
}

# Render Kibana configuration file
data "template_file" "Kibana_cfg" {
  count    = "${var.ES_master_instance_count}"
  template = "${file("${path.module}/userdata/kibana.yml.tpl")}"

  vars {
    ip = "${element(module.create_ES_master.ComputePrivateIPs, count.index)}"
  }
}

# ES Data node data sources and templates
# Get a list of VNIC attachments on the ES Data Nodes
data "oci_core_vnic_attachments" "DataInstanceVnicAttachments" {
  count               = "${var.ES_data_instance_count}"
  availability_domain = "${element(data.template_file.deployment_ad.*.rendered, count.index)}"
  compartment_id      = "${var.compartment_ocid}"
  instance_id         = "${element(module.create_ES_data.ComputeOcids, count.index)}"
}

locals {
  vnics_data = "${flatten(concat(data.oci_core_vnic_attachments.DataInstanceVnicAttachments.*.vnic_attachments))}"
}

# Get OCIDs of the Vnics
data "template_file" "ES_data_vnic_ocids" {
  template = "$${name}"
  count    = "${var.ES_data_instance_count}"

  vars = {
    name = "${lookup(local.vnics_data[count.index], "vnic_id")}"
  }
}

data "oci_core_private_ips" "ES_data_privateIpId" {
  count   = "${var.ES_data_instance_count}"
  vnic_id = "${element(data.template_file.ES_data_vnic_ocids.*.rendered, count.index)}"

  filter {
    name   = "is_primary"
    values = ["true"]
  }
}

locals {
  ES_data_privateIpId = "${flatten(concat(data.oci_core_private_ips.ES_data_privateIpId.*.private_ips))}"
}

data "template_file" "ES_data_privateIp_ocid" {
  template = "$${name}"
  count    = "${var.ES_data_instance_count}"

  vars = {
    name = "${lookup(local.ES_data_privateIpId[count.index], "id")}"
  }
}

data "template_file" "ES_data_hostname_label" {
  template = "$${name}"
  count    = "${var.ES_data_instance_count}"

  vars = {
    name = "${lookup(local.ES_data_privateIpId[count.index], "hostname_label")}"
  }
}

# Render ElasticSearch Master node configuration file
data "template_file" "ES_data_cfg" {
  count    = "${var.ES_data_instance_count}"
  template = "${file("${path.module}/userdata/es_data_cfg.tpl")}"

  vars {
    host_label           = "${element(data.template_file.ES_data_hostname_label.*.rendered, count.index)}"
    ip                   = "${element(module.create_ES_data.ComputePrivateIPs, count.index)}"
    data_ips             = "${join(",", formatlist("\"%s\"", module.create_ES_data.ComputePrivateIPs))}"
    master_ips           = "${join(",", formatlist("\"%s\"", module.create_ES_master.ComputePrivateIPs))}"
    minimum_master_nodes = "1"

    /*
      data_ips   = "${join(", ", module.create_ES_data.ComputePrivateIPs)}"
      master_ips = "${join(", ", module.create_ES_master.ComputePrivateIPs)}"
      minimum_master_nodes = "${floor(var.ES_master_instance_count} / 2 + 1)}"
    */
  }
}

data "template_file" "bootstrap_ES_data" {
  template = "${file("${path.module}/userdata/bootstrap_ES_data.tpl")}"

  vars {
    timezone = "${var.timezone}"
  }
}

data "template_file" "bootstrap_ES_master" {
  template = "${file("${path.module}/userdata/bootstrap_ES_master.tpl")}"

  vars {
    timezone = "${var.timezone}"
  }
}
