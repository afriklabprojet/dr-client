# 📦 Feature Commandes (Orders) - Documentation

## 📋 Vue d'ensemble

La feature **Commandes** permet aux clients de :

- Gérer leur panier d'achats
- Passer des commandes
- Consulter l'historique de leurs commandes
- Voir les détails d'une commande
- Annuler une commande (si elle est annulable)

---

## ✅ Statut : **COMPLÈTEMENT IMPLÉMENTÉE**

---

## 🎯 Fonctionnalités disponibles

### 1. **Panier (Cart)**

- ✅ Ajouter des produits au panier
- ✅ Modifier la quantité d'un produit
- ✅ Retirer des produits du panier
- ✅ Vider complètement le panier
- ✅ Calcul automatique du total
- ✅ Persistance du panier (sauvegardé localement)
- ✅ Validation de disponibilité des produits

### 2. **Checkout (Passage de commande)**

- ✅ Sélection du mode de paiement
- ✅ Saisie de l'adresse de livraison
- ✅ Upload d'une ordonnance (optionnel)
- ✅ Notes pour le vendeur (optionnel)
- ✅ Récapitulatif de la commande
- ✅ Création de la commande

### 3. **Liste des commandes**

- ✅ Affichage de toutes les commandes
- ✅ Filtrage par statut (En attente, Confirmée, En livraison, Livrée, Annulée)
- ✅ Pull-to-refresh
- ✅ Badge de statut coloré
- ✅ Informations essentielles (référence, pharmacie, montant, date)
- ✅ Navigation vers les détails

### 4. **Détails d'une commande**

- ✅ Statut et progression de la commande
- ✅ Informations de la commande (référence, date, paiement)
- ✅ Détails de la pharmacie
- ✅ Adresse de livraison
- ✅ Liste des articles commandés
- ✅ Récapitulatif des montants (sous-total, livraison, total)
- ✅ Timeline de suivi (si disponible)
- ✅ Bouton d'annulation (si la commande est annulable)

---

## 🏗️ Architecture

### Clean Architecture - 3 couches

```
features/orders/
├── domain/                     # Logique métier
│   ├── entities/
│   │   ├── order_entity.dart
│   │   ├── order_item_entity.dart
│   │   ├── cart_item_entity.dart
│   │   └── delivery_address_entity.dart
│   ├── repositories/
│   │   └── orders_repository.dart
│   └── usecases/
│       ├── get_orders_usecase.dart
│       ├── get_order_details_usecase.dart
│       ├── create_order_usecase.dart
│       ├── cancel_order_usecase.dart
│       └── initiate_payment_usecase.dart
│
├── data/                       # Accès aux données
│   ├── models/
│   │   ├── order_model.dart
│   │   ├── order_item_model.dart
│   │   ├── cart_item_model.dart
│   │   └── delivery_address_model.dart
│   ├── datasources/
│   │   ├── orders_remote_datasource.dart
│   │   └── orders_local_datasource.dart
│   └── repositories/
│       └── orders_repository_impl.dart
│
└── presentation/               # Interface utilisateur
    ├── pages/
    │   ├── cart_page.dart
    │   ├── checkout_page.dart
    │   ├── orders_list_page.dart
    │   └── order_details_page.dart
    ├── widgets/
    │   ├── cart_item_card.dart
    │   ├── order_card.dart
    │   ├── order_timeline.dart
    │   └── empty_state.dart
    └── providers/
        ├── cart_state.dart
        ├── cart_notifier.dart
        ├── cart_provider.dart
        ├── orders_state.dart
        ├── orders_notifier.dart
        └── orders_provider.dart
```

---

## 🔌 API Endpoints Utilisés

### 1. Liste des commandes

```
GET /api/customer/orders
Params: status (optional), page, per_page
```

### 2. Détails d'une commande

```
GET /api/customer/orders/{id}
```

### 3. Créer une commande

```
POST /api/customer/orders
Body: {
  pharmacy_id: int
  items: [{product_id, quantity, unit_price}]
  delivery_address: {name, phone, address, latitude?, longitude?}
  payment_mode: string
  prescription_image?: string
  customer_notes?: string
}
```

### 4. Annuler une commande

```
POST /api/customer/orders/{id}/cancel
Body: {reason: string}
```

### 5. Initier un paiement

```
POST /api/customer/orders/{id}/payment/initiate
Body: {payment_mode: string}
```

---

## 📊 Statuts de commande

### OrderStatus (Enum)

