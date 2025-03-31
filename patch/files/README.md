  ### 要求
  要构建此项目，Debian 11 是首选。并且您需要使用基于 AMD64 架构的 CPU，至少 4GB RAM 和 25GB 可用磁盘空间。确保 __Internet__ 可访问。

  编译OpenWrt需要以下工具，不同发行版的包名称有所不同

  - 以下是 Debian11/Ubuntu22.04 用户的示例：<br/>
    - 方法一 :
      <details>
        <summary>通过 APT 设置依赖项</summary>

        ```bash
        sudo apt update -y
        sudo apt full-upgrade -y
        sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip python3-ply python3-docutils python3-pyelftools qemu-utils re2c rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip vim wget xmlto xxd zlib1g-dev zstd
        ```
      </details>
    - 方法二 :
      ```bash
      sudo bash -c 'bash <(curl -s https://git.kejizero.online/zhao/files/raw/branch/main/Rely/init_build_environment.sh)'
      ```

  - 以下是 Ubuntu24.04 用户的示例：<br/>
    - 方法一 :
      <details>
        <summary>通过 APT 设置依赖项</summary>

        ```bash
        sudo rm -rf /etc/apt/sources.list.d
        sudo bash -c "curl -skL https://git.kejizero.online/zhao/files/raw/branch/main/Rely/sources-24.04.list > /etc/apt/sources.list"
        sudo apt-get update
        sudo apt-get install -y build-essential flex bison cmake g++ gawk gcc-multilib g++-multilib gettext git gnutls-dev libfuse-dev libncurses5-dev libssl-dev python3 python3-pip python3-ply python3-pyelftools rsync unzip zlib1g-dev file wget subversion patch upx-ucl autoconf automake curl asciidoc binutils bzip2 lib32gcc-s1 libc6-dev-i386 uglifyjs msmtp texinfo libreadline-dev libglib2.0-dev xmlto libelf-dev libtool autopoint antlr3 gperf ccache swig coreutils haveged scons libpython3-dev rename qemu-utils jq
      ```

    - 方法二 :
      ```bash
      sudo bash -c 'bash <(curl -s https://git.kejizero.online/zhao/files/raw/branch/main/Rely/init_24.04_build.sh)'
      ```

  