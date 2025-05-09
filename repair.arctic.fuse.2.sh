#!/bin/sh
SKIN_PATH="/storage/.kodi/addons/skin.arctic.fuse.2"
SEARCH_XML="${SKIN_PATH}/shortcuts/generator/data/setup/search_path.xml"

# 安装xmlstarlet（若未安装）
if ! command -v xmlstarlet &> /dev/null; then
    echo "安装xmlstarlet中..."
    opkg update && opkg install xmlstarlet
fi

# 备份文件
cp "$SEARCH_XML" "${SEARCH_XML}.bak"

# 修改Movies规则
xmlstarlet ed -u '
    //rule[condition="{item_path}==DefaultSearch-Movies"]/value' \
    -v 'videodb://movies/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22' \
    "$SEARCH_XML" > "${SEARCH_XML}.tmp" && mv "${SEARCH_XML}.tmp" "$SEARCH_XML"

# 修改TvShows规则
xmlstarlet ed -u '
    //rule[condition="{item_path}==DefaultSearch-TvShows"]/value' \
    -v 'videodb://tvshows/titles/?xsp=%7B%22order%22%3A%7B%22direction%22%3A%22ascending%22%2C%22ignorefolders%22%3A0%2C%22method%22%3A%22sorttitle%22%7D%2C%22rules%22%3A%7B%22or%22%3A%5B%7B%22field%22%3A%22title%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22%22%5D%7D%2C%7B%22field%22%3A%22originaltitle%22%2C%22operator%22%3A%22contains%22%2C%22value%22%3A%5B%22' \
    "$SEARCH_XML" > "${SEARCH_XML}.tmp" && mv "${SEARCH_XML}.tmp" "$SEARCH_XML"

echo -e "\033[32m修复完成！请重启Kodi生效\033[0m"