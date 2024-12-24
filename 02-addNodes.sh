. configuration/config.sh

current_number_of_nodes=$(aerolab cluster list -i | tail -1 | grep -E -o 'node=.{0,1}' | egrep -o '[0-9]')
new_nodes_count=$(($current_number_of_nodes + 1))

sed "s/@CLUSTER_NAME@/${CLUSTER_NAME}/g" configuration/aerospike.conf.tpl > configuration/aerospike.conf

# Managing disk on the new node
aerolab cluster grow -n ${CLUSTER_NAME} -c 1 --instance-type=${CLUSTER_INSTANCE_TYPE} --start=n --aws-expire=${DURATION}h --customconf configuration/aerospike.conf

aerolab files upload --name=${CLUSTER_NAME} -l ${new_nodes_count} tools/aerospike_best_practices.sh /root/aerospike_best_practices.sh
aerolab attach shell --name=${CLUSTER_NAME} -l ${new_nodes_count} -- sh /root/aerospike_best_practices.sh

aerolab files upload --name=${CLUSTER_NAME} tools/disk.sh /root/disk.sh
aerolab attach shell --name=${CLUSTER_NAME} -l ${new_nodes_count} -- sh /root/disk.sh

aerolab aerospike start -n ${CLUSTER_NAME} -l ${new_nodes_count}
sleep 10

aerolab cluster add exporter -n ${CLUSTER_NAME} -l ${new_nodes_count}

# Managing disk on the second new node
current_number_of_nodes=$new_nodes_count
new_nodes_count=$(($current_number_of_nodes + 1))

aerolab cluster grow -n ${CLUSTER_NAME} -c 1 --instance-type=${CLUSTER_INSTANCE_TYPE} --start=n --aws-expire=${DURATION}h --customconf configuration/aerospike.conf

aerolab files upload --name=${CLUSTER_NAME} -l ${new_nodes_count} tools/aerospike_best_practices.sh /root/aerospike_best_practices.sh
aerolab attach shell --name=${CLUSTER_NAME} -l ${new_nodes_count} -- sh /root/aerospike_best_practices.sh

aerolab files upload --name=${CLUSTER_NAME} tools/disk.sh /root/disk.sh
aerolab attach shell --name=${CLUSTER_NAME} -l ${new_nodes_count} -- sh /root/disk.sh

aerolab aerospike start -n ${CLUSTER_NAME} -l ${new_nodes_count}

echo "Wait"
sleep 10

aerolab cluster add exporter -n ${CLUSTER_NAME} -l ${new_nodes_count}

rm configuration/aerospike.conf

echo "Reconfiguring Prometheus"
aerolab client configure ams -n ${GRAFANA_NAME} -s ${CLUSTER_NAME}