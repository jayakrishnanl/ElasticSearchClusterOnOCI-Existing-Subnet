#! /bin/bash
# Set JAVA heap to 50% of available RAM, but no more than 26Gb
MAX_HEAP=26624
JVM_HEAP_SIZE=$(grep MemTotal /proc/meminfo | \
                   awk -v max_heap=$MAX_HEAP \
                       '{$2/=(2*1024);printf "%dm\n",($2 > max_heap) ? max_heap : $2}')
sed -i -e "s/^-Xms.*/-Xms$JVM_HEAP_SIZE/g" /etc/elasticsearch/jvm.options
sed -i -e "s/^-Xmx.*/-Xmx$JVM_HEAP_SIZE/g" /etc/elasticsearch/jvm.options

sed -i 's/\/var\/log\/elasticsearch/\/elasticsearch\/log/g' /etc/elasticsearch/jvm.options
sed -i 's/\/var\/lib\/elasticsearch/\/elasticsearch\/data/g' /etc/elasticsearch/jvm.options