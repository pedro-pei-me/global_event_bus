import 'dart:async';

import 'package:flutter/widgets.dart';

import 'global_event_bus_api.dart';
import 'global_event_model.dart';

/// 事件总线监听器 Mixin，用于在 StatefulWidget 中监听事件。
///
/// 自动管理订阅生命周期，在 Widget 销毁时自动取消所有订阅。
/// 使用泛型 [T] 来指定事件数据类型，提供类型安全。
mixin GebListener on State {
  /// 订阅列表，用于管理所有事件订阅
  final List<StreamSubscription<GebBaseEvent>> _eventBusSubscriptions = [];

  /// 获取事件总线实例，默认为全局单例
  GlobalEventBus get eventBus => globalEventBus;

  /// 订阅事件，监听指定类型的事件
  ///
  /// [listenerId] 监听器唯一标识，必填
  /// [eventType] 要监听的单个事件类型，与 [eventTypes] 二选一
  /// [eventTypes] 要监听的多个事件类型，与 [eventType] 二选一
  /// [onEvent] 事件回调函数，收到匹配事件时触发
  /// [onError] 错误回调函数，可选
  ///
  /// 返回值：[StreamSubscription]，用于手动取消订阅
  StreamSubscription<GebBaseEvent> gebSubscribe<T>({
    required String listenerId,
    String? eventType,
    List<String>? eventTypes,
    required void Function(GebEvent<T> event) onEvent,
    void Function(Object error)? onError,
  }) {
    final types = eventTypes ?? (eventType != null ? [eventType] : null);

    final subscription = eventBus.listen<T>(
      listenerId: listenerId,
      onEvent: onEvent,
      eventTypes: types,
      onError: onError,
    );

    _eventBusSubscriptions.add(subscription);
    return subscription;
  }

  /// 订阅一次性事件，只触发一次后自动移除
  ///
  /// [listenerId] 监听器唯一标识，必填
  /// [eventType] 要监听的单个事件类型，与 [eventTypes] 二选一
  /// [eventTypes] 要监听的多个事件类型，与 [eventType] 二选一
  /// [onEvent] 事件回调函数，收到匹配事件时触发
  ///
  /// 返回值：[StreamSubscription]，用于手动取消订阅
  StreamSubscription<GebBaseEvent> gebSubscribeOnce<T>({
    required String listenerId,
    String? eventType,
    List<String>? eventTypes,
    required void Function(GebEvent<T> event) onEvent,
  }) {
    final types = eventTypes ?? (eventType != null ? [eventType] : null);

    final subscription = eventBus.listenOnce<T>(
      listenerId: listenerId,
      onEvent: onEvent,
      eventTypes: types,
    );

    _eventBusSubscriptions.add(subscription);
    return subscription;
  }

  /// 根据监听器ID取消订阅
  ///
  /// [listenerId] 要取消的监听器ID
  void gebUnsubscribe(String listenerId) {
    eventBus.removeListener(listenerId);
    _eventBusSubscriptions.removeWhere((sub) => sub.isPaused);
  }

  /// 取消所有订阅
  void gebUnsubscribeAll() {
    for (final subscription in _eventBusSubscriptions) {
      subscription.cancel();
    }
    _eventBusSubscriptions.clear();
  }

  @override
  void dispose() {
    gebUnsubscribeAll();
    super.dispose();
  }
}

