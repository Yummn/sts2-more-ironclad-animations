# 更多铁甲战士动画（独立手机版）

- 移植版本：1.9.60-android.1
- 目标游戏：杀戮尖塔 2 Android v0.111.0
- 上游模组：[Steam 创意工坊「More Ironclad Animations」](https://steamcommunity.com/sharedfiles/filedetails/?id=3798368044)，Workshop ID `3798368044`
- 原作者：page
- 外部模组依赖：无

## 内容

为铁甲战士加入持盾、格挡、壁垒、壁撞、恶魔形态、战斗专注、黑暗之拥、耸肩无视、狂宴、放血、祭品、御血术等战斗动画与效果。动画资源位于 `spine/`、`blood/` 和 `offering/`。

## 手机版移植说明

保留原程序集 `ShieldOnly.dll`、Harmony 动画补丁和资源路径。将程序集内可选 BaseLib/JmcModLib 设置菜单的初始化改为只设定原版默认值（全部动画开启），不再探测或加载外部菜单程序集。`ShieldOnly.BaseLib.dll` 和 `ShieldOnly.Settings.dll` 不包含在包内；Manifest 的依赖列表为空。

本包按 Android v0.111.0 的游戏程序集进行了静态引用解析；核心逻辑仍为上游托管程序集，不含平台原生插件。

## 安装

1. 解压压缩包。
2. 将 `ShieldOnly` 文件夹复制到游戏/启动器实际使用的 `mods` 目录。
3. 确认目录中直接包含 `ShieldOnly.json`、`ShieldOnly.dll`、`spine/`、`blood/` 和 `offering/`。
4. 启动游戏并启用「更多战士动画（独立手机版）」。

不要与同 ID 的 Steam/旧版模组重复启用，否则 Harmony 动画补丁可能重复注册。

## 验证状态

- 原始 Workshop 包：127 项原始校验记录全部通过。
- v0.111.0 静态引用解析：核心程序集引用和方法/字段/类型引用均无未解析项。
- Windows v0.111.0 隔离游戏实测：成功加载；祭品、耸肩无视、壁垒、恶魔形态、黑暗之拥、壁撞均创建自定义视觉对象并完成出牌结算。具体结果见「验证报告.md」。
- Android 实机验证：本次 ADB 未检测到设备，未进行实机验证。

## 使用限制

本包默认全部动画开启，未提供逐项开关菜单。与替换战士身体/骨骼的皮肤同时使用时，依赖原骨骼的部分动画可能退回原版表现。这里只验证了单人战斗的上述六张牌，没有覆盖全部卡牌和多人模式。PC 运行结果不代表已完成 Android 性能测试。

## 移植源码

仓库的 `porting/` 提供 Mono.Cecil 适配工具及重建脚本；需要自行提供合法取得的上游包和 v0.111.0 游戏程序集，不分发游戏 DLL。

## 来源与许可

动画 DLL 和 `spine/`、`blood/`、`offering/` 资源取自 Workshop ID `3798368044` 的上游发布包。本移植仅对可选菜单初始化及手机 Manifest/说明做适配；原作者及其资源版权/许可保持不变。发布或再分发请遵循上游作者的 Workshop 许可。
