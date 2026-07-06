# 调试面板

## 概述

调试面板提供了可视化的开发调试工具，帮助开发者查看和调试事件总线的运行状态。

## 功能模块

| 模块 | 功能 |
|------|------|
| **统计概览** | 事件总数、监听器数量、事件类型分布、运行状态 |
| **实时事件流** | 实时显示事件列表、优先级、暂停/继续 |
| **历史记录** | 事件历史列表、按类型筛选、事件详情 |
| **监听器管理** | 监听器列表、移除单个/全部监听器 |
| **日志查看** | 实时日志、级别过滤、暂停/继续、导出 |
| **调试工具** | 发送测试事件、系统操作、批量模式切换 |

## 打开方式

### 方式一：标准方式

```dart
globalEventBus.debug.show(context);
```

### 方式二：悬浮按钮

```dart
// 在 initState 中显示悬浮按钮
WidgetsBinding.instance.addPostFrameCallback((_) {
  globalEventBus.debug.showFloating(context);
});

// 隐藏悬浮按钮
globalEventBus.debug.hideFloating();
```

### 方式三：路由名称

```dart
// 在 MaterialApp 中注册路由
routes: {
  '/geb_debug': (_) => globalEventBus.debug.panel,
}

// 调用
globalEventBus.debug.pushNamed(context);
```

### 方式四：模态弹窗

```dart
globalEventBus.debug.showModal(context);
```

## 使用示例

### 在开发环境中自动显示

```dart
void main() {
  runApp(const MyApp());
  
  if (kDebugMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 自动显示悬浮按钮
      globalEventBus.debug.showFloating(
        navigatorKey.currentContext!,
        icon: Icons.bug_report,
        color: Colors.deepPurple,
      );
    });
  }
}
```

### 通过按钮打开

```dart
FloatingActionButton(
  onPressed: () => globalEventBus.debug.show(context),
  child: const Icon(Icons.developer_mode),
);
```

## 调试面板功能详解

### 统计概览

显示事件总线的运行状态：
- 已发送事件数
- 已接收事件数
- 当前监听器数量
- 事件类型分布（图表）
- 批量模式状态
- 历史记录状态

### 实时事件流

实时显示最近发送的事件：
- 事件类型
- 事件数据
- 优先级标识（颜色区分）
- 时间戳
- 暂停/继续按钮
- 清空按钮

### 历史记录

显示已记录的历史事件：
- 事件列表
- 按类型筛选
- 事件详情查看
- 搜索功能（通过调试工具）

### 监听器管理

管理当前注册的监听器：
- 监听器 ID 列表
- 监听的事件类型
- 状态标识
- 移除单个监听器
- 移除所有监听器

### 日志查看

查看实时日志：
- 日志级别过滤（debug/info/warning/error）
- 暂停/继续日志接收
- 清空日志
- 导出日志到控制台

### 调试工具

提供各种调试操作：
- 发送测试事件
- 清空历史记录
- 重置统计数据
- 切换批量模式
- 导出数据为 JSON

## 配置选项

### 悬浮按钮配置

```dart
globalEventBus.debug.showFloating(
  context,
  icon: Icons.bug_report,        // 自定义图标
  color: Colors.deepPurple,       // 按钮颜色
  offset: const Offset(16, 16),   // 距离右下角的偏移量
);
```

### 键盘快捷键（计划中）

```dart
// Ctrl+Shift+D 打开调试面板
globalEventBus.debug.enableShortcuts(context);
```

## 生产环境

调试面板仅在开发环境使用，建议通过 `kDebugMode` 条件判断：

```dart
if (kDebugMode) {
  globalEventBus.debug.showFloating(context);
}
```

## 注意事项

1. 调试面板会监听所有事件，可能影响性能
2. 生产环境应禁用调试面板
3. 日志和历史记录有最大容量限制，防止内存泄漏
4. 避免在调试面板中显示敏感数据