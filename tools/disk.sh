DISKS=$(lsblk -o KNAME,MODEL | grep NVMe | awk '{print $1}')
                  
for disk in $DISKS;
 do
    blkdiscard /dev/${disk} -f;
    sleep 5;
    
    blkdiscard -z --length 8MiB /dev/${disk};
    sleep 5;
    
    echo "device /dev/$disk" >> disk.txt;
done


#Updating configuration for storage
sed -i -e "/@DISK@/{rdisk.txt" -e "d}" /etc/aerospike/aerospike.conf