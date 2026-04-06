import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const _serviceId = 'service_u7rnqnj';
  static const _publicKey = 'k25KMYGf_XoOgRODh';

  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String toName,
  }) async {
    return _send(
      templateId: 'template_welcome',
      params: {
        'email': toEmail,
        'name': toName,
      },
    );
  }

  static Future<bool> sendApprovalEmail({
    required String toEmail,
    required String toName,
    required String loanAmount,
    required String referenceNo,
    required String repayment,
    required int duration,
    // required DateTime date,
  }) async {
    return _send(
      templateId: 'template_approved',
      params: {
        'first_name': toName.split(' ').first,
        'email': toEmail,
        'name': toName,
        'loan_amount': loanAmount,
        'reference_no': referenceNo,
        'repayment': repayment,
        'duration': duration,
        // 'date': date,
      },
    );
  }

  static Future<bool> sendRejectionEmail({
    required String toEmail,
    required String toName,
    required String loanAmount,
    required String referenceNo,
    required String repayment,
    required int duration,
    // required DateTime date,
  }) async {
    return _send(
      templateId: 'template_rejected',
      params: {
        'first_name': toName.split(' ').first,
        'email': toEmail,
        'name': toName,
        'loan_amount': loanAmount,
        'reference_no': referenceNo,
        'repayment': repayment,
        'duration': duration,
        // 'date': date,
      },
    );
  }

  static Future<bool> _send({
    required String templateId,
    required Map<String, dynamic> params,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': templateId,
          'user_id': _publicKey,
          'template_params': params,
        }),
      );
      print('EmailJS status: ${response.statusCode}');
      print('EmailJS body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('EmailJS error: $e');
      return false;
    }
  }
}
