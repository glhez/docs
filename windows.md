# Windows

## Restaurer les permissions par défaut sous Windows

Avec une console admin, faire un `icacls <dossier> /reset /C /T`

Où `<dossier>` correspond au dossier ayant des mauvaises permissions.

Description des options (copiée depuis `icacls /?`)

- `/reset` : remplace les listes de contrôle d’accès par les listes héritées par défaut pour tous les fichiers correspondants. **Doit être la première option après le fichier/dossier**.
- `/T` indique que cette opération est effectuée sur tous les fichiers/répertoires correspondants qui se trouvent sous les répertoires spécifiés dans le nom.
- `/C` indique que cette opération se poursuivra sur toutes les erreurs de fichiers. Les messages d’erreurs continueront à s’afficher.


