# SQL et PL/SQL

**Note:** cela concerne principalement Oracle 11g (et ultérieur).


## Utilisation de `with`

Avec Oracle, il est possible d'utiliser `with` pour calculer des tables temporaires pour découper une grosse requête:

```
with
  a as (
    -- requête compliquée
  ),
  b as (
    select *
    from a
    inner join x on a.id = x.id
  )
  select *
  from b
```

D'un point de vue technique, Oracle déclare une table (dans l'exemple `a` et `b`) sur le `tablespace` temporaire qui
peut être par la suite réutilisée.

## Utilisation des ROWTYPE avec `out`:

Lorsqu'on utilise un ROWTYPE de cette façon:

    procedure foobar(id   in SOME_TABLE.ID%type, data out SOME_TABLE%ROWTYPE) is
      cursor cur_st is  select * from SOME_TABLE where ID = id;
      begin
        open cur_st;
        fetch cur_st into data;
        close cur_st;
      exception
        when others then
          if cur_st%isopen then close cur_st; end if;
    end;

Alors si la procédure ne trouve pas de lignes, toutes les colonnes seront `NULL`.

## Curseurs implicites

A privilégier en toute circonstance :

    for cur in (select * from some_table) loop
      dbms_output.put_line(to_char(cur.id));
    end loop;

Ce qui gère automatiquement l'ouverture, le fetch et la clôture du curseur. C'est également plus lisible 
car cela crée des variables locales à la boucle.

## Curseurs explicites

### Chargement unitaire

En ne chargeant les éléments qu'unitairement :

    declare
      t_row employees%ROWTYPE;
      cursor cur1(P_AGE employees.age%TYPE) is
        select *
        from employees
        where age > P_AGE
      ;
    begin
      open cur1(18);
      loop
        fetch cur1 collect into t_row;
        exit when cur1%notfound;
        dbms_output.put_line('age: ' || t_row.age);
      end loop;
      close cur1;
    end;

Le `exit when` permet de sortir de la boucle en cas d'événements _aucune donnée trouvée_.

### Chargement par blocs

En ne chargeant les éléments qu'unitairement :

    declare
      type type_employees is table of employees%ROWTYPE;
      t_rows type_employees;
      cursor cur1 is
        select *
        from employees
        where age > P_AGE
      ;
    begin
      open cur1;
      loop
        fetch cur1 bulk collect into t_rows limit 100;
        for i in 1 .. t_rows.count loop
          dbms_output.put_line('age: ' || t_rows(i).age);
        end loop;
        exit when cur1%notfound;
      end loop;
      close cur1;
    end;

Il  faut laisser `exit when` après la boucle sur les éléments car sinon on va ignorer le dernier bloc (si on a
130 résultats, on aura 2 blocs : un de 100, l'autre de 30).

Il ne faut pas utiliser `first` et `last` comme ici :

    forall i in t_rows.first..t_rows.last
      update employees set salary = salary * 1.25 where id = t_rows(i).id;
      
Dans ce cas Oracle gère le fait que `first` et `last` soient `null` alors que si on s'en sert dans une boucle `for`, 
le résultat est une erreur de conversion "numérique":

    for i in t_rows.first .. t_rows.last loop -- echec: i in NULL .. NULL => non convertible en number.
      dbms_output.put_line('age: ' || t_rows(i).age);
    end loop;

## Utilisation de `select into`

Il vaut mieux gérer l'exception `NO_DATA_FOUND` que de faire un `count(*)` au préalable.

Voir également [Predefined PL/SQL Exceptions](https://docs.oracle.com/cd/B10501_01/appdev.920/a96624/07_errs.htm#784)

    begin
      select * into t_row from employees where id = 1;
    exception
      when NO_DATA_FOUND then
        RAISE_APPLICATION_ERROR(-20001, 'employee not found: ' || id);
        raise; -- pour que le compilateur PL/SQL comprenne qu'on quitte; ce n'est nullement obligatoire.           
      -- when TOO_MANY_ROWS then
      --   raise;
    end;

Cela vaut également mieux qu'un curseur explicite (moins lourd à déclarer).    

Un indéniable avantage est la lisibilité au niveau de l'intention qu'un `count(*)`.
    
## Exceptions

Eviter ceci:

    begin
      select * into t_row from employees where id = 1;
    exception
      when others then
        raise; -- relance l'exception catchée.
    end;
  
Dans ce cas, on perds la stacktrace de l'exception.

On peut utiliser `dbms_utility.format_error_backtrace` pour la logguer.

Voir: [FORMAT_CALL_STACK](https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_util.htm#i997163)


