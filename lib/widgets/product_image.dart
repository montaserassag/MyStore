import 'package:flutter/material.dart';
import '../models/product.dart';

/// Shared product image widget.
///
/// Renders the product's [Product.imageUrl] (from the API/cache) with a
/// loading spinner while it downloads, and falls back to the category
/// icon if there's no image URL or the image fails to load.
class ProductImage extends StatelessWidget {
  final Product product;
  final double size;
  final double radius;

  const ProductImage({
    super.key,
    required this.product,
    required this.size,
    this.radius = 14,
  });

  Widget _iconFallback() => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      color: product.accent.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Icon(product.iconData, size: size * 0.48, color: product.accent),
  );

  @override
  Widget build(BuildContext context) {
    if (product.imageUrl.isEmpty) return _iconFallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        product.imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size, height: size,
            color: kCardColor,
            alignment: Alignment.center,
            child: SizedBox(
              width: size * 0.32, height: size * 0.32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: product.accent,
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stack) => _iconFallback(),
      ),
    );
  }
}
