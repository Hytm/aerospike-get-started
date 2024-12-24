# get-started-with-aerospike

This repository is here to help you get started with Aerospike in an efficient and easy manner.

## Requirements

First, this guide require the use of Aerolab. You can find the tool here: https://github.com/aerospike/aerolab

Download the relevant release from there: https://github.com/aerospike/aerolab/releases

The repository supports only [AWS EC2 instances](#AWS) or [Docker](#Docker).
Depending on what you want, install the Docker CLI https://www.docker.com/ or AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html.

Don't forger to have Docker or the AWS cli configured properly.

## Configuration

Configuration for Aerolab, Docker, or AWS are done directly with the tool.

All the relevant configuration for the demo to work is done in the file located in configuration/config.sh
There is no default configuration!

### GENERAL section
| Parameter | Description |
| --------- | ----------- |
| BACKEND | AWS or DOCKER only supported |
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


#  Working with AWS {#AWS}

To work with AWS, be sure you set it in the configuration file located in configuration/config.sh

# Working with Docker {#Docker}
**Important**
It's better to ensure you can use Docker without sudo to ensure a smooth experience with this guide. Please follow post-installation steps from docker: https://docs.docker.com/engine/install/linux-postinstall/ 

## Cluster and Monitoring setup

First, configure Aerolab to use docker
    `aerolab config backend -t docker`

Then you can start a cluster with this command
`aerolab cluster create -c 5`

It'll create a 5 nodes cluster locally.

Add the exporter for monitoring
`aerolab cluster add exporter -n mydc`

And finally the monitoring client
`aerolab client create ams -s mydc`

You should be now able to access the Grafana console from http://127.0.0.1:3000

## Testing the installation

In this repo, you can find the get-started binary. You can simply launch it, it should be ok and start inserting and reading data from your Aerospike cluster!

Here are the parameters you can use:
| Parameter | Description | Default |
| ----------- | ----------- | ----------- |
| -H | One of the node IP | 127.0.0.1 |
| -p | Port used | 3101 |
| -d | Duration of the tes in seconds | 60 |
| -m | Maximum number of records to write | 1000000 |
| -h | help | |

It's up to you to change those parameters or to create your own tool. But with that you should be able to check the performance and resilience of Aerospike!