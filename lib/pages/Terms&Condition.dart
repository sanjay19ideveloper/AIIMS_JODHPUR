import 'package:flutter/gestures.dart';
   import 'package:flutter/material.dart';
   import 'package:url_launcher/url_launcher.dart';

   class TermsConditionsScreen extends StatelessWidget {
     const TermsConditionsScreen({super.key});

     // Hardcoded Terms and Conditions content
     final String _termsConditionsContent = '''
Terms and Conditions

Last updated: April 30, 2025

Welcome to the Hriday sathi (हृदय साथी) HeartCare mobile application (the "App"), operated by Hriday sathi (हृदय साथी). By accessing or using the App, you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to these Terms, please do not use the App.

1. Use of the App
The App is designed to provide health-related services, including access to lab reports, OPD inquiries, patient registration, and heart health tracking. You agree to:
- Use the App for lawful purposes only.
- Provide accurate, current, and complete information when registering or using the App's features.
- Not use the App to engage in any activity that violates local, state, national, or international laws.

2. Disclaimer
The content provided in the App is for informational purposes only and should not be construed as medical advice or a statement of law. Hriday sathi (हृदय साथी) makes every effort to ensure the accuracy and currency of the content, but we do not guarantee its completeness or suitability for any purpose. Users are advised to consult healthcare professionals for medical advice and verify information with appropriate sources.

3. Limitation of Liability
Under no circumstances will Hriday sathi (हृदय साथी) or its affiliates be liable for any expense, loss, or damage, including indirect or consequential loss, arising from the use or inability to use the App, or from any errors or omissions in the content. This includes, but is not limited to, loss of data or loss caused by reliance on the App's information.

4. Intellectual Property
The App, including its design, text, graphics, and logos, is owned by or licensed to Hriday sathi (हृदय साथी). You may not reproduce, distribute, or create derivative works from any part of the App without prior written permission, except as permitted for personal, non-commercial use.

5. Third-Party Services
The App may include services provided by third parties (e.g., CDAC Noida for development). These services are subject to their respective terms and conditions, and Hriday sathi (हृदय साथी) is not responsible for their performance or content.

6. Termination
We reserve the right to terminate or suspend your access to the App at any time, without notice, for conduct that we believe violates these Terms or is harmful to other users or the App's operation.

7. Governing Law
These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising under these Terms shall be subject to the exclusive jurisdiction of the courts in Jodhpur, Rajasthan.

8. Changes to These Terms
We may update these Terms from time to time. We will notify you of any changes by posting the updated Terms within the App and updating the "Last updated" date at the top of this document. Your continued use of the App after such changes constitutes your acceptance of the new Terms.

9. Contact Us
If you have any questions about these Terms, please contact us:
- By email: support@aiimsjodhpur.edu.in
- By visiting: www.aiimsjodhpur.edu.in
- By phone: +91-291-2740741

By using the App, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.
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
             'Terms and Conditions',
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
               children: _buildTextSpans(context, _termsConditionsContent),
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

         if (RegExp(r'^\d+\.|^[A-Za-z\s]+$').hasMatch(line) && line.endsWith(':')) {
           // Handle headings (e.g., "1. Use of the App", "Contact Us")
           spans.add(TextSpan(
             text: '$line\n\n',
             style: const TextStyle(
               fontSize: 20,
               fontWeight: FontWeight.bold,
               color: Color(0xFF0D3B3F),
               height: 1.4,
             ),
           ));
         } else if (line.contains('support@aiimsjodhpur.edu.in') ||
                    line.contains('www.aiimsjodhpur.edu.in') ||
                    line.contains('+91-291-2740741')) {
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
             } else if (part == '+91-291-2740741') {
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