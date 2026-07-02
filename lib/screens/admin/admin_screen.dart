import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/admin_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/product_image.dart';
import 'add_product_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products     = context.watch<ProductProvider>().products;
    final adminProvider= context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('Manage your store products',
            style: TextStyle(fontSize: 11, color: kTextSecond, fontWeight: FontWeight.normal)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: kRed),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(children: [
            _StatCard(label: 'Total Products', value: '${products.length}', icon: Icons.inventory_2_rounded, color: kAccent),
            const SizedBox(width: 10),
            _StatCard(label: 'Categories', value: '${products.map((p) => p.category).toSet().length}', icon: Icons.grid_view_rounded, color: kGold),
          ]),
        ),
        if (adminProvider.error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kRed.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded, size: 16, color: kRed),
              const SizedBox(width: 8),
              Expanded(child: Text(adminProvider.error!,
                style: const TextStyle(fontSize: 12, color: kRed))),
            ]),
          ),
        Expanded(
          child: products.isEmpty
              ? const _EmptyAdminState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) => _ProductAdminTile(p: products[i]),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddProductScreen())),
        backgroundColor: kGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to sign out?',
          style: TextStyle(color: kTextSecond)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kTextSecond))),
          TextButton(
            onPressed: () { Navigator.pop(ctx); AuthService.signOut(); },
            child: const Text('Sign Out', style: TextStyle(color: kRed, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _ProductAdminTile extends StatelessWidget {
  final Product p;
  const _ProductAdminTile({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(children: [
        ProductImage(product: p, size: 52, radius: 10),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextPrimary)),
          const SizedBox(height: 3),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (kCategoryColors[p.category] ?? kAccent).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(p.category,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                  color: kCategoryColors[p.category] ?? kAccent)),
            ),
            const SizedBox(width: 6),
            Text(p.stock, style: const TextStyle(fontSize: 10, color: kTextSecond)),
          ]),
          const SizedBox(height: 4),
          Text('\$${p.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: kRed, size: 22),
          onPressed: () => _confirmDelete(context),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('Delete "${p.name}"? This cannot be undone.',
          style: const TextStyle(color: kTextSecond)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kTextSecond))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminProvider>().deleteProduct(p.docId);
            },
            child: const Text('Delete', style: TextStyle(color: kRed, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kBorderColor)),
    child: Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: kTextSecond)),
      ]),
    ]),
  ));
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 56, color: kTextSecond),
      SizedBox(height: 16),
      Text('No Products Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
      SizedBox(height: 8),
      Text('Tap the + button below to add your first product',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: kTextSecond)),
    ]),
  );
}
