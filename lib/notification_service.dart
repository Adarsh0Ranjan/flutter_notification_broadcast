// notification_service.dart

import 'dart:async';

import 'charging_events.dart'; // Import our event definitions

class NotificationService {
  // Singleton setup
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  // The StreamController now broadcasts specific ChargingEvent objects
  final StreamController<ChargingEvent> _eventController =
      StreamController<ChargingEvent>.broadcast();

  // The public stream that widgets can listen to
  Stream<ChargingEvent> get eventStream => _eventController.stream;

  // Method to add a new event to the stream
  void broadcast(ChargingEvent event) {
    print("\n--- Broadcasting new event: ${event.runtimeType} ---");
    _eventController.add(event);
  }

  // Dispose the controller when it's no longer needed
  void dispose() {
    _eventController.close();
  }
}
