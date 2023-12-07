# source lib.sh

# function
command_exists() {
    command -v "$@" >/dev/null 2>&1
}
setup_color() {
    FMT_RED=$(printf '\033[31m')
    FMT_GREEN=$(printf '\033[32m')
    FMT_YELLOW=$(printf '\033[33m')
    FMT_BLUE=$(printf '\033[34m')
    FMT_BOLD=$(printf '\033[1m')
    FMT_RESET=$(printf '\033[0m')
}

function fmt_info() {
    printf '%sINFO: %s%s\n' "${FMT_GREEN}${FMT_BOLD}" "$*" "$FMT_RESET"
}

function fmt_error() {
    printf '%sERRO: [%s] %s%s\n' "${FMT_RED}${FMT_BOLD}" "$funcstack[2] $@" "$@" "$FMT_RESET"  1>&2
}

setup_color

# sudo yum -y install epel-release   # dnf fd-find ripgrep 都在这个仓库里
# yum repolist
# dnf makecache

# app install
sudo dnf config-manager --set-enabled crb
app="epel-release git telnet tar wget tmux vim python3-pip 
	fd-find ripgrep lua rpm-build"
sudo dnf install -y $app

# ninja
sudo dnf install ninja-build
sudo dnf --enablerepo=powertools install ninja-build  # centos 8

# python
sudo pip3 install meson

# check network proxy
if curl -s www.google.com --connect-timeout 3 > /dev/null; then
	fmt_info "Proxy ok."
else
	fmt_error "Proxy fail. Please check win10 v2ray is ok for 10809."
	fmt_error "1. win v2ray is ok for 10809 ?"
	fmt_error "2. win firewall is opened for wsl ?. If not, do the following command in powershell."
	fmt_error 'sudo Set-NetFirewallProfile -DisabledInterfaceAliases "vEthernet (WSL)".'
	exit
fi

export all_proxy=http://localhost:10809
# fzf
if [[ ! -e ~/.fzf ]]; then
	git clone https://github.com/junegunn/fzf.git ~/.fzf --depth 1
	~/.fzf/install --all  # --all for set short-cut <ctrl-t> <ctrl-r>
fi

if [[ ! -e ~/.zluarepo ]]; then
	git clone https://github.com/skywind3000/z.lua ~/.zluarepo --depth 1
	echo 'eval "$(lua ~/.zluarepo/z.lua --init bash)"' >> ~/.bashrc
fi


