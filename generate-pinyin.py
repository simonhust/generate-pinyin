import time
import requests
from pypinyin import pinyin, Style

class KodiUpdater:
    def __init__(self):
        self.api_url = "http://127.0.0.1:8080/jsonrpc"
        self.auth = ("kodi", "kodi")  # 修改为你的凭据
        self.marker = "#PY"
        self.check_interval = 60  # 5分钟检测一次
        self.last_counts = {'movie': 0, 'tvshow': 0}  # 内存存储状态

    def get_total_count(self, media_type):
        """获取当前总数"""
        response = requests.post(
            self.api_url,
            auth=self.auth,
            json={
                "jsonrpc": "2.0",
                "method": f"VideoLibrary.Get{media_type.capitalize()}s",
                "id": 1,
                "params": {
                    "limits": {"start": 0, "end": 1},
                    "properties": []
                }
            }
        )
        return response.json().get('result', {}).get('limits', {}).get('total', 0)

    def get_pinyin_initials(self, text):
        """生成拼音首字母"""
        if not text:
            return ""
        initials = pinyin(text, style=Style.FIRST_LETTER)
        return ''.join([i[0].upper() for i in initials if i]) + self.marker

    def process_media(self, media_type):
        """处理指定类型的未标记记录"""
        updated = 0
        result = requests.post(
            self.api_url,
            auth=self.auth,
            json={
                "jsonrpc": "2.0",
                "method": f"VideoLibrary.Get{media_type.capitalize()}s",
                "id": 2,
                "params": {
                    "properties": ["title"],
                    "filter": {
                        "field": "originaltitle",
                        "operator": "doesnotcontain",
                        "value": self.marker
                    }
                }
            }
        ).json()

        for item in result.get('result', {}).get(f"{media_type}s", []):
            new_value = self.get_pinyin_initials(item.get('title', ''))
            requests.post(
                self.api_url,
                auth=self.auth,
                json={
                    "jsonrpc": "2.0",
                    "method": f"VideoLibrary.Set{media_type.capitalize()}Details",
                    "id": 3,
                    "params": {
                        f"{media_type}id": item[f"{media_type}id"],
                        "originaltitle": new_value
                    }
                }
            )
            updated += 1
        return updated

    def run(self):
        """主监控循环"""
        # 初始化总数
        self.last_counts['movie'] = self.get_total_count('movie')
        self.last_counts['tvshow'] = self.get_total_count('tvshow')

        while True:
            try:
                # 获取当前总数
                current_movie = self.get_total_count('movie')
                current_tvshow = self.get_total_count('tvshow')

                # 检测变化
                if current_movie != self.last_counts['movie'] or \
                   current_tvshow != self.last_counts['tvshow']:

                    print("检测到库变化，开始更新...")
                    movie_updated = self.process_media('movie')
                    tvshow_updated = self.process_media('tvshow')
                    print(f"更新完成：电影{movie_updated} 电视剧{tvshow_updated}")

                    # 更新内存状态
                    self.last_counts['movie'] = current_movie
                    self.last_counts['tvshow'] = current_tvshow

                time.sleep(self.check_interval)

            except Exception as e:
                print(f"运行错误: {str(e)}")
                time.sleep(60)

if __name__ == '__main__':
    updater = KodiUpdater()
    updater.run()
