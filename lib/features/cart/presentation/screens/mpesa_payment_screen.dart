import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_service.dart';

class MpesaPaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final double amount;

  const MpesaPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  ConsumerState<MpesaPaymentScreen> createState() =>
      _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState
    extends ConsumerState<MpesaPaymentScreen> {
  final _phoneController = TextEditingController(text: '07');
  bool _isLoading = false;
  bool _stkSent = false;
  String? _errorMessage;


  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initiatePush() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() {
        _errorMessage = 'Enter a valid Safaricom number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();
      await api.post('/payments/mpesa/stk-push', data: {
  'phone': phone,
  'orderId': widget.orderId,
});

      setState(() {
        _stkSent = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to send STK push. Check your number and try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final response = await api.get(
          '/payments/status/${widget.orderId}');
      final paymentStatus = response.data['paymentStatus'];

      if (paymentStatus == 'paid') {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _PaymentSuccessScreen(
                orderId: widget.orderId),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Payment not received yet. Please complete the M-Pesa prompt on your phone.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking payment status.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('M-Pesa Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // M-Pesa logo area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00A651),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.phone_android,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'M-PESA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KSh ${widget.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (!_stkSent) ...[
              const Text(
                'Enter your M-Pesa number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'An STK push will be sent to your phone',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '0712 345 678',
                  prefixIcon: Icon(Icons.phone_outlined),
                  prefixText: '+254 ',
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _initiatePush,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Send STK Push'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A651),
                  ),
                ),
              ),
            ] else ...[
              // STK sent confirmation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Color(0xFF22C55E),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'STK Push Sent!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your phone ${_phoneController.text} for the M-Pesa prompt and enter your PIN to complete payment.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A651),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('I have paid — confirm'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    setState(() => _stkSent = false),
                child: const Text('Resend STK Push'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentSuccessScreen extends StatelessWidget {
  final String orderId;
  const _PaymentSuccessScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your M-Pesa payment has been received and your order is confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}