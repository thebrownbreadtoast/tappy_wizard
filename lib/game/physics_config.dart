class PhysicsConfig {
  double gravity;
  double flapForce;
  double pipeGap;

  PhysicsConfig({
    required this.gravity,
    required this.flapForce,
    required this.pipeGap,
  });

  /// Creates a copy of this config with updated values.
  PhysicsConfig copyWith({
    double? gravity,
    double? flapForce,
    double? pipeGap,
  }) {
    return PhysicsConfig(
      gravity: gravity ?? this.gravity,
      flapForce: flapForce ?? this.flapForce,
      pipeGap: pipeGap ?? this.pipeGap,
    );
  }
}
