import 'package:flutter/material.dart';

/// Modèle pour les éléments promotionnels du slider
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

/// Liste des promotions par défaut
class PromoData {
  static const List<PromoItem> defaultPromos = [
    PromoItem(
      badge: 'Nouveau',
      title: 'Livraison Gratuite',
      subtitle: 'Sur votre première commande',
      gradientColors: [Color(0xFF00A86B), Color(0xFF008556)],
    ),
    PromoItem(
      badge: '-20%',
      title: 'Vitamines & Compléments',
      subtitle: 'Profitez des promotions santé',
      gradientColors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
    ),
    PromoItem(
      badge: 'Pharmacie de garde',
      title: 'Service 24h/24',
      subtitle: 'Trouvez une pharmacie ouverte près de vous',
      gradientColors: [Color(0xFFFF5722), Color(0xFFE64A19)],
      actionType: 'onDuty',
    ),
    PromoItem(
      badge: 'Ordonnance',
      title: 'Envoyez votre ordonnance',
      subtitle: 'Recevez vos médicaments à domicile',
      gradientColors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
      actionType: 'prescription',
    ),
  ];
}
