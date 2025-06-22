import 'package:flutter/gestures.dart';
   import 'package:flutter/material.dart';
   import 'package:url_launcher/url_launcher.dart';

   class PrivacyPolicyScreen extends StatelessWidget {
     const PrivacyPolicyScreen({super.key});

     // Hardcoded Privacy Policy content
     final String _privacyPolicyContent = '''
Privacy Policy

Last updated: April 30, 2025

Hriday sathi (हृदय साथी) ("we", "us", or "our") operates the Hriday sathi (हृदय साथी) HeartCare mobile application (the "App"). This Privacy Policy informs you of our policies regarding the collection, use, and disclosure of personal data when you use our App and the choices you have associated with that data.

Information Collection and Use
We collect minimal personal information to provide and improve our services. When you use the App, we may collect:
- Personal Data: If you choose to provide information such as your name, email address, or phone number (e.g., during registration or profile creation), it is used solely to fulfill your request for services, such as accessing lab reports, OPD inquiries, or patient registration.
- Technical Data: We automatically collect technical information, including your device's internet domain, IP address, browser type, operating system, pages accessed, and documents downloaded. This data does not identify you personally and is used to enhance the App's functionality and user experience.
- Usage Data: Information about how you interact with the App, such as navigation patterns, is collected to improve our services.

No personal information, such as names or addresses, is collected unless voluntarily provided by you.

Use of Data
We use the collected data for various purposes:
- To provide and maintain the App's services, such as displaying lab reports and OPD details.
- To notify you about updates, new features, or health-related information.
- To analyze usage patterns to improve the App's performance and user experience.
- To comply with legal obligations under Indian laws.

Data Sharing
We do not share your personal data with third parties except:
- When required by law or to respond to valid requests by public authorities.
- In the case of a merger, acquisition, or asset sale, where your data may be transferred with prior notice.
- With service providers (e.g., CDAC Noida) who assist in operating the App, bound by confidentiality agreements.

Data Security
The security of your data is important to us. We implement reasonable security measures to protect your personal data from unauthorized access, use, or disclosure. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.

Your Data Protection Rights
Under applicable Indian laws, you have the following rights:
- Access: Request access to the personal data we hold about you.
- Rectification: Request correction of inaccurate or incomplete data.
- Deletion: Request deletion of your personal data, subject to legal obligations.
- Objection: Object to the processing of your personal data for specific purposes.

To exercise these rights, contact us at support@aiimsjodhpur.edu.in.

Help & Support
If you have questions or need assistance with the App, including issues related to lab reports, OPD inquiries, or patient registration, please contact our support team:
- Email: support@aiimsjodhpur.edu.in
- Phone: +91-291-2740741 (Medical College) or +91-291-2740742 (Hospital)
- Website: www.aiimsjodhpur.edu.in

Our support team is available to address technical issues, clarify privacy concerns, or assist with account management. For urgent medical inquiries, please contact the hospital directly.

Changes to This Privacy Policy
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy within the App and updating the "Last updated" date at the top of this policy. You are advised to review this Privacy Policy periodically for any changes.

Contact Us
If you have any questions about this Privacy Policy, please contact us:
- By email: support@aiimsjodhpur.edu.in
- By visiting: www.aiimsjodhpur.edu.in
- By phone: +91-291-2740741

This Privacy Policy is governed by and construed in accordance with the laws of India. Any disputes arising under this policy shall be subject to the exclusive jurisdiction of the courts in Jodhpur, Rajasthan.
     ''';

     Future<void> _launchUrl(String url, BuildContext context) async {
       final Uri uri = Uri.parse(url);
       if (await canLaunchUrl(uri)) {
         await launchUrl(uri, mode: LaunchMode.externalApplication);
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Could not open $url')),
         );
       }
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         backgroundColor: Colors.grey[100],
         appBar: AppBar(
           backgroundColor: const Color(0xFF0D3B3F),
           title: const Text(
             'Privacy Policy',
             style: TextStyle(color: Colors.white, fontSize: 18),
           ),
           leading: IconButton(
             icon: const Icon(Icons.arrow_back, color: Colors.white),
             onPressed: () => Navigator.pop(context),
           ),
           elevation: 0,
         ),
         body: SingleChildScrollView(
           padding: const EdgeInsets.all(16.0),
           child: RichText(
             text: TextSpan(
               style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
               children: _buildTextSpans(context, _privacyPolicyContent),
             ),
           ),
         ),
       );
     }

     List<TextSpan> _buildTextSpans(BuildContext context, String content) {
       final List<TextSpan> spans = [];
       final lines = content.split('\n');

       for (var line in lines) {
         line = line.trim();
         if (line.isEmpty) continue;

         if (line.startsWith('#')) {
           // Handle headings
           final level = line.split('#').length - 1;
           final text = line.replaceAll('#', '').trim();
           spans.add(TextSpan(
             text: '$text\n\n',
             style: TextStyle(
               fontSize: level == 1 ? 24 : (level == 2 ? 20 : 18),
               fontWeight: FontWeight.bold,
               color: const Color(0xFF0D3B3F),
               height: 1.4,
             ),
           ));
         } else if (line.contains('support@aiimsjodhpur.edu.in') ||
                    line.contains('www.aiimsjodhpur.edu.in') ||
                    line.contains('+91-291-2740741') ||
                    line.contains('+91-291-2740742')) {
           // Handle links
           final parts = line.split(RegExp(r'(\s+)'));
           for (var part in parts) {
             if (part == 'support@aiimsjodhpur.edu.in') {
               spans.add(TextSpan(
                 text: part,
                 style: const TextStyle(
                   color: Colors.blue,
                   decoration: TextDecoration.underline,
                   fontSize: 16,
                 ),
                 recognizer: TapGestureRecognizer()
                   ..onTap = () => _launchUrl('mailto:$part', context),
               ));
             } else if (part == 'www.aiimsjodhpur.edu.in') {
               spans.add(TextSpan(
                 text: part,
                 style: const TextStyle(
                   color: Colors.blue,
                   decoration: TextDecoration.underline,
                   fontSize: 16,
                 ),
                 recognizer: TapGestureRecognizer()
                   ..onTap = () => _launchUrl('https://$part', context),
               ));
             } else if (part == '+91-291-2740741' || part == '+91-291-2740742') {
               spans.add(TextSpan(
                 text: part,
                 style: const TextStyle(
                   color: Colors.blue,
                   decoration: TextDecoration.underline,
                   fontSize: 16,
                 ),
                 recognizer: TapGestureRecognizer()
                   ..onTap = () => _launchUrl('tel:$part', context),
               ));
             } else {
               spans.add(TextSpan(text: part));
             }
             spans.add(const TextSpan(text: ' '));
           }
           spans.add(const TextSpan(text: '\n'));
         } else {
           // Handle regular text
           spans.add(TextSpan(text: '$line\n'));
         }
       }
       return spans;
     }
   }