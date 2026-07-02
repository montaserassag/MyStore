import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import '../models/favorite_item.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

const _guestFile = 'favorites.json';

// ✅ Exercise 3: users/{userId}/favorites — each user has their own data.
// ✅ Uses set() / snapshots() / delete() as required.
// ✅ On app start favorites are automatically loaded (auth state listener).
// ✅ Guests fall back to local JSON file — gracefully.
class FavoritesProvider extends ChangeNotifier {
  final Map<int, FavoriteItem> _items = {};
  bool   _isLoaded = false;
  String? _error;
  String? _userId;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<FavoriteItem>>? _favSub;

  int  get count    => _items.length;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  bool isFav(int id) => _items.containsKey(id);

  FavoritesProvider() {
    // ✅ React to auth state changes — load/clear favorites automatically.
    _authSub = AuthService.authStateChanges.listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) {
    _favSub?.cancel();
    _items.clear();
    _isLoaded = false;
    _userId = user?.uid;

    if (_userId == null) { _loadGuestFavorites(); return; }

    // ✅ Exercise 3: snapshots() — real-time sync per user
    _favSub = FirestoreService.favoritesStream(_userId!).listen(
      (favs) {
        _items.clear();
        for (final f in favs) _items[f.id] = f;
        _isLoaded = true; _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoaded = true;
        _error = e is FirestoreException ? e.message : 'Unable to sync favorites.';
        notifyListeners();
      },
    );
  }

  Future<void> _loadGuestFavorites() async {
    final data = await StorageService.readJson(_guestFile);
    if (data is List) {
      for (final entry in data) {
        if (entry is Map<String, dynamic>) {
          final item = FavoriteItem.fromJson(entry);
          if (item.id != 0) _items[item.id] = item;
        }
      }
    }
    _isLoaded = true; _error = null;
    notifyListeners();
  }

  Future<void> _saveGuestFavorites() => StorageService.writeJson(
      _guestFile, _items.values.map((f) => f.toJson()).toList());

  Future<void> toggle(Product product) async {
    final id      = product.id;
    final wasFav  = _items.containsKey(id);

    if (_userId != null) {
      try {
        if (wasFav) {
          await FirestoreService.removeFavorite(_userId!, id);
        } else {
          // ✅ set() — Exercise 3 operation
          await FirestoreService.setFavorite(_userId!, FavoriteItem.fromProduct(product));
        }
        // snapshots() listener updates _items automatically
      } on FirestoreException catch (e) {
        _error = e.message; notifyListeners();
      }
      return;
    }

    // Guest
    wasFav ? _items.remove(id) : _items[id] = FavoriteItem.fromProduct(product);
    notifyListeners();
    await _saveGuestFavorites();
  }

  List<Product> getFavorites(List<Product> all) {
    final byId = {for (final p in all) p.id: p};
    return _items.values.map((f) => byId[f.id] ?? f.toMinimalProduct()).toList();
  }

  @override
  void dispose() { _authSub?.cancel(); _favSub?.cancel(); super.dispose(); }
}
