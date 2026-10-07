// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;

// class ApiService {

//   // Laptop hotspot IP
//   static const String baseUrl =
//       'http://192.168.137.1:8000';


//   // ============================================================
//   // ANALYZE ONION IMAGE
//   // ============================================================

//   static Future<Map<String, dynamic>> analyzeImage(
//       File image) async {

//     final uri = Uri.parse(
//       '$baseUrl/analyze',
//     );

//     final request = http.MultipartRequest(
//       'POST',
//       uri,
//     );

//     request.files.add(
//       await http.MultipartFile.fromPath(
//         'file',
//         image.path,
//       ),
//     );

//     final streamedResponse =
//         await request.send();

//     final response =
//         await http.Response.fromStream(
//       streamedResponse,
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         'Server error: ${response.statusCode}\n'
//         '${response.body}',
//       );
//     }

//     final data =
//         jsonDecode(response.body);

//     if (data['status'] != 'success') {
//       throw Exception(
//         'Analysis failed',
//       );
//     }

//     return data['result'];
//   }


//   // ============================================================
//   // GET MARKET PRICES
//   // ============================================================

//   static Future<List<dynamic>> getMarketPrices() async {

//     final uri = Uri.parse(
//       '$baseUrl/market-prices',
//     );

//     final response = await http.get(
//       uri,
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         'Server error: ${response.statusCode}\n'
//         '${response.body}',
//       );
//     }

//     final data =
//         jsonDecode(response.body);

//     if (data['status'] != 'success') {
//       throw Exception(
//         'Failed to fetch market prices',
//       );
//     }

//     return data['prices'];
//   }


//   // ============================================================
//   // GENERATE PDF REPORT
//   // ============================================================

//   static Future<List<int>> generatePdf(
//       Map<String, dynamic> result) async {

//     final uri = Uri.parse(
//       '$baseUrl/generate-pdf',
//     );

//     final response = await http.post(
//       uri,

//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/pdf',
//       },

//       body: jsonEncode({
//         'result': result,
//       }),
//     );

//     // Check server response
//     if (response.statusCode != 200) {
//       throw Exception(
//         'PDF generation failed: '
//         '${response.statusCode}\n'
//         '${response.body}',
//       );
//     }

//     // Make sure backend actually returned PDF
//     final contentType =
//         response.headers['content-type'] ?? '';

//     if (!contentType.contains('application/pdf')) {
//       throw Exception(
//         'Server did not return a PDF.\n'
//         'Content-Type: $contentType',
//       );
//     }

//     // Return actual PDF binary data
//     return response.bodyBytes;
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://192.168.137.1:8000';

  // ==========================================================
  // ANALYZE MULTIPLE PHOTOS OF THE SAME HEAP
  // ==========================================================

  static Future<Map<String, dynamic>> analyzeImages(
      List<File> images) async {
    if (images.isEmpty) {
      throw Exception('Please select at least one image.');
    }

    final uri = Uri.parse('$baseUrl/analyze');

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    // IMPORTANT:
    // The backend expects the field name "files" repeatedly.
    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          image.path,
        ),
      );
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      String message = response.body;

      try {
        final errorData = jsonDecode(response.body);

        if (errorData is Map &&
            errorData['detail'] != null) {
          message = errorData['detail'].toString();
        }
      } catch (_) {
        // Keep the raw response if it is not JSON.
      }

      throw Exception(
        'Server error: ${response.statusCode}\n$message',
      );
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception('Analysis failed.');
    }

    final result = data['result'];

    if (result is! Map<String, dynamic>) {
      throw Exception(
        'Invalid analysis result received from server.',
      );
    }

    return result;
  }

  // ==========================================================
  // BACKWARD-COMPATIBLE SINGLE IMAGE METHOD
  // ==========================================================

  static Future<Map<String, dynamic>> analyzeImage(
      File image) async {
    return analyzeImages([image]);
  }

  // ==========================================================
  // MARKET PRICES
  // ==========================================================

  static Future<List<dynamic>> getMarketPrices() async {
    final uri = Uri.parse('$baseUrl/market-prices');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      String message = response.body;

      try {
        final errorData = jsonDecode(response.body);

        if (errorData is Map &&
            errorData['detail'] != null) {
          message = errorData['detail'].toString();
        }
      } catch (_) {}

      throw Exception(
        'Server error: ${response.statusCode}\n$message',
      );
    }

    final data = jsonDecode(response.body);

    if (data['status'] != 'success') {
      throw Exception(
        'Failed to fetch market prices',
      );
    }

    return data['prices'];
  }

  // ==========================================================
  // PDF
  // ==========================================================

  static Future<List<int>> generatePdf(
      Map<String, dynamic> result) async {
    final uri = Uri.parse('$baseUrl/generate-pdf');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/pdf',
      },
      body: jsonEncode({
        'result': result,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'PDF generation failed: '
        '${response.statusCode}\n'
        '${response.body}',
      );
    }

    final contentType =
        response.headers['content-type'] ?? '';

    if (!contentType.contains('application/pdf')) {
      throw Exception(
        'Server did not return a PDF.\n'
        'Content-Type: $contentType',
      );
    }

    return response.bodyBytes;
  }
}
