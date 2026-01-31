import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart'; // Import pour notificationService
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import '../../../../home_page.dart';

/// Écran de connexion premium pour DR-PHARMA
/// Design moderne, minimaliste et professionnel
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _useEmail = false;
  bool _isRedirecting = false; // Track post-login operations

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Check authorization on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Prevent double-tap / multiple submissions
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.loading || _isRedirecting) {
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .login(
            email: _phoneController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  /// Convertit les messages d'erreur techniques en messages utilisateur explicites
  String _getReadableErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
    
    final errorLower = error.toLowerCase();
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Erreurs d'identifiants (401)
    // ═══════════════════════════════════════════════════════════════════════════
    if (errorLower.contains('invalid') || 
        errorLower.contains('credentials') ||
        errorLower.contains('incorrect') ||
        errorLower.contains('identifiants') ||
        errorLower.contains('unauthorized') ||
        errorLower.contains('401')) {
      return 'Email ou mot de passe invalide.\nVeuillez vérifier vos identifiants.';
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Compte non trouvé
    // ═══════════════════════════════════════════════════════════════════════════
    if (errorLower.contains('not found') || 
        errorLower.contains('introuvable') ||
        errorLower.contains('n\'existe pas') ||
        errorLower.contains('no user')) {
      return 'Aucun compte n\'existe avec cet email.\nVeuillez créer un compte ou vérifier votre saisie.';
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Compte désactivé/suspendu
    // ═══════════════════════════════════════════════════════════════════════════
    if (errorLower.contains('disabled') || 
        errorLower.contains('suspended') ||
        errorLower.contains('blocked') ||
        errorLower.contains('désactivé') ||
        errorLower.contains('suspendu') ||
        errorLower.contains('bloqué')) {
      return 'Votre compte a été désactivé.\nVeuillez contacter le support pour plus d\'informations.';
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Erreurs réseau
    // ═══════════════════════════════════════════════════════════════════════════
    if (errorLower.contains('network') || 
        errorLower.contains('connexion') ||
        errorLower.contains('internet') ||
        errorLower.contains('timeout') ||
        errorLower.contains('socket') ||
        errorLower.contains('connection')) {
      return 'Problème de connexion internet.\nVérifiez votre connexion et réessayez.';
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Erreurs serveur
    // ═══════════════════════════════════════════════════════════════════════════
    if (errorLower.contains('server') || 
        errorLower.contains('500') ||
        errorLower.contains('503') ||
        errorLower.contains('serveur')) {
      return 'Le service est temporairement indisponible.\nVeuillez réessayer dans quelques instants.';
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Erreurs de validation
    // ═══════════════════════════════════════════════════════════════════════════
    if (errorLower.contains('validation') || 
        errorLower.contains('required') ||
        errorLower.contains('format')) {
      return 'Les informations saisies sont incorrectes.\nVeuillez vérifier le format de votre email et mot de passe.';
    }
    
    // ═══════════════════════════════════════════════════════════════════════════
    // Trop de tentatives
    // ═══════════════════════════════════════════════════════════════════════════
    if (errorLower.contains('too many') || 
        errorLower.contains('rate limit') ||
        errorLower.contains('throttle') ||
        errorLower.contains('tentatives')) {
      return 'Trop de tentatives de connexion.\nVeuillez patienter quelques minutes avant de réessayer.';
    }
    
    // Message par défaut si aucun pattern ne correspond
    // Mais on évite d'afficher l'erreur technique brute
    return 'Les identifiants fournis sont incorrects.\nVeuillez vérifier votre email et mot de passe.';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) async {
      if (next.status == AuthStatus.authenticated && !_isRedirecting) {
        // Prevent multiple redirections and keep loader visible
        // Use immediate setState to ensure UI updates before async operations
        if (mounted) {
          setState(() => _isRedirecting = true);
        }
        
        // Small delay to ensure UI shows loading state
        await Future.delayed(const Duration(milliseconds: 50));
        
        try {
          // Initialiser les notifications après authentification
          await ref.read(notificationServiceProvider).initNotifications();
        } catch (e) {
          // Continue even if notification init fails
          debugPrint('Notification init error: $e');
        }

        if (mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else if (next.status == AuthStatus.error) {
        // Reset redirecting state on error
        if (_isRedirecting && mounted) {
          setState(() => _isRedirecting = false);
        }
        if (mounted) {
          // Convertir le message technique en message utilisateur explicite
          final userFriendlyMessage = _getReadableErrorMessage(next.errorMessage);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(userFriendlyMessage),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50],
        body: Stack(
          children: [
            // Background Design
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                _buildHeader(isDark),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16213E) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 10),
                                  Center(
                                    child: Container(
                                      width: 50,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    'Bon retour !',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Connectez-vous pour continuer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 30),

                                  // Toggle Phone/Email
                                  _buildToggleMethod(isDark),
                                  const SizedBox(height: 24),

                                  // Phone/Email Field
                                  _buildPhoneField(isDark),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  _buildPasswordField(isDark),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ForgotPasswordPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Mot de passe oublié ?',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Login Button
                                  _buildLoginButton(authState, isDark),

                                  const SizedBox(height: 24),

                                  // Security Badge
                                  _buildSecurityBadge(isDark),

                                  const SizedBox(height: 24),

                                  // Register Link
                                  _buildRegisterLink(),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
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
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.local_pharmacy_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'DR-PHARMA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleMethod(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Téléphone',
              isSelected: !_useEmail,
              onTap: () => setState(() => _useEmail = false),
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Email',
              isSelected: _useEmail,
              onTap: () => setState(() => _useEmail = true),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? Colors.white54 : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isDark = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.grey[400] : AppColors.primary,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return _buildTextField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      label: _useEmail ? 'Adresse email' : 'Numéro de téléphone',
      icon: _useEmail ? Icons.email_outlined : Icons.phone_android_rounded,
      isDark: isDark,
      keyboardType: _useEmail
          ? TextInputType.emailAddress
          : TextInputType.phone,
      inputFormatters: _useEmail
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _useEmail ? 'Email requis' : 'Numéro requis';
        }
        if (_useEmail && !value.contains('@')) {
          return 'Email invalide';
        }
        if (!_useEmail && value.length < 8) {
          return 'Numéro invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return _buildTextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      label: 'Mot de passe',
      icon: Icons.lock_outline_rounded,
      isDark: isDark,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: isDark ? Colors.white54 : Colors.grey[600],
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Mot de passe requis';
        }
        if (value.length < 6) {
          return 'Minimum 6 caractères';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(AuthState authState, bool isDark) {
    // Show loader during login AND during post-login operations (redirecting)
    final isLoading = authState.status == AuthStatus.loading || _isRedirecting;
    final loadingText = _isRedirecting ? 'Connexion...' : null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      if (loadingText != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          loadingText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : AppColors.primary).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user,
            size: 18,
            color: isDark ? Colors.white70 : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Connexion sécurisée',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: TextStyle(
            color: isDark ? Colors.white60 : AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
          },
          child: Text(
            'Créer un compte',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
