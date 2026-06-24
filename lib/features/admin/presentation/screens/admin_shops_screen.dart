import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/widgets/image_picker_widget.dart';

// Provider for all shops (admin view — includes inactive)
final adminShopsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ApiService();
  final response = await api.get('/shops');
  return response.data['shops'];
});

class AdminShopsScreen extends ConsumerStatefulWidget {
  const AdminShopsScreen({super.key});

  @override
  ConsumerState<AdminShopsScreen> createState() =>
      _AdminShopsScreenState();
}

class _AdminShopsScreenState extends ConsumerState<AdminShopsScreen> {
  @override
  Widget build(BuildContext context) {
    final shops = ref.watch(adminShopsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Manage Shops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showShopForm(context),
          ),
        ],
      ),
      body: shops.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: Color(0xFFFF6B35)),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (shopList) => shopList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.store_outlined,
                        size: 64, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),
                    const Text('No shops yet'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showShopForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Shop'),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: shopList.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final shop = shopList[index];
                  return _ShopManageCard(
                    shop: shop,
                    onEdit: () =>
                        _showShopForm(context, shop: shop),
                    onManageProducts: () =>
                        _showProductsScreen(context, shop),
                    onRefresh: () =>
                        ref.invalidate(adminShopsProvider),
                  );
                },
              ),
      ),
    );
  }

  void _showShopForm(BuildContext context,
      {Map<String, dynamic>? shop}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ShopFormSheet(
        shop: shop,
        onSaved: () {
          ref.invalidate(adminShopsProvider);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showProductsScreen(
      BuildContext context, Map<String, dynamic> shop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminProductsScreen(shop: shop),
      ),
    );
  }
}

