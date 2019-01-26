# SED

**Note :** chaque script doit être sauvegardée et peut être utilisé ainsi:

```
sed -r -f /path/to/script.sed [...]
```

Il est intéressant de noter que KDiff3 permet d'utiliser une précommande pour nettoyer les fichiers avant
d'appliquer l'analyse des diffs. `sed` (ou même `awk`) est toute indiquée dans ce cas là.

## Remplacer les tabulations par des espaces

```
# remove tab  
s/\t/  /g
```

## Nettoyer un fichier properties

```
# remove tab  
s/\t/  /g
# remove comments
s/^ *#.+$//g
# remove properties \
s/\\n\\$//g
s/\\$//g
# remove space before/end of line
s/^ +| +$//g
# convert case
s/[A-Z]+/\L\0/g
# remove multi space
s/ +/ /g
## tokenize
#s/[ \n]*([a-z0-9_]+|<=|>=|[?(),=])[ \n]*/\n\1\n/g
## replace space by newlines
#s/ /\n/gi
## new line in non identifier
## s/[^a-z0-9_.]/\n\0\n/gi
## remove empty line
#/^ *$/d
```