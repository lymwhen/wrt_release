# 京东云亚瑟路由器（jdcloud_ipq60xx）定制化文档

## 项目关系

- **本项目**: lymwhen/wrt_release（Fork）
- **上游项目**: ZqinKing/wrt_release（原始仓库）

本文档描述**本项目相对于上游 ZqinKing/wrt_release 的定制化**。

**定制化原则**: 本项目不主动进行结构性改动，为的是更好地跟进上游，而不是不接受上游来的重大变更。

---

## 上游项目简介

### 仓库地址
- **GitHub**: https://github.com/ZqinKing/wrt_release.git
- **分支**: main

### 上游文件结构
```
wrt_release/
├── .github/workflows/          # GitHub Actions 工作流
│   ├── build_wrt.yml          # 构建工作流
│   └── release_wrt.yml        # 发布工作流
├── wrt_core/                   # 核心模块
│   ├── compilecfg/            # 编译配置文件 (.ini)
│   ├── deconfig/              # 默认配置文件 (.config)
│   │   └── fragments/        # 配置片段目录
│   ├── modules/               # 模块化脚本
│   │   ├── custom_feed.sh    # custom_feed 管理
│   │   ├── verify.sh         # 验证脚本
│   │   ├── feed_source_fixes.sh  # feed 源修复
│   │   ├── package_source_updates.sh  # 包源更新
│   │   ├── service_fixes.sh  # 服务修复
│   │   └── packages.sh       # 入口脚本（加载上述模块）
│   ├── patches/               # 补丁文件
│   ├── scripts/               # 辅助脚本
│   ├── update.sh              # 更新逻辑
│   └── pre_clone_action.sh    # 预克隆操作
├── build.sh                    # 主编译脚本
└── README.md                   # 说明文档
```

### 上游目标设备
上游支持以下设备：
- 京东云系列：雅典娜(02)、亚瑟(01)、太乙(07)、AX5(JDC版)、百里
- 阿里云：AP8220
- 领势：MX4200v1、MX4200v2、MX4300
- 奇虎：360v6
- 红米：AX5、AX6
- CMCC：RAX3000M
- 斐讯：N1
- 兆能：M2
- Gemtek：W1701K
- Cudy：TR3000
- Nokia：040G-MD
- SuperGateway：S20M
- X64

### 上游软件包配置

上游通过 `custom_feed` 从以下仓库添加软件包：

1. **kenzok8/small-package** - 第三方软件包集合
   - 科学上网：xray-core、sing-box、hysteria、naiveproxy 等
   - 广告过滤：adguardhome
   - 工具：ddns-go、cups、easytier 等
   - LuCI 应用：luci-app-adguardhome、luci-app-ddns-go 等

2. **sbwml/luci-app-mosdns** - MosDNS DNS 工具
3. **Openwrt-Passwall/openwrt-passwall** - Passwall 科学上网工具
4. **nikkinikki-org/OpenWrt-nikki** - Nikki 科学上网工具
5. **adminchenyu/eMMC-Health** - eMMC 健康监控
6. **huchd0/luci-app-netwiz** - 上游新增的网络向导（本项目按定制优先不引入）
7. **rchen14b/luci-app-airoha-npu** - Airoha NPU 支持

### 上游配置片段系统

上游引入了配置片段（config fragments）系统：

**配置片段目录**: `wrt_core/deconfig/fragments/`
- `nss.config` - 高通 NSS 加速配置
- `docker_deps.config` - Docker 依赖配置
- `proxy.config` - 代理配置

**工作方式**:
- 在 `compilecfg/*.ini` 中通过 `CONFIG_FRAGMENTS` 参数指定片段
- 构建时自动从 `fragments/` 目录加载配置
- 支持通过工作流参数动态添加/移除片段

### 上游 GitHub Actions 工作流

#### 构建工作流 (`build_wrt.yml`)
- **触发方式**: 手动触发 (`workflow_dispatch`)
- **输入参数**:
  - `model`: 设备型号（下拉选择）
  - `add_fragments`: 添加配置片段（逗号分隔）
  - `remove_fragments`: 移除默认配置片段（逗号分隔）
- **构建环境**: Ubuntu 24.04

#### 发布工作流 (`release_wrt.yml`)
- 自动创建 GitHub Release
- 上传编译好的固件

---

## 本项目对上游的定制化

### 定制化概览

本项目跟进上游更新，同时保持以下定制化：

1. **配置片段**: 跟进上游配置片段系统，但不引入 docker 片段
2. **模块重构**: 跟进上游模块拆分结构
3. **新增软件包**: 添加 luci-app-emmc-health
4. **保持定制化**: 保留本项目已有的定制化内容

---

### 1. 配置片段系统跟进

本项目跟进上游的配置片段系统，但不引入 docker 片段：

**配置片段**:
- `nss.config` - 高通 NSS 加速配置
- `proxy.config` - 代理配置

**未引入的片段**:
- `docker_deps.config` - Docker 依赖配置（按精简原则不引入）

