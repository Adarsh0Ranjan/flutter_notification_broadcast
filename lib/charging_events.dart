// charging_events.dart

/// A base class for all charging-related events.
/// This allows us to use a single stream for all related events.
abstract class ChargingEvent {
  final String purpose;
  ChargingEvent(this.purpose);
}

/// Event for when a charging session starts.
class ChargingSessionStarted extends ChargingEvent {
  ChargingSessionStarted()
    : super(
        "Purpose: A new charging session has begun. Update UI to show active state.",
      );
}

/// Event for when a charging session stops.
class ChargingSessionStopped extends ChargingEvent {
  ChargingSessionStopped()
    : super("Purpose: The charging session has ended. Clean up UI and state.");
}

/// Event for when a charging session is paused.
class ChargingSessionPaused extends ChargingEvent {
  ChargingSessionPaused()
    : super(
        "Purpose: The session is paused. Update timer UI to a 'paused' state.",
      );
}
