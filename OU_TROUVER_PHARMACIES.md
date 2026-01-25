# 📱 Où trouver l'option Pharmacies - Guide visuel

## 🎯 Page d'accueil de DR-PHARMA

Voici à quoi ressemble la page d'accueil avec l'option **Pharmacies** :

```
╔════════════════════════════════════════════════╗
║  DR-PHARMA        🛒(3)  🔔  ⋮                 ║ ← AppBar
╠════════════════════════════════════════════════╣
║                                                ║
║  ┌────────────────────────────────────────┐   ║
║  │                                        │   ║
║  │  Bonjour, [Votre nom] 👋               │   ║
║  │                                        │   ║
║  │  Trouvez vos médicaments rapidement   │   ║
║  │                                        │   ║
║  └────────────────────────────────────────┘   ║ ← Banner
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  Actions Rapides                        │ ║
║  ├──────────────────────────────────────────┤ ║
║  │                                          │ ║
║  │  ┌────────────┐    ┌─────────────┐     │ ║
║  │  │    💊      │    │     🔍      │     │ ║
║  │  │  Produits  │    │  Rechercher │     │ ║
║  │  └────────────┘    └─────────────┘     │ ║
║  │    [BLEU]             [VIOLET]          │ ║
║  │                                          │ ║
║  │  ┌────────────┐    ┌─────────────┐     │ ║
║  │  │    📦      │    │     🏥      │     │ ║
║  │  │ Commandes  │    │  Pharmacies │ ←── │ ║ ← CLIQUEZ ICI !
║  │  └────────────┘    └─────────────┘     │ ║
║  │    [ORANGE]           [VERT] ⭐        │ ║
║  │                                          │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  À Découvrir                             │ ║
║  │  ...                                     │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
╚════════════════════════════════════════════════╝
```

## 🟢 Caractéristiques de la carte "Pharmacies"

### Couleur

- **Fond** : Vert (AppColors.success)
- **Contraste** : Facilement identifiable parmi les autres cartes

### Icône

- **Type** : `Icons.local_pharmacy` (🏥)
- **Taille** : Grande et visible
- **Couleur** : Blanc sur fond vert

### Texte

- **Label** : "Pharmacies"
- **Police** : Bold, bien lisible

### Position

- **Ligne 2** de la grille (4 cartes au total)
- **Colonne droite** (à côté de "Commandes")

---

## 🚀 Après avoir cliqué sur "Pharmacies"

Vous arriverez sur cette page :

```
╔════════════════════════════════════════════════╗
║  ←  Pharmacies                    📍          ║ ← AppBar
╠════════════════════════════════════════════════╣
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie Centrale                  │ ║
║  │      🟢 Ouverte                           │ ║
║  │                                           │ ║
║  │      📍 Boulevard Latrille, Abidjan       │ ║
║  │      📞 +225 07 12 34 56 78              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie du Nord                   │ ║
║  │      🔴 Fermée                            │ ║
║  │                                           │ ║
║  │      📍 Cocody, Abidjan                   │ ║
║  │      📞 +225 07 98 76 54 32              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie du Plateau                │ ║
║  │      🟢 Ouverte                           │ ║
║  │                                           │ ║
║  │      📍 Plateau, Abidjan                  │ ║
║  │      📞 +225 07 11 22 33 44              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║                                                ║
║                          ┌─────────────────┐  ║
║                          │  📍 À proximité │  ║ ← FAB (Bouton flottant)
║                          └─────────────────┘  ║
╚════════════════════════════════════════════════╝
```

---

## 🎯 Comment activer la géolocalisation

### Option 1 : FloatingActionButton (Recommandé)

```
Cliquez sur le bouton vert en bas à droite :

    ┌─────────────────┐
    │  📍 À proximité │  ← Cliquez ici
    └─────────────────┘

Résultat :
✅ Demande de permission de localisation
✅ Activation du GPS
✅ Affichage des pharmacies avec distances
```

### Option 2 : Icône AppBar

