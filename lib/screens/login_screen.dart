import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

double _scale = 1;

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const Color blue = Color(0xFF005BAA);
  static const Color deepBlue = Color(0xFF003B73);
  static const Color green = Color(0xFF2F9E63);
  static const Color deepGreen = Color(0xFF145A32);
  static const Color bg = Color(0xFFF7FAFD);
  static const Color fieldBg = Color(0xFFF0F4F8);
  static const Color textDark = Color(0xFF14213D);
  static const Color textSoft = Color(0xFF7B8794);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await auth.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (success && mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  Future<void> _handleRegister(AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await auth.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirm: confirmPasswordController.text,
      );

      if (success && mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  void _switchMode() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      confirmPasswordController.clear();
      _controller
        ..reset()
        ..forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Stack(
              children: [
                _backgroundDecor(),
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 34),
                            _illustration(),
                            const SizedBox(height: 26),
                            Text(
                              isLogin ? 'Login' : 'Sign up',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: textDark,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isLogin
                                  ? 'Please login to continue.'
                                  : 'Create your account to continue.',
                              style: const TextStyle(
                                fontSize: 17,
                                color: textSoft,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 34),

                            if (!isLogin) ...[
                              _field(
                                controller: nameController,
                                hint: 'Enter your full name',
                                icon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez entrer votre nom';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Le nom est trop court';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),
                            ],

                            _field(
                              controller: emailController,
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Veuillez entrer votre e-mail';
                                }
                                if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return 'Veuillez entrer un e-mail valide';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            _field(
                              controller: passwordController,
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              onTogglePassword: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre mot de passe';
                                }
                                if (value.length < 6) {
                                  return '6 caractères minimum';
                                }
                                return null;
                              },
                            ),

                            if (!isLogin) ...[
                              const SizedBox(height: 18),
                              _field(
                                controller: confirmPasswordController,
                                hint: 'Confirm your password',
                                icon: Icons.verified_user_outlined,
                                isPassword: true,
                                obscureText: _obscureConfirmPassword,
                                onTogglePassword: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez confirmer le mot de passe';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                              ),
                            ],

                            if (isLogin) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: textDark,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              const SizedBox(height: 26),

                            const SizedBox(height: 16),
                            _mainButton(auth),
                            const SizedBox(height: 26),

                            Center(
                              child: TextButton(
                                onPressed: _switchMode,
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: textSoft,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: isLogin
                                            ? "Don't have an account? "
                                            : 'Already have an account? ',
                                      ),
                                      TextSpan(
                                        text: isLogin
                                            ? 'Register Now'
                                            : 'Login Now',
                                        style: const TextStyle(
                                          color: blue,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 34),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _backgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -80,
          child: _blob(
            size: 230,
            colors: [blue.withOpacity(0.18), green.withOpacity(0.12)],
          ),
        ),
        Positioned(
          top: 170,
          left: -95,
          child: _blob(
            size: 190,
            colors: [green.withOpacity(0.16), blue.withOpacity(0.08)],
          ),
        ),
        Positioned(
          bottom: -100,
          right: -90,
          child: _blob(
            size: 260,
            colors: [blue.withOpacity(0.13), green.withOpacity(0.15)],
          ),
        ),
      ],
    );
  }

  Widget _blob({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _illustration() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: blue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                left: 68,
                top: 28,
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: blue.withOpacity(0.16),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      bottom: 36,
                      right: 26,
                      child: Container(
                        width: 70,
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [blue, green]),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 42,
                      right: 38,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: bg,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 22,
                child: Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textDark.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: textDark,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: textSoft,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: textSoft),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: textSoft,
                ),
              )
            : null,
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 21,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: green, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 1.3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 1.3),
        ),
      ),
    );
  }

  Widget _mainButton(AuthService auth) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: auth.isLoading
          ? const Center(child: SpinKitThreeBounce(color: blue, size: 26))
          : AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 120),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _scale = 0.96),
                onTapUp: (_) => setState(() => _scale = 1),
                onTapCancel: () => setState(() => _scale = 1),
                child: ElevatedButton(
                  onPressed: () {
                    if (isLogin) {
                      _handleLogin(auth);
                    } else {
                      _handleRegister(auth);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [deepBlue, blue, green],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: blue.withOpacity(0.26),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: green.withOpacity(0.16),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isLogin ? 'Log In' : 'Sign Up',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
