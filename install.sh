#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi:${plain} Phải chạy script này bằng quyền root!\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "alpine"; then
    release="alpine"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat|rocky|alma|oracle linux"; then
    release="centos"
elif cat /proc/version | grep -Eqi "arch"; then
    release="arch"
else
    echo -e "${red}Không phát hiện được phiên bản hệ thống, vui lòng liên hệ tác giả!${plain}\n" && exit 1
fi

arch=$(uname -m)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64-v8a"
elif [[ $arch == "s390x" ]]; then
    arch="s390x"
else
    arch="64"
    echo -e "${red}Phát hiện kiến trúc thất bại, sử dụng kiến trúc mặc định: ${arch}${plain}"
fi

echo "Kiến trúc: ${arch}"

if [ "$(getconf WORD_BIT)" != '32' ] && [ "$(getconf LONG_BIT)" != '64' ] ; then
    echo "Phần mềm này không hỗ trợ hệ thống 32-bit (x86), vui lòng sử dụng hệ thống 64-bit (x86_64). Nếu phát hiện sai, vui lòng liên hệ tác giả."
    exit 2
fi

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Vui lòng sử dụng CentOS 7 hoặc cao hơn!${plain}\n" && exit 1
    fi
    if [[ ${os_version} -eq 7 ]]; then
        echo -e "${red}Lưu ý: CentOS 7 không thể sử dụng giao thức hysteria1/2!${plain}\n"
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Vui lòng sử dụng Ubuntu 16 hoặc cao hơn!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Vui lòng sử dụng Debian 8 hoặc cao hơn!${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
        yum install epel-release wget curl unzip tar crontabs socat ca-certificates -y >/dev/null 2>&1
        update-ca-trust force-enable >/dev/null 2>&1
    elif [[ x"${release}" == x"alpine" ]]; then
        apk add wget curl unzip tar socat ca-certificates >/dev/null 2>&1
        update-ca-certificates >/dev/null 2>&1
    elif [[ x"${release}" == x"debian" ]]; then
        apt-get update -y >/dev/null 2>&1
        apt install wget curl unzip tar cron socat ca-certificates -y >/dev/null 2>&1
        update-ca-certificates >/dev/null 2>&1
    elif [[ x"${release}" == x"ubuntu" ]]; then
        apt-get update -y >/dev/null 2>&1
        apt install wget curl unzip tar cron socat -y >/dev/null 2>&1
        apt-get install ca-certificates wget -y >/dev/null 2>&1
        update-ca-certificates >/dev/null 2>&1
    elif [[ x"${release}" == x"arch" ]]; then
        pacman -Sy --noconfirm >/dev/null 2>&1
        pacman -S --noconfirm --needed wget curl unzip tar cron socat >/dev/null 2>&1
        pacman -S --noconfirm --needed ca-certificates wget >/dev/null 2>&1
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f /usr/local/V2bX/V2bX ]]; then
        return 2
    fi
    if [[ x"${release}" == x"alpine" ]]; then
        temp=$(service V2bX status | awk '{print $3}')
        if [[ x"${temp}" == x"started" ]]; then
            return 0
        else
            return 1
        fi
    else
        temp=$(systemctl status V2bX | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
        if [[ x"${temp}" == x"running" ]]; then
            return 0
        else
            return 1
        fi
    fi
}

