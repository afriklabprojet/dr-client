# 🏥 Feature Pharmacies - Documentation

## 📋 Vue d'ensemble

La feature **Pharmacies** permet aux clients de consulter la liste des pharmacies disponibles, voir les détails d'une pharmacie, et trouver les pharmacies à proximité.

---

## 🎯 Fonctionnalités

### ✅ Implémentées

1. **Liste des pharmacies**

   - Affichage paginé de toutes les pharmacies
   - Pull-to-refresh pour actualiser
   - Infinite scroll pour charger plus de résultats
   - Statut d'ouverture (Ouverte/Fermée)
   - Distance depuis la position de l'utilisateur (si disponible)

2. **Détails d'une pharmacie**

   - Nom et statut
   - Adresse complète
   - Numéro de téléphone
   - Email
   - Horaires d'ouverture
   - Description
   - Distance

3. **Navigation**
   - Accès depuis la page d'accueil via le bouton "Pharmacies"
   - Navigation vers les détails en cliquant sur une carte

---

## 🏗️ Architecture

### Clean Architecture - 3 couches

```
features/pharmacies/
├── domain/                     # Logique métier
│   ├── entities/
│   │   └── pharmacy_entity.dart
│   ├── repositories/
│   │   └── pharmacies_repository.dart
│   └── usecases/
│       ├── get_pharmacies_usecase.dart
│       ├── get_nearby_pharmacies_usecase.dart
│       └── get_pharmacy_details_usecase.dart
│
├── data/                       # Accès aux données
│   ├── models/
│   │   └── pharmacy_model.dart
│   ├── datasources/
│   │   └── pharmacies_remote_datasource.dart
│   └── repositories/
│       └── pharmacies_repository_impl.dart
│
└── presentation/               # Interface utilisateur
    ├── pages/
    │   ├── pharmacies_list_page.dart
    │   └── pharmacy_details_page.dart
    ├── widgets/
    │   └── pharmacy_card.dart
    └── providers/
        ├── pharmacies_state.dart
        └── pharmacies_notifier.dart
```

---

## 🔌 API Endpoints Utilisés

### 1. Liste des pharmacies

```
GET /api/customer/pharmacies
Params: page, per_page
```

### 2. Pharmacies à proximité

```
GET /api/customer/pharmacies/nearby
Params: latitude, longitude, radius
```

### 3. Détails d'une pharmacie

```
GET /api/customer/pharmacies/{id}
```

---

## 🎨 UI/UX

### PharmaciesListPage

- **AppBar** : Titre "Pharmacies"
- **Liste** : Cards avec nom, statut, adresse, téléphone, distance
- **Loading** : Indicateur de chargement pendant le fetch
- **Error** : Message d'erreur avec bouton "Réessayer"
- **Empty** : État vide avec icône et message
- **Infinite Scroll** : Charge automatiquement plus de résultats en scrollant

### PharmacyDetailsPage

- **Header** : Grande carte colorée avec icône, nom et badge de statut
- **Info Cards** : Cartes pour adresse, téléphone, email, horaires
- **Description** : Texte complet de description si disponible
- **Distance** : Badge spécial si la distance est calculée

### PharmacyCard (Widget)

- **Icône** : `local_pharmacy` dans un conteneur coloré
- **Nom** : Titre principal en bold
- **Statut** : Indicateur visuel (point vert/rouge + texte)
- **Distance** : Affichée si disponible (en m ou km)
- **Adresse** : Avec icône `location_on`
- **Téléphone** : Avec icône `phone`

---

## 🔄 State Management (Riverpod)

### PharmaciesState

```dart
enum PharmaciesStatus { initial, loading, success, error }

PharmaciesState {
  status: PharmaciesStatus
  pharmacies: List<PharmacyEntity>
  nearbyPharmacies: List<PharmacyEntity>
  selectedPharmacy: PharmacyEntity?
  errorMessage: String?
  hasReachedMax: bool
  currentPage: int
}
```

### PharmaciesNotifier

Méthodes:

- `fetchPharmacies({refresh})` - Charge la liste
- `fetchNearbyPharmacies({latitude, longitude, radius})` - Pharmacies à proximité
- `fetchPharmacyDetails(id)` - Détails d'une pharmacie
- `clearError()` - Efface les erreurs
- `clearSelectedPharmacy()` - Nettoie la sélection

---

## 📦 Modèles de données

### PharmacyEntity

```dart
{
  id: int
  name: String
  address: String
  phone: String?
  email: String?
  latitude: double?
  longitude: double?
  status: String
  isOpen: bool
  distance: double?        // en km
  openingHours: String?
  description: String?
}
```

**Helpers:**

