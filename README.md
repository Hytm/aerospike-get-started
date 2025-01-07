# get-started-with-aerospike

This repository is here to help you get started with Aerospike in an efficient and easy manner.

## Requirements

First, this guide require the use of Aerolab. You can find the tool here: https://github.com/aerospike/aerolab

Download the relevant release from there: https://github.com/aerospike/aerolab/releases

The repository supports only [AWS EC2 instances](#working-with-aws) or [Docker](##working-with-docker).
Depending on what you want, install the Docker CLI https://www.docker.com/ or AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html.

When working with AWS, it is mandatory to have instances with NVME, like m7gd.4xlarge or i3.large for example. The Aerospike configuration will require this to work properly and define the devices in aerospike.conf.

Don't forger to have Docker or the AWS cli configured properly.

## Configuration

Configuration for Aerolab, Docker, or AWS are done directly with the tool.

All the relevant configuration for the demo to work is done in the file located in configuration/config.sh
There is no default configuration!

### GENERAL section
| Parameter | Description |
| --------- | ----------- |
| BACKEND | AWS or DOCKER only supported |
| DESTROY_ON_CREATE | If set to true, aerolab destroy command will be sent before attempting creation |
| DURATION | Aerolab will automaticlly kill the cluster after this number of hours |
| NODE_TO_STOP | Should always be between 1 and the initial size defined with CLUSTER_NUMBER_OF_NODES |

### CLUSTER section 
| Parameter | Description |
| --------- | ----------- |
| CLUSTER_NAME | The name of the cluster. Useful when using `aeorlab cluster list` |
| CLUSTER_INSTANCE_TYPE | **Only for AWS** Define the instance type to be used. Don't forget it is mandatory to have NVME with the instance |
| CLUSTER_NUMBER_OF_NODES | **Only for AWS** It is recommended to start with at least 3 nodes in the cluster, but you can define any number. |

### MONITORING section
| Parameter | Description |
| --------- | ----------- |
| GRAFANA_NAME | Define the name of the Grafana client to monitor the cluster. It is recommended to use a name with the cluster name inside, like this `${CLUSTER_NAME}"_GRAFANA"`  |
| GRAFANA_INSTANCE_TYPE | **Only for AWS** Client instance type |

### CLIENT section
| Parameter | Description |
| --------- | ----------- |
| CLIENT_NAME | This is the client where the tool will be uploaded to. It is recommended to use a name with the cluster name inside, like this `${CLUSTER_NAME}"_CLIENT"` |
| CLIENT_INSTANCE_TYPE | **Only for AWS** Use ARM instance like `c4.4xlarge` |
| CLIENT_NUMBER_OF_NODES | At least 1 to upload the load generator. You can skip this parameter if you plan to develop your own tool to work with the cluster. |


##  Working with AWS

To work with AWS, be sure you set it in the configuration file located in configuration/config.sh the different parameter mandatory for AWS, like instances type (check "Only for AWS" in the configuration parameters description).

Validate you have you AWS CLI properly configured to manage EC2, Subnets, etc. 

This is an example of configuration 

> #### GENERAL
> BACKEND="AWS"
> 
> DESTROY_ON_CREATE="true"
> 
> DURATION=12
> 
> NODE_TO_STOP=3
> 
> #### CLUSTER
> CLUSTER_NAME="DEMO"
> 
> CLUSTER_INSTANCE_TYPE="i4g.4xlarge"
> 
> CLUSTER_NUMBER_OF_NODES=5
> 
> #### MONITORING
> GRAFANA_NAME=${CLUSTER_NAME}"_GRAFANA"
> 
> GRAFANA_INSTANCE_TYPE="t3.xlarge"
> 
> #### CLIENT
> CLIENT_NAME=${CLUSTER_NAME}"_CLIENT"
> 
> CLIENT_INSTANCE_TYPE="c7i.12xlarge"
> 
> CLIENT_NUMBER_OF_NODES=1

## Working with Docker

**Important**
It's better to ensure you can use Docker without sudo to ensure a smooth experience with this guide. Please follow post-installation steps from docker: https://docs.docker.com/engine/install/linux-postinstall/ 

> #### GENERAL
> BACKEND="DOCKER"
> 
> DESTROY_ON_CREATE="true"
> 
> DURATION=4
> 
> NODE_TO_STOP=3
> 
> #### CLUSTER
> CLUSTER_NAME="DEMO"
> 
> CLUSTER_NUMBER_OF_NODES=3
> 
> #### MONITORING
> GRAFANA_NAME=${CLUSTER_NAME}"_GRAFANA"
> 
> #### CLIENT
> CLIENT_NAME=${CLUSTER_NAME}"_CLIENT"
> 
> CLIENT_NUMBER_OF_NODES=1

# Use the scripts

In the script folder, you'll find all the script needed to get up & running!

| Script Name | Description |
| --------- | ----------- |
| 01-start.sh | As expected, this one creates the whole environment |
| 02-addNodes.sh | This one adds two nodes to the existing cluster |
| 03-stopNode.sh | Will send a stop command to a node with Aerolab |
| 04-restartNode.sh | Restart the node stopped by 03-stopNode.sh |
| 05-clean.sh | Destroy all the environment (cluster, grafana, and client) |

You don't need to follow the numbers, those are not steps. 

Scripts to add nodes, stop and restart a node, are mostly helpful to help you observe the impact on performance when an issue happens in your cluster. 

So, you mostly need to start everything and clean your environment, especially when running on AWS to avoid paying too much!

# Cluster and Monitoring setup

Once finished, the installation should have prepared a Grafana host to check monitoring.

In the dashboards section, you can find multiple Aerospike dedicated dashboards. You can also import the one provided in the grafana/dashboard folder. Simply copy the content and paste it in the import box from Grafana.

# Testing the installation

In this repo, you can find the benchme binary in client folder. 

You can simply launch it, it should be ok and start inserting and reading data from your Aerospike cluster!
After the launch, you'll see the command to run from the client.
To connect to the client, you need to pass the ssh key used by Aerolab. Here is an example

`ssh -i ~/aerolab-keys/aerolab-DEMO_CLIENT_us-east-2 ubuntu@{Client IP}`

### Parameters for benchme
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| -H --host-ip | Host IP| 127.0.0.1 |
| -p --port | Port | 3000 |
| -w --write-ratio | Percentage of write threads. Other will be read threads | 20 |
| -c --concurrency | Concurrency defines the number of threads | 2 |
| -d --duration | Duration in seconds. 0 means unlimited | 0 |
| -m --max-keys | Maximum number of records. Past this value, you can update or insert/delete records. | 1 000 000 |
| -r --report-delay | Delay between information printed on screen | 10 |
| -s --size | Size of records in bytes | 2048 |
| -u --update | After MAX_KEYS is reached, update record or not | true |
| -t --truncate | Will truncate the namespace before inserting new keys. | false |
| -d --docker | If set to true, change the client behavior to ensure you can run on local machine. | false |
| -h --h | Print help |
| -V --v | Print version |

It's up to you to change parameters or to create your own tool. But with that you should be able to check the performance and resilience of Aerospike!

## Use your own application

It's not mandatory to use the tool provided. This tool is just here to let you observe the performance achievable by Aerospike.
Feel free to create your own tool and connect to the cluster.