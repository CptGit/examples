#!/bin/bash bash

sudo cp config.json.bak /etc/shadowsocks-libev/config.json
sudo systemctl restart shadowsocks-libev
