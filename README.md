# devloppement_mobile


Ce dépôt contient le projet final de développement mobile, composé de :
- **Une application mobile d’administration** (`admin_mobile`) développée avec **Flutter**.
- **Un backend API** (`backend`) développé avec **Laravel**.
- Le tout regroupé dans le dossier principal [devloppement_mobile]

---

## 1. Structure du projet

- [devloppement_mobile/]
  - `admin_mobile/`  
    Application mobile Flutter (interface d’administration).
  - `backend/`  
    API REST réalisée avec Laravel (gestion des données, authentification, etc.).

---

## 2. Prérequis

- **Général**
  - Git
  - PHP ≥ 8.x
  - Composer
  - Serveur web local type XAMPP  (MySQL)
  -laravel
  -flutter

- **Pour l’app mobile (`admin_mobile`)**
  - Flutter SDK (version compatible avec le projet)
  - Android Studio et VS Code avec les extensions Flutter/Dart
  - Un émulateur Android 

- **Pour le backend (`backend`)**
  - PHP ≥ 8.x
  - Composer
  - MySQL 
 

---

## 3. Installation du backend (Laravel)

1. Aller dans le dossier du backend :

   ```bash
   cd devloppement_mobile/backend
## Fonctionnalités

- **Authentification administrateur**
  - Connexion sécurisée de l’administrateur via l’API Laravel.
  - Protection des routes par token (Laravel Sanctum) et middleware `IsAdmin`.

- **Dashboard administrateur**
  - Accès à un tableau de bord récapitulatif.
  - Vue globale sur l’activité de location des caftans.

- **Gestion des caftans**
  - Création, modification, suppression de caftans (nom, description, prix/jour, catégorie, disponibilité…).
  - Gestion des catégories, couleurs et tailles associées.
  - Upload de plusieurs images par caftan, avec image principale et ordre d’affichage.
  - Recherche par nom, filtrage par catégorie et par disponibilité (disponible / loué).
  - Indicateur automatique de disponibilité en fonction des locations actives.

- **Gestion des clients**
  - Création, modification, suppression de fiches clients.
  - Informations stockées : nom, CIN, téléphone, email, adresse, notes.
  - Recherche de client par CIN.
  - Consultation de l’historique des locations d’un client.

- **Gestion des locations de caftans**
  - Création d’une nouvelle location en associant un client et un caftan.
  - Deux modes pour le client :
    - sélection d’un client existant,
    - création d’un nouveau client au moment de la réservation.
  - Sélection de la période de location (date de début et de fin).
  - Calcul automatique du nombre de jours et du prix total (jours × prix/jour).
  - Gestion de la caution (avance) et du statut de paiement :
    - `pending` (en attente),
    - `partial` (partiel),
    - `paid` (payé).
  - Suivi du statut de la location :
    - `active` (en cours),
    - `returned` (retournée),
    - `cancelled` (annulée).
  - Mise à jour automatique de la disponibilité du caftan selon le statut de la location.
  - Filtrage des locations par statut, paiement, caftan et plage de dates.

- **Vitrine des caftans**
  - Écran vitrine affichant une sélection de caftans avec images, catégorie et prix/jour.
  - Filtrage par catégorie.
  - Consultation du détail d’un caftan, avec galerie d’images et description.

- **Intégration Flutter ↔ Laravel**
  - L’application mobile Flutter consomme l’API Laravel pour toutes les opérations :
    - authentification,
    - gestion des caftans, clients et locations,
    - vérification de la disponibilité d’un caftan sur une période donnée.