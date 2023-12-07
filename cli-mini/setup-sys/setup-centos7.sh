# source lib.sh
apps="epel-release gcc git telnet tmux vim python3-pip lua
        rpm-build sshpass wget"
sudo yum install -y $apps

# ninja for dpdk build
sudo yum install -y ninja-build meson

source make.sh

