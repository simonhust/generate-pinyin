#!/bin/sh
# Aeon Nox Silvo 皮肤搜索规则修复工具

# 配置参数
SKIN_NAME="skin.aeon.nox.silvo"
SKIN_PATH="/storage/.kodi/addons/${SKIN_NAME}"
TARGET_XML="${SKIN_PATH}/16x9/custom_1125_LibrarySearch.xml"

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
[ ! -f "$TARGET_XML" ] && {
    echo -e "\033[31m错误：未找到文件 $TARGET_XML\033[0m"
    exit 1
}

# 备份文件
cp "$TARGET_XML" "${TARGET_XML}.bak" || {
    echo -e "\033[31m错误：无法创建备份文件\033[0m"
    exit 1
}

# 定义修改函数
modify_include_rule() {
    local include_id="$1"
    local new_content="$2"
    
    xmlstarlet ed -P -L \
        -u "//include[@content='ExtendedInfoListLayout']/param[@name='id' and text()='$include_id']/../param[@name='content']/text()" \
        -v "$new_content" \
        "$TARGET_XML"
}

# Movies 规则（id=5001）
MOVIES_CONTENT='$INFO[Window(Home).Property(library_search_string),videodb://movies/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%5D%7D%2C%22type%22%3A%22movies%22%7D]'
modify_include_rule "5001" "$MOVIES_CONTENT"

# TvShows 规则（id=5002）
TVSHOWS_CONTENT='$INFO[Window(Home).Property(library_search_string),videodb://tvshows/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%5D%7D%2C%22type%22%3A%22tvshows%22%7D]'
modify_include_rule "5002" "$TVSHOWS_CONTENT"

echo -e "\033[32m[修复成功]\033[0m 已更新以下规则："
echo -e "- Movies 搜索规则（ID 5001）\n- TvShows 搜索规则（ID 5002）"
echo "请重启 Kodi 使修改生效。"
