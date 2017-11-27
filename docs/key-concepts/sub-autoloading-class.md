#Classe Autoloading 


Yii si basa sul meccanismo di autoloading della classe per individuare e includere tutti i file di classe richiesti. Fornisce un'autoloader di classe ad alte prestazioni conforme allo standard PSR-4. L'autoloader viene installato quando si include il file `Yii.php`.

!!!Warning
    Per semplicità di descrizione, in questa sezione parleremo solo del caricamento automatico delle classi. Tuttavia, tieni presente che il contenuto che stiamo descrivendo qui si applica anche all'autoloading di interfacce e Traits.


##Uso dell'autoloader di Yii


Per utilizzare l'autoloader della classe Yii, è necessario seguire due semplici regole durante la creazione e la denominazione delle classi:

- Ogni classe deve essere in uno spazio dei nomi (ad esempio `foo\bar\MyClass\`)
- Ogni classe deve essere salvata in un singolo file il cui percorso è determinato dal seguente algoritmo:

    // $className is a fully qualified class name without the leading backslash
    $classFile = Yii::getAlias('@' . str_replace('\\', '/', $className) . '.php');

Ad esempio, se un nome di una classe e un namespace sono `foo\bar\MyClass`, l' alias per il corrispondente percorso del file di classe sarebbe `@foo/bar/MyClass.php`. Affinché questo alias sia risolvibile in un percorso file, `@foo` o `@foo/bar` deve essere un alias di root.

Quando si utilizza il modello progetto base di Yii, è possibile mettere le classi sotto i namespace di livello superiore ad `app` in modo che possano essere autoloaded da Yii senza la necessità di definire un nuovo alias. Questo perché `@app` è un alias predefinito e un nome di classe come `app\components\MyClass` può essere risolto nel file di classe `AppBasePath/components/MyClass.php`, in base all'algoritmo appena descritto.

Nel modello di progetto avanzato, ogni livello ha il proprio alias di root. Ad esempio, il livello front-end ha un alias root `@frontend`, mentre l'alias root del tier back-end è `@backend`. Di conseguenza, puoi inserire le classi front-end sotto i namespace "frontend", mentre le classi back-end sono sotto "backend". Ciò consentirà a queste classi di essere autoloading dell'autoloader di Yii.

Per aggiungere un namespace personalizzato all'autoloader, è necessario definire un alias per la directory base dei namespaces utilizzando **Yii :: setAlias()**. Ad esempio, per caricare classi nel namespace `foo` che si trovano nella `path/to/foodirectory` che chiamerai `Yii::setAlias('@foo', 'path/to/foo')`.


##Class Map


L'autoloading della classe Yii supporta la funzione mapping delle classi, che associa i nomi delle classi ai percorsi dei file di classe corrispondenti. Quando l'autoloading sta caricando una classe, controllerà innanzitutto se la classe è stata trovata nella mappa. In tal caso, il percorso del file corrispondente verrà incluso direttamente senza ulteriori verifiche. Questo rende la classe autoloading super veloce. In effetti, tutte le classi Yii di base vengono caricate automaticamente in questo modo.

Puoi aggiungere una classe alla stessa mappa, memorizzata in `Yii::$classMap`,usando:

    Yii::$classMap['foo\bar\MyClass'] = 'path/to/MyClass.php';

Gli alias possono essere utilizzati per specificare i percorsi dei file di classe. È necessario impostare la mappa della classe nel processo di avvio automatico in modo che la mappa sia pronta prima di utilizzare le classi.


##Uso di altri Autoloaders


Poiché Yii include Composer come gestore delle dipendenze del pacchetto, si consiglia di installare anche l'autoloader Composer. Se si utilizzano librerie di terze parti con i propri caricatori automatici, è necessario installarle.

Quando si utilizza l'autoloader Yii insieme ad altri caricatori automatici, è necessario includere il file `Yii.php` dopo aver installato tutti gli altri caricatori automatici. Questo renderà l'autoloader di Yii il primo a rispondere a qualsiasi richiesta di autoloading della classe. Ad esempio, il codice seguente viene estratto dallo script di entrata del modello base del progetto di Yii. La prima riga installa l'autoloader Composer, mentre la seconda riga installa il l'autoloader Yii:

    require __DIR__ . '/../vendor/autoload.php';
    require __DIR__ . '/../vendor/yiisoft/yii2/Yii.php';

È possibile utilizzare l'autoloader del Composer da solo senza l'autoloader di Yii. Tuttavia, così facendo, le prestazioni dell'autoloader della tua classe potrebbero essere ridotte, e devi seguire le regole impostate da Composer affinché le tue classi siano autoloadable.

!!!Info
    Se non si desidera utilizzare l'autoloader di Yii, è necessario creare la propria versione del file di `Yii.php` e includerlo nell'entry script.


##Estensione della Classe Autoloading

L'autoloader di Yii è in grado di caricare automaticamente le classi di estensione. L'unico requisito è che un'estensione specifichi correttamente la sezione `autoload` nel suo file `composer.json`.

Nel caso in cui non si utilizzi l'autoloader di Yii, l'autoloader del Composer può ancora caricare automaticamente le classi di estensione.
