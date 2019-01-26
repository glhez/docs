# Base de données

## PostgreSQL

### Livres

Editeur: [Packt](https://www.packtpub.com/)

- PostgreSQL Cookbook
- PostgreSQL High Performance

### Utilitaires

- `pg_dump` produit un dump cohérent
- `pgbarman` : manager de backup pgsql

### Informations diverses

- Les DDL (create table, etc) sont transactionnels, ce qui n'est pas le cas chez les concurrents (Oracle, ...)
- WAL : Write Ahead Log. C'est ce qui permet en gros de gérer les transactions & ++. Chaque requête (insert, update) produit un WAL, qui est appliqué sur une
        instance "de base" (un peu comme un commit sous git)
- PITR : Point In Time Recovery
- TOAST : il s'agit du mode de stockage des données, fait de manière implicite, sur tous les champs types texte >= 2KiO. Ces champs sont stockés dans une table
          à part, pouvant produire des jointures implicites (et cachés dans les explain plan) si les champs sont "projetés" (ie: dans la liste du select).

### Requêtes

```pgsql
create table reservation (
  during tsrange not null,
  exclude using gist (during with &&) -- depuis pgsql 9.2
)
```

- tsrange est un type représentant un intervalle de temps.
- `exclude using gist (during with &&)` permet de faire une sorte de contrainte d'unicité interdisant l'insertion de tout intervalle chevauchant un déjà existant.


```pgsql

create extension cube;
create extension earthdistance;

with geoloc as (
  ... -- CTE
)
select ...
from names, geoloc

```

- Le `with` force la requête a être exécutée avant l'autre (marche aussi sous Oracle).
- On fait un produit cartésien car le CTE (le nom du `with`) ne renvoie qu'une valeur, sinon on peut faire un `join`, etc.
- Barrière d'optimisation pour l'exécuteur SQL car on force l'ordre d'exécution.

```pgsql
select name, pos <@> point(:lat, :lng) miles
from pubnames
order by pos <-> point(:lat, :lng)
limit 3
```

- Renvoie les 3 premiers pubs les plus proches
- `<@>` est un opérateur renvoie la distance en miles [...] entre deux positions GPS
- `<->` est un opérateur d'ordre abstrait

## Timesten

### Windows 7 et l'édition 64 bits

**Note:** ceci concerne une vieille version de Timesten.

TimesTen est une base de données mémoire.

Je ne sais pas si c'est mieux (d'un point de vue licences et autres coûts) que d'utiliser des SSD avec une base Oracle
classique, voire autre chose qu'Oracle, mais toujours est-il que vous pouvez télécharger sur 
[le site d'Oracle](http://www.oracle.com/technetwork/products/timesten/downloads/index.html), la base de données en 
version Windows 64bits.

Vous pouvez aussi télécharger ça en version 32bits, ou pour Linux, mais là n'est pas le sujet.

Quand vous aurez installé la base de données, vous aurez alors un service TimesTen, qui sous un 
[Process Explorer](http://technet.microsoft.com/en-us/sysinternals/bb896653), n'aura de cesse que de planter.

L'executable `ttcserver1122.exe`, après l'installation par défaut, s'arrêtera, sera relancé, s'arrêtera encore, sera 
encore relancé, ..., et ainsi de suite jusqu'à ce que vous arrêtiez le processus père `timestend1122.exe`.

Si vous regardez les logs du serveur, que vous trouverez en principe dans `C:\TimesTen\tt1122_64\srv\info` 
(bien sûr, ce chemin peut changer !), vous pourrez lire ceci :

    14:25:53.96 Info:    :  5840: mark process up: index 1000006, port 51685, pid 14020
    14:25:53.98 Info:    :  5840: maind: done with request #14.14
    14:25:53.98 Err : SRV: 14020: EventID=7| Unable to open the ODBC.INI data sources root  
    14:25:53.99 Info:    :  5840: maind 13: socket closed, calling recovery (last cmd was 13)
    14:25:53.99 Info:    :  5840: Starting daRecovery for 14020

La troisième ligne est plutôt obscure, et vous comprendrez qu'il manque quelque chose à TimesTen pour fonctionner. 
Le quoi en question, je l'ai trouvé. Je ne sais plus comment (je pense que j'ai du faire appel à des forces obscures).

1. Ouvrez la base de registre en _Administrateur_ (recherchez le programme `regedit.exe`, puis clic droit et éxecuter en tant qu'administrateur)
2. Naviguez jusqu'à `HKEY_USERS\.DEFAULT\Software\ODBC\ODBC.INI\ODBC Data Sources` en créant les clefs manquantes en faisant un clic droit sur l'interface de gauche (celle qui s'apparente à des dossiers), puis Nouveau > Clé.
3. Redémarrez le service TimesTen.

Ce dernier ne devrait plus planter. Sinon, c'est qu'un nouveau bug frappe TimesTen x64 sous Windows 7 (x64).

Et pour finir, si vous escomptiez désinstaller TimesTen, pour le réinstaller ailleurs, alors une autre tâche vous 
incombera : corriger les chemins des drivers ODBC. Et pour cela, cela se passe là : `HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\Nom de la datasource`,
 et en particulier la valeur "chaîne" `Driver` qui pointe pas/plus au bon endroit.

## Oracle Database

### Lister les sessions bloquantes/bloquées

    select blocking.sid      as blocking_sid
         , blocking.serial#  as blocking_serial
         , blocking.machine  as blocking_machine
         , blocking.osuser   as blocking_osuser  
         , blocking.username as blocking_username
         , blocking.program  as blocking_program 
         , blocked.sid       as blocked_sid     
         , blocked.serial#   as blocked_serial
         , blocked.machine   as blocked_machine         
         , blocked.osuser    as blocked_osuser  
         , blocked.username  as blocked_username
         , blocked.program   as blocked_program
         , blocked.state     as blocked_state 
         , blocked.WAIT_TIME_MICRO / (1000000 *60) AS blocked_since_minutes
         , o.object_type
         , o.object_name      
    from V$SESSION blocked 
    inner join V$SESSION   blocking on blocking.sid = blocked.BLOCKING_SESSION
    inner join V$SQL       sql      on sql.sql_id   = blocked.sql_id          
    inner join DBA_OBJECTS o        on o.object_id   = blocked.row_wait_obj#   
    where blocked.status = 'ACTIVE'
    order by blocking.sid, blocked.sid

### Lister les verrous sur les objets

    select A.*, s.machine, s.osuser, s.username, S.*
    from V$ACCESS A
    inner join V$SESSION S on S.SID = a.sid
    where A.OWNER  = :owner
      and A.TYPE   = :object_type
      and A.OBJECT = :object_name
