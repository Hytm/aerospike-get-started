service {
        proto-fd-max 60000
        cluster-name @CLUSTER_NAME@
        enable-health-check true    
        os-group-perms true
}

logging {
        file /var/log/aerospike/aerospike.log {
                context any info
        }
}

network {
        service {
                address any
                port 3000
        }
        heartbeat {
                mode mesh
                port 3002
                mesh-seed-address-port 172.20.1.68 3002
                interval 150
                timeout 20
        }
        fabric {
                port 3001
        }
        info {
                port 3003
        }
}

namespace test {
        replication-factor 2
        default-ttl 0
        nsup-period 3600
        partition-tree-sprigs 8192

        storage-engine device {
            device /dev/@DISK@
            defrag-sleep 1000
            read-page-cache true
            stop-writes-avail-pct 5
            stop-writes-used-pct 70
        }
}
