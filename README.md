# 🚀 Global Event Bus

[中文](README_CN.md) | [English](README.md)

<div align="center">
  <img src="assets/icons/animated_logo.svg" alt="Global Event Bus Logo" width="400" height="200">
</div>

[![pub package](https://img.shields.io/pub/v/global_event_bus.svg)](https://pub.dev/packages/global_event_bus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance, type-safe global event bus system for Flutter applications, enabling decoupled communication between different modules. Built on the observer pattern and stream processing architecture, it supports event priorities, batch processing, delayed sending, statistics monitoring, reactive Widgets, BLoC integration, and other advanced features.

## ✨ Core Features

### 🔒 Type Safety

- Generic-based type-safe event system
- Compile-time type checking to avoid runtime errors
- Automatic type inference for better development experience

### ⚡ High Performance

- Efficient event distribution based on Dart Stream
- Batch processing mode for high-frequency event scenarios
- Built-in event statistics and performance monitoring

### 🎯 Event Priority

- Four-level priority system: critical, high, normal, low
- High-priority events are processed first
- Suitable for event classification in different business scenarios

### 📊 Comprehensive Logging System

- Multi-level log configuration (debug, info, warning, error, none)
- Configurable log output format
- Support for custom log handlers
- Event type and listener filtering

### 🔧 Flexible Listening

- Type listening: only listen for specific event types
- One-time listening: automatically removed after first trigger
- Multi-type listening: listen for multiple event types simultaneously
- Delayed sending: support sending events after a specified delay

### 📈 Statistics Monitoring

- Real-time event statistics
- Send/receive counting
- Event type distribution statistics
- Performance monitoring data

### 🎨 Reactive Widget

- **GebBuilder**: StreamBuilder-like reactive Widget
- Automatic subscription lifecycle management
- Support for initial data from history

### 🔄 BLoC Integration

- **GebBlocBridge**: Bidirectional bridge between BLoC and event bus
- **GebBlocMixin**: Direct event bus integration in BLoC classes
- **GebBlocMapper**: Event mapping utility class

### 📚 Event History

- **GebHistory**: Event history manager
- Support querying history by type and count
- Configurable maximum records and enable/disable

## 🏗️ Architecture

```plantext
┌───────────────────────────────────────┐
│ Global Event Bus                      │
├───────────────────────────────────────┤
│ GlobalEventManager (Singleton)        │
│ ├── Event Sending & Dispatching       │
│ ├── Listener Management               │
│ ├── Batch Processing                  │
│ └── Statistics Monitoring             │
├───────────────────────────────────────┤
│ GebBaseEvent (Base Event Class)       │
│ ├── Event Type Identifier             │
│ ├── Timestamp                        │
│ ├── Priority                         │
│ └── Metadata                         │
├───────────────────────────────────────┤
│ GebEvent<T> (Generic Event Class)     │
│ └── Type-safe Data Transfer          │
├───────────────────────────────────────┤
│ GebLogger (Logging System)            │
│ ├── Multi-level Logging               │
│ ├── Configurable Output Format        │
│ └── Custom Handler                    │
└───────────────────────────────────────┘
```

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  global_event_bus: <latest_version>
```

Then run:

```zsh
flutter pub get
```

## 🚀 Quick Start

### 1. Import Package

```dart
import 'package:global_event_bus/global_event_bus.dart';
```

### 2. Configure Logging (Optional)

```dart
void main() {
  // Configure global event bus logging
  globalEventBus.configureLogging(
    const GebLogConfig(
      level: GebLogLevel.debug,
      showEventData: true,
      showEventId: true,
      showListenerInfo: true,
    ),
  );

  runApp(MyApp());
}
```

### 3. Send Events

```dart
// Send simple event
globalEventBus.sendEvent<String>(
  type: 'user_message',
  data: 'Hello, World!',
);

// Send event with priority
globalEventBus.sendEvent<Map<String, dynamic>>(
  type: 'user_login',
  data: {
    'userId': '12345',
    'username': 'john_doe',
    'loginTime': DateTime.now().toIso8601String(),
  },
  priority: GebPriority.high,
);

// Send delayed event
globalEventBus.sendEventDelayed<String>(
  type: 'delayed_notification',
  data: 'This is a delayed message',
  delay: Duration(milliseconds: 3000), // Send after 3 seconds
);

// Send event without data
globalEventBus.sendEventWithoutData(type: 'app_started');
```

### 4. Listen to Events

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late StreamSubscription<GebBaseEvent> _subscription;

  @override
  void initState() {
    super.initState();

    // Listen for specific event type
    _subscription = globalEventBus.listen<String>(
      listenerId: 'my_widget_listener',
      onEvent: (GebEvent<String> event) {
        print('Received event: ${event.type}, data: ${event.data}');
        // Handle event data
        setState(() {
          // Update UI
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel subscription
    super.dispose();
  }
}
```

### 5. Use GebBuilder (Recommended)

```dart
// Use reactive Widget to listen to events, auto-manage lifecycle
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GebBuilder<int>(
      eventType: 'counter_updated',
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Counter: 0');
        }
        return Text('Counter: ${snapshot.data}');
      },
    );
  }
}
```

### 6. Use GebListener Mixin

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with GebListener {
  String _message = 'Waiting for events...';

  @override
  void initState() {
    super.initState();

    // Subscribe to events using Mixin method
    gebSubscribe<String>(
      listenerId: 'message_listener',
      eventType: 'user_message',
      onEvent: (GebEvent<String> event) {
        setState(() {
          _message = event.data;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(_message);
  }

  // All subscriptions automatically cancelled on dispose
}
```

### API Reference

#### Event Sending Methods

**sendEvent<T>** - Send event with data

| Parameter | Type                  | Required | Default            | Description           |
| --------- | --------------------- | -------- | ------------------ | --------------------- |
| type      | String                | ✅       | -                  | Event type identifier |
| data      | T                     | ✅       | -                  | Event data            |
| priority  | GebPriority           | ❌       | GebPriority.normal | Event priority        |
| metadata  | Map<String, dynamic>? | ❌       | null               | Event metadata        |

**sendEventWithoutData** - Send event without data

| Parameter | Type                  | Required | Default            | Description           |
| --------- | --------------------- | -------- | ------------------ | --------------------- |
| type      | String                | ✅       | -                  | Event type identifier |
| priority  | GebPriority           | ❌       | GebPriority.normal | Event priority        |
| metadata  | Map<String, dynamic>? | ❌       | null               | Event metadata        |

**sendEventSafe<T>** - Safely send event (no exceptions thrown)

| Parameter | Type                  | Required | Default            | Description           |
| --------- | --------------------- | -------- | ------------------ | --------------------- |
| type      | String                | ✅       | -                  | Event type identifier |
| data      | T                     | ✅       | -                  | Event data            |
| priority  | GebPriority           | ❌       | GebPriority.normal | Event priority        |
| metadata  | Map<String, dynamic>? | ❌       | null               | Event metadata        |

**sendEventDelayed<T>** - Send event with delay

| Parameter | Type                  | Required | Default            | Description           |
| --------- | --------------------- | -------- | ------------------ | --------------------- |
| type      | String                | ✅       | -                  | Event type identifier |
| data      | T                     | ✅       | -                  | Event data            |
| delay     | Duration              | ✅       | -                  | Delay duration        |
| priority  | GebPriority           | ❌       | GebPriority.normal | Event priority        |
| metadata  | Map<String, dynamic>? | ❌       | null               | Event metadata        |

#### Event Listening Methods

**listen<T>** - Listen to events

| Parameter  | Type                  | Required | Default | Description                       |
| ---------- | --------------------- | -------- | ------- | --------------------------------- |
| listenerId | String                | ✅       | -       | Unique listener identifier        |
| onEvent    | Function(GebEvent<T>) | ✅       | -       | Event handler callback            |
| eventTypes | List<String>?         | ❌       | null    | List of event types to listen for |
| onError    | Function(Object)?     | ❌       | null    | Error callback                    |

**listenOnce<T>** - Listen to event once

| Parameter  | Type                  | Required | Default | Description                       |
| ---------- | --------------------- | -------- | ------- | --------------------------------- |
| listenerId | String                | ✅       | -       | Unique listener identifier        |
| onEvent    | Function(GebEvent<T>) | ✅       | -       | Event handler callback            |
| eventTypes | List<String>?         | ❌       | null    | List of event types to listen for |

**removeListener** - Remove listener

| Parameter  | Type   | Required | Default | Description              |
| ---------- | ------ | -------- | ------- | ------------------------ |
| listenerId | String | ✅       | -       | ID of listener to remove |

**removeAllListeners** - Remove all listeners

**cleanupExpiredListeners** - Clean up expired listeners

#### Logging Configuration

**configureLogging** - Configure logging

| Parameter | Type         | Required | Default | Description              |
| --------- | ------------ | -------- | ------- | ------------------------ |
| config    | GebLogConfig | ✅       | -       | Log configuration object |

**GebLogConfig** Parameters

| Parameter        | Type              | Required | Default          | Description        |
| ---------------- | ----------------- | -------- | ---------------- | ------------------ |
| level            | GebLogLevel       | ❌       | GebLogLevel.info | Log level          |
| enabled          | bool              | ❌       | true             | Enable logging     |
| showTimestamp    | bool              | ❌       | true             | Show timestamp     |
| showEventId      | bool              | ❌       | false            | Show event ID      |
| showPriority     | bool              | ❌       | true             | Show priority      |
| showEventData    | bool              | ❌       | false            | Show event data    |
| showListenerInfo | bool              | ❌       | true             | Show listener info |
| logPrefix        | String            | ❌       | '[GlobalEvent]'  | Custom log prefix  |
| eventTypeFilter  | List<String>?     | ❌       | null             | Event type filter  |
| listenerIdFilter | List<String>?     | ❌       | null             | Listener ID filter |
| customLogger     | Function(String)? | ❌       | null             | Custom log handler |

**GebLogConfig Presets**

| Configuration                 | Description                                |
| ----------------------------- | ------------------------------------------ |
| GebLogConfig.defaultConfig    | Default: info level                        |
| GebLogConfig.debugConfig      | Debug: debug level with detailed info      |
| GebLogConfig.productionConfig | Production: error level, no sensitive info |
| GebLogConfig.silentConfig     | Silent: all logging disabled               |

## 📖 Documentation

- [Getting Started](doc/getting_started.md) - Installation and basic usage
- [API Reference](doc/api_reference.md) - Complete API documentation
- [GebBuilder Widget](doc/widgets/geb_builder.md) - Reactive Widget
- [Debug Panel](doc/widgets/debug_panel.md) - Development debugging tools
- [GebListener Mixin](doc/mixins/geb_listener.md) - Simplified event subscription
- [GebBlocMixin](doc/mixins/geb_bloc_mixin.md) - BLoC integration
- [BLoC Integration Guide](doc/integration/bloc_integration.md) - Complete integration
- [Event Priority](doc/advanced/priority.md) - Priority system
- [Batch Mode](doc/advanced/batch_mode.md) - Performance optimization

## 📚 Detailed Usage

### Event Priority

Event priority determines processing order. There are four levels:

```dart
enum GebPriority {
  low(0),      // Low priority - background tasks like logging, statistics
  normal(1),   // Normal priority - default, general business events
  high(2),     // High priority - user interactions, UI updates
  critical(3); // Critical priority - system-level important events
}

// Usage example
globalEventBus.sendEvent<String>(
  type: 'emergency_logout',
  data: 'Session expired',
  priority: GebPriority.critical,
);
```

### Batch Processing Mode

Enable batch mode for high-frequency event scenarios:

```dart
// Enable batch mode, process events every 50ms
globalEventBus.manager.setBatchMode(true, intervalMs: 50);

// Send many events
for (int i = 0; i < 1000; i++) {
  globalEventBus.sendEvent<int>(
    type: 'batch_event',
    data: i,
  );
}

// Disable batch mode
globalEventBus.manager.setBatchMode(false);
```

### Listening Patterns

#### One-Time Listening

```dart
// Listen once, automatically removed after receiving event
globalEventBus.listenOnce<String>(
  listenerId: 'splash_page',
  onEvent: (GebEvent<String> event) {
    print('App initialization complete');
    // Navigate to main page
  },
);
```

#### Multi-Type Listening

```dart
// Listen for multiple event types simultaneously
globalEventBus.listen<String>(
  listenerId: 'notification_handler',
  eventTypes: ['user_login', 'user_logout', 'message_received'],
  onEvent: (GebEvent<String> event) {
    switch (event.type) {
      case 'user_login':
        handleUserLogin(event);
        break;
      case 'user_logout':
        handleUserLogout(event);
        break;
      case 'message_received':
        handleMessage(event);
        break;
    }
  },
);
```

#### Conditional Listening

```dart
// Conditional event listening
globalEventBus.listen<Map<String, dynamic>>(
  listenerId: 'admin_listener',
  onEvent: (GebEvent<Map<String, dynamic>> event) {
    // Only handle admin-related events
    if (event.data['userRole'] == 'admin') {
      handleAdminEvent(event);
    }
  },
);
```

### Logging Configuration

#### Preset Configurations

```dart
// Development environment - detailed logging
globalEventBus.configureLogging(GebLogConfig.debugConfig);

// Production environment - only errors
globalEventBus.configureLogging(GebLogConfig.productionConfig);

// Disable all logging
globalEventBus.configureLogging(GebLogConfig.silentConfig);
```

#### Custom Configuration

```dart
// Detailed custom logging configuration
globalEventBus.configureLogging(GebLogConfig(
  level: GebLogLevel.info,           // Log level
  enabled: true,                     // Enable logging
  showTimestamp: true,               // Show timestamp
  showEventId: false,                // Hide event ID
  showPriority: true,                // Show priority
  showEventData: false,              // Hide event data (recommended for production)
  showListenerInfo: true,            // Show listener info
  logPrefix: '[MyApp-Events]',       // Custom log prefix
  eventTypeFilter: ['user_action', 'api_call'], // Only log specific event types
  customLogger: (message) {          // Custom log handler
    // Write to file or send to server
    print('Custom: $message');
  },
));
```

### Performance Monitoring

```dart
// Get event statistics
final stats = globalEventBus.stats;

print('Total sent: ${stats.totalEventsSent}');
print('Total received: ${stats.totalEventsReceived}');
print('Last event time: ${stats.lastEventTime}');

// Check event type counts
stats.eventTypeCount.forEach((type, count) {
  print('Event type $type: $count times');
});

// Get performance info
final performanceInfo = globalEventBus.performanceInfo;
print('Active listeners: ${performanceInfo['listenerCount']}');
print('Batch mode: ${performanceInfo['batchEnabled']}');
```

### Event History

```dart
// Configure history (optional, defaults to enabled with max 100 records)
globalEventBus.configureHistory(GebHistoryConfig(
  enabled: true,
  maxHistorySize: 500,
));

// Get recent 10 events
final recentEvents = globalEventBus.getRecentEvents(count: 10);

// Get recent 5 events of specific type
final loginEvents = globalEventBus.getRecentEventsByType('user_login', count: 5);

// Get last event of specific type
final lastLogin = globalEventBus.getLastEventByType('user_login');

// Get all recorded event types
final allTypes = globalEventBus.eventTypes;

// Clear history
globalEventBus.clearHistory();
```

### 🎯 Real-World Use Cases

#### 1. User State Management

```dart
// User login
globalEventBus.sendEvent<UserInfo>(
  type: 'user_login',
  data: UserInfo(id: '123', name: 'John', email: 'john@example.com'),
  priority: GebPriority.high,
);

// Listen for user state changes and update UI immediately after login
globalEventBus.listen<UserInfo>(
  listenerId: 'user_profile_page',
  onEvent: (GebEvent<UserInfo> event) {
    // Update user interface
    updateUserProfile(event.data);
  },
);
```

#### 2. Shopping Cart Management

```dart
// Add item to cart
globalEventBus.sendEvent<CartItem>(
  type: 'cart_add_item',
  data: CartItem(
    productId: 'p001',
    productName: 'iPhone 15',
    price: 999.99,
    quantity: 1,
  ),
);

// Listen for cart changes
globalEventBus.listen<CartItem>(
  listenerId: 'cart_badge',
  eventTypes: ['cart_add_item', 'cart_remove_item', 'cart_update_quantity'],
  onEvent: (GebEvent<CartItem> event) {
    // Update cart badge
    updateCartBadge();
  },
);
```

#### 3. Network Status Monitoring

```dart
// Network status changed
globalEventBus.sendEvent<bool>(
  type: 'network_status_changed',
  data: isConnected,
  priority: GebPriority.critical,
);

// Global network status listener
globalEventBus.listen<bool>(
  listenerId: 'global_network_monitor',
  onEvent: (GebEvent<bool> event) {
    if (event.data) {
      showSnackBar('Network connected');
    } else {
      showSnackBar('Network disconnected');
    }
  },
  eventTypes: ['network_status_changed'],
);
```

#### 4. Theme Switching

```dart
// Switch theme
globalEventBus.sendEvent<ThemeMode>(
  type: 'theme_changed',
  data: ThemeMode.dark,
);

// Listen for theme changes
globalEventBus.listen<ThemeMode>(
  listenerId: 'main_app',
  onEvent: (GebEvent<ThemeMode> event) {
    // Update app theme
    updateAppTheme(event.data);
  },
  eventTypes: ['theme_changed'],
);
```

### 🔧 Advanced Features

#### GebBuilder Reactive Widget

```dart
// Build reactive UI with GebBuilder
class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GebBuilder<String>(
      eventType: 'notification_received',
      useHistoryForInitialData: true,
      initialData: 'No notifications',
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Card(
          child: ListTile(
            title: Text(snapshot.data!),
            subtitle: Text('Event ID: ${snapshot.event?.eventId}'),
          ),
        );
      },
    );
  }
}
```

#### GebListener Mixin

```dart
// Use Mixin for simplified event subscription
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with GebListener {
  String _userName = 'Not logged in';

  @override
  void initState() {
    super.initState();

    // Subscribe to user login event
    gebSubscribe<Map<String, dynamic>>(
      listenerId: 'home_user_login',
      eventType: 'user_login',
      onEvent: (GebEvent<Map<String, dynamic>> event) {
        setState(() {
          _userName = event.data['name'];
        });
      },
    );

    // Subscribe to one-time event
    gebSubscribeOnce<void>(
      listenerId: 'home_first_load',
      eventType: 'app_initialized',
      onEvent: (_) {
        print('App first load complete');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('Welcome, $_userName');
  }

  // All subscriptions automatically cancelled on dispose
}
```

#### BLoC Integration

```dart
// Bridge BLoC and event bus using GebBlocBridge
final bridge = GebBlocBridge<CounterEvent, CounterState>(
  bloc: counterBloc,
  stateEventType: 'counter_state_changed',
);

// Start bridge
bridge.start();

// Forward event bus events to BLoC
bridge.forwardEventToBloc<int>(
  eventType: 'external_increment',
  mapper: (event) => IncrementEvent(event.data),
);

// Manually publish current state
bridge.publishCurrentState();

// Stop bridge (usually called in dispose)
bridge.dispose();
```

```dart
// Direct integration in BLoC using GebBlocMixin
class CounterBloc extends Bloc<CounterEvent, CounterState> with GebBlocMixin<CounterState> {
  CounterBloc() : super(CounterState(0)) {
    // Initialize event bus integration
    gebInit(
      eventBus: globalEventBus,
      stateEventType: 'counter_state',
    );
  }

  // ... other BLoC logic ...

  @override
  Future<void> close() {
    gebDispose(); // Clean up resources
    return super.close();
  }
}
```

#### BLoC Event Mapping

```dart
// Map events using GebBlocMapper
bridge.forwardEventToBloc<String>(
  eventType: 'user_input',
  mapper: GebBlocMapper.direct, // Direct mapping
);

// Use custom mapping
bridge.forwardEventToBloc<Map<String, dynamic>>(
  eventType: 'complex_event',
  mapper: (event) => CustomEvent(
    id: event.data['id'],
    name: event.data['name'],
  ),
);
```

### 🧪 Testing Support

```dart
// Usage in tests
void main() {
  group('Global Event Bus Tests', () {
    setUp(() {
      // Clean up previous listeners
      globalEventBus.removeAllListeners();
    });

    test('should send and receive events', () async {
      String? receivedData;

      // Set up listener
      final subscription = globalEventBus.listen<String>(
        listenerId: 'test_listener',
        onEvent: (GebEvent<String> event) {
          receivedData = event.data;
        },
      );

      // Send event
      globalEventBus.sendEvent<String>(
        type: 'test_event',
        data: 'test_data',
      );

      // Wait for event processing
      await Future.delayed(const Duration(milliseconds: 10));

      // Verify result
      expect(receivedData, equals('test_data'));

      // Clean up
      subscription.cancel();
    });
  });
}
```

### 📊 Performance Tips

1. **Use Event Priority Wisely**
   - Use `critical` priority for system-critical events
   - Use `high` priority for user interaction events
   - Use `normal` priority for general business events
   - Use `low` priority for logging and statistics events

2. **Optimize for High-Frequency Events**
   - Enable batch processing mode for high-frequency events (scrolling, animations)
   - Set reasonable batch interval (recommended 50-200ms)
   - Avoid time-consuming operations in event handlers

3. **Memory Management**
   - Use `GebListener` Mixin or `GebBuilder` Widget for automatic subscription lifecycle
   - Cancel subscriptions in Widget `dispose()`
   - Avoid creating too many listeners

4. **Logging Configuration**
   - Use `GebLogConfig.productionConfig` in production
   - Use event type filtering to reduce log volume
   - Consider using custom log handlers

5. **History Configuration**
   - Set reasonable maximum history size based on business needs
   - Use `GebHistoryConfig.disabled` when history is not needed

### 🤝 Contributing

We welcome contributions in any form! Please see CONTRIBUTING.md for details.

#### Development Setup

```bash
# Clone repository
git clone https://gitee.com/pedro-labs/global_event_bus.git
# Enter project directory
cd global_event_bus
# Install dependencies
flutter pub get
# Run example
cd example && flutter run
# Run tests
flutter test
```

### 📄 License

This project is licensed under the MIT License.

### 🔗 Links

- [Pub.dev Package](https://pub.dev/packages/global_event_bus)
- [GitHub Repository](https://github.com/pedro-labs/global_event_bus)
- [Gitee Repository](https://gitee.com/pedro-labs/global_event_bus)
- [Issue Tracker](https://gitee.com/pedro-labs/global_event_bus/issues)

### 📝 Class Naming Reference

For backward compatibility, old class names are preserved via typedef. New projects should use the `Geb`-prefixed class names.

| Old Name                  | New Name             | Status      |
| ------------------------- | -------------------- | ----------- |
| GlobalEvent\<T\>          | GebEvent\<T\>        | @Deprecated |
| BaseGlobalEvent           | GebBaseEvent         | @Deprecated |
| EventPriority             | GebPriority          | @Deprecated |
| EventStats                | GebStats             | @Deprecated |
| GlobalEventLogger         | GebLogger            | @Deprecated |
| GlobalEventLogConfig      | GebLogConfig         | @Deprecated |
| EventLogLevel             | GebLogLevel          | @Deprecated |
| EventHistory              | GebHistory           | @Deprecated |
| EventHistoryConfig        | GebHistoryConfig     | @Deprecated |
| EventBusBuilder\<T\>      | GebBuilder\<T\>      | @Deprecated |
| EventBusSnapshot\<T\>     | GebSnapshot\<T\>     | @Deprecated |
| EventBusConnectionState   | GebConnectionState   | @Deprecated |
| EventBusListener          | GebListener          | @Deprecated |
| EventBusNoDataListener    | GebNoDataListener    | @Deprecated |
| EventBusBlocBridge\<E,S\> | GebBlocBridge\<E,S\> | @Deprecated |
| EventBusBlocMixin\<S\>    | GebBlocMixin\<S\>    | @Deprecated |
| BlocEventMapper           | GebBlocMapper        | @Deprecated |
