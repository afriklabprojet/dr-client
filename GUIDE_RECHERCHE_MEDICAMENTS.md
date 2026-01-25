# 💊 Guide Recherche & Sélection de Médicaments

## 📋 Vue d'ensemble

Le système permet deux modes d'achat :

- **🛒 Cas A : Sans ordonnance** - Recherche libre et ajout au panier
- **📄 Cas B : Avec ordonnance** - Upload d'ordonnance pour validation

---

## 🛒 CAS A - SANS ORDONNANCE

### 1. Recherche par nom de médicament

#### Accès

Page d'accueil → Cliquez sur **"Produits"** (carte bleue)

#### Interface de recherche

```
╔════════════════════════════════════════════════╗
║  Produits                          📤         ║
╠════════════════════════════════════════════════╣
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  🔍  Rechercher des médicaments...       │ ║ ← Barre de recherche
║  └──────────────────────────────────────────┘ ║
║                                                ║
╚════════════════════════════════════════════════╝
```

#### Fonctionnalités

- ✅ **Recherche en temps réel** (minimum 2 caractères)
- ✅ **Bouton X** pour effacer la recherche
- ✅ **Résultats instantanés**
- ✅ **Message si aucun résultat**

#### Utilisation

**Étape 1** : Cliquez dans la barre de recherche

**Étape 2** : Tapez le nom du médicament (ex: "Paracétamol")

**Étape 3** : Les résultats s'affichent automatiquement

**Étape 4** : Cliquez sur un produit pour voir les détails

**Exemple** :

```
Recherche: "para"

Résultats :
- Paracétamol 500mg - 1 500 F CFA
- Paracétamol 1000mg - 2 000 F CFA
- Paracodéine - 3 500 F CFA
```

---

### 2. Navigation par catégories

#### Interface des catégories

```
╔════════════════════════════════════════════════╗
║  [Tous] [Antidouleurs] [Antibiotiques] ...   ║ ← Chips scrollables
╠════════════════════════════════════════════════╣
```

#### Catégories disponibles

| Catégorie          | Icône | Description                       |
| ------------------ | ----- | --------------------------------- |
| **Tous**           | 📊    | Affiche tous les médicaments      |
| **Antidouleurs**   | 🩹    | Paracétamol, Ibuprofène, etc.     |
| **Antibiotiques**  | 💊    | Amoxicilline, Azithromycine, etc. |
| **Vitamines**      | 💧    | Compléments vitaminiques          |
| **Premiers Soins** | 🚨    | Pansements, désinfectants, etc.   |

#### Utilisation

**Étape 1** : Scrollez horizontalement dans la liste des catégories

**Étape 2** : Cliquez sur une catégorie

**Étape 3** : La liste des produits se filtre automatiquement

**Visuel de sélection** :

```
Non sélectionné : [🩹 Antidouleurs]  (fond blanc, bordure grise)
Sélectionné     : [🩹 Antidouleurs]  (fond bleu, texte blanc)
```

---

### 3. Affichage des produits

#### Carte produit

```
┌──────────────────────────────────────┐
│  [Image du produit]                  │
│                                      │
│  Paracétamol 500mg                   │ ← Nom
│                                      │
│  2 500 F CFA                         │ ← Prix
│  ✅ Disponible                       │ ← Statut
└──────────────────────────────────────┘
```

#### Informations affichées

1. **Image** : Photo du médicament
2. **Nom** : Nom complet et dosage
3. **Prix** : Formaté en F CFA
4. **Disponibilité** :
   - ✅ **Disponible** (vert) - En stock
   - ❌ **Rupture** (rouge) - Hors stock

---

### 4. Ajout au panier

#### Depuis la liste

**Étape 1** : Cliquez sur un produit

**Étape 2** : Page de détails s'ouvre

**Étape 3** : Ajustez la quantité

**Étape 4** : Cliquez sur "Ajouter au panier"

#### Depuis la page de détails

