import 'package:flutter/material.dart';
import '../models/outfit_history_table.dart';
import '../repositories/outfit_history_repository.dart';

class OutfitHistoryController with ChangeNotifier {
  final OutfitHistoryRepository _repository = OutfitHistoryRepository();

  List<OutfitHistory> _history = [];
  List<OutfitHistory> get history => _history;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUserOutfits(String userId) async {
    _isLoading = true;
    notifyListeners();

    _history = await _repository.getUserOutfitHistory(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOutfit(OutfitHistory outfit) async {
    await _repository.addOutfitHistory(outfit);
    await fetchUserOutfits(outfit.userId); // Refresh after adding
  }

  Future<void> deleteOutfit(String docId, String userId) async {
    await _repository.deleteOutfitHistory(docId);
    await fetchUserOutfits(userId);
  }
}
