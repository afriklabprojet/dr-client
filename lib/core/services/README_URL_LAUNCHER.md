# 🔗 UrlLauncherService - Documentation

## 📋 Vue d'ensemble

Service utilitaire centralisé pour lancer des URLs externes depuis l'application :

- Appels téléphoniques
- Envoi d'emails
- Envoi de SMS
- Ouverture de sites web
- Navigation (Google Maps)
- WhatsApp

---

## 🎯 Méthodes disponibles

### 1. **Appel téléphonique**

```dart
Future<bool> makePhoneCall(String phoneNumber)
```

**Description** : Lance l'application téléphone avec le numéro pré-rempli.

**Paramètres** :

- `phoneNumber` : Numéro de téléphone (formats acceptés : +225 XX XX XX XX, 0X-XX-XX-XX-XX, etc.)

**Retour** : `true` si l'action a réussi, `false` sinon

**Exemple** :

```dart
final success = await UrlLauncherService.makePhoneCall('+225 07 12 34 56 78');
if (!success) {
  // Afficher un message d'erreur
}
```

**Notes** :

- Nettoie automatiquement le numéro (enlève espaces, tirets, parenthèses)
- Utilise le schéma `tel:`
- Sur iOS, demande confirmation avant l'appel

---

### 2. **Envoi d'email**

```dart
Future<bool> sendEmail({
  required String email,
  String? subject,
  String? body,
})
```

**Description** : Ouvre l'application email avec l'adresse et optionnellement le sujet/corps pré-remplis.

**Paramètres** :

- `email` : Adresse email du destinataire (requis)
- `subject` : Objet de l'email (optionnel)
- `body` : Corps de l'email (optionnel)

**Retour** : `true` si l'action a réussi, `false` sinon

**Exemple** :

```dart
final success = await UrlLauncherService.sendEmail(
  email: 'contact@pharmacie.com',
  subject: 'Demande d\'information',
  body: 'Bonjour,\n\nJe souhaiterais avoir des informations sur...',
);
```

**Notes** :

- Utilise le schéma `mailto:`
- Ouvre l'application email par défaut
- Les paramètres subject et body sont encodés automatiquement

---

### 3. **Envoi de SMS**

```dart
Future<bool> sendSMS(String phoneNumber, {String? body})
```

**Description** : Ouvre l'application SMS avec le numéro et optionnellement le message pré-rempli.

**Paramètres** :

- `phoneNumber` : Numéro de téléphone du destinataire
- `body` : Message à pré-remplir (optionnel)

**Retour** : `true` si l'action a réussi, `false` sinon

**Exemple** :

```dart
final success = await UrlLauncherService.sendSMS(
  '+225 07 12 34 56 78',
  body: 'Bonjour, je souhaite commander...',
);
```

**Notes** :

- Utilise le schéma `sms:`
- Compatible Android et iOS
- Le message n'est pas envoyé automatiquement

---

### 4. **Ouverture d'URL web**

```dart
Future<bool> openWebUrl(String url)
```

**Description** : Ouvre une URL dans le navigateur externe.

**Paramètres** :

