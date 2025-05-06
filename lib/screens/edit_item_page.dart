// lib/pages/edit_item_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clothing_item_model.dart';
import '../constants/tag_options.dart';
import '../repositories/clothing_item_repository.dart';

class EditItemPage extends StatefulWidget {
  final ClothingItemModel clothingItem;

  const EditItemPage({super.key, required this.clothingItem});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final ImagePicker _picker = ImagePicker();
  final ClothingItemRepository _repo = ClothingItemRepository();

  late File selectedImage;
  late TextEditingController _priceController;
  late String? _selectedStyleTag;
  late String? _selectedMoodTag;
  late String? _selectedOccasionTag;
  late String? _selectedColorTag;
  late String? _selectedFitTag;
  late String? _selectedWeatherTypeTag;
  late String? _selectedCulturalTag;
  late WearType? _selectedWearTypeTag;

  @override
  void initState() {
    super.initState();
    selectedImage = File(widget.clothingItem.imageUrl);
    _priceController = TextEditingController(
      text: widget.clothingItem.priceTag?.toStringAsFixed(2) ?? '',
    );
    _selectedStyleTag = widget.clothingItem.styleTag;
    _selectedMoodTag = widget.clothingItem.moodTag;
    _selectedOccasionTag = widget.clothingItem.occasionTag;
    _selectedColorTag = widget.clothingItem.colorTag;
    _selectedFitTag = widget.clothingItem.fitTag;
    _selectedWeatherTypeTag = widget.clothingItem.weatherTypeTag;
    _selectedCulturalTag = widget.clothingItem.culturalInfluenceTag;
    _selectedWearTypeTag = widget.clothingItem.wearTypeTag;
  }

  Future<void> _pickImage(ImageSource src) async {
    final picked = await _picker.pickImage(source: src);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  bool _validateForm() {
    if (_priceController.text.isEmpty ||
        double.tryParse(_priceController.text) == null) {
      _showError('Please enter a valid Price.');
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
    if (_selectedColorTag == null) {
      _showError('Please select a Color tag.');
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveAndReturn() async {
    if (!_validateForm()) return;

    final updatedItem = widget.clothingItem.copyWith(
      imageUrl: selectedImage.path,
      priceTag: double.parse(_priceController.text),
      styleTag: _selectedStyleTag!,
      moodTag: _selectedMoodTag!,
      occasionTag: _selectedOccasionTag!,
      colorTag: _selectedColorTag!,
      fitTag: _selectedFitTag!,
      weatherTypeTag: _selectedWeatherTypeTag!,
      culturalInfluenceTag: _selectedCulturalTag!,
      wearTypeTag: _selectedWearTypeTag!,
    );

    try {
      await _repo.updateClothingItem(updatedItem);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully!')),
      );
      Navigator.of(context).pop(updatedItem);
    } catch (e) {
      _showError('Update failed: $e');
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
          items: options.map((opt) => DropdownMenuItem(
            value: opt,
            child: Text(labelBuilder?.call(opt) ?? opt.toString()),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndReturn,
            tooltip: 'Save Changes',
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
                child: Image.file(selectedImage, fit: BoxFit.contain),
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
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ],
            ),
            const Divider(height: 32),
            // Required dropdowns and fields
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
            Text('Price *', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Enter price'),
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              label: 'Color Tag',
              options: TagOptions.colorTags,
              value: _selectedColorTag,
              onChanged: (v) => setState(() => _selectedColorTag = v),
            ),
            const SizedBox(height: 16),
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
