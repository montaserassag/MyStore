import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/database_service.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  bool _loaded = false;

  List<CartItem> get itemList  => _items.values.toList();
  int    get totalItems        => _items.values.fold(0, (s, i) => s + i.quantity);
  double get totalPrice        => _items.values.fold(0.0, (s, i) => s + i.subtotal);
  bool   get isLoaded          => _loaded;
  bool   contains(int id)      => _items.containsKey(id);
  int    getQty(int id)        => _items[id]?.quantity ?? 0;

  CartProvider() {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    final rows = await DatabaseService.instance.getAllCartItems();
    for (final row in rows) {
      final id       = row['id']       as int;
      final title    = row['title']    as String;
      final price    = row['price']    as double;
      final image    = row['image']    as String;
      final quantity = row['quantity'] as int;

      final cat = 'Others';
      final product = Product(
        id: id, name: title, category: cat,
        price: price, originalPrice: price, discount: 0,
        iconData: kCategoryIcons[cat]!,
        accent: kCategoryColors[cat]!,
        stock: '', imageUrl: image,
      );
      _items[id] = CartItem(product: product, quantity: quantity);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _upsert(CartItem ci) async {
    await DatabaseService.instance.insertOrUpdateCartItem({
      'id':       ci.product.id,
      'title':    ci.product.name,
      'price':    ci.product.price,
      'image':    ci.product.imageUrl,
      'quantity': ci.quantity,
    });
  }

  void add(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
    _upsert(_items[product.id]!);
  }

  void remove(int id) {
    _items.remove(id);
    notifyListeners();
    DatabaseService.instance.deleteCartItem(id);
  }

  void increment(int id) {
    if (_items[id] == null) return;
    _items[id]!.quantity++;
    notifyListeners();
    DatabaseService.instance.updateCartQuantity(id, _items[id]!.quantity);
  }

  void decrement(int id) {
    if (_items[id] == null) return;
    if (_items[id]!.quantity <= 1) {
      _items.remove(id);
      DatabaseService.instance.deleteCartItem(id);
    } else {
      _items[id]!.quantity--;
      DatabaseService.instance.updateCartQuantity(id, _items[id]!.quantity);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    DatabaseService.instance.clearCart();
  }
}
