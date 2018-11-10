# DEVOXX 2018 (Notes)

# Jeudi

## [Génération de code, moteur Catalyst... Démystifions Apache Spark](https://cfp.devoxx.fr/2018/talk/QDX-9426/Generation_de_code,_moteur_Catalyst%E2%80%A6_Demystifions_Apache_Spark_!) (Jeudi 11:15 - 12:00)

- Volcano Model: utilisé dans la plupart des SGBD relationnels.
- JIT: a du mal avec les classes "megamorphics" qui mettent à mal le pipelining.
- Janino: compilateur Java en mémoire.

## [Spring Framework 5: Feature Highlight & Hidden Gems](https://cfp.devoxx.fr/2018/talk/MIC-1172/Spring_Framework_5:_Feature_Highlights_&_Hidden_Gems) (Jeudi 12:55 - 13:40)

- Ajout d'extension pour Kotlin
- Reactor 3: Reactive Stream with back pressure
- Spring MVC Servlets vs Spring WebFlux on Reactor (Webflux est bien tant qu'il n'y a pas d'API bloquante, type JPA/JDBC)
- Améliorations apportées sur les librairies de log embarquées.

## [JDK 9 Mission Accomplished: What Next for Java ?](https://cfp.devoxx.fr/2018/talk/ZCY-6316/JDK_9_Mission_Accomplished:_What_Next_For_Java) (Jeudi 13:55 - 14:40)

- java.se.ee désormais plus inclut avec Java 10 (?).
- Disparition des versions 32 bits à partir de Java 10 (uniquement VM Oracle)
- Mise en Open Source de Flight Recorder, Mission Controls et autres; objectif prévu pour fin 2018: plus de différences entre OpenJDK et Oracle JDK.
- LTS Release disponique uniquement aux binaires Oracle et payant; implique la mise à jour tous les 6 mois.
- JDK10:
  - Class Data Sharing
  - More on Collection
- JDK11
  - Epsilon GC : un GC qui ne fait pas de GC, pour tester les performances sans GC.
  - Ajout de nullInputStream(), nullOutputStream()
- JDK12++
  - Amber déjà présent en 10 (var x)
  - [JEP301](http://openjdk.java.net/jeps/301): enum avec type paramété
  - [JEP032](http://openjdk.java.net/jeps/302): lambda leftovers
  - [JEP326](http://openjdk.java.net/jeps/326): Raw String Literals; permet d'utiliser le backtick (caractère casse pied à taper en AZERTY, mais passons) pour faire des chaînes multilignes/echappées.
  - [JEP305](http://openjdk.java.net/jeps/305): Pattern Matching
  - [JEP325](http://openjdk.java.net/jeps/325): Switch Expressions
  - [Valhala](http://openjdk.java.net/projects/valhalla/): brings value type and generic specialization over Primitive Types.
  - [Metropolis](http://openjdk.java.net/projects/metropolis/): a Java on Java RT.
  - [Loom](cr.openjdk.java.net/~rpressler/loom/Loom-Proposal.html): Project Loom: Fibers and Continuations for the Java Virtual Machine; de nouvelles API pour la concurrence plus adaptée au monde moderne.

## [Chaos Engineering, principes et mise en application](https://cfp.devoxx.fr/2018/talk/IQJ-6767/Chaos_Engineering,_principes_et_mise_en_application) (Jeudi 14:55 - 15:40)

- Initiée par Netflix
- [PRINCIPLES OF CHAOS ENGINEERING](http://principlesofchaos.org/)
- Permettre d'accroître la résilience du système
- Chaos Monkey : tester la résilience des applications

## [Effective Java 3rd Edition](https://cfp.devoxx.fr/2018/talk/TXO-1273/Effective_Java,_Third_Edition:_Keepin'_it_Effective) (Jeudi 16:10 - 16:55)

Utiliser des lambda dans les enumérés plutôt qu'une fonction par énuméré

    enum Operator {
      PLUS {
        @Override public int evaluate(int a, int b) {return a + b;}
      };
      abstract public int evaluate(int a, int b);
    }

Mais plutôt:

    enum Operator {
      PLUS((a,b) -> a + b));
      private final IntBinaryOperator expr;
      private Operaror(IntBinaryOperator expr) {this.expr = expr;}  
      public final int evaluate(int a, int b) {return expr.applyAsInt(a,b);}
    }

Probablement à utiliser avec modération.

## [Clean Code with Java 8 (4 years later)](https://cfp.devoxx.fr/2018/talk/OPQ-7183/Clean_Code_with_Java8_(4_years_later) (Jeudi 17:10 - 17:55)

...

# Vendredi

## [Nouvelles génération de tests pour projets Java](https://cfp.devoxx.fr/2018/talk/OCF-8843/Nouvelle_generation_de_tests_pour_projets_Java) (Vendredi 11:15 - 12:20)

- Présenté par un membre de [XWiki](https://fr.wikipedia.org/wiki/XWiki)
- [Projet STAMP](https://www.stamp-project.eu/view/main) : projet de recherche sur l'amplification des TU.
  - Propose des types de tests expérimentaux qui dupliquent des traces Java pour reproduire des cas
- Revap Maven Plugin (?)
- Utilisation des AspectJ pour supprimer le code @Deprecated
  - déplacement du code @Deprecated vers un JAR legacy via AspectJ
  - permet de forcer la migration vers les versions non @Deprecated (le nouveau code ne voit plus l'ancien)
- [Descartes](https://github.com/STAMP-project/pitest-descartes) : outil de mutation testing associé à PITest.
- [DSpot](https://github.com/STAMP-project/dspot) :
  - ajoute automatiquement des assertions aux tests existants.
  - semble difficilement compatible avec AspectJ
  - très lent
- Fabric8 Docker Maven plugin
- PropertiesBaseTesting
- Environment testing et mutation environment testing : modifie les configurations des dockers.

## [Lazy Java](https://cfp.devoxx.fr/2018/talk/XHI-1349/Lazy_Java) (Vendredi 12:55 - 13:40)

- Le _lazy_ permet via un _supplier_ de minimiser les coûts, ex: `logger.base(() -> "bla bla bla" + s);`
- Permet aussi de faire l'équivalent du `@tailrec` de Scala
- _Reader Monad_ : fournit un environnement pour encapsuler un calcul abstrait sans l'évaluer.

## [Blockchain - baiser de Judas de l'entreprise](https://cfp.devoxx.fr/2018/talk/LCK-0461/Blockchain_:_le_baiser_de_Judas_de_l%E2%80%99Entreprise) (Vendredi 13:55 - 14:40)

...

## [Bytecode Pattern Matching](https://cfp.devoxx.fr/2018/talk/DGI-1882/Bytecode_Pattern_Matching) (Vendredi 14:55 - 15:40)

- `valueOf`, `values` et le constructeur par défaut ne sont pas _synthetic_ au niveau du code; le compilateur ne voit pas ces attributs/méthodes (_synthetic_).
- S'applique aussi aux lambda.
- Le finally est dupliqué sur les blocs `try (...) catch (...)`.

## [java.lang.invoke: gagner en vitesse d'exécution en parlant au JIT](https://cfp.devoxx.fr/2018/talk/RCG-8661/java.lang.invoke:_gagner_en_vitesse_d'execution_en_parlant_au_JIT) (Vendredi 16:10 - 16:55)

- Les champs `final` ne sont pas constants pour la JVM; c'est lié à la sérialisation
- Le `bindTo` de [MethodHandle](https://docs.oracle.com/javase/8/docs/api/java/lang/invoke/MethodHandle.html#bindTo-java.lang.Object-) permet d'indiquer au JIT qu'il y a une constante; cela coûte cher une seule fois.
- Voir les projets de @forax : [beautiful_logger](https://github.com/forax/beautiful_logger) et [exotic](https://github.com/forax/exotic).

Conclusion de la présentation : la méthode `isXXXEnabled()` d'un logger classique comme logback ou log4j2 coûte plus cher qu'on ne le pense car la JVM ne voit pas les attributs `final` comme constants. 
L'implementation de @forax s'assure que le JIT inline le code au maximum au détriment du démarrage (= le JIT doit plus travailler).

## [Les 12 factors Kubernetes](https://cfp.devoxx.fr/2018/talk/ACQ-2247/Les_12_factors_Kubernetes) (Vendredi 17:10 - 17:55)

...

