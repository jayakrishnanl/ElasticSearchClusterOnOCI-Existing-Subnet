#cloud-config
timezone: "${timezone}"

output: {all: '| tee -a /var/log/cloud-init-output.log'}
  
yum_repos: 
  elasticsearch-7.x: 
    autorefresh: true
    baseurl: "https://artifacts.elastic.co/packages/7.x/yum"
    enabled: true
    gpgcheck: true
    gpgkey: "https://artifacts.elastic.co/GPG-KEY-elasticsearch"
    name: "Elasticsearch repository for 7.x packages"
    type: rpm-md

runcmd:
 - rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch