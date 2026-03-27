import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  int _selectedContactType = 0;
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _contactTypes = [
    'General Inquiry',
    'Bug Report',
    'Feature Request',
    'Billing',
    'Account Issue',
  ];

  final List<IconData> _contactTypeIcons = [
    Icons.help_outline,
    Icons.bug_report_outlined,
    Icons.lightbulb_outline,
    Icons.payment_outlined,
    Icons.account_circle_outlined,
  ];

  void _submitMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your message'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final message = 'Type: ${_contactTypes[_selectedContactType]}\n\nMessage: ${_messageController.text}';
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('https://wa.me/250792342586?text=$encodedMessage');
      
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        
        if (mounted) {
          setState(() => _isSubmitting = false);
          _messageController.clear();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Opening WhatsApp to send your message...'),
              backgroundColor: Colors.green.shade400,
            ),
          );
        }
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error sending message. Please try again.'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Contact Us',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Contact Methods Section
            Text(
              'Quick Contact',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Column(
                children: [
                  _buildContactMethod(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@ikibina.com',
                    onTap: () {
                      // Copy email or open email client
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _buildContactMethod(
                    icon: Icons.phone_outlined,
                    title: 'WhatsApp Support',
                    subtitle: '0792342586',
                    onTap: () async {
                      final whatsappUrl = Uri.parse('https://wa.me/250792342586');
                      if (await canLaunchUrl(whatsappUrl)) {
                        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                      }
                    },
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Form Section
            Text(
              'Send us a Message',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Type Selector
                  Text(
                    'Type of Inquiry',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      _contactTypes.length,
                      (index) => GestureDetector(
                        onTap: () => setState(() => _selectedContactType = index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedContactType == index
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedContactType == index
                                  ? const Color(0xFF2E7D32)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _contactTypeIcons[index],
                                size: 16,
                                color: _selectedContactType == index
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _contactTypes[index],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedContactType == index
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Message Input
                  Text(
                    'Your Message',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 6,
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      hintText: 'Please describe your issue or inquiry...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black38,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF2E7D32),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey.shade400,
                                ),
                              ),
                            )
                          : Text(
                              'Send Message',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Column(
                children: [
                  _buildFAQItem(
                    question: 'How do I reset my password?',
                    answer:
                        'Go to Login, click "Forgot Password", enter your email, and follow the instructions sent to your inbox.',
                    showDivider: true,
                  ),
                  _buildFAQItem(
                    question: 'How do I create and manage a group?',
                    answer:
                        'Go to the Groups tab and tap "Create Group". Enter group details, set savings goals, and invite members. You can manage contributions and track progress from the group detail screen.',
                    showDivider: true,
                  ),
                  _buildFAQItem(
                    question: 'How can I update my payment method?',
                    answer:
                        'Go to Profile > Payment Methods to add, remove, or update your payment information.',
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required bool showDivider,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Column(
        children: [
          ExpansionTile(
            title: Text(
              question,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Text(
                  answer,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }


}
