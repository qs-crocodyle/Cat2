-- -------------------------------------
-- 
-- Cat2 喵！
-- 发布者：妖姬变
-- 
-- 本插件纯粹个人爱好，完全免费，不作为任何商业化目的，可以随意在本插件基础上进行修改或扩展，我也是个普通玩家，如果哪天不玩了，就不再继续更新，请不要过于依赖一键宏。
-- 
-- 感谢制作过程中无数朋友的帮助，包括各职业打法经验分享、功能机制的实现脚本、设计思路、功能测试等等，Cat是无数朋友的共同努力结果。
--
-- -------------------------------------

-- 此文件必须在 TOC 第一位加载：负责创建所有模块共享的 Cat2 命名空间。
-- 界面、拖放、滚动和弹窗实现位于 UI 目录；卡片注册逻辑位于 Core 目录。
--
--[[
Cat2 架构速览（维护前建议先读本段）：

1. Core 基础层
   ClassSpecializations / CatLib / Buff / PlayerInformation 提供职业、技能书、Buff 与玩家快照。
   CatEvent-* 是旧职业机制需要的常驻事件数据，不属于流程卡片事件框架。

2. 卡片基础设施
   CardRegistry 统一登记卡片定义，并包装 RefreshRuntimeData、Apply、Validate、Execute。
   CardEventDispatcher 只把事件交给“当前配置中存在且已启用”的事件卡片。
   CastInterruptMonitor 负责治疗读条监控；异步阶段只提出请求，真正停止施法必须回到宏按键链。

3. Cards 定义层
   每个卡片文件在末尾调用 Cat2.RegisterCard(card)。卡片定义是全局唯一模板，不保存某个配置的状态。
   玩家拖入流程后产生 step 实例；enabled、minimizedVisible、optionValues 都属于 step。

4. 数据与执行层
   Persistence 仅保存角色级稳定数据；加载时根据卡片 ID 把函数重新绑定到 step。
   ConfigurationCodec 仅导入导出配置名、职业、卡片 ID、顺序、状态和卡片参数。
   ConfigurationRunner 每次 /cat2 配置名：处理中断请求 -> 刷新玩家快照 -> 应用被动 -> 校验 -> 顺序执行普通卡。

5. UI 层
   Controls 是无业务状态的基础控件；FlowEditor 编辑当前流程；ShortcutWindows 管理配置级快捷窗；
   ProfileManager 管理配置名称与快捷窗外观；ImportExport、Rules、Notice 为互斥弹窗。

必须保持的约束：
- 卡片 id 发布后视为存档协议；改名时应在 Persistence 的 legacyCardIds 中迁移。
- card.Execute(context, step) 返回 true 终止，false/nil 继续，Cat2.JumpTo(编号) 跳转；其他返回值视为 false。
- 主执行阶段每轮最多60步；暂停卡与被动预处理不计步，向前跳转不重置计数。
- 被动卡不依赖排列位置：执行器会先扫描整条流程并建立 context.parameters。
- 事件卡只有位于当前配置且 enabled 不为 0 时才接收事件；隐藏快捷窗图标不等于停用卡片。
- 不在事件或 OnUpdate 中执行受保护的施法、停法操作；这些操作必须由用户按键触发的流程完成。
- 项目兼容旧版 Lua，新增代码不要使用长度运算符或取模运算符。
]]

-- 插件根命名空间：新增公共函数与状态应挂在此表，避免污染游戏全局环境
Cat2 = Cat2 or {}
-- UI 子命名空间：仅用于跨 UI 文件共享的控件与窗口入口
Cat2.UI = Cat2.UI or {}

-- 用户可见的插件名称
Cat2.Name = "Cat2"

-- 版本
Cat2.Version = "2026-09-16"
