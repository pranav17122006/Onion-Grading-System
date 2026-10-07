
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../localization/app_localizations.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ============================================================
  // LOGIN FUNCTIONALITY
  // ============================================================
Future<void> _loginUser() async {
  final l = AppLocalizations.of(context);

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    debugPrint('================================');
    debugPrint('LOGIN SUCCESS');
    debugPrint('UID: ${credential.user?.uid}');
    debugPrint('EMAIL: ${credential.user?.email}');
    debugPrint('================================');

    if (!mounted) return;

    // LoginPage was opened from WelcomePage.
    // Remove LoginPage and reveal AuthGate.
    Navigator.of(context).popUntil((route) => route.isFirst);

  } on FirebaseAuthException catch (e) {
    debugPrint('================================');
    debugPrint('LOGIN FAILED');
    debugPrint('CODE: ${e.code}');
    debugPrint('MESSAGE: ${e.message}');
    debugPrint('================================');

    String message;

    switch (e.code) {
      case 'invalid-credential':
        message = l.get('invalidEmailPassword');
        break;

      case 'invalid-email':
        message = l.get('invalidEmail');
        break;

      case 'user-not-found':
        message = l.get('userNotFound');
        break;

      case 'wrong-password':
        message = l.get('wrongPassword');
        break;

      case 'user-disabled':
        message = l.get('userDisabled');
        break;

      case 'too-many-requests':
        message = l.get('tooManyAttempts');
        break;

      case 'network-request-failed':
        message = l.get('networkError');
        break;

      default:
        // Include Firebase error code while debugging.
        message = '${l.get('loginFailed')} (${e.code})';
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9A4E4E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  } catch (e) {
    debugPrint('UNEXPECTED LOGIN ERROR: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l.get('loginFailed')} $e',
        ),
        backgroundColor: const Color(0xFF9A4E4E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _forgotPassword() async {
    final l = AppLocalizations.of(context);

    final email =
        _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.get('enterEmailFirst'),
          ),

          backgroundColor:
              const Color(0xFF7A3E5D),

          behavior:
              SnackBarBehavior.floating,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l.get('passwordResetSent'),
          ),

          backgroundColor:
              const Color(0xFF7A3E5D),

          behavior:
              SnackBarBehavior.floating,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = l.get('invalidEmail');
          break;

        case 'user-not-found':
          message = l.get('userNotFound');
          break;

        default:
          message = l.get('resetEmailFailed');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),

          backgroundColor:
              const Color(0xFF9A4E4E),

          behavior:
              SnackBarBehavior.floating,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final size =
        MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          const Color(0xFFFCF6EF),

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),

          child: ConstrainedBox(
            constraints:
                BoxConstraints(
              minHeight:
                  size.height -
                      MediaQuery.of(context)
                          .padding
                          .top -
                      MediaQuery.of(context)
                          .padding
                          .bottom,
            ),

            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),

                    // ==================================================
                    // TOP BAR
                    // ==================================================

                    Align(
                      alignment:
                          Alignment.centerLeft,

                      child: Material(
                        color:
                            Colors.transparent,

                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),

                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },

                          child: Container(
                            width: 46,
                            height: 46,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),

                              border:
                                  Border.all(
                                color:
                                    const Color(
                                  0xFFE7DDD5,
                                ),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black
                                          .withOpacity(
                                    0.04,
                                  ),

                                  blurRadius:
                                      10,

                                  offset:
                                      const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),

                            child:
                                const Icon(
                              Icons
                                  .arrow_back_rounded,

                              color:
                                  Color(
                                0xFF49332F,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // ONION LOGO
                    // ==================================================

                    Container(
                      width: 92,
                      height: 92,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF3E0E9,
                        ),

                        shape:
                            BoxShape.circle,

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFD7B4C5,
                          ),

                          width: 1.5,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(
                              0xFF7A3E5D,
                            ).withOpacity(
                              0.10,
                            ),

                            blurRadius:
                                20,

                            offset:
                                const Offset(
                              0,
                              8,
                            ),
                          ),
                        ],
                      ),

                      child: Center(
                        child: Container(
                          width: 70,
                          height: 70,

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,

                            shape:
                                BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black
                                        .withOpacity(
                                  0.04,
                                ),

                                blurRadius:
                                    8,
                              ),
                            ],
                          ),

                          child:
                              const Center(
                            child: Text(
                              '🧅',

                              style:
                                  TextStyle(
                                fontSize:
                                    42,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    Text(
                      l.get(
                        'welcomeBack',
                      ),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 28,

                        fontWeight:
                            FontWeight.w800,

                        color:
                            Color(
                          0xFF2F2926,
                        ),

                        letterSpacing:
                            -0.5,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      l.get(
                        'loginContinue',
                      ),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 14.5,

                        color:
                            Color(
                          0xFF7E6B64,
                        ),

                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // ==================================================
                    // EMAIL LABEL
                    // ==================================================

                    Align(
                      alignment:
                          Alignment.centerLeft,

                      child: Text(
                        l.get('email'),

                        style:
                            const TextStyle(
                          fontSize: 14,

                          fontWeight:
                              FontWeight.w700,

                          color:
                              Color(
                            0xFF49332F,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    // ==================================================
                    // EMAIL FIELD
                    // ==================================================

                    TextFormField(
                      controller:
                          _emailController,

                      keyboardType:
                          TextInputType
                              .emailAddress,

                      textInputAction:
                          TextInputAction.next,

                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value
                                .trim()
                                .isEmpty) {
                          return l.get(
                            'enterEmail',
                          );
                        }

                        if (!value
                            .contains('@')) {
                          return l.get(
                            'invalidEmail',
                          );
                        }

                        return null;
                      },

                      decoration:
                          InputDecoration(
                        hintText:
                            l.get(
                          'enterEmail',
                        ),

                        hintStyle:
                            const TextStyle(
                          color:
                              Color(
                            0xFFB0A19A,
                          ),

                          fontSize: 14,
                        ),

                        prefixIcon:
                            Container(
                          margin:
                              const EdgeInsets
                                  .all(
                            10,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF3E0E9,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              9,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .email_outlined,

                            size: 20,

                            color:
                                Color(
                              0xFF7A3E5D,
                            ),
                          ),
                        ),

                        filled:
                            true,

                        fillColor:
                            Colors.white,

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              16,

                          vertical:
                              17,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFE6D8CF,
                            ),
                          ),
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFE6D8CF,
                            ),
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFF7A3E5D,
                            ),

                            width: 1.5,
                          ),
                        ),

                        errorBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFB45C5C,
                            ),
                          ),
                        ),

                        focusedErrorBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFB45C5C,
                            ),

                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // PASSWORD LABEL
                    // ==================================================

                    Align(
                      alignment:
                          Alignment.centerLeft,

                      child: Text(
                        l.get(
                          'password',
                        ),

                        style:
                            const TextStyle(
                          fontSize: 14,

                          fontWeight:
                              FontWeight.w700,

                          color:
                              Color(
                            0xFF49332F,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    // ==================================================
                    // PASSWORD FIELD
                    // ==================================================

                    TextFormField(
                      controller:
                          _passwordController,

                      obscureText:
                          _obscurePassword,

                      textInputAction:
                          TextInputAction.done,

                      onFieldSubmitted:
                          (_) {
                        if (!_isLoading) {
                          _loginUser();
                        }
                      },

                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value.isEmpty) {
                          return l.get(
                            'enterPassword',
                          );
                        }

                        return null;
                      },

                      decoration:
                          InputDecoration(
                        hintText:
                            l.get(
                          'enterPassword',
                        ),

                        hintStyle:
                            const TextStyle(
                          color:
                              Color(
                            0xFFB0A19A,
                          ),

                          fontSize: 14,
                        ),

                        prefixIcon:
                            Container(
                          margin:
                              const EdgeInsets
                                  .all(
                            10,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF5E3D4,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              9,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .lock_outline_rounded,

                            size: 20,

                            color:
                                Color(
                              0xFF9A6040,
                            ),
                          ),
                        ),

                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },

                          icon:
                              Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,

                            color:
                                const Color(
                              0xFF8C7870,
                            ),
                          ),
                        ),

                        filled:
                            true,

                        fillColor:
                            Colors.white,

                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              16,

                          vertical:
                              17,
                        ),

                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFE6D8CF,
                            ),
                          ),
                        ),

                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFE6D8CF,
                            ),
                          ),
                        ),

                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFF9A6040,
                            ),

                            width: 1.5,
                          ),
                        ),

                        errorBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFB45C5C,
                            ),
                          ),
                        ),

                        focusedErrorBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),

                          borderSide:
                              const BorderSide(
                            color:
                                Color(
                              0xFFB45C5C,
                            ),

                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // FORGOT PASSWORD
                    // ==================================================

                    Align(
                      alignment:
                          Alignment.centerRight,

                      child: TextButton(
                        onPressed:
                            _forgotPassword,

                        style:
                            TextButton.styleFrom(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                        ),

                        child: Text(
                          l.get(
                            'forgotPassword',
                          ),

                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF7A3E5D,
                            ),

                            fontSize: 13.5,

                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ==================================================
                    // LOGIN BUTTON
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,

                      height: 55,

                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _loginUser,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF7A3E5D,
                          ),

                          disabledBackgroundColor:
                              const Color(
                            0xFFC8AAB9,
                          ),

                          foregroundColor:
                              Colors.white,

                          elevation: 3,

                          shadowColor:
                              const Color(
                            0xFF7A3E5D,
                          ).withOpacity(
                            0.25,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),

                        child:
                            _isLoading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,

                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,

                                      valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(
                                        Colors
                                            .white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,

                                    children: [
                                      const Icon(
                                        Icons
                                            .login_rounded,

                                        size: 21,
                                      ),

                                      const SizedBox(
                                        width: 9,
                                      ),

                                      Text(
                                        l.get(
                                          'login',
                                        ).toUpperCase(),

                                        style:
                                            const TextStyle(
                                          fontSize:
                                              15,

                                          fontWeight:
                                              FontWeight
                                                  .w800,

                                          letterSpacing:
                                              0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    // ==================================================
                    // REGISTER LINK
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        Text(
                          l.get(
                            'dontHaveAccount',
                          ),

                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF7E6B64,
                            ),

                            fontSize: 13.5,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        const RegisterPage(),
                              ),
                            );
                          },

                          style:
                              TextButton.styleFrom(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 5,
                            ),
                          ),

                          child: Text(
                            l.get(
                              'register',
                            ),

                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF7A3E5D,
                              ),

                              fontSize: 13.5,

                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // ==================================================
                    // PROJECT FOOTER
                    // ==================================================

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFF3E0E9,
                        ).withOpacity(
                          0.55,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
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

                          const SizedBox(
                            width: 8,
                          ),

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                l.get(
                                  'appName',
                                ),

                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF49332F,
                                  ),

                                  fontSize:
                                      12,

                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 2,
                              ),

                              Text(
                                l.get(
                                  'smartSimpleReliable',
                                ),

                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFF8C7870,
                                  ),

                                  fontSize:
                                      10.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
