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