import 'dart:async';

import 'package:flutter/material.dart';
import 'package:global_event_bus/global_event_bus.dart';

abstract class DemoEvent {}

class Increment extends DemoEvent {}

class Decrement extends DemoEvent {}

class Reset extends DemoEvent {}

class DemoState {
  final int count;
  const DemoState(this.count);
}

abstract class SimpleBloc<E, S> {
  final StreamController<E> _eventController = StreamController<E>();
  final StreamController<S> _stateController = StreamController<S>.broadcast();

  S _currentState;
  S get state => _currentState;
  Stream<S> get stream => _stateController.stream;

  SimpleBloc(S initialState) : _currentState = initialState {
    _eventController.stream.listen(_mapEventToState);
    _stateController.add(initialState);
  }

  void _mapEventToState(E event) => onEvent(event);
  void onEvent(E event);

  void emit(S state) {
    _currentState = state;
    _stateController.add(state);
  }

  void add(E event) => _eventController.add(event);

  Future<void> close() async {
    await _eventController.close();
    await _stateController.close();
  }
}

class CounterBloc extends SimpleBloc<DemoEvent, DemoState> {
  CounterBloc() : super(const DemoState(0));

  @override
  void onEvent(DemoEvent event) {
    if (event is Increment) {
      emit(DemoState(state.count + 1));
    } else if (event is Decrement) {
      emit(DemoState(state.count - 1));
    } else if (event is Reset) {
      emit(const DemoState(0));
    }
  }
}

class BlocSimpleDemoPage extends StatefulWidget {
  const BlocSimpleDemoPage({super.key});

  @override
  State<BlocSimpleDemoPage> createState() => _BlocSimpleDemoPageState();
}

class _BlocSimpleDemoPageState extends State<BlocSimpleDemoPage> {
  late CounterBloc _bloc;
  StreamSubscription? _subscription;
  bool _bridgeEnabled = false;
  String _log = '';

  void _logMessage(String msg) {
    if (!mounted) return;
    setState(() {
      _log = msg;
    });
  }

  void _enableBridge() {
    globalEventBus.listen<void>(
      listenerId: 'simple_bloc_inc',
      eventTypes: ['simple_inc'],
      onEvent: (_) {
        _bloc.add(Increment());
        _logMessage('EventBus → Increment');
      },
    );

    globalEventBus.listen<void>(
      listenerId: 'simple_bloc_dec',
      eventTypes: ['simple_dec'],
      onEvent: (_) {
        _bloc.add(Decrement());
        _logMessage('EventBus → Decrement');
      },
    );

    _bloc.stream.listen((state) {
      globalEventBus.sendEvent<DemoState>(
        type: 'simple_state',
        data: state,
      );
    });

    _bridgeEnabled = true;
    _logMessage('Bridge enabled');
  }

  void _disableBridge() {
    globalEventBus.removeListener('simple_bloc_inc');
    globalEventBus.removeListener('simple_bloc_dec');
    _bridgeEnabled = false;
    _logMessage('Bridge disabled');
  }

  @override
  void initState() {
    super.initState();
    _bloc = CounterBloc();
    _subscription = _bloc.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _disableBridge();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLoC Simple Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Count: ${_bloc.state.count}', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _bloc.add(Increment());
                    _logMessage('Direct Increment');
                  },
                  child: const Text('+1 Direct'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _bloc.add(Decrement());
                    _logMessage('Direct Decrement');
                  },
                  child: const Text('-1 Direct'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _bridgeEnabled ? _disableBridge : _enableBridge,
              child: Text(_bridgeEnabled ? 'Disable Bridge' : 'Enable Bridge'),
            ),
            const SizedBox(height: 16),
            if (_bridgeEnabled)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      globalEventBus.sendEventWithoutData(type: 'simple_inc');
                    },
                    child: const Text('+1 via EventBus'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      globalEventBus.sendEventWithoutData(type: 'simple_dec');
                    },
                    child: const Text('-1 via EventBus'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            GebBuilder<DemoState>(
              eventType: 'simple_state',
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('Waiting...');
                return Text('Sync: ${snapshot.data!.count}');
              },
            ),
            const SizedBox(height: 16),
            Text('Log: $_log'),
          ],
        ),
      ),
    );
  }
}
