resource "null_resource" "provision_es_master" {
  count = "${var.ES_master_instance_count}"

  #depends_on = ["module.create_hap.ComputePrivateIPs"]
  connection {
    agent               = false
    timeout             = "30m"
    host                = "${element(module.create_ES_master.ComputePrivateIPs, count.index)}"
    user                = "opc"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.create_bastion.ComputePublicIPs[0]}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python-oci-cli",
      "sudo yum install -y java elasticsearch kibana logstash",
      "sudo mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig",
      "sudo mkdir /etc/systemd/system/elasticsearch.service.d",
      "sudo -s bash -c 'echo \"[Service]\" >>/etc/systemd/system/elasticsearch.service.d/override.conf'",
      "sudo echo 'LimitMEMLOCK=infinity' >>/etc/systemd/system/elasticsearch.service.d/override.conf",
      "sudo firewall-offline-cmd --port=9200:tcp",
      "sudo firewall-offline-cmd --port=9300:tcp",
      "sudo firewall-offline-cmd --port=5601:tcp",
      "sudo /bin/systemctl restart firewalld",
      "sudo firewall-cmd --reload",
      "sudo ulimit -n 65536",
      "sudo ulimit -u 4096",
      "sudo -s bash -c 'echo \"elasticsearch  -  nofile  65536\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"elasticsearch  -  nproc  4096\" >>/etc/security/limits.conf'",
      "sudo -s bash -c 'echo \"vm.max_map_count=262144\" >>/etc/sysctl.conf'",
      "sudo -s bash -c 'echo \"vm.swappiness=1\" >>/etc/sysctl.conf'",
      "sudo sysctl -p",
    ]
  }

  provisioner "file" {
    content     = "${element(data.template_file.EsMasterCfg.*.rendered, count.index)}"
    destination = "/tmp/elasticsearch.yml"
  }

  provisioner "file" {
    content     = "${element(data.template_file.Kibana_cfg.*.rendered, count.index)}"
    destination = "/tmp/kibana.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -s bash -c 'cp /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml'",
      "sudo -s bash -c 'chmod 660 /etc/elasticsearch/elasticsearch.yml'",
      "sudo -s bash -c 'chown root:elasticsearch /etc/elasticsearch/elasticsearch.yml'",
      "sudo -s bash -c 'cp /tmp/kibana.cfg /etc/kibana/kibana.yml'",
      "sudo mkdir -p /elasticsearch/data /elasticsearch/log",
      "sudo chown -R elasticsearch:elasticsearch  /elasticsearch",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch.service",
      "sudo systemctl start elasticsearch.service",
      "sudo systemctl enable kibana.service",
      "sudo systemctl start kibana.service",
    ]
  }
}
