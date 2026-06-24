import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../orders/presentation/screens/order_success_screen.dart';
import '../../../../core/network/api_service.dart';
import 'mpesa_payment_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _ensureAuthenticated() async {
    final api = ApiService();
    final token = await api.getToken();
    if (token != null && token.isNotEmpty) return true;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return false;

    try {
      final response = await api.post('/auth/google', data: {
        'firebaseUid': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ?? 'User',
        'photoUrl': firebaseUser.photoURL ?? '',
        'role': 'customer',
      });
      await api.saveToken(response.data['token']);
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a delivery address'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isAuth = await _ensureAuthenticated();
      if (!isAuth) {
        throw Exception('Please sign in again to place an order');
      }

      final cartItems = ref.read(cartProvider);
      if (cartItems.isEmpty) return;

      final shopId = cartItems.first.product.shopId;
      final items = cartItems
          .map((item) => {
                'product': item.product.id,
                'name': item.product.name,
                'price': item.product.price,
                'quantity': item.quantity,
                'imageUrl': item.product.imageUrl,
              })
          .toList();

      final order = await ref.read(orderRepositoryProvider).createOrder(
            shopId: shopId,
            items: items,
            deliveryAddress: _addressController.text.trim(),
            deliveryFee: 50,
            paymentMethod: _paymentMethod,
            notes: _notesController.text.trim(),
          );

      ref.read(cartProvider.notifier).clearCart();

      if (!mounted) return;

      // If M-Pesa, go to payment screen, else go straight to success
      if (_paymentMethod == 'mpesa') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MpesaPaymentScreen(
              orderId: order.id,
              amount: order.total,
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(orderId: order.id),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    const deliveryFee = 50.0;
    final grandTotal = total + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/cart'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            _SectionCard(
              title: 'Order Summary',
              child: Column(
                children: [
                  ...cartItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} x${item.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            'KSh ${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                  _PriceRow(label: 'Subtotal', amount: total),
                  const SizedBox(height: 6),
                  const _PriceRow(
                    label: 'Delivery fee',
                    amount: deliveryFee,
                    color: Color(0xFF6B7280),
                  ),
                  const Divider(height: 20),
                  _PriceRow(
                    label: 'Total',
                    amount: grandTotal,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Delivery address
            _SectionCard(
              title: 'Delivery Address',
              child: TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Westlands, Nairobi — Apt 4B',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment method
            _SectionCard(
              title: 'Payment Method',
              child: Column(
                children: [
                  _PaymentOption(
                    label: 'Cash on delivery',
                    icon: Icons.money,
                    value: 'cash',
                    selected: _paymentMethod,
                    onTap: () =>
                        setState(() => _paymentMethod = 'cash'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    label: 'M-Pesa',
                    icon: Icons.phone_android,
                    value: 'mpesa',
                    selected: _paymentMethod,
                    onTap: () =>
                        setState(() => _paymentMethod = 'mpesa'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    label: 'Card',
                    icon: Icons.credit_card,
                    value: 'card',
                    selected: _paymentMethod,
                    onTap: () =>
                        setState(() => _paymentMethod = 'card'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            _SectionCard(
              title: 'Order Notes (optional)',
              child: TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText:
                      'Any special instructions for your order...',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Place order button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _paymentMethod == 'mpesa'
                            ? 'Continue to M-Pesa • KSh ${grandTotal.toStringAsFixed(0)}'
                            : 'Place Order • KSh ${grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEFF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? const Color(0xFF1A1A2E),
          ),
        ),
        Text(
          'KSh ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? const Color(0xFFFF6B35)
                : (color ?? const Color(0xFF1A1A2E)),
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF6B35).withValues(alpha: 0.08)
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B35)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFFF6B35)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFFFF6B35)
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF6B35),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}