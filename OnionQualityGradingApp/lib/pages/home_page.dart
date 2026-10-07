
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../localization/app_localizations.dart';

import 'market_prices_page.dart';
import 'upload_page.dart';
import 'welcome_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  final Future<void> Function(String languageCode)
      onLanguageChanged;

  const HomePage({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // ============================================================
  // LOAD USERNAME
  // ============================================================

  Future<void> _loadUserName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      String name = user.displayName?.trim() ?? '';

      try {
        final DocumentSnapshot<Map<String, dynamic>> document =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (document.exists) {
          final Map<String, dynamic>? data = document.data();

          final String firestoreName =
              data?['username']?.toString().trim() ?? '';

          if (firestoreName.isNotEmpty) {
            name = firestoreName;
          }
        }
      } catch (e) {
        debugPrint('Firestore username error: $e');
      }

      if (name.isEmpty) {
        final String email = user.email ?? '';

        if (email.contains('@')) {
          name = email.split('@').first;
        }
      }

      if (name.isEmpty) {
        name = 'User';
      }

      if (!mounted) return;

      setState(() {
        _userName = name;
      });
    } catch (e) {
      debugPrint('Username loading error: $e');
    }
  }

  // ============================================================
  // LANGUAGE SELECTOR
  // ============================================================

  Future<void> _showLanguageDialog() async {
    final l = AppLocalizations.of(context);

    final String currentLanguage =
        Localizations.localeOf(context).languageCode;

    final Map<String, String> languages = {
      'en': 'English',
      'ta': 'தமிழ்',
      'hi': 'हिन्दी',
      'te': 'తెలుగు',
      'ml': 'മലയാളം',
      'kn': 'ಕನ್ನಡ',
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFAF5),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Row(
            children: [
              const Icon(
                Icons.language_rounded,
                color: Color(0xFF7A3E5D),
              ),
              const SizedBox(width: 10),
              Text(
                l.get('language'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF49332F),
                ),
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.entries.map((entry) {
              final bool isSelected =
                  currentLanguage == entry.key;

              return ListTile(
                contentPadding: EdgeInsets.zero,

                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? const Color(0xFF7A3E5D)
                      : Colors.grey,
                ),

                title: Text(
                  entry.value,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: const Color(0xFF49332F),
                  ),
                ),

                onTap: () async {
                  Navigator.of(dialogContext).pop();

                  if (currentLanguage == entry.key) {
                    return;
                  }

                  await widget.onLanguageChanged(entry.key);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final l = AppLocalizations.of(context);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFAF5),

          title: Text(
            l.get('logout'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF49332F),
            ),
          ),

          content: Text(
            l.get('logoutConfirmation'),
            style: const TextStyle(
              color: Color(0xFF7E6B64),
            ),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },

              child: Text(
                l.get('cancel').toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF7A3E5D),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF7A3E5D),

                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),

              child: Text(
                l.get('logout').toUpperCase(),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      
      // Removed the Navigator.pushAndRemoveUntil block here!
      // AuthGate will automatically handle the routing.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l.get('logoutFailed')}: $e',
          ),
          backgroundColor:
              const Color(0xFF9A4E4E),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // OPEN UPLOAD PAGE
  // ============================================================

  void _openUploadPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UploadPage(),
      ),
    );
  }

  // ============================================================
  // OPEN MARKET PRICE PAGE
  // ============================================================

  void _openMarketPrices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MarketPricesPage(),
      ),
    );
  }

  // ============================================================
  // OPEN HISTORY PAGE
  // ============================================================

  void _openHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryPage(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          const Color(0xFFFCF6EF),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF7A3E5D),

        foregroundColor:
            Colors.white,

        elevation: 0,

        title: Row(
          children: [
            const Text(
              '🧅',
              style: TextStyle(
                fontSize: 25,
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Expanded(
              child: Text(
                l.get('appName'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        actions: [
          // --------------------------------------------------------
          // LANGUAGE
          // --------------------------------------------------------

          IconButton(
            onPressed:
                _showLanguageDialog,

            tooltip:
                l.get('language'),

            icon: const Icon(
              Icons.language_rounded,
            ),
          ),

          // --------------------------------------------------------
          // LOGOUT
          // --------------------------------------------------------

          IconButton(
            onPressed: _logout,

            tooltip:
                l.get('logout'),

            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          padding:
              const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ====================================================
              // WELCOME CARD
              // ====================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(22),

                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,

                    end:
                        Alignment.bottomRight,

                    colors: [
                      Color(0xFF5B3152),
                      Color(0xFF7A3E5D),
                      Color(0xFF9A6040),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF7A3E5D)
                              .withOpacity(0.22),

                      blurRadius: 18,

                      offset:
                          const Offset(0, 7),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ----------------------------------------------
                    // USER
                    // ----------------------------------------------

                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,

                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.17),

                            shape:
                                BoxShape.circle,

                            border:
                                Border.all(
                              color: Colors.white
                                  .withOpacity(0.22),
                            ),
                          ),

                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color:
                                  Colors.white,
                              size: 29,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                l.get(
                                  'welcomeBack',
                                ),

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white70,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(
                                height: 3,
                              ),

                              Text(
                                _userName,

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ------------------------------------------
                        // ONION
                        // ------------------------------------------

                        Container(
                          width: 52,
                          height: 52,

                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.15),

                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),

                            border:
                                Border.all(
                              color: Colors.white
                                  .withOpacity(0.12),
                            ),
                          ),

                          child:
                              const Center(
                            child: Text(
                              '🧅',
                              style:
                                  TextStyle(
                                fontSize: 29,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Text(
                      l.get(
                        'readyCheckQuality',
                      ),

                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      l.get(
                        'uploadAssessment',
                      ),

                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ----------------------------------------------
                    // PROCESS
                    // ----------------------------------------------

                    Row(
                      children: [
                        _processStep(
                          icon:
                              Icons.camera_alt_rounded,
                          text:
                              l.get('capture'),
                        ),

                        _processArrow(),

                        _processStep(
                          icon:
                              Icons.auto_awesome_rounded,
                          text:
                              l.get('analyze'),
                        ),

                        _processArrow(),

                        _processStep(
                          icon:
                              Icons.verified_rounded,
                          text:
                              l.get('grade'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ====================================================
              // SECTION TITLE
              // ====================================================

              Text(
                l.get(
                  'whatWouldYouLike',
                ),

                style:
                    const TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      Color(0xFF63364D),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // ====================================================
              // GRADE YOUR ONION
              // ====================================================

              _buildMainCard(
                icon:
                    Icons.camera_alt_rounded,

                title:
                    l.get('gradeYourOnion'),

                subtitle:
                    l.get(
                  'gradeYourOnionDescription',
                ),

                buttonText:
                    l.get('startGrading'),

                onPressed:
                    _openUploadPage,
              ),

              const SizedBox(
                height: 16,
              ),

              // ====================================================
              // MARKET + RESULTS
              // ====================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child:
                        _buildSmallCard(
                      icon:
                          Icons.currency_rupee_rounded,

                      title:
                          l.get('marketPrices'),

                      subtitle:
                          l.get(
                        'viewCurrentOnionPrices',
                      ),

                      onPressed:
                          _openMarketPrices,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child:
                        _buildSmallCard(
                      icon:
                          Icons.analytics_rounded,

                      title:
                          l.get('results'),

                      subtitle:
                          l.get(
                        'viewGradingHistory',
                      ),

                      onPressed:
                          _openHistoryPage,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              // ====================================================
              // QUALITY TIP
              // ====================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(18),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius.circular(19),

                  border:
                      Border.all(
                    color:
                        const Color(0xFFE5D2DC),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(0.035),

                      blurRadius: 10,

                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 46,
                      height: 46,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF3E0E9,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),

                      child:
                          const Center(
                        child: Text(
                          '🧅',
                          style:
                              TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            l.get(
                              'qualityTip',
                            ),

                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  Color(0xFF63364D),
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            l.get(
                              'qualityTipDescription',
                            ),

                            style:
                                const TextStyle(
                              fontSize: 13,
                              color:
                                  Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ====================================================
              // LOGOUT
              // ====================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child:
                    OutlinedButton.icon(
                  onPressed:
                      _logout,

                  icon:
                      const Icon(
                    Icons.logout_rounded,
                  ),

                  label:
                      Text(
                    l.get(
                      'logout',
                    ).toUpperCase(),

                    style:
                        const TextStyle(
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
                      color:
                          Color(0xFFD99B9B),
                    ),

                    backgroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // ====================================================
              // FOOTER
              // ====================================================

              Center(
                child: Text(
                  l.get(
                    'smartSimpleReliable',
                  ),

                  style:
                      const TextStyle(
                    color:
                        Colors.black38,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROCESS STEP
  // ============================================================

  Widget _processStep({
    required IconData icon,
    required String text,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.16,
              ),

              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              icon,

              color:
                  Colors.white,

              size: 19,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            text,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  Colors.white70,

              fontSize: 10,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROCESS ARROW
  // ============================================================

  Widget _processArrow() {
    return const Icon(
      Icons.arrow_forward_rounded,

      color:
          Colors.white54,

      size: 16,
    );
  }

  // ============================================================
  // MAIN CARD
  // ============================================================

  Widget _buildMainCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final l = AppLocalizations.of(context);

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border:
            Border.all(
          color:
              const Color(0xFFE4D4DC),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.045,
            ),

            blurRadius: 12,

            offset:
                const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFFF3E0E9),
                      Color(0xFFF6E7D8),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: Icon(
                  icon,

                  color:
                      const Color(
                    0xFF7A3E5D,
                  ),

                  size: 30,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      l.get(
                        'aiPoweredGrading',
                      ),

                      style:
                          const TextStyle(
                        color:
                            Color(0xFF7A3E5D),

                        fontSize: 11,

                        fontWeight:
                            FontWeight.w700,

                        letterSpacing: 0.4,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      l.get(
                        'onionQuality',
                      ),

                      style:
                          const TextStyle(
                        color:
                            Color(0xFF63364D),

                        fontSize: 20,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                '🧅',

                style:
                    TextStyle(
                  fontSize: 30,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            title,

            style:
                const TextStyle(
              fontSize: 18,

              fontWeight:
                  FontWeight.bold,

              color:
                  Color(0xFF49332F),
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            subtitle,

            style:
                const TextStyle(
              fontSize: 14,

              color:
                  Colors.black54,

              height: 1.4,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          SizedBox(
            width: double.infinity,
            height: 48,

            child:
                ElevatedButton.icon(
              onPressed:
                  onPressed,

              icon:
                  const Icon(
                Icons.camera_alt_rounded,
                size: 19,
              ),

              label:
                  Text(
                buttonText,

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,

                  letterSpacing: 0.3,
                ),
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF7A3E5D,
                ),

                foregroundColor:
                    Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL CARD
  // ============================================================

  Widget _buildSmallCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap:
          onPressed,

      borderRadius:
          BorderRadius.circular(18),

      child: Container(
        constraints:
            const BoxConstraints(
          minHeight: 170,
        ),

        padding:
            const EdgeInsets.all(16),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(18),

          border:
              Border.all(
            color:
                const Color(0xFFE4D4DC),
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.04,
              ),

              blurRadius: 10,

              offset:
                  const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 48,
              height: 48,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF3E0E9,
                ),

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child: Icon(
                icon,

                color:
                    const Color(
                  0xFF7A3E5D,
                ),

                size: 25,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              title,

              style:
                  const TextStyle(
                fontSize: 16,

                fontWeight:
                    FontWeight.bold,

                color:
                    Color(0xFF63364D),
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              subtitle,

              style:
                  const TextStyle(
                fontSize: 12,

                color:
                    Colors.black54,

                height: 1.3,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            const Align(
              alignment:
                  Alignment.bottomRight,

              child: Icon(
                Icons.arrow_forward_rounded,

                color:
                    Color(0xFF7A3E5D),

                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