```dart
enum OrderStatus {
  pending,      // En attente de confirmation
  confirmed,    // Confirmée par la pharmacie
  ready,        // Prête pour livraison
  delivering,   // En cours de livraison
  delivered,    // Livrée
  cancelled,    // Annulée
  failed,       // Échec
}
```

**Règles d'annulation :**

- ✅ Annulable : `pending`, `confirmed`
- ❌ Non annulable : `ready`, `delivering`, `delivered`, `cancelled`, `failed`

---

## 🎨 UI/UX

### CartPage

- **Panier vide** : Icône + message + bouton "Voir les produits"
- **Liste d'articles** : Cards avec image, nom, prix, quantité, boutons +/-
- **Résumé** : Sous-total, frais de livraison, total
- **Actions** : Bouton "Vider le panier", bouton "Commander"

### CheckoutPage

- **Étape 1** : Sélection du mode de paiement (Cash, Mobile Money, Card)
- **Étape 2** : Adresse de livraison (formulaire complet)
- **Étape 3** : Ordonnance (upload optionnel)
- **Étape 4** : Notes (texte libre optionnel)
- **Récapitulatif** : Résumé complet avant validation
- **Validation** : Bouton "Confirmer la commande"

### OrdersListPage

- **AppBar** : Titre + filtre par statut (dropdown)
- **Liste** : Cards avec référence, pharmacie, nombre d'articles, date, montant
- **Badge de statut** : Couleur différente selon le statut
- **Pull-to-refresh** : Actualiser la liste
- **Navigation** : Tap sur une card → OrderDetailsPage

### OrderDetailsPage

- **Header** : Badge de statut + référence
- **Informations** : Date, paiement, pharmacie, livraison
- **Articles** : Liste complète des produits commandés
- **Montants** : Sous-total, livraison, total
- **Timeline** : Historique de suivi (si disponible)
- **Actions** : Bouton "Annuler" (si annulable)

---

## 🔄 State Management (Riverpod)

### CartState

```dart
CartState {
  items: List<CartItemEntity>
  selectedPharmacyId: int?
  totalItems: int
  subtotal: double
  deliveryFee: double
  totalAmount: double
}
```

**Méthodes CartNotifier :**

- `addToCart(product, quantity)`
- `updateQuantity(productId, quantity)`
- `removeFromCart(productId)`
- `clearCart()`
- `loadCart()` - Charge depuis SharedPreferences
- `_saveCart()` - Sauvegarde dans SharedPreferences

### OrdersState

```dart
enum OrdersStatus { initial, loading, loaded, error }

OrdersState {
  status: OrdersStatus
  orders: List<OrderEntity>
  selectedOrder: OrderEntity?
  createdOrder: OrderEntity?
  errorMessage: String?
}
```

**Méthodes OrdersNotifier :**

- `loadOrders({status})`
- `loadOrderDetails(orderId)`
- `createOrder({...})`
- `cancelOrder(orderId, reason)`
- `clearError()`

---

## 💾 Persistance locale

### Cart (Panier)

- **Stockage** : SharedPreferences
- **Clé** : `cart_data`
- **Format** : JSON serialisé avec :
  - Liste des items (product, quantity)
  - pharmacy_id sélectionné
- **Chargement** : Au démarrage de l'app (CartNotifier)
- **Sauvegarde** : Après chaque modification du panier

---

## 📦 Modèles de données

### OrderEntity

```dart
{
  id: int
  reference: String
  status: OrderStatus
  paymentMode: PaymentMode
  paymentStatus: PaymentStatus
  pharmacyId: int
  pharmacyName: String
  customerId: int
  items: List<OrderItemEntity>
  deliveryAddress: DeliveryAddressEntity
  subtotal: double
  deliveryFee: double
  totalAmount: double
  paidAt: DateTime?
  createdAt: DateTime
  updatedAt: DateTime
  timeline: List<OrderTimelineEvent>?
  prescriptionImage: String?
  customerNotes: String?
  pharmacyNotes: String?
  cancellationReason: String?
}
```

### CartItemEntity

```dart
{
  product: ProductEntity
  quantity: int
  subtotal: double
  isAvailable: bool
}
```

### DeliveryAddressEntity

```dart
{
  name: String
  phone: String
  address: String
  city: String?
  postalCode: String?
  latitude: double?
  longitude: double?
}
```

---

## 🚀 Utilisation

