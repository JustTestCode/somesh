#!/bin/bash

#日志类开始

decorate() {
    echo -e $@
}

gray() {
    echo -e "\033[90m$@\033[39m"
}

red() {
    echo -e "\033[91m$@\033[39m"
}

green() {
    echo -e "\033[92m$@\033[39m"
}

yellow() {
    echo -e "\033[93m$@\033[39m"
}

blue() {
    echo -e "\033[94m$@\033[39m"
}

magenta() {
    echo -e "\033[95m$@\033[39m"
}

cyan() {
    echo -e "\033[96m$@\033[39m"
}

light_gray() {
    echo -e "\033[97m$@\033[39m"
}

black() {
    echo -e "\033[30m$@\033[39m"
}

dark_red() {
    echo -e "\033[31m$@\033[39m"
}

dark_green() {
    echo -e "\033[32m$@\033[39m"
}

dark_yellow() {
    echo -e "\033[33m$@\033[39m"
}

dark_blue() {
    echo -e "\033[34m$@\033[39m"
}

dark_magenta() {
    echo -e "\033[35m$@\033[39m"
}

dark_cyan() {
    echo -e "\033[36m$@\033[39m"
}

white() {
    echo -e "\033[37m$@\033[39m"
}

light_purple() {
    if [[ -z $_PURPLE ]]; then
        _PURPLE=$(tput setaf 171)
    fi
    echo -e "${_PURPLE}$@\033[39m"
}

light_blue() {
    if [[ -z $_BLUE ]]; then
        _BLUE=$(tput setaf 38)
    fi
    echo -e "${_BLUE}$@\033[39m"
}

# export -f decorate
# export -f red
# export -f green
# export -f yellow
# export -f blue
# export -f magenta
# export -f cyan
# export -f dark_red
# export -f dark_green
# export -f dark_yellow
# export -f dark_blue
# export -f dark_magenta
# export -f dark_cyan

# Color variables

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)

Bold="\033[1m"
Dim="\033[2m"
Underlined="\033[4m"
Blink="\033[5m"
Reverse="\033[7m"
Hidden="\033[8m"

ResetBold="\033[21m"
ResetDim="\033[22m"
ResetUnderlined="\033[24m"
ResetBlink="\033[25m"
ResetReverse="\033[27m"
ResetHidden="\033[28m"

# Log functions
# Usage:
# e_header "ArchLinux Installation"

e_header() {
    light_purple "========== $@ =========="
}
e_arrow() {
    echo "==========|| ➜ $@ ||=========="
}

e_success() {
    green "==========|| ✔ $@ ||=========="
}
e_error() {
    dark_red "==========|| ✖ $@ ||=========="
}
e_warning() {
    dark_yellow $(e_arrow "$@")
}
e_underline() {
    printf "${underline}%s${reset}\n" "$@"
}
e_bold() {
    printf "${bold}%s${reset}\n" "$@"
}
e_note() {
    light_blue "${Underlined}${Bold}Note:${ResetBold}${ResetUnderlined} $@"
}

