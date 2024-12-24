#!/bin/bash -x

mkdir -p /var/log/aerospike
echo -e "Applying Aerospike Linux best practices \n"

# Set min_free_kbytes to allow OS minimum buffer memory
sync
echo 3 > /proc/sys/vm/drop_caches
sysctl vm.compact_memory=1
echo 1310720 > /proc/sys/vm/min_free_kbytes
grep -qF 'vm.min_free_kbytes=' /etc/sysctl.conf || echo "vm.min_free_kbytes=1310720" >> /etc/sysctl.conf

# turn off swappiness
echo 0 > /proc/sys/vm/swappiness
grep -qF 'vm.swappiness=' /etc/sysctl.conf || echo "vm.swappiness=0" >> /etc/sysctl.conf

# force linux to reload conf from /etc/sysctl.conf
sysctl -p

ulimit -Hn 100000
ulimit -Sn 100000
# turn off THP
echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null

cat << 'EOF' >/usr/local/bin/disable-transparent-huge-pages.sh
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    aerospike
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case $1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag

    re='^[0-1]+$'
    if [[ $(cat ${thp_path}/khugepaged/defrag) =~ $re ]]
    then
      echo 0  > ${thp_path}/khugepaged/defrag
    else
      echo 'no' > ${thp_path}/khugepaged/defrag
    fi

    unset re
    unset thp_path
    ;;
esac
EOF

chmod +x /usr/local/bin/disable-transparent-huge-pages.sh

/usr/local/bin/disable-transparent-huge-pages.sh

cat << 'EOF' > /etc/systemd/system/disable-transparent-huge-pages.service
[Unit]
Description=Disable Transparent Huge Pages

[Service]
Type=oneshot
ExecStart=/bin/bash  /usr/local/bin/disable-transparent-huge-pages.sh  start

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable disable-transparent-huge-pages.service

cat << 'EOF' > /etc/logrotate.d/aerospike
/var/log/aerospike/aerospike.log {
    daily
    rotate 90
    dateext
    compress
    olddir /var/log/aerospike/
    sharedscripts
    postrotate
        /bin/kill -HUP `pgrep -x asd`
    endscript
}
EOF