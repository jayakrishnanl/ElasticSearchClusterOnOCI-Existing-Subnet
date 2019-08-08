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





curl -XGET http://10.0.5.15:9200/_cluster/health
curl -XGET http://10.0.5.15:9200/_cluster/state?pretty


curl -XGET http://10.0.5.15:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason| grep UNASSIGNED
curl -XGET http://10.0.5.15:9200/_cluster/allocation/explain?pretty


curl -XGET http://10.0.3.6:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason| grep UNASSIGNED
curl -XGET http://10.0.3.6:9200/_cluster/allocation/explain?pretty

curl -XPOST '10.0.3.11:9200/_cluster/reroute?retry_failed'
curl -XPOST '10.0.5.8:9200/_cluster/reroute?retry_failed'


curl -GET http://10.0.5.15:9200/_cat/indices?v
curl -GET http://10.0.3.6:9200/_cat/indices?v

-H "Content-Type: application/json" 


curl -XDELETE http://10.0.5.14:9200/.kibana_1


[root@master1 ~]# cat /etc/elasticsearch/elasticsearch.yml  | egrep -v "^$|^#"
cluster.name: oci-es-cluster
node.name: master1
path.data: /elasticsearch/data
path.logs: /elasticsearch/log
bootstrap.memory_lock: true
network.host: 10.0.5.11
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.0.5.11", "10.0.5.12", "10.0.3.2"]
discovery.zen.minimum_master_nodes: 1
node.master: true
node.data: false
cluster.initial_master_nodes: ["10.0.5.11"]



[root@data1 ~]# cat /etc/elasticsearch/elasticsearch.yml  | egrep -v "^$|^#"
cluster.name: oci-es-cluster
node.name: data1
path.data: /elasticsearch/data
path.logs: /elasticsearch/log
bootstrap.memory_lock: true
network.host: 10.0.5.12
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.0.5.11", "10.0.5.12", "10.0.3.2"]
discovery.zen.minimum_master_nodes: 1
node.master: false
node.data: true
cluster.initial_master_nodes: [10.0.5.11]
[root@data1 ~]# 


S

[root@master1 ~]# cat /etc/security/limits.conf  | egrep -v "^$|^#"
elasticsearch  -  nofile  65536
elasticsearch  -  nproc  4096
*      soft    nofile      65536 
*      hard    nofile      65536
*	soft	nproc	4096
*	hard	nproc	4096


[root@master1 ~]# cat /etc/kibana/kibana.yml | egrep -v "^$|^#"
server.host: "10.0.5.11"
elasticsearch.hosts: ["http://10.0.5.11:9200"]

[root@master1 ~]# cat /etc/systemd/system/elasticsearch.service.d/override.conf
[Service]
LimitMEMLOCK=infinity
 ^^ all nodes


null_resource.provision_es_data[0] (remote-exec): /tmp/terraform_228658006.sh: line 7: /etc/systemd/system/elasticsearch.service.d/override.conf: Permission denied

null_resource.provision_es_data[1] (remote-exec): /tmp/terraform_737650587.sh: line 7: /etc/systemd/system/elasticsearch.service.d/override.conf: Permission denied

*/