# has: Check if executable exist
# Usage:
# has tput
# has bash
# has foo
has() {
    if [[ $(type $1) = *"is"* ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Step function
# Usage:
# e_reset_step
# e_step "Install requirements"
# e_step "Install binaries"
# e_reset_step
# e_step "Another step"
e_step() {
    if [[ -z $_DE_COLOR ]]; then
        export _DE_COLOR="\033[39m"
    fi
    if [[ -z $_UNDERLINE ]]; then
        export _UNDERLINE="\033[4m"
        export _DE_UNDERLINE="\033[24m"
    fi
    if [[ -z $_BLUE ]]; then
        if [[ $(has tput) = "true" ]]; then
            _BLUE=$(tput setaf 38)
        else
            _BLUE="\033[94m"
        fi
    fi
    echo -en "${_UNDERLINE}${_BLUE}Step"
    # if [[ $(has expr) ]]; then
    export E_STEP=${E_STEP:-1}
    echo -en " $E_STEP"
    export E_STEP=$((E_STEP + 1))
    # fi
    echo -e ".${_DE_COLOR}${_DE_UNDERLINE} $@"
}

e_reset_step() {
    export E_STEP=
}

# Indent strings
# Usage:
# echo "haha" | indent 2
# cat file.txt | indent 1 4

indent() {
    local indentCount=1
    local indentWidth=2
    if [[ -n "$1" ]]; then indentCount=$1; fi
    if [[ -n "$2" ]]; then indentWidth=$2; fi
    pr -to $((indentCount * indentWidth))
}

eecho() {
    echo "$@" 1>&2
}

#日志类结束

#全局变量
fd_ver='8.4.0'
ssh_cert="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAr0xdTps65qvyHbwXks6Ik219y9nOa6oono1YQR20Gb03Gh8OOMLM/bijGsyNlI0Lh5ccwEexUGK1IvpLGqAty14wFPjvgYc5x6xOURuvuxSEgmKxNHsX97smIWvKqt8n6kOyjLSaGnbMT8KpNCTWy7IblhiJc8TvDh3LrXMMsCazX3T7n/nF4B1trQSESxsePir2UUrovm0LT2Z4F1nnFRMyEhOvie3EMqxG8XA/n463spHHMrtBpfCh+zcMijS7vt7W5fhFn+7GIngNfjWXHqkmEOXqzJ/WuNzDxbLMXUf5vsyovnHTMvaMpfjW+dzhHIWyBlRuxO6E7f/XAwLzmQ== root"

set_swapfile() {
    e_warning 配置虚拟内存
    Mem=$(free -m | awk '/Mem:/{print $2}')
    Swap=$(free -m | awk '/Swap:/{print $2}')
    if [ "$Swap" == '0' ]; then
        if [ $Mem -le 1024 ]; then
            MemCount=1024
        elif [ $Mem -gt 1024 ]; then
            MemCount=2048
        fi
        dd if=/dev/zero of=/swapfile count=$MemCount bs=1M
        sudo mkswap /swapfile
        sudo swapon /swapfile
        sudo chmod 600 /swapfile
        sudo [ -z "$(grep swapfile /etc/fstab)" ] && sudo echo '/swapfile    swap    swap    defaults    0 0' >>/etc/fstab
        e_success 虚拟内存设置完毕 $MemCount
    fi
    e_warning 虚拟内存无需配置

}

set_apt_source() {
    sudo cat >"/etc/apt/sources.list" <<EOF
deb http://deb.debian.org/debian bullseye main
deb-src http://deb.debian.org/debian bullseye main
deb http://security.debian.org/debian-security bullseye-security main
deb-src http://security.debian.org/debian-security bullseye-security main
deb http://deb.debian.org/debian bullseye-updates main
deb-src http://deb.debian.org/debian bullseye-updates main
deb http://deb.debian.org/debian bullseye-backports main
deb-src http://deb.debian.org/debian bullseye-backports main
EOF
    sudo apt update
}

set_init() {
    e_warning 初始化系统
    apt update
    apt install sudo -y
    e_warning 更新系统
    sudo apt update
    e_warning 安装常用库
    sudo apt install curl wget unzip zip jq lrzsz tmux -y
}

set_ssh() {
    e_warning "配置密钥登陆并禁用密码登录"
    mkdir /root/.ssh
    sudo echo $ssh_cert | cat >/root/.ssh/authorized_keys
    sudo chmod 600 /root/.ssh/authorized_keys
    sudo sed -i '/Protocol/d' /etc/ssh/sshd_config
    sudo echo "Protocol 2" >>/etc/ssh/sshd_config
    sudo sed -i "s/.*RSAAuthentication.*/RSAAuthentication yes/g" /etc/ssh/sshd_config
    sudo sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
    sudo sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config
    sudo sed -i "s/.*AuthorizedKeysFile.*/AuthorizedKeysFile\t\.ssh\/authorized_keys/g" /etc/ssh/sshd_config
    sudo sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
    sudo service sshd restart
    e_success "密钥配置完成"
}

set_ntp() {
    e_warning 安装时间同步ntp
    sudo apt install ntp -y
    sudo systemctl enable ntp
    sudo service ntp restart
    sudo ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    date
}

set_clean() {
    e_warning 一键清理垃圾
    sudo apt autoremove --purge
    sudo apt clean
    sudo apt autoclean
    sudo apt remove --purge $(dpkg -l | awk '/^rc/ {print $2}')
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s
    sudo journalctl --vacuum-size=50M
    sudo apt remove --purge $(dpkg -l | awk '/^ii linux-(image|headers)-[^ ]+/{print $2}' | grep -v $(uname -r | sed 's/-.*//') | xargs)
}

set_update() {
    e_warning 一键纯净更新
    sudo apt update -y
    sudo apt full-upgrade -y
    sudo apt autoremove -y
    sudo apt autoclean -y
}

app_docker() {
    e_warning 开始安装Docker
    curl -fsSL https://get.docker.com | bash -s docker
    e_warning 开始安装Docker-compose
    compose_ver=$(wget -qO- -t1 -T2 "https://api.github.com/repos/docker/compose/releases/latest" | jq -r '.tag_name')
    sudo curl -L "https://github.com/docker/compose/releases/download/$compose_ver/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/dc
    e_success Docker安装完毕
}
app_fd() {
    e_warning 开始安装fd
    wget https://github.com/sharkdp/fd/releases/download/v$fd_ver/fd_${fd_ver}_amd64.deb
    sudo dpkg -i fd_${fd_ver}_amd64.deb
    rm fd_${fd_ver}_amd64.deb
    e_success fd安装完毕
}
app_zsh() {
    e_warning 开始安装ZSH
    sudo apt install zsh git fonts-firacode -y
    e_warning 开始安装oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    wget http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme -O ~/.oh-my-zsh/themes/bullet-train.zsh-theme
    sed -i "s/ZSH_THEME=.*/ZSH_THEME='bullet-train'/" ~/.zshrc
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i "s/plugins=.*/plugins=(extract zsh-syntax-highlighting zsh-autosuggestions git)/" ~/.zshrc
    echo "source ~/.profile" >>~/.zshrc
    e_warning 设置zsh为默认shell
    sudo chsh -s /bin/zsh
    e_success "请手动执行 zsh 和 source ~/.zshrc  "
    #source ~/.zshrc
}
app_netclient() {
    curl -sL 'https://apt.netmaker.org/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/netclient.asc
    curl -sL 'https://apt.netmaker.org/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/netclient.list
    sudo apt update
    sudo apt install netclient -y
    sudo systemctl enable netclient
    sudo systemctl start netclient
}
app_kcptun() {
    e_warning 开始安装kcptun
    case $(uname -m) in
    x86_64) _cpu=amd64 ;;
    aarch64) _cpu=arm64 ;;
    esac
    mkdir /opt/kcptun
    curl -s https://api.github.com/repos/xtaci/kcptun/releases/latest | grep -woi "https.*$(uname).*${_cpu}.*gz" | xargs wget -O kcptun.tar.gz
    tar xvf kcptun.tar.gz -C /opt/kcptun && rm kcptun.tar.gz
    mv /opt/kcptun/server* /opt/kcptun/kcptun-server
    mv /opt/kcptun/client* /opt/kcptun/kcptun-client
    e_success kcptun安装完毕
}
clean_log() {
    echo >/var/log/wtmp
    echo >/var/log/btmp
    echo >/var/log/lastlog
    echo >/var/log/secure
    echo >/var/log/messages
    echo >/var/log/syslog
    echo >/var/log/xferlog
    echo >/var/log/auth.log
    echo >/var/log/user.log
    cat /dev/null >/var/adm/sylog
    cat /dev/null >/var/log/maillog
    cat /dev/null >/var/log/openwebmail.log
    cat /dev/null >/var/log/mail.info
    echo >/var/run/utmp
    echo >~/.bash_history
    history -c
    echo >.bash_history
}
e_error 开始执行脚本
for i in "$@"; do
    $i
done
e_error 脚本执行完毕
