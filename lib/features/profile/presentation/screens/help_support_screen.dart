import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I place an order?',
      'answer':
          'Browse shops on the home screen, add items to your cart, then tap Checkout. Fill in your delivery address, choose a payment method and tap Place Order.',
    },
    {
      'question': 'How long does delivery take?',
      'answer':
          'Delivery times vary by shop and your location. Each shop displays an estimated delivery time on its card. Most deliveries in Nairobi take between 20–45 minutes.',
    },
    {
      'question': 'How do I pay with M-Pesa?',
      'answer':
          'At checkout, select M-Pesa as your payment method. Enter your Safaricom phone number and tap Send STK Push. An M-Pesa prompt will appear on your phone — enter your PIN to complete payment.',
    },
    {
      'question': 'Can I track my order?',
      'answer':
          'Yes! Once your order is confirmed and a rider is assigned, go to My Orders and tap Track Order to see live status updates from your rider.',
    },
    {
      'question': 'What if my order is wrong or missing items?',
      'answer':
          'Contact our support team immediately via phone or email below. We will investigate and arrange a replacement or refund within 24 hours.',
    },
    {
      'question': 'How do I cancel an order?',
      'answer':
          'You can cancel an order while it is still in Pending status. Once the shop confirms and starts preparing your order, cancellation may not be possible. Contact support for assistance.',
    },
    {
      'question': 'Is my payment information secure?',
      'answer':
          'Yes. SwiftDrop does not store any card or M-Pesa PIN information. All payments are processed securely through Safaricom Daraja API and comply with industry security standards.',
    },
    {
      'question': 'How do I become a rider?',
      'answer':
          'Download the SwiftDrop app, tap Sign Up and select Rider as your role. Fill in your details and our team will review your application within 48 hours.',
    },
    {
      'question': 'How do I list my shop on SwiftDrop?',
      'answer':
          'Contact our business team via email at business@swiftdrop.co.ke or call +254 700 000 000. We will guide you through the onboarding process.',
    },
    {
      'question': 'What areas do you currently serve?',
      'answer':
          'SwiftDrop currently serves Nairobi and its suburbs including Westlands, Kilimani, Karen, CBD, Eastlands and surrounding areas. We are expanding rapidly.',
    },
  ];

  final Set<int> _expandedItems = {};

  Future<void> _launchPhone() async {
    final uri = Uri(scheme: 'tel', path: '+254700000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@swiftdrop.co.ke',
      queryParameters: {
        'subject': 'SwiftDrop Support Request',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/254700000000?text=Hello%20SwiftDrop%20Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent,
                      color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find answers to common questions below\nor contact us directly.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact options
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.phone_outlined,
                    label: 'Call Us',
                    value: '+254 700 000 000',
                    color: const Color(0xFF22C55E),
                    onTap: _launchPhone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    label: 'Email Us',
                    value: 'support@swiftdrop.co.ke',
                    color: const Color(0xFF3B82F6),
                    onTap: _launchEmail,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // WhatsApp
            GestureDetector(
              onTap: _launchWhatsApp,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.chat,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chat on WhatsApp',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Typically replies within minutes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: Color(0xFF6B7280)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // FAQ section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEFF2)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color(0xFFEEEFF2),
                ),
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  final isExpanded = _expandedItems.contains(index);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedItems.remove(index);
                        } else {
                          _expandedItems.add(index);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq['question']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isExpanded
                                        ? const Color(0xFFFF6B35)
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration:
                                    const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: isExpanded
                                      ? const Color(0xFFFF6B35)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(top: 10),
                                    child: Text(
                                      faq['answer']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                        height: 1.5,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Business hours
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEFF2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Color(0xFFFF6B35), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Support Hours',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HoursRow(
                      day: 'Monday — Friday',
                      hours: '8:00 AM — 10:00 PM'),
                  const SizedBox(height: 6),
                  _HoursRow(
                      day: 'Saturday',
                      hours: '9:00 AM — 8:00 PM'),
                  const SizedBox(height: 6),
                  _HoursRow(day: 'Sunday', hours: '10:00 AM — 6:00 PM'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEFF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;

  const _HoursRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          hours,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}