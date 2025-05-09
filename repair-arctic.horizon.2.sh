#!/bin/sh
# Arctic Horizon 2 皮肤搜索规则修复工具（xmlstarlet 版本）

# 配置参数
SKIN_PATH="/storage/.kodi/addons/skin.arctic.horizon.2"
TEMPLATE_XML="${SKIN_PATH}/shortcuts/template.xml"

# 检查依赖项
if ! command -v xmlstarlet >/dev/null 2>&1; then
    echo -e "\033[31m错误：需要安装 xmlstarlet 工具\033[0m"
    echo "正在尝试自动安装..."
    opkg update && opkg install xmlstarlet || {
        echo -e "\033[31m安装失败，请手动安装后重试\033[0m"
        exit 1
    }
fi

# 检查文件是否存在
[ ! -f "$TEMPLATE_XML" ] && {
    echo -e "\033[31m错误：未找到文件 $TEMPLATE_XML\033[0m"
    exit 1
}

# 备份文件
cp "$TEMPLATE_XML" "${TEMPLATE_XML}.bak" || {
    echo -e "\033[31m错误：无法创建备份文件\033[0m"
    exit 1
}

# 定义修改函数
modify_rule() {
    local target="$1"
    local new_value="$2"
    
    xmlstarlet ed -P -L \
        -u "//property[@name='widgetPath' and contains(@value,'$target')]/text()" \
        -v "$new_value" \
        "$TEMPLATE_XML"
}

# 修改 Movies 规则
modify_rule "DefaultSearch-Movies" \
'videodb://movies/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22'

# 修改 TvShows 规则
modify_rule "DefaultSearch-TvShows" \
'videodb://tvshows/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22'

echo -e "\033[32m[修复成功]\033[0m 搜索规则已更新！请重启Kodi生效。"