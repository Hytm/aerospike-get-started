. configuration/config.sh

aerolab client destroy -f -n ${CLIENT_NAME}

aerolab client destroy -f -n ${GRAFANA_NAME}

aerolab cluster destroy -f -n ${CLUSTER_NAME}