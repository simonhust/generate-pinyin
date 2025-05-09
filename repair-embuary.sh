#!/bin/sh
# Embuary 皮肤搜索规则修复工具（精准版）

# 配置参数
SKIN_NAME="skin.embuary.cpm"
SKIN_PATH="/storage/.kodi/addons/${SKIN_NAME}"
TARGET_XML="${SKIN_PATH}/xml/Embuary_Variables.xml"

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
modify_search_rule() {
    local variable_name="$1"
    local new_value="$2"
    
    xmlstarlet ed -P -L \
        -u "//variable[@name='$variable_name']/value/text()" \
        -v "$new_value" \
        "$TARGET_XML"
}

# Movies 规则（Local.SearchMovies）
MOVIES_VALUE='videodb://movies/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22$INFO[Skin.String(CustomSearchTerm)]%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22$INFO[Skin.String(CustomSearchTerm)]%22%5D%7D%5D%7D%2C%22type%22%3A%22movies%22%7D'
modify_search_rule "Local.SearchMovies" "$MOVIES_VALUE"

# TvShows 规则（Local.SearchShows）
TVSHOWS_VALUE='videodb://tvshows/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22$INFO[Skin.String(CustomSearchTerm)]%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22$INFO[Skin.String(CustomSearchTerm)]%22%5D%7D%5D%7D%2C%22type%22%3A%22tvshows%22%7D'
modify_search_rule "Local.SearchShows" "$TVSHOWS_VALUE"

echo -e "\033[32m[修复成功]\033[0m 已更新以下规则："
echo -e "- Movies 搜索路径（Local.SearchMovies）\n- TvShows 搜索路径（Local.SearchShows）"
echo "请重启 Kodi 使修改生效。"
