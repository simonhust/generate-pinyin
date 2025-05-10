import json
import requests
from pypinyin import pinyin, Style
import xml.etree.ElementTree as ET
import os

class KodiPinyinUpdater:
    def __init__(self, host='localhost', port=8080, username=None, password=None, guisettings_path=None):
        # 自动获取guisettings.xml路径
        if not guisettings_path:
            default_path = os.path.expanduser("~/.kodi/userdata/guisettings.xml")
            if os.path.exists(default_path):
                guisettings_path = default_path
            else:
                raise FileNotFoundError("未找到默认的guisettings.xml文件，请手动指定路径")

        # 解析XML获取用户名和密码
        self.username, self.password = self._parse_guisettings(guisettings_path)
        
        self.url = f"http://{host}:{port}/jsonrpc"
        self.auth = (self.username, self.password)
        self.marker = "@_@"

    def _parse_guisettings(self, path):
        """解析guisettings.xml获取Web服务器凭据"""
        try:
            tree = ET.parse(path)
            root = tree.getroot()
            
            # 定位用户名和密码节点
            username_node = root.find(".//setting[@id='services.webserverusername']")
            password_node = root.find(".//setting[@id='services.webserverpassword']")
            
            username = username_node.text if username_node is not None else "kodi"
            password = password_node.text if password_node is not None else ""
            
            return username, password
        except Exception as e:
            raise ValueError(f"解析guisettings.xml失败: {str(e)}")

    def get_pinyin_initials(self, text):
        """生成首拼首字母"""
        if not text:
            return ""
        initials = pinyin(text, style=Style.FIRST_LETTER)
        pinyin_part = ''.join([i[0].upper() for i in initials if i])
        return f"{text}{pinyin_part}{self.marker}"

    def call_api(self, method, params):
        """通用API调用方法"""
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

    def process_media(self, media_type):
        """通用处理逻辑（支持movie/tvshow）"""
        # 确定API方法
        get_method = f"VideoLibrary.Get{media_type.capitalize()}s"
        set_method = f"VideoLibrary.Set{media_type.capitalize()}Details"
        id_field = f"{media_type}id"  # movieid/tvshowid

        # 获取未处理记录
        result = self.call_api(get_method, {
            "properties": ["title", "originaltitle"],
            "filter": {
                "field": "originaltitle",
                "operator": "doesnotcontain",
                "value": self.marker
            }
        })

        if not result or 'result' not in result:
            print(f"获取{media_type}数据失败")
            return 0

        updated_count = 0
        for item in result['result'].get(f"{media_type}s", []):
            new_value = self.get_pinyin_initials(item.get('title', ''))

            # 更新记录
            update_result = self.call_api(set_method, {
                id_field: item[id_field],
                "originaltitle": new_value
            })

            if update_result and 'error' not in update_result:
                updated_count += 1

        return updated_count

    def run(self):
        movie_count = self.process_media('movie')
        tvshow_count = self.process_media('tvshow')
        summary_message = f"更新完成！电影：{movie_count}条，电视剧：{tvshow_count}条"
        print(summary_message)

        # 发送Kodi通知
        self.call_api("GUI.ShowNotification", {
            "title": "首拼更新结果",
            "message": summary_message
        })

if __name__ == '__main__':
    try:
        # 使用自动检测的路径，或手动指定路径
        updater = KodiPinyinUpdater(
            host='127.0.0.1',
            port=8080,
            guisettings_path="/storage/.kodi/userdata/guisettings.xml"  # 可选自定义路径
        )
        updater.run()
    except Exception as e:
        print(f"初始化失败: {str(e)}")
        
        # 执行增量更新
        movie_count = self.process_media('movie')
        tvshow_count = self.process_media('tvshow')
        print(f"更新完成：电影 {movie_count} 部，电视剧 {tvshow_count} 部")

if __name__ == '__main__':
    updater = KodiPinyinUpdater()
    updater.run()
