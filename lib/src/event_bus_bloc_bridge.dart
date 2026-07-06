import 'dart:async';

import 'global_event_bus_api.dart';
import 'global_event_model.dart';
import 'global_event_log.dart';

/// BLoC 与全局事件总线的桥接器。
///
/// 实现 BLoC 和事件总线之间的双向通信：
/// 1. BLoC 状态变更 → 事件总线（自动发送）
/// 2. 事件总线事件 → BLoC（通过 [forwardEventToBloc] 手动转发）
///
/// 泛型参数：
/// - [Event] BLoC 的事件类型
/// - [State] BLoC 的状态类型
class GebBlocBridge<Event, State> {
  /// BLoC 实例，使用 dynamic 类型以避免直接依赖 bloc 包
  final dynamic bloc;

  /// 使用的事件总线实例，默认为全局单例
  final GlobalEventBus eventBus;

  /// BLoC 状态变更事件的类型名，默认为 'bloc_state_changed'
  final String stateEventType;

  /// BLoC 状态流订阅
  StreamSubscription<State>? _stateSubscription;

  /// 事件总线订阅列表
  final List<StreamSubscription<GebBaseEvent>> _eventSubscriptions = [];

  /// 是否已启动桥接
  bool get isStarted => _stateSubscription != null;

  /// 创建 BLoC 桥接器
  ///
  /// [bloc] BLoC 实例，必须具有 `stream` 和 `add` 方法
  /// [eventBus] 事件总线实例，默认为全局单例
  /// [stateEventType] BLoC 状态变更事件的类型名
  GebBlocBridge({
    required this.bloc,
    GlobalEventBus? eventBus,
    this.stateEventType = 'bloc_state_changed',
  }) : eventBus = eventBus ?? globalEventBus;

