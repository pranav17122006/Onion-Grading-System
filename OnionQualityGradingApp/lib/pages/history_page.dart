import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/supabase_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> reports = [];

  // ============================================================
  // ONION COLORS
  // ============================================================

  static const Color onionPurple = Color(0xFF7A3E5D);
  static const Color onionDark = Color(0xFF4A3029);
  static const Color onionPink = Color(0xFFF3E0E9);
  static const Color onionCream = Color(0xFFFCF6EF);
  static const Color onionBorder = Color(0xFFE6D5DC);
  static const Color onionBrown = Color(0xFF9A6040);
  static const Color onionText = Color(0xFF7E6B64);

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  // ============================================================
  // LOAD REPORTS
  // ============================================================

  Future<void> loadReports() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await SupabaseService.getReports();

      if (!mounted) return;

      setState(() {
        reports = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // OPEN PDF
  // ============================================================

  Future<void> openPdf(String pdfPath) async {
    try {
      final String pdfUrl =
          SupabaseService.getPdfUrl(pdfPath);

      final Uri uri = Uri.parse(pdfUrl);

      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open PDF report.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open PDF: $e',
          ),
          backgroundColor: const Color(0xFF9A4E4E),
        ),
      );
    }
  }

  // ============================================================
  // OPEN IMAGE
  // ============================================================

  void openImage(String imagePath) {
    final String imageUrl =
        SupabaseService.getImageUrl(imagePath);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImagePage(
          imageUrl: imageUrl,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: onionCream,

      appBar: AppBar(
        backgroundColor: onionCream,
        elevation: 0,
        foregroundColor: onionDark,

        title: const Row(
          children: [
            Text(
              '🧅',
              style: TextStyle(
                fontSize: 27,
              ),
            ),
            SizedBox(width: 9),
            Text(
              'Analysis History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
                color: onionDark,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(
              right: 12,
            ),
            decoration: BoxDecoration(
              color: onionPink,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: loadReports,
              icon: const Icon(
                Icons.refresh_rounded,
                color: onionPurple,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: buildBody(),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: onionPurple,
        ),
      );
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (reports.isEmpty) {
      return RefreshIndicator(
        color: onionPurple,
        onRefresh: loadReports,

        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          children: [
            const SizedBox(height: 120),

            Container(
              width: 100,
              height: 100,
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: onionPink,
                shape: BoxShape.circle,
                border: Border.all(
                  color: onionBorder,
                ),
              ),
              child: const Center(
                child: Text(
                  '🧅',
                  style: TextStyle(
                    fontSize: 52,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No analysis history yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: onionDark,
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'Your previous onion analyses\n'
              'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onionText,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: onionPurple,
      onRefresh: loadReports,

      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          25,
        ),

        itemCount: reports.length,

        itemBuilder: (context, index) {
          final report = reports[index];

          return buildReportCard(report);
        },
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: const Color(0xFFF6E3E3),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: Color(0xFF9A4E4E),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load history',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: onionDark,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: onionText,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: loadReports,

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'TRY AGAIN',
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: onionPurple,
                foregroundColor: Colors.white,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget buildReportCard(
    Map<String, dynamic> report,
  ) {
    final String grade =
        report['onion_grade'] ?? 'N/A';

    final double score =
        report['quality_score'] == null
            ? 0
            : (report['quality_score'] as num)
                .toDouble();

    final double? price =
        report['estimated_price'] == null
            ? null
            : (report['estimated_price'] as num)
                .toDouble();

    final int total =
        report['total_onions'] ?? 0;

    final int healthy =
        report['healthy_count'] ?? 0;

    final int unhealthy =
        report['unhealthy_count'] ?? 0;

    final int small =
        report['small_count'] ?? 0;

    final int medium =
        report['medium_count'] ?? 0;

    final int large =
        report['large_count'] ?? 0;

    final String createdAt =
        report['created_at'] ?? '';

    final List<String> imagePaths =
    List<String>.from(report['image_path'] ?? []);

final String? imagePath =
    imagePaths.isNotEmpty ? imagePaths.first : null;

    final String? pdfPath =
        report['pdf_path'];

    return Container(
      margin: const EdgeInsets.only(
        bottom: 17,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: onionBorder,
        ),

        boxShadow: [
          BoxShadow(
            color:
                onionPurple.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // IMAGE + HEADER
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                GestureDetector(
                  onTap: imagePath == null
                      ? null
                      : () {
                          openImage(imagePath);
                        },

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(15),

                    child: imagePath == null
                        ? Container(
                            width: 100,
                            height: 100,
                            color: onionPink,
                            child: const Center(
                              child: Text(
                                '🧅',
                                style: TextStyle(
                                  fontSize: 40,
                                ),
                              ),
                            ),
                          )
                        : Image.network(
                            SupabaseService
                                .getImageUrl(
                              imagePath,
                            ),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,

                            loadingBuilder:
                                (
                              context,
                              child,
                              loadingProgress,
                            ) {
                              if (loadingProgress ==
                                  null) {
                                return child;
                              }

                              return Container(
                                width: 100,
                                height: 100,
                                color: onionPink,
                                child:
                                    const Center(
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        onionPurple,
                                  ),
                                ),
                              );
                            },

                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: onionPink,
                                child: const Center(
                                  child: Icon(
                                    Icons
                                        .broken_image_rounded,
                                    color:
                                        onionBrown,
                                    size: 38,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Row(
                        children: [

                          Container(
                            width: 45,
                            height: 45,

                            decoration:
                                BoxDecoration(
                              color:
                                  gradeColor(
                                    grade,
                                  ).withOpacity(
                                    0.12,
                                  ),
                              shape:
                                  BoxShape.circle,
                            ),

                            child: Center(
                              child: Text(
                                grade,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      gradeColor(
                                    grade,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 9),

                          const Expanded(
                            child: Text(
                              'Onion Quality Analysis',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.bold,
                                color: onionDark,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        formatDate(createdAt),
                        style:
                            const TextStyle(
                          color: onionText,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 9),

                      if (pdfPath != null)
                        SizedBox(
                          height: 38,

                          child:
                              OutlinedButton.icon(
                            onPressed: () {
                              openPdf(pdfPath);
                            },

                            icon: const Icon(
                              Icons
                                  .picture_as_pdf_rounded,
                              size: 18,
                              color:
                                  Color(0xFF9A4E4E),
                            ),

                            label: const Text(
                              'View PDF',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            style:
                                OutlinedButton.styleFrom(
                              foregroundColor:
                                  const Color(
                                0xFF9A4E4E,
                              ),

                              side:
                                  const BorderSide(
                                color: Color(
                                  0xFFE2BFC3,
                                ),
                              ),

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              height: 1,
              color: onionBorder,
            ),

            const SizedBox(height: 13),

            // ==================================================
            // QUALITY SCORE
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Quality Score',
                  style: TextStyle(
                    color: onionText,
                  ),
                ),

                Text(
                  '${score.toStringAsFixed(1)} / 100',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onionPurple,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // TOTAL
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Total Onions',
                  style: TextStyle(
                    color: onionText,
                  ),
                ),

                Text(
                  '$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onionDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // ==================================================
            // HEALTH
            // ==================================================

            Row(
              children: [

                Expanded(
                  child: historyValue(
                    'Healthy',
                    '$healthy',
                    onionPurple,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: historyValue(
                    'Unhealthy',
                    '$unhealthy',
                    const Color(0xFF9A4E4E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // SIZE
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: onionCream,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: onionBorder,
                ),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,

                children: [
                  sizeValue('Small', small),
                  sizeValue('Medium', medium),
                  sizeValue('Large', large),
                ],
              ),
            ),

            // ==================================================
            // PRICE
            // ==================================================

            if (price != null) ...[
              const SizedBox(height: 14),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: onionPink,
                  borderRadius:
                      BorderRadius.circular(11),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    const Text(
                      'Estimated Price',
                      style: TextStyle(
                        color: onionText,
                      ),
                    ),

                    Text(
                      '₹${price.toStringAsFixed(0)} / quintal',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color: onionPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HISTORY VALUE
  // ============================================================

  Widget historyValue(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIZE VALUE
  // ============================================================

  Widget sizeValue(
    String title,
    int value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: onionText,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: onionDark,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GRADE COLOR
  // ============================================================

  Color gradeColor(String grade) {
    switch (grade) {
      case 'A':
        return const Color(0xFF7A3E5D);

      case 'B':
        return const Color(0xFF934C70);

      case 'C':
        return const Color(0xFF9A6040);

      default:
        return const Color(0xFF9A4E4E);
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(String value) {
    if (value.isEmpty) {
      return 'Date unavailable';
    }

    try {
      final date =
          DateTime.parse(value).toLocal();

      final day =
          date.day.toString().padLeft(2, '0');

      final month =
          date.month.toString().padLeft(2, '0');

      final year =
          date.year.toString();

      final hour =
          date.hour.toString().padLeft(2, '0');

      final minute =
          date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year • '
          '$hour:$minute';
    } catch (_) {
      return value;
    }
  }
}


// ================================================================
// FULL IMAGE PAGE
// ================================================================

class FullImagePage extends StatelessWidget {
  final String imageUrl;

  const FullImagePage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        title: const Row(
          children: [
            Text(
              '🧅',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            SizedBox(width: 8),
            Text('Onion Image'),
          ],
        ),
      ),

      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,

            fit: BoxFit.contain,

            loadingBuilder:
                (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }

              return const CircularProgressIndicator(
                color: Colors.white,
              );
            },

            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {
              return const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 60,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Unable to load image',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}