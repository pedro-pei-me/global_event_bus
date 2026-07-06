# GebBlocMixin

## 概述

`GebBlocMixin` 用于在 BLoC 类中直接集成事件总线，简化 BLoC 与事件总线的通信。

## 使用方式

```dart
import 'package:bloc/bloc.dart';
import 'package:global_event_bus/global_event_bus.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> with GebBlocMixin {
  CounterBloc() : super(CounterInitial()) {
    on<IncrementEvent>((event, emit) {
      emit(CounterState(state.count + 1));
    });
    
    // 订阅事件总线
    gebSubscribe<int>(
      listenerId: 'counter_bloc',
      eventType: 'external_update',
      onEvent: (GebEvent<int> event) {
        add(IncrementEvent());
      },
    );
  }
}
```

## 核心方法

### gebSubscribe

订阅事件总线事件。

```dart
StreamSubscription<GebBaseEvent> gebSubscribe<T>({
  required String listenerId,
  String? eventType,
  List<String>? eventTypes,
  required void Function(GebEvent<T> event) onEvent,
});
```

### gebSubscribeOnce

订阅一次性事件。

```dart
StreamSubscription<GebBaseEvent> gebSubscribeOnce<T>({
  required String listenerId,
  String? eventType,
  List<String>? eventTypes,
  required void Function(GebEvent<T> event) onEvent,
});
```

### gebSendEvent

发送事件到事件总线。

```dart
void gebSendEvent<T>({
  required String eventType,
  required T data,
  GebPriority priority = GebPriority.normal,
});
```

### gebUnsubscribeAll

取消所有订阅。

```dart
void gebUnsubscribeAll();
```

## 完整示例

```dart
import 'package:bloc/bloc.dart';
import 'package:global_event_bus/global_event_bus.dart';

enum AuthEvent { login, logout }

class AuthState {
  final bool isLoggedIn;
  final String? username;

  AuthState({required this.isLoggedIn, this.username});
}

class AuthBloc extends Bloc<AuthEvent, AuthState> with GebBlocMixin {
  AuthBloc() : super(AuthState(isLoggedIn: false)) {
    on<AuthEvent>((event, emit) {
      switch (event) {
        case AuthEvent.login:
          emit(AuthState(isLoggedIn: true, username: 'user'));
          gebSendEvent<String>(
            eventType: 'user_logged_in',
            data: 'user',
          );
          break;
        case AuthEvent.logout:
          emit(AuthState(isLoggedIn: false));
          gebSendEventWithoutData('user_logged_out');
          break;
      }
    });

    // 监听外部事件
    gebSubscribe<String>(
      listenerId: 'auth_bloc_login',
      eventType: 'external_login_request',
      onEvent: (event) {
        add(AuthEvent.login);
      },
    );
  }
}
```

## BLoC 事件映射

使用 `GebBlocMapper` 将事件总线事件映射到 BLoC 事件：

```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> with GebBlocMixin {
  CounterBloc() : super(CounterState(count: 0)) {
    on<IncrementEvent>((event, emit) => emit(CounterState(count: state.count + 1)));
    on<DecrementEvent>((event, emit) => emit(CounterState(count: state.count - 1)));
    
    // 使用映射器
    GebBlocMapper<CounterEvent>(this)
      .map<int>('counter_increment', (data) => IncrementEvent())
      .map<int>('counter_decrement', (data) => DecrementEvent());
  }
}
```

## 双向桥接

使用 `GebBlocBridge` 实现 BLoC 与事件总线的双向通信：

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  late final GebBlocBridge<MyEvent> _bridge;

  MyBloc() : super(MyInitialState()) {
    _bridge = GebBlocBridge(
      bloc: this,
      eventMapper: (eventType, data) {
        switch (eventType) {
          case 'user_action':
            return UserActionEvent(data);
          default:
            return null;
        }
      },
      stateMapper: (state) {
        if (state is UserLoggedIn) {
          return ('user_logged_in', state.username);
        }
        return null;
      },
    );
  }

  @override
  Future<void> close() {
    _bridge.dispose();
    return super.close();
  }
}
```

## 注意事项

1. 在 `close()` 方法中调用 `gebUnsubscribeAll()` 或 `_bridge.dispose()`
2. `listenerId` 必须唯一
3. 使用 `gebSendEvent` 发送事件时要注意事件类型命名规范
4. 避免在 BLoC 中发送会触发自身的事件，防止无限循环