// ── Shop card ──
class _ShopManageCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  final VoidCallback onEdit;
  final VoidCallback onManageProducts;
  final VoidCallback onRefresh;

  const _ShopManageCard({
    required this.shop,
    required this.onEdit,
    required this.onManageProducts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = shop['imageUrl'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop image
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.store_outlined,
                            size: 40, color: Color(0xFF6B7280)),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.store_outlined,
                        size: 40, color: Color(0xFF6B7280)),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        shop['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        shop['category'] ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  shop['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined,
                            size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onManageProducts,
                        icon: const Icon(
                            Icons.inventory_2_outlined,
                            size: 16),
                        label: const Text('Products'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          minimumSize: Size.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shop form sheet ──
class _ShopFormSheet extends StatefulWidget {
  final Map<String, dynamic>? shop;
  final VoidCallback onSaved;

  const _ShopFormSheet({this.shop, required this.onSaved});

  @override
  State<_ShopFormSheet> createState() => _ShopFormSheetState();
}

class _ShopFormSheetState extends State<_ShopFormSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  String _category = 'Food';
  String? _imageUrl;
  bool _isOpen = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'Food', 'Groceries', 'Pharmacy',
    'Electronics', 'Fashion', 'Drinks',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.shop != null) {
      final s = widget.shop!;
      _nameController.text = s['name'] ?? '';
      _descController.text = s['description'] ?? '';
      _addressController.text = s['address'] ?? '';
      _deliveryFeeController.text =
          (s['deliveryFee'] ?? 0).toString();
      _deliveryTimeController.text =
          s['deliveryTime'] ?? '30-45 min';
      _category = s['category'] ?? 'Food';
      _imageUrl = s['imageUrl'];
      _isOpen = s['isOpen'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _deliveryFeeController.dispose();
    _deliveryTimeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      final api = ApiService();
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'address': _addressController.text.trim(),
        'category': _category,
        'imageUrl': _imageUrl ?? '',
        'deliveryFee':
            double.tryParse(_deliveryFeeController.text) ?? 0,
        'deliveryTime': _deliveryTimeController.text.trim().isEmpty
            ? '30-45 min'
            : _deliveryTimeController.text.trim(),
        'isOpen': _isOpen,
      };

      if (widget.shop != null) {
        await api.patch('/shops/${widget.shop!['_id']}',
            data: data);
      } else {
        await api.post('/shops', data: data);
      }

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.shop != null ? 'Edit Shop' : 'Add New Shop',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),

            // Image upload
            ImagePickerWidget(
              currentImageUrl: _imageUrl,
              folder: 'shops',
              size: 160,
              onImageUploaded: (url) =>
                  setState(() => _imageUrl = url),
            ),
            const SizedBox(height: 16),

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name *',
                hintText: 'e.g. Burger Palace',
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of the shop',
              ),
            ),
            const SizedBox(height: 12),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration:
                  const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? 'Food'),
            ),
            const SizedBox(height: 12),

            // Address
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'e.g. Westlands, Nairobi',
              ),
            ),
            const SizedBox(height: 12),

            // Delivery fee and time
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _deliveryFeeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Fee (KSh)',
                      hintText: '50',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _deliveryTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Time',
                      hintText: '30-45 min',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Is open toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shop is Open',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Switch(
                  value: _isOpen,
                  activeThumbColor: const Color(0xFFFF6B35),
                  onChanged: (v) => setState(() => _isOpen = v),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(widget.shop != null
                        ? 'Save Changes'
                        : 'Create Shop'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Products management screen ──
class AdminProductsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> shop;

  const AdminProductsScreen({super.key, required this.shop});

  @override
  ConsumerState<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState
    extends ConsumerState<AdminProductsScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final response = await api.get(
          '/shops/${widget.shop['_id']}/products');
      setState(() => _products = response.data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showProductForm({Map<String, dynamic>? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProductFormSheet(
        product: product,
        shopId: widget.shop['_id'],
        onSaved: () {
          _loadProducts();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('${widget.shop['name']} — Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFFFF6B35)),
            )
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 64, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),
                      const Text('No products yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showProductForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Product'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _ProductManageCard(
                      product: product,
                      onEdit: () =>
                          _showProductForm(product: product),
                      onDelete: () async {
                        final api = ApiService();
                        await api.delete(
                            '/products/${product['_id']}');
                        _loadProducts();
                      },
                    );
                  },
                ),
    );
  }
}

// ── Product card ──
class _ProductManageCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductManageCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['imageUrl'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood_outlined,
                          color: Color(0xFF6B7280)),
                    ),
                  )
                : const Icon(Icons.fastfood_outlined,
                    color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'KSh ${product['price'] ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  product['category'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Color(0xFF3B82F6), size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFFEF4444), size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Product'),
                      content: Text(
                          'Remove ${product['name']} from this shop?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFEF4444),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Product form sheet ──
class _ProductFormSheet extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String shopId;
  final VoidCallback onSaved;

  const _ProductFormSheet({
    this.product,
    required this.shopId,
    required this.onSaved,
  });

  @override
  State<_ProductFormSheet> createState() =>
      _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'Food';
  String? _imageUrl;
  bool _isAvailable = true;
  bool _isSaving = false;

  final List<String> _categories = [
    'Food', 'Groceries', 'Pharmacy',
    'Electronics', 'Fashion', 'Drinks',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p['name'] ?? '';
      _descController.text = p['description'] ?? '';
      _priceController.text = (p['price'] ?? 0).toString();
      _category = p['category'] ?? 'Food';
      _imageUrl = p['imageUrl'];
      _isAvailable = p['isAvailable'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (mounted) {
  Navigator.pop(context);
}

    setState(() => _isSaving = true);

    try {
      final api = ApiService();
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'category': _category,
        'shop': widget.shopId,
        'imageUrl': _imageUrl ?? '',
        'isAvailable': _isAvailable,
      };

      if (widget.product != null) {
        await api.patch('/products/${widget.product!['_id']}',
            data: data);
      } else {
        await api.post('/products', data: data);
      }

      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product != null
                  ? 'Edit Product'
                  : 'Add New Product',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),

            // Image upload
            ImagePickerWidget(
              currentImageUrl: _imageUrl,
              folder: 'products',
              size: 160,
              onImageUploaded: (url) =>
                  setState(() => _imageUrl = url),
            ),
            const SizedBox(height: 16),

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g. Chicken Burger',
              ),
            ),
            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description',
              ),
            ),
            const SizedBox(height: 12),

            // Price and category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (KSh) *',
                      hintText: '450',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                        labelText: 'Category'),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _category = v ?? 'Food'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Available toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  activeThumbColor: const Color(0xFFFF6B35),
                  onChanged: (v) =>
                      setState(() => _isAvailable = v),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(widget.product != null
                        ? 'Save Changes'
                        : 'Add Product'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}