install_V2bX() {
    if [[ -e /usr/local/V2bX/ ]]; then
        rm -rf /usr/local/V2bX/
    fi

    mkdir /usr/local/V2bX/ -p
    cd /usr/local/V2bX/

    if  [ $# == 0 ] ;then
        last_version=$(curl -Ls "https://api.github.com/repos/wyx2685/V2bX/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}Kiểm tra phiên bản V2bX thất bại, có thể do giới hạn API Github, vui lòng thử lại sau hoặc chỉ định phiên bản V2bX thủ công${plain}"
            exit 1
        fi
        echo -e "Đã phát hiện phiên bản V2bX mới nhất: ${last_version}, bắt đầu cài đặt"
        wget --no-check-certificate -N --progress=bar -O /usr/local/V2bX/V2bX-linux.zip https://github.com/wyx2685/V2bX/releases/download/${last_version}/V2bX-linux-${arch}.zip
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Tải V2bX thất bại, vui lòng đảm bảo server của bạn có thể tải file từ Github${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/wyx2685/V2bX/releases/download/${last_version}/V2bX-linux-${arch}.zip"
        echo -e "Bắt đầu cài đặt V2bX $1"
        wget --no-check-certificate -N --progress=bar -O /usr/local/V2bX/V2bX-linux.zip ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Tải V2bX $1 thất bại, vui lòng đảm bảo phiên bản này tồn tại${plain}"
            exit 1
        fi
    fi

    unzip V2bX-linux.zip
    rm V2bX-linux.zip -f
    chmod +x V2bX
    mkdir /etc/V2bX/ -p
    cp geoip.dat /etc/V2bX/
    cp geosite.dat /etc/V2bX/
    if [[ x"${release}" == x"alpine" ]]; then
        rm /etc/init.d/V2bX -f
        cat <<EOF > /etc/init.d/V2bX
#!/sbin/openrc-run

name="V2bX"
description="V2bX"

command="/usr/local/V2bX/V2bX"
command_args="server"
command_user="root"

pidfile="/run/V2bX.pid"
command_background="yes"

depend() {
        need net
}
EOF
        chmod +x /etc/init.d/V2bX
        rc-update add V2bX default
        echo -e "${green}V2bX ${last_version}${plain} Cài đặt hoàn tất, đã thiết lập tự khởi động"
    else
        rm /etc/systemd/system/V2bX.service -f
        cat <<EOF > /etc/systemd/system/V2bX.service
[Unit]
Description=V2bX Service
After=network.target nss-lookup.target
Wants=network.target

[Service]
User=root
Group=root
Type=simple
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=999999
WorkingDirectory=/usr/local/V2bX/
ExecStart=/usr/local/V2bX/V2bX server
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl stop V2bX
        systemctl enable V2bX
        echo -e "${green}V2bX ${last_version}${plain} Cài đặt hoàn tất, đã thiết lập tự khởi động"
    fi

    if [[ ! -f /etc/V2bX/config.json ]]; then
        cp config.json /etc/V2bX/
        echo -e ""
        echo -e "Cài đặt mới, vui lòng tham khảo hướng dẫn trước: https://v2bx.v-50.me/ để cấu hình các nội dung cần thiết"
        first_install=true
    else
        if [[ x"${release}" == x"alpine" ]]; then
            service V2bX start
        else
            systemctl start V2bX
        fi
        sleep 2
        check_status
        echo -e ""
        if [[ $? == 0 ]]; then
            echo -e "${green}V2bX Khởi động lại thành công${plain}"
        else
            echo -e "${red}V2bX có thể khởi động thất bại, vui lòng dùng lệnh 'V2bX log' để xem nhật ký. Nếu không thể khởi động, có thể bạn đã sửa sai định dạng cấu hình, vui lòng xem wiki: https://github.com/V2bX-project/V2bX/wiki${plain}"
        fi
        first_install=false
    fi

    if [[ ! -f /etc/V2bX/dns.json ]]; then
        cp dns.json /etc/V2bX/
    fi
    if [[ ! -f /etc/V2bX/route.json ]]; then
        cp route.json /etc/V2bX/
    fi
    if [[ ! -f /etc/V2bX/custom_outbound.json ]]; then
        cp custom_outbound.json /etc/V2bX/
    fi
    if [[ ! -f /etc/V2bX/custom_inbound.json ]]; then
        cp custom_inbound.json /etc/V2bX/
    fi
    curl -o /usr/bin/V2bX -Ls https://raw.githubusercontent.com/AZZ-vopp/V2bX-script/master/V2bX.sh
    chmod +x /usr/bin/V2bX
    if [ ! -L /usr/bin/v2bx ]; then
        ln -s /usr/bin/V2bX /usr/bin/v2bx
        chmod +x /usr/bin/v2bx
    fi
    cd $cur_dir
    rm -f install.sh
    echo -e ""
    echo "Cách sử dụng script quản lý V2bX (Tương thích với lệnh V2bX, không phân biệt chữ hoa thường): "
    echo "------------------------------------------"
    echo "V2bX              - Hiển thị menu quản lý (nhiều tính năng hơn)"
    echo "V2bX start        - Khởi động V2bX"
    echo "V2bX stop         - Dừng V2bX"
    echo "V2bX restart      - Khởi động lại V2bX"
    echo "V2bX status       - Xem trạng thái V2bX"
    echo "V2bX enable       - Bật tự khởi động V2bX"
    echo "V2bX disable      - Tắt tự khởi động V2bX"
    echo "V2bX log          - Xem nhật ký (log) V2bX"
    echo "V2bX x25519       - Tạo khóa x25519"
    echo "V2bX generate     - Tạo file cấu hình V2bX"
    echo "V2bX update       - Cập nhật V2bX"
    echo "V2bX update x.x.x - Cập nhật V2bX phiên bản chỉ định"
    echo "V2bX install      - Cài đặt V2bX"
    echo "V2bX uninstall    - Gỡ cài đặt V2bX"
    echo "V2bX version      - Xem phiên bản V2bX"
    echo "------------------------------------------"
    curl -fsS --max-time 10 "https://api.v-50.me/counter_v2bx" || true
    # Hỏi người dùng có muốn tạo file cấu hình cho lần đầu cài đặt không
    if [[ $first_install == true ]]; then
        read -rp "Phát hiện bạn cài đặt V2bX lần đầu, có muốn tự động tạo file cấu hình không? (y/n): " if_generate
        if [[ $if_generate == [Yy] ]]; then
            curl -o ./initconfig.sh -Ls https://raw.githubusercontent.com/AZZ-vopp/V2bX-script/master/initconfig.sh
            source initconfig.sh
            rm initconfig.sh -f
            generate_config_file
        fi
    fi
}

echo -e "${green}Bắt đầu cài đặt${plain}"
install_base
install_V2bX $1
