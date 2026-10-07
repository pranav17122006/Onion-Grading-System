import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../localization/app_localizations.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic> result;
  final List<String> imagePaths;

  const ResultsPage({
    super.key,
    required this.result,
    required this.imagePaths,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool isGeneratingPdf = false;

  static const Color onionPurple = Color(0xFF7A3E5D);
  static const Color onionDark = Color(0xFF4A3029);
  static const Color onionPink = Color(0xFFF3E0E9);
  static const Color onionCream = Color(0xFFFCF6EF);
  static const Color onionBorder = Color(0xFFE6D5DC);
  static const Color onionBrown = Color(0xFF9A6040);
  static const Color onionText = Color(0xFF7E6B64);

  // ============================================================
  // GENERATE PDF
  // ============================================================

  Future<void> generatePdf() async {
    final l = AppLocalizations.of(context);

    setState(() {
      isGeneratingPdf = true;
    });

    try {
      final pdfBytes = await ApiService.generatePdf(
        widget.result,
      );

      final directory = await getApplicationDocumentsDirectory();

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final filePath =
          '${directory.path}/onion_quality_report_$timestamp.pdf';

      final file = File(filePath);

      await file.writeAsBytes(
        pdfBytes,
        flush: true,
      );

      final String pdfPath =
          await SupabaseService.uploadPdf(file);

          await SupabaseService.saveReport(
      imagePaths: widget.imagePaths,
      pdfPath: pdfPath,
      result: widget.result,
    );

      if (!mounted) return;

      setState(() {
        isGeneratingPdf = false;
      });

      final openResult = await OpenFilex.open(filePath);

      if (!mounted) return;

      if (openResult.type == ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.get('reportSavedSuccessfully'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l.get('reportUploadedSuccessfully')}\n'
              '${l.get('localFile')}: $filePath',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGeneratingPdf = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l.get('pdfGenerationFailed')}:\n$e',
          ),
          backgroundColor: const Color(0xFF9A4E4E),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final result = widget.result;

    final int total = result['total_onions'] ?? 0;

    final int healthy = result['healthy'] ?? 0;

    final int unhealthy = result['unhealthy'] ?? 0;

    final int small = result['small'] ?? 0;

    final int medium = result['medium'] ?? 0;

    final int large = result['large'] ?? 0;

    final double score =
        (result['final_score'] ?? 0).toDouble();

    final String grade =
        result['grade'] ?? 'N/A';

    final String description =
        getGradeDescription(context, grade);

    final double? estimatedPrice =
        result['estimated_price'] == null
            ? null
            : (result['estimated_price']).toDouble();

    final market = result['market'];

    return Scaffold(
      backgroundColor: onionCream,

      appBar: AppBar(
        backgroundColor: onionCream,
        elevation: 0,
        foregroundColor: onionDark,

        title: Row(
          children: [
            const Text(
              '🧅',
              style: TextStyle(
                fontSize: 26,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.get('analysisResults'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: onionDark,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            25,
          ),

          child: Column(
            children: [

              // ==================================================
              // GRADE CARD
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [
                      Color(0xFF7A3E5D),
                      Color(0xFF934C70),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(26),

                  boxShadow: [
                    BoxShadow(
                      color: onionPurple.withOpacity(0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    Container(
                      width: 72,
                      height: 72,

                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              Colors.white.withOpacity(0.25),
                        ),
                      ),

                      child: const Center(
                        child: Text(
                          '🧅',
                          style: TextStyle(
                            fontSize: 38,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      l.get('qualityGrade').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.6,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      grade,
                      style: const TextStyle(
                        fontSize: 65,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.13),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: Column(
                        children: [
                          Text(
                            '${score.toStringAsFixed(1)} / 100',
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          Text(
                            l.get('qualityScore'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // TOTAL
              // ==================================================

              ResultCard(
                title: l.get('onionsDetected'),
                value: '$total',
                icon: Icons.inventory_2_rounded,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // HEALTH
              // ==================================================

              Row(
                children: [

                  Expanded(
                    child: ResultCard(
                      title: l.get('healthy'),
                      value: '$healthy',
                      icon: Icons.check_circle_rounded,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ResultCard(
                      title: l.get('unhealthy'),
                      value: '$unhealthy',
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // SIZE DISTRIBUTION
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: onionBorder,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [
                        const Icon(
                          Icons.donut_large_rounded,
                          size: 20,
                          color: onionPurple,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          l.get('sizeDistribution').toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: onionDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizeRow(
                      label: l.get('small'),
                      value: small,
                    ),

                    SizeRow(
                      label: l.get('medium'),
                      value: medium,
                    ),

                    SizeRow(
                      label: l.get('large'),
                      value: large,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // MARKET PRICE
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: onionBorder,
                  ),
                ),

                child: Column(
                  children: [

                    Container(
                      width: 52,
                      height: 52,

                      decoration: BoxDecoration(
                        color: onionPink,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.currency_rupee_rounded,
                        color: onionPurple,
                        size: 27,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      l.get('estimatedMarketPrice').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: onionDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      estimatedPrice == null
                          ? l.get('unavailable')
                          : '₹${estimatedPrice.toStringAsFixed(0)}',

                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: onionPurple,
                      ),
                    ),

                    Text(
                      l.get('perQuintal'),
                      style: const TextStyle(
                        color: onionText,
                      ),
                    ),

                    if (market != null) ...[
                      const SizedBox(height: 14),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: onionCream,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),

                        child: Text(
                          '${market['states']} '
                          '${l.get('states')} • '
                          '${market['markets']} '
                          '${l.get('markets')}',

                          style: const TextStyle(
                            color: onionText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // PDF
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton.icon(
                  onPressed:
                      isGeneratingPdf
                          ? null
                          : generatePdf,

                  icon: isGeneratingPdf
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.picture_as_pdf_rounded,
                        ),

                  label: Text(
                    isGeneratingPdf
                        ? l.get('savingReport').toUpperCase()
                        : l.get('generatePdfReport').toUpperCase(),

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: onionPurple,
                    foregroundColor: Colors.white,

                    disabledBackgroundColor:
                        Colors.grey.shade400,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // ANALYZE ANOTHER
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child: OutlinedButton.icon(
                  onPressed:
                      isGeneratingPdf
                          ? null
                          : () {
                              Navigator.pop(context);
                            },

                  icon: const Icon(
                    Icons.camera_alt_rounded,
                  ),

                  label: Text(
                    l.get('analyzeAnotherImage').toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor: onionPurple,

                    side: const BorderSide(
                      color: onionPurple,
                      width: 1.5,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ================================================================
// RESULT CARD
// ================================================================

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFFE6D5DC),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: const Color(0xFFF3E0E9),
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF7A3E5D),
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF7E6B64),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color: Color(0xFF4A3029),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ================================================================
// SIZE ROW
// ================================================================

class SizeRow extends StatelessWidget {
  final String label;
  final int value;

  const SizeRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),

      child: Row(
        children: [

          Container(
            width: 8,
            height: 8,

            decoration: const BoxDecoration(
              color: Color(0xFF7A3E5D),
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7E6B64),
              ),
            ),
          ),

          Text(
            '$value ${l.get('onions')}',

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3029),
            ),
          ),
        ],
      ),
    );
  }
}


// ================================================================
// LOCALIZATION HELPERS
// ================================================================

String getGradeDescription(
  BuildContext context,
  String grade,
) {
  final l = AppLocalizations.of(context);

  switch (grade.toUpperCase()) {
    case 'A':
      return l.get('excellent');

    case 'B':
      return l.get('good');

    case 'C':
      return l.get('average');

    case 'REJECT':
      return l.get('poor');

    default:
      return '';
  }
}