import 'product.dart';

/// ─────────────────────────────────────────────────────────────────────
/// Exercise 2: FavoriteItem — "store only necessary data (id, name, price, image)"
///
/// This is intentionally smaller than [Product]: it's what gets written
/// to favorites.json so the file stays small and survives even if the
/// product catalog (from the API) changes shape later.
/// ─────────────────────────────────────────────────────────────────────
class FavoriteItem {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  const FavoriteItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory FavoriteItem.fromProduct(Product p) => FavoriteItem(
    id: p.id,
    name: p.name,
    price: p.price,
    imageUrl: p.imageUrl,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
  };

  /// ✅ Validate After Decoding — safe fallbacks for every field.
  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    final id    = json['id'];
    final name  = json['name'];
    final price = json['price'];
    final image = json['imageUrl'];

    return FavoriteItem(
      id:       id    is int    ? id    : int.tryParse('$id') ?? 0,
      name:     name  is String ? name  : '',
      price:    price is num    ? price.toDouble() : 0.0,
      imageUrl: image is String ? image : '',
    );
  }

  /// Build a minimal [Product] for display when the live catalog (from the
  /// API/cache) hasn't loaded yet — keeps Favorites usable while offline.
  Product toMinimalProduct() => Product(
    id: id,
    name: name,
    category: 'Others',
    price: price,
    originalPrice: price,
    discount: 0,
    iconData: kCategoryIcons['Others']!,
    accent: kCategoryColors['Others']!,
    stock: '',
    imageUrl: imageUrl,
  );
}
