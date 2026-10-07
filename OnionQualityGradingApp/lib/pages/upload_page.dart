
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../localization/app_localizations.dart';
import '../services/api_service.dart';
import 'results_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();

  List<File> _images = [];

  bool _isAnalyzing = false;

  // ==========================================================
  // ONION COLORS
  // ==========================================================

  static const Color onionPurple = Color(0xFF7A3E5D);
  static const Color onionDark = Color(0xFF4A3029);
  static const Color onionPink = Color(0xFFF3E0E9);
  static const Color onionCream = Color(0xFFFCF6EF);
  static const Color onionBorder = Color(0xFFE6D5DC);
  static const Color onionBrown = Color(0xFF9A6040);
  static const Color onionText = Color(0xFF7E6B64);

  // ==========================================================
  // CAMERA
  // ==========================================================

  Future<void> _takePhoto() async {
    final l = AppLocalizations.of(context);

    if (_images.length >= 5) {
      _showMessage(
        l.get('maximumFivePhotos'),
      );
      return;
    }

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (photo == null) {
      return;
    }

    setState(() {
      _images.add(
        File(photo.path),
      );
    });
  }

  // ==========================================================
  // GALLERY
  // ==========================================================

  Future<void> _pickFromGallery() async {
    final l = AppLocalizations.of(context);

    final List<XFile> picked =
        await _picker.pickMultiImage(
      imageQuality: 90,
    );

    if (picked.isEmpty) {
      return;
    }

    final remaining = 5 - _images.length;

    if (remaining <= 0) {
      _showMessage(
        l.get('maximumFivePhotos'),
      );
      return;
    }

    final selected =
        picked.take(remaining).toList();

    setState(() {
      _images.addAll(
        selected.map(
          (image) => File(image.path),
        ),
      );
    });

    if (picked.length > remaining) {
      _showMessage(
        l.get('onlyFivePhotos'),
      );
    }
  }

  // ==========================================================
  // REMOVE PHOTO
  // ==========================================================

  void _removePhoto(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // ==========================================================
  // ANALYZE
  // ==========================================================

  Future<void> _analyze() async {
    final l = AppLocalizations.of(context);

    if (_images.isEmpty) {
      _showMessage(
        l.get('addAtLeastOnePhoto'),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result =
          await ApiService.analyzeImages(
        _images,
      );

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsPage(
            result: result,
            imagePaths: _images
                .map(
                  (image) => image.path,
                )
                .toList(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

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
                fontSize: 27,
              ),
            ),

            const SizedBox(width: 9),

            Text(
              l.get('uploadHeapPhotos'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: onionDark,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER DESCRIPTION
            // ==================================================

            Container(
              margin: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                10,
              ),

              padding: const EdgeInsets.all(18),

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
                    BorderRadius.circular(22),

                boxShadow: [
                  BoxShadow(
                    color:
                        onionPurple.withOpacity(0.14),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Row(
                children: [

                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),

                    child: const Center(
                      child: Text(
                        '🧅',
                        style: TextStyle(
                          fontSize: 33,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          l.get('analyzeYourOnionHeap'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          l.get('sameHeapDifferentAngles'),
                          style: const TextStyle(
                            fontSize: 12,
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

            // ==================================================
            // CAMERA + GALLERY
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isAnalyzing
                              ? null
                              : _takePhoto,

                      icon: const Icon(
                        Icons.camera_alt_rounded,
                      ),

                      label: Text(
                        l.get('camera').toUpperCase(),
                      ),

                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            onionPurple,

                        side: const BorderSide(
                          color: onionPurple,
                          width: 1.4,
                        ),

                        backgroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

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

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isAnalyzing
                              ? null
                              : _pickFromGallery,

                      icon: const Icon(
                        Icons.photo_library_rounded,
                      ),

                      label: Text(
                        l.get('gallery').toUpperCase(),
                      ),

                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            onionPurple,

                        side: const BorderSide(
                          color: onionPurple,
                          width: 1.4,
                        ),

                        backgroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

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
            ),

            // ==================================================
            // PHOTO COUNT
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 5,
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.collections_rounded,
                    size: 18,
                    color: onionPurple,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    '${_images.length}/5 ${l.get('photosSelected')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: onionDark,
                    ),
                  ),

                  const Spacer(),

                  if (_images.isNotEmpty)
                    Text(
                      l.get('tapToRemove'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: onionText,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ==================================================
            // IMAGE GRID
            // ==================================================

            Expanded(
              child: _images.isEmpty
                  ? _emptyUploadState()
                  : GridView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        12,
                      ),

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),

                      itemCount:
                          _images.length,

                      itemBuilder:
                          (context, index) {
                        return _imageTile(index);
                      },
                    ),
            ),

            // ==================================================
            // ANALYZE BUTTON
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                7,
                18,
                18,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton.icon(
                  onPressed:
                      _isAnalyzing
                          ? null
                          : _analyze,

                  icon: _isAnalyzing
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
                          Icons.analytics_rounded,
                        ),

                  label: Text(
                    _isAnalyzing
                        ? l.get('analyzing').toUpperCase()
                        : l.get('analyzeHeap').toUpperCase(),

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        onionPurple,

                    foregroundColor:
                        Colors.white,

                    disabledBackgroundColor:
                        Colors.grey.shade400,

                    elevation: 3,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY UPLOAD STATE
  // ==========================================================

  Widget _emptyUploadState() {
    final l = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFFFFFCF8),
            Color(0xFFF7E9EE),
          ],
        ),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: onionBorder,
          width: 1.5,
        ),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Container(
            width: 100,
            height: 100,

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

          const SizedBox(height: 20),

          Text(
            l.get('noPhotosSelected'),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: onionDark,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l.get('takePhotoOrChooseGallery'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: onionText,
              height: 1.5,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                color: onionBorder,
              ),
            ),

            child: Text(
              l.get('upToFivePhotos'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onionPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // IMAGE TILE
  // ==========================================================

  Widget _imageTile(int index) {
    final l = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(17),

        border: Border.all(
          color: onionBorder,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),

        child: Stack(
          fit: StackFit.expand,

          children: [

            Image.file(
              _images[index],
              fit: BoxFit.cover,
            ),

            // PHOTO NUMBER

            Positioned(
              left: 8,
              bottom: 8,

              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: onionPurple,
                  borderRadius:
                      BorderRadius.circular(9),
                ),

                child: Text(
                  '${l.get('photo')} ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // REMOVE BUTTON

            Positioned(
              top: 7,
              right: 7,

              child: Material(
                color: Colors.black54,

                shape: const CircleBorder(),

                child: InkWell(
                  customBorder:
                      const CircleBorder(),

                  onTap:
                      _isAnalyzing
                          ? null
                          : () =>
                              _removePhoto(index),

                  child: const Padding(
                    padding:
                        EdgeInsets.all(6),

                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