- `initials` - Initiales du nom (ex: "Pharmacie Centrale" → "PC")
- `statusLabel` - Label traduit du statut
- `distanceLabel` - Distance formatée (ex: "500 m" ou "1.5 km")

---

## 🚀 Utilisation

### Navigation vers la liste

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const PharmaciesListPage(),
  ),
);
```

### Accéder au state

```dart
final pharmaciesState = ref.watch(pharmaciesProvider);
final pharmacies = pharmaciesState.pharmacies;
final isLoading = pharmaciesState.status == PharmaciesStatus.loading;
```

### Fetch pharmacies

```dart
await ref.read(pharmaciesProvider.notifier).fetchPharmacies(refresh: true);
```

### Fetch détails

```dart
await ref.read(pharmaciesProvider.notifier).fetchPharmacyDetails(pharmacyId);
```

---

## 🔮 Fonctionnalités futures

### ✅ Récemment implémentées

- [x] **Appel téléphonique** : Cliquer sur le téléphone pour appeler directement
- [x] **Email** : Cliquer sur l'email pour envoyer un message
- [x] **Navigation** : Cliquer sur l'adresse pour ouvrir Google Maps

### À implémenter

- [ ] **Géolocalisation** : Demander la position de l'utilisateur pour calculer les distances
- [ ] **Carte interactive** : Afficher les pharmacies sur une carte (Google Maps / OpenStreetMap)
- [ ] **Filtres** : Filtrer par statut (ouvert/fermé), distance, services
- [ ] **Recherche** : Recherche par nom ou adresse
- [ ] **Favoris** : Marquer des pharmacies comme favorites
- [ ] **Itinéraire détaillé** : Options de transport (voiture, marche, vélo)
- [ ] **Produits par pharmacie** : Voir les produits disponibles dans une pharmacie spécifique
- [ ] **Pharmacies de garde** : Liste des pharmacies ouvertes 24h/24
- [ ] **Partage** : Partager les coordonnées d'une pharmacie
- [ ] **Avis et notes** : Noter et commenter les pharmacies

---

## 🧪 Tests

### Tests à créer

```dart
// Unit Tests
- pharmacy_entity_test.dart
- pharmacy_model_test.dart
- get_pharmacies_usecase_test.dart
- pharmacies_repository_impl_test.dart

// Widget Tests
- pharmacy_card_test.dart
- pharmacies_list_page_test.dart
- pharmacy_details_page_test.dart

// Integration Tests
- pharmacies_flow_test.dart
```

---

## 📝 Notes techniques

### Gestion de la pagination

- Taille de page : 20 éléments
- Chargement automatique à 90% du scroll
- Flag `hasReachedMax` pour arrêter le fetch

### Gestion des erreurs

- Affichage d'un message d'erreur convivial
- Bouton "Réessayer" pour refetch
- Conservation des données précédentes en cas d'erreur de pagination

### Performance

- Utilisation de `ListView.builder` pour le rendu optimisé
- Chargement lazy des pages suivantes
- Cache local via SharedPreferences (à implémenter)

---

## 🎨 Design System

### Couleurs utilisées

- **Primary** : AppColors.primary - Icônes, badges
- **Success** : AppColors.success - Statut "Ouverte"
- **Error** : AppColors.error - Statut "Fermée"
- **Info** : AppColors.info - Information générale
- **Warning** : AppColors.warning - Alertes

### Icônes

- `local_pharmacy` - Icône principale des pharmacies
- `location_on` - Adresse
- `phone` - Téléphone
- `email` - Email
- `access_time` - Horaires
- `directions` - Distance/Navigation

---

## 📱 Responsive Design

- **Mobile** : Liste en colonne avec cards pleine largeur
- **Tablet** : Grid à 2 colonnes (à implémenter)
- **Desktop** : Grid à 3 colonnes (à implémenter)

---

## ✅ Checklist d'intégration

- [x] Domain layer (Entities, Repositories, UseCases)
- [x] Data layer (Models, DataSources, Repository Implementation)
- [x] Presentation layer (Pages, Widgets, State Management)
- [x] Providers configuration
- [x] Navigation depuis HomePage
- [x] Gestion des erreurs
- [x] États vides
- [x] Pull-to-refresh
- [x] Infinite scroll
- [x] Documentation

---

## 🐛 Problèmes connus

Aucun pour le moment.

---

## 👥 Contribution

Pour ajouter de nouvelles fonctionnalités :

1. Créer un UseCase dans `domain/usecases/`
2. Implémenter dans le Repository
3. Ajouter dans le DataSource
4. Créer la méthode dans PharmaciesNotifier
5. Mettre à jour l'UI

---

**Dernière mise à jour** : 29 décembre 2024
**Status** : ✅ Feature complète et fonctionnelle
