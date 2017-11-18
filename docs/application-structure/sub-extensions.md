#Estensioni


Le estensioni sono pacchetti software ridistribuibili progettati specificamente per essere utilizzati nella applicazioni Yii e offrono funzionalità pronte all'uso. Ad esempio, l'estensione ***yiisoft / yii2-debug*** aggiunge una comoda barra di debug nella parte inferiore di ogni pagina dell'applicazione per aiutarti a comprendere più facilmente come vengono generate le pagine. Puoi usare le estensioni per accellerare il tuo processo di sviluppo. Puoi anche impacchettare il tuo codice come estensione per condividere con altre persone il tuo grande lavoro.

!!!Note
    Utiliziamo il termine "estensione" per fare riferimento ai pacchetti software specifici di Yii. Per pacchetti software generici che possono essere utilizzati senza Yii, faremo riferimento a loro usando il termine di "pacchetto" o "libreria".


##Utilizzando le estensioni


Per utilizzare un'estensione, è necessario prima installarla. La maggior parte delle estensioni sono distribuite come pacchetti di ***Composer*** che possono essere installati seguendo due semplici passaggi:
1. modificare il file ```composer.json``` dell'applicazione e specificare quali estensioni (pacchetti di Composer) si desidera installare.
2. eseguire ```composer install``` per installare le estensioni specificate.

Si noti che potrebbe essere necessario installare il Composer se non lo si possiede.

Per impostazione predefinita, il Composer installa i pacchetti registrati su ***Packagist***, il più grande repository per i pacchetti Composer open source. Puoi cercare estensioni su Packagist. Puoi anche creare il tuo repository e configurare il Composer per usarlo. Questo è utile se stai sviluppando estensioni private che vuoi condividere solo nei tuoi progetti.

Le estensioni installate da Composer sono memorizzate nella directory ```BasePath/vendor```, dove ```BasePath``` fa riferimento al percorso base dell'applicazione.
Poichè il Composer è un gestore delle dipendenze, quando installa un pacchetto, installa anche tutti i suoi pacchetti dipendenti.

Ad esempio, per installare l'estensione ```yiisoft/yii2-imagine```, dobbiamo modificare il nostro ```composer.json```, simile al seguente:

    {
        // ...

        "require": {
            // ... other dependencies

            "yiisoft/yii2-imagine": "*"
        }
    }

Dopo l'installazione, dovresti vedere la directory ```yiisoft/yii2-imagine``` sotto ```BasePath/vendor```. Dovresti anche vedere un'altra directory ```imagine/imagine``` che contiene il pacchetto dipendente installato.

!!!Tip
    Il ```yiisoft/yii2-imagine``` è un'estensione nucleo sviluppato e mantenuto dal team di sviluppo di Yii. Tutte le estensioni base sono ospitate su ***Packagist*** e sono denominate come ```yiisoft/yii2-xyz```, dove ```xyz``` stanno per le diverse versioni.

Ora puoi usare le estensioni installate che faranno parte della tua applicazione. L'esempio seguente mostra come utilizzare la classe ```yii\imagine\Image``` fornita dall'estensione ```yiisoft/yii2-imagine```:

    use Yii;
    use yii\imagine\Image;

    // generate a thumbnail image
    Image::thumbnail('@webroot/img/test-image.jpg', 120, 120)
        ->save(Yii::getAlias('@runtime/thumb-test-image.jpg'), ['quality' => 50]);


!!!Tip
    Le classi delle estensioni vengono caricate automaticamente dal caricatore automatico della classe Yii.


##Installare manualmente le estensioni


In alcune rare occasioni, potresti voler installare alcune o tutte le estensioni manualmente, piuttosto che affidarti al Composer. Per fare ciò, dovresti:

1. scaricare i file dell'archivio dell'estensione e decomprimerli nella directory ```vendor```.
2. installare i caricatori automatici della classe forniti dalle estensioni, se presenti.
3. scaricare e installare le estensioni dipendenti come da istruzioni.

Se un'estensione non ha un autoloader di classe ma segue lo standard ***PSR-4***, è possibile utilizzare il caricatore automatico di classe fornito da Yii per caricare automaticamente le classe di estensione. Tutto quello che devi fare è solo dichiarare un alias di root per la directory dell'estensione. Ad esempio, supponendo di aver installato un'estensione nella directory ```vendor/mycompany/myext``` e le classi di estensione si trovano nel namespace ```myext```, è possibile includere il seguente codice nella configurazione dell'applicazione:

    [
        'aliases' => [
            '@myext' => '@vendor/mycompany/myext',
        ],
    ]


##Creazione di un'estensione


Potresti considerare di creare un'estensione quando senti la necessità di condividere con altre persone il tuo codice. Un'estensione può contenere qualsiasi codice che preferisci, come una classe helper, un widget, un modulo, ecc..

Si consiglia di creare un'estensione in termini di un pacchetto Composer in modo che possa essere installato in modo più semplice e che possa essere anche utilizzato da altri utenti.

