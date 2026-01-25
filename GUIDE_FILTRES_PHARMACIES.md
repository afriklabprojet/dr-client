# 🔍 Guide des Filtres - Pharmacies à Proximité

## 📋 Vue d'ensemble

Le système de filtrage permet de personnaliser l'affichage des pharmacies selon :

- **Distance** : < 1 km, < 5 km, < 10 km, ou toutes distances
- **Disponibilité** : Ouvertes seulement, Fermées seulement, ou Toutes

---

## 🎯 Accéder aux filtres

### Prérequis

Les filtres sont disponibles **uniquement en mode "Pharmacies à proximité"**

### Étapes

1. Activez le mode géolocalisation :
   - Cliquez sur le FAB "À proximité" OU
   - Cliquez sur l'icône 📍 dans l'AppBar
2. Accordez les permissions de localisation
3. Une fois en mode proximité, cliquez sur l'**icône de filtre** 🔽 dans l'AppBar

---

## 🎨 Interface des filtres

### Vue du Bottom Sheet

```
╔═══════════════════════════════════════════╗
║  Filtres                            ✕     ║
╠═══════════════════════════════════════════╣
║                                           ║
║  Distance maximale                        ║
║  ┌───────────┐ ┌───────────┐            ║
║  │ Toutes ✓  │ │   < 1 km  │            ║
║  └───────────┘ └───────────┘            ║
║  ┌───────────┐ ┌───────────┐            ║
║  │  < 5 km   │ │  < 10 km  │            ║
║  └───────────┘ └───────────┘            ║
║                                           ║
║  Disponibilité                            ║
║  ┌───────────┐ ┌─────────────────┐      ║
║  │ Toutes ✓  │ │ Ouvertes 🟢     │      ║
║  └───────────┘ └─────────────────┘      ║
║  ┌─────────────────┐                     ║
║  │ Fermées 🔴      │                     ║
║  └─────────────────┘                     ║
║                                           ║
║  ┌────────────┐  ┌────────────┐         ║
║  │Réinitialiser│  │  Appliquer │         ║
║  └────────────┘  └────────────┘         ║
║                                           ║
╚═══════════════════════════════════════════╝
```

---

## 🔽 Types de filtres

### 1. Filtre de Distance

**Options disponibles** :

#### Toutes distances (par défaut)

- Affiche toutes les pharmacies dans le rayon de recherche (10 km)
- Aucune restriction de distance

#### < 1 km

- Affiche uniquement les pharmacies à moins de 1 kilomètre
- Idéal pour les pharmacies très proches

#### < 5 km

- Affiche les pharmacies dans un rayon de 5 km
- Bon compromis entre proximité et choix

#### < 10 km

- Affiche les pharmacies dans un rayon de 10 km
- Maximum de résultats disponibles

**Indicateurs visuels** :

- Puce bleue (✓) sur le filtre actif
- Bordure bleue autour du chip sélectionné
- Icône de règle (📏) dans le chip actif

---

### 2. Filtre de Disponibilité

**Options disponibles** :

#### Toutes (par défaut)

- Affiche toutes les pharmacies (ouvertes et fermées)
- Aucun filtrage sur le statut

#### Ouvertes seulement 🟢

- Affiche uniquement les pharmacies actuellement ouvertes
- Chip vert avec icône ✓
- Pratique pour trouver une pharmacie disponible immédiatement

#### Fermées seulement 🔴

- Affiche uniquement les pharmacies actuellement fermées
- Chip rouge avec icône ✕
- Utile pour planifier une visite ultérieure

**Indicateurs visuels** :

- Puce verte (✓) pour "Ouvertes"
- Puce rouge (✕) pour "Fermées"
- Fond coloré selon le filtre actif

---

## 📊 Affichage des filtres actifs

### Chips de filtres actifs

Lorsque des filtres sont appliqués, des **chips** apparaissent sous l'AppBar :

```
╔════════════════════════════════════════════════╗
║  ←  Pharmacies à proximité     🔽  📋          ║
╠════════════════════════════════════════════════╣
║                                                ║
║  📏 < 5 km  ✕     🟢 Ouvertes seulement  ✕   ║ ← Filtres actifs
║                                                ║
╠════════════════════════════════════════════════╣
║  [Pharmacies filtrées...]                      ║
```

**Fonctionnalités** :

- Affichage compact des filtres appliqués
- Bouton ✕ pour supprimer un filtre individuel
- Couleurs distinctives selon le type de filtre

