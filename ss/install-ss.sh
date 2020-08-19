#!/bin/bash

_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PROJ_DIR="${_DIR}"

port=${1}; shift
config_file="${PROJ_DIR}/config.json.bak"

## Default port
if [[ -z ${port} ]]; then
        port=1984
else
        sed -i "s/server_port\":.*,$/server_port\":${port},/" "${config_file}"
fi

## Download yum repo and install shadowsocks-libev
(
        cd /etc/yum.repos.d/
        sudo wget https://copr.fedorainfracloud.org/coprs/librehat/shadowsocks/repo/epel-7/librehat-shadowsocks-epel-7.repo
)
sudo yum update
sudo yum install shadowsocks-libev

## Config shadowsocks-libev
sudo cp "${config_file}" /etc/shadowsocks-libev/config.json

## Enable shadowsocks-libev service
sudo systemctl enable shadowsocks-libev

## Config firewall
sudo firewall-cmd --zone=public --add-port=${port}/tcp --permanent
sudo firewall-cmd --zone=public	--add-port=${port}/udp --permanent
sudo firewall-cmd --reload
