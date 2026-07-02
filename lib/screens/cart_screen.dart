import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart  = context.watch<CartProvider>();
    final items = cart.itemList;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Shopping Cart',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('${cart.totalItems} item${cart.totalItems != 1 ? "s" : ""} in cart',
            style: const TextStyle(fontSize: 11, color: kTextSecond, fontWeight: FontWeight.normal)),
        ]),
      ),
      body: items.isEmpty
          ? const Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('🛒', style: TextStyle(fontSize: 56)),
                SizedBox(height: 12),
                Text('Cart is Empty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text('Add products from the home screen to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: kTextSecond)),
                ),
              ]),
            )
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _CartItemTile(item: items[i]),
                ),
              ),
              _TotalSection(cart: cart),
            ]),
    );
  }
}

// ── Cart Item Tile ──────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(children: [
        ProductImage(product: p, size: 52, radius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextPrimary)),
            const SizedBox(height: 2),
            Text('${p.category} · Series: ${p.id}',
              style: const TextStyle(fontSize: 10, color: kTextSecond)),
            const SizedBox(height: 4),
            Text('\$${item.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          // Delete button
          GestureDetector(
            onTap: () => context.read<CartProvider>().remove(p.id),
            child: Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          // Qty controls
          Row(children: [
            _QtyBtn(
              onTap: () => context.read<CartProvider>().decrement(p.id),
              icon: Icons.remove, bg: kBorderColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('${item.quantity}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            _QtyBtn(
              onTap: () => context.read<CartProvider>().increment(p.id),
              icon: Icons.add, bg: kGold, iconColor: Colors.black,
            ),
          ]),
        ]),
      ]),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  const _QtyBtn({required this.onTap, required this.icon, required this.bg, this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: iconColor),
    ),
  );
}

// ── Total Section ───────────────────────────────────────────────────────────
class _TotalSection extends StatelessWidget {
  final CartProvider cart;
  const _TotalSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(children: [
        _Row('Subtotal (${cart.totalItems} items)', '\$${cart.totalPrice.toStringAsFixed(2)}', kTextPrimary),
        const SizedBox(height: 8),
        _Row('Shipping', 'FREE ✈️', kGreen),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: kBorderColor, height: 1),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('\$${cart.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kGold)),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showCheckoutDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGold, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            child: const Text('Checkout →'),
          ),
        ),
      ]),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Order Placed! 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('Your order is on its way! Thank you for shopping with us.',
          style: TextStyle(color: kTextSecond)),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); cart.clear(); },
            child: const Text('OK', style: TextStyle(color: kGold, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  const _Row(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: kTextSecond)),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor)),
    ],
  );
}
