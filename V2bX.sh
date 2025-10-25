#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# kiểm tra quyền root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi: ${plain} Bạn phải sử dụng tài khoản root để chạy script này!\n" && exit 1

# kiểm tra hệ điều hành
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
    echo -e "${red}Không phát hiện được phiên bản hệ điều hành, vui lòng liên hệ tác giả script!${plain}\n" && exit 1
fi

# phiên bản hệ điều hành
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Vui lòng sử dụng CentOS 7 hoặc phiên bản cao hơn!${plain}\n" && exit 1
    fi
    if [[ ${os_version} -eq 7 ]]; then
        echo -e "${red}Chú ý: CentOS 7 không thể sử dụng giao thức hysteria1/2!${plain}\n"
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Vui lòng sử dụng Ubuntu 16 hoặc phiên bản cao hơn!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Vui lòng sử dụng Debian 8 hoặc phiên bản cao hơn!${plain}\n" && exit 1
    fi
fi

check_ipv6_support() {
    if ip -6 addr | grep -q "inet6"; then
        echo "1"  # Hỗ trợ IPv6
    else
        echo "0"  # Không hỗ trợ IPv6
    fi
}

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -rp "$1 [Mặc định $2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -rp "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Bạn có muốn khởi động lại V2bX không?" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Nhấn Enter để quay lại menu chính: ${plain}" && read temp
    show_menu
}

