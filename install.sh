#!/bin/sh

# 配置参数
ADDONS_DIR="/storage/.kodi/addons"
TEMPFILE="/tmp/check.tmp"
PYPI_GEN="/storage/generate-pinyin/generate-pinyin.py"
CRON_JOB="*/2 * * * * /usr/bin/python3 /storage/generate-pinyin/generate-pinyin.py"
SUPPORTED_SKINS="script.globalsearch skin.aeon.nox.silvo skin.arctic.fuse.2 skin.arctic.horizon.2 skin.confluence skin.estuary.*"

# 界面绘制函数
draw_interface() {
    clear
    # 上部：LOGO和标题
    echo -e "\033[34m
  ██████╗ ██████╗ ██████╗ ███████╗██╗     ███████╗███████╗ ██████╗
 ██╔════╝██╔═══██╗██╔══██╗██╔════╝██║     ██╔════╝██╔════╝██╔════╝
 ██║     ██║   ██║██████╔╝█████╗  ██║     █████╗  █████╗  ██║     
 ██║     ██║   ██║██╔══██╗██╔══╝  ██║     ██╔══╝  ██╔══╝  ██║     
 ╚██████╗╚██████╔╝██║  ██║███████╗███████╗███████╗███████╗╚██████╗
  ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝
\033[0m"
    echo -e "\033[32mCoreELEC 首拼搜索修复脚本 v1.2\033[0m"
    echo "========================================================"
}

# 依赖检查与修复
check_dependencies() {
    while true; do
        draw_interface
        echo -e "\033[33m[系统状态检测]\033[0m"
        
        # 检测状态
        error_found=0
        [ ! -x /opt/bin/opkg ] && {
            echo -e "1. Entware环境:\t❌ 未安装" 
            error_found=1
        } || echo -e "1. Entware环境:\t✅ 已安装"

        ! /opt/bin/python3 -c "import pypinyin" 2>/dev/null && {
            echo -e "2. 拼音支持库:\t❌ 未安装" 
            error_found=1
        } || echo -e "2. 拼音支持库:\t✅ 已安装"

        ! grep -q '<setting id="services.webserver">true</setting>' /storage/.kodi/userdata/guisettings.xml 2>/dev/null && {
            echo -e "3. 远程控制:\t❌ 未开启"
            error_found=1
        } || echo -e "3. 远程控制:\t✅ 已开启"

        [ ! -f "$PYPI_GEN" ] && {
            echo -e "4. 拼音生成脚本:\t❌ 未安装"
            error_found=1
        } || echo -e "4. 拼音生成脚本:\t✅ 已安装"

        echo "--------------------------------------------------------"
        
        # 依赖修复逻辑
        if [ $error_found -ne 0 ]; then
            echo -e "\033[31m检测到未满足的依赖项，请选择操作：\033[0m"
            echo "1. 自动修复依赖"
            echo "2. 退出脚本"
            read -p "请输入选择: " dep_choice
            
            case $dep_choice in
                1)
                    echo -e "\n\033[34m正在修复依赖...\033[0m"
                    # 安装Entware
                    [ ! -x /opt/bin/opkg ] && {
                        echo "安装Entware..."
                        installentware
                        echo -e "\033[33mEntware安装完成，请重启系统后重新运行本脚本！\033[0m"
                        exit 0
                    }
                    
                    # 安装pypinyin
                    ! /opt/bin/python3 -c "import pypinyin" 2>/dev/null && {
                        echo "更新软件源..."
                        /opt/bin/opkg update
                        echo "安装python3-pip..."
                        /opt/bin/opkg install python3-pip
                        echo "升级pip..."
                        /opt/bin/pip3 install --upgrade pip
                        echo "安装pypinyin..."
                        /opt/bin/pip3 install pypinyin
                    }
                    
                    # 开启远程控制
                    ! grep -q '<setting id="services.webserver">true</setting>' /storage/.kodi/userdata/guisettings.xml 2>/dev/null && {
                        echo "开启远程控制..."
                        sed -i 's/<setting id="services.webserver">false<\/setting>/<setting id="services.webserver">true<\/setting>/' /storage/.kodi/userdata/guisettings.xml
                    }

					install_pinyin_gen

                    echo -e "\033[32m依赖修复完成！\033[0m"
                    sleep 2
                    ;;
                2)
                    exit 0
                    ;;
                *)
                    echo "无效的选择！"
                    sleep 1
                    ;;
            esac
        else
            break
        fi
    done
}