### Navigation vers les commandes

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const OrdersListPage(),
  ),
);
```

### Navigation depuis HomePage

- **Quick Action** : Bouton "Commandes" → OrdersListPage
- **Drawer** : Menu latéral → OrdersListPage
- **Badge de panier** : Icône panier (AppBar) → CartPage

### Ajouter au panier

```dart
await ref.read(cartProvider.notifier).addToCart(product, quantity);
```

### Créer une commande

```dart
await ref.read(ordersProvider.notifier).createOrder(
  pharmacyId: pharmacyId,
  items: items,
  deliveryAddress: address,
  paymentMode: 'cash',
);
```

### Annuler une commande

```dart
await ref.read(ordersProvider.notifier).cancelOrder(orderId, reason);
```

---

## 🎨 Design System

### Couleurs de statut

- **Pending** : `AppColors.warning` (Orange)
- **Confirmed/Ready** : `Colors.blue`
- **Delivering** : `AppColors.primary` (Vert)
- **Delivered** : `AppColors.success` (Vert foncé)
- **Cancelled/Failed** : `AppColors.error` (Rouge)

### Icônes principales

- `shopping_cart` - Panier
- `receipt_long` - Commandes
- `local_pharmacy` - Pharmacie
- `location_on` - Adresse
- `payment` - Paiement
- `cancel` - Annulation

---

## 🔮 Fonctionnalités futures à ajouter

### À implémenter

- [ ] **Historique de paiement** : Voir les transactions de paiement
- [ ] **Répéter une commande** : Créer une nouvelle commande identique
- [ ] **Favoris de commandes** : Sauvegarder des commandes fréquentes
- [ ] **Notifications push** : Alertes de changement de statut
- [ ] **Suivi en temps réel** : Position du livreur sur une carte
- [ ] **Évaluation** : Noter la pharmacie et le service après livraison
- [ ] **Facture PDF** : Télécharger la facture
- [ ] **Recherche de commandes** : Rechercher par référence ou produit
- [ ] **Export de l'historique** : Exporter en CSV/PDF
- [ ] **Programme de fidélité** : Points de récompense par commande

---

## 🧪 Tests

### Tests unitaires

- ✅ `cart_notifier_test.dart` - Logique du panier
- ✅ `orders_notifier_test.dart` - Logique des commandes
- ✅ `orders_repository_impl_test.dart` - Repository

### Tests de widgets

- ✅ `cart_page_test.dart` - Interface du panier
- ✅ `orders_list_page_test.dart` - Liste des commandes
- ✅ `order_details_page_test.dart` - Détails d'une commande

### Tests d'intégration

- ✅ `orders_flow_test.dart` - Flux complet de commande

---

## 📝 Notes techniques

### Validation des données

- **Quantité** : Min 1, Max 99
- **Adresse** : Obligatoire avec nom, téléphone, adresse
- **Mode de paiement** : cash, mobile_money, card
- **Ordonnance** : Image optionnelle, formats acceptés : JPG, PNG, PDF

### Gestion des erreurs

- Validation côté client avant envoi
- Messages d'erreur clairs et traduits
- Retry automatique pour les erreurs réseau
- État d'erreur sauvegardé dans le state

### Performance

- Chargement paginé des commandes (20 par page)
- Cache local du panier
- Images optimisées avec CachedNetworkImage
- Skeleton loading pendant le chargement

---

## ✅ Checklist d'intégration

- [x] Domain layer (Entities, Repositories, UseCases)
- [x] Data layer (Models, DataSources, Repository Implementation)
- [x] Presentation layer (Pages, Widgets, State Management)
- [x] Providers configuration
- [x] Navigation depuis HomePage (Quick Action + Drawer)
- [x] Gestion du panier avec persistance
- [x] Création de commande
- [x] Liste des commandes avec filtres
- [x] Détails d'une commande
- [x] Annulation de commande
- [x] Gestion des erreurs
- [x] États vides
- [x] Pull-to-refresh
- [x] Badges de statut
- [x] Formatage des montants (F CFA)

---

## 🐛 Problèmes connus

Aucun problème connu. La feature fonctionne correctement.

---

## 👥 Contribution

Pour ajouter de nouvelles fonctionnalités :

1. Créer un UseCase dans `domain/usecases/`
2. Implémenter dans le Repository
3. Ajouter dans le DataSource
4. Créer la méthode dans OrdersNotifier/CartNotifier
5. Mettre à jour l'UI

---

**Dernière mise à jour** : 29 décembre 2025
**Status** : ✅ **Feature complète et opérationnelle**
