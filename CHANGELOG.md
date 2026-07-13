# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-07-06

### 🚀 New Features

**Visual Debug Panel**

- Added `GebDebugPanel` debug panel, providing visual development debugging tools
- Includes 6 functional modules:
  - **Statistics Overview**: Total events, listener count, event type distribution, running status
  - **Real-time Event Stream**: Real-time event list, priority indicators, pause/resume, clear
  - **History**: Event history list, filter by type, view event details
  - **Listener Management**: Listener list, listening types, remove single/all listeners
  - **Log Viewer**: Real-time logs, level filtering, pause/resume, export to console
  - **Debug Tools**: Send test events, system operations, batch mode toggle, data export
- Supports multiple opening methods:
  - `globalEventBus.debug.show(context)` - Standard way
  - `globalEventBus.debug.showModal(context)` - Modal dialog
  - `globalEventBus.debug.showFloating(context)` - Floating button
  - `globalEventBus.debug.pushNamed(context)` - Named route
- Provides `GebDebugController` for easy integration and configuration
- Supports automatic floating debug button in development environment

### 📝 Documentation

- Added `doc/` directory structure, organized according to Dart official conventions
- Created detailed functional module documentation:
  - `doc/getting_started.md` - Getting started guide
  - `doc/api_reference.md` - Complete API reference
  - `doc/widgets/geb_builder.md` - GebBuilder Widget usage guide
  - `doc/widgets/debug_panel.md` - Debug panel usage guide
  - `doc/mixins/geb_listener.md` - GebListener Mixin usage guide
  - `doc/mixins/geb_bloc_mixin.md` - GebBlocMixin usage guide
  - `doc/integration/bloc_integration.md` - BLoC integration complete guide
  - `doc/advanced/priority.md` - Event priority system
  - `doc/advanced/batch_mode.md` - Batch processing mode
- Updated README.md with documentation directory links
- Improved example project with debug panel demo entry

### 🔧 Improvements

- Fixed Row overflow issue in debug panel log page by replacing Row with Wrap
- Fixed setState called after dispose issue by adding mounted checks
- Optimized layout and interaction of debug panel modules

---

## [1.2.0] - 2026-07-06

### 🚀 New Features

**GebBuilder - Reactive Widget**

- Added `GebBuilder<T>` Widget, similar to Flutter's `StreamBuilder`, designed specifically for global event bus
- Automatically manages event subscription and cancellation
- Supports getting initial data from history
- Provides `GebSnapshot<T>` snapshot class, encapsulating event data and connection state
- Supports `GebConnectionState` connection state enum (none/active/done)

**GebListener - Event Listener Mixin**

- Added `GebListener` Mixin for listening to events in StatefulWidget
- Automatically manages subscription lifecycle, cancels all subscriptions when Widget is destroyed
- Provides `gebSubscribe<T>()` and `gebSubscribeOnce<T>()` methods
- Added `GebNoDataListener` Mixin, specifically for listening to events without data

**GebBlocBridge - BLoC Integration**

- Added `GebBlocBridge<Event, State>` bridge for bidirectional communication between BLoC and event bus
- BLoC state changes automatically sent to event bus
- Supports forwarding event bus events to BLoC
- Added `GebBlocMixin<State>` for direct event bus integration in BLoC classes
- Added `GebBlocMapper` utility class with multiple predefined event mapping methods
- Added `global_event_bus_bloc.dart` export file for easy BLoC integration

**GebHistory - Event History**

- Added `GebHistory` event history manager
- Supports querying historical events by type, count, and other methods
- Provides `GebHistoryConfig` configuration class with enable/disable and max records settings
- GlobalEventBus API added `history`, `configureHistory()`, `getRecentEvents()` and other methods

**Logging Configuration Enhancements**

- `GebLogConfig` added preset configurations: `debugConfig`, `productionConfig`, `silentConfig`
- Added `copyWith()` method for selective configuration overriding
- Added `listenerIdFilter` filter for filtering logs by listener ID

**Class Naming Refactoring**

- All core classes added `Geb` prefix (e.g., `GebEvent<T>`, `GebPriority`, `GebLogger`)
- Maintained backward compatibility through typedef and @Deprecated (e.g., `GlobalEvent<T> = GebEvent<T>`)
- Old class names still work but show deprecation warnings

### 🔧 Improvements

- Used `is` type checking instead of direct casting to avoid CastError
- Checked `mounted` property before State updates to prevent Flutter framework assertion errors
- Optimized event sorting and sending logic in batch mode
- Enhanced error handling and exception catching mechanism

### ⚠️ Backward Compatibility

- All old class names (e.g., `GlobalEvent<T>`, `EventPriority`) preserved via typedef
- Old class names marked as @Deprecated with deprecation warnings
- New projects recommended to use the new Geb-prefixed class names