**compilecfg 文件更新**:
```ini
# jdcloud_ipq60xx_immwrt.ini
REPO_URL=https://github.com/VIKINGYFY/immortalwrt.git
REPO_BRANCH=main
BUILD_DIR=imm-nss
CONFIG_FRAGMENTS=nss,proxy
```

---

### 2. 模块重构跟进

本项目跟进上游的模块拆分结构：

**新增模块文件**:
- `wrt_core/modules/custom_feed.sh` - custom_feed 管理
- `wrt_core/modules/verify.sh` - 验证脚本
- `wrt_core/modules/feed_source_fixes.sh` - feed 源修复
- `wrt_core/modules/package_source_updates.sh` - 包源更新
- `wrt_core/modules/service_fixes.sh` - 服务修复
- `wrt_core/modules/packages.sh` - 入口脚本（加载上述模块）

**更新的文件**:
- `wrt_core/update.sh` - 更新逻辑，加载新模块
- `build.sh` - 主编译脚本，支持配置片段

---

### 3. 新增软件包

本项目跟进上游新增的软件包：

**新增软件包**: `luci-app-emmc-health`
- **作用**: eMMC 健康监控，监控 eMMC 存储寿命
- **来源**: adminchenyu/eMMC-Health.git
- **风险点**: 轻量级工具，无明显风险
- **可能的冲突**: 无

---

### 4. 保持本项目已有的定制化

本项目已有的定制化内容已保留，并根据本次 upstream 跟进调整主题：

#### 保留的软件包
- `luci-app-wolplus` - 网络唤醒工具（保留 `update_wolplus`）
- `quickstart`、`luci-app-quickstart`、`luci-app-store`、`luci-app-istorex` - 保留现有软件包源和修复逻辑

#### 主题调整
- 默认主题由 Argon 切换为 Vantage
- 使用 `anothaDev/luci-theme-vantage` 提供 `luci-theme-vantage` 与 `luci-app-vantage`
- 移除 Argon 主题源、`luci-app-argon-config` 和 `990_set_argon_primary`

#### 不引入的软件包
- 不引入 `luci-app-netwiz` 和 `luci-i18n-netwiz-zh-cn`
- 不同步 `huchd0/luci-app-netwiz`，避免替换现有 quickstart/store/istorex 定制

#### 新增的配置文件
- `jdcloud_ipq60xx_immwrt_nowifi_mini.config` - 无 WiFi 精简版配置
- `jdcloud_ipq60xx_immwrt_mini.config` - 精简版配置

---

## 变更记录

### 2026-11-12：跟进 upstream/main

- 合并至 upstream/main `0624835`，包括新设备配置、Passwall/SmartDNS 修复、miniupnpd 同步和 Lucky 3.4.1
- 保留 `jdcloud_ipq60xx_immwrt_mini` 与 `jdcloud_ipq60xx_immwrt_nowifi_mini` 定制配置
- 保留 EasyTier、Zerotier、WolPlus 和无 WiFi 精简配置
- 默认主题切换为 Vantage，移除 Argon 主题源和相关初始化补丁
- 不引入 NetWiz，继续保留 quickstart/store/istorex 软件包源与修复逻辑

---

## 版本说明

### WiFi 版本 (`jdcloud_ipq60xx_immwrt`)
- **配置文件**: `wrt_core/deconfig/jdcloud_ipq60xx_immwrt.config`
- **特点**: 包含完整无线驱动和固件，支持 WiFi 功能

### Nowifi_mini 版本 (`jdcloud_ipq60xx_immwrt_nowifi_mini`)
- **配置文件**: `wrt_core/deconfig/jdcloud_ipq60xx_immwrt_nowifi_mini.config`
- **特点**: 移除所有无线相关驱动和固件，适合纯有线环境

### Mini 版本 (`jdcloud_ipq60xx_immwrt_mini`)
- **配置文件**: `wrt_core/deconfig/jdcloud_ipq60xx_immwrt_mini.config`
- **特点**: 精简版，包含基本功能

---

## 后续跟进上游指南

### 1. 关注上游更新
- 定期检查上游 ZqinKing/wrt_release 的提交
- 特别关注 `wrt_core/` 目录的变化

### 2. 配置文件同步
- 对比上游 `jdcloud_ipq60xx_immwrt.config` 的变化
- 同步更新本项目的配置文件

### 3. 软件包更新
- 关注上游 `custom_feed` 的包列表变化
- 同步更新本项目的包配置

### 4. 新增设备支持
- 关注上游新增的设备支持
- 评估是否需要添加到本项目

### 5. 合并上游更新
```bash
# 获取上游更新
git fetch upstream

# 合并上游更新
git merge upstream/main

# 解决冲突（如有）
# ...

# 提交合并
git commit
```

---

## 相关链接

- **本项目**: https://github.com/lymwhen/wrt_release.git
- **上游项目**: https://github.com/ZqinKing/wrt_release.git
- **immortalwrt**: https://github.com/VIKINGYFY/immortalwrt.git
- **三方插件**: https://github.com/kenzok8/small-package.git
