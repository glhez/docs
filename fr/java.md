# Java

## Configuration de JAVA_OPTS ou des paramètres VM dans les IDE

Sur chaque JVM lancée, ne pas oublier d'ajouter `-XX:+UnlockCommercialFeatures -XX:+FlightRecorder` ce qui permet à 
  `jmc` d'aller scruter la JVM.


## Utiliser [JaCoCo][1] avec Weblogic pour vérifier la couverture de code


```
declare jacoco_agent_file=$(_zb_win_path "${JACOCO_LIB}/jacocoagent.jar")
declare jacoco_file=$(_zb_win_path "${APPS_DATA_HOME}/jacoco/jacoco.exec")
declare JACOCO_INCLUDES='com.acme.example.*:com.acme.foobar.*'
declare JACOCO_PROPERTIES_FILE="-javaagent:${jacoco_agent_file}=output=file,destfile=${jacoco_file},jmx=true,includes=${JACOCO_INCLUDES}"
declare JACOCO_PROPERTIES_TCP="-javaagent:${jacoco_agent_file}=output=tcpserver,port=${JACOCO_TCP_PORT},address=*,jmx=true,includes=${JACOCO_INCLUDES}"

export EXTRA_JAVA_PROPERTIES="${JAVA_DEBUG_OPTIONS} ${JACOCO_PROPERTIES_FILE}"
```

La variable `jacoco_agent_file` est à modifier pour pointer sur la librairie agent de JaCoCo. On peut la trouver sur le site de JaCoCo ou sur un repository Maven.

La variable `jacoco_file` contient le fichier d'éxecution (le dump du coverage).

Il est aussi possible de se connecter via JMX pour faire du remote coverage (seconde option `JACOCO_PROPERTIES_TCP`).

La couverture de code peut ne pas s'écrire à la fin d'éxecution de la JVM. Si tel est le cas, alors il est possible d'appeler le MBean de JaCoCo `org.jacoco.Runtime` et en particulier l'opération `dump` en lui passant `false`.

## Utiliser [JaCoCo][1] avec Java Web Start pour vérifier la couverture de code

Il faut préfixer la commande par `-J` (voir exemple pour Weblogic).


## Batch

### Rajouter des sauts de lignes tous les N caractères dans un gros fichier

Le code ci-dessous (Java 7) fera l'affaire :

    import static java.nio.channels.FileChannel.open;
    import static java.nio.file.StandardOpenOption.CREATE;
    import static java.nio.file.StandardOpenOption.READ;
    import static java.nio.file.StandardOpenOption.TRUNCATE_EXISTING;
    import static java.nio.file.StandardOpenOption.WRITE;
    
    import java.io.IOException;
    import java.nio.ByteBuffer;
    import java.nio.MappedByteBuffer;
    import java.nio.channels.FileChannel;
    import java.nio.channels.FileChannel.MapMode;
    import java.nio.file.Path;
    import java.nio.file.Paths;
    
    public class Splitter {
      public static void main(String[] args) throws IOException {
        split(Paths.get(args[0]), Paths.get(args[1]), Interger.parseInt(args[2]));
      }
    
      private static void split(Path src, Path dest, int charByLine) throws IOException {
        try (FileChannel in = open(src, READ); FileChannel out = open(dest, WRITE, CREATE, TRUNCATE_EXISTING)) {
          final MappedByteBuffer map = in.map(MapMode.READ_ONLY, 0, in.size());
    
          byte[] line = new byte[] { 0x0A };
          byte[] buffer = new byte[charByLine];
          while (map.hasRemaining()) {
            final int get = Math.min(map.remaining(), charByLine);
            map.get(buffer, 0, get);
    
            out.write(ByteBuffer.wrap(buffer));
            out.write(ByteBuffer.wrap(line));
          }
        }
      }
    }
    

Le programme prends en paramètre le fichier d'entrée, le fichier de sortie, et enfin le nombre de caractères 
par ligne. Le caractère de saut de ligne utilisé est le LF.

[1]: http://www.jacoco.org/jacoco/index.html

## Debug

### Detail Formatter

#### java.lang.Class

Affiche des informations utiles sur une classe Java :