---

## [1.1.0] - 2026-06-18

### 📝 Documentation

- Added complete API documentation comments for all classes, enums, functions, and properties
- Added detailed parameter descriptions, return value descriptions, and usage examples
- Improved documentation for `EventPriority` enum priority descriptions
- Improved documentation for `EventStats` class statistics methods
- Improved documentation for `BaseGlobalEvent` and `GlobalEvent<T>` event models
- Improved documentation for `EventLogLevel` enum log level descriptions
- Improved documentation for `GlobalEventLogConfig` configuration parameters and preset configurations
- Improved documentation for all `GlobalEventLogger` log methods
- Improved documentation for `GlobalEventManager` core management methods
- Improved documentation for `GlobalEventBus` public API
- All documentation includes Chinese descriptions and code examples

### 🔧 Code Quality

- Passed `flutter analyze` static code analysis with no issues
- Passed `pana` tool score pre-check with score 120/140
- All unit tests passed 100% (6/6 test cases)

---

## [1.0.2] - 2025-08-26

### 🚀 Release Improvements

- Improved release process to ensure code quality and test coverage
- Verified through comprehensive static code analysis and unit testing
- Optimized package release standards to improve user experience
- Updated documentation and API descriptions to ensure version consistency

---

## [1.0.1] - 2025-01-26

### 🔧 Code Quality Improvements

- Fixed code style issues in test files
- Optimized constructor const keyword usage for performance
- Passed static code analysis checks to ensure code quality
- Unified code formatting standards

---

## [1.0.0] - Previous Version

### 🎉 Major Release - Pure Dart Package

### ✨ Features

- **BREAKING CHANGE**: Converted to pure Dart package, removed all platform-specific code
- Maintained all core event bus functionality
- Simplified package structure for improved performance and compatibility

### 🗑️ Removed

- Removed platform plugin configuration and dependencies
- Removed `getPlatformVersion()` method (non-core functionality)
- Removed all native platform directories (android, ios, linux, macos, windows)
- Removed platform interface related files:
  - `global_event_bus_platform_interface.dart`
  - `global_event_bus_method_channel.dart`
  - `global_event_bus_web.dart`

### 🔧 Technical Changes

- Updated `pubspec.yaml`, removed `plugin_platform_interface` and `flutter_web_plugins` dependencies
- Simplified main entry file `global_event_bus.dart`
- Updated test files to focus on core event bus functionality

### 📈 Benefits

- ✅ Better cross-platform compatibility
- ✅ Simpler maintenance and deployment
- ✅ Faster package loading speed
- ✅ Reduced dependency conflict risk

### 🔄 Migration Guide

If you previously used the `getPlatformVersion()` method, please remove related calls. All other APIs remain unchanged.

---

## [Unreleased]

### 🚀 Planned Features

- Event persistence support
- Event replay functionality
- More event filters

---

## [0.0.7]

### 🔧 Improvements

- **Repository Migration**: Migrated main repository from GitHub to Gitee for better domestic access experience
- **Documentation Updates**: Updated repository links in all project documents, including:
  - homepage, repository, and issue_tracker links in `pubspec.yaml`
  - Clone command in `README.md`
  - homepage links in iOS and macOS podspec files
- **Dual Repository Sync**: Configured dual repository sync mechanism between Gitee and GitHub, with GitHub as backup repository

### 📝 Documentation

- Updated project homepage link to Gitee repository
- Updated issue feedback link to Gitee Issues
- Maintained technical documentation and third-party dependency links unchanged

---

## [0.0.6]

### 🚀 New Features

`GlobalEventBus` Class

- **Enhanced Event Sending API**: Added `sendEventWithoutData()` method for sending events without data payload
- **Safe Event Sending**: Added `sendEventSafe()` method providing exception-safe sending mechanism
- **Delayed Event Sending**: Added `sendEventDelayed()` method supporting delayed event sending
- **One-Time Listener**: Added `listenOnce()` method for one-time event listeners
- **Batch Listener Management**: Added `removeAllListeners()` and `cleanupExpiredListeners()` methods
- **Listener Status Query**: Added `hasListener()` method to check if a specific listener exists
- **Performance Monitoring Enhancement**: Added `listenerCount`, `listenerIds`, and `performanceInfo` properties
- **Batch Processing Control**: Added `setBatchMode()` method for dynamic batch processing mode enable/disable

### 🔧 Improvements

- **API Completeness**: GlobalEventBus class now provides more complete event management functionality
- **Error Handling Enhancement**: All listener methods now support optional `onError` callback parameter
- **Type Safety Optimization**: Improved generic event type inference and safety
- **Performance Monitoring**: Enhanced event statistics and performance information collection
- **Code Structure Optimization**: Better encapsulation, hiding internal implementation details

