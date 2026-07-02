import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_item.dart';
import '../models/product.dart';

class FirestoreException implements Exception {
  final String message;
  final String code;
  FirestoreException(this.message, this.code);
  @override String toString() => message;
}

class FirestoreService {
  FirestoreService._();
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Product>> productsStream() {
    return _db.collection('products').orderBy('createdAt', descending: true).snapshots()
        .map((snap) => snap.docs.map(Product.fromDoc).toList())
        .handleError((e) => throw FirestoreException(
          'Unable to load products.', e is FirebaseException ? e.code : 'unknown'));
  }

  static Future<void> addProduct(Map<String, dynamic> data) async {
    try {
      await _db.collection('products').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException('Could not add product.', e.code);
    }
  }

  static Future<void> deleteProduct(String docId) async {
    try {
      await _db.collection('products').doc(docId).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException('Could not delete product.', e.code);
    }
  }

  static CollectionReference<Map<String, dynamic>> _favsRef(String uid) =>
      _db.collection('users').doc(uid).collection('favorites');

  static Stream<List<FavoriteItem>> favoritesStream(String uid) {
    return _favsRef(uid).snapshots()
        .map((snap) => snap.docs.map((d) =>
            FavoriteItem.fromJson({...d.data(), 'id': int.tryParse(d.id) ?? 0})).toList())
        .handleError((e) => throw FirestoreException(
          'Unable to sync favorites.', e is FirebaseException ? e.code : 'unknown'));
  }

  static Future<void> setFavorite(String uid, FavoriteItem item) async {
    try {
      await _favsRef(uid).doc(item.id.toString()).set(item.toJson());
    } on FirebaseException catch (e) {
      throw FirestoreException('Could not save favorite.', e.code);
    }
  }

  static Future<void> removeFavorite(String uid, int id) async {
    try {
      await _favsRef(uid).doc(id.toString()).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException('Could not remove favorite.', e.code);
    }
  }
}
