. configuration/config.sh

#CLUSTER
# cluster instances creation
echo "Launching the cluster in AWS"
sed "s/@CLUSTER_NAME@/${CLUSTER_NAME}/g" configuration/aerospike.conf.tpl > configuration/aerospike.conf

aerolab cluster create -n ${CLUSTER_NAME} -c ${CLUSTER_NUMBER_OF_NODES} --instance-type=${CLUSTER_INSTANCE_TYPE} --start=n --aws-expire=${DURATION}h --customconf configuration/aerospike.conf

rm configuration/aerospike.conf

aerolab files upload --name=${CLUSTER_NAME} tools/aerospike_best_practices.sh /root/aerospike_best_practices.sh
aerolab attach shell --name=${CLUSTER_NAME} --node=all --parallel -- sh /root/aerospike_best_practices.sh

aerolab files upload --name=${CLUSTER_NAME} tools/disk.sh /root/disk.sh
aerolab attach shell --name=${CLUSTER_NAME} --node=all --parallel -- sh /root/disk.sh

# starting instances
aerolab aerospike start -n ${CLUSTER_NAME} -l all

sleep 10

# adding exporter for monitoring
echo "Monitoring"
aerolab cluster add exporter -n ${CLUSTER_NAME}
aerolab client create ams -n ${GRAFANA_NAME} -s ${CLUSTER_NAME} --instance-type ${GRAFANA_INSTANCE_TYPE} --aws-expire=${DURATION}h

# CLIENT
echo "Creating the client nodes"
aerolab client create base -c ${CLIENT_NUMBER_OF_NODES} -n ${CLIENT_NAME}  --instance-type ${CLIENT_INSTANCE_TYPE} --aws-expire=${DURATION}h

# preparing nodes
aerolab files upload -c -n ${CLIENT_NAME} client/benchme /home/ubuntu/benchme
seed=$(aerolab cluster list -i | head -1 | grep -E -o 'int_ip=.{0,15}' | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' )
client_duration='3000 * DURATION'
cmd="./benchme -H ${seed} -c 192 -m 100000000 -d $((client_duration)) -r 1 -s 3072 -u false"
#cmd2="./benchme -H ${seed} -c 12 -m 25000000 -d $((client_duration)) -r 1 -s 1024 -u false"
echo $cmd
#echo $cmd2

aerolab client attach --name=${CLIENT_NAME} --node all --detach -- ${cmd}

grafana=$(aerolab client list -i | grep -A7 ${GRAFANA_NAME} | head -1 | grep -E -o 'ext_ip=.{0,15}' | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' )

aerolab client list

echo "You can now visit http://${grafana}:3000"

#echo "You can connect to client injector and use the command ${cmd}"