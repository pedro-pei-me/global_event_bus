import 'dart:async';

import 'package:flutter/widgets.dart';

import 'global_event_bus_api.dart';
import 'global_event_model.dart';

/// 连接状态枚举，描述 [GebBuilder] 与事件总线的连接状态。
enum GebConnectionState {
  /// 未连接，初始状态
  none,

  /// 已连接并活跃，正在监听事件
  active,

  /// 已断开连接，通常是因为 Widget 已销毁
  done,
}

@Deprecated('Use GebConnectionState instead. Will be removed in a future version')
typedef EventBusConnectionState = GebConnectionState;

/// 事件快照类，封装了事件数据和连接状态。
///
/// 用于 [GebBuilder] 的 builder 回调中，提供当前事件数据和连接状态。
class GebSnapshot<T> {
  /// 当前连接状态
  final GebConnectionState connectionState;

  /// 事件数据，类型为 [T]
  final T? data;

  /// 完整的事件对象
  final GebEvent<T>? event;

  /// 错误对象，如果发生错误
  final Object? error;

  /// 是否有数据
  bool get hasData => data != null;

  /// 是否有事件
  bool get hasEvent => event != null;

  /// 是否有错误
  bool get hasError => error != null;

  /// 是否处于活跃状态
  bool get isActive => connectionState == GebConnectionState.active;

  /// 创建快照的私有构造函数
  const GebSnapshot._({
    required this.connectionState,
    this.data,
    this.event,
    this.error,
  });

  /// 创建一个 none 状态的快照
  const GebSnapshot.none() : this._(connectionState: GebConnectionState.none);

  /// 创建一个活跃状态的快照，包含数据和事件
  const GebSnapshot.active(T data, GebEvent<T> event)
      : this._(
          connectionState: GebConnectionState.active,
          data: data,
          event: event,
        );

  /// 创建一个活跃状态但无数据的快照
  const GebSnapshot.activeWithoutData() : this._(connectionState: GebConnectionState.active);

  /// 创建一个包含错误的快照
  const GebSnapshot.error(Object error)
      : this._(
          connectionState: GebConnectionState.active,
          error: error,
        );

  /// 创建一个 done 状态的快照
  const GebSnapshot.done() : this._(connectionState: GebConnectionState.done);

  /// 创建一个新的快照，可选择性覆盖原有属性
  GebSnapshot<T> copyWith({
    GebConnectionState? connectionState,
    T? data,
    GebEvent<T>? event,
    Object? error,
  }) {
    return GebSnapshot._(
      connectionState: connectionState ?? this.connectionState,
      data: data ?? this.data,
      event: event ?? this.event,
      error: error ?? this.error,
    );
  }
}

@Deprecated('Use GebSnapshot<T> instead. Will be removed in a future version')
typedef EventBusSnapshot<T> = GebSnapshot<T>;

/// 响应式 Widget，用于根据事件总线的事件更新 UI。
///
/// 类似于 Flutter 的 [StreamBuilder]，但专门用于全局事件总线。
/// 自动处理事件订阅和取消订阅，支持从历史记录获取初始数据。
class GebBuilder<T> extends StatefulWidget {
  /// 要监听的单个事件类型
  final String? eventType;

  /// 要监听的多个事件类型
  final List<String>? eventTypes;

  /// 初始数据，用于 Widget 首次构建时
  final T? initialData;

  /// 初始事件，用于 Widget 首次构建时
  final GebEvent<T>? initialEvent;

  /// 是否使用历史记录中的最后一个事件作为初始数据
  final bool useHistoryForInitialData;

  /// 使用的事件总线实例，默认为全局单例
  final GlobalEventBus eventBus;

  /// 构建 Widget 的回调函数，接收 [BuildContext] 和 [GebSnapshot<T>]
  final Widget Function(BuildContext context, GebSnapshot<T> snapshot) builder;

  /// 错误回调函数，当事件处理发生错误时触发
  final void Function(Object error)? onError;

  /// 创建 [GebBuilder] Widget
  ///
  /// [eventType] 和 [eventTypes] 必须至少指定一个
  /// [useHistoryForInitialData] 默认为 true，表示从历史记录获取初始数据
  /// [eventBus] 默认为全局单例 [globalEventBus]
  GebBuilder({
    super.key,
    this.eventType,
    this.eventTypes,
    this.initialData,
    this.initialEvent,
    this.useHistoryForInitialData = true,
    GlobalEventBus? eventBus,
    required this.builder,
    this.onError,
  })  : eventBus = eventBus ?? globalEventBus,
        assert(
          eventType != null || eventTypes != null,
          '必须指定 eventType 或 eventTypes',
        );

  @override
  State<GebBuilder<T>> createState() => _GebBuilderState<T>();
}

@Deprecated('Use GebBuilder<T> instead. Will be removed in a future version')
typedef EventBusBuilder<T> = GebBuilder<T>;

class _GebBuilderState<T> extends State<GebBuilder<T>> {
  StreamSubscription<GebBaseEvent>? _subscription;
  GebSnapshot<T> _snapshot = const GebSnapshot.none();

  @override
  void initState() {
    super.initState();
    _initializeSnapshot();
    _subscribe();
  }

  @override
  void didUpdateWidget(GebBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final typesChanged = _getEventTypes(oldWidget) != _getEventTypes(widget);
    final busChanged = oldWidget.eventBus != widget.eventBus;

    if (typesChanged || busChanged) {
      _unsubscribe();
      _initializeSnapshot();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  /// 获取要监听的事件类型列表
  List<String>? _getEventTypes(GebBuilder<T> widget) {
    if (widget.eventTypes != null && widget.eventTypes!.isNotEmpty) {
      return widget.eventTypes;
    }
    if (widget.eventType != null) {
      return [widget.eventType!];
    }
    return null;
  }

  /// 初始化快照数据
  void _initializeSnapshot() {
    if (widget.initialData != null || widget.initialEvent != null) {
      _snapshot = GebSnapshot.active(
        widget.initialData ?? widget.initialEvent?.data as T,
        widget.initialEvent ?? GebEvent<T>(type: '', data: widget.initialData as T),
      );
      return;
    }

    if (widget.useHistoryForInitialData) {
      final types = _getEventTypes(widget);
      if (types != null) {
        for (final type in types) {
          final lastEvent = widget.eventBus.getLastEventByType(type);
          if (lastEvent is GebEvent<T>) {
            _snapshot = GebSnapshot.active(lastEvent.data, lastEvent);
            return;
          }
        }
      }
    }

    _snapshot = const GebSnapshot.none();
  }

  /// 订阅事件
  void _subscribe() {
    final types = _getEventTypes(widget);

    _subscription = widget.eventBus.listen<T>(
      listenerId: 'GebBuilder_$widget.eventType_$hashCode',
      onEvent: (event) {
        setState(() {
          _snapshot = GebSnapshot.active(event.data, event);
        });
      },
      eventTypes: types,
      onError: (error) {
        setState(() {
          _snapshot = GebSnapshot.error(error);
        });
        widget.onError?.call(error);
      },
    );

    if (_snapshot.connectionState == GebConnectionState.none) {
      setState(() {
        _snapshot = _snapshot.copyWith(
          connectionState: GebConnectionState.active,
        );
      });
    }
  }

  /// 取消订阅
  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _snapshot = const GebSnapshot.done();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _snapshot);
  }
}
