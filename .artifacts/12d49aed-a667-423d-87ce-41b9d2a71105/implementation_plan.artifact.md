# Plan de Finalisation du CMS Institutionnel et Optimisation de l'Accueil

Ce plan vise à rendre la gestion institutionnelle 100% opérationnelle, à sublimer le design des formulaires et à optimiser la page d'accueil pour une navigation fluide vers les détails.

## Changements Proposés

### 1. [DATA] Centralisation de la Gestion (CMS)
- [MODIFY] [info_repository.dart](file:///C:/wamp/istm_mahagi/lib/features/info/data/repositories/info_repository.dart)
  - Ajout des méthodes de gestion pour **Actualités** (News) et **Galerie**.
  - Finalisation des méthodes de mise à jour et suppression pour toutes les sections (7 fonctions).

### 2. [UI ADMIN] Console CMS Ultra-Premium
- [MODIFY] [institutional_management_page.dart](file:///C:/wamp/istm_mahagi/lib/features/info/presentation/pages/institutional_management_page.dart)
  - Réduction de la taille des cartes pour une grille plus compacte et élégante.
  - Ajout de la carte **"Actualités"**.
  - Suppression du message "Coming Soon" et activation de tous les liens.
- [NEW] Création des pages de gestion manquantes :
  - `AnthemManagementPage`
  - `StatutesManagementPage`
  - `GalleryManagementPage`
  - `NewsManagementPage`
- [MODIFY] Raffinement de tous les formulaires :
  - Design sombre (Midnight Navy).
  - Listes d'éléments en bas de page avec options **Modifier** et **Supprimer**.

### 3. [UI PUBLIC] Optimisation de la Page d'Accueil
- [MODIFY] [home_page.dart](file:///C:/wamp/istm_mahagi/lib/features/home/presentation/pages/home_page.dart)
  - **Limitation** : Affichage de seulement **2 éléments** pour les News, la Galerie et le Comité.
  - **Navigation** : Ajout d'un bouton **"VOIR PLUS"** ou **"VOIR TOUT"** stylisé sur chaque section pour rediriger vers la page complète.

## Plan de Vérification
- **Admin** : Ajouter un membre du comité avec photo et vérifier son apparition en bas de page.
- **Suppression** : Supprimer une actualité et vérifier qu'elle disparaît de l'accueil.
- **Navigation** : Cliquer sur "Voir plus" dans la galerie de l'accueil et vérifier l'arrivée sur `GalleryPage`.

> [!IMPORTANT]
> Toutes les pages de gestion adopteront le style **Dark-Premium** pour une cohérence totale avec le reste de l'administration.