```
Cliquez sur l'icône dans l'AppBar :

╔════════════════════════════════════════════════╗
║  ←  Pharmacies                    📍 ← Cliquez ║
╠════════════════════════════════════════════════╣

Résultat :
✅ Même effet que le FAB
✅ Basculement entre modes
```

---

## 📍 Après activation de la géolocalisation

```
╔════════════════════════════════════════════════╗
║  ←  Pharmacies à proximité        📋          ║ ← Titre changé
╠════════════════════════════════════════════════╣
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie Centrale                  │ ║
║  │      🟢 Ouverte  📍 350 m ← Distance !   │ ║
║  │                                           │ ║
║  │      📍 Boulevard Latrille, Abidjan       │ ║
║  │      📞 +225 07 12 34 56 78              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie du Plateau                │ ║
║  │      🟢 Ouverte  📍 1.2 km ← Distance !  │ ║
║  │                                           │ ║
║  │      📍 Plateau, Abidjan                  │ ║
║  │      📞 +225 07 11 22 33 44              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie d'Abobo                   │ ║
║  │      🔴 Fermée  📍 3.8 km ← Distance !   │ ║
║  │                                           │ ║
║  │      📍 Abobo, Abidjan                    │ ║
║  │      📞 +225 07 55 66 77 88              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║                                                ║
║                       (Pas de FAB ici)         ║ ← FAB disparu
╚════════════════════════════════════════════════╝
```

### Différences visibles :

1. **Titre** : "Pharmacies" → "Pharmacies à proximité" ✅
2. **Distance** : Affichée sur chaque carte (ex: "350 m", "1.2 km") ✅
3. **Icône AppBar** : 📍 → 📋 (pour revenir au mode "Toutes") ✅
4. **FAB** : Disparu (déjà en mode proximité) ✅
5. **Tri** : Les pharmacies les plus proches en premier ✅

---

## 🔄 Basculer entre les modes

### Du mode "Toutes" vers "À proximité"

```
Mode actuel : Pharmacies (toutes)
               ↓
    Cliquer sur : FAB "À proximité" OU Icône 📍
               ↓
    Permission demandée (si première fois)
               ↓
    Géolocalisation en cours...
               ↓
Mode nouveau : Pharmacies à proximité (avec distances)
```

### Du mode "À proximité" vers "Toutes"

```
Mode actuel : Pharmacies à proximité
               ↓
    Cliquer sur : Icône 📋 dans AppBar
               ↓
    Rechargement des données...
               ↓
Mode nouveau : Pharmacies (toutes, sans distances)
```

---

## 📱 Dialogues de permission

### Première utilisation

Quand vous cliquez sur "À proximité" pour la première fois :

```
┌────────────────────────────────────────┐
│  Autoriser DR-PHARMA à accéder à       │
│  votre position ?                      │
│                                        │
│  DR-PHARMA a besoin d'accéder à votre │
│  position pour trouver les pharmacies │
│  à proximité.                         │
│                                        │
│  ┌──────────────┐  ┌────────────────┐ │
│  │  Refuser     │  │  Autoriser     │ │
│  └──────────────┘  └────────────────┘ │
│                                        │
└────────────────────────────────────────┘
```

### Si services désactivés

```
┌────────────────────────────────────────┐
│  Services de localisation désactivés   │
│                                        │
│  Veuillez activer les services de     │
│  localisation pour trouver les        │
│  pharmacies à proximité.              │
│                                        │
│  ┌──────────────┐  ┌────────────────┐ │
│  │  Annuler     │  │  Ouvrir        │ │
│  │              │  │  paramètres    │ │
│  └──────────────┘  └────────────────┘ │
│                                        │
└────────────────────────────────────────┘
```

---

## ✅ Checklist visuelle

Vérifiez que vous voyez bien :

### Sur la page d'accueil

- [ ] Section "Actions Rapides" visible
- [ ] 4 cartes de couleurs différentes (bleu, violet, orange, vert)
- [ ] Carte VERTE avec icône 🏥 et texte "Pharmacies"
- [ ] La carte "Pharmacies" est en bas à droite

