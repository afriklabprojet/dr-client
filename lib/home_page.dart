import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'core/constants/app_colors.dart';
import 'config/providers.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/products/presentation/pages/products_list_page.dart';
import 'features/orders/presentation/pages/cart_page.dart';
import 'features/orders/presentation/pages/orders_list_page.dart';
import 'features/orders/presentation/providers/cart_provider.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'features/pharmacies/presentation/pages/pharmacies_list_page_v2.dart';
import 'features/pharmacies/presentation/pages/pharmacy_details_page.dart';
import 'features/pharmacies/presentation/pages/on_duty_pharmacies_map_page.dart';
import 'features/pharmacies/presentation/providers/pharmacies_state.dart';
import 'features/prescriptions/presentation/pages/prescription_upload_page.dart';
import 'features/prescriptions/presentation/pages/prescriptions_list_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _promoPageController = PageController();
  final PageController _pharmacyPageController = PageController();
  Timer? _promoTimer;
  Timer? _pharmacyTimer;
  int _currentPromoIndex = 0;
  int _currentPharmacyIndex = 0;

  final List<PromoItem> _promoItems = [
    PromoItem(
      badge: 'Nouveau',
      title: 'Livraison Gratuite',
      subtitle: 'Sur votre première commande',
      gradientColors: [AppColors.primary, AppColors.primaryDark],
    ),
    PromoItem(
      badge: '-20%',
      title: 'Vitamines & Compléments',
      subtitle: 'Profitez des promotions santé',
      gradientColors: [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
    ),
    PromoItem(
      badge: 'Pharmacie de garde',
      title: 'Service 24h/24',
      subtitle: 'Trouvez une pharmacie ouverte près de vous',
      gradientColors: [const Color(0xFFFF5722), const Color(0xFFE64A19)],
      actionType: 'onDuty',
    ),
    PromoItem(
      badge: 'Ordonnance',
      title: 'Envoyez votre ordonnance',
      subtitle: 'Recevez vos médicaments à domicile',
      gradientColors: [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      actionType: 'prescription',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startPromoTimer();
    // Load featured pharmacies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pharmaciesProvider.notifier).fetchFeaturedPharmacies();
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _pharmacyTimer?.cancel();
    _promoPageController.dispose();
    _pharmacyPageController.dispose();
    super.dispose();
  }

  void _startPharmacyTimer(int pharmacyCount) {
    _pharmacyTimer?.cancel();
    if (pharmacyCount <= 1) return;
    
    _pharmacyTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pharmacyPageController.hasClients) {
        _currentPharmacyIndex = (_currentPharmacyIndex + 1) % pharmacyCount;
        _pharmacyPageController.animateToPage(
          _currentPharmacyIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoPageController.hasClients) {
        _currentPromoIndex = (_currentPromoIndex + 1) % _promoItems.length;
        _promoPageController.animateToPage(
          _currentPromoIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cartState = ref.watch(cartProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, ref, cartState, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(user?.name, isDark),
                  const SizedBox(height: 32),
                  _buildFeaturedPharmaciesSection(context, ref, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Services', isDark),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context, isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('À la une', isDark),
                  const SizedBox(height: 16),
                  _buildPromoSlider(context, isDark),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    WidgetRef ref,
    dynamic cartState,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50],
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_pharmacy_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'DR-PHARMA',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        _buildNotificationButton(context, ref, isDark),
        _buildCartButton(context, cartState, isDark),
        _buildProfileMenu(context, ref, isDark),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
        ),
        Consumer(
          builder: (context, ref, _) {
            final unreadCount = ref.watch(unreadCountProvider);
            if (unreadCount > 0) {
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildCartButton(
    BuildContext context,
    dynamic cartState,
    bool isDark,
  ) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_bag_outlined,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CartPage()));
          },
        ),
        if (cartState.itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '${cartState.itemCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, WidgetRef ref, bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 40),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
        } else if (value == 'orders') {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const OrdersListPage()));
        } else if (value == 'logout') {
          ref.read(authProvider.notifier).logout();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('Mon Profil'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'orders',
          child: Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 20),
              SizedBox(width: 12),
              Text('Mes Commandes'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(String? userName, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour,',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName ?? 'Client',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ProductsListPage()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey[400] : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Rechercher un médicament...',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _QuickActionCard(
          icon: Icons.medication_outlined,
          title: 'Produits',
          subtitle: 'Parcourir le catalogue',
          color: AppColors.primary,
          isDark: isDark,
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProductsListPage()));
          },
        ),
        _QuickActionCard(
          icon: Icons.emergency_outlined,
          title: 'Garde',
          subtitle: 'Pharmacies de garde',
          color: const Color(0xFFFF5722),
          isDark: isDark,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OnDutyPharmaciesMapPage()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.local_pharmacy_outlined,
          title: 'Pharmacies',
          subtitle: 'Trouver à proximité',
          color: AppColors.accent,
          isDark: isDark,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PharmaciesListPageV2()),
            );
          },
        ),
        _QuickActionCard(
          icon: Icons.upload_file_outlined,
          title: 'Ordonnance',
          subtitle: 'Mes ordonnances',
          color: const Color(0xFF9C27B0),
          isDark: isDark,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrescriptionsListPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPromoSlider(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _promoPageController,
            onPageChanged: (index) {
              setState(() {
                _currentPromoIndex = index;
              });
            },
            itemCount: _promoItems.length,
            itemBuilder: (context, index) {
              final promo = _promoItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPromoCard(promo, isDark),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promoItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPromoIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPromoIndex == index
                    ? AppColors.primary
                    : (isDark ? Colors.grey[600] : Colors.grey[300]),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePromoTap(PromoItem promo) {
    switch (promo.actionType) {
      case 'onDuty':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OnDutyPharmaciesMapPage()),
        );
        break;
      case 'prescription':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PrescriptionUploadPage()),
        );
        break;
      default:
        // No action for other promo cards
        break;
    }
  }

  Widget _buildPromoCard(PromoItem promo, bool isDark) {
    return GestureDetector(
      onTap: promo.actionType != null ? () => _handlePromoTap(promo) : null,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: promo.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: promo.gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            promo.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          promo.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo.subtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (promo.actionType != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        promo.actionType == 'onDuty'
                            ? Icons.map_outlined
                            : Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
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

  Widget _buildFeaturedPharmaciesSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final pharmaciesState = ref.watch(pharmaciesProvider);
    final pharmacies = pharmaciesState.featuredPharmacies;

    // Start auto-scroll timer when pharmacies are loaded
    if (pharmacies.isNotEmpty && _pharmacyTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startPharmacyTimer(pharmacies.length);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pharmacies en Vedette',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PharmaciesListPageV2()),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Voir tout',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (pharmaciesState.status == PharmaciesStatus.loading &&
            pharmacies.isEmpty)
          _buildPharmaciesLoadingShimmer(isDark)
        else if (pharmacies.isEmpty)
          _buildNoPharmaciesWidget(isDark)
        else
          Column(
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _pharmacyPageController,
                  itemCount: pharmacies.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPharmacyIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final pharmacy = pharmacies[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildFeaturedPharmacyCard(context, pharmacy, isDark),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Page indicators (dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pharmacies.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPharmacyIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPharmacyIndex == index
                          ? Colors.amber
                          : (isDark ? Colors.grey[600] : Colors.grey[300]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPharmaciesLoadingShimmer(bool isDark) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoPharmaciesWidget(bool isDark) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_pharmacy_outlined,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des pharmacies...',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                ref.read(pharmaciesProvider.notifier).fetchFeaturedPharmacies();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Actualiser',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildFeaturedPharmacyCard(
    BuildContext context,
    dynamic pharmacy,
    bool isDark,
  ) {
    // Generate gradient colors based on pharmacy id
    final colors = [
      [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
      [const Color(0xFF2196F3), const Color(0xFF1565C0)],
      [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)],
      [const Color(0xFFFF5722), const Color(0xFFD84315)],
      [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
    ];
    final gradientColors = colors[pharmacy.id % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PharmacyDetailsPage(pharmacyId: pharmacy.id),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left side - Icon and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Status badges
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: pharmacy.isOpen
                                    ? Colors.greenAccent.withValues(alpha: 0.3)
                                    : Colors.redAccent.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: pharmacy.isOpen
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    pharmacy.isOpen ? 'Ouvert' : 'Fermé',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (pharmacy.isOnDuty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_hospital_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Garde',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          pharmacy.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Address
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                pharmacy.address,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right side - Pharmacy icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy_rounded,
                      color: Colors.white,
                      size: 40,
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
}

// Data class for promo items
class PromoItem {
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String? actionType; // 'onDuty', 'prescription', etc.

  const PromoItem({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    this.actionType,
  });
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