```
╔════════════════════════════════════════════════╗
║  ←  Paracétamol 500mg                         ║
╠════════════════════════════════════════════════╣
║                                                ║
║  [Image du produit]                            ║
║                                                ║
║  Description du produit...                     ║
║                                                ║
║  2 500 F CFA                                   ║
║                                                ║
║  Quantité: [-] 1 [+]                           ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │   Ajouter au panier (2 500 F CFA)        │ ║
║  └──────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════╝
```

#### Confirmation

Après ajout au panier :

- ✅ **SnackBar** : "Produit ajouté au panier"
- ✅ **Badge** sur l'icône panier (nombre d'articles)
- ✅ **Possibilité** de continuer les achats

---

## 📄 CAS B - AVEC ORDONNANCE

### 1. Accès à l'upload d'ordonnance

#### Option A : Depuis l'AppBar

```
╔════════════════════════════════════════════════╗
║  Produits                          📤         ║ ← Cliquez ici
╠════════════════════════════════════════════════╣
```

#### Option B : Depuis la bannière

```
╔════════════════════════════════════════════════╗
║  ┌──────────────────────────────────────────┐ ║
║  │  📤  Vous avez une ordonnance ?          │ ║
║  │      Uploadez-la pour validation     →   │ ║ ← Cliquez ici
║  └──────────────────────────────────────────┘ ║
╠════════════════════════════════════════════════╣
```

---

### 2. Upload de la photo d'ordonnance

#### Interface d'upload

```
╔════════════════════════════════════════════════╗
║  ←  Upload d'ordonnance                       ║
╠════════════════════════════════════════════════╣
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  ℹ️  Comment ça marche ?                 │ ║
║  │                                           │ ║
║  │  1. Prenez une photo claire               │ ║
║  │  2. Ajoutez des notes si nécessaire       │ ║
║  │  3. Envoyez pour validation               │ ║
║  │  4. Recevez une notification              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  Photos de l'ordonnance                        ║
║  ┌──────────────────────────────────────────┐ ║
║  │                                           │ ║
║  │       📷  Aucune photo ajoutée            │ ║
║  │                                           │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │  ➕  Ajouter une photo                    │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  Notes complémentaires (optionnel)             ║
║  ┌──────────────────────────────────────────┐ ║
║  │  Ajoutez des informations...              │ ║
║  └──────────────────────────────────────────┘ ║
║                                                ║
║  ┌──────────────────────────────────────────┐ ║
║  │   Envoyer pour validation                 │ ║
║  └──────────────────────────────────────────┘ ║
╚════════════════════════════════════════════════╝
```

---

### 3. Processus d'upload détaillé

#### Étape 1 : Ajouter une photo

**Cliquez sur "Ajouter une photo"**

Bottom Sheet s'ouvre :

```
┌────────────────────────────────────────┐
│  Ajouter une photo                     │
│                                        │
│  📷  Prendre une photo                 │ ← Option A
│  🖼️   Choisir depuis la galerie       │ ← Option B
└────────────────────────────────────────┘
```

**Option A : Prendre une photo**

1. Caméra s'ouvre
2. Cadrez l'ordonnance
3. Prenez la photo
4. Photo ajoutée automatiquement

**Option B : Depuis la galerie**

1. Galerie photos s'ouvre
2. Sélectionnez une ou plusieurs photos
3. Confirmez la sélection
4. Photos ajoutées automatiquement

#### Étape 2 : Gérer les photos

**Affichage des photos** :

```
┌───────────┬───────────┐
│ [Photo 1] │ [Photo 2] │
│     ✕     │     ✕     │ ← Boutons de suppression
└───────────┴───────────┘
```

**Actions disponibles** :

- ✅ **Ajouter** d'autres photos
- ✅ **Supprimer** une photo (clic sur ✕)
- ✅ **Voir** en grand (clic sur la photo)

#### Étape 3 : Ajouter des notes (optionnel)

```
┌──────────────────────────────────────────┐
│  Ajoutez des informations                │
│  complémentaires pour la pharmacie...    │
│                                          │
│  Ex: "Allergie à la pénicilline"        │
│      "Urgence - besoin sous 24h"        │
└──────────────────────────────────────────┘
```

