#!/bin/sh

# PPPoE 配置
uci set network.wan.proto=pppoe
uci set network.wan.username='t536020670645'  # 替换为实际的用户名
uci set network.wan.password='165445'  # 替换为实际的密码
uci commit network

# 默认wan口防火墙打开
uci set firewall.@zone[1].input='ACCEPT'
uci commit firewall

# 设置主机名映射，解决安卓原生TV首次连不上网的问题
uci add dhcp domain
uci set "dhcp.@domain[-1].name=time.android.com"
uci set "dhcp.@domain[-1].ip=203.107.6.88"
uci commit dhcp

# 设置所有网口可访问网页终端
uci delete ttyd.@ttyd[0].interface

# 设置所有网口可连接 SSH
uci set dropbear.@dropbear[0].Interface=''
uci commit