  /// 启动桥接，开始监听 BLoC 状态变更并发送到事件总线
  void start() {
    if (isStarted) return;

    _stateSubscription = (bloc as dynamic).stream.listen((State state) {
      eventBus.sendEvent<State>(
        type: stateEventType,
        data: state,
        metadata: {
          'bloc': bloc.runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  /// 停止桥接，取消所有订阅
  void stop() {
    _stateSubscription?.cancel();
    _stateSubscription = null;

    for (final subscription in _eventSubscriptions) {
      subscription.cancel();
    }
    _eventSubscriptions.clear();
  }

  /// 将事件总线的事件转发到 BLoC
  ///
  /// [eventType] 要转发的事件类型
  /// [mapper] 事件映射函数，将 [GebEvent<D>] 转换为 BLoC 的 [Event]
  ///          如果不指定，默认直接将事件数据作为 BLoC 事件
  ///
  /// 返回值：[StreamSubscription]，用于手动取消转发
  StreamSubscription<GebBaseEvent> forwardEventToBloc<D>({
    required String eventType,
    Event Function(GebEvent<D> event)? mapper,
  }) {
    final listenerId = 'bloc_bridge_${eventType}_${bloc.hashCode}';
    final subscription = eventBus.listen<D>(
      listenerId: listenerId,
      eventTypes: [eventType],
      onEvent: (event) {
        try {
          final blocEvent = mapper != null ? mapper(event) : event.data as Event;
          (bloc as dynamic).add(blocEvent);
        } catch (e) {
          GebLogger.logError(
            'Error forwarding event to bloc',
            error: e,
            context: 'forwardEventToBloc',
          );
        }
      },
    );

    _eventSubscriptions.add(subscription);
    return subscription;
  }

  /// 批量将多个事件类型转发到 BLoC
  ///
  /// [eventTypes] 要转发的事件类型列表
  /// [mapper] 事件映射函数，将 [GebEvent<D>] 转换为 BLoC 的 [Event]
  void forwardEventsToBloc<D>({
    required List<String> eventTypes,
    Event Function(GebEvent<D> event)? mapper,
  }) {
    for (final type in eventTypes) {
      forwardEventToBloc<D>(
        eventType: type,
        mapper: mapper,
      );
    }
  }

  /// 手动发布当前 BLoC 状态到事件总线
  ///
  /// 通常用于初始化时同步当前状态
  void publishCurrentState() {
    final state = (bloc as dynamic).state;
    if (state != null) {
      eventBus.sendEvent<State>(
        type: stateEventType,
        data: state as State,
        metadata: {
          'bloc': bloc.runtimeType.toString(),
          'source': 'manual',
        },
      );
    }
  }

  /// 销毁桥接器，释放所有资源
  void dispose() {
    stop();
  }
}

@Deprecated('Use GebBlocBridge instead. Will be removed in a future version')
typedef EventBusBlocBridge<Event, State> = GebBlocBridge<Event, State>;

/// BLoC Mixin，用于在 BLoC 类中集成事件总线。
///
/// 提供便捷方法将 BLoC 状态变更自动发送到事件总线。
/// 泛型参数 [State] 为 BLoC 的状态类型。
mixin GebBlocMixin<State> {
  /// 事件总线实例
  GlobalEventBus? _eventBus;

  /// 状态变更事件的类型名
  String? _stateEventType;

  /// BLoC 状态流订阅
  StreamSubscription<State>? _stateSubscription;

  /// 初始化 BLoC 与事件总线的集成
  ///
  /// [eventBus] 事件总线实例，必填
  /// [stateEventType] 状态变更事件的类型名，默认为 'bloc_state_changed'
  void gebInit({
    required GlobalEventBus eventBus,
    String stateEventType = 'bloc_state_changed',
  }) {
    _eventBus = eventBus;
    _stateEventType = stateEventType;

    _stateSubscription = (this as dynamic).stream.listen((State state) {
      _eventBus?.sendEvent<State>(
        type: _stateEventType!,
        data: state,
        metadata: {
          'bloc': runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  /// 手动发布当前状态到事件总线
  void gebPublishState() {
    if (_eventBus == null || _stateEventType == null) return;

    final state = (this as dynamic).state;
    if (state != null) {
      _eventBus!.sendEvent<State>(
        type: _stateEventType!,
        data: state as State,
        metadata: {
          'bloc': runtimeType.toString(),
          'source': 'manual',
        },
      );
    }
  }

  /// 清理资源，取消订阅
  void gebDispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _eventBus = null;
    _stateEventType = null;
  }
}

@Deprecated('Use GebBlocMixin instead. Will be removed in a future version')
mixin EventBusBlocMixin<State> {
  GlobalEventBus? _eventBus;
  String? _stateEventType;
  StreamSubscription<State>? _stateSubscription;

  void eventBusInit({
    required GlobalEventBus eventBus,
    String stateEventType = 'bloc_state_changed',
  }) {
    _eventBus = eventBus;
    _stateEventType = stateEventType;

    _stateSubscription = (this as dynamic).stream.listen((State state) {
      _eventBus?.sendEvent<State>(
        type: _stateEventType!,
        data: state,
        metadata: {
          'bloc': runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  void eventBusPublishState() {
    if (_eventBus == null || _stateEventType == null) return;

    final state = (this as dynamic).state;
    if (state != null) {
      _eventBus!.sendEvent<State>(
        type: _stateEventType!,
        data: state as State,
        metadata: {
          'bloc': runtimeType.toString(),
          'source': 'manual',
        },
      );
    }
  }

  void eventBusDispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _eventBus = null;
    _stateEventType = null;
  }
}

/// BLoC 事件映射工具类。
///
/// 提供多种预定义的映射方法，用于将事件总线的事件转换为 BLoC 事件。
class GebBlocMapper {
  /// 直接映射：将事件数据作为 BLoC 事件
  ///
  /// [D] 事件总线事件的数据类型
  /// [Event] BLoC 事件类型
  static Event direct<D, Event>(GebEvent<D> event) {
    return event.data as Event;
  }

  /// 将整个事件对象作为 BLoC 事件
  ///
  /// [D] 事件总线事件的数据类型
  static GebEvent<D> eventObject<D>(GebEvent<D> event) {
    return event;
  }

  /// 将事件转换为 Map
  ///
  /// [D] 事件总线事件的数据类型
  static Map<String, dynamic> toMap<D>(GebEvent<D> event) {
    return {
      'type': event.type,
      'data': event.data,
      'priority': event.priority.name,
      'timestamp': event.timestamp.toIso8601String(),
    };
  }

  /// 使用自定义转换函数映射
  ///
  /// [D] 事件总线事件的数据类型
  /// [Event] BLoC 事件类型
  /// [transform] 自定义转换函数，将事件数据转换为 BLoC 事件
  static Event custom<D, Event>(
    GebEvent<D> event,
    Event Function(D data) transform,
  ) {
    return transform(event.data);
  }
}

@Deprecated('Use GebBlocMapper instead. Will be removed in a future version')
typedef BlocEventMapper = GebBlocMapper;
