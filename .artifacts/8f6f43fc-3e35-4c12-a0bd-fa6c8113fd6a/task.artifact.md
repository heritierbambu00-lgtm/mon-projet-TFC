# Tâches pour la Réactivité et les Résultats Étudiants

- [x] **Rendre les données utilisateur réactives**
    - [x] Modifier `AuthRepository` pour ajouter un stream de données utilisateur.
    - [x] Mettre à jour `auth_provider.dart` pour utiliser un `StreamProvider`.
- [x] **Affinement de la page Résultats**
    - [x] Adapter le calcul des moyennes (uniquement sur les cours avec notes).
    - [x] Gérer l'affichage conditionnel des mentions (masquer si données insuffisantes).
    - [x] Améliorer les messages d'état (remplacer "ECHEC" par "Session en cours").
- [x] **Vérification**
    - [x] Vérifier que le changement de promo est instantané côté étudiant.
    - [x] Vérifier qu'un étudiant sans notes ne voit pas de mention d'échec.
