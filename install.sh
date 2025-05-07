#!/bin/sh
# CoreELEC 拼音生成脚本安装工具

# 定义路径
CONFIG_DIR="/storage/.config"
SCRIPT_NAME="generate-pinyin.py"
SCRIPT_PATH="$CONFIG_DIR/$SCRIPT_NAME"
AUTOSTART_FILE="$CONFIG_DIR/autostart.sh"

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

# 6. 下载脚本
download_script() {
    echo "下载生成脚本..."
    wget -qO $SCRIPT_PATH https://raw.githubusercontent.com/simonhust/generate-pinyin/main/generate-pinyin.py
    [ $? -ne 0 ] && echo "脚本下载失败！" && exit 6  # 退出码更新为6
    
    chmod +x $SCRIPT_PATH
    echo "脚本已保存到：$SCRIPT_PATH"
}

# 7. 配置自动启动
configure_autostart() {
    echo "配置自动启动..."
    
    # 创建 autostart.sh 如果不存在
    [ ! -f "$AUTOSTART_FILE" ] && touch $AUTOSTART_FILE
    
    # 检查是否已存在启动命令
    if ! grep -q "$SCRIPT_NAME" $AUTOSTART_FILE; then
        echo "nohup python3 $SCRIPT_PATH >/dev/null 2>&1 &" >> $AUTOSTART_FILE
        chmod +x $AUTOSTART_FILE
        echo "自动启动配置完成"
    else
        echo "自动启动已配置，跳过此步骤"
    fi
}

# 8. 启动脚本
start_script() {
    echo "启动脚本..."
    nohup python3 $SCRIPT_PATH >/dev/null 2>&1 &
    sleep 2
    if pgrep -f $SCRIPT_NAME >/dev/null; then
        echo "脚本已成功启动 (PID: $(pgrep -f $SCRIPT_NAME))"
    else
        echo "脚本启动失败！"
        exit 7  # 退出码更新为7
    fi
}

# 主安装流程
main() {
    echo "====== CoreELEC 拼音生成工具安装程序 ======"
    install_entware
    update_opkg
    install_pip
    upgrade_pip
    install_pypinyin  
    download_script
    configure_autostart
    start_script
    echo "=============== 安装完成 ================="
}

# 执行主程序
main