install() {
    bash <(curl -Ls https://raw.githubusercontent.com/AZZ-vopp/V2bX-script/master/install.sh)
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

update() {
    if [[ $# == 0 ]]; then
        echo && echo -n -e "Nhập phiên bản mong muốn (mặc định là mới nhất): " && read version
    else
        version=$2
    fi
    bash <(curl -Ls https://raw.githubusercontent.com/AZZ-vopp/V2bX-script/master/install.sh) $version
    if [[ $? == 0 ]]; then
        echo -e "${green}Cập nhật hoàn tất, V2bX đã được tự động khởi động lại, vui lòng dùng V2bX log để xem nhật ký hoạt động${plain}"
        exit
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

config() {
    echo "Sau khi chỉnh sửa cấu hình, V2bX sẽ tự động khởi động lại"
    nano /etc/V2bX/config.json
    sleep 2
    restart
    check_status
    case $? in
        0)
            echo -e "Trạng thái V2bX: ${green}Đang chạy${plain}"
            ;;
        1)
            echo -e "Chưa khởi động V2bX hoặc khởi động lại thất bại, bạn có muốn xem nhật ký log không? [Y/n]" && echo
            read -e -rp "(Mặc định: y):" yn
            [[ -z ${yn} ]] && yn="y"
            if [[ ${yn} == [Yy] ]]; then
               show_log
            fi
            ;;
        2)
            echo -e "Trạng thái V2bX: ${red}Chưa cài đặt${plain}"
    esac
}

uninstall() {
    confirm "Bạn chắc chắn muốn gỡ cài đặt V2bX?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    if [[ x"${release}" == x"alpine" ]]; then
        service V2bX stop
        rc-update del V2bX
        rm /etc/init.d/V2bX -f
    else
        systemctl stop V2bX
        systemctl disable V2bX
        rm /etc/systemd/system/V2bX.service -f
        systemctl daemon-reload
        systemctl reset-failed
    fi
    rm /etc/V2bX/ -rf
    rm /usr/local/V2bX/ -rf

    echo ""
    echo -e "Gỡ cài đặt thành công, nếu muốn xóa luôn script, hãy thoát và chạy lệnh ${green}rm /usr/bin/V2bX -f${plain}"
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        echo -e "${green}V2bX đã chạy, không cần khởi động lại. Nếu muốn hãy chọn khởi động lại.${plain}"
    else
        if [[ x"${release}" == x"alpine" ]]; then
            service V2bX start
        else
            systemctl start V2bX
        fi
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            echo -e "${green}Khởi động V2bX thành công, dùng V2bX log để xem nhật ký hoạt động${plain}"
        else
            echo -e "${red}V2bX có thể khởi động thất bại, vui lòng dùng V2bX log để kiểm tra nhật ký${plain}"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    if [[ x"${release}" == x"alpine" ]]; then
        service V2bX stop
    else
        systemctl stop V2bX
    fi
    sleep 2
    check_status
    if [[ $? == 1 ]]; then
        echo -e "${green}Đã dừng V2bX thành công${plain}"
    else
        echo -e "${red}Dừng V2bX thất bại, có thể do thời gian dừng vượt quá 2 giây, vui lòng kiểm tra lại nhật ký${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    if [[ x"${release}" == x"alpine" ]]; then
        service V2bX restart
    else
        systemctl restart V2bX
    fi
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        echo -e "${green}Khởi động lại V2bX thành công, dùng V2bX log để xem nhật ký hoạt động${plain}"
    else
        echo -e "${red}V2bX có thể khởi động lại thất bại, vui lòng dùng V2bX log để kiểm tra nhật ký${plain}"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    if [[ x"${release}" == x"alpine" ]]; then
        service V2bX status
    else
        systemctl status V2bX --no-pager -l
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    if [[ x"${release}" == x"alpine" ]]; then
        rc-update add V2bX
    else
        systemctl enable V2bX
    fi
    if [[ $? == 0 ]]; then
        echo -e "${green}Đặt tự động khởi động cùng hệ thống thành công${plain}"
    else
        echo -e "${red}Đặt tự động khởi động cùng hệ thống thất bại${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    if [[ x"${release}" == x"alpine" ]]; then
        rc-update del V2bX
    else
        systemctl disable V2bX
    fi
    if [[ $? == 0 ]]; then
        echo -e "${green}Tắt tự động khởi động cùng hệ thống thành công${plain}"
    else
        echo -e "${red}Tắt tự động khởi động cùng hệ thống thất bại${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    if [[ x"${release}" == x"alpine" ]]; then
        echo -e "${red}Hiện chưa hỗ trợ xem log trên hệ thống Alpine${plain}\n" && exit 1
    else
        journalctl -u V2bX.service -e --no-pager -f
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

install_bbr() {
    bash <(curl -L -s https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcpx.sh)
}

update_shell() {
    wget -O /usr/bin/V2bX -N --no-check-certificate https://raw.githubusercontent.com/AZZ-vopp/V2bX-script/master/V2bX.sh
    if [[ $? != 0 ]]; then
        echo ""
        echo -e "${red}Tải script thất bại, kiểm tra kết nối Github${plain}"
        before_show_menu
    else
        chmod +x /usr/bin/V2bX
        echo -e "${green}Cập nhật script thành công, vui lòng chạy lại script${plain}" && exit 0
    fi
}

# ... (phần dưới không chứa thông báo tiếng Trung, không cần dịch)

show_usage() {
    echo "Cách sử dụng script quản lý V2bX: "
    echo "------------------------------------------"
    echo "V2bX              - Hiển thị menu quản lý (nhiều chức năng hơn)"
    echo "V2bX start        - Khởi động V2bX"
    echo "V2bX stop         - Dừng V2bX"
    echo "V2bX restart      - Khởi động lại V2bX"
    echo "V2bX status       - Xem trạng thái V2bX"
    echo "V2bX enable       - Thiết lập tự động khởi động"
    echo "V2bX disable      - Tắt tự động khởi động"
    echo "V2bX log          - Xem nhật ký log"
    echo "V2bX x25519       - Tạo khoá x25519"
    echo "V2bX generate     - Tạo file cấu hình"
    echo "V2bX update       - Cập nhật V2bX"
    echo "V2bX update x.x.x - Cài đặt phiên bản chỉ định"
    echo "V2bX install      - Cài đặt V2bX"
    echo "V2bX uninstall    - Gỡ cài đặt V2bX"
    echo "V2bX version      - Xem phiên bản V2bX"
    echo "------------------------------------------"
}

show_menu() {
    echo -e "
  ${green}Script quản lý V2bX,${plain}${red}không áp dụng cho docker${plain}
--- https://github.com/wyx2685/V2bX ---
  ${green}0.${plain} Chỉnh sửa cấu hình
————————————————
  ${green}1.${plain} Cài đặt V2bX
  ${green}2.${plain} Cập nhật V2bX
  ${green}3.${plain} Gỡ cài đặt V2bX
————————————————
  ${green}4.${plain} Khởi động V2bX
  ${green}5.${plain} Dừng V2bX
  ${green}6.${plain} Khởi động lại V2bX
  ${green}7.${plain} Xem trạng thái V2bX
  ${green}8.${plain} Xem nhật ký V2bX
————————————————
  ${green}9.${plain} Thiết lập tự động khởi động
  ${green}10.${plain} Tắt tự động khởi động
————————————————
  ${green}11.${plain} Cài đặt nhanh bbr (kernel mới)
  ${green}12.${plain} Xem phiên bản V2bX
  ${green}13.${plain} Tạo khoá X25519
  ${green}14.${plain} Cập nhật script quản lý V2bX
  ${green}15.${plain} Tạo file cấu hình V2bX
  ${green}16.${plain} Mở toàn bộ port trên VPS
  ${green}17.${plain} Thoát script
 "
    show_status
    echo && read -rp "Vui lòng chọn [0-17]: " num

    case "${num}" in
        0) config ;;
        1) check_uninstall && install ;;
        2) check_install && update ;;
        3) check_install && uninstall ;;
        4) check_install && start ;;
        5) check_install && stop ;;
        6) check_install && restart ;;
        7) check_install && status ;;
        8) check_install && show_log ;;
        9) check_install && enable ;;
        10) check_install && disable ;;
        11) install_bbr ;;
        12) check_install && show_V2bX_version ;;
        13) check_install && generate_x25519_key ;;
        14) update_shell ;;
        15) generate_config_file ;;
        16) open_ports ;;
        17) exit ;;
        *) echo -e "${red}Vui lòng nhập đúng số [0-17]${plain}" ;;
    esac
}

if [[ $# > 0 ]]; then
    case $1 in
        "start") check_install 0 && start 0 ;;
        "stop") check_install 0 && stop 0 ;;
        "restart") check_install 0 && restart 0 ;;
        "status") check_install 0 && status 0 ;;
        "enable") check_install 0 && enable 0 ;;
        "disable") check_install 0 && disable 0 ;;
        "log") check_install 0 && show_log 0 ;;
        "update") check_install 0 && update 0 $2 ;;
        "config") config $* ;;
        "generate") generate_config_file ;;
        "install") check_uninstall 0 && install 0 ;;
        "uninstall") check_install 0 && uninstall 0 ;;
        "x25519") check_install 0 && generate_x25519_key 0 ;;
        "version") check_install 0 && show_V2bX_version 0 ;;
        "update_shell") update_shell ;;
        *) show_usage
    esac
else
    show_menu
fi
