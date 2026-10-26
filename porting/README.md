# 重新生成独立手机版

需要 .NET 9 SDK、PowerShell 7、原版 Workshop 3798368044 v1.9.60-wings.3 解压目录，以及 Android v0.111.0 的托管程序集引用目录。

运行：

```powershell
./Build-Mobile.ps1 -UpstreamDir 'D:/input/3798368044' -GameRefDir 'D:/input/v0.111.0' -OutputDir 'D:/output/ShieldOnly'
```

输出目录必须不存在。脚本检查上游校验清单、运行程序集引用审计、保留原动画资源并生成无依赖 Manifest；它不分发或安装游戏文件。GameRefDir 应含 sts2.dll、GodotSharp.dll、0Harmony.dll 及解析所需的 .NET 运行时引用。

适配内容：将 OptionalModSettings.Install 改成只初始化默认开关；调整程序集版本及启动日志。所有卡牌动画和原结算代码保留。Mono.Cecil 工具仅用于构建，运行 Mod 不需要安装它。

动画程序集及素材来自 page 的上游发布包，版权与许可遵循上游；本仓库的适配脚本不改变这些资源的归属。
