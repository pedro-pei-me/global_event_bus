import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_event_bus/global_event_bus.dart';

void main() {
  group('GlobalEventBus Tests', () {
    late GlobalEventBus eventBus;

    setUp(() {
      eventBus = GlobalEventBus.instance;
      // 清理之前的监听器
      eventBus.removeAllListeners();
    });

    tearDown(() {
      eventBus.removeAllListeners();
    });

    test('should create singleton instance', () {
      final instance1 = GlobalEventBus.instance;
      final instance2 = GlobalEventBus();
      expect(instance1, equals(instance2));
    });

    test('should send and receive events', () async {
      String? receivedData;
      final completer = Completer<void>();

      eventBus.listen<String>(
        listenerId: 'test_listener',
        onEvent: (event) {
          receivedData = event.data;
          completer.complete();
        },
        eventTypes: ['test_event'],
      );

      eventBus.sendEvent<String>(
        type: 'test_event',
        data: 'Hello World',
      );

      await completer.future.timeout(const Duration(seconds: 1));
      expect(receivedData, equals('Hello World'));
    });

    test('should send event without data', () async {
      bool eventReceived = false;
      final completer = Completer<void>();

      eventBus.listen<void>(
        listenerId: 'test_listener',
        onEvent: (event) {
          eventReceived = true;
          completer.complete();
        },
        eventTypes: ['no_data_event'],
      );

      eventBus.sendEventWithoutData(
        type: 'no_data_event',
      );

      await completer.future.timeout(const Duration(seconds: 1));
      expect(eventReceived, isTrue);
    });

    test('should handle safe event sending', () {
      final result = eventBus.sendEventSafe<String>(
        type: 'safe_event',
        data: 'Safe data',
      );
      expect(result, isTrue);
    });

    test('should handle delayed events', () async {
      String? receivedData;
      final completer = Completer<void>();
      final stopwatch = Stopwatch()..start();

      eventBus.listen<String>(
        listenerId: 'delayed_listener',
        onEvent: (event) {
          receivedData = event.data;
          stopwatch.stop();
          completer.complete();
        },
        eventTypes: ['delayed_event'],
      );

      eventBus.sendEventDelayed<String>(
        type: 'delayed_event',
        delay: const Duration(milliseconds: 100),
        data: 'Delayed data',
      );

      await completer.future.timeout(const Duration(seconds: 2));
      expect(receivedData, equals('Delayed data'));
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });

    test('should handle event priorities in batch mode', () async {
      final receivedEvents = <String>[];
      final completer = Completer<void>();
      int eventCount = 0;

      // 启用批量模式以测试优先级排序
      eventBus.manager.setBatchMode(true, intervalMs: 50);

      eventBus.listen<String>(
        listenerId: 'priority_listener',
        onEvent: (event) {
          receivedEvents.add(event.data);
          eventCount++;
          if (eventCount == 3) {
            completer.complete();
          }
        },
        eventTypes: ['priority_event'],
      );

      // 发送不同优先级的事件
      eventBus.sendEvent<String>(
        type: 'priority_event',
        data: 'Low priority',
        priority: GebPriority.low,
      );

      eventBus.sendEvent<String>(
        type: 'priority_event',
        data: 'High priority',
        priority: GebPriority.high,
      );

      eventBus.sendEvent<String>(
        type: 'priority_event',
        data: 'Normal priority',
        priority: GebPriority.normal,
      );

      await completer.future.timeout(const Duration(seconds: 2));
      expect(receivedEvents.length, equals(3));
      // 在批量模式下，高优先级事件应该先被处理
      expect(receivedEvents.first, equals('High priority'));

      // 关闭批量模式
      eventBus.manager.setBatchMode(false);
    });
  });
}