### Sur la page Pharmacies (mode "Toutes")

- [ ] Titre "Pharmacies" dans l'AppBar
- [ ] Icône 📍 (localisation) dans l'AppBar
- [ ] Liste des pharmacies visible
- [ ] FloatingActionButton vert "À proximité" en bas à droite
- [ ] Pas de distances affichées

### Après activation géolocalisation (mode "À proximité")

- [ ] Titre "Pharmacies à proximité" dans l'AppBar
- [ ] Icône 📋 (liste) dans l'AppBar
- [ ] Distances affichées (ex: "1.2 km", "350 m")
- [ ] Icône 📍 rouge à côté des distances
- [ ] Pas de FloatingActionButton
- [ ] Pharmacies triées par distance

---

## 🎨 Codes couleur

Pour vous aider à identifier les éléments :

| Élément              | Couleur  | Code                |
| -------------------- | -------- | ------------------- |
| Carte "Pharmacies"   | 🟢 Vert  | `AppColors.success` |
| FloatingActionButton | 🟢 Vert  | `AppColors.success` |
| Statut "Ouverte"     | 🟢 Vert  | `AppColors.success` |
| Statut "Fermée"      | 🔴 Rouge | `AppColors.error`   |
| Icône distance       | 🔴 Rouge | `Colors.red`        |
| AppBar               | 🔵 Bleu  | `AppColors.primary` |

---

## 🚨 Problèmes courants

### "Je ne vois pas la carte Pharmacies"

**Solution 1** : Scrollez vers le bas

- La section "Actions Rapides" peut être en dessous du banner de bienvenue

**Solution 2** : Hot Restart

```bash
# Dans le terminal où Flutter tourne
Appuyez sur 'R' (majuscule)
```

**Solution 3** : Vérifier le code

```dart
// Dans home_page.dart, cherchez :
_QuickActionCard(
  icon: Icons.local_pharmacy,
  title: 'Pharmacies',
  color: AppColors.success, // ← Doit être success (vert)
)
```

### "Je ne vois pas le bouton À proximité"

**Cause** : Vous êtes déjà en mode "À proximité"

**Solution** : Cliquez sur l'icône 📋 dans l'AppBar pour revenir au mode "Toutes"

### "Les distances ne s'affichent pas"

**Vérifications** :

1. Êtes-vous en mode "Pharmacies à proximité" ? (titre AppBar)
2. Avez-vous accordé la permission de localisation ?
3. Le GPS est-il activé sur votre appareil ?
4. Les pharmacies ont-elles des coordonnées GPS dans la BDD ?

---

## 📸 Captures d'écran de référence

### Vue d'ensemble

```
┌─ HomePage ─────────────────────────┐
│  Banner "Bonjour..."               │
│  ┌─ Actions Rapides ─────────────┐ │
│  │ [Produits]   [Rechercher]     │ │
│  │ [Commandes]  [Pharmacies] ⭐  │ │ ← Cliquez ici
│  └───────────────────────────────┘ │
│  Autres sections...                │
└────────────────────────────────────┘
            │
            │ Navigation
            ↓
┌─ PharmaciesListPage ───────────────┐
│  Liste des pharmacies              │
│  [FAB: À proximité] ⭐             │ ← Cliquez ici
└────────────────────────────────────┘
            │
            │ Géolocalisation
            ↓
┌─ PharmaciesListPage (proximité) ──┐
│  Pharmacies avec distances         │
│  📍 350 m                          │
│  📍 1.2 km                         │
│  📍 3.8 km                         │
└────────────────────────────────────┘
```

---

## 🎯 Résumé en 3 étapes

1. **Trouver** : Page d'accueil → Carte verte "Pharmacies" 🏥
2. **Ouvrir** : Cliquez sur la carte → Liste des pharmacies
3. **Localiser** : Cliquez sur "À proximité" → Distances affichées 📍

---

**Date** : 29 décembre 2025  
**Version** : 1.0.0+1  
**Status** : ✅ Fonctionnel

Bonne utilisation ! 🎉
