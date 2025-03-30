#!/bin/bash

# Change default ip
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/luci2/bin/config_generate

# Change hostname
sed -i "s/hostname='.*'/hostname='ZeroWrt'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='ZeroWrt'/g" package/base-files/luci2/bin/config_generate

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# banner
cp -f $GITHUB_WORKSPACE/diy/banner  package/base-files/files/etc/banner

# Replace kernel
sed -i 's/6.12/6.6/g' target/linux/x86/Makefile

# Remove and update plugins
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/lang/golang

# The modified version is the compilation date
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by OPPEN321/g" package/lean/default-settings/files/zzz-default-settings
sed -i 's/LEDE/ZeroWrt/' package/lean/default-settings/files/zzz-default-settings

# Custom git
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Golang
git clone -b 24.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# adguardhome
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome

# OpenAppFilter
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# DDNS.to
git_sparse_clone main https://github.com/linkease/nas-packages-luci luci/luci-app-ddnsto
git_sparse_clone master https://github.com/linkease/nas-packages network/services/ddnsto

# MosDNS
git clone https://github.com/sbwml/luci-app-mosdns -b v5-lua package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Alist
git clone -b lua https://github.com/sbwml/luci-app-alist package/alist

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# 5G
git clone https://github.com/oppen321/5G-Modem-Support package/5G

# Scientific Internet plug-in
git clone --depth=1 -b master https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