@Deprecated('Use GebListener instead. Will be removed in a future version')
mixin EventBusListener on State {
  final List<StreamSubscription<GebBaseEvent>> _eventBusSubscriptions = [];

  GlobalEventBus get eventBus => globalEventBus;

  StreamSubscription<GebBaseEvent> eventBusSubscribe<T>({
    required String listenerId,
    String? eventType,
    List<String>? eventTypes,
    required void Function(GebEvent<T> event) onEvent,
    void Function(Object error)? onError,
  }) {
    final types = eventTypes ?? (eventType != null ? [eventType] : null);

    final subscription = eventBus.listen<T>(
      listenerId: listenerId,
      onEvent: onEvent,
      eventTypes: types,
      onError: onError,
    );

    _eventBusSubscriptions.add(subscription);
    return subscription;
  }

  StreamSubscription<GebBaseEvent> eventBusSubscribeOnce<T>({
    required String listenerId,
    String? eventType,
    List<String>? eventTypes,
    required void Function(GebEvent<T> event) onEvent,
  }) {
    final types = eventTypes ?? (eventType != null ? [eventType] : null);

    final subscription = eventBus.listenOnce<T>(
      listenerId: listenerId,
      onEvent: onEvent,
      eventTypes: types,
    );

    _eventBusSubscriptions.add(subscription);
    return subscription;
  }

  void eventBusUnsubscribe(String listenerId) {
    eventBus.removeListener(listenerId);
    _eventBusSubscriptions.removeWhere((sub) => sub.isPaused);
  }

  void eventBusUnsubscribeAll() {
    for (final subscription in _eventBusSubscriptions) {
      subscription.cancel();
    }
    _eventBusSubscriptions.clear();
  }

  @override
  void dispose() {
    eventBusUnsubscribeAll();
    super.dispose();
  }
}

/// 无数据事件监听器 Mixin，用于监听不带数据的事件。
///
/// 与 [GebListener] 类似，但专门用于监听 [sendEventWithoutData] 发送的事件。
mixin GebNoDataListener on State {
  /// 订阅列表，用于管理所有无数据事件订阅
  final List<StreamSubscription<GebBaseEvent>> _noDataSubscriptions = [];

  /// 获取事件总线实例，默认为全局单例
  GlobalEventBus get eventBus => globalEventBus;

  /// 订阅无数据事件，监听指定类型的事件
  ///
  /// [listenerId] 监听器唯一标识，必填
  /// [eventType] 要监听的单个事件类型，与 [eventTypes] 二选一
  /// [eventTypes] 要监听的多个事件类型，与 [eventType] 二选一
  /// [onEvent] 事件回调函数，收到匹配事件时触发
  ///
  /// 返回值：[StreamSubscription]，用于手动取消订阅
  StreamSubscription<GebBaseEvent> gebSubscribeNoData({
    required String listenerId,
    String? eventType,
    List<String>? eventTypes,
    required void Function() onEvent,
  }) {
    final types = eventTypes ?? (eventType != null ? [eventType] : null);

    final subscription = eventBus.listen<void>(
      listenerId: listenerId,
      onEvent: (_) => onEvent(),
      eventTypes: types,
    );

    _noDataSubscriptions.add(subscription);
    return subscription;
  }

  /// 取消所有无数据事件订阅
  void gebUnsubscribeNoDataAll() {
    for (final subscription in _noDataSubscriptions) {
      subscription.cancel();
    }
    _noDataSubscriptions.clear();
  }

  @override
  void dispose() {
    gebUnsubscribeNoDataAll();
    super.dispose();
  }
}

@Deprecated('Use GebNoDataListener instead. Will be removed in a future version')
mixin EventBusNoDataListener on State {
  final List<StreamSubscription<GebBaseEvent>> _noDataSubscriptions = [];

  GlobalEventBus get eventBus => globalEventBus;

  StreamSubscription<GebBaseEvent> eventBusSubscribeNoData({
    required String listenerId,
    String? eventType,
    List<String>? eventTypes,
    required void Function() onEvent,
  }) {
    final types = eventTypes ?? (eventType != null ? [eventType] : null);

    final subscription = eventBus.listen<void>(
      listenerId: listenerId,
      onEvent: (_) => onEvent(),
      eventTypes: types,
    );

    _noDataSubscriptions.add(subscription);
    return subscription;
  }

  void eventBusUnsubscribeNoDataAll() {
    for (final subscription in _noDataSubscriptions) {
      subscription.cancel();
    }
    _noDataSubscriptions.clear();
  }

  @override
  void dispose() {
    eventBusUnsubscribeNoDataAll();
    super.dispose();
  }
}