---

## 🎯 Utilisation des filtres

### Scénario 1 : Pharmacies ouvertes à moins de 1 km

**Objectif** : Trouver une pharmacie ouverte très proche

**Étapes** :

1. Activez le mode "À proximité"
2. Cliquez sur l'icône de filtre 🔽
3. Sélectionnez **"< 1 km"** dans Distance
4. Sélectionnez **"Ouvertes seulement"** dans Disponibilité
5. Cliquez sur **"Appliquer"**

**Résultat** :

```
╔════════════════════════════════════════════════╗
║  📏 < 1 km  ✕     🟢 Ouvertes seulement  ✕   ║
╠════════════════════════════════════════════════╣
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie Centrale                  │ ║
║  │      🟢 Ouverte  📍 350 m                │ ║
║  │      📍 Boulevard Latrille, Abidjan      │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🏥  Pharmacie du Plateau                │ ║
║  │      🟢 Ouverte  📍 870 m                │ ║
║  │      📍 Plateau, Abidjan                 │ ║
║  └──────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════╝
```

---

### Scénario 2 : Toutes les pharmacies dans 5 km

**Objectif** : Voir toutes les options dans un rayon raisonnable

**Étapes** :

1. Mode "À proximité" activé
2. Cliquez sur l'icône de filtre
3. Sélectionnez **"< 5 km"**
4. Laissez **"Toutes"** pour Disponibilité
5. Appliquez

**Résultat** : Liste avec pharmacies ouvertes et fermées, toutes < 5 km

---

### Scénario 3 : Pharmacies fermées (pour planification)

**Objectif** : Voir les pharmacies fermées pour planifier une visite

**Étapes** :

1. Mode "À proximité" activé
2. Filtres → Sélectionnez **"Fermées seulement"**
3. Appliquez

**Utilité** :

- Planifier une visite pour plus tard
- Vérifier les options à proximité pour le lendemain
- Comparer les pharmacies disponibles

---

## 🔄 Gestion des filtres

### Réinitialiser les filtres

**Méthode 1 : Bouton "Réinitialiser"**

- Ouvrez le bottom sheet des filtres
- Cliquez sur **"Réinitialiser"**
- Tous les filtres reviennent à "Toutes"

**Méthode 2 : Supprimer un chip**

- Cliquez sur le ✕ d'un chip actif
- Le filtre est immédiatement supprimé
- La liste se met à jour automatiquement

**Méthode 3 : Revenir au mode "Toutes"**

- Cliquez sur l'icône 📋 dans l'AppBar
- Retour au mode sans filtres
- Toutes les pharmacies s'affichent

---

## 💡 Bonnes pratiques

### Optimiser vos recherches

1. **Urgence** → Filtre "Ouvertes + < 1 km"

   - Résultats immédiats
   - Pharmacies accessibles rapidement

2. **Comparaison** → "Toutes + < 5 km"

   - Vue d'ensemble des options
   - Permet de comparer les distances

3. **Planification** → "Fermées + Toutes distances"

   - Voir toutes les pharmacies
   - Planifier pour plus tard

4. **Exploration** → Pas de filtres
   - Découvrir toutes les pharmacies
   - Élargir les possibilités

---

## 📱 Indicateurs visuels

### Couleurs des chips

| Filtre   | Couleur  | Signification             |
| -------- | -------- | ------------------------- |
| Distance | 🔵 Bleu  | Filtre géographique actif |
| Ouvertes | 🟢 Vert  | Disponibilité immédiate   |
| Fermées  | 🔴 Rouge | Actuellement fermées      |

### Icônes

| Icône | Signification                       |
| ----- | ----------------------------------- |
| 🔽    | Ouvrir les filtres                  |
| 📏    | Filtre de distance                  |
| ✓     | Pharmacie ouverte                   |
| ✕     | Pharmacie fermée / Supprimer filtre |
| 📍    | Localisation                        |

---

## 🐛 Dépannage

### Problème : Icône de filtre non visible

**Cause** : Vous n'êtes pas en mode "À proximité"

**Solution** :

1. Activez d'abord la géolocalisation
2. L'icône 🔽 apparaîtra dans l'AppBar

---

### Problème : "Aucune pharmacie ne correspond aux filtres"

**Causes possibles** :

1. Filtres trop restrictifs (ex: < 1 km + Ouvertes, mais aucune ouverte à proximité)
2. Peu de pharmacies dans la zone

