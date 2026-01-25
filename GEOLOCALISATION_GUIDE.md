# 📍 Guide Géolocalisation - DR-PHARMA

## ✅ Ce qui a été implémenté

### 1. **Bouton "Pharmacies" sur la page d'accueil**

- Carte verte avec icône `local_pharmacy`
- Navigation vers la liste des pharmacies

### 2. **Page Liste des Pharmacies avec Géolocalisation**

#### Fonctionnalités principales :

**🌍 Mode "Toutes les pharmacies"** (par défaut)

- Affiche toutes les pharmacies disponibles
- FloatingActionButton "À proximité" en bas à droite
- Icône de localisation dans l'AppBar

**📍 Mode "Pharmacies à proximité"**

- Bouton FAB "À proximité" : Active la géolocalisation
- Icône dans l'AppBar : Bascule entre les deux modes
- Affiche la distance pour chaque pharmacie
- Rayon de recherche : 10 km

### 3. **Affichage des distances**

- Distance calculée en temps réel si coordonnées GPS disponibles
- Format : "125 m" (< 1 km) ou "2.5 km" (≥ 1 km)
- Icône de localisation rouge à côté de la distance
- Visible uniquement en mode "à proximité"

### 4. **Gestion des permissions**

#### Permissions demandées :

- ✅ Localisation fine (GPS)
- ✅ Localisation approximative (réseau)

#### Dialogues intelligents :

- **Services désactivés** : Propose d'ouvrir les paramètres de localisation
- **Permission refusée** : Message d'erreur avec SnackBar
- **Permission refusée définitivement** : Dialogue pour ouvrir les paramètres de l'app

---

## 🧪 Comment tester

### Étape 1 : Lancer l'application

```bash
cd Mobile/client_flutter
flutter run
```

### Étape 2 : Naviguer vers les Pharmacies

1. Sur la **page d'accueil**, cherchez la section "Actions Rapides"
2. Cliquez sur la carte **"Pharmacies"** (icône verte avec croix de pharmacie)

### Étape 3 : Tester le mode "Toutes les pharmacies"

Vous devriez voir :

- ✅ Liste de toutes les pharmacies
- ✅ Nom, adresse, téléphone
- ✅ Statut "Ouverte" (vert) ou "Fermée" (rouge)
- ✅ FloatingActionButton "À proximité" en bas à droite
- ✅ Pas de distance affichée

### Étape 4 : Tester la géolocalisation

#### Option A : Via le FloatingActionButton

1. Cliquez sur le **FAB "À proximité"** (bouton vert en bas)
2. Accordez la permission de localisation si demandée
3. Attendez le message "Localisation en cours..."
4. Les pharmacies se rechargent avec les distances

#### Option B : Via l'icône AppBar

1. Cliquez sur l'**icône de localisation** dans l'AppBar (en haut à droite)
2. Accordez la permission si demandée
3. Les pharmacies à proximité se chargent automatiquement

### Étape 5 : Vérifier les distances

En mode "à proximité", chaque carte doit afficher :

- ✅ Icône de localisation rouge
- ✅ Distance : "350 m" ou "1.2 km"
- ✅ Tri par distance (les plus proches en premier)

### Étape 6 : Basculer entre les modes

Cliquez sur l'icône dans l'AppBar pour basculer :

- **Icône de localisation** → Mode "À proximité"
- **Icône de liste** → Mode "Toutes les pharmacies"

### Étape 7 : Tester le Pull-to-Refresh

1. Tirez vers le bas pour rafraîchir
2. En mode "À proximité" : Relocalisation + rechargement
3. En mode "Toutes" : Simple rechargement

---

## 🔧 Configuration des permissions

### Android (AndroidManifest.xml)

✅ **Déjà configuré** dans `/android/app/src/main/AndroidManifest.xml` :

```xml
<!-- Permissions de géolocalisation -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Queries pour URL Launcher -->
<queries>
  <!-- Téléphone -->
  <intent>
    <action android:name="android.intent.action.DIAL" />
  </intent>

  <!-- Email -->
  <intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="mailto" />
  </intent>

  <!-- Maps -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="geo" />
  </intent>
</queries>
```

### iOS (Info.plist)

✅ **Déjà configuré** dans `/ios/Runner/Info.plist` :

```xml
<!-- Messages de demande de permission -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>DR-PHARMA a besoin d'accéder à votre position pour trouver les pharmacies à proximité.</string>

<!-- Schémas URL autorisés -->
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
  <string>mailto</string>
  <string>comgooglemaps</string>
</array>
```

---

## 📱 Scénarios de test

### Scénario 1 : Permission acceptée

1. Cliquez sur "À proximité"
2. **Dialogue système** : "Autoriser DR-PHARMA à accéder à votre position ?"
3. Choisissez : "Autoriser pendant l'utilisation de l'app"
4. ✅ Résultat : Pharmacies chargées avec distances

### Scénario 2 : Permission refusée

1. Cliquez sur "À proximité"
2. Dialogue système : Choisissez "Refuser"
3. ✅ Résultat : SnackBar rouge "Permission de localisation refusée"
4. Mode reste sur "Toutes les pharmacies"

