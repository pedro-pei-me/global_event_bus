# BLoC 集成指南

## 概述

Global Event Bus 提供了多种方式与 BLoC 状态管理库集成，实现事件总线与 BLoC 的双向通信。

## 方式一：使用 GebBlocMixin

最简单的方式是使用 `GebBlocMixin`：

```dart
import 'package:bloc/bloc.dart';
import 'package:global_event_bus/global_event_bus.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> with GebBlocMixin {
  CounterBloc() : super(CounterState(count: 0)) {
    on<IncrementEvent>((event, emit) => emit(CounterState(count: state.count + 1)));
    
    // 订阅事件总线
    gebSubscribe<int>(
      listenerId: 'counter_bloc',
      eventType: 'counter_increment',
      onEvent: (event) => add(IncrementEvent()),
    );
  }
}
```

## 方式二：使用 GebBlocMapper

使用 `GebBlocMapper` 简化事件映射：

```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> with GebBlocMixin {
  CounterBloc() : super(CounterState(count: 0)) {
    on<IncrementEvent>((event, emit) => emit(CounterState(count: state.count + 1)));
    on<DecrementEvent>((event, emit) => emit(CounterState(count: state.count - 1)));
    
    GebBlocMapper<CounterEvent>(this)
      .map<int>('counter_increment', (data) => IncrementEvent())
      .map<int>('counter_decrement', (data) => DecrementEvent());
  }
}
```

## 方式三：使用 GebBlocBridge

实现完整的双向桥接：

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final GebBlocBridge<AuthEvent> _bridge;

  AuthBloc() : super(AuthState(isLoggedIn: false)) {
    on<LoginEvent>((event, emit) => emit(AuthState(isLoggedIn: true)));
    on<LogoutEvent>((event, emit) => emit(AuthState(isLoggedIn: false)));
    
    _bridge = GebBlocBridge(
      bloc: this,
      eventMapper: (eventType, data) {
        switch (eventType) {
          case 'login_request':
            return LoginEvent();
          case 'logout_request':
            return LogoutEvent();
          default:
            return null;
        }
      },
      stateMapper: (state) {
        if (state.isLoggedIn) {
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

## 方式四：手动集成

完全手动控制事件订阅和发送：

```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  StreamSubscription? _subscription;

  CounterBloc() : super(CounterState(count: 0)) {
    on<IncrementEvent>((event, emit) => emit(CounterState(count: state.count + 1)));
    
    _subscription = globalEventBus.listen<int>(
      listenerId: 'counter_bloc',
      eventType: 'counter_increment',
      onEvent: (event) => add(IncrementEvent()),
    );
  }

  void sendUpdate() {
    globalEventBus.sendEvent<int>(
      eventType: 'counter_updated',
      data: state.count,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

## 事件类型命名规范

为避免冲突，建议使用 BLoC 特定的事件类型前缀：

```dart
// 推荐：使用前缀
globalEventBus.sendEvent<String>(
  eventType: 'auth_user_logged_in',
  data: 'username',
);

// 不推荐：通用名称
globalEventBus.sendEvent<String>(
  eventType: 'user_logged_in',
  data: 'username',
);
```

## 在 Widget 中使用

结合 `BlocBuilder` 和事件总线：

```dart
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        return Column(
          children: [
            Text('计数器: ${state.count}'),
            GebBuilder<int>(
              eventType: 'external_update',
              builder: (context, event) {
                return Text('外部更新: ${event?.data}');
              },
            ),
          ],
        );
      },
    );
  }
}
```

## 最佳实践

1. **事件类型唯一** - 使用 BLoC 特定的事件类型前缀
2. **生命周期管理** - 在 `close()` 中取消订阅
3. **避免循环** - 不要在 BLoC 中发送会触发自身的事件
4. **单向数据流** - 事件总线用于跨模块通信，BLoC 内部使用自身事件系统
5. **调试面板** - 使用调试面板查看事件流向

## 常见问题

### Q: BLoC 事件和事件总线事件有什么区别？

A: BLoC 事件用于 BLoC 内部状态管理，事件总线事件用于跨模块通信。两者可以通过桥接器相互转换。

### Q: 什么时候使用事件总线，什么时候使用 BLoC？

A: 如果是组件间通信或全局状态，使用事件总线；如果是复杂的业务逻辑和状态管理，使用 BLoC。两者可以结合使用。

### Q: 如何处理事件总线事件到 BLoC 事件的映射？

A: 使用 `GebBlocMapper` 或在 `gebSubscribe` 的回调中手动转换。