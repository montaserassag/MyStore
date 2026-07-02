import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/deal_card.dart';
import '../widgets/trending_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(child: Builder(builder: (context) {
        if (prov.isLoading && prov.products.isEmpty) return const _LoadingView();
        if (prov.isEmpty) return const _EmptyStoreView();
        if (prov.hasError && prov.products.isEmpty) return _ErrorView(
          message: prov.errorMessage,
          onRetry: () => context.read<ProductProvider>().refresh(),
        );

        return RefreshIndicator(
          color: kAccent,
          backgroundColor: kCardColor,
          onRefresh: () async => context.read<ProductProvider>().refresh(),
          child: CustomScrollView(slivers: [
            SliverAppBar(
              floating: true, backgroundColor: kBgColor, elevation: 0,
              title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Today Deals 🔥',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Fresh picks curated for today only',
                  style: TextStyle(fontSize: 11, color: kTextSecond, fontWeight: FontWeight.normal)),
              ]),
            ),

            if (prov.isOffline)
              const SliverToBoxAdapter(child: _OfflineBanner()),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(color: kCardColor,
                    borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorderColor)),
                  child: const TextField(
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: kTextSecond, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: kTextSecond, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
            ),

            if (prov.deals.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 275,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: prov.deals.length,
                    itemBuilder: (_, i) => DealCard(p: prov.deals[i]),
                  ),
                ),
              ),

            if (prov.trending.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, 18, 14, 10),
                  child: Text('Trending 📈',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => TrendingTile(p: prov.trending[i]),
                  childCount: prov.trending.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ]),
        );
      })),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircularProgressIndicator(color: kAccent),
      SizedBox(height: 16),
      Text('Loading products...', style: TextStyle(fontSize: 13, color: kTextSecond)),
    ]),
  );
}

class _EmptyStoreView extends StatelessWidget {
  const _EmptyStoreView();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.storefront_outlined, size: 64, color: kTextSecond),
      SizedBox(height: 16),
      Text('Store is Empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
      SizedBox(height: 8),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'No products have been added yet.\nCheck back soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: kTextSecond, height: 1.5),
        ),
      ),
    ]),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.cloud_off_rounded, size: 56, color: kTextSecond),
        const SizedBox(height: 16),
        const Text("Couldn't load products",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: kTextSecond)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kGold, foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      ]),
    ),
  );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFF9800).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.4)),
    ),
    child: const Row(children: [
      Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFFFF9800)),
      SizedBox(width: 10),
      Expanded(child: Text('Offline mode — showing last saved products',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFFB74D)))),
    ]),
  );
}