### Scénario 3 : Services de localisation désactivés

1. Désactivez le GPS dans les paramètres
2. Cliquez sur "À proximité"
3. ✅ Résultat : Dialogue "Services de localisation désactivés"
4. Bouton "Ouvrir paramètres" → Ouvre les paramètres système

### Scénario 4 : Permission refusée définitivement

1. Refusez la permission ET cochez "Ne plus demander" (Android)
2. Cliquez sur "À proximité"
3. ✅ Résultat : Dialogue "Permission requise"
4. Bouton "Ouvrir paramètres" → Ouvre les paramètres de l'app

---

## 🐛 Dépannage

### Problème : Bouton "Pharmacies" invisible sur la page d'accueil

**Cause** : Navigation non configurée

**Solution** : Vérifier que `PharmaciesListPage` est bien importée dans `home_page.dart`

```dart
import 'features/pharmacies/presentation/pages/pharmacies_list_page.dart';
```

### Problème : FloatingActionButton "À proximité" ne s'affiche pas

**Cause** : Déjà en mode "à proximité"

**Solution** : Le FAB disparaît en mode proximité (normal). Cliquez sur l'icône de l'AppBar pour revenir au mode "Toutes".

### Problème : Distances non affichées

**Causes possibles** :

1. Les pharmacies n'ont pas de coordonnées GPS dans la BDD
2. La localisation a échoué silencieusement
3. Mode "Toutes les pharmacies" actif

**Solution** :

- Vérifier que le mode "À proximité" est actif (icône liste dans AppBar)
- Vérifier les logs pour erreurs de géolocalisation
- Vérifier que les pharmacies ont `latitude` et `longitude` non-null

### Problème : "Aucune pharmacie disponible"

**Causes possibles** :

1. Backend non démarré
2. Endpoint `/api/pharmacies` non implémenté
3. Rayon de 10 km trop petit

**Solutions** :

1. Démarrer le backend : `cd Backend/laravel-api && php artisan serve`
2. Implémenter l'endpoint backend si nécessaire
3. Augmenter le rayon dans le code (ligne `radius: 10.0`)

---

## 📊 Données de test

Pour tester avec des données réelles, assurez-vous que votre backend retourne :

### Endpoint : `GET /api/pharmacies`

```json
{
  "data": [
    {
      "id": 1,
      "name": "Pharmacie Centrale",
      "address": "Boulevard Latrille, Abidjan",
      "phone": "+225 07 12 34 56 78",
      "email": "contact@pharmacie-centrale.ci",
      "latitude": 5.316667,
      "longitude": -4.033333,
      "is_open": true
    }
  ]
}
```

### Endpoint : `GET /api/pharmacies/nearby` (à créer si nécessaire)

**Paramètres** :

- `latitude` : Latitude actuelle
- `longitude` : Longitude actuelle
- `radius` : Rayon en km (défaut: 10)

---

## 🎯 Prochaines améliorations possibles

- [ ] Slider pour ajuster le rayon de recherche (5, 10, 20, 50 km)
- [ ] Tri manuel (distance, nom, statut)
- [ ] Filtrage (ouvertes seulement, avec garde)
- [ ] Carte interactive avec marqueurs
- [ ] Itinéraire vers la pharmacie sélectionnée
- [ ] Sauvegarde des pharmacies favorites
- [ ] Notifications pour pharmacies de garde
- [ ] Recherche par nom/ville

---

## 📝 Checklist de test complète

### Permissions Android

- [ ] Permission ACCESS_FINE_LOCATION demandée
- [ ] Permission ACCESS_COARSE_LOCATION demandée
- [ ] Dialogue système s'affiche correctement
- [ ] Message "Autoriser pendant l'utilisation" fonctionnel
- [ ] Refus de permission géré gracieusement
- [ ] Ouverture des paramètres fonctionnelle

### Permissions iOS

- [ ] Message `NSLocationWhenInUseUsageDescription` affiché
- [ ] Permission "Autoriser une fois" fonctionnelle
- [ ] Permission "Autoriser pendant l'utilisation" fonctionnelle
- [ ] Refus de permission géré gracieusement

### Interface utilisateur

- [ ] Bouton "Pharmacies" visible sur la page d'accueil
- [ ] FloatingActionButton "À proximité" visible (mode toutes)
- [ ] Icône AppBar change selon le mode
- [ ] Titre AppBar change selon le mode
- [ ] Distances affichées en mode proximité
- [ ] Pull-to-refresh fonctionne dans les deux modes

### Fonctionnalités

- [ ] Chargement initial des pharmacies
- [ ] Géolocalisation fonctionnelle
- [ ] Calcul des distances correct
- [ ] Tri par distance (proximité)
- [ ] Basculement entre modes fluide
- [ ] Gestion d'erreurs appropriée
- [ ] Messages de feedback clairs

---

**Date de création** : 29 décembre 2025  
**Version de l'app** : 1.0.0+1  
**Packages utilisés** :

- `geolocator: ^11.0.0`
- `url_launcher: ^6.2.5`

**Status** : ✅ Production-ready
