import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product p;
  const ProductDetailScreen({super.key, required this.p});

  String get _description {
    switch (p.category) {
      case 'Electronics':
        return 'Premium ${p.name} featuring cutting-edge technology and exceptional performance. Designed for modern lifestyles with long-lasting battery life and smart connectivity.';
      case 'Fashion':
        return 'Elegant ${p.name} crafted with high-quality materials. A perfect blend of style and functionality designed for the fashion-forward individual.';
      case 'Sports':
        return 'Professional-grade ${p.name} engineered for peak athletic performance. Lightweight, durable, and built to exceed your training expectations.';
      case 'Perfumes':
        return 'Luxurious ${p.name} — a unique fragrance that lasts all day. A sophisticated blend of premium ingredients for the discerning nose.';
      default:
        return 'High-quality ${p.name} designed to meet your everyday needs. Exceptional quality at an unbeatable price — limited stock available.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final favs   = context.watch<FavoritesProvider>();
    final inCart = cart.contains(p.id);
    final isFav  = favs.isFav(p.id);
    final catClr = kCategoryColors[p.category] ?? kAccent;

    return Scaffold(
      backgroundColor: kBgColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: kBgColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              // Favorite Button in AppBar
              GestureDetector(
                onTap: () => context.read<FavoritesProvider>().toggle(p),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: isFav ? const Color(0xFF3D1515) : Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? kRed : Colors.white, size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [p.accent.withValues(alpha: 0.25), kBgColor],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 40),
                  // Discount badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.discount >= 40 ? kRed : const Color(0xFFD4880A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('-${p.discount}% OFF',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 16),
                  // Product image (large)
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: p.accent.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: ProductImage(product: p, size: 120, radius: 24),
                  ),
                ]),
              ),
            ),
          ),

          // ── Product Details ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Category + Stock Row
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: catClr.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: catClr.withValues(alpha: 0.3)),
                    ),
                    child: Text(p.category,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: catClr)),
                  ),
                  Row(children: [
                    Icon(Icons.inventory_2_outlined, size: 14, color: p.stock == '5 left' ? kRed : kTextSecond),
                    const SizedBox(width: 4),
                    Text('⏰ ${p.stock}',
                      style: TextStyle(fontSize: 12, color: p.stock == '5 left' ? kRed : const Color(0xFFFF7878),
                        fontWeight: FontWeight.w600)),
                  ]),
                ]),
                const SizedBox(height: 12),

                // Product Name
                Text(p.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                const SizedBox(height: 16),

                // Price Section
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kCardColor, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Price', style: TextStyle(fontSize: 11, color: kTextSecond)),
                      const SizedBox(height: 4),
                      Text('\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                    ]),
                    const Spacer(),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('\$${p.originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, color: kTextSecond,
                          decoration: TextDecoration.lineThrough)),
                      const SizedBox(height: 4),
                      Text('Save \$${(p.originalPrice - p.price).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF4CAF50), fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),

                // Rating (simulated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: kCardColor, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: Row(children: [
                    ...List.generate(5, (i) => Icon(
                      i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                      color: kGold, size: 18)),
                    const SizedBox(width: 8),
                    const Text('4.5', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(width: 6),
                    const Text('(128 reviews)', style: TextStyle(fontSize: 12, color: kTextSecond)),
                  ]),
                ),
                const SizedBox(height: 16),

                // Description
                const Text('Description',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text(_description,
                  style: const TextStyle(fontSize: 13, color: kTextSecond, height: 1.6)),
                const SizedBox(height: 24),

                // Action Buttons
                Row(children: [
                  // Favorite Button
                  GestureDetector(
                    onTap: () => context.read<FavoritesProvider>().toggle(p),
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: isFav ? const Color(0xFF3D1515) : kCardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isFav ? kRed : kBorderColor),
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? kRed : kTextSecond, size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add to Cart Button
                  Expanded(
                    child: inCart
                        ? Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C1E0C),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF4CAF50)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              GestureDetector(
                                onTap: () => context.read<CartProvider>().decrement(p.id),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(color: kBorderColor, shape: BoxShape.circle),
                                  child: const Icon(Icons.remove, size: 14, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text('${cart.getQty(p.id)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                              GestureDetector(
                                onTap: () => context.read<CartProvider>().add(p),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(color: kGold, shape: BoxShape.circle),
                                  child: const Icon(Icons.add, size: 14, color: Colors.black),
                                ),
                              ),
                            ]),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => context.read<CartProvider>().add(p),
                            icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                            label: const Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGold, foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                  ),
                ]),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