Di seguito sono riportati i passaggi di base che è possibile seguire per creare un'estensione come pacchetto di Composer.

1. Crea un progetto per la tua estensione e ospitalo si una repository VCS, come per esempio ***github.com***. Il lavoro di sviluppo e manutensione per l'estensione dovrebbe essere fatto su questa directory.
2. Sotto la directory root del progetto, crea un file chiamato ```composer.json``` come richiesto dal Composer.
3. Registra la tua estensione come una repository Composer, come Packagist, in modo che altri utenti possano trovare e installare la tua estensione usando il Composer.


##Composer.json


Ogni pacchetto di Composer deve avere un file ```composer.json``` nella sua directory principale. Il file contiene i metadati relativi al pacchetto. L'esempio seguente mostra il file ```composer.json``` per l'estensione ```yiisoft/yii2-imagine```:

    {
        // package name
        "name": "yiisoft/yii2-imagine",

        // package type
        "type": "yii2-extension",

        "description": "The Imagine integration for the Yii framework",
        "keywords": ["yii2", "imagine", "image", "helper"],
        "license": "BSD-3-Clause",
        "support": {
            "issues": "https://github.com/yiisoft/yii2/issues?labels=ext%3Aimagine",
            "forum": "http://www.yiiframework.com/forum/",
            "wiki": "http://www.yiiframework.com/wiki/",
            "irc": "irc://irc.freenode.net/yii",
            "source": "https://github.com/yiisoft/yii2"
        },
        "authors": [
            {
                "name": "Lorenzo Milicia",
                "email": "lorenzo.milicia4@gmail.com"
            }
        ],

        // package dependencies
        "require": {
            "yiisoft/yii2": "~2.0.0",
            "imagine/imagine": "v0.5.0"
        },

        // class autoloading specs
        "autoload": {
            "psr-4": {
                "yii\\imagine\\": ""
            }
        }
    }
    

##Estensioni principali


Yii fornisce le seguenti estensioni principali sviluppate e gestite dal team di sviluppatori di Yii. Sono tutti registrati su Packagist. Ecco un elenco delle principali estensioni:

- ***yiisoft / yii2-apidoc***: fornisce un generatore di documentazione API estensibile e ad alte prestazioni. Viene anche utilizzato per generare la documentazione dell'API del framework principale.
- ***yiisoft / yii2-authclient***: fornisce un insieme di client di autenticazione comunemente utilizzati, come il client OAuth2 di Facebook, il client GitHub OAuth2.
- ***yiisoft / yii2-bootstrap***: fornisce un set di widget che incapsulano i componenti e i plugin Bootstrap .
- ***yiisoft / yii2-codeception***: fornisce supporto di test basato su Codeception .
- ***yiisoft / yii2-debug***: fornisce il supporto per il debug per le applicazioni Yii. Quando viene utilizzata questa estensione, nella parte inferiore di ogni pagina viene visualizzata una barra degli strumenti del debugger. L'estensione fornisce anche una serie di pagine autonome per visualizzare informazioni di debug più dettagliate.
- ***yiisoft / yii2-elasticsearch***: fornisce il supporto per l'utilizzo di Elasticsearch . Comprende il supporto di query / ricerca di base e implementa anche il pattern Active Record che consente di archiviare i record attivi in ​​Elasticsearch.
- ***yiisoft / yii2-faker***: fornisce il supporto per l'utilizzo di Faker per generare dati falsi per te.
- ***yiisoft / yii2-gii***: fornisce un generatore di codice basato sul Web che è altamente estensibile e può essere utilizzato per generare rapidamente modelli, moduli, moduli, CRUD, ecc.
- ***yiisoft / yii2-httpclient***: fornisce un client HTTP.
- ***yiisoft / yii2-imagine***: fornisce funzioni di manipolazione delle immagini di uso comune basate su Imagine .
- ***yiisoft / yii2-jui***: fornisce un insieme di widget che incapsulano le interazioni e i widget dell'interfaccia utente JQuery .
- ***yiisoft / yii2-mongodb***: fornisce il supporto per l'utilizzo di MongoDB . Include funzionalità come query di base, record attivi, migrazioni, memorizzazione nella cache, generazione di codice, ecc.
- ***yiisoft / yii2-redis***: fornisce il supporto per l'utilizzo di redis . Include funzionalità come query di base, record attivi, memorizzazione nella cache, ecc.
- ***yiisoft / yii2-smarty***: fornisce un motore di template basato su Smarty .
- ***yiisoft / yii2-sfinge***: fornisce il supporto per l'uso di Sfinge . Include funzionalità come query di base, Active Record, generazione di codice, ecc.
- ***yiisoft / yii2-swiftmailer***: fornisce funzioni di invio e-mail basate su swiftmailer .
- ***yiisoft / yii2-twig***: fornisce un motore di template basato su Twig .