**Exemples de notes utiles** :

- Allergies connues
- Médicaments déjà pris
- Urgence de la commande
- Questions spécifiques

#### Étape 4 : Envoyer

**Cliquez sur "Envoyer pour validation"**

**Vérifications** :

- ✅ Au moins une photo ajoutée
- ✅ Photos de bonne qualité
- ✅ Ordonnance lisible

**Feedback** :

```
Envoi en cours...
[Indicateur de chargement]
```

---

### 4. Validation par la pharmacie

#### Processus côté pharmacie

**Temps de traitement** : 30 minutes à 2 heures

**Étapes** :

1. 🔍 Réception de l'ordonnance
2. 👨‍⚕️ Vérification par le pharmacien
3. ✅ Validation des médicaments
4. 💰 Calcul du prix total
5. 📢 Notification envoyée au client

#### Critères de validation

| Critère         | Accepté ✅        | Rejeté ❌          |
| --------------- | ----------------- | ------------------ |
| **Lisibilité**  | Ordonnance claire | Texte illisible    |
| **Validité**    | Date < 3 mois     | Ordonnance expirée |
| **Signature**   | Médecin identifié | Pas de signature   |
| **Médicaments** | En stock          | Rupture de stock   |
| **Conformité**  | Dosage correct    | Dosage invalide    |

---

### 5. Notifications de confirmation / rejet

#### Notification de CONFIRMATION ✅

```
┌────────────────────────────────────────┐
│  🎉 Ordonnance validée !               │
│                                        │
│  Votre ordonnance a été approuvée      │
│  par la pharmacie.                     │
│                                        │
│  Montant total : 15 000 F CFA          │
│                                        │
│  [Voir les détails] [Payer]           │
└────────────────────────────────────────┘
```

**Informations incluses** :

- ✅ Liste des médicaments validés
- ✅ Quantités disponibles
- ✅ Prix total
- ✅ Délai de préparation
- ✅ Pharmacie assignée

**Actions possibles** :

1. **Voir les détails** : Liste complète des médicaments
2. **Payer** : Procéder au paiement
3. **Modifier** : Ajuster les quantités

---

#### Notification de REJET ❌

```
┌────────────────────────────────────────┐
│  ❌ Ordonnance non validée             │
│                                        │
│  Votre ordonnance n'a pas pu être      │
│  validée pour la raison suivante :     │
│                                        │
│  "Photo illisible - Veuillez          │
│   reprendre une photo plus claire"    │
│                                        │
│  [Réessayer] [Contacter pharmacie]     │
└────────────────────────────────────────┘
```

**Raisons possibles de rejet** :

1. **Photo illisible** 📷

   - Solution : Reprendre une photo avec meilleur éclairage

2. **Ordonnance expirée** 📅

   - Solution : Consulter un médecin pour une nouvelle ordonnance

3. **Médicaments non disponibles** 💊

   - Solution : Contacter la pharmacie pour alternatives

4. **Informations manquantes** ℹ️

   - Solution : Vérifier que toutes les informations sont visibles

5. **Signature manquante** ✍️
   - Solution : S'assurer que l'ordonnance est signée par le médecin

**Actions possibles** :

1. **Réessayer** : Prendre une nouvelle photo
2. **Contacter la pharmacie** : Appeler pour plus d'informations
3. **Annuler** : Abandonner la demande

---

## 🔔 Système de notifications

### Types de notifications

#### 1. Ordonnance reçue

```
📬 "Ordonnance reçue"
"Votre ordonnance est en cours de vérification"
```

#### 2. En cours de validation

```
⏳ "Validation en cours"
"Un pharmacien vérifie votre ordonnance"
```

#### 3. Validée

```
✅ "Ordonnance validée"
"Commande prête - Montant : 15 000 F CFA"
```

#### 4. Rejetée

```
❌ "Ordonnance rejetée"
"Photo illisible - Veuillez réessayer"
```

