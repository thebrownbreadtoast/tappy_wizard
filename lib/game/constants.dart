class GameConstants {
  GameConstants._();

  // ── Physics ──────────────────────────────────────
  static const double defaultGravity = 1600.0;
  static const double defaultFlapForce = -500.0;
  static const double defaultMaxFallSpeed = 600.0;

  // ── Wizard ───────────────────────────────────────
  static const double wizardWidth = 50.0;
  static const double wizardHeight = 40.0;
  static const double wizardHitboxInset = 6.0;
  static const double wizardStartXFraction = 0.25;
  static const double wizardStartYFraction = 0.45;
  static const double wizardTiltUp = -0.5;
  static const double wizardTiltDown = 0.8;

  // ── Pipes ────────────────────────────────────────
  static const double pipeWidth = 60.0;
  static const double defaultPipeGap = 250.0;
  static const double defaultPipeSpeed = 200.0;
  static const double defaultPipeSpawnInterval = 1.5;
  static const double pipeMinTopHeight = 70.0;
  static const double pipeBottomPadding = 100.0;

  // ── Ground ───────────────────────────────────────
  static const double groundHeight = 80.0;
  static const double groundSpeed = 200.0; // matches pipe speed

  // ── Background ───────────────────────────────────
  static const double bgLayerSpeed1 = 30.0; // far layer
  static const double bgLayerSpeed2 = 60.0; // near layer

  // ── Difficulty scaling ───────────────────────────
  static const double speedIncreasePerPoint = 1.2; // px/s per score
  static const double minPipeGap = 130.0;
  static const double maxPipeSpeed = 300.0;

  // ── Animation ────────────────────────────────────
  static const double wizardFrameDuration = 0.12; // seconds per frame
  static const int wizardFrameCount = 4;
}
