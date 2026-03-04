import 'package:flutter/material.dart';
import '../game/physics_config.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;

  const SettingsScreen({super.key, required this.settingsService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late PhysicsConfig _tempConfig;

  @override
  void initState() {
    super.initState();
    _tempConfig = widget.settingsService.config.copyWith();
  }

  void _save() {
    widget.settingsService.updateConfig(_tempConfig);
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      widget.settingsService.resetToDefaults();
      _tempConfig = widget.settingsService.config.copyWith();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Physics Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSlider(
            label: 'Gravity',
            value: _tempConfig.gravity,
            min: 400,
            max: 2500,
            divisions: 210, // (2500 - 400) / 10
            onChanged: (v) => setState(() => _tempConfig.gravity = v),
          ),
          _buildSlider(
            label: 'Flap Force',
            value: _tempConfig.flapForce,
            min: -800,
            max: -200,
            divisions: 60, // (-200 - -800) / 10
            onChanged: (v) => setState(() => _tempConfig.flapForce = v),
          ),
          _buildSlider(
            label: 'Pipe Gap',
            value: _tempConfig.pipeGap,
            min: 80,
            max: 300,
            divisions: 22, // (300 - 80) / 10
            onChanged: (v) => setState(() => _tempConfig.pipeGap = v),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save & Apply', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.purpleAccent),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(1),
          activeColor: Colors.purpleAccent,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
