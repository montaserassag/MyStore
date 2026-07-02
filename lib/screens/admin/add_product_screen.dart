import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/admin_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _origCtrl     = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _imageCtrl    = TextEditingController();
  final _stockCtrl    = TextEditingController();

  String _selectedCategory = 'Electronics';

  static const _categories = ['Electronics','Fashion','Sports','Perfumes','Backset','Others'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose(); _origCtrl.dispose();
    _discountCtrl.dispose(); _imageCtrl.dispose(); _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name':          _nameCtrl.text.trim(),
      'category':      _selectedCategory,
      'price':         double.parse(_priceCtrl.text.trim()),
      'originalPrice': _origCtrl.text.trim().isEmpty
          ? double.parse(_priceCtrl.text.trim())
          : double.parse(_origCtrl.text.trim()),
      'discount':      _discountCtrl.text.trim().isEmpty
          ? 0
          : int.parse(_discountCtrl.text.trim()),
      'imageUrl':      _imageCtrl.text.trim(),
      'stock':         _stockCtrl.text.trim().isEmpty
          ? 0
          : int.parse(_stockCtrl.text.trim()),
    };

    final ok = await context.read<AdminProvider>().addProduct(data);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Product added successfully'),
          backgroundColor: kGreen, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Product',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _Field(ctrl: _nameCtrl, label: 'Product Name *', hint: 'e.g. Wireless Headphones',
              icon: Icons.label_outline_rounded,
              validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
            const SizedBox(height: 14),

            const _SectionLabel('Category *'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorderColor)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: kCardColor,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                  items: _categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Row(children: [
                      Icon(kCategoryIcons[cat], size: 16, color: kCategoryColors[cat] ?? kAccent),
                      const SizedBox(width: 8),
                      Text(cat),
                    ]),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: _Field(ctrl: _priceCtrl, label: 'Price *', hint: '0.00',
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price required';
                  if (double.tryParse(v.trim()) == null) return 'Invalid number';
                  return null;
                })),
              const SizedBox(width: 10),
              Expanded(child: _Field(ctrl: _origCtrl, label: 'Original Price', hint: '0.00',
                icon: Icons.price_change_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (double.tryParse(v.trim()) == null) return 'Invalid number';
                  return null;
                })),
            ]),
            const SizedBox(height: 14),

            Row(children: [
              Expanded(child: _Field(ctrl: _discountCtrl, label: 'Discount %', hint: '0',
                icon: Icons.percent_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0 || n > 100) return '0–100 only';
                  return null;
                })),
              const SizedBox(width: 10),
              Expanded(child: _Field(ctrl: _stockCtrl, label: 'Stock', hint: '0',
                icon: Icons.inventory_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (int.tryParse(v.trim()) == null) return 'Invalid number';
                  return null;
                })),
            ]),
            const SizedBox(height: 14),

            _Field(ctrl: _imageCtrl, label: 'Image URL', hint: 'https://...',
              icon: Icons.image_outlined,
              keyboardType: TextInputType.url),
            const SizedBox(height: 28),

            if (admin.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: kRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10), border: Border.all(color: kRed.withValues(alpha: 0.4))),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: kRed),
                  const SizedBox(width: 8),
                  Expanded(child: Text(admin.error!, style: const TextStyle(fontSize: 12, color: kRed))),
                ]),
              ),

            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: admin.isLoading ? null : _submit,
                icon: admin.isLoading
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.add_rounded, size: 18),
                label: Text(admin.isLoading ? 'Adding...' : 'Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold, foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({required this.ctrl, required this.label, required this.hint,
    required this.icon, this.keyboardType = TextInputType.text, this.validator});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionLabel(label),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: kTextSecond, fontSize: 13),
          prefixIcon: Icon(icon, color: kTextSecond, size: 18),
          filled: true, fillColor: kCardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          border:             OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
          enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
          focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAccent)),
          errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
        ),
      ),
    ],
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextSecond));
}
