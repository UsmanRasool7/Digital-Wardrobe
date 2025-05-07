import 'package:flutter/material.dart';
import '../constants/tag_options.dart';


class UserPreferencesPage extends StatefulWidget {
  const UserPreferencesPage({Key? key}) : super(key: key);

  @override
  State<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  String? _style;
  String? _mood;
  String? _occasion;
  String? _culture;

  /// Collects the responses in a map
  Map<String, String> get _responses => {
    'styleTags': _style ?? '',
    'moodTags': _mood ?? '',
    'occasionTags': _occasion ?? '',
    'culturalInfluenceTag': _culture ?? '',
  };

  bool get _isComplete {
    return _style != null && _mood != null && _occasion != null && _culture != null;
  }

  void _onSave() {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions.')),
      );
      return;
    }
    Navigator.of(context).pop(_responses);
  }

  Widget _buildDropdown({
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButton<String>(
          isExpanded: true,
          hint: Text('Select $label'),
          items: options.map((opt) => DropdownMenuItem(
            value: opt,
            child: Text(opt),
          )).toList(),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onSave,
            tooltip: 'Save preferences',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdown(
              label: 'Style',
              options: TagOptions.styleTags,
              value: _style,
              onChanged: (v) => setState(() => _style = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Mood',
              options: TagOptions.moodTags,
              value: _mood,
              onChanged: (v) => setState(() => _mood = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Occasion',
              options: TagOptions.occasionTags,
              value: _occasion,
              onChanged: (v) => setState(() => _occasion = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Culture',
              options: TagOptions.culturalInfluenceTags,
              value: _culture,
              onChanged: (v) => setState(() => _culture = v),
            ),
          ],
        ),
      ),
    );
  }
}
