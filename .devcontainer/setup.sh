#!/bin/bash

# setup for factory AI app

# add the iot extension
az extension add -n azure-iot

# create shared directories / mounts
sudo mkdir -p /k3d/var/lib/kubelet
sudo mkdir -p /k3d/etc/kubernetes
sudo chown -R "$USER":"$USER" /k3d

echo "/k3d/var/lib/kubelet /k3d/var/lib/kubelet none bind,shared" | sudo tee -a /etc/fstab
sudo mount -a

# create init.d script
cat << EOF > mount
#! /bin/sh

### BEGIN INIT INFO
# Provides:          mount
# Required-Start:    \$local_fs \$remote_fs
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Mount fstab
### END INIT INFO

case "\$1" in
  start|reload|restart|force-reload)
        sudo mount -a
        ;;
  stop)
        echo "stop not implemented"
        ;;
  status)
        sudo mount | grep k3d
        ;;
  *)
        echo "Usage: \$N {start|stop|restart|force-reload|status}" >&2
        exit 1
        ;;
esac

exit 0

EOF

sudo mv mount /etc/init.d/mount
sudo chmod +x /etc/init.d/mount
sudo update-rc.d mount defaults

## todo - fix init.d - mount gets linked but doesn't run during boot
##        temporarily add the mount-a to sudo (which runs)
sudo sed -i "s/set -e/mount -a\n\nset -e/" /etc/init.d/sudo