### 📝 Documentation

- Improved GlobalEventBus class API documentation
- Added usage examples and best practices for new features
- Updated documentation related to performance optimization

### 🐛 Fixes

- Fixed metadata parameter passing issue in `sendEventDelayed()` method
- Optimized automatic cleanup mechanism for one-time listeners
- Improved event sorting logic in batch processing mode

### ⚡ Performance Optimizations

- Optimized listener lookup and management performance
- Improved batch event processing efficiency
- Reduced unnecessary memory allocation and garbage collection

---

## [0.0.5]

### 🚀 New Features

- Support for optional data field when sending events (GlobalEvent class modified to T? type)
- Optimized sendEvent method implementation in global_event_manager.dart

### 🔧 Improvements

- Added type validation for null data scenarios
- Updated related test cases to cover events without data parameter

---

## [0.0.4]

### 🐛 Fixes

- Fixed Android platform package name configuration issue, resolving "cannot find main class" error when referencing the plugin
- Added package declaration in Android Kotlin files to ensure package name consistency with configuration
- Fixed missing `dart:async` import in test files
- Optimized Android platform compatibility

### 🔧 Improvements

- Unified Android package name to `com.example.global_event_bus`
- Improved Kotlin file package structure declarations
- Enhanced plugin reference stability in different projects

### 📝 Documentation

- Updated Android platform configuration documentation
- Improved plugin integration guide

### ⚠️ Version Notes

- Versions 0.0.2 and 0.0.3 have been withdrawn due to Android compatibility issues
- Strongly recommended for all users to upgrade to version 0.0.4

---

## [0.0.3]

### 🚀 New Features

- Upgraded minimum Dart SDK version requirement to 2.19.0 for improved performance and stability
- Upgraded minimum Flutter SDK version requirement to 3.3.0
- Removed web plugin support
- Enhanced type safety checks and compile-time optimizations

### 🔧 Improvements

- Optimized event dispatch performance, reduced memory usage
- Improved efficiency of batch processing mechanism
- Enhanced error handling and exception catching
- Optimized log output format and performance

### 📝 Documentation

- Updated API documentation to reflect latest changes
- Improved code examples and best practice guides
- Added performance optimization suggestions

### 🐛 Fixes

- Fixed memory leak issues in high-concurrency scenarios
- Resolved event loss issues in certain edge cases
- Fixed Web platform compatibility issues

### ⚠️ Breaking Changes

- Minimum Dart SDK version requirement increased from 2.17.0 to 2.19.0
- Minimum Flutter SDK version requirement increased from 3.0.0 to 3.3.0

---

## [0.0.2]

### 🚀 New Features

- Reduced minimum Flutter SDK version requirement to 3.0.0 for improved compatibility
- Reduced minimum Dart SDK version requirement to 2.17.0
- Optimized dependency package version constraints for improved stability

### 🔧 Improvements

- Updated project documentation and example code
- Improved test coverage
- Optimized plugin platform compatibility configuration

### 📝 Documentation

- Added detailed API documentation
- Improved usage examples and best practices
- Updated README.md file

### 🐛 Fixes

- Fixed compatibility issues on certain platforms
- Optimized event processing performance

---

## [0.0.1]

### 🎉 Initial Release

- Initial release of Global Event Bus
- Type-safe event system with generic support
- Event priority system (critical, high, normal, low)
- Batch processing mode for high-frequency events
- Comprehensive logging system with multiple levels
- Performance monitoring and statistics
- Delayed event sending
- Multiple listener types (once, multi-type, conditional)

### ✨ Core Features

- **Type Safety**: Full Dart generic support, compile-time type checking
- **Priority System**: Supports critical, high, normal, low four priorities
- **Batch Processing**: Batch processing mode for high-frequency events, improving performance
- **Logging System**: Multi-level log recording for debugging and monitoring
- **Performance Monitoring**: Built-in statistics for monitoring event sending and receiving
- **Delayed Sending**: Supports delayed event sending
- **Multiple Listeners**: Supports once, multi-type, conditional listeners

### 🎯 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Linux
- ✅ Windows

---

## Version Notes

### Version Number Rules

This project follows [Semantic Versioning](https://semver.org/lang/en/):

- **Major Version**: Incompatible API changes
- **Minor Version**: Backward-compatible feature additions
- **Patch Version**: Backward-compatible bug fixes

### Icon Definitions

- 🚀 New Feature (Added)
- 🔧 Improvement (Changed)
- 🗑️ Deprecated
- 🐛 Bug Fix (Fixed)
- 🔒 Security
- 📝 Documentation
- ⚠️ Breaking Changes
- 🎉 Major Milestones
- ⚡ Performance Optimization
