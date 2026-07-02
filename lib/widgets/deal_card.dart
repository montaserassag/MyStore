import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../screens/product_detail_screen.dart';
import 'product_image.dart';

class DealCard extends StatelessWidget {
  final Product p;
  const DealCard({super.key, required this.p});

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
        width: 162,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: kCardColor, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderColor),
        ),
        padding: const EdgeInsets.all(11),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Badge + Heart
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _Badge(disc: p.discount),
            GestureDetector(
              onTap: () => context.read<FavoritesProvider>().toggle(p),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: isFav ? const Color(0xFF3D1515) : kBorderColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 14, color: isFav ? kRed : kTextSecond,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          // Product Image
          Center(child: ProductImage(product: p, size: 70, radius: 14)),
          const SizedBox(height: 8),
          Text(p.category,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: catClr)),
          const SizedBox(height: 2),
          Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: kTextPrimary, height: 1.3)),
          const SizedBox(height: 3),
          Text('⏰ ${p.stock}',
            style: const TextStyle(fontSize: 10, color: Color(0xFFFF7878))),
          const SizedBox(height: 4),
          Row(children: [
            Text('\$${p.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(width: 5),
            Text('\$${p.originalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 10, color: kTextSecond,
                decoration: TextDecoration.lineThrough)),
          ]),
          const SizedBox(height: 8),
          // FIX 1: tapTargetSize.shrinkWrap prevents overflow
          SizedBox(
            width: double.infinity,
            child: inCart
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1E0C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kGreen),
                    ),
                    child: Text('✓ In Cart (${cart.getQty(p.id)})',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
                  )
                : ElevatedButton(
                    onPressed: () => context.read<CartProvider>().add(p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      // ✅ FIX OVERFLOW: remove default 48px min tap height
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
  }
}

class _Badge extends StatelessWidget {
  final int disc;
  const _Badge({required this.disc});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: disc >= 40 ? kRed : const Color(0xFFD4880A),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text('-$disc%',
      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
  );
}
