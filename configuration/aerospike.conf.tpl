service {
        proto-fd-max 60000
        cluster-name @CLUSTER_NAME@
        enable-health-check true    
        os-group-perms true
        microsecond-histograms  true
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
                interval 100
                timeout 10
                connect-timeout-ms 250
                mode mesh
                port 3002
                mesh-seed-address-port 172.20.1.68 3002
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
        nsup-period 120
	nsup-threads 1

        @RACK_ID@
        
        storage-engine device {
            device /dev/@DISK@
            defrag-sleep 1000
            read-page-cache true
            stop-writes-avail-pct 5
            stop-writes-used-pct 90
        }
}
