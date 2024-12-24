# get-started-with-aerospike

This repository is here to help you get started with Aerospike in an efficient and easy manner.

## Requirements

First, this guide require the use of Aerolab. You can find the tool here: https://github.com/aerospike/aerolab

Download the relevant release from there: https://github.com/aerospike/aerolab/releases

Then, you will also need to use Docker as it'll be the backend for Aerolab. This way, you can manage everything from your laptop/desktop. https://www.docker.com/


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