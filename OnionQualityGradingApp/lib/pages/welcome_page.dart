
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF6EF),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  // ==========================================================
                  // TOP ONION LOGO
                  // ==========================================================

                  const SizedBox(height: 8),

                  Center(
                    child: Container(
                      width: 94,
                      height: 94,

                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF4E3D2),
                            Color(0xFFE9D0B8),
                          ],
                        ),

                        shape: BoxShape.circle,

                        border: Border.all(
                          color:
                              const Color(0xFFD6B08A),
                          width: 2,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF9A6040)
                                    .withOpacity(0.12),
                            blurRadius: 15,
                            offset:
                                const Offset(0, 7),
                          ),
                        ],
                      ),

                      child: const Center(
                        child: Text(
                          '🧅',
                          style: TextStyle(
                            fontSize: 55,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================================================
                  // APP NAME
                  // ==========================================================

                  Text(
                    l.get('onionQualityGrading'),
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 34,
                      height: 1.12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3029),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==========================================================
                  // DESCRIPTION
                  // ==========================================================

                  Text(
                    l.get('smartSimpleDescription'),
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF7E6B64),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==========================================================
                  // MAIN ONION QUALITY ILLUSTRATION
                  // ==========================================================

                  Container(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      22,
                      20,
                      22,
                    ),

                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,

                        colors: [
                          Color(0xFFFFFCF8),
                          Color(0xFFF7E9EE),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(28),

                      border: Border.all(
                        color:
                            const Color(0xFFE6D5DC),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF7A3E5D)
                                  .withOpacity(0.08),

                          blurRadius: 20,

                          offset:
                              const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        // ==================================================
                        // CLEAN ONION LOGO ILLUSTRATION
                        // ==================================================

                        const SizedBox(
                          height: 215,
                          width: double.infinity,

                          child: Center(
                            child:
                                OnionLogoIllustration(),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // ==================================================
                        // TITLE
                        // ==================================================

                        Text(
                          l.get('gradeYourOnionsEasily'),

                          textAlign:
                              TextAlign.center,

                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(0xFF49312B),
                          ),
                        ),

                        const SizedBox(height: 9),

                        // ==================================================
                        // DESCRIPTION
                        // ==================================================

                        Text(
                          l.get('uploadImageInstantAssessment'),

                          textAlign:
                              TextAlign.center,

                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color:
                                Color(0xFF7E6B64),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================================
                  // GET STARTED BUTTON
                  // ==========================================================

                  SizedBox(
                    height: 56,

                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const RegisterPage(),
                          ),
                        );
                      },

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF7A3E5D),

                        foregroundColor:
                            Colors.white,

                        elevation: 3,

                        shadowColor:
                            const Color(0xFF7A3E5D)
                                .withOpacity(0.25),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          const Icon(
                            Icons.agriculture_rounded,
                            size: 21,
                          ),

                          const SizedBox(width: 9),

                          Text(
                            l.get('getStarted').toUpperCase(),

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),

                          const SizedBox(width: 9),

                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // ==========================================================
                  // LOGIN BUTTON
                  // ==========================================================

                  SizedBox(
                    height: 56,

                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginPage(),
                          ),
                        );
                      },

                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF7A3E5D),

                        side:
                            const BorderSide(
                          color:
                              Color(0xFF7A3E5D),
                          width: 1.5,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          const Icon(
                            Icons.login_rounded,
                            size: 20,
                          ),

                          const SizedBox(width: 9),

                          Text(
                            l.get('login').toUpperCase(),

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 27),

                  // ==========================================================
                  // FEATURES
                  // ==========================================================

                  Text(
                    l.get('whyUseOnionQualityGrading'),

                    textAlign:
                        TextAlign.center,

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF4B403A),
                    ),
                  ),

                  const SizedBox(height: 17),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Expanded(
                        child: _buildFeature(
                          icon:
                              Icons.photo_camera_rounded,
                          title:
                              l.get('easy'),
                          subtitle:
                              l.get('uploadAnImage'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _buildFeature(
                          icon:
                              Icons.psychology_rounded,
                          title:
                              l.get('smart'),
                          subtitle:
                              l.get('aiPoweredGrading'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _buildFeature(
                          icon:
                              Icons.verified_rounded,
                          title:
                              l.get('fast'),
                          subtitle:
                              l.get('instantResults'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 27),

                  // ==========================================================
                  // ONION PROCESS STRIP
                  // ==========================================================

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFF1E9E1),

                      borderRadius:
                          BorderRadius.circular(17),

                      border: Border.all(
                        color:
                            const Color(0xFFE6D8CC),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,

                      children: [

                        _buildProcessItem(
                          icon:
                              Icons.photo_camera_rounded,
                          label:
                              l.get('capture'),
                        ),

                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color:
                              Color(0xFF9A796A),
                        ),

                        _buildProcessItem(
                          icon:
                              Icons.psychology_rounded,
                          label:
                              l.get('analyze'),
                        ),

                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color:
                              Color(0xFF9A796A),
                        ),

                        _buildProcessItem(
                          icon:
                              Icons.verified_rounded,
                          label:
                              l.get('grade'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 27),

                  // ==========================================================
                  // FOOTER
                  // ==========================================================

                  Text(
                    l.get('onionQualityGrading'),

                    textAlign:
                        TextAlign.center,

                    style: const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF8C7770),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    l.get('smartGradingBetterQuality'),
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFF9B9089),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // FEATURE CARD
  // ==============================================================

  static Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 14,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              const Color(0xFFE7DAD1),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.025),
            blurRadius: 7,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [

          Container(
            width: 42,
            height: 42,

            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFF3E0E9),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,

              color:
                  const Color(0xFF7A3E5D),

              size: 22,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            title,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF3D3530),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              fontSize: 10,
              height: 1.25,
              color:
                  Color(0xFF8A817B),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PROCESS ITEM
  // ==============================================================

  static Widget _buildProcessItem({
    required IconData icon,
    required String label,
  }) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [

        Container(
          width: 34,
          height: 34,

          decoration:
              BoxDecoration(
            color:
                Colors.white,

            shape:
                BoxShape.circle,

            border:
                Border.all(
              color:
                  const Color(0xFFD8C8BE),
            ),
          ),

          child: Icon(
            icon,

            size: 17,

            color:
                const Color(0xFF7B5144),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,

          style:
              const TextStyle(
            fontSize: 8,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 0.4,
            color:
                Color(0xFF766960),
          ),
        ),
      ],
    );
  }
}


// ==========================================================
// CLEAN ONION LOGO ILLUSTRATION
// ==========================================================

class OnionLogoIllustration extends StatelessWidget {
  const OnionLogoIllustration({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(
        160,
        190,
      ),
      painter: OnionLogoPainter(),
    );
  }
}


// ==========================================================
// ONION LOGO PAINTER
// ==========================================================

class OnionLogoPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final double centerX =
        size.width / 2;

    // --------------------------------------------------------
    // ONION COLORS
    // --------------------------------------------------------

    const Color darkPurple =
        Color(0xFF713653);

    const Color purple =
        Color(0xFF934C70);

    const Color lightPurple =
        Color(0xFFC87999);

    const Color cream =
        Color(0xFFFFF8F4);

    const Color stemBrown =
        Color(0xFF856048);

    // --------------------------------------------------------
    // SOFT BACKGROUND
    // --------------------------------------------------------

    final Paint backgroundPaint =
        Paint()
          ..color =
              const Color(0xFFF3E1E8);

    canvas.drawCircle(
      Offset(
        centerX,
        95,
      ),
      76,
      backgroundPaint,
    );

    // --------------------------------------------------------
    // SUBTLE INNER RING
    // --------------------------------------------------------

    final Paint ringPaint =
        Paint()
          ..color =
              const Color(0xFFE2C3CF)
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 1.5;

    canvas.drawCircle(
      Offset(
        centerX,
        95,
      ),
      67,
      ringPaint,
    );

    // ========================================================
    // DRIED ONION STEM
    // ========================================================

    final Paint stemPaint =
        Paint()
          ..color = stemBrown
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap =
              StrokeCap.round;

    // Main stem
    final Path mainStem =
        Path();

    mainStem.moveTo(
      centerX,
      50,
    );

    mainStem.cubicTo(
      centerX - 2,
      40,
      centerX + 5,
      29,
      centerX + 2,
      17,
    );

    canvas.drawPath(
      mainStem,
      stemPaint,
    );

    // Left stem
    final Path leftStem =
        Path();

    leftStem.moveTo(
      centerX,
      33,
    );

    leftStem.cubicTo(
      centerX - 8,
      28,
      centerX - 12,
      22,
      centerX - 10,
      16,
    );

    canvas.drawPath(
      leftStem,
      stemPaint,
    );

    // Right stem
    final Path rightStem =
        Path();

    rightStem.moveTo(
      centerX + 1,
      31,
    );

    rightStem.cubicTo(
      centerX + 8,
      27,
      centerX + 12,
      21,
      centerX + 11,
      15,
    );

    canvas.drawPath(
      rightStem,
      stemPaint,
    );

    // ========================================================
    // MAIN ONION BODY
    // ========================================================

    final Path onion =
        Path();

    onion.moveTo(
      centerX,
      44,
    );

    onion.cubicTo(
      centerX - 13,
      49,
      centerX - 45,
      63,
      centerX - 50,
      98,
    );

    onion.cubicTo(
      centerX - 54,
      130,
      centerX - 32,
      157,
      centerX,
      166,
    );

    onion.cubicTo(
      centerX + 32,
      157,
      centerX + 54,
      130,
      centerX + 50,
      98,
    );

    onion.cubicTo(
      centerX + 45,
      63,
      centerX + 13,
      49,
      centerX,
      44,
    );

    onion.close();

    // ========================================================
    // ONION GRADIENT
    // ========================================================

    final Paint onionPaint =
        Paint()
          ..shader =
              const LinearGradient(
            begin:
                Alignment.topLeft,
            end:
                Alignment.bottomRight,
            colors: [
              lightPurple,
              purple,
              darkPurple,
            ],
          ).createShader(
            Rect.fromLTWH(
              45,
              40,
              70,
              130,
            ),
          );

    canvas.drawPath(
      onion,
      onionPaint,
    );

    // ========================================================
    // ONION OUTLINE
    // ========================================================

    final Paint outlinePaint =
        Paint()
          ..color =
              darkPurple
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 3.2;

    canvas.drawPath(
      onion,
      outlinePaint,
    );

    // ========================================================
    // LEFT INNER ONION LAYER
    // ========================================================

    final Paint layerPaint =
        Paint()
          ..color = cream
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap =
              StrokeCap.round;

    final Path leftLayer =
        Path();

    leftLayer.moveTo(
      centerX - 2,
      56,
    );

    leftLayer.cubicTo(
      centerX - 12,
      68,
      centerX - 29,
      82,
      centerX - 31,
      105,
    );

    leftLayer.cubicTo(
      centerX - 33,
      127,
      centerX - 19,
      147,
      centerX - 2,
      156,
    );

    canvas.drawPath(
      leftLayer,
      layerPaint,
    );

    // ========================================================
    // RIGHT INNER ONION LAYER
    // ========================================================

    final Path rightLayer =
        Path();

    rightLayer.moveTo(
      centerX + 2,
      56,
    );

    rightLayer.cubicTo(
      centerX + 12,
      68,
      centerX + 29,
      82,
      centerX + 31,
      105,
    );

    rightLayer.cubicTo(
      centerX + 33,
      127,
      centerX + 19,
      147,
      centerX + 2,
      156,
    );

    canvas.drawPath(
      rightLayer,
      layerPaint,
    );

    // ========================================================
    // INNER ONION LAYER
    // ========================================================

    final Path innerLayer =
        Path();

    innerLayer.moveTo(
      centerX,
      64,
    );

    innerLayer.cubicTo(
      centerX - 7,
      78,
      centerX - 18,
      89,
      centerX - 19,
      108,
    );

    innerLayer.cubicTo(
      centerX - 20,
      127,
      centerX - 10,
      143,
      centerX,
      152,
    );

    innerLayer.cubicTo(
      centerX + 10,
      143,
      centerX + 20,
      127,
      centerX + 19,
      108,
    );

    innerLayer.cubicTo(
      centerX + 18,
      89,
      centerX + 7,
      78,
      centerX,
      64,
    );

    canvas.drawPath(
      innerLayer,
      layerPaint,
    );

    // ========================================================
    // CENTER ONION LINE
    // ========================================================

    final Paint centerPaint =
        Paint()
          ..color = cream
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap =
              StrokeCap.round;

    final Path centerLine =
        Path();

    centerLine.moveTo(
      centerX,
      57,
    );

    centerLine.cubicTo(
      centerX - 1,
      82,
      centerX - 1,
      124,
      centerX,
      153,
    );

    canvas.drawPath(
      centerLine,
      centerPaint,
    );

    // ========================================================
    // ONION ROOT
    // ========================================================

    final Paint rootPaint =
        Paint()
          ..color = stemBrown
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap =
              StrokeCap.round;

    final Path rootLeft =
        Path();

    rootLeft.moveTo(
      centerX,
      155,
    );

    rootLeft.quadraticBezierTo(
      centerX - 7,
      163,
      centerX - 12,
      167,
    );

    final Path rootRight =
        Path();

    rootRight.moveTo(
      centerX,
      155,
    );

    rootRight.quadraticBezierTo(
      centerX + 7,
      163,
      centerX + 12,
      167,
    );

    canvas.drawPath(
      rootLeft,
      rootPaint,
    );

    canvas.drawPath(
      rootRight,
      rootPaint,
    );

    // ========================================================
    // CENTER ROOT
    // ========================================================

    final Path rootCenter =
        Path();

    rootCenter.moveTo(
      centerX,
      155,
    );

    rootCenter.lineTo(
      centerX,
      168,
    );

    canvas.drawPath(
      rootCenter,
      rootPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

