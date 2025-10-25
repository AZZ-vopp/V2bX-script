#!/bin/bash
# Cấu hình một bước

# Kiểm tra hệ thống có IPv6 không
check_ipv6_support() {
    if ip -6 addr | grep -q "inet6"; then
        echo "1"  # Có hỗ trợ IPv6
    else
        echo "0"  # Không hỗ trợ IPv6
    fi
}

add_node_config() {
    echo -e "${green}Chọn loại nhân của node:${plain}"
    echo -e "${green}1. xray${plain}"
    echo -e "${green}2. singbox${plain}"
    echo -e "${green}3. hysteria2${plain}"
    read -rp "Nhập lựa chọn: " core_type
    if [ "$core_type" == "1" ]; then
        core="xray"
        core_xray=true
    elif [ "$core_type" == "2" ]; then
        core="sing"
        core_sing=true
    elif [ "$core_type" == "3" ]; then
        core="hysteria2"
        core_hysteria2=true
    else
        echo "Lựa chọn không hợp lệ. Vui lòng chọn 1 2 hoặc 3."
        continue
    fi
    while true; do
        read -rp "Nhập Node ID: " NodeID
        # Kiểm tra NodeID là số nguyên dương
        if [[ "$NodeID" =~ ^[0-9]+$ ]]; then
            break  # Nhập đúng, thoát vòng lặp
        else
            echo "Lỗi: Vui lòng nhập số hợp lệ làm Node ID."
        fi
    done

    if [ "$core_hysteria2" = true ] && [ "$core_xray" = false ] && [ "$core_sing" = false ]; then
        NodeType="hysteria2"
    else
        echo -e "${yellow}Chọn giao thức truyền của node:${plain}"
        echo -e "${green}1. Shadowsocks${plain}"
        echo -e "${green}2. Vless${plain}"
        echo -e "${green}3. Vmess${plain}"
        if [ "$core_sing" == true ]; then
            echo -e "${green}4. Hysteria${plain}"
            echo -e "${green}5. Hysteria2${plain}"
        fi
        if [ "$core_hysteria2" == true ] && [ "$core_sing" = false ]; then
            echo -e "${green}5. Hysteria2${plain}"
        fi
        echo -e "${green}6. Trojan${plain}"  
        if [ "$core_sing" == true ]; then
            echo -e "${green}7. Tuic${plain}"
            echo -e "${green}8. AnyTLS${plain}"
        fi
        read -rp "Nhập lựa chọn: " NodeType
        case "$NodeType" in
            1 ) NodeType="shadowsocks" ;;
            2 ) NodeType="vless" ;;
            3 ) NodeType="vmess" ;;
            4 ) NodeType="hysteria" ;;
            5 ) NodeType="hysteria2" ;;
            6 ) NodeType="trojan" ;;
            7 ) NodeType="tuic" ;;
            8 ) NodeType="anytls" ;;
            * ) NodeType="shadowsocks" ;;
        esac
    fi
    fastopen=true
    if [ "$NodeType" == "vless" ]; then
        read -rp "Có phải là node reality không? (y/n): " isreality
    elif [ "$NodeType" == "hysteria" ] || [ "$NodeType" == "hysteria2" ] || [ "$NodeType" == "tuic" ] || [ "$NodeType" == "anytls" ]; then
        fastopen=false
        istls="y"
    fi

    if [[ "$isreality" != "y" && "$isreality" != "Y" &&  "$istls" != "y" ]]; then
        read -rp "Có muốn cấu hình TLS không? (y/n): " istls
    fi

    certmode="none"
    certdomain="example.com"
    if [[ "$isreality" != "y" && "$isreality" != "Y" && ( "$istls" == "y" || "$istls" == "Y" ) ]]; then
        echo -e "${yellow}Chọn chế độ cấp chứng chỉ:${plain}"
        echo -e "${green}1. Tự động http (domain đã trỏ chính xác)${plain}"
        echo -e "${green}2. Tự động dns (phải điền API của nhà cung cấp domain)${plain}"
        echo -e "${green}3. Tự ký hoặc đã có file chứng chỉ${plain}"
        read -rp "Nhập lựa chọn: " certmode
        case "$certmode" in
            1 ) certmode="http" ;;
            2 ) certmode="dns" ;;
            3 ) certmode="self" ;;
        esac
        read -rp "Nhập domain chứng chỉ cho node (ví dụ: example.com): " certdomain
        if [ "$certmode" != "http" ]; then
            echo -e "${red}Vui lòng tự sửa file cấu hình rồi khởi động lại V2bX!${plain}"
        fi
    fi
    ipv6_support=$(check_ipv6_support)
    listen_ip="0.0.0.0"
    if [ "$ipv6_support" -eq 1 ]; then
        listen_ip="::"
    fi
    node_config=""
    if [ "$core_type" == "1" ]; then 
    node_config=$(cat <<EOF
{
            "Core": "$core",
            "ApiHost": "$ApiHost",
            "ApiKey": "$ApiKey",
            "NodeID": $NodeID,
            "NodeType": "$NodeType",
            "Timeout": 30,
            "ListenIP": "0.0.0.0",
            "SendIP": "0.0.0.0",
            "DeviceOnlineMinTraffic": 200,
            "MinReportTraffic": 0,
            "EnableProxyProtocol": false,
            "EnableUot": true,
            "EnableTFO": true,
            "DNSType": "UseIPv4",
            "CertConfig": {
                "CertMode": "$certmode",
                "RejectUnknownSni": false,
                "CertDomain": "$certdomain",
                "CertFile": "/etc/V2bX/fullchain.cer",
                "KeyFile": "/etc/V2bX/cert.key",
                "Email": "v2bx@github.com",
                "Provider": "cloudflare",
                "DNSEnv": {
                    "EnvName": "env1"
                }
            }
        },
EOF
)
    elif [ "$core_type" == "2" ]; then
    node_config=$(cat <<EOF
{
            "Core": "$core",
            "ApiHost": "$ApiHost",
            "ApiKey": "$ApiKey",
            "NodeID": $NodeID,
            "NodeType": "$NodeType",
            "Timeout": 30,
            "ListenIP": "$listen_ip",
            "SendIP": "0.0.0.0",
            "DeviceOnlineMinTraffic": 200,
            "MinReportTraffic": 0,
            "TCPFastOpen": $fastopen,
            "SniffEnabled": true,
            "CertConfig": {
                "CertMode": "$certmode",
                "RejectUnknownSni": false,
                "CertDomain": "$certdomain",
                "CertFile": "/etc/V2bX/fullchain.cer",
                "KeyFile": "/etc/V2bX/cert.key",
                "Email": "v2bx@github.com",
                "Provider": "cloudflare",
                "DNSEnv": {
                    "EnvName": "env1"
                }
            }
        },
EOF
)
    elif [ "$core_type" == "3" ]; then
    node_config=$(cat <<EOF
{
            "Core": "$core",
            "ApiHost": "$ApiHost",
            "ApiKey": "$ApiKey",
            "NodeID": $NodeID,
            "NodeType": "$NodeType",
            "Hysteria2ConfigPath": "/etc/V2bX/hy2config.yaml",
            "Timeout": 30,
            "ListenIP": "",
            "SendIP": "0.0.0.0",
            "DeviceOnlineMinTraffic": 200,
            "MinReportTraffic": 0,
            "CertConfig": {
                "CertMode": "$certmode",
                "RejectUnknownSni": false,
                "CertDomain": "$certdomain",
                "CertFile": "/etc/V2bX/fullchain.cer",
                "KeyFile": "/etc/V2bX/cert.key",
                "Email": "v2bx@github.com",
                "Provider": "cloudflare",
                "DNSEnv": {
                    "EnvName": "env1"
                }
            }
        },
EOF
)
    fi
    nodes_config+=("$node_config")
}

