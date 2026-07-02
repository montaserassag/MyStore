import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../screens/product_detail_screen.dart';
import 'product_image.dart';

class TrendingTile extends StatelessWidget {
  final Product p;
  const TrendingTile({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final favs   = context.watch<FavoritesProvider>();
    final inCart = cart.contains(p.id);
    final isFav  = favs.isFav(p.id);
    final catClr = kCategoryColors[p.category] ?? kAccent;

    return GestureDetector(
      // FIX: tap → ProductDetailScreen
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(p: p))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCardColor, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(children: [
          // Product image
          ProductImage(product: p, size: 54, radius: 12),
          const SizedBox(width: 12),
          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: catClr)),
            const SizedBox(height: 2),
            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextPrimary)),
            const SizedBox(height: 4),
            Row(children: [
              Text('\$${p.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(width: 6),
              Text('\$${p.originalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 10, color: kTextSecond,
                  decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: p.discount >= 40 ? kRed : const Color(0xFFD4880A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('-${p.discount}%',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ]),
          ])),
          // Actions
          Column(children: [
            GestureDetector(
              onTap: () => context.read<FavoritesProvider>().toggle(p),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: isFav ? const Color(0xFF3D1515) : kBorderColor, shape: BoxShape.circle),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 15, color: isFav ? kRed : kTextSecond,
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => context.read<CartProvider>().add(p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: inCart ? const Color(0xFF0C1E0C) : kGold,
                  borderRadius: BorderRadius.circular(8),
                  border: inCart ? Border.all(color: kGreen) : null,
                ),
                child: Text(inCart ? '✓ ${cart.getQty(p.id)}' : '+ Cart',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w800,
                    color: inCart ? kGreen : Colors.black)),
              ),
            ),
          ]),
          // Chevron hint
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, size: 18, color: kTextSecond),
        ]),
      ),
    );
  }
}
