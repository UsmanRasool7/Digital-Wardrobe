// lib/pages/add_item_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/clothing_item_model.dart';
import '../constants/tag_options.dart';
import '../repositories/clothing_item_repository.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final ImagePicker _picker = ImagePicker();
  final ClothingItemRepository _repo = ClothingItemRepository();

  File? selectedImage;
  bool _removeBg = true; // Toggle for background removal

  // --- tag state ---
  final TextEditingController _priceController = TextEditingController();
  String? _selectedStyleTag;
  String? _selectedMoodTag;
  String? _selectedOccasionTag;
  String? _selectedColorTag;
  String? _selectedFitTag;
  String? _selectedWeatherTypeTag;
  String? _selectedCulturalTag;
  WearType? _selectedWearTypeTag;

  // --- Background removal (your Flask service) ---
  Future<File?> _removeBackground(File imageFile) async {
    final url = Uri.parse('http://10.0.2.2:5000/remove-bg');
    final req = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final resp = await req.send();
    if (resp.statusCode == 200) {
      final bytes = await resp.stream.toBytes();
      //final tmp = await Directory.systemTemp.createTemp();
      //final out = File('${tmp.path}/${DateTime.now().millisecondsSinceEpoch}.png');
      // get a persistent directory in the app sandbox
      final docsDir = await getApplicationDocumentsDirectory();
      final itemsDir = Directory('${docsDir.path}/items');
      if (!await itemsDir.exists()) {
        await itemsDir.create(recursive: true);
      }
      final filename = '${DateTime.now().millisecondsSinceEpoch}.png';
      final out = File('${itemsDir.path}/$filename');
      await out.writeAsBytes(bytes);
      return out;
    } else {
      debugPrint('Background removal failed: ${resp.statusCode}');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    if (selectedImage != null) {
      _showError('Only one image allowed.');
      return;
    }
    final picked = await _picker.pickImage(source: src);
    if (picked != null) {
      File? finalImage = File(picked.path);
      if (_removeBg) {
        try {
          final cleaned = await _removeBackground(finalImage);
          if (cleaned != null) {
            finalImage = cleaned;
          } else {
            _showError('Background removal failed. Uploading original image.');
          }
        } catch (e) {
          _showError(
              'Background removal API unreachable. Uploading original image.');
        }
      }
      if (mounted) {
        setState(() => selectedImage = finalImage);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return; // Ensure the widget is still mounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateForm() {
    if (selectedImage == null) {
      _showError('Please select an image.');
      return false;
    }
    if (_selectedStyleTag == null) {
      _showError('Please select a Style tag.');
      return false;
    }
    if (_selectedMoodTag == null) {
      _showError('Please select a Mood tag.');
      return false;
    }
    if (_selectedOccasionTag == null) {
      _showError('Please select an Occasion tag.');
      return false;
    }
    if (_priceController.text.isEmpty ||
        double.tryParse(_priceController.text) == null) {
      _showError('Please enter a valid Price.');
      return false;
    }
    if (_selectedFitTag == null) {
      _showError('Please select a Fit tag.');
      return false;
    }
    if (_selectedWeatherTypeTag == null) {
      _showError('Please select a Weather Type tag.');
      return false;
    }
    if (_selectedCulturalTag == null) {
      _showError('Please select a Cultural Influence tag.');
      return false;
    }
    if (_selectedWearTypeTag == null) {
      _showError('Please select a Wear Type tag.');
      return false;
    }
    return true;
  }

  Future<void> _saveAndReturn() async {
    if (!_validateForm()) return;

    final user = FirebaseAuth.instance.currentUser!;
    final item = ClothingItemModel(
      id: const Uuid().v4(),
      userId: user.uid,
      imageUrl: selectedImage!.path,
      category: 'Uncategorized',
      color: _selectedColorTag,
      tag: null,
      uploadDate: DateTime.now(),
      styleTag: _selectedStyleTag!,
      moodTag: _selectedMoodTag!,
      priceTag: double.parse(_priceController.text),
      occasionTag: _selectedOccasionTag!,
      colorTag: _selectedColorTag,
      fitTag: _selectedFitTag!,
      weatherTypeTag: _selectedWeatherTypeTag!,
      culturalInfluenceTag: _selectedCulturalTag!,
      wearTypeTag: _selectedWearTypeTag!,
    );

    try {
      await _repo.addClothingItem(item);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item saved successfully!')),
      );
      Navigator.of(context).pop(item);
    } catch (e) {
      _showError('Save failed: $e');
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> options,
    required T? value,
    required void Function(T?) onChanged,
    String Function(T)? labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        DropdownButton<T>(
          isExpanded: true,
          hint: Text('Select $label'),
          value: value,
          items: options.map((opt) {
            final text = labelBuilder?.call(opt) ?? opt.toString();
            return DropdownMenuItem(value: opt, child: Text(text));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips(
      String label, List<String> options, List<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSel = selected.contains(opt);
            return ChoiceChip(
              label: Text(opt),
              selected: isSel,
              onSelected: (on) {
                setState(() {
                  if (on) {
                    selected.add(opt);
                  } else {
                    selected.remove(opt);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndReturn,
            tooltip: 'Save (all fields required)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            SizedBox(
              height: 200,
              child: Center(
                child: selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.contain)
                    : const Text('No image selected *'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                ),
              ],
            ),

            const Divider(height: 32),

            // Toggle for background removal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remove Background',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _removeBg,
                  onChanged: (value) => setState(() => _removeBg = value),
                ),
              ],
            ),

            const Divider(height: 32),

            // Required dropdowns
            _buildDropdown<String>(
              label: 'Style Tag',
              options: TagOptions.styleTags,
              value: _selectedStyleTag,
              onChanged: (v) => setState(() => _selectedStyleTag = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Mood Tag',
              options: TagOptions.moodTags,
              value: _selectedMoodTag,
              onChanged: (v) => setState(() => _selectedMoodTag = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Occasion Tag',
              options: TagOptions.occasionTags,
              value: _selectedOccasionTag,
              onChanged: (v) => setState(() => _selectedOccasionTag = v),
            ),

            const SizedBox(height: 16),
            // Price
            Text('Price *',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Enter price'),
            ),

            const SizedBox(height: 16),
            // Color dropdown
            _buildDropdown<String>(
              label: 'Color Tag',
              options: TagOptions.colorTags,
              value: _selectedColorTag,
              onChanged: (v) => setState(() => _selectedColorTag = v),
            ),

            const SizedBox(height: 16),
            // Remaining single‑selects
            _buildDropdown<String>(
              label: 'Fit Tag',
              options: TagOptions.fitTags,
              value: _selectedFitTag,
              onChanged: (v) => setState(() => _selectedFitTag = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Weather Type',
              options: TagOptions.weatherTypeTags,
              value: _selectedWeatherTypeTag,
              onChanged: (v) => setState(() => _selectedWeatherTypeTag = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Cultural Influence',
              options: TagOptions.culturalInfluenceTags,
              value: _selectedCulturalTag,
              onChanged: (v) => setState(() => _selectedCulturalTag = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown<WearType>(
              label: 'Wear Type',
              options: WearType.values,
              value: _selectedWearTypeTag,
              onChanged: (v) => setState(() => _selectedWearTypeTag = v),
              labelBuilder: (wt) => wt.name,
            ),
          ],
        ),
      ),
    );
  }
}
