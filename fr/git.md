# GIT

## Liens

- [Ignorer des fichiers](https://help.github.com/articles/ignoring-files/)
- [Fonctionnement de GIT](http://git-scm.com/book/en/v2/Git-Internals-Git-Objects)
- [Supprimer une ref de backup après un `git filter-branch`](https://stackoverflow.com/questions/7654822/remove-refs-original-heads-master-from-git-repo-after-filter-branch-tree-filte) : `git update-ref -d refs/original/refs/heads/master`
- [Lister les fichiers d'un commit](https://stackoverflow.com/questions/424071/list-all-the-files-for-a-commit-in-git) : `git diff-tree --no-commit-id --name-only -r <commit>`

## Recupérer des commits "unreachable"

    git fsck --unreachable --lost-found | \
         grep commit | \
         sed -r -e 's/unreachable commit //g' | \
         while read s; do git branch "dangling/${s}" "$s" ; done

- Crée autant de branche qu'il y a de commits "unreachable".
- Les commits peuvent être invalides si les objets associés ont été supprimés. 

Voir [Stackoverflow](https://stackoverflow.com/questions/8498471/find-all-dangling-commits-with-a-given-ancestor-git).

## Faire des diff sans wrapper

```
GIT_PAGER='less -FRSX' git diff ...
```

## Nettoyage

Faire partir les reflogs inutilisés :

```
    git reflog expire -n --verbose --all
    git reflog expire -n --expire=0days --rewrite --updateref --verbose --all
```

Et supprimer les objets inutilisés :

```
    git gc --aggressive --prune='0 days'
```

## Configuration de git

Pour le proxy :

    git config --global http.proxy x.y.z.a:P

Pour les mots de passe : si on passe par du https, git va demander un mot de passe. Cela peut être évité en jouant avec
la configuration `credential.helper` (qui peut être locale ou globale).

- Cache temporaire : ne demande le mot de passe qu'une fois un certain temps écoulé, ce temps pouvant être configuré.

        git config --global credential.helper cache
    
- Stockage en clair : stocke que dans `~/.git-credentials` l'url `https://user:password@host`.

        git config --global credential.helper store     

## Changer l'auteur ou le committer

```
git filter-branch --commit-filter '
  if [ "$GIT_AUTHOR_EMAIL" =~ "foo.bar@*" ]; then
    GIT_AUTHOR_NAME="Foo Bar"; 
    GIT_AUTHOR_EMAIL="foo.bar@example.com";
  fi
  if [ "$GIT_COMMITTER_EMAIL" =~ "foo.bar@*" ]; then
    GIT_COMMITTER_NAME="Foo Bar";
    GIT_COMMITTER_EMAIL="foo.bar@example.com";
  fi
  
  git commit-tree "$@";
' -- "$@"
```

## Changer le nom de l'utilisateur et son email en local

```
git config --local user.name 'Foo Bar'
git config --local user.email 'foo.bar@example.com'
```

## Changer la date d'un (ou plusieurs) commit

**Note :** on change à la fois la date de création (`GIT_AUTHOR_DATE`) et celle de commit (`GIT_COMMITTER_DATE`).

```
git filter-branch --commit-filter '
  GIT_AUTHOR_DATE="$(date --iso-8601=seconds)"
  GIT_COMMITTER_DATE="${GIT_AUTHOR_DATE}"
  git commit-tree "$@";
' --  "$@"
```

## Positionner l'indicateur _executable_ sur un fichier Bash/etc

Voir cette réponse : [How to create file execute mode permissions in Git on Windows?](https://stackoverflow.com/questions/21691202/how-to-create-file-execute-mode-permissions-in-git-on-windows)


