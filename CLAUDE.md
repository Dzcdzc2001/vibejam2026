# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在此仓库中工作时提供指导。

## 项目概述

"边境远征"（Frontier Expedition）—— 一款像素风 2.5D 俯视角 RPG，回合制战斗。
玩家扮演远征队长，从主城出发向四周扩张领土，与以灭绝生物为原型的怪物战斗。

## 引擎

Godot 4.6（Forward Plus 渲染器，Jolt Physics 3D，Windows 平台 D3D12）。
Godot 项目位于 `bianjingyuanzheng/` —— 使用 Godot 编辑器打开 `project.godot`。

## 构建与运行

```bash
# 在编辑器中打开
godot -e bianjingyuanzheng/project.godot

# 运行游戏
godot bianjingyuanzheng/project.godot

# 运行指定场景
godot bianjingyuanzheng/project.godot res://path/to/scene.tscn

# 运行测试（待测试套件就绪后）
godot -d -s --path bianjingyuanzheng addons/gut/gut_cmdln.gd
```

## 设计文档

仓库根目录的 `游戏玩法设定.md` 是主游戏设计文档（v1.0，概念设计阶段）。
在实现任何游戏系统之前应先阅读该文档。其定义的核心系统：

- **世界地图**：主城居中，向外辐射区域（东部火山地带 / 北部冰川区域），每个区域包含探索/精英/BOSS 节点
- **怪物生成**：三维叠加算法（地域 × 天气 × 灭绝生物数据库）
- **BOSS 战斗**：回合制 + AI 解析自由输入技能名称（玩家输入技能名，AI 评判创意值）
- **武器与材料**：BOSS 掉落 → 锻造升级，4 种武器类型（刀剑/弓弩/法杖/盾反）
- **动态天气**：影响战斗属性与稀有怪物出现率
- **玩家成长**：等级上限 60，自由属性点分配，图鉴收集提供永久加成
- **领土征服**：击败区域全部 BOSS → 区域变色为王国旗帜色，解锁快速传送

注意：设计文档推荐使用 Unity 2D，但实际引擎选用的是 Godot 4.6。

## 项目结构（规划中）

项目目前处于概念阶段 —— 尚无脚本或场景文件。设计文档建议的目录结构：

- `scenes/` —— Godot 场景文件（.tscn）
- `scripts/` —— GDScript 文件（.gd）
- `assets/` —— 像素美术资源、瓦片集
- `data/` —— 怪物、武器、天气的 JSON 配置文件
- `addons/` —— GUT（测试框架）及其他插件

## 代码风格

- 使用 GDScript（Godot 原生脚本语言）
- 遵循 GDScript 风格指南
- 类名/节点名使用 PascalCase，函数/变量使用 snake_case
- 在可行的前提下优先使用静态类型（类型化数组、类型化变量）
