/*
Pre-requisites
- Create or chose existing Public Subnets where Bastion and ES Master nodes are to be launched. Make sure you create the Subnets across the available ADs.
- Tag (freeform-tag) the Public and Private Subnets using the following format:
Public Subnet on AD1 --> subnet:public-AD1
Public Subnet on AD2 --> subnet:public-AD2
Public Subnet on AD3 --> subnet:public-AD3

Private Subnet on AD1 --> subnet:private-AD1
Private Subnet on AD2 --> subnet:private-AD2
Private Subnet on AD3 --> subnet:private-AD3

Refer: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcetags.htm#workingtags

*/

/*
Master:
discovery.zen.minimum_master_nodes: 2 - done
cluster.routing.allocation.awareness.attributes: privad
node.attr.privad: $subnetID"
node.ingest: false

Prov
mkdir -p /elasticsearch/data /elasticsearch/log - Done
chown -R elasticsearch:elasticsearch  /elasticsearch - Done
sed -i 's/\/var\/log\/elasticsearch/\/elasticsearch\/log/g' /etc/elasticsearch/jvm.options
sed -i 's/\/var\/lib\/elasticsearch/\/elasticsearch\/data/g' /etc/elasticsearch/jvm.options
sed -i 's/-Xmx1g/-Xmx'$memgb'g/' /etc/elasticsearch/jvm.options
sed -i 's/-Xms1g/-Xms'$memgb'g/' /etc/elasticsearch/jvm.options
sed -i 's/#MAX_LOCKED_MEMORY/MAX_LOCKED_MEMORY/' /etc/sysconfig/elasticsearch


Kibana
echo "server.host: $local_ip" >>/etc/kibana/kibana.yml
echo "elasticsearch.host: "http://$local_ip:9200"" >>/etc/kibana/kibana.yml


Join list to make it a string.
join(", ", module.create_ES_master.ComputePrivateIPs)

**********
null_resource.provision_es_master[1] (remote-exec): sudo: ulimit: command not found
null_resource.provision_es_master[1] (remote-exec): sudo: ulimit: command not found

null_resource.provision_es_master[0] (remote-exec): sudo: ulimit: command not found
null_resource.provision_es_master[0] (remote-exec): sudo: ulimit: command not found



*/