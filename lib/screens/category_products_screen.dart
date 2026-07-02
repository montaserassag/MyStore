import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/trending_tile.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final Color  categoryColor;
  const CategoryProductsScreen({
    super.key, required this.categoryName, required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products.where((p) => p.category == categoryName).toList();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: categoryColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(categoryName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${products.length} items',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: categoryColor)),
            ),
          ),
        ],
      ),
      body: productProvider.isLoading && products.isEmpty
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : products.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.search_off_rounded, size: 56, color: kTextSecond),
                const SizedBox(height: 12),
                const Text('No Products Found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text('No products in $categoryName yet',
                  style: const TextStyle(fontSize: 13, color: kTextSecond)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: products.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => Navigator.push(ctx,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(p: products[i]))),
                child: TrendingTile(p: products[i]),
              ),
            ),
    );
  }
}
