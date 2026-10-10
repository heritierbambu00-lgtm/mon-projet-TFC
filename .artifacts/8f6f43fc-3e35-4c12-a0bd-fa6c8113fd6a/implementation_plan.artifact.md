# Plan de Finalisation : Réinscription Réactive et Résultats Étudiants

Ce plan vise à rendre la réinscription (changement de promotion) effective immédiatement pour l'étudiant et à affiner l'affichage des résultats et mentions.

## Problèmes Identifiés
1.  **Réinscription non "appliquée"** : L'étudiant reste bloqué sur son ancienne promotion car ses données sont chargées une seule fois au login.
2.  **Affichage des mentions** : Confusion possible entre "pas encore de notes" et "échec" (0%).

## Modifications Proposées

### 1. Rendre les données utilisateur réactives
#### [MODIFY] [auth_provider.dart](file:///C:/wamp/istm_mahagi/lib/features/auth/presentation/providers/auth_provider.dart)
*   Transformer `currentUserDataProvider` en un `StreamProvider` qui écoute en temps réel le document Firestore de l'utilisateur connecté (si c'est un étudiant).
*   Cela garantit que si un admin change sa promotion, l'application de l'étudiant se met à jour instantanément sans reconnexion.

### 2. Affinage de la page de Résultats
#### [MODIFY] [student_results_page.dart](file:///C:/wamp/istm_mahagi/lib/features/academic/presentation/pages/student_results_page.dart)
*   **Logique des Mentions** :
    *   Calculer la moyenne uniquement sur les cours ayant une note saisie.
    *   Si le nombre de notes est inférieur à un certain seuil (ex: moins de 3 cours saisis), ne pas afficher de "Mention" ni de "Décision du Jury" pour éviter les conclusions hâtives.
    *   Remplacer "ECHEC" par "Session en cours" ou "En attente" si la moyenne pondérée globale n'est pas encore représentative.

## Plan de Vérification
1.  **Vérification Réinscription** :
    *   Ouvrir l'espace étudiant sur un téléphone/simulateur.
    *   Côté Admin (PC), réinscrire l'étudiant dans une autre promotion.
    *   Vérifier que l'espace étudiant change de promotion (et de cours) automatiquement.
2.  **Vérification Résultats** :
    *   Saisir une seule note pour un étudiant.
    *   Vérifier que la page de résultats n'affiche pas encore de mention globale d'échec/réussite tant que le volume de notes est insuffisant.