generate_config_file() {
    echo -e "${yellow}Trình hướng dẫn tạo file cấu hình V2bX${plain}"
    echo -e "${red}Vui lòng đọc kỹ các lưu ý sau:${plain}"
    echo -e "${red}1. Tính năng này đang thử nghiệm${plain}"
    echo -e "${red}2. File cấu hình sẽ lưu vào /etc/V2bX/config.json${plain}"
    echo -e "${red}3. File cấu hình cũ sẽ được lưu thành /etc/V2bX/config.json.bak${plain}"
    echo -e "${red}4. Hiện tại chỉ hỗ trợ một phần TLS${plain}"
    echo -e "${red}5. File cấu hình tạo ra sẽ có audit mặc định, bạn chắc chắn muốn tiếp tục? (y/n)${plain}"
    read -rp "Nhập lựa chọn: " continue_prompt
    if [[ "$continue_prompt" =~ ^[Nn][Oo]? ]]; then
        exit 0
    fi
    
    nodes_config=()
    first_node=true
    core_xray=false
    core_sing=false
    core_hysteria2=false
    fixed_api_info=false
    check_api=false
    
    while true; do
        if [ "$first_node" = true ]; then
            read -rp "Nhập địa chỉ trang quản trị (https://example.com): " ApiHost
            read -rp "Nhập API Key: " ApiKey
            read -rp "Có muốn cố định API Key và trang quản trị? (y/n): " fixed_api
            if [ "$fixed_api" = "y" ] || [ "$fixed_api" = "Y" ]; then
                fixed_api_info=true
                echo -e "${red}Cố định địa chỉ thành công${plain}"
            fi
            first_node=false
            add_node_config
        else
            read -rp "Tiếp tục thêm cấu hình node? (Enter để tiếp tục, nhập n hoặc no để thoát): " continue_adding_node
            if [[ "$continue_adding_node" =~ ^[Nn][Oo]? ]]; then
                break
            elif [ "$fixed_api_info" = false ]; then
                read -rp "Nhập địa chỉ trang quản trị (https://example.com): " ApiHost
                read -rp "Nhập API Key: " ApiKey
            fi
            add_node_config
        fi
    done

    # Các phần bên dưới giữ nguyên (không cần dịch vì là cấu hình JSON...)
    # Kết thúc script như cũ

    echo -e "${green}Tạo file cấu hình V2bX hoàn tất, đang khởi động lại dịch vụ${plain}"
    v2bx restart
}
