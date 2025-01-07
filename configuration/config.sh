#GENERAL
BACKEND="AWS" # AWS or DOCKER only supported
DESTROY_ON_CREATE="true"
DURATION=12
#Should always be between 1 and the initial size defined with CLUSTER_NUMBER_OF_NODES
NODE_TO_STOP=3

#CLUSTER
CLUSTER_NAME="DEMO"
CLUSTER_INSTANCE_TYPE="i4g.4xlarge"
CLUSTER_NUMBER_OF_NODES=5
#Lower configuration, use command 2 when running the benchme tool
#CLUSTER_INSTANCE_TYPE="i3.large"
#CLUSTER_NUMBER_OF_NODES=3

#MONITORING
GRAFANA_NAME=${CLUSTER_NAME}"_GRAFANA"
GRAFANA_INSTANCE_TYPE="t3.xlarge"

#CLIENT
CLIENT_NAME=${CLUSTER_NAME}"_CLIENT"
CLIENT_INSTANCE_TYPE="c7i.12xlarge"
#Lower configuration, use command 2 when running the benchme tool
#CLIENT_INSTANCE_TYPE="c4.4xlarge"
CLIENT_NUMBER_OF_NODES=1
