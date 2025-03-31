#!/bin/bash -e

export gitea=https://git.kejizero.online/zhao
export mirror==https://raw.githubusercontent.com/oppen321/ZeroWrt-Action/refs/heads/master

# 定义一个函数，用来克隆指定的仓库和分支
clone_repo() {
  # 参数1是仓库地址，参数2是分支名，参数3是目标目录
  repo_url=$1
  branch_name=$2
  target_dir=$3
  # 克隆仓库到目标目录，并指定分支名和深度为1
  git clone -b $branch_name --depth 1 $repo_url $target_dir
}

# 定义一些变量，存储仓库地址和分支名
immortalwrt_repo="https://github.com/immortalwrt/immortalwrt"
openwrt_repo="https://github.com/openwrt/openwrt.git"

# 开始克隆仓库，并行执行
clone_repo $immortalwrt_repo openwrt-24.10 immortalwrt &
clone_repo $openwrt_repo openwrt-24.10 openwrt &
# 等待所有后台任务完成
wait

# Enter source code
cd openwrt

# Init feeds
./scripts/feeds update -a
./scripts/feeds install -a

# Nginx
sed -i "s/large_client_header_buffers 2 1k/large_client_header_buffers 4 32k/g" feeds/packages/net/nginx-util/files/uci.conf.template
sed -i "s/client_max_body_size 128M/client_max_body_size 2048M/g" feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tclient_body_buffer_size 8192M;' feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tserver_names_hash_bucket_size 128;' feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -ri "/luci-webui.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations
sed -ri "/luci-cgi_io.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations

# uwsgi
sed -i 's,procd_set_param stderr 1,procd_set_param stderr 0,g' feeds/packages/net/uwsgi/files/uwsgi.init
sed -i 's,buffer-size = 10000,buffer-size = 131072,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's,logger = luci,#logger = luci,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile $gitea/files/raw/branch/main/root/.bash_profile
curl -so files/root/.bashrc $gitea/files/raw/branch/main/root/.bashrc

# make olddefconfig
wget -qO - https://raw.githubusercontent.com/oppen321/ZeroWrt-Action/refs/heads/master/patch/linux/0003-include-kernel-defaults.mk.patch | patch -p1

# 更换为 ImmortalWrt Uboot 以及 Target
rm -rf ./target/linux/rockchip
cp -rf ../immortalwrt/target/linux/rockchip ./target/linux/rockchip
rm -rf package/boot/{rkbin,uboot-rockchip,arm-trusted-firmware-rockchip}
cp -rf ../immortalwrt/package/boot/uboot-rockchip ./package/boot/uboot-rockchip
cp -rf ../immortalwrt/package/boot/arm-trusted-firmware-rockchip ./package/boot/arm-trusted-firmware-rockchip
sed -i '/REQUIRE_IMAGE_METADATA/d' target/linux/rockchip/armv8/base-files/lib/upgrade/platform.sh

curl -L -o include/kernel-6.6 https://raw.githubusercontent.com/immortalwrt/immortalwrt/refs/heads/openwrt-24.10/include/kernel-6.6

# default-settings
git clone --depth=1 -b openwrt-24.10 https://github.com/oppen321/default-settings package/default-settings

# Luci diagnostics.js
sed -i "s/openwrt.org/www.qq.com/g" feeds/luci/modules/luci-mod-network/htdocs/luci-static/resources/view/network/diagnostics.js

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# luci
pushd feeds/luci
    curl -s $mirror/patch/luci/0001-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -s $mirror/patch/luci/0002-luci-mod-status-displays-actual-process-memory-usage.patch | patch -p1
    curl -s $mirror/patch/luci/0003-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s $mirror/patch/luci/0004-luci-mod-status-storage-index-applicable-only-to-val.patch | patch -p1
    curl -s $mirror/patch/luci/0005-luci-mod-system-add-refresh-interval-setting.patch | patch -p1
    curl -s $mirror/patch/luci/0006-luci-mod-system-mounts-add-docker-directory-mount-po.patch | patch -p1  
popd

# module
curl -O https://raw.githubusercontent.com/oppen321/ZeroWrt-Action/refs/heads/master/patch/linux/0001-linux-module-video.patch
git apply 0001-linux-module-video.patch


# 移除 SNAPSHOT 标签
sed -i 's,-SNAPSHOT,,g' include/version.mk
sed -i 's,-SNAPSHOT,,g' package/base-files/image-config.in
sed -i '/CONFIG_BUILDBOT/d' include/feeds.mk
sed -i 's/;)\s*\\/; \\/' include/feeds.mk

# 替换软件包
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/utils/coremark
rm -rf feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/net/{socat.alist,zerotier,xray-core,v2ray-core,v2ray-geodata,sing-box,sms-tool}

