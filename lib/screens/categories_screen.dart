import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'category_products_screen.dart';

class AppCategory {
  final String name;
  final IconData icon;
  final Color color;
  const AppCategory({required this.name, required this.icon, required this.color});
}

const kCategories = [
  AppCategory(name: 'Electronics', icon: Icons.electrical_services, color: Color(0xFF00BCD4)),
  AppCategory(name: 'Fashion',     icon: Icons.checkroom,            color: Color(0xFFE91E63)),
  AppCategory(name: 'Sports',      icon: Icons.sports,               color: Color(0xFF4CAF50)),
  AppCategory(name: 'Perfumes',    icon: Icons.spa,                  color: Color(0xFF9C27B0)),
  AppCategory(name: 'Backset',     icon: Icons.backpack,             color: Color(0xFFFF9800)),
  AppCategory(name: 'Others',      icon: Icons.category,             color: Color(0xFF607D8B)),
];

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor, elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const Text('Choose a category to browse products',
            style: TextStyle(fontSize: 11, color: kTextSecond, fontWeight: FontWeight.normal)),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10,
            mainAxisSpacing: 10, childAspectRatio: 1.05,
          ),
          itemCount: kCategories.length,
          itemBuilder: (ctx, i) {
            final cat   = kCategories[i];
            final count = products.where((p) => p.category == cat.name).length;

            return GestureDetector(
              // FIX: navigate to filtered products screen
              onTap: () => Navigator.push(ctx, MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(
                  categoryName: cat.name, categoryColor: cat.color,
                ),
              )),
              child: Container(
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cat.color.withValues(alpha: 0.22)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(cat.icon, size: 28, color: cat.color),
                  ),
                  const SizedBox(height: 10),
                  Text(cat.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('$count items',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cat.color)),
                  const SizedBox(height: 4),
                  // Arrow indicator
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Browse', style: TextStyle(fontSize: 10, color: cat.color.withValues(alpha: 0.7))),
                    Icon(Icons.arrow_forward_ios_rounded, size: 9, color: cat.color.withValues(alpha: 0.7)),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
