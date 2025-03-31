#!/bin/bash

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 输出颜色信息
echo -e "${GREEN}开始设置环境并更新系统...${NC}"

# 设置环境并更新系统
sudo apt-get install -y curl
sudo rm -rf /etc/apt/sources.list.d
sudo bash -c "curl -skL https://git.kejizero.online/zhao/files/raw/branch/main/Rely/sources-24.04.list > /etc/apt/sources.list"
sudo apt-get update

# 安装依赖包
echo -e "${BLUE}安装所需的依赖包...${NC}"
sudo apt-get install -y build-essential flex bison cmake g++ gawk gcc-multilib g++-multilib gettext git gnutls-dev \
  libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-pyelftools rsync unzip zlib1g-dev \
  file wget subversion patch upx-ucl autoconf automake curl asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs \
  msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils \
  haveged scons libpython3-dev rename qemu-utils jq genisoimage

# 清理 apt 缓存
sudo apt-get clean

# 克隆 OpenWrt 源码
echo -e "${YELLOW}克隆 OpenWrt 源码...${NC}"
git clone -b openwrt-24.10 --single-branch --filter=blob:none https://github.com/openwrt/openwrt

# 更新 feeds 并安装
cd openwrt || exit
echo -e "${GREEN}更新并安装 feeds...${NC}"
./scripts/feeds update -a
./scripts/feeds install -a

# scripts
curl -sO https://git.kejizero.online/zhao/files/raw/branch/main/ZeroWrt/01-prepare_package.sh
curl -sO https://git.kejizero.online/zhao/files/raw/branch/main/ZeroWrt/02-custom.sh
chmod 0755 *sh
bash 01-prepare_package.sh
bash 02-custom.sh

# 加载 .config
echo -e "${YELLOW}加载 .config${NC}"
curl -s https://git.kejizero.online/zhao/files/raw/branch/main/Config/x86_64.config > .config

# 生成默认配置
echo -e "${GREEN}生成默认配置...${NC}"
make defconfig

# 编译 ZeroWrt
echo -e "${BLUE}开始编译 ZeroWrt...${NC}"
echo -e "${YELLOW}使用所有可用的 CPU 核心进行并行编译...${NC}"
make -j$(nproc) || make -j1 || make -j1 V=s
  
# 输出编译完成的固件路径
echo -e "${GREEN}编译完成！固件已生成至：${NC} bin/targets"
