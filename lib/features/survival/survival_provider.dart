import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'survival_controller.dart';

/// Exposes [SurvivalController] state to Flutter widgets via Riverpod.
///
/// The game loop mutates [SurvivalController] directly for performance.
/// This notifier polls key values each game tick and notifies the HUD.
class SurvivalNotifier extends Notifier<SurvivalState> {
  SurvivalController? _controller;

  @override
  SurvivalState build() => SurvivalState.initial();

  /// Called by VeilbornGame after the player is loaded.
  void attach(SurvivalController controller) {
    _controller = controller;

    // Wire threshold callback → notify UI
    controller.onSanityThresholdCrossed = (threshold) {
      state = state.copyWith(currentThreshold: threshold);
      notifyListeners(); // force immediate UI update on threshold cross
    };
  }

  /// Called every game tick by VeilbornGame.update()
  void syncFromController() {
    final c = _controller;
    if (c == null) return;
    state = SurvivalState(
      health:           c.health,
      maxHealth:        c.maxHealth,
      stamina:          c.stamina,
      maxStamina:       c.maxStamina,
      sanity:           c.sanity,
      maxSanity:        c.maxSanity,
      currentThreshold: state.currentThreshold,
    );
  }

  // Trigger a rebuild by reassigning state — Riverpod 2.x pattern
  void notifyListeners() { state = state; }
}

final survivalProvider =
    NotifierProvider<SurvivalNotifier, SurvivalState>(SurvivalNotifier.new);

// ── State model ───────────────────────────────────────────
class SurvivalState {
  const SurvivalState({
    required this.health,
    required this.maxHealth,
    required this.stamina,
    required this.maxStamina,
    required this.sanity,
    required this.maxSanity,
    required this.currentThreshold,
  });

  factory SurvivalState.initial() => const SurvivalState(
    health:           100,
    maxHealth:        100,
    stamina:          100,
    maxStamina:       100,
    sanity:           100,
    maxSanity:        100,
    currentThreshold: SanityThreshold.normal,
  );

  final double          health;
  final double          maxHealth;
  final double          stamina;
  final double          maxStamina;
  final double          sanity;
  final double          maxSanity;
  final SanityThreshold currentThreshold;

  SurvivalState copyWith({
    double?          health,
    double?          maxHealth,
    double?          stamina,
    double?          maxStamina,
    double?          sanity,
    double?          maxSanity,
    SanityThreshold? currentThreshold,
  }) => SurvivalState(
    health:           health           ?? this.health,
    maxHealth:        maxHealth        ?? this.maxHealth,
    stamina:          stamina          ?? this.stamina,
    maxStamina:       maxStamina       ?? this.maxStamina,
    sanity:           sanity           ?? this.sanity,
    maxSanity:        maxSanity        ?? this.maxSanity,
    currentThreshold: currentThreshold ?? this.currentThreshold,
  );
}
