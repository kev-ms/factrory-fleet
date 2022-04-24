#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "post-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create start" >> "$HOME/status"

# secrets are not available during on-create

mkdir -p "$HOME/.ssh"

if [ "$PAT" != "" ]
then
    echo "$PAT" > "$HOME/.ssh/akdc.pat"
    chmod 600 "$HOME/.ssh/akdc.pat"
fi

# add shared ssh key
echo "$AKDC_ID_RSA" | base64 -d > "$HOME/.ssh/id_rsa"
echo "$AKDC_ID_RSA_PUB" | base64 -d > "$HOME/.ssh/id_rsa.pub"

# set file mode
chmod 600 "$HOME"/.ssh/id*
chmod 600 "$HOME"/.ssh/certs.*
chmod 600 "$HOME"/.ssh/*.key

# update oh-my-zsh
git -C "$HOME/.oh-my-zsh" pull

# update repos
git -C ../webvalidate pull
git -C ../imdb-app pull
git -C ../inner-loop pull
git -C ../vtlog pull
git -C ../cli pull


az extension add -n azure-iot

sudo mkdir -p /k3d/var/lib/kubelet
sudo mkdir -p /k3d/etc/kubernetes
sudo chown -R "$USER":"$USER" /k3d

echo "/k3d/var/lib/kubelet /k3d/var/lib/kubelet none bind,shared" | sudo tee -a /etc/fstab
sudo mount -a


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
##        temporarily add the mount-a to ssh (which runs)
sudo sed -i "s/set -e/mount -a\n\nset -e/" /etc/init.d/ssh

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"
