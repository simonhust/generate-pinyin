import json
import requests
import os
import xml.etree.ElementTree as ET
from pypinyin import pinyin, Style

class KodiPinyinUpdater:
    def __init__(self):
        self.url = "http://127.0.0.1:8080/jsonrpc"
        self.auth = self._load_kodi_credentials()

    def _get_kodi_config_path(self):
        """获取Kodi配置文件路径"""
        if os.name == 'nt':  # Windows
            return os.path.join(os.environ['APPDATA'], 'Kodi', 'userdata', 'guisettings.xml')
        else:  # Linux/macOS
            return os.path.expanduser("~/.kodi/userdata/guisettings.xml")

    def _load_kodi_credentials(self):
        """从Kodi配置文件中自动获取用户名密码"""
        config_file = self._get_kodi_config_path()
        
        try:
            tree = ET.parse(config_file)
            root = tree.getroot()
            
            webserver = root.find(".//webserver")
            username = webserver.find('webserverusername').text
            password = webserver.find('webserverpassword').text
            return (username, password)
        except Exception as e:
            print(f"自动获取认证失败: {str(e)}，使用默认凭据")
            return ('kodi', 'kodi')  # 默认值

    def get_pinyin_initials(self, text):
        """生成拼音首字母并添加标记"""
        if not text:
            return ""
        initials = pinyin(text, style=Style.FIRST_LETTER)
        return ''.join([i[0].upper() for i in initials if i]) + "☆"

    def call_api(self, method, params):
        """API调用核心方法"""
        try:
            response = requests.post(
                self.url,
                auth=self.auth,
                headers={'Content-Type': 'application/json'},
                data=json.dumps({
                    "jsonrpc": "2.0",
                    "id": 1,
                    "method": method,
                    "params": params
                })
            )
            return response.json()
        except Exception as e:
            print(f"API调用失败: {str(e)}")
            return None

    def check_for_updates(self, media_type):
        """检查是否存在需要更新的数据"""
        get_method = f"VideoLibrary.Get{media_type.capitalize()}s"
        params = {
            "properties": ["title"],
            "filter": {
                "field": "originaltitle",
                "operator": "doesnotcontain",
                "value": "☆"
            },
            "limits": {"start": 0, "end": 1}  # 只检查是否存在至少一条记录
        }
        
        result = self.call_api(get_method, params)
        if result and 'result' in result:
            return result['result'].get('limits', {}).get('total', 0) > 0
        return False

    def process_media(self, media_type):
        """通用媒体处理逻辑"""
        get_method = f"VideoLibrary.Get{media_type.capitalize()}s"
        set_method = f"VideoLibrary.Set{media_type.capitalize()}Details"
        id_field = f"{media_type}id"

        result = self.call_api(get_method, {
            "properties": ["title"],
            "filter": {
                "field": "originaltitle",
                "operator": "doesnotcontain",
                "value": "☆"
            }
        })

        if not result or 'result' not in result:
            return 0

        updated_count = 0
        for item in result['result'].get(f"{media_type}s", []):
            new_value = self.get_pinyin_initials(item.get('title', ''))
            update_result = self.call_api(set_method, {
                id_field: item[id_field],
                "originaltitle": new_value
            })
            if update_result and 'error' not in update_result:
                updated_count += 1

        return updated_count

    def run(self):
        """执行更新操作"""
        # 检查是否存在需要更新的数据
        need_movie_update = self.check_for_updates('movie')
        need_tvshow_update = self.check_for_updates('tvshow')
        
        if not need_movie_update and not need_tvshow_update:
            print("所有数据均已更新，无需操作。")
            return
        
        # 执行增量更新
        movie_count = self.process_media('movie')
        tvshow_count = self.process_media('tvshow')
        print(f"更新完成：电影 {movie_count} 部，电视剧 {tvshow_count} 部")

if __name__ == '__main__':
    updater = KodiPinyinUpdater()
    updater.run()
