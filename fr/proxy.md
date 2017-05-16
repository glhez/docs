Proxy
=====

## CNTLM

A télécharger : [CNTLM](http://cntlm.sourceforge.net/)

CNTLM permet de créer un serveur proxy en local forwardant vers un proxy NTLM. Le but étant
de permettre à des applications ne connaissant pas le protocole de proxy NTLM de quand même
pouvoir se connecter via un proxy.

C'est donc un outil très utile en environnement fermé (eg: entreprises qui bloquent des CDN
comme github mais pas des sites "people").

### Git for Windows / MSYS2

Il est recommandé d'aller dans le dossier de CNTLM, puis de lancer `cmd`, plutôt que de le
faire via Bash. En fait, CNTLM ne va pas apprécier les chemins POSIX `/c/program files`.


### Tester le proxy

    cntlm -v -l 17444 -f <url>:<port>

- `-v` active le mode verbeux
- `-l <port>` définit le port local proxy
- `-f` permet à CNTLM de rester en foreground (à toujours utiliser)
- `<url>:<port>` indique le proxy CNTLM visé

Il suffit ensuite d'utiliser ce proxy dans les applications.


### Configuration (cntlm.ini)

Il faut configurer le fichier cntlm.ini de sorte à avoir le bon proxy, le bon utilisateur
et domaine, puis :

    cntlm -c cntlm.ini -v -f -H -M http://www.google.fr

- L'option `-M` permet de vérifier qu'on accède bien à google.fr
- L'option `-H` affiche une configuration NTLMv2 permettant de ne pas avoir le mot de passe
 utilisateur en clair tout en conservant la connexion utilisateur. Il faudra ensuite recopier
 ce paramètrage dans cntlm.ini.

## Android

Plutôt que d'installer le téléphone en tant que modem USB, il est possible d'utiliser les 
outils de debug d'Android pour faire du _bridge_ en utilisant un proxy Android et en 
redirigeant les ports.

Il faut installer l'Android SDK, et faire en sorte de charger les drivers USB afin que le
téléphone soit reconnu en lançant la commande suivante :

    adb devices

Une fois l'appareil reconnu, et un serveur proxy installé dessus, il est ensuite possible 
de forwarder des ports locaux de/vers les ports du téléphone.

    adb forward tcp:3128 tcp:56540

Ce qui forward le port 56540 du device vers le port 3128 du PC.

- [Drivers Samsung](http://developer.samsung.com/technical-doc/view.do?v=T000000117)