- `url` : URL complète à ouvrir (http:// ou https://)

**Retour** : `true` si l'action a réussi, `false` sinon

**Exemple** :

```dart
final success = await UrlLauncherService.openWebUrl(
  'https://www.drpharma.ci',
);
```

**Notes** :

- Force l'ouverture dans un navigateur externe
- Ne s'ouvre pas dans un WebView intégré

---

### 5. **Navigation avec coordonnées GPS**

```dart
Future<bool> openMap({
  required double latitude,
  required double longitude,
  String? label,
})
```

**Description** : Ouvre Google Maps avec des coordonnées GPS spécifiques.

**Paramètres** :

- `latitude` : Latitude (requis)
- `longitude` : Longitude (requis)
- `label` : Étiquette optionnelle pour le lieu

**Retour** : `true` si l'action a réussi, `false` sinon

**Exemple** :

```dart
final success = await UrlLauncherService.openMap(
  latitude: 5.316667,
  longitude: -4.033333,
  label: 'Pharmacie Centrale',
);
```

**Notes** :

- Priorité à Google Maps si installé
- Fallback vers l'URI géo générique
- Ouvre l'application dans un navigateur web si aucune app de navigation n'est installée

---

### 6. **Navigation avec adresse textuelle**

```dart
Future<bool> openMapWithAddress(String address)
```

**Description** : Ouvre Google Maps avec une adresse textuelle.

**Paramètres** :

- `address` : Adresse complète (rue, ville, pays)

**Retour** : `true` si l'action a réussi, `false` sinon

**Exemple** :

```dart
final success = await UrlLauncherService.openMapWithAddress(
  'Boulevard Latrille, Abidjan, Côte d\'Ivoire',
);
```

**Notes** :

- Encode automatiquement l'adresse pour l'URL
- Utilise l'API de recherche Google Maps

---

### 7. **Ouverture de WhatsApp**

```dart
Future<bool> openWhatsApp(String phoneNumber, {String? message})
```

**Description** : Ouvre WhatsApp avec un contact spécifique et optionnellement un message pré-rempli.

**Paramètres** :

- `phoneNumber` : Numéro de téléphone (format international recommandé)
- `message` : Message à pré-remplir (optionnel)

**Retour** : `true` si l'action a réussi, `false` sinon

**Exemple** :

```dart
final success = await UrlLauncherService.openWhatsApp(
  '+225 07 12 34 56 78',
  message: 'Bonjour, je souhaite avoir des informations sur vos produits',
);
```

**Notes** :

- Nécessite WhatsApp installé sur l'appareil
- Utilise l'API web de WhatsApp
- Le message n'est pas envoyé automatiquement

---

## 🔧 Configuration requise

### Dépendances

```yaml
dependencies:
  url_launcher: ^6.2.5
```

### Android (AndroidManifest.xml)

```xml
<manifest>
  <queries>
    <!-- Pour les appels téléphoniques -->
    <intent>
      <action android:name="android.intent.action.DIAL" />
    </intent>

    <!-- Pour les emails -->
    <intent>
      <action android:name="android.intent.action.SENDTO" />
      <data android:scheme="mailto" />
    </intent>

    <!-- Pour les SMS -->
    <intent>
      <action android:name="android.intent.action.SENDTO" />
      <data android:scheme="sms" />
    </intent>

    <!-- Pour les URLs web -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="https" />
    </intent>

    <!-- Pour la navigation -->
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="geo" />
    </intent>
  </queries>
</manifest>
```

### iOS (Info.plist)

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tel</string>
  <string>mailto</string>
  <string>sms</string>
  <string>https</string>
  <string>comgooglemaps</string>
  <string>whatsapp</string>
</array>
```

---

## 💡 Bonnes pratiques

### 1. Gestion des erreurs

Toujours vérifier le retour et afficher un message approprié :

```dart
Future<void> _callPharmacy(String phone) async {
  final success = await UrlLauncherService.makePhoneCall(phone);

  if (!success && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impossible de lancer l\'appel téléphonique'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
```

### 2. Validation des données

Vérifier que les données existent avant d'appeler le service :

```dart
if (pharmacy.phone != null && pharmacy.phone!.isNotEmpty) {
  await UrlLauncherService.makePhoneCall(pharmacy.phone!);
}
```

### 3. Permissions

Sur Android 11+, déclarer les queries dans le manifest pour éviter les problèmes de sécurité.

### 4. Contexte monté

Toujours vérifier `mounted` avant d'afficher des messages après un appel async :

```dart
if (!success && mounted) {
  // Afficher message d'erreur
}
```

---

## 🎨 Exemples d'utilisation dans l'UI

### Bouton d'appel

```dart
ElevatedButton.icon(
  onPressed: () => UrlLauncherService.makePhoneCall(pharmacy.phone!),
  icon: const Icon(Icons.phone),
  label: const Text('Appeler'),
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
  ),
)
```

### Liste d'actions

```dart
ListTile(
  leading: const Icon(Icons.phone, color: AppColors.success),
  title: const Text('Appeler'),
  subtitle: Text(pharmacy.phone!),
  onTap: () => UrlLauncherService.makePhoneCall(pharmacy.phone!),
  trailing: const Icon(Icons.chevron_right),
)
```

### FAB (Floating Action Button)

```dart
FloatingActionButton.extended(
  onPressed: () => UrlLauncherService.makePhoneCall(pharmacy.phone!),
  icon: const Icon(Icons.phone),
  label: const Text('Appeler'),
  backgroundColor: AppColors.success,
)
```

---

## 🐛 Dépannage

### Problème : "Could not launch tel:..."

**Cause** : Queries non déclarées dans AndroidManifest.xml (Android 11+)

**Solution** : Ajouter les `<queries>` dans le manifest (voir section Configuration)

### Problème : L'appel ne se lance pas sur iOS

**Cause** : Schéma `tel` non déclaré dans Info.plist

**Solution** : Ajouter `LSApplicationQueriesSchemes` dans Info.plist

### Problème : Google Maps n'ouvre pas

**Cause** : App Google Maps non installée ou schéma non autorisé

**Solution** : Le service fait automatiquement un fallback vers le navigateur web

---

## 📱 Compatibilité

- ✅ Android (API 21+)
- ✅ iOS (11+)
- ✅ Web (limitations : pas d'appels directs, redirection vers `mailto:` et URLs)
- ❌ Desktop (non supporté pour les schémas natifs)

---

## 🔐 Sécurité

- ✅ Validation et nettoyage automatique des numéros de téléphone
- ✅ Encodage URL automatique pour les emails et SMS
- ✅ Vérification de la possibilité de lancer l'URL avec `canLaunchUrl()`
- ✅ Pas de permissions dangereuses requises

---

## 📊 Tests

### Tests unitaires recommandés

```dart
test('makePhoneCall should clean phone number', () async {
  // Tester que les espaces, tirets sont enlevés
});

test('sendEmail should encode subject and body', () async {
  // Tester l'encodage des caractères spéciaux
});

test('openMap should prioritize coordinates over address', () async {
  // Tester la logique de fallback
});
```

---

**Dernière mise à jour** : 29 décembre 2025
**Package utilisé** : `url_launcher: ^6.2.5`
**Status** : ✅ Production-ready
