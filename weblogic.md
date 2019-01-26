# Weblogic 12.1.1

## Avertissement

La plupart de ces documentations ne sont plus à jour ou il existe un meilleur moyen de faire, 
ou il existe une meilleure version de Weblogic (ou un patch de la 12.1.1). 

Seul le point _Injection et trucs à savoir_ peut encore s'appliquer pour sa méthode de résolution (point d'arrêt 
sur exception).

## Injection et trucs à savoir

Imaginons plusieurs EJB :

- Un EJB Singleton, qui doit être initialisé au démarrage, et qu'on appellera `MonSuperEJBSingleton1`. Ce dernier a une ressource, par exemple une datasource, nommée "madatasource" et qui n'existe pas.
- Un second EJB Singleton, dépendant de MonSuperEJBSingleton1, qui doit aussi être initialisé au démarrage, et qu'on appellera `MonSuperEJBSingleton2`.

Et dans les deux cas, un `@PostConstruct postConstruct()`, puis une méthode `foobar()`. J'aurai aussi bien pu ne pas en mettre, mais sinon Weblogic risque de ne pas déployer car l'EJB n'a pas de méthodes.

Ce qui donne ce code :

```java
@Singleton @LocalBean @Startup
public class MonSuperEJBSingleton2 {
  @Resource(name="madatasource")
  private DataSource ds;
  
  @PostConstruct
  public void postConstruct() { /* truc intéressant à faire */ }
  
  public void foobar() { /* parce que sans méthode, Weblogic risque de râler. */}
}  

@Singleton @LocalBean @Startup @DependsOn("MonSuperEJBSingleton1")
public class MonSuperEJBSingleton2 {
  @EJB
  private MonSuperEJBSingleton1 ejb1;
  
  @PostConstruct
  public void postConstruct() { /* truc intéressant à faire */ }
  
  public void foobar() {
    ejb1.foobar();
  }
}
```

Il ne reste plus qu'à le déployer, en créant par exemple un EAR avec Maven, que l'on déploiera aussi avec Maven.

Le résultat sera _Unable to deploy EJB: MonSuperEJBSingleton2 from ejb-0.0.0.jar_ avec un message de ce genre:

```
[EJB:011148]Singleton MonSuperEJBSingleton2(Application: ear-0.0.0, EJBComponent: ejb-0.0.0.jar) not initialized as Singleton MonSuperEJBSingleton1(Application: ear-0.0.0, EJBComponent: ejb-0.0.0.jar) from the DependsOn transitive, closure failed initialization.
  at weblogic.ejb.container.deployer.EJBModule.start(EJBModule.java:592)
  at weblogic.application.internal.flow.ModuleStateDriver$3.next(ModuleStateDriver.java:213)
  at ...
Caused by: javax.ejb.NoSuchEJBException: [EJB:011148]Singleton MonSuperEJBSingleton2(Application: ear-0.0.0, EJBComponent: ejb-0.0.0.jar) not initialized as Singleton MonSuperEJBSingleton1(Application: ear-0.0.0, EJBComponent: ejb-0.0.0.jar) from the DependsOn transitive, closure failed initialization.
  at weblogic.ejb.container.manager.SingletonSessionManager$SingletonLifecycleManager.doActualInit(SingletonSessionManager.java:792)
  at weblogic.ejb.container.manager.SingletonSessionManager$SingletonLifecycleManager.initInternal(SingletonSessionManager.java:744)
  at ...
```

Ce classique de la programmation (comme le `table or view not found` sans préciser le nom de table/vue) est plus tordu 
que cela : pour trouver le problème, il vous faudra mettre un _exception breakpoint_ en mode debug sur la classe
 `javax.ejb.EJBException` et toutes ses filles, puis lire les messages qu'il y a dedans.
 
Vous y trouverez alors un truc du genre _could not inject a resource of type [javax.sql.DataSource]_. Et vous saurez que
la datasource utilisée n'est soit pas déployée sur l'instance du serveur, soit le nom JNDI n'est pas bon.

Et vous aurez probablement perdu votre temps, mais ça, c'est une autre histoire.   

