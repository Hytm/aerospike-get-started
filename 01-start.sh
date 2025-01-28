. configuration/config.sh

if [[ "$BACKEND" ==  "AWS" ]]; then
    aerolab config backend -t aws
else
    aerolab config backend -t docker
fi

if [[ "$DESTROY_ON_CREATE" == "true" ]]; then
    aerolab cluster destroy -f -n ${CLUSTER_NAME}
    aerolab client destroy -f -n ${CLIENT_NAME}
    aerolab client destroy -f -n ${GRAFANA_NAME}
fi

#CLUSTER
version_to_use=""
# cluster instances creation
if [[ "$VERSION" != "" ]]; then
    version_to_use="-v ${VERSION}"
fi

if [[ "$BACKEND" ==  "AWS" ]]; then
    sed "s/@CLUSTER_NAME@/${CLUSTER_NAME}/g" configuration/aerospike.conf.tpl > configuration/aerospike.conf

    aerolab cluster create -n ${CLUSTER_NAME} -c ${CLUSTER_NUMBER_OF_NODES} --instance-type=${CLUSTER_INSTANCE_TYPE} --start=n --aws-expire=${DURATION}h --customconf configuration/aerospike.conf ${version_to_use}

    rm configuration/aerospike.conf

    aerolab files upload --name=${CLUSTER_NAME} tools/aerospike_best_practices.sh /root/aerospike_best_practices.sh
    aerolab attach shell --name=${CLUSTER_NAME} --node=all --parallel -- sh /root/aerospike_best_practices.sh

    aerolab files upload --name=${CLUSTER_NAME} tools/disk.sh /root/disk.sh
    aerolab attach shell --name=${CLUSTER_NAME} --node=all --parallel -- sh /root/disk.sh

    # starting instances
    aerolab aerospike start -n ${CLUSTER_NAME} -l all
else
    aerolab cluster create -n ${CLUSTER_NAME} -c ${CLUSTER_NUMBER_OF_NODES} $version_to_use
fi

sleep 10

# adding exporter for monitoring
echo "Monitoring"
aerolab cluster add exporter -n ${CLUSTER_NAME}
if [[ "$BACKEND" ==  "AWS" ]]; then
    aerolab client create ams -n ${GRAFANA_NAME} -s ${CLUSTER_NAME} --instance-type ${GRAFANA_INSTANCE_TYPE} --aws-expire=${DURATION}h
else 
    aerolab client create ams -n ${GRAFANA_NAME} -s ${CLUSTER_NAME}
fi

# CLIENT
echo "Creating the client nodes"
if [[ "$BACKEND" ==  "AWS" ]]; then
    aerolab client create base -c ${CLIENT_NUMBER_OF_NODES} -n ${CLIENT_NAME}  --instance-type ${CLIENT_INSTANCE_TYPE} --aws-expire=${DURATION}h
else 
    aerolab client create base -c ${CLIENT_NUMBER_OF_NODES} -n ${CLIENT_NAME}
fi

# preparing nodes
aerolab files upload -c -n ${CLIENT_NAME} client/benchme /home/ubuntu/benchme
client_duration='3000 * DURATION'
if [[ "$BACKEND" ==  "AWS" ]]; then
    seed=$(aerolab cluster list -i | head -1 | grep -E -o 'int_ip=.{0,15}' | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' )
    grafana=$(aerolab client list -i | grep -A7 ${GRAFANA_NAME} | head -1 | grep -E -o 'ext_ip=.{0,15}' | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' )
    cmd="./benchme -H ${seed} -c 192 -m 100000000 -d $((client_duration)) -r 1 -s 3072 -u false"
else
    seed=$(aerolab cluster list -i | head -1 | grep -E -o 'ext_ip=.{0,15}' | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}' )
    grafana="127.0.0.1"
    #smaller configuration of benchme when running with Docker. the -D parameter is used to let benchme know is running in Docker
    cmd="./benchme -H ${seed} -p 3100 -c 12 -m 2000000 -d $((client_duration)) -r 1 -s 1024 -u false -D true"
fi

echo $cmd


aerolab client list

echo "You can now visit http://${grafana}:3000"

echo "You can connect to client injector and use the command ${cmd}"