**Solutions** :

1. **Élargir la distance** : Passer de < 1 km à < 5 km
2. **Retirer le filtre de disponibilité** : Voir toutes les pharmacies
3. **Réinitialiser** : Bouton "Réinitialiser" dans les filtres

---

### Problème : Filtres ne s'appliquent pas

**Solution** :

1. Assurez-vous de cliquer sur **"Appliquer"** après sélection
2. Vérifiez que les chips apparaissent sous l'AppBar
3. Si problème persiste, fermez et rouvrez le bottom sheet

---

### Problème : Distances non calculées

**Cause** : Problème de géolocalisation

**Solution** :

1. Vérifiez que le GPS est activé
2. Accordez les permissions de localisation
3. Réactivez le mode "À proximité"

---

## 🎨 Combinaisons de filtres

### Recommandations par situation

| Situation            | Distance | Disponibilité | Résultat attendu                     |
| -------------------- | -------- | ------------- | ------------------------------------ |
| **Urgence médicale** | < 1 km   | Ouvertes      | Pharmacies immédiatement accessibles |
| **Recherche rapide** | < 5 km   | Ouvertes      | Bon équilibre proximité/choix        |
| **Comparaison**      | < 10 km  | Toutes        | Vue complète des options             |
| **Planification**    | Toutes   | Fermées       | Pharmacies pour visite ultérieure    |
| **Découverte**       | Toutes   | Toutes        | Exploration complète                 |

---

## 📊 Exemples d'affichage

### Sans filtres (mode proximité)

```
🏥 Pharmacie A - 🟢 Ouverte - 📍 350 m
🏥 Pharmacie B - 🔴 Fermée - 📍 1.2 km
🏥 Pharmacie C - 🟢 Ouverte - 📍 2.8 km
🏥 Pharmacie D - 🔴 Fermée - 📍 4.5 km
🏥 Pharmacie E - 🟢 Ouverte - 📍 7.3 km
```

### Avec filtre "< 5 km"

```
📏 < 5 km  ✕

🏥 Pharmacie A - 🟢 Ouverte - 📍 350 m
🏥 Pharmacie B - 🔴 Fermée - 📍 1.2 km
🏥 Pharmacie C - 🟢 Ouverte - 📍 2.8 km
🏥 Pharmacie D - 🔴 Fermée - 📍 4.5 km
```

### Avec filtres "< 5 km + Ouvertes"

```
📏 < 5 km  ✕     🟢 Ouvertes seulement  ✕

🏥 Pharmacie A - 🟢 Ouverte - 📍 350 m
🏥 Pharmacie C - 🟢 Ouverte - 📍 2.8 km
```

---

## ✅ Checklist d'utilisation

### Pour trouver une pharmacie ouverte proche

- [ ] Activer le mode "À proximité"
- [ ] Accorder les permissions GPS
- [ ] Ouvrir les filtres (icône 🔽)
- [ ] Sélectionner "< 1 km" ou "< 5 km"
- [ ] Sélectionner "Ouvertes seulement"
- [ ] Appliquer les filtres
- [ ] Vérifier les résultats
- [ ] Cliquer sur une pharmacie pour voir les détails

---

## 🚀 Fonctionnalités avancées

### Tri automatique

Les pharmacies sont **toujours triées par distance** en mode proximité :

- La plus proche apparaît en premier
- Les filtres conservent ce tri
- Facilite la recherche de l'option la plus accessible

### Mise à jour en temps réel

Les filtres s'appliquent instantanément :

- Pas besoin de recharger la page
- Changements visibles immédiatement
- Chips actifs mis à jour automatiquement

### Persistance visuelle

Les chips restent visibles pendant la navigation :

- Rappel constant des filtres actifs
- Suppression facile d'un filtre
- Indication claire de l'état de filtrage

---

## 📝 Notes importantes

⚠️ **Les filtres sont disponibles uniquement en mode "À proximité"**

⚠️ **La distance est calculée à vol d'oiseau, pas par itinéraire**

ℹ️ **Les filtres se réinitialisent si vous quittez le mode proximité**

ℹ️ **Vous pouvez combiner tous les types de filtres**

---

**Date de création** : 29 décembre 2025  
**Version** : 1.0.0+1  
**Status** : ✅ Production-ready

🎉 **Utilisez les filtres pour personnaliser votre recherche de pharmacies !**
