// main.dart

import 'dart:async';

import 'package:flutter/material.dart';

import 'charging_events.dart';
import 'notification_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Bus POC',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      home: const PocHomePage(),
    );
  }
}

class PocHomePage extends StatelessWidget {
  const PocHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typed Event Bus POC')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. The Control Panel to trigger events
            const ControlPanel(),
            const Divider(height: 30, thickness: 2),
            // 2. The Listener Widgets that react to events
            const Text(
              'Listener Widgets',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // This listener ONLY cares about START and STOP events
            ListenerWidget(
              title: 'Home Page Listener',
              description: 'Listens for STARTED and STOPPED events.',
              listenTo: [ChargingSessionStarted, ChargingSessionStopped],
            ),
            // This listener ONLY cares about PAUSED events
            ListenerWidget(
              title: 'Charging Timer Listener',
              description: 'Only listens for PAUSED events.',
              listenTo: [ChargingSessionPaused],
            ),
            // This listener cares about EVERYTHING
            ListenerWidget(
              title: 'Global State Listener',
              description: 'Listens for ALL charging events.',
              listenTo: [ChargingEvent], // Listens to the base class
            ),
          ],
        ),
      ),
    );
  }
}

// The buttons that create and broadcast events
class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Control Panel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed:
                      () => NotificationService.instance.broadcast(
                        ChargingSessionStarted(),
                      ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed:
                      () => NotificationService.instance.broadcast(
                        ChargingSessionStopped(),
                      ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed:
                      () => NotificationService.instance.broadcast(
                        ChargingSessionPaused(),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable listener widget
class ListenerWidget extends StatefulWidget {
  final String title;
  final String description;
  final List<Type> listenTo;

  const ListenerWidget({
    super.key,
    required this.title,
    required this.description,
    required this.listenTo,
  });

  @override
  State<ListenerWidget> createState() => _ListenerWidgetState();
}

class _ListenerWidgetState extends State<ListenerWidget> {
  StreamSubscription? _subscription;
  String _lastReceivedMessage = 'Awaiting events...';
  Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _subscription = NotificationService.instance.eventStream.listen((
      ChargingEvent event,
    ) {
      // This is the core logic: check if the received event's type
      // is in the list of types this widget cares about.
      if (widget.listenTo.contains(event.runtimeType) ||
          widget.listenTo.contains(ChargingEvent)) {
        // Print to console for clarity
        print("${widget.title} RECEIVED event. ${event.purpose}");

        // Update the UI
        setState(() {
          _lastReceivedMessage = event.purpose;
          if (event is ChargingSessionStarted)
            _cardColor = Colors.green.shade100;
          if (event is ChargingSessionStopped) _cardColor = Colors.red.shade100;
          if (event is ChargingSessionPaused)
            _cardColor = Colors.orange.shade100;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Very important to prevent memory leaks!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _cardColor,
      child: ListTile(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Text('Last Received: $_lastReceivedMessage'),
          ],
        ),
      ),
    );
  }
}