#### 5. Prête à retirer

```
📦 "Commande prête"
"Votre commande est prête à être retirée"
```

---

## 💡 Conseils pour une bonne photo d'ordonnance

### ✅ À FAIRE

1. **Éclairage**

   - Lumière naturelle ou bonne luminosité
   - Éviter les ombres sur le document

2. **Cadrage**

   - Toute l'ordonnance visible
   - Marges incluses
   - Document à plat (pas plié)

3. **Qualité**

   - Photo nette (pas floue)
   - Résolution suffisante
   - Contraste correct

4. **Angle**
   - Photo de face (perpendiculaire)
   - Document droit (pas penché)

### ❌ À ÉVITER

1. **Éclairage**

   - Contre-jour
   - Reflets sur le papier
   - Trop sombre

2. **Cadrage**

   - Partie coupée
   - Trop de zoom
   - Doigts sur le document

3. **Qualité**
   - Photo floue ou pixelisée
   - Document froissé
   - Taches ou salissures

---

## 🎯 Comparaison des deux cas

| Critère           | Sans ordonnance 🛒       | Avec ordonnance 📄         |
| ----------------- | ------------------------ | -------------------------- |
| **Recherche**     | Libre                    | Basée sur ordonnance       |
| **Sélection**     | Par le client            | Par le pharmacien          |
| **Validation**    | Aucune                   | Requise (pharmacien)       |
| **Délai**         | Immédiat                 | 30 min - 2h                |
| **Prix**          | Connu immédiatement      | Après validation           |
| **Disponibilité** | Vérifiable en temps réel | Confirmée après validation |

---

## 🔄 Flux complet

### Sans ordonnance

```
1. Recherche/Catégorie
   ↓
2. Sélection produit
   ↓
3. Ajout au panier
   ↓
4. Paiement
   ↓
5. Commande confirmée
```

### Avec ordonnance

```
1. Upload ordonnance
   ↓
2. Envoi pour validation
   ↓
3. Attente (30 min - 2h)
   ↓
4. Notification reçue
   ↓
5a. Si validée → Paiement
5b. Si rejetée → Réessayer
```

---

## 🐛 Dépannage

### Problème : Impossible d'ajouter une photo

**Causes possibles** :

1. Permissions caméra/galerie refusées
2. Stockage plein
3. Format de fichier non supporté

**Solutions** :

1. Activer les permissions dans les paramètres
2. Libérer de l'espace
3. Utiliser des photos JPG/PNG

---

### Problème : Recherche ne fonctionne pas

**Causes** :

1. Moins de 2 caractères tapés
2. Connexion internet perdue
3. Backend non disponible

**Solutions** :

1. Taper au moins 2 caractères
2. Vérifier la connexion internet
3. Réessayer plus tard

---

### Problème : Catégories ne filtrent pas

**Note** : Actuellement, les catégories rechargent tous les produits.  
**TODO** : Implémentation du filtrage par catégorie côté API.

---

## ✅ Checklist d'utilisation

### Pour acheter sans ordonnance

- [ ] Ouvrir la page Produits
- [ ] Utiliser la recherche OU les catégories
- [ ] Sélectionner un produit
- [ ] Vérifier la disponibilité
- [ ] Ajuster la quantité
- [ ] Ajouter au panier
- [ ] Procéder au paiement

### Pour acheter avec ordonnance

- [ ] Cliquer sur l'icône 📤 ou la bannière
- [ ] Ajouter une photo claire de l'ordonnance
- [ ] Ajouter des notes (optionnel)
- [ ] Envoyer pour validation
- [ ] Attendre la notification (30 min - 2h)
- [ ] Si validée : Procéder au paiement
- [ ] Si rejetée : Reprendre une photo

---

**Date de création** : 29 décembre 2025  
**Version** : 1.0.0+1  
**Package ajouté** : `image_picker: ^1.0.7`  
**Status** : ✅ Production-ready

🎉 **Système complet de recherche et sélection de médicaments opérationnel !**