# 安装拼音生成脚本
install_pinyin_gen() {
    [ ! -f "$PYPI_GEN" ] && {
        echo -e "\033[34m下载拼音生成脚本...\033[0m"
        mkdir -p /storage/generate-pinyin
        wget -qO "$PYPI_GEN" https://gh.llkk.cc/https://github.com/simonhust/generate-pinyin/blob/main/generate-pinyin.py
        
        echo -e "\033[34m设置定时任务...\033[0m"
        (crontab -l 2>/dev/null | grep -v "$PYPI_GEN"; echo "$CRON_JOB") | crontab -
        echo -e "\033[32m定时任务已添加（每2分钟运行）\033[0m"
        sleep 2
    }
}

# 皮肤修复处理
handle_skin_repair() {
    case $1 in
        "script.globalsearch")
            echo -e "\033[34m更新GlobalSearch组件...\033[0m"
            wget -qO /storage/.kodi/addons/script.globalsearch/lib/defs.py \
            https://gh.llkk.cc/https://github.com/simonhust/generate-pinyin/main/defs.py
            ;;
        "skin.aeon.nox.silvo")
            echo -e "\033[34m更新Aeon Nox皮肤文件...\033[0m"
            wget -qO /storage/.kodi/addons/skin.aeon.nox.silvo/16x9/custom_1125_LibrarySearch.xml \
            https://gh.llkk.cc/https://github.com/simonhust/generate-pinyin/main/custom_1125_LibrarySearch.xml
            ;;
        "skin.arctic.fuse.2")
            echo -e "\033[34m更新Arctic Fuse皮肤文件...\033[0m"
            wget -qO /storage/.kodi/addons/skin.arctic.fuse.2/shortcuts/generator/data/setup/search_path.xml \
            https://gh.llkk.cc/https://github.com/simonhust/generate-pinyin/main/search_path.xml
            ;;
        "skin.arctic.horizon.2")
            echo -e "\033[34m更新Arctic Horizon皮肤文件...\033[0m"
            wget -qO /storage/.kodi/addons/skin.arctic.horizon.2/shortcuts/template.xml \
            https://gh.llkk.cc/https://github.com/simonhust/generate-pinyin/main/template.xml
            ;;
        "skin.confluence")
            echo -e "\033[34m基于script.globalsearch插件的皮肤只需要更新搜索插件\033[0m"
            ;;
        "sskin.estuary.*")
            echo -e "\033[34m基于script.globalsearch插件的皮肤只需要更新搜索插件\033[0m"
            ;;
        *)
            echo -e "\033[31m暂不支持此皮肤/组件的自动修复！\033[0m"
            return 1
            ;;
    esac
    echo -e "\033[32m请重新加载皮肤或重启Kodi使更改生效！\033[0m"
    return 0
}

# 主流程
main() {
    check_dependencies
    install_pinyin_gen
    
    while true; do
        draw_interface
        echo -e "\033[33m[可用组件列表]\033[0m"
        skin_list=$(find $ADDONS_DIR -maxdepth 1 -type d \( -name 'skin.*' -o -name 'script.globalsearch' \) -exec basename {} \; | sort)
        
        # 显示支持状态（统一对齐）
        count=0
        for skin in $skin_list; do
            index=$((++count))
            if echo "$SUPPORTED_SKINS" | grep -qw "$skin"; then
                printf " \033[37m%2d.\033[0m %-28s \033[32m✅ 支持\033[0m\n" "$index" "$skin"
            else
                printf " \033[37m%2d.\033[0m %-28s \033[31m❌ 不支持\033[0m\n" "$index" "$skin"
            fi
        done
        
        # 退出项使用相同格式
        printf " \033[37m%2d.\033[0m %-28s\n" 0 "退出"
        
        read -p $'\n\033[31m输入要修复的组件编号: \033[0m' choice
        
        [ "$choice" = "0" ] && break
        
        if ! echo "$choice" | grep -qE "^[0-9]+$" || [ "$choice" -gt "$count" ]; then
            echo -e "\033[31m错误：无效的编号！\033[0m"
            sleep 1
            continue
        fi

        selected_skin=$(echo "$skin_list" | sed -n "${choice}p")
        if ! echo "$SUPPORTED_SKINS" | grep -qw "$selected_skin"; then
            echo -e "\033[31m该组件暂不支持自动修复！\033[0m"
            sleep 2
            continue
        fi
        
        handle_skin_repair "$selected_skin"
        echo -e "\n按回车键继续..."
        read
    done
    clear
}

# 执行主程序
main
