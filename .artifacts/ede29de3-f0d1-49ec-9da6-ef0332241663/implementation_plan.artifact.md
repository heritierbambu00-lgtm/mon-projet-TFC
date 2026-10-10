# Possibilité de modifier les utilisateurs (Agents)

Ce plan vise à ajouter la fonctionnalité de modification des comptes agents dans l'interface de gestion de l'équipe académique.

## Proposed Changes

### [Auth Feature - User Management]

#### [MODIFY] [user_management_repository.dart](file:///C:/wamp/istm_mahagi/lib/features/auth/data/repositories/user_management_repository.dart)
- Modifier `addAgent` pour supporter la mise à jour si un ID est présent (utilisation de `doc(id).set` au lieu de `add`).

#### [MODIFY] [user_management_page.dart](file:///C:/wamp/istm_mahagi/lib/features/auth/presentation/pages/user_management_page.dart)
- Ajouter une variable d'état `_editingAgentId` pour suivre si on est en mode édition.
- Mettre à jour `_addAgent` (peut être renommé `_saveAgent`) pour gérer l'ID lors de l'enregistrement.
- Ajouter un bouton d'édition (icône crayon) dans chaque ligne de la liste des utilisateurs.
- Créer une fonction `_startEditing(UtilisateurEntity agent)` qui remplit les contrôleurs avec les données de l'agent.
- Modifier le bouton principal du formulaire pour afficher "Mettre à jour le compte" quand on est en mode édition.
- Ajouter un bouton "Annuler la modification" pour réinitialiser le formulaire.

## Verification Plan

### Manual Verification
1. Accéder à la page "Gestion de l'Équipe Académique".
2. Cliquer sur l'icône de modification d'un utilisateur existant.
3. Vérifier que les champs se remplissent correctement.
4. Modifier une information (ex: le rôle ou le nom).
5. Cliquer sur "Mettre à jour le compte".
6. Vérifier que la liste se met à jour instantanément et que le formulaire se réinitialise.
7. Tester le bouton "Annuler" pour s'assurer qu'il vide bien les champs et repasse en mode "Créer".
