# Linux

## Firefox / Iceweasel ~ Debian Wheezy

En cas de souci graphique (texte avec rature rouge, jira affichant des rectangles blancs, etc...), lire ce
[lien](http://www.waveguide.se/?article=speed-up-that-sluggish-iceweasel-firefox).

Il y est notamment préconisé de changer `gfx.xrender.enabled` à `false` dans `about:config`.

## Imprimantes sous Debian / Ubuntu

- Aller sur cette URL : http://localhost:631/admin
- Si ça rate, c'est que CUPS n'est pas installé. Veuillez lire cette [documentation](https://wiki.debian.org/fr/CUPS). Même si ça va se résumer à l'installation des paquets `cupsys-bsd`, `cupsys-driver-gimpprint` et `cupsomatic-ppd` pour faire rapide)
- Cliquez sur le bouton Ajouter une imprimante
- Tapez le compte `root` et son mot de passe (j'ai bien dit le root, pas votre utilisateur !). Je ne sais pas s'il y a moyen de le faire avec votre compte normal, la doc d'Ubuntu dit que si, mais l'expérience dit que non.
- Sélectionnez _Internet Printing Protocol_ (http) dans _Autres Imprimantes Réseaux_ puis cliquez _Continuer_
- Dans _Connexion_ rentrez `socket://10.33.1.5` puis cliquez _Continuer_
- Dans l'écran _Nom/Description/Emplacement_, rentrez ce que vous voulez (j'ai mis _HP-LasetJet-P3015_ comme nom et _Imprimante DSI_ comme description). Puis cliquez sur _Continuer_.
- Il vous faudra choisir la marque, qui sera _HP_. Puis cliquez sur _Continuer_.
- Dans le modèle, sélectionnez _HP LaserJet P3010 Series Postscript (recommended)_ et enfin cliquez sur _Ajouter une imprimante_.

## Afficher les caractères cachés avec `cat`

`cat -A` pour afficher les caractères cachés avec `cat` (voir aussi doc sur vim).


## Convertir des noms de fichier non UTF-8 (typiquement provenant d'un vieux disques NTFS/FAT)

```
convmv -f cp1252 -t utf-8 -r *
```