```
class org.apache.xml.serialize.XMLSerializer
CodeSource: [location: file:/<somewhere>/xerces/xercesImpl/2.11.0/xercesImpl-2.11.0.jar]
jar:file:/<somewhere>/xerces/xercesImpl/2.11.0/xercesImpl-2.11.0.jar!/org/apache/xml/serialize/XMLSerializer.class
```


```
StringBuilder sb = new StringBuilder();
sb.append(this.toString()).append('\n');
java.security.CodeSource cs = this.getProtectionDomain().getCodeSource();
if (null != cs) {
  sb.append("CodeSource: [location: ").append(cs.getLocation()).append("]\n");
}
sb.append(this.getResource('/' + this.getName().replace('.', '/') + ".class")).append('\n');
return sb.toString();
```


### Expression

#### Sauvegarder dans un fichier



**Java 6 + CommonsIO: **

Ne fonctionne pas (le fichier n'est probablement pas flushé).

```
org.apache.commons.io.IOUtils.write(
  s, // to replaced (and comment to remove)
  new java.io.BufferedWriter(
    new java.io.OutputStreamWriter(
      new java.io.FileOutputStream(
        "path/to/file"
      ), "utf-8"
    )
  )
)
```



## Maven

### Déployer le code source sur un repo maven

Cela peut se faire en utilisant l'option [`attach`](https://maven.apache.org/plugins/maven-source-plugin/jar-mojo.html#attach):

```
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-source-plugin</artifactId>
        <version>2.2.1</version>
        <executions>
          <execution>
            <id>attach-sources</id>
            <phase>verify</phase>
            <goals><goal>jar</goal></goals>
            <configuration>
              <attach>true</attach>
            </configuration>
          </execution>
        </executions>
      </plugin>
```      

### Utilisation de Saxon et Maven pour transformer du XML en XSLT

Voir project exemple: 

- [pom.xml](../examples/xml-maven-plugin/pom.xml)
- [stylesheet.xsl](../examples/xml-maven-plugin/src/main/xslt/stylesheet.xsl)
- [data1.xml](../examples/xml-maven-plugin/src/main/xml/data1.xml)

## API

### ProcessBuilder

La classe `ProcessBuilder` ne fait pas ce qu'on pense (en tout cas sous Windows) :

```
new ProcessBuilder(asList("A", "B")).inheritIO().start();
```

On pourrait penser qu'en interne, Java utiliserait [fork][1] + [execv][2], mais ce n'est pas le cas.

En  premier lieu, Java va transformer ça sous forme de chaîne (dans l'exemple A B) en échappant éventuellement
les chaînes pour

1. Gérer les executables dont le chemin contient des espaces (`C:\Program Files`)
2. Gérer les petites subtilités pour qu'un argument reste un argument.

Si on passe du JSON en paramètre - l'idée peut paraître saugrenue - alors, on peut avoir ceci:

```
new ProcessBuilder(asList("C:\\Program Files\\Git\\usr\\bin\\echo", "{\"key\": \"value\"}")).inheritIO().start();
```

On devrait s'attendre à voir afficher: `{"key": "value"}` mais ce n'est pas le cas: `{key: value}`.

Le  comportement  est  également  différent  avec la commande `echo` de cmd.exe, mais c'est probablement du au
fait que `cmd.exe` vérifie si la ligne commence par echo et traite très spécialement le reste:

```
new ProcessBuilder(asList("cmd", "/C", "echo", "{\"key\": \"value\"}")).inheritIO().start();
```

Le résultat est `"{"key": "value"}"`.

Pour vérifier avec java.exe (ou python.exe, ou autre), on va utiliser ce code suivant:

```
  public static void main(final String[] args) {
    Arrays.stream(args).forEach(System.out::println);
  }
```

Cela ne fait qu'afficher la ligne de commande, avec une ligne pour chaque argument.

Le main de test est donc le suivant:

```
  public static void main(final String[] args) throws IOException {
    new ProcessBuilder(asList("java", "-cp", "target/classes", "so.PrintArgs", "{\"key\": \"value\"}")).inheritIO().start();
  }
```

Et le résultat: `{key: value}`.

En revanche, si on fait le travail de Java:

```
  public static void main(final String[] args) throws IOException {
    new ProcessBuilder(asList("java", "-cp", "target/classes", "so.PrintArgs", "{\\\"key\\\": \\\"value\\\"}")).inheritIO().start();
  }
```

Le résultat est bien celui attendu (mais la méthode n'est pas bonne) :

```
{"key": "value"}
```

Ce  comportement  n'est  pas  bon : ce n'est pas à l'appelant d'échapper les arguments mais à Java (sinon quel
intérêt d'utiliser des tableaux ou des listes d'arguments dans les API).

**Solutions:**

- Echapper à nouveau les chaînes pour un résultat discutable
- Utiliser un fichier à la place du JSON

## Trouver la version Java d'un JAR

Ce  script, à modifier, permet de vérifier les versions des classes Java présentes dans les JARs présents dans
un  dépôt  local  maven  (par  défaut  `$HOME/.m2/repository`  ou  `%USERPROFILE%\.m2\repository`) : il va les
décompresser dans le dossier où se situe le script:

- Necessite la commande `file` qui donne la version d'une classe
- Peut produire plusieurs versions par JARs
- Prend en paramètre les noms des dépendances (à la base, c'était pour chercher des plugin maven)

    #!/bin/bash
    declare here="$(realpath "$0")"
    here="${here%/*}"
    for plugin; do
      find -type f -name "*$plugin*.jar" -not -path "$here" | while read -r file; do
        declare filename="${file##*/}"
        declare exdir="$here/${filename%.jar}"
        if [[ ! -d "$exdir" ]]; then
          unzip -q "$file" -d "$exdir"
        fi
        echo ":: java version for ${filename}"
        find "$exdir" -type f -name "*.class" -print0|xargs -r0 file --brief|sort --unique
      done
    done

## Migration Java 10

*Problèmes rencontrés:*

- Eclipse ne voit pas les classes provenant de dépendance type test et étant aussi des modules Java 10.
- Java 10 ajoute une surcouche de validation de l'accès aux ressources d'un module qui peut poser problèmes. 
- Mockito ne peut pas voir les classes package protected ou dont les packages ne sont pas exportés, malgré un _open package to module_.

### Java 10 ajoute une surcouche de validation de l'accès aux ressources d'un module qui peut poser problèmes.

Voir la documentation de `Module::getResourceAsStream` référencée par `Class::getResourceAsStream`:

> A package name is derived from the resource name. If the package name
> is a package in the module then the resource can only be located by
> **the caller of this method when the package is open to at least the
> caller's module.** If the resource is not in a package in the module
> then the resource is not encapsulated.

### Mockito ne peut pas voir les classes package protected ou dont les packages ne sont pas exportés, malgré un _open package to module_.

Le  problème  vient  du fait que Maven/Eclipse ne considèrent pas les modules pour lancer les tests : ils sont
lancés  dans le module _sans nom_. Il est donc impossible de configurer via un `module-info.java` de test (par
exemple dans `src/test/java`) ces modules :

- Maven/Eclipse ne vont pas lire ce `module-info.java`
- Ils ne vont pas non plus fusionner `src/main/java/module-info.java` et `src/test/java/module-info.java`
- ... puis de toute façon on ne peut pas spécifier via ce `module-info.java` de test qu'on ouvre un package d'un module à Mockito

Il  est  possible  de  configurer  Java  pour  autoriser cela, mais cela n'est d'une part pas satisfaisant, et
d'autre part, c'est fastidieux (à faire pour chaque module, chaque package, ...) :
  
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <configuration>
          <argLine>
            --add-opens module/package=ALL-UNNAMED
          </argLine>
        </configuration>      
      </plugin>
      
Il est aussi possible de faire ça au niveau du module-info.java, ce qui est une mauvaise idée puisque cela pollue le fichier
utilisé par le jar :

    opens somepackage; // to org.mockito;

Dans  tous  les  cas  ce  n'est  pas  satisfaisant  :  il  doit être possible de générer ça automatiquement en
détectant  les  appels  de  `mock`  (via  la  compilation  ?), nécessitant forcément un add-opens si le module
org.mockito n'a pas accès au module de la classe mockée.
    
[1]:https://linux.die.net/man/3/fork
[2]:https://linux.die.net/man/3/exec
