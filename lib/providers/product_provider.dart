import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

enum ProductStatus { initial, loading, loaded, empty, offline, error }

const _cacheFile = 'products_cache.json';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  ProductStatus _status   = ProductStatus.initial;
  String _errorMessage    = '';
  StreamSubscription<List<Product>>? _sub;

  List<Product> get products     => _products;
  List<Product> get deals        => _products.take(4).toList();
  List<Product> get trending     => _products.length > 4 ? _products.sublist(4) : [];
  ProductStatus get status       => _status;
  bool   get isLoading           => _status == ProductStatus.loading;
  bool   get isOffline           => _status == ProductStatus.offline;
  bool   get isEmpty             => _status == ProductStatus.empty;
  bool   get hasError            => _status == ProductStatus.error;
  String get errorMessage        => _errorMessage;

  ProductProvider() {
    _listenToFirestore();
  }

  void _listenToFirestore() {
    _status = ProductStatus.loading;
    notifyListeners();
    _sub?.cancel();
    _sub = FirestoreService.productsStream().listen(
      (products) {
        _products     = products;
        _status       = products.isEmpty ? ProductStatus.empty : ProductStatus.loaded;
        _errorMessage = '';
        notifyListeners();
        if (products.isNotEmpty) {
          StorageService.writeJson(_cacheFile,
              products.map((p) => {...p.toFirestoreMap(), 'id': p.id, 'docId': p.docId}).toList());
        }
      },
      onError: (_) => _loadFromCache(),
    );
  }

  Future<void> _loadFromCache() async {
    final cached = await StorageService.readJson(_cacheFile);
    if (cached is List && cached.isNotEmpty) {
      _products = cached.whereType<Map<String, dynamic>>().map((j) {
        final cat = j['category'] is String ? j['category'] as String : 'Others';
        return Product(
          docId: j['docId'] is String ? j['docId'] as String : '',
          id:    j['id']    is num    ? (j['id']    as num).toInt() : 0,
          name:  j['name']  is String ? j['name']   as String : 'Product',
          category: cat,
          price:    j['price']         is num ? (j['price']         as num).toDouble() : 0.0,
          originalPrice: j['originalPrice'] is num ? (j['originalPrice'] as num).toDouble() : 0.0,
          discount: j['discount']       is num ? (j['discount']       as num).toInt() : 0,
          iconData: kCategoryIcons[cat] ?? Icons.shopping_bag_rounded,
          accent:   kCategoryColors[cat] ?? kAccent,
          stock:    '${j['stock'] is num ? (j['stock'] as num).toInt() : 0} left',
          imageUrl: j['imageUrl'] is String ? j['imageUrl'] as String : '',
        );
      }).toList();
      _status = ProductStatus.offline;
    } else {
      _products = [];
      _status   = ProductStatus.error;
      _errorMessage = 'Unable to connect. No saved products available.';
    }
    notifyListeners();
  }

  void refresh() => _listenToFirestore();

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
