
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../localization/app_localizations.dart';

class MarketPricesPage extends StatefulWidget {
  const MarketPricesPage({super.key});

  @override
  State<MarketPricesPage> createState() => _MarketPricesPageState();
}

class _MarketPricesPageState extends State<MarketPricesPage> {
  List<dynamic> prices = [];

  bool isLoading = true;
  String? errorMessage;

  // Selected filter
  String selectedState = 'All States';

  // ============================================================
  // ONION THEME COLORS
  // ============================================================

  static const Color onionPurple = Color(0xFF7A3E5D);
  static const Color onionDarkPurple = Color(0xFF4A3029);
  static const Color onionPurpleLight = Color(0xFFF3E0E9);
  static const Color onionCream = Color(0xFFFCF6EF);
  static const Color onionBorder = Color(0xFFE6D5DC);
  static const Color onionBrown = Color(0xFF9A6040);
  static const Color onionText = Color(0xFF49312B);
  static const Color onionGrey = Color(0xFF7E6B64);

  @override
  void initState() {
    super.initState();
    loadMarketPrices();
  }

  // ============================================================
  // LOAD MARKET PRICES
  // ============================================================

  Future<void> loadMarketPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getMarketPrices();

      setState(() {
        prices = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // ============================================================
  // GET STATES
  // ============================================================

  List<String> getStates() {
    final states = prices
        .map((price) => price['state']?.toString() ?? '')
        .where((state) => state.isNotEmpty)
        .toSet()
        .toList();

    states.sort();

    return ['All States', ...states];
  }

  // ============================================================
  // FILTER PRICES
  // ============================================================

  List<dynamic> getFilteredPrices() {
    if (selectedState == 'All States') {
      return prices;
    }

    return prices.where((price) {
      return price['state']?.toString() == selectedState;
    }).toList();
  }

  // ============================================================
  // BUILD PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filteredPrices = getFilteredPrices();

    return Scaffold(
      backgroundColor: onionCream,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: onionCream,
        foregroundColor: onionDarkPurple,
        elevation: 0,
        centerTitle: false,

        title: Row(
          children: [
            const Text(
              '🧅',
              style: TextStyle(
                fontSize: 27,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              l.get('marketPrices'),
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: onionDarkPurple,
              ),
            ),
          ],
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: onionPurpleLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: l.get('refresh'),
              onPressed: loadMarketPrices,
              icon: const Icon(
                Icons.refresh_rounded,
                color: onionPurple,
              ),
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: onionPurple,
              ),
            )
          : errorMessage != null
              ? _buildError()
              : Column(
                  children: [

                    // =================================================
                    // HEADER CARD
                    // =================================================

                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        14,
                      ),
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7A3E5D),
                            Color(0xFF934C70),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: onionPurple.withOpacity(0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          // ONION ICON

                          Container(
                            width: 62,
                            height: 62,

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                              ),
                            ),

                            child: const Center(
                              child: Text(
                                '🧅',
                                style: TextStyle(
                                  fontSize: 34,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),

                          // HEADER TEXT

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  l.get('onionMandiPrices'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  l.get('latestMarketPrices'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // =================================================
                    // FILTER SECTION
                    // =================================================

                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: onionBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.025),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Row(
                            children: [

                              const Icon(
                                Icons.filter_alt_rounded,
                                size: 19,
                                color: onionPurple,
                              ),

                              const SizedBox(width: 7),

                              Text(
                                l.get('filterByState'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: onionText,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Container(
                            height: 50,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),

                            decoration: BoxDecoration(
                              color: onionCream,
                              borderRadius:
                                  BorderRadius.circular(13),
                              border: Border.all(
                                color: onionBorder,
                              ),
                            ),

                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedState,
                                isExpanded: true,

                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: onionPurple,
                                ),

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: onionText,
                                ),

                                items: getStates().map(
                                  (state) {
                                    return DropdownMenuItem<String>(
                                      value: state,
                                      child: Text(
                                        state == 'All States'
                                            ? l.get('allStates')
                                            : state,
                                      ),
                                    );
                                  },
                                ).toList(),

                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }

                                  setState(() {
                                    selectedState = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =================================================
                    // MARKET LIST
                    // =================================================

                    Expanded(
                      child: filteredPrices.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              color: onionPurple,
                              onRefresh: loadMarketPrices,

                              child: ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),

                                padding:
                                    const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  25,
                                ),

                                itemCount:
                                    filteredPrices.length,

                                itemBuilder:
                                    (context, index) {
                                  final price =
                                      filteredPrices[index];

                                  return _marketCard(price);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    final l = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Container(
              width: 86,
              height: 86,

              decoration: BoxDecoration(
                color: onionPurpleLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: onionBorder,
                ),
              ),

              child: const Center(
                child: Text(
                  '🧅',
                  style: TextStyle(
                    fontSize: 43,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              l.get('noMarketPrices'),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: onionText,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              l.get('noMarketPricesSelectedState'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: onionGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR WIDGET
  // ============================================================

  Widget _buildError() {
    final l = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

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
                border: Border.all(
                  color: const Color(0xFFE5C5C5),
                ),
              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: Color(0xFF9A4E4E),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l.get('unableToLoadMarketPrices'),
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: onionText,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              errorMessage!,
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: onionGrey,
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 48,

              child: ElevatedButton.icon(
                onPressed: loadMarketPrices,

                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                ),

                label: Text(
                  l.get('tryAgain').toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: onionPurple,
                  foregroundColor: Colors.white,
                  elevation: 2,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MARKET CARD
  // ============================================================

  Widget _marketCard(dynamic price) {
    final l = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
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
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ======================================================
            // MARKET INFORMATION
            // ======================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ONION / MARKET ICON

                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(0xFFF3E0E9),
                        Color(0xFFEBD2DD),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(15),

                    border: Border.all(
                      color: onionBorder,
                    ),
                  ),

                  child: const Center(
                    child: Text(
                      '🧅',
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 13),

                // MARKET NAME

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        price['market']?.toString() ??
                            l.get('unknownMarket'),

                        maxLines: 2,

                        overflow:
                            TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                          color: onionText,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: onionBrown,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              '${price['district'] ?? ''}, '
                              '${price['state'] ?? ''}',

                              style: const TextStyle(
                                fontSize: 13,
                                color: onionGrey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (price['variety'] != null &&
                          price['variety']
                              .toString()
                              .isNotEmpty) ...[
                        const SizedBox(height: 5),

                        Row(
                          children: [

                            const Icon(
                              Icons.eco_rounded,
                              size: 15,
                              color: onionPurple,
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                '${l.get('variety')}: '
                                '${price['variety']}',

                                style: const TextStyle(
                                  fontSize: 12,
                                  color: onionGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            // ======================================================
            // DIVIDER
            // ======================================================

            Container(
              height: 1,
              color: onionBorder,
            ),

            const SizedBox(height: 15),

            // ======================================================
            // PRICE SECTION
            // ======================================================

            Row(
              children: [

                Expanded(
                  child: _priceItem(
                    l.get('minimum'),
                    price['min_price'],
                  ),
                ),

                Container(
                  width: 1,
                  height: 42,
                  color: onionBorder,
                ),

                Expanded(
                  child: _priceItem(
                    l.get('modal'),
                    price['modal_price'],
                    highlight: true,
                  ),
                ),

                Container(
                  width: 1,
                  height: 42,
                  color: onionBorder,
                ),

                Expanded(
                  child: _priceItem(
                    l.get('maximum'),
                    price['max_price'],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ======================================================
            // ARRIVAL DATE
            // ======================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),

              decoration: BoxDecoration(
                color: onionCream,

                borderRadius:
                    BorderRadius.circular(11),

                border: Border.all(
                  color: onionBorder,
                ),
              ),

              child: Row(
                children: [

                  Container(
                    width: 30,
                    height: 30,

                    decoration: BoxDecoration(
                      color: onionPurpleLight,
                      borderRadius:
                          BorderRadius.circular(8),
                    ),

                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: onionPurple,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Text(
                    l.get('arrivalDate'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color: onionGrey,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${price['arrival_date'] ?? 'N/A'}',

                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.bold,
                      color: onionText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRICE ITEM
  // ============================================================

  Widget _priceItem(
    String label,
    dynamic value, {
    bool highlight = false,
  }) {
    final l = AppLocalizations.of(context);

    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [

        Text(
          label,

          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: onionGrey,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          '₹${value ?? 0}',

          maxLines: 1,

          overflow:
              TextOverflow.ellipsis,

          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,

            color: highlight
                ? onionPurple
                : onionText,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          l.get('perUnit'),
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

