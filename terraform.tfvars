
# Region
# region = "eu-frankfurt-1"

# AD (Availability Domain to use for creating infrastructure) 
AD = ["1","2","3"]

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
ES_master_instance_count = "2"
ES_data_instance_count = "4"

# Bastion instance shape
bastion_instance_shape = "VM.STandard2.1"

# ElastiSearch instance shape
ES_instance_shape = "VM.Standard2.2"

# OS user
bastion_user = "opc"
compute_instance_user = "opc"

# OCID of the VCN
vcn_id = "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa5v2jd5b3aathqm64ad6oceeoi2jawfzotxr4egumqepopownk5da"

# ElasticSearch Public Subnet - make sure SL has opened ingress: 9200/TCP, 5601/TCP; EGress ALL/TCP and has RT with IG configured.
# es_subnet = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaatXXXXXXXXXqkl57s6ssz7wxufvqwdlidqfqxjq"




