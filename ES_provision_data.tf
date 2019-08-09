resource "null_resource" "provision_es_data" {
  count      = "${var.ES_data_instance_count}"
  depends_on = ["null_resource.provision_es_master"]

  connection {
    agent               = false
    timeout             = "30m"
    host                = "${element(module.create_ES_data.ComputePrivateIPs, count.index)}"
    user                = "${var.compute_instance_user}"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.create_bastion.ComputePublicIPs[0]}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python-oci-cli",
      "sudo yum install -y java-1.8.0 elasticsearch",
      "sudo mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig",
      "sudo mkdir /etc/systemd/system/elasticsearch.service.d",
      "sudo -s bash -c 'echo \"[Service]\" >>/etc/systemd/system/elasticsearch.service.d/override.conf'",
      "sudo -s bash -c 'echo 'LimitMEMLOCK=infinity' >>/etc/systemd/system/elasticsearch.service.d/override.conf'",
      "sudo firewall-offline-cmd --port=9200:tcp",
      "sudo firewall-offline-cmd --port=9300:tcp",
      "sudo /bin/systemctl restart firewalld",
      "sudo firewall-cmd --reload",
      "sudo -s bash -c 'echo \"*      soft    nofile      65536\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"*      hard    nofile      65536\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"*  soft  nproc 4096\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"*  hard  nproc 4096\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"elasticsearch  -  nofile  65536\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"elasticsearch  -  nproc  4096\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"vm.max_map_count=262144\" >>/etc/sysctl.conf'",
      "sudo -s bash -c 'echo \"vm.swappiness=1\" >>/etc/sysctl.conf'",
      "sudo sysctl -p",
    ]
  }

  provisioner "file" {
    content     = "${element(data.template_file.ES_data_cfg.*.rendered, count.index)}"
    destination = "/tmp/elasticsearch.yml"
  }

  provisioner "file" {
    source      = "./userdata/jvm_options.tpl"
    destination = "/tmp/jvm_options.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/jvm_options.sh",
      "sudo sh /tmp/jvm_options.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -s bash -c 'cp /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml'",
      "sudo -s bash -c 'chmod 660 /etc/elasticsearch/elasticsearch.yml'",
      "sudo -s bash -c 'chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml'",
      "sudo mkdir -p /elasticsearch/data /elasticsearch/log",
      "sudo chown -R elasticsearch:elasticsearch  /elasticsearch",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch.service",
      "sudo systemctl start elasticsearch.service",
    ]
  }
}
