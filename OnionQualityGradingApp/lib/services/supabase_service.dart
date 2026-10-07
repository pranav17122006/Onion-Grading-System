import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client =
      Supabase.instance.client;

  // ============================================================
  // GET CURRENT FIREBASE UID
  // ============================================================

  static String getFirebaseUid() {
    final firebase_auth.User? user =
        firebase_auth.FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    return user.uid;
  }

  // ============================================================
  // UPLOAD ONION IMAGE
  // ============================================================

  static Future<String> uploadImage(
    File imageFile,
  ) async {
    final String uid = getFirebaseUid();

    final String timestamp =
        DateTime.now().millisecondsSinceEpoch.toString();

    final String extension =
        imageFile.path.split('.').last.toLowerCase();

    final String filePath =
        '$uid/images/onion_$timestamp.$extension';

    await client.storage
        .from('onion_data')
        .upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(
            upsert: false,
          ),
        );

    return filePath;
  }

  // ============================================================
  // GET PUBLIC IMAGE URL
  // ============================================================

  static String getImageUrl(
    String imagePath,
  ) {
    return client.storage
        .from('onion_data')
        .getPublicUrl(imagePath);
  }

  // ============================================================
  // UPLOAD PDF REPORT
  // ============================================================

  static Future<String> uploadPdf(
    File pdfFile,
  ) async {
    final String uid = getFirebaseUid();

    final String timestamp =
        DateTime.now().millisecondsSinceEpoch.toString();

    final String filePath =
        '$uid/reports/onion_report_$timestamp.pdf';

    await client.storage
        .from('onion_data')
        .upload(
          filePath,
          pdfFile,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: false,
          ),
        );

    return filePath;
  }

  // ============================================================
  // GET PUBLIC PDF URL
  // ============================================================

  static String getPdfUrl(
    String pdfPath,
  ) {
    return client.storage
        .from('onion_data')
        .getPublicUrl(pdfPath);
  }

  // ============================================================
// SAVE REPORT DETAILS
// ============================================================

static Future<void> saveReport({
  required List<String> imagePaths,
  required String pdfPath,
  required Map<String, dynamic> result,
}) async {
  final String uid = getFirebaseUid();

  await client.from('reports').insert({
    'firebase_uid': uid,

    // IMPORTANT:
    // image_path is a text[] column in Supabase
    'image_path': imagePaths,

    'pdf_path': pdfPath,

    'total_onions':
        result['total_onions'] ?? 0,

    'healthy_count':
        result['healthy'] ?? 0,

    'unhealthy_count':
        result['unhealthy'] ?? 0,

    'small_count':
        result['small'] ?? 0,

    'medium_count':
        result['medium'] ?? 0,

    'large_count':
        result['large'] ?? 0,

    'quality_score':
        result['final_score'] ?? 0,

    'onion_grade':
        result['grade'] ?? 'N/A',

    'estimated_price':
        result['estimated_price'],
  });
}

  // ============================================================
  // GET ALL REPORTS FOR CURRENT USER
  // ============================================================

  static Future<List<Map<String, dynamic>>> getReports() async {
    final String uid = getFirebaseUid();

    final response = await client
        .from('reports')
        .select()
        .eq('firebase_uid', uid)
        .order(
          'created_at',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(
      response,
    );
  }
}