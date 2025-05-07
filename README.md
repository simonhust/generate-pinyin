# Kodi 拼音首字母生成工具

[![GitHub License](https://img.shields.io/github/license/simonhust/generate-pinyin)](LICENSE)

为 Kodi 视频库自动生成拼音首字母标记，支持电影 (`movie`) 和电视剧 (`tvshow`) 的增量更新。

## 功能特性

- 🚀 **全自动处理**：自动检测媒体库变更并触发更新
- 🔄 **增量更新**：仅处理新增/修改的记录，基于 `#PY` 标记
- 📦 **一键安装**：支持通过 GitHub 链接直接部署
- ⏲️ **可调间隔**：默认每1分钟检测一次（可自定义）
- 🌍 **国内优化**：内置清华 pip 镜像源加速依赖安装

## 安装指南

### 一键安装（推荐）

在 CoreELEC/LibreELEC 的 SSH 终端中执行：

```bash
curl -sL https://raw.githubusercontent.com/simonhust/generate-pinyin/main/install.sh | bash