# golong1.24依赖
git clone --depth=1 -b 24.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# helloworld
git clone --depth=1 -b helloworld https://github.com/oppen321/openwrt-package package/helloworld

# 加载软件源
git clone --depth=1 https://github.com/oppen321/openwrt-package package/openwrt-package

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://git.kejizero.online/zhao/luci-app-dockerman feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
git clone $gitea/packages_utils_docker feeds/packages/utils/docker
git clone $gitea/packages_utils_dockerd feeds/packages/utils/dockerd
git clone $gitea/packages_utils_containerd feeds/packages/utils/containerd
git clone $gitea/packages_utils_runc feeds/packages/utils/runc
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
    curl -s $mirror/patch/docker/0001-dockerd-fix-bridge-network.patch | patch -p1
    curl -s $mirror/patch/docker/0002-docker-add-buildkit-experimental-support.patch | patch -p1
    curl -s $mirror/patch/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch | patch -p1
popd

# UPnP
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
git clone $gitea/miniupnpd feeds/packages/net/miniupnpd -b v2.3.7
git clone $gitea/luci-app-upnp feeds/luci/applications/luci-app-upnp -b master

# opkg
mkdir -p package/system/opkg/patches
curl -s $mirror/patch/opkg/0001-opkg-download-disable-hsts.patch > package/system/opkg/patches/0001-opkg-download-disable-hsts.patch
curl -s $mirror/patch/opkg/0002-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch > package/system/opkg/patches/0002-libopkg-opkg_install-copy-conffiles-to-the-system-co.patch

# 主题设置
sed -i 's/bing/none/' package/openwrt-package/luci-app-argon-config/root/etc/config/argon
curl -L https://git.kejizero.online/zhao/files/raw/branch/main/images/bg1.jpg -o package/openwrt-package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i 's#<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a> /#<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a> /#' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/oppen321/ZeroWrt-Action" target="_blank">ZeroWrt-Action</a> |g' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
sed -i 's#<a class="luci-link" href="https://github.com/openwrt/luci" target="_blank">Powered by <%= ver.luciname %> (<%= ver.luciversion %>)</a> /#<a class="luci-link" href="https://www.kejizero.online" target="_blank">探索无限</a> /#' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
sed -i 's|<a href="https://github.com/jerrykuku/luci-theme-argon" target="_blank">ArgonTheme <%# vPKG_VERSION %></a>|<a href="https://github.com/oppen321/ZeroWrt-Action" target="_blank">ZeroWrt-Action</a> |g' package/openwrt-package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

# update feeds
./scripts/feeds update -a
./scripts/feeds install -a

# Load devices Config
if [ "$model" = "OpenWrt_Rockchip_v24.10" ]; then
    curl -s https://git.kejizero.online/zhao/files/raw/branch/main/toolchain/Configs/immortalwrt_rockchip.config > .config
elif [ "$model" = "OpenWrt_X86_64_v24.10" ]; then
    curl -s https://git.kejizero.online/zhao/files/raw/branch/main/toolchain/Configs/immortalwrt_x86_64.config > .config  
fi

# LTO
curl -s $mirror/generic/config-lto >> .config

# mold
echo 'CONFIG_USE_MOLD=y' >> .config

# gcc14 & 15
if [ "$USE_GCC13" = y ]; then
    export USE_GCC13=y gcc_version=13
elif [ "$USE_GCC14" = y ]; then
    export USE_GCC14=y gcc_version=14
fi

# gcc config
echo -e "\n# gcc ${gcc_version}" >> .config
echo -e "CONFIG_DEVEL=y" >> .config
echo -e "CONFIG_TOOLCHAINOPTS=y" >> .config
echo -e "CONFIG_GCC_USE_VERSION_${gcc_version}=y\n" >> .config

# Compile
make defconfig
make -j$cores toolchain/compile || make -j$cores toolchain/compile V=s || exit 1

# Create folder
mkdir toolchain-cache

# Compression toolchain
case "$model" in
    "OpenWrt_Rockchip_v24.10" | "OpenWrt_X86_64_v24.10")
        if [ -z "$gcc_version" ]; then
            echo "Error: GCC version not set!"
            exit 1
        fi

        if [ "$model" = "OpenWrt_Rockchip_v24.10" ]; then
            output_file="toolchain_musl_openwrt_rockchip_gcc-${gcc_version}.tar.zst"
        elif [ "$model" = "OpenWrt_X86_64_v24.10" ]; then
            output_file="toolchain_musl_openwrt_X86_64_gcc-${gcc_version}.tar.zst"
        fi

        tar -I zstd -cvf "toolchain-cache/${output_file}" build_dir dl tmp staging_dir
        ;;
    *)
        echo "Error: Unknown model '$model'!"
        exit 1
        ;;
esac
