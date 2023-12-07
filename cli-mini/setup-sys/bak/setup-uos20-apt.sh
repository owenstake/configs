# source lib.sh
DIR=$(dirname $(realpath $0))

# sudo yum -y install epel-release   # dnf fd-find ripgrep 都在这个仓库里
# yum repolist
# dnf makecache

# app install
# app="git telnet tar wget tmux vim python3-pip 
# 	fd-find ripgrep lua rpm-build"
app="git telnet tmux vim python3-pip lua rpm-build sshpass"
sudo yum install -y $app

# ninja for dpdk build
sudo yum install -y ninja-build meson

source ${DIR}/setup-base.sh

