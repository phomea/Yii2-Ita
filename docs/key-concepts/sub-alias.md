#Alias


Gli alias vengono utilizzati per rappresentare i percorsi dei file o gli URL in modo da non dover codificare percorsi o URL assoluti nel progetto. Un alias deve iniziare con il carattere `@` da differenziare dai normali percorsi di file e URL.

Yii ha molti alias predefiniti già disponibili. Ad esempio, l'alias `@yii` rappresenta il percorso di installazione del framework Yii; `@web` rappresenta l'URL di base per l'applicazione Web attualmente in esecuzione.


##Definizione di alias


E' possibile definire un alias per un percorso file o un URL chiamando **Yii :: setAlias()**

    // an alias of a file path
    Yii::setAlias('@foo', '/path/to/foo');

    // an alias of a URL
    Yii::setAlias('@bar', 'http://www.example.com');

    // an alias of a concrete file that contains a \foo\Bar class
    Yii::setAlias('@foo/Bar.php', '/definitely/not/foo/Bar.php');

!!!Warning
    Il percorso del file o l'alias dell'URL potrebbe non riferirsi necessariamente a un file o risorsa esistente.

Dato un alias definito, è possibile derivare un nuovo alias (senza la necessità di chiamare **Yii :: setAlias()** ) aggiungendo uno slash `/` seguita da uno o più segmenti di percorso. Gli alias definiti tramite **Yii :: setAlias()** diventano l' alias di root, mentre gli alias derivati ​​da esso sono alias derivati . Ad esempio, `@foo` è un alias di root, mentre `@foo/bar/file.php` è un alias derivato.

Puoi definire un alias usando un altro alias (root o derivato):

    Yii::setAlias('@foobar', '@foo/bar');

Gli alias di root vengono generalmente definiti durante la fase di avvio. Ad esempio, è possibile chiamare **Yii :: setAlias()** nello script di immissione. Per comodità, l' applicazione fornisce una proprietà scrivibile denominata `aliases` che è possibile configurare nella configurazione dell'applicazione:

    return [
        // ...
        'aliases' => [
            '@foo' => '/path/to/foo',
            '@bar' => 'http://www.example.com',
        ],
    ];


##Risoluzione di Alias


Puoi chiamare **Yii :: getAlias()** per risolvere un alias di root nel percorso del file o nell'URL che rappresenta. Lo stesso metodo può anche risolvere un alias derivato nel percorso o nell'URL corrispondente:

    echo Yii::getAlias('@foo');               // displays: /path/to/foo
    echo Yii::getAlias('@bar');               // displays: http://www.example.com   
    echo Yii::getAlias('@foo/bar/file.php');  // displays: /path/to/foo/bar/file.php

Il percorso / URL rappresentato da un alias derivato viene determinato sostituendo la parte dell'alias root con il percorso / URL corrispondente nell'alias derivato.

!!!Note
    Il metodo **Yii :: getAlias()** non controlla se il percordo URL risultante fa riferimento a un file o una risorsa esistente.

Un alias di root può contenere anche slash `/` . Il metodo **Yii :: getAlias()** è abbastanza intelligente da stabilire quale parte di un alias è un alias di root e quindi determina correttamente il percorso o l'URL del file corrispondente:

    Yii::setAlias('@foo', '/path/to/foo');
    Yii::setAlias('@foo/bar', '/path2/bar');
    Yii::getAlias('@foo/test/file.php');  // displays: /path/to/foo/test/file.php
    Yii::getAlias('@foo/bar/file.php');   // displays: /path2/bar/file.php

Se `@foo/bar` non è definito come un alias di root, verrà visualizzata l'ultima istruzione `/path/to/foo/bar/file.php`.


##Utilizzo degli Alias


Gli alias sono riconosciuti in molti punti di Yii senza bisogno di chiamare **Yii :: getAlias()** per convertirli in percorsi o URL. Ad esempio, **yii \ caching \ FileCache :: $ cachePath** può accettare sia un percorso file che un alias che rappresenta un percorso file, grazie al prefisso `@` che consente di differenziare un percorso file da un alias.

    use yii\caching\FileCache;

    $cache = new FileCache([
        'cachePath' => '@runtime/cache',
    ]);

Prestare attenzione alla documentazione dell'API per verificare se una proprietà o un parametro del metodo supporta alias.


##Alias predefiniti


Yii predefinisce un set di alias per fare facilmente riferimento ai percorsi e agli URL dei file comunemente utilizzati:

- `@yii`, la directory in cui `BaseYii.php` si trova il file (chiamando anche la directory framework).
- `@app`, **yii\ base \ Application :: basePath** dell'applicazione attualmente in esecuzione.
- `@runtime`, **yii \ base \ Application :: runtimePath** dell'applicazione attualmente in esecuzione. Predefinito a `@app/runtime`.
- `@webroot`, la directory principale Web della nostra applicazione attualmente in esecuzione. Viene determinato in base alla directory contenente lo script di immissione.
- `@web`, l'URL di base dell'applicazione Web attualmente in esecuzione. Ha lo stesso valore di **yii \ web \ Request :: baseUrl**.
- `@vendor`, **yii \ base \ Application :: vendorPath**. Il valore predefinito è `@app/vendor`.
- `@bower`, la directory root che contiene i pacchetit di bower. Il valore predefinito è `@vendor/bower`.
- `@npm`, la directory root che contiene i pacchetti npm. Il valore predefinito è `@vendor/npm`.

L'alias `@yii` viene definito quando si include il file `Yii.php` nell'entry script. Il resto degli alias vengono definiti nel costruttore dell'applicazione quando applichiamo la sua configurazione.


##Alias di estensione


Un alias viene automaticamente definito per ogni estensione installata tramite Composer. Ogni alias prende il nome  dell'estensione come dichiarato nel suo file `composer.json` e ogni alias rappresenta la directory radice del pacchetto. Ad esempio, se si installa l' estensione `yiisoft/yii2-jui`, si avrà automaticamente l'alias `@yii/jui` definito durante la fase di avvio , equivalente a:

    Yii::setAlias('@yii/jui', 'VendorPath/yiisoft/yii2-jui');

