# Walkthrough - Modification des Utilisateurs (Agents)

La fonctionnalité de modification des comptes agents a été implémentée dans la console d'administration. Vous pouvez désormais corriger les informations d'un membre de l'équipe sans avoir à supprimer et recréer son compte.

## Changements Effectués

### 1. Gestion des Données (Repository)
- **saveAgent** : La méthode d'ajout a été optimisée pour détecter si un compte existe déjà (via son ID). Si c'est le cas, elle met à jour les informations au lieu d'en créer un nouveau.

### 2. Interface de Gestion (`UserManagementPage`)
- **Bouton d'Édition** : Une nouvelle icône "Crayon" (`edit_note_rounded`) est disponible pour chaque agent dans la liste de droite.
- **Formulaire Dynamique** :
    - En cliquant sur modifier, le formulaire de gauche se remplit instantanément avec les données de l'agent.
    - Le titre du formulaire devient **"Modifier le compte Agent"**.
    - Le bouton d'action change de couleur (Orange) et affiche **"Mettre à jour le compte"**.
- **Mode Annulation** : Un bouton **"ANNULER"** apparaît en mode édition pour permettre de vider le formulaire et revenir en mode création d'un clic.

## Comment l'utiliser ?

1. Rendez-vous dans **Utilisateurs & Agents**.
2. Dans la liste des utilisateurs enregistrés, repérez l'agent à modifier.
3. Cliquez sur l'icône **Crayon** à gauche de la corbeille.
4. Modifiez les champs nécessaires (Nom, Rôle, Département, etc.) dans le formulaire.
5. Cliquez sur **Mettre à jour le compte**.

> [!TIP]
> Si vous vous trompez d'utilisateur, cliquez simplement sur le bouton **ANNULER** qui apparaît en haut du formulaire pour réinitialiser les champs.
