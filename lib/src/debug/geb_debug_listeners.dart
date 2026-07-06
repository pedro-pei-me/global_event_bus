import 'dart:async';

import 'package:flutter/material.dart';

import '../global_event_bus_api.dart';

class GebDebugListenerPanel extends StatefulWidget {
  const GebDebugListenerPanel({super.key});

  @override
  State<GebDebugListenerPanel> createState() => _GebDebugListenerPanelState();
}

class _GebDebugListenerPanelState extends State<GebDebugListenerPanel> {
  late Timer _timer;
  List<String> _listenerIds = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _listenerIds = globalEventBus.listenerIds;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _removeListener(String listenerId) {
    globalEventBus.removeListener(listenerId);
  }

  void _removeAllListeners() {
    globalEventBus.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: _removeAllListeners,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('移除全部'),
              ),
              const SizedBox(width: 8),
              Text('共 ${_listenerIds.length} 个监听器'),
            ],
          ),
        ),
        Expanded(
          child: _listenerIds.isEmpty
              ? const Center(child: Text('暂无活跃监听器'))
              : ListView.builder(
                  itemCount: _listenerIds.length,
                  itemBuilder: (context, index) {
                    final listenerId = _listenerIds[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(
                          listenerId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeListener(listenerId),
                          tooltip: '移除监听器',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}