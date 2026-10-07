
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../localization/app_localizations.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<void> _registerUser() async {
    final l = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final String username =
          _usernameController.text.trim();

      final String email =
          _emailController.text.trim();

      final String password =
          _passwordController.text;

      final UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user =
          userCredential.user;

      if (user == null) {
        throw Exception(
          l.get('unableToCreateAccount'),
        );
      }

      await user.updateDisplayName(
        username,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'username': username,
        'email': email,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l.get('accountCreatedLogin'),
          ),
          backgroundColor:
              const Color(0xFF7A3E5D),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginPage(),
        ),
      );
    }

    on FirebaseAuthException catch (e) {
      String message =
          l.get('registrationFailed');

      switch (e.code) {
        case 'email-already-in-use':
          message =
              l.get('emailAlreadyRegistered');
          break;

        case 'invalid-email':
          message =
              l.get('pleaseEnterValidEmail');
          break;

        case 'weak-password':
          message =
              l.get('passwordMinSix');
          break;

        case 'operation-not-allowed':
          message =
              l.get('emailPasswordAuthDisabled');
          break;

        case 'network-request-failed':
          message =
              l.get('checkInternet');
          break;

        default:
          message =
              e.message ??
              l.get('registrationFailed');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              const Color(0xFF9A4E4E),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }

    on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${l.get('databaseError')}: '
            '${e.message ?? l.get('unableToSaveUser')}',
          ),
          backgroundColor:
              const Color(0xFF9A4E4E),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }

    catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${l.get('somethingWentWrong')}: $e',
          ),
          backgroundColor:
              const Color(0xFF9A4E4E),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }

    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF49332F),
          ),

          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            5,
            24,
            30,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // =================================================
                // ONION LOGO
                // =================================================

                Center(
                  child: Container(
                    width: 90,
                    height: 90,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFF1DFE8),

                      shape:
                          BoxShape.circle,

                      border: Border.all(
                        color:
                            const Color(0xFFD7B4C5),
                        width: 1.5,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF7A3E5D)
                                  .withOpacity(0.12),
                          blurRadius: 18,
                          offset:
                              const Offset(0, 7),
                        ),
                      ],
                    ),

                    child: const Center(
                      child: Text(
                        '🧅',
                        style: TextStyle(
                          fontSize: 48,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // TITLE
                // =================================================

                Center(
                  child: Text(
                    l.get('createAccount'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF332C28),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    l.get('createAccountDescription'),
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color:
                          Color(0xFF83716A),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =================================================
                // USERNAME
                // =================================================

                Text(
                  l.get('username'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF49332F),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _usernameController,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      _inputDecoration(
                    hint:
                        l.get('enterUsername'),
                    icon:
                        Icons.person_outline_rounded,
                    iconColor:
                        const Color(0xFF7A3E5D),
                    iconBackground:
                        const Color(0xFFF1DFE8),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return l.get(
                        'enterUsernameValidation',
                      );
                    }

                    if (value.trim().length < 2) {
                      return l.get(
                        'usernameMinTwo',
                      );
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // EMAIL
                // =================================================

                Text(
                  l.get('email'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF49332F),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      _inputDecoration(
                    hint:
                        l.get('enterEmail'),
                    icon:
                        Icons.email_outlined,
                    iconColor:
                        const Color(0xFF7A3E5D),
                    iconBackground:
                        const Color(0xFFF3E0E9),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return l.get(
                        'enterEmailValidation',
                      );
                    }

                    final emailRegex =
                        RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!emailRegex.hasMatch(
                      value.trim(),
                    )) {
                      return l.get(
                        'validEmail',
                      );
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // PASSWORD
                // =================================================

                Text(
                  l.get('password'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF49332F),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _passwordController,

                  obscureText:
                      _hidePassword,

                  textInputAction:
                      TextInputAction.next,

                  decoration:
                      _inputDecoration(
                    hint:
                        l.get('enterPassword'),
                    icon:
                        Icons.lock_outline_rounded,
                    iconColor:
                        const Color(0xFF9A6040),
                    iconBackground:
                        const Color(0xFFF5E3D4),

                    suffix: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                        color:
                            const Color(0xFF8C7870),
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword =
                              !_hidePassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return l.get(
                        'enterPasswordValidation',
                      );
                    }

                    if (value.length < 6) {
                      return l.get(
                        'passwordMinSix',
                      );
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =================================================
                // CONFIRM PASSWORD
                // =================================================

                Text(
                  l.get('confirmPassword'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Color(0xFF49332F),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _confirmPasswordController,

                  obscureText:
                      _hideConfirmPassword,

                  textInputAction:
                      TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _registerUser();
                    }
                  },

                  decoration:
                      _inputDecoration(
                    hint:
                        l.get('confirmYourPassword'),
                    icon:
                        Icons.lock_outline_rounded,
                    iconColor:
                        const Color(0xFF9A6040),
                    iconBackground:
                        const Color(0xFFF5E3D4),

                    suffix: IconButton(
                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                        color:
                            const Color(0xFF8C7870),
                      ),
                      onPressed: () {
                        setState(() {
                          _hideConfirmPassword =
                              !_hideConfirmPassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return l.get(
                        'confirmPasswordValidation',
                      );
                    }

                    if (value !=
                        _passwordController.text) {
                      return l.get(
                        'passwordsDoNotMatch',
                      );
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // =================================================
                // CREATE ACCOUNT BUTTON
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _registerUser,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF7A3E5D),

                      disabledBackgroundColor:
                          const Color(0xFFC8AAB9),

                      foregroundColor:
                          Colors.white,

                      elevation: 2,

                      shadowColor:
                          const Color(0xFF7A3E5D)
                              .withOpacity(0.25),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color:
                                  Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              const Icon(
                                Icons
                                    .agriculture_rounded,
                                size: 21,
                              ),

                              const SizedBox(width: 9),

                              Text(
                                l.get('createAccount')
                                    .toUpperCase(),

                                style:
                                    const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                  letterSpacing:
                                      0.4,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // LOGIN LINK
                // =================================================

                Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Text(
                        l.get(
                          'alreadyHaveAccount',
                        ),
                        style: const TextStyle(
                          color:
                              Color(0xFF83716A),
                          fontSize: 13,
                        ),
                      ),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator
                                    .pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const LoginPage(),
                                  ),
                                );
                              },

                        child: Text(
                          l.get('login'),
                          style: const TextStyle(
                            color:
                                Color(0xFF7A3E5D),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // =================================================
                // PROJECT FOOTER
                // =================================================

                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFFF1DFE8)
                              .withOpacity(0.65),

                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        const Text(
                          '🧅',
                          style:
                              TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(width: 7),

                        Text(
                          l.get('appName'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Color(0xFF5D4740),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    l.get('smartSimpleReliable'),
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color:
                          Color(0xFFA2948D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT FIELD DESIGN
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xFFB0A19A),
        fontSize: 14,
      ),

      prefixIcon: Container(
        margin:
            const EdgeInsets.all(9),

        decoration:
            BoxDecoration(
          color: iconBackground,
          borderRadius:
              BorderRadius.circular(9),
        ),

        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),

      suffixIcon: suffix,

      filled: true,

      fillColor:
          Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 14,
      ),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Color(0xFFE7D9D0),
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Color(0xFFE7D9D0),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Color(0xFF7A3E5D),
          width: 1.5,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Color(0xFFB45C5C),
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(
          color: Color(0xFFB45C5C),
          width: 1.5,
        ),
      ),
    );
  }
}