## JodaTime, à la bonne version

JodaTime est embarqué par défaut par Weblogic, avec une version (1.2.1.1) probablement renommée par Weblogic.

La conséquence (classique) est qu'il faut dans chaque EAR mettre la ligne suivante dans le weblogic-application.xml :

```xml
<prefer-application-packages>
  <package-name>org.joda.*</package-name>
</prefer-application-packages>
```

Si jamais JodaTime n'est pas embarqué (par exemple, en provided dans maven) mais que la ligne ajoutée ci-dessous persiste 
dans le fichier XML embarqué dans l'EAR, alors le classloader de Weblogic provoquera une exception (probablement un 
`ClassNotFoundException` ou une autre insulte du même acabit).

En supposant le fonctionnement suivant pour charger la classe `org.joda.time.ReadableDateTime` :

`WeblogicMainClassLoader` (appelons comme ça le classloader qui tentera en premier de charger `ReadableDateTime`) va dans
un premier temps vérifier si la classe vérifie l'un des filtres, puis :

- Si le filtre matche, appeler le classloader `MonEARClassLoader` qui ne trouvera rien car la librairie n'est pas là (bien entendu !).
- Sinon, il passera par mettons `WeblogicDelegatingClassLoader` qui cherchera la classe, et s'il ne la trouve pas, utilisera `MonEARClassLoader`.

Là où c'est merveilleux, c'est quand vous mélangez cela avec des méthodes EJB asynchrones
 ([`@Asynchronous`](http://docs.oracle.com/javaee/6/api/javax/ejb/Asynchronous.html)) : inutile de chercher des logs, 
 y en aura aucun. Il ne semble pas que les thread executant les traîtements asynchrones logguent quoique ce soit.

Et si vous pensiez utiliser une version plus récente de l'API JodaTime, alors vous pourriez tomber sur des
[`NoSuchMethodException`](http://docs.oracle.com/javase/7/docs/api/java/lang/NoSuchMethodException.html) par ci 
par là. Une solution "simple" consiste à passer à JodaTime 1.2.1.1 et, si le jar
 n'est pas disponible sur le dépôt central de maven, l'ajouter sur un nexus ou le copier en local. 

## ça ne logguera pas comme ça

1. Vous utilisez SLF4J ?
2. Vous utilisez Weblogic 12 ?
3. Vous voulez utiliser logback, ou configurer à minima les logs ?

Hé bien, vous ne pourrez pas.

Enfin si, vous pourrez toujours passer les logs du serveur de _Java Util Logging_ (JUL) à log4j via la console du
serveur, et il vous faudra peut-être embarquer log4j ou le mettre en librairie du serveur. Moi, ça a résulté en un
`ClassNotFound` et ça en est revenu à JUL.

Mais là encore, y a _eine kleine problem_ : SLF4J utilise un static binding, et va simplement charger la première
implémentation qu'il trouve. Du coup, si vous vouliez utiliser logback, vous ne pourriez pas. Et pareil pour log4j,
puisque c'est JUL qui passe en premier.

Heureusement il y a moyen d'éviter ça.

[Téléchargez logback 0.9.29](http://logback.qos.ch/download.html)

En théorie, la version doit implémenter SLF4J 1.6.1, d'où le fait qu'on ne prenne pas la dernière version; dans 
la pratique, j'ai pu utiliser la version 1.0.6 sans souci. Vous pouvez probablement utiliser la dernière version,
mais vous augmenterez vos chances d'obtenir des erreurs ce que, connaissant Weblogic 12, je ne vous recommande pas !

Une fois cette version en main, il vous faudra la charger de sorte à ce qu'elle soit en premier dans le classpath. 
Ce qui est possible avec la JVM via l'option `-Xbootclasspath/p:` qui prend un classpath et qui permet de forcer 
un jar à être chargé en premier.


## Installer (ou mettre à jour) un domaine via le GUI

Dans le dossier `%MW_HOME%\oracle_common\common\bin`, lancer config.cmd après avoir défini `JAVA_HOME`.
