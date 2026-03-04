import 'package:shared_preferences/shared_preferences.dart';
import '../game/constants.dart';
import '../game/physics_config.dart';

/// Persists and manages game physics settings.
class SettingsService {
  static const _gravityKey = 'physics_gravity';
  static const _flapForceKey = 'physics_flap_force';
  static const _pipeGapKey = 'physics_pipe_gap';

  SharedPreferences? _prefs;
  late PhysicsConfig _config;

  PhysicsConfig get config => _config;

  /// Loads settings from disk or uses defaults.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    _config = PhysicsConfig(
      gravity: _prefs?.getDouble(_gravityKey) ?? GameConstants.defaultGravity,
      flapForce:
          _prefs?.getDouble(_flapForceKey) ?? GameConstants.defaultFlapForce,
      pipeGap: _prefs?.getDouble(_pipeGapKey) ?? GameConstants.defaultPipeGap,
    );
  }

  /// Updates a setting and persists it.
  Future<void> updateConfig(PhysicsConfig newConfig) async {
    _config.gravity = newConfig.gravity;
    _config.flapForce = newConfig.flapForce;
    _config.pipeGap = newConfig.pipeGap;

    await _prefs?.setDouble(_gravityKey, _config.gravity);
    await _prefs?.setDouble(_flapForceKey, _config.flapForce);
    await _prefs?.setDouble(_pipeGapKey, _config.pipeGap);
  }

  /// Resets all settings to defaults.
  Future<void> resetToDefaults() async {
    final defaults = PhysicsConfig(
      gravity: GameConstants.defaultGravity,
      flapForce: GameConstants.defaultFlapForce,
      pipeGap: GameConstants.defaultPipeGap,
    );
    await updateConfig(defaults);
  }
}
