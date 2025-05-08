#!/bin/sh
# CoreELEC 拼音插件依赖安装工具

# 定义路径
CONFIG_DIR="/storage/.config"
DOWNLOAD_DIR="/storage/downloads"
PLUGIN_ZIP_URL="https://github.com/simonhust/generate-pinyin/raw/main/script.globalsearch-master.zip"
ZIP_PATH="$DOWNLOAD_DIR/script.globalsearch-master.zip"

# 1. 安装 Entware
install_entware() {
    if [ ! -f "/opt/bin/opkg" ]; then
        echo "正在安装 Entware..."
        /storage/installentware.sh
        [ $? -ne 0 ] && echo "Entware 安装失败！" && exit 1
    else
        echo "Entware 已安装，跳过此步骤"
    fi
}

# 2. 更新 opkg
update_opkg() {
    echo "更新软件源..."
    opkg update
    [ $? -ne 0 ] && echo "opkg 更新失败！" && exit 2
}

# 3. 安装 pip
install_pip() {
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "正在安装 pip..."
        opkg install python3-pip
        [ $? -ne 0 ] && echo "pip 安装失败！" && exit 3
    else
        echo "pip 已安装，跳过此步骤"
    fi
}

# 4. 升级 pip
upgrade_pip() {
    echo "升级 pip..."
    python3 -m pip install --no-cache-dir --upgrade pip
    [ $? -ne 0 ] && echo "pip 升级失败！" && exit 4
}

# 5. 安装 pypinyin
install_pypinyin() {
    echo "安装 pypinyin 库..."
    python3 -m pip install pypinyin
    [ $? -ne 0 ] && echo "pypinyin 安装失败！" && exit 5
}

# 6. 下载插件到下载目录
download_plugin() {
    echo "创建下载目录..."
    mkdir -p $DOWNLOAD_DIR

    echo "正在下载插件..."
    wget -qO $ZIP_PATH $PLUGIN_ZIP_URL
    [ $? -ne 0 ] && echo "插件下载失败！" && exit 6

    echo "-----------------------------------------------"
    echo "插件已下载到：$ZIP_PATH"
    echo "请按以下步骤手动安装："
    echo "1. 进入 Kodi 主界面"
    echo "2. 选择 插件浏览器 ➔ 从ZIP文件安装"
    echo "3. 找到存储路径：/storage/downloads"
    echo "4. 选择 script.globalsearch-master.zip 安装"
    echo "-----------------------------------------------"
}

# 主安装流程
main() {
    echo "====== CoreELEC 拼音插件依赖安装程序 ======"
    install_entware
    update_opkg
    install_pip
    upgrade_pip
    install_pypinyin
    download_plugin
    echo "=============== 安装完成 ================="
    echo "注意：插件需要手动安装，请按上述提示操作"
}

# 执行主程序
main
