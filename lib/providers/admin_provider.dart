import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class AdminProvider extends ChangeNotifier {
  bool   _isLoading = false;
  String? _error;

  bool    get isLoading => _isLoading;
  String? get error     => _error;

  Future<bool> addProduct(Map<String, dynamic> data) async {
    _isLoading = true; _error = null;
    notifyListeners();
    try {
      await FirestoreService.addProduct(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirestoreException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String docId) async {
    _error = null;
    try {
      await FirestoreService.deleteProduct(docId);
      return true;
    } on FirestoreException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
