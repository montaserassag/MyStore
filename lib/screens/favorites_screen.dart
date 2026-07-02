import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_image.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs     = context.watch<FavoritesProvider>();
    final cart     = context.watch<CartProvider>();
    final products = context.watch<ProductProvider>().products;
    final favProds = favs.getFavorites(products);

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor, elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Favorites ❤️',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('${favs.count} saved item${favs.count != 1 ? "s" : ""}',
            style: const TextStyle(fontSize: 11, color: kTextSecond, fontWeight: FontWeight.normal)),
        ]),
      ),
      body: favProds.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('🤍', style: TextStyle(fontSize: 56)),
              SizedBox(height: 12),
              Text('No Favorites Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text('Tap ❤️ on any product to save it here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kTextSecond)),
              ),
            ]))
          : GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10,
                mainAxisSpacing: 10, childAspectRatio: 0.72,
              ),
              itemCount: favProds.length,
              itemBuilder: (ctx, i) {
                final p = favProds[i];
                final inCart = cart.contains(p.id);
                final catClr = kCategoryColors[p.category] ?? kAccent;

                return GestureDetector(
                  onTap: () => Navigator.push(ctx,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(p: p))),
                  child: Container(
                    decoration: BoxDecoration(color: kCardColor,
                      borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorderColor)),
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: p.discount >= 40 ? kRed : const Color(0xFFD4880A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('-${p.discount}%',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                        GestureDetector(
                          onTap: () => context.read<FavoritesProvider>().toggle(p),
                          child: const Icon(Icons.favorite_rounded, size: 18, color: kRed)),
                      ]),
                      const SizedBox(height: 10),
                      Center(child: ProductImage(product: p, size: 64, radius: 12)),
                      const SizedBox(height: 8),
                      Text(p.category,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: catClr)),
                      const SizedBox(height: 2),
                      Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          color: kTextPrimary, height: 1.3)),
                      const Spacer(),
                      Row(children: [
                        Text('\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(width: 4),
                        Text('\$${p.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 10, color: kTextSecond,
                            decoration: TextDecoration.lineThrough)),
                      ]),
                      const SizedBox(height: 8),
                      SizedBox(width: double.infinity,
                        child: inCart
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFF0C1E0C),
                                  borderRadius: BorderRadius.circular(8), border: Border.all(color: kGreen)),
                                child: Text('✓ In Cart (${cart.getQty(p.id)})',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)))
                            : ElevatedButton(
                                onPressed: () => context.read<CartProvider>().add(p),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kGold, foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                                child: const Text('Add to Cart'),
                              ),
                      ),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
