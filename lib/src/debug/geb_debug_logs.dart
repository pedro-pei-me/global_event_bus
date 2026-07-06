import 'package:flutter/material.dart';

import '../global_event_bus_api.dart';
import '../global_event_log.dart';

class GebDebugLogPanel extends StatefulWidget {
  const GebDebugLogPanel({super.key});

  @override
  State<GebDebugLogPanel> createState() => _GebDebugLogPanelState();
}

class _GebDebugLogPanelState extends State<GebDebugLogPanel> {
  final List<LogEntry> _logs = [];
  GebLogLevel _filterLevel = GebLogLevel.debug;
  bool _isPaused = false;
  final ScrollController _scrollController = ScrollController();
  GebLogConfig? _originalLogConfig;

  static const int maxLogs = 500;

  @override
  void initState() {
    super.initState();
    _setupLogCollector();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _restoreLogCollector();
    super.dispose();
  }

  void _setupLogCollector() {
    _originalLogConfig = GebLogger.config;
    globalEventBus.configureLogging(
      GebLogger.config.copyWith(
        customLogger: (message) {
          if (!_isPaused && mounted) {
            final level = _parseLogLevel(message);
            setState(() {
              _logs.insert(0, LogEntry(message, level));
              while (_logs.length > maxLogs) {
                _logs.removeLast();
              }
            });

            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(0);
                }
              });
            }
          }
          debugPrint(message);
        },
      ),
    );
  }

  void _restoreLogCollector() {
    if (_originalLogConfig != null) {
      globalEventBus.configureLogging(_originalLogConfig!);
    }
  }

  GebLogLevel _parseLogLevel(String message) {
    if (message.contains('[ERROR]')) return GebLogLevel.error;
    if (message.contains('[WARNING]')) return GebLogLevel.warning;
    if (message.contains('[DEBUG]')) return GebLogLevel.debug;
    return GebLogLevel.info;
  }

  void _togglePause() {
    if (!mounted) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _clearLogs() {
    if (!mounted) return;
    setState(() {
      _logs.clear();
    });
  }

  void _exportLogs() {
    final exportText = _logs.map((log) => log.message).join('\n');
    debugPrint('=== Log Export ===\n$exportText\n=== End Export ===');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日志已导出到控制台')),
      );
    }
  }

  Color _getLevelColor(GebLogLevel level) {
    switch (level) {
      case GebLogLevel.error:
        return Colors.red;
      case GebLogLevel.warning:
        return Colors.orange;
      case GebLogLevel.debug:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _togglePause,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPaused ? Colors.green : Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: Text(_isPaused ? '继续' : '暂停'),
              ),
              ElevatedButton(
                onPressed: _clearLogs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('清空'),
              ),
              ElevatedButton(
                onPressed: _exportLogs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('导出'),
              ),
              DropdownButton<GebLogLevel>(
                value: _filterLevel,
                items: GebLogLevel.values
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level.name.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() {
                    _filterLevel = value ?? GebLogLevel.debug;
                  });
                },
              ),
              Text('共 ${_logs.length} 条'),
            ],
          ),
        ),
        Expanded(
          child: _logs.isEmpty
              ? const Center(child: Text('等待日志...'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    if (log.level.index < _filterLevel.index) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getLevelColor(log.level).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getLevelColor(log.level),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class LogEntry {
  final String message;
  final GebLogLevel level;

  LogEntry(this.message, this.level);
}