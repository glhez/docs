# SSH / Putty

## Utiliser une clef publique/privée au lieu d'un mot de passe avec Putty

Les deux premières étapes sont optionnelles.

1. Génération de la clef: `ssh-keygen -f ~/.ssh/foobar.id_rsa`
2. Recopie de la clef: `ssh-copy-id -i ~/.ssh/foobar.id_rsa -p 22 user@hostname` (le port est nécessaire dans le cas d'un machine virtuelle et de l'utilisation du NAT).
3. Démarrer (_Putty Key Generator_)
4. Importer la clef (_Conversion > Import Key_ puis `~/.ssh/foobar.id_rsa` ou autre)
5. Sauvegarder la clef au format PPK.
6. Dans Putty, aller dans _Connections > SSH > Auth_ puis sélectionner la clef privée (`ppk`). Ne pas oublier de sauvegarder.

## Utiliser une clef publique/privée en fonction d'un serveur dans OpenSSH (git, ssh)

Dans le fichier `~/.ssh/config`, il faut configurer ainsi (le `# Port 22` en commentaire montre également comment changer le port par défaut) :

```
Host bitbucket
  HostName bitbucket.org
  IdentityFile ~/.ssh/bitbucket.id_rsa
  # Port 22
  User git

Host github
  HostName github.com
  IdentityFile ~/.ssh/github.id_rsa
  User git
```

La configuration présente permet ensuite de se connecter à GIT via une commande comme : `git clone github:glhez/docs.git`.

## Exporter la configuration de Putty

C'est écrit dans l'aide (voir section _4.29 Storing configuration in a file_) et il faut faire :

```
regedit /ea putty.reg HKEY_CURRENT_USER\Software\SimonTatham\PuTTY
```

## Plus de couleurs

Dans l'onglet _Connection > Data_, il faut mettre _Terminal-type string_ à _putty-256color_. 
La plupart des Linux support ce terminal, sinon il vaut mieux utiliser _xterm-256color_.


## Utiliser le _numpad_ sur Putty et éviter de mauvaises surprises

Dans _Terminal > Features_, il faut tout décocher sauf:

- _[x] Disable application keypad mode_
- _[x] Disable remote window title querying (SECURITY)_