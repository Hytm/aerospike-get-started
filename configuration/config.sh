#GENERAL
BACKEND="AWS" # AWS or DOCKER only supported
DESTROY_ON_CREATE="true"
DURATION=4
#Should always be between 1 and the initial size defined with CLUSTER_NUMBER_OF_NODES
NODE_TO_STOP=2
VERSION="" # specify a version to use. Mandatory for CE usage

MULTI_AZ="false"
AZ1=us-east-2a
AZ2=us-east-2b
AZ3=us-east-2c

#CLUSTER
CLUSTER_NAME="DEMO"
CLUSTER_INSTANCE_TYPE="i4i.4xlarge"
CLUSTER_NUMBER_OF_NODES=3
#Use when MULTI_AZ = true
CLUSTER_NUMBER_OF_NODES_PER_AZ=2
#Lower configuration, use command 2 when running the benchme tool
#CLUSTER_INSTANCE_TYPE="i3.xlarge"
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
CLIENT_NUMBER_OF_NODES_PER_AZ=3
