#Risorse (Assets)


Una risorsa in Yii è un file a cui è possibile fare riferimento in una pagina Web. Può essere un file CSS, un file JavaScript, un'immagine o un file video, ecc.. Le risorse si trovano in directory accessibili dal Web e sono servite direttamente dai server Web.

Spesso è preferibile gestire le risorse a livello di programmazione. Ad esempio, quando si utilizza il widget ***yii \ jui \ DatePicker*** in una pagina, verranno automaticamente inclusi i file CSS e JavaScript richiesti, invece di chiedere di trovare manualmente questi file e includerli. E quando si aggiorna il widget a una nuova versione, verrà automaticamente utilizzata la nuova versione dei file di asset. In questo tutorial, descriveremo la potente capacità di gestione degli asset fornita da Yii.


##Definizione dei pacchetti di asset


I pacchetti di asset sono specificati come classi PHP che si estendono da ***yii \ web \ AssetBundle***. Il nome di un bundle è semplicemente il suo nome relativo alla classe PHP. una classe di asset bundle dovrebbe essere autoloadable. Solitamente specifica dove si trovano le risorse, quali file CSS e JavaScript, e ci dice anche quale pacchetto dipende da altri bundle.

Il seguente codice definisce il pacchetto di asset principale utilizzato dal progetto del modello base:

    <?php

    namespace app\assets;

    use yii\web\AssetBundle;

    class AppAsset extends AssetBundle{

        public $basePath = '@webroot';
        public $baseUrl = '@web';
        public $css = [
            'css/site.css',
            ['css/print.css', 'media' => 'print'],
        ];
        public $js = [
        ];
        public $depends = [
            'yii\web\YiiAsset',
            'yii\bootstrap\BootstrapAsset',
        ];
    }

La classe ```AppAsset``` specifica che il file di asset si trovano nella directory ```@webroot``` che corrisponde all'URL ```@web```; il pacchetto contiene un singolo file CSS ```css/site.css```. e nessun file JavaScript. Il pacchetto dipende da altri due bundle: ***yii \ base \ YiiAsset*** e ***yii \ bootstrap \ BootstrapAsset***. Una spiegazione più dettagliata della proprietà ***yii \ web \ AssetBundle*** può essere trovata nel modo seguente:

- ***sourcePath***: specifica la directory root che contiene i file di asset in questo pacchetto. Questa proprietà deve essere impostata se la directory principale non è accessibile dal Web. In caso contrario, è necessario impostare la proprietà ***basePath*** e  la proprietà ***baseurl***. Gli alias di percorso possono essere utilizzati.
- ***basePath***: specifica una directory accessibile dal Web che contiene i file di asset in questo pacchetto. Quando si specifica la proprietà ***sourcePath***, il gestore risorse pubblica le risorse di questo pacchetto in una directory accessibile dal Web, e sovrascrive di conseguenza questa proprietà. È necessario impostarla se i file delle risorse sono già in una directory accessibile dal Web e non è necessario pubblicare gli asset. Gli alias di percorso possono essere utilizzati.
- ***baseUrl***: specifica l'URL corrispondente alla directory basePath. Come basePath , se si specifica la proprietà sourcePath , il gestore risorse pubblicherà le risorse e sovrascriverà di conseguenza questa proprietà. Gli alias di percorso possono essere utilizzati.
- ***css***: specifica un array che elenca i file CSS contenuti in questo pacchetto. Si noti che solo la barra "/" deve essere utilizzata come separatore di directory. Ogni file può essere specificato da solo come stringa o in un array insieme ai tag di attributo e ai relativi valori.
- ***js***: specifica un array che elenca i file JavaScript contenuti in questo pacchetto. Il formato di questo array è lo stesso di quello del css . Ogni file JavaScript può essere specificato in uno dei seguenti due formati:
    1. un percorso relativo che rappresenta un file JavaScript locale (es js/main.js.). Il percorso effettivo del file può essere determinato anteponendo ***yii \ web \ AssetManager :: $ basePath*** al percorso relativo e l'URL effettivo del file può essere determinato anteponendo ***yii \ web \ AssetManager :: $ baseUrl*** al percorso relativo.
    2. un URL assoluto che rappresenta un file JavaScript esterno. Ad esempio ```http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js``` o ```//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js.```.

- ***depends***: specifica un array che elenca i nomi dei bundle di asset da cui dipende questo bundle (sarà spiegato nei prossimi paragrafi).
- ***jsOptions***: specifica le opzioni che verranno passate al metodo ***yii \ web \ View :: registerJsFile ()*** quando viene chiamato per registrare ogni file JavaScript in questo pacchetto.
- ***cssOptions***: specifica le opzioni che verranno passate al metodo ***yii \ web \ View :: registerCssFile ()*** quando viene chiamato per registrare ogni file CSS in questo pacchetto.
- ***publishOptions***: specifica le opzioni che verranno passate al metodo ***yii \ web \ AssetManager :: publish ()*** quando viene chiamato per pubblicare i file di risorse dall'origine in una directory Web. Viene utilizzato solo se si specifica la proprietà ***sourcePath***.


##Posizioni delle risorse


Le risorse, in base alla loro posizione, possono essere classificate come:

- ***source assets***: i file delle risorse si trovano insieme al codice sorgente PHP che non può essere direttamente accessibile via Web. Per utilizzare le source assets in una pagina, devono essere copiati in una directory Web e trasformati nelle cosiddette risorse pubbliche. Questo processo è chiamato ***asset publishing*** che verrà descritto nei paragrafi successivi.
- ***risorse pubblicate***: i file delle risorse si trovano in una directory Web e possono quindi essere accessibili direttamente via Web.
- ***risorse esterne***: i file delle risorse si trovano su un server Web diverso da quello che ospita la tua applicazione Web.

Quando si definisce una classe bundle di asset, se si specifica la proprietà ***sourcePath***, significa che tutte le risorse elencate, stanno utilizzando percorsi relativi e saranno considerate come source assets. Se non si specifica questa proprietà, significa che tali risorse sono risorse pubblicate (public assets) (è necessario specificare ***basePath*** e ***baseUrl*** per consentire a Yii di sapere dove si trovano).

Si consiglia di posizionare le risorse appartenenti a un'applicazione in una directory Web, per evitare il processo di pubblicazione di asset non necessario e non voluto. Questo è il motivo per cui ```AppAssetper``,nell'esempio precedente, gli viene specificato il ***basePath***, anziché il ***sourcePath***.

Per le estensioni, poiché le loro risorse si trovano insieme al loro codice sorgente nelle directory che non sono accessibili dal Web, è necessario specificare la proprietà ***sourcePath*** quando si definiscono le classi di pacchetti di asset relativi ad essi.

!!!Warning
    Non utilizzare il percorso di origine ```@webroot/assetscome```. Questa directory viene utilizzata come impostazione predefinita dal gestore risorse, per salvare i file di asset pubblicati dalla loro posizione di origine. Qualsiasi contenuto in questa directory, è considerato temporaneamente e potrebbe essere soggetto a rimozione.


##Dipendenze delle risorse


Quando includi più file CSS o JavaScript in una pagina Web, devono seguire un certo ordine per evitare problemi di sovrascrittura. Ad esempio, se si utilizza un widget dell'interfaccia utente jQuery in una pagina Web, è necessario assicurarsi che il file jQuery JavaScript sia incluso prima del file JavaScript dell'interfaccia jQuery. Chiamiamo questi controlli "dipendenze tra le risorse".

Le dipendenze delle risorse vengono principalmente specificate tramite la proprietà ***yii \ web \ AssetBundle :: $ depends***. Nell'esempio ```AppAsset```, il fascio di asset dipende da altri due fasci di attività:***Yii \ web \ YiiAsset*** e ***Yii \ bootstrap \ BootstrapAsset***, il che significa che i file CSS e JavaScript in ```AppAsset``` saranno incluse dopo quei file nei due pacchetti dipendenti.

Le dipendenze delle risorse sono transitive. Ciò significa che se il pacchetto A dipende da B, che dipende da C, A dipenderà anche da C.


##Opzioni degli asset


È possibile specificare le proprietà ***cssOptions*** e ***jsOptions*** per personalizzare il modo in cui i file CSS e JavaScript sono inclusi in una pagina. I valori di queste proprietà verranno passati ai metodi ***yii \ web \ View :: registerCssFile ()*** e ***yii \ web \ View :: registerJsFile ()***, quando verranno chiamati dalla view per includere file CSS e JavaScript.

!!!Note
    Le opzioni impostate in una classe di bundle di asset, si applicano a ogni file CSS / JavaScript nel pacchetto. Se si desidera utilizzare diverse opzioni per file diversi, è necessario utilizzare il formato indicato sopra o creare pacchetti di risorse separati e utilizzare un set di opzioni in ciascun pacchetto.

Ad esempio, per includere in modo condizionale un file CSS per i browser con IE9 (Internet Explorer 9) o inferiore, è possibile utilizzare la seguente opzione:

    public $cssOptions = ['condition' => 'lte IE9'];

Ciò causerà l'inclusione di un file CSS nel pacchetto utilizzando i seguenti tag HTML:

    <!--[if lte IE9]>
    <link rel="stylesheet" href="path/to/foo.css">
    <![endif]-->

Per racchiudere i tag di collegamento CSS generati all'interno di ```noscript>```, puoi configurare ```cssOptions``` come segue:

    public $cssOptions = ['noscript' => true];

Per includere un file JavaScript nella sezione head di una pagina, puoi utilizzare la seguente opzione:

    public $jsOptions = ['position' => \yii\web\View::POS_HEAD];

Per impostazione predefinita, quando un pacchetto di risorse viene pubblicato, tutti i contenuti nella directory specificata da ***yii \ web \ AssetBundle :: $ sourcePath*** verranno pubblicati. È possibile personalizzare questo comportamento configurando la proprietà ***publishOptions***. Ad esempio, per pubblicare solo una o alcune sottodirectory di ***yii \ web \ AssetBundle :: $ sourcePath***, è possibile effettuare quanto segue nella classe bundle degli asset:

    <?php
    namespace app\assets;

    use yii\web\AssetBundle;

    class FontAwesomeAsset extends AssetBundle {

        public $sourcePath = '@bower/font-awesome'; 
        public $css = [ 
            'css/font-awesome.min.css', 
        ];
        public $publishOptions = [
            'only' => [
                'fonts/',
                'css/',
            ]
        ];
    }

L'esempio precedente definisce un pacchetto di risorse per il pacchetto "fontawesome" . Specificando l'opzione di pubblicazione ```only```, verranno pubblicate solo le sottodirectory ```fonts```e ```css```.


##Utilizzo dei pacchetti di asset


Per utilizzare un pacchetto di risorse, dobbiamo registrarlo con una vista chiamando il metodo ***yii \ web \ AssetBundle :: register ()***. Ad esempio, in un modello di vista è possibile registrare un pacchetto di asset come il seguente:  

    use app\assets\AppAsset;
    AppAsset::register($this);  // $this represents the view object

!!!Tip
    Il metodo ***yii \ web \ AssetBundle :: register()*** restituisce un oggetto bundle di asset contenente le informazioni sulle risorse pubblicate, come  ***basePath*** e ***baseUrl***.

Se si sta registrando un pacchetto di risorse in altri luoghi, è necessario fornire l'oggetto di visualizzazione necessario. Ad esempio, per registrare un pacchetto di risorse in una classe widget , è possibile ottenere l'oggetto vista per ```$this->view```.

Quando un bundle di asset è registrato con una view, Yii registrerà tutti i suoi bundle di asset dipendenti. Se un pacchetto di risorse si trova in una directory inaccessibile attraverso il Web, verrà pubblicato in una directory Web. Successivamente, quando la vista esegue il rendering di una pagina, genererà tag ```<link>```e  ```<script>``` per i file CSS e JavaScript elencati nei pacchetti registrati. L'ordine di questi tag è determinato dalle dipendenze tra i bundle registrati e dall'ordine delle risorse elencate nelle proprietà ***yii \ web \ AssetBundle :: $ css*** e ***yii \ web \ AssetBundle :: $ js***.


##Bundle di asset dinamici


Essendo un normale pacchetto di risorse di classe PHP, è possibile avere alcune logiche aggiuntive ad esso correlate e può modificare dinamicamente i parametri interni. Ad esempio: è possibile utilizzare una sofisticata libreria JavaScript, che fornisce internazionalizzazione in file di origine separati: ciascuno per ciascuna lingua supportata. Quindi dovrai aggiungere un particolare file ".js" alla tua pagina per far funzionare la traduzione della libreria. Questo può essere ottenuto sovrascrivendo il metodo yii \ web \ AssetBundle :: init () :

    namespace app\assets;

    use yii\web\AssetBundle;
    use Yii;

    class SophisticatedAssetBundle extends AssetBundle{

        public $sourcePath = '/path/to/sophisticated/src';
        public $js = [
            'sophisticated.js' // file, which is always used
        ];

        public function init(){

            parent::init();
            $this->js[] = 'i18n/' . Yii::$app->language . '.js'; // dynamic file added
        }
    }

L'asset bunlde può anche essere regolato tramite la sua istanza restituita da ***yii \ web \ AssetBundle :: register()***. Per esempio:

    use app\assets\SophisticatedAssetBundle;
    use Yii;

    $bundle = SophisticatedAssetBundle::register(Yii::$app->view);
    $bundle->js[] = 'i18n/' . Yii::$app->language . '.js'; // dynamic file added


!!!Warning
    Sebbene sia supportata la regolazione dinamica dei pacchetti di asset, non è una buona pratica, perchè può portare a effetti collaterali imprevisti e, se possibile, dovrebbe essere evitata.


##Personalizzazione dei pacchetti di risorse


Yii gestisce i bundle delle risorse tramite un componente dell'applicazione denominato ```assetManager``` che è implementato da ***yii \ web \ AssetManager***. Configurando la proprietà ***yii \ web \ AssetManager :: $ bundles***, è possibile personalizzare il comportamento di un pacchetto di risorse. Ad esempio, il pacchetto asset predefinito ***yii \ web \ JqueryAsset*** utilizza il file ```jquery.js``` dal pacchetto jquery Bower installato. Per migliorare la disponibilità e le prestazioni, potresti voler utilizzare una versione ospitata da Google. Questo lo possiamo ottenere configurando ```assetManager``` nella configurazione dell'applicazione come mostrato di seguito:

    return [
        // ...
        'components' => [
            'assetManager' => [
                'bundles' => [
                    'yii\web\JqueryAsset' => [
                        'sourcePath' => null,   // do not publish the bundle
                        'js' => [
                            '//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js',
                        ]
                    ],
                ],
            ],
        ],
    ];

È possibile configurare più bundle di asset in modo simile tramite ***yii \ web \ AssetManager :: $ bundles***. Le chiavi dell'array dovrebbero essere i nomi delle classi  dei bundle di asset (senza la barra rovesciata iniziale) e i valori dell'array dovrebbero corrispondere agli array di configurazione corrispondenti.

!!!Tip
    E' possibile scegliere condizionalmente quali risorse utilizzare in un pacchetto di risorse. L'esempio seguente mostra come utilizzare ```jquery.js``` nell'ambiente di sviluppo e anche ```jquery.min.js``` in altro modo:
        'yii\web\JqueryAsset' => [
            'js' => [
            YII_ENV_DEV ? 'jquery.js' : 'jquery.min.js'
            ]
        ],

È possibile disabilitare uno o più gruppi di risorse associandogli il valore ```false``` ai nomi dei pacchetti di asset che si desidera disabilitare. Quando si registra un pacchetto di asset disabilitato ad una vista, nessuno dei suoi bundle dipendenti verrà registrato e la vista non includerà alcuna delle risorse nel pacchetto nella pagina che esegue il rendering. Ad esempio, per disabilitare ***yii \ web \ JqueryAsset***, è possibile utilizzare la seguente configurazione:

    return [
        // ...
        'components' => [
            'assetManager' => [
                'bundles' => [
                    'yii\web\JqueryAsset' => false,
                ],
            ],
        ],
    ];

Puoi anche disabilitare tutti i pacchetti delle risorse impostante ***yii \ web \ AssetManager :: $bundles*** a ```false```.

Tieni presente che la personalizzazione effettuata tramite ***yii \ web \ AssetManager :: $ bundle*** viene applicata alla creazione del bundle di risorse, ad esempio durante la fase di costruzione di oggetti. Pertanto, qualsiasi aggiustamento apportato all'oggetto ***bundle***,sostituirà l'impostazione della mappatura al livello di ***yii \ web \ AssetManager :: $ bundles***. In particolare: le regolazioni effettuate all'interno del metodo ***yii \ web \ AssetBundle :: init ()*** o sull'oggetto bundle registrato, avranno la precedenza sulla configurazione dell'```AssetManager```. Ecco alcuni esempi, in cui la mappatura impostata tramite ***yii \ web \ AssetManager :: $ bundles*** non ha alcun effetto:

    // Program source code:

    namespace app\assets;

    use yii\web\AssetBundle;
    use Yii;

    class LanguageAssetBundle extends AssetBundle{

        // ...

        public function init(){

            parent::init();
            $this->baseUrl = '@web/i18n/' . Yii::$app->language; // can NOT be handled by `AssetManager`!
        }
    }
    // ...

    $bundle = \app\assets\LargeFileAssetBundle::register(Yii::$app->view);
    $bundle->baseUrl = YII_DEBUG ? '@web/large-files': '@web/large-files/minified'; // can NOT be handled by `AssetManager`!


    // Application config :

    return [
        // ...
        'components' => [
            'assetManager' => [
                'bundles' => [
                    'app\assets\LanguageAssetBundle' => [
                        'baseUrl' => 'http://some.cdn.com/files/i18n/en' // makes NO effect!
                    ],
                    'app\assets\LargeFileAssetBundle' => [
                        'baseUrl' => 'http://some.cdn.com/files/large-files' // makes NO effect!
                    ],
                ],
            ],
        ],
    ];


##Mapping degli asset


A volte potresti voler "correggere" i percorsi dei file di asset errati / incompatibili usati in più bundle. Ad esempio, il pacchetto A utilizza la versione 1.11.1 del file ```jquery.min.js``` e il pacchetto B utilizza la versione 2.1.1 del file ```jquery.js```. Mentre è possibile risolvere il problema personalizzando ogni fascio, un modo più semplice è quello di utilizzare funzione per mappare le attività non corrette a agli oggetti desiderati. Per fare ciò, dobbiamo configurare la proprietà ***yii \ web \ AssetManager :: $ assetMap*** come segue: 

    return [
        // ...
        'components' => [
            'assetManager' => [
                'assetMap' => [
                    'jquery.js' => '//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js',
                ],
            ],
        ],
    ];

Le chiavi di ```assetMap``` sono i nomi delle risorse che si desidera correggere e i valori sono i percorsi degli asset desiderati. Quando registri un pacchetto di asset con una vista, ogni file di asset relativo nei suoi array css e js sarà esaminato rispetto a questa mappa. Se si trova che una delle chiavi è l'ultima parte di un file di asset (che è preceduta dal metodo***yii \ web \ AssetBundle :: $ sourcePath***, se disponibile), il valore corrispondente sostituirà l'asset, e sarà registrato nella vista. Ad esempio, il file di asset ```my/path/to/jquery.js```corrisponde alla chiave ```jquery.js```.

!!!Warning
    Solo le risorse specificate utilizzando i percorsi relativi sono soggette alla mappatura delle risorse. I percorsi delle risorse devono essere URL assoluti o percorsi relativi a ***yii \ web \ AssetManager :: $basePath***.


##Publishing degli asset


Come sopra indicato, se un pacchetto di risorse si trova in una directory che non è accessibile dal Web, le sue risorse verranno copiate in una directory Web quando il bundle viene registrato con una vista. Questo processo è chiamato ```asset publishing``` e viene eseguito automaticamente dal gestore degli asset .

Per impostazione predefinita, le risorse vengono pubblicate nella directory ```@webroot/assets``` che corrisponde all'URL ```@web/assets```. È possibile personalizzare questa posizione configurando le proprietà ***basePath*** e ***baseUrl***.

Invece di pubblicare le risorse tramite la copia di file, è possibile considerare l'utilizzo di collegamenti simbolici, sempre che sia il sistema operativo che il server lo permettano.Questa funzione può essere abilitata impostando il valore di ***linkAssets*** a ```true```.

    return [
        // ...
        'components' => [
            'assetManager' => [
                'linkAssets' => true,
            ],
        ],
    ];

Con la configurazione sopra indicata, il gestore degli asset creerà un collegamento simbolico al percorso di origine di un pacchetto di asset quando esso verrà pubblicato. È più veloce della copia di file e può anche garantire che le risorse pubblicate siano sempre aggiornate.


##Cache busting


Per l'applicazione Web eseguita in modalità di produzione, è prassi abilitare la memorizzazione nella cache HTTP per le risorse. Uno svantaggio di questa pratica è che ogni volta che si modifica una risorsa e la si distribuisce in produzione, un client utente può ancora utilizzare la versione precedente a causa della memorizzazione nella cache HTTP. Per ovviare a questo inconveniente, è possibile utilizzare la funzionalità ***cache busting***, introdotta nella versione 2.0.3, configurando ***yii \ web \ AssetManager*** come segue:

    return [
        // ...
        'components' => [
            'assetManager' => [
                'appendTimestamp' => true,
            ],
        ],
    ];

In questo modo, l'URL di ogni risorsa pubblicata verrà aggiunto con il timestamp dell'ultima modifica. Ad esempio, l'URL ```yii.js``` potrebbe essere così fatto  ```/assets/5515a87c/yii.js?v=1423448645"```, in cui il parametro ```v``` rappresenta l'ultima data di modifica del file ```yii.js```. Ora se modifichi una risorsa, anche il suo URL verrà modificato, il che fa sì che il client recuperi la versione più recente della risorsa.


##Pacchetti di beni comunemente usati


Il codice principale di Yii definisce molti pacchetti di risorse. Tra questi, i seguenti pacchetti sono comunemente usati e possono essere referenziati nell'applicazione o nel codice di estensione.

- ***yii \ web \ YiiAsset***: include principalmente il file ```yii.js```  che implementa un meccanismo di organizzazione del codice JavaScript nei moduli. Fornisce inoltre supporto speciale per gli attributi ```data-method``` e ```data-confirm``` e altre funzionalità utili.
- ***yii \ web \ JqueryAsset***: include il file ```jquery.js``` dal pacchetto ***jQuery Bower***.
- ***yii \ bootstrap \ BootstrapAsset***: include il file CSS dal framework Bootstrap di Twitter.
- ***yii \ bootstrap \ BootstrapPluginAsset**: include il file JavaScript dal framework Bootstrap di Twitter per supportare i plug-in JavaScript di Bootstrap.
- ***yii \ jui \ JuiAsset***: include i file CSS e JavaScript dalla libreria dell'interfaccia utente jQuery.

Se il tuo codice dipende da jQuery, jQuery UI o Bootstrap, dovresti utilizzare questi bundle di asset predefiniti piuttosto che creare le tue versioni.


##Conversione delle risorse


Invece di scrivere direttamente codice CSS e / o JavaScript, gli sviluppatori spesso li scrivono in una sintassi estesa e usano strumenti speciali per convertirli in CSS / JavaScript. Ad esempio,per il codice CSS è possibile utilizzare ***LESS*** o ***SCSS***; e per JavaScript puoi usare ***TypeScript***.

È possibile elencare i file di asset in sintassi estesa nelle proprietà ***css*** e ***js*** di un pacchetto di risorse. Per esempio,

    class AppAsset extends AssetBundle{

        public $basePath = '@webroot';
        public $baseUrl = '@web';
        public $css = [
            'css/site.less',
        ];
        public $js = [
            'js/site.ts',
        ];
        public $depends = [
            'yii\web\YiiAsset',
            'yii\bootstrap\BootstrapAsset',
        ];
    }

Quando si registra un pacchetto di asset con una vista, il gestore risorse eseguirà automaticamente gli strumenti di pre-processore per convertire le risorse nella sintassi estesa riconosciuta in CSS / JavaScript. Quando alla fine, la vista esegue il rendering di una pagina, includerà i file CSS / JavaScript nella pagina, anziché le risorse originali nella sintassi estesa.

Yii usa le estensioni dei nomi dei file per identificare la sintassi estesa in cui è presente una risorsa. Per impostazione predefinita riconosce le seguenti estensioni di sintassi e nome file:

- ***LESS***: ```.less```
- ***SCSS***: ```.scss```
- ***Stilo***: ```.styl```
- ***CoffeeScript***: ```.coffee```
- ***TypeScript***: ```.ts```

Yii fa affidamento sugli strumenti pre-processore installati per convertire le risorse. Ad esempio, per utilizzare ***LESS*** è necessario installare il comando ```lessc``` pre-processore.

E' possibile personalizzare i comandi del pre-processore e la sintassi estesa supportata, configurando il convertitore ***yii \ web \ AssetManager ::*** come il seguente:

    return [
        'components' => [
            'assetManager' => [
                'converter' => [
                    'class' => 'yii\web\AssetConverter',
                    'commands' => [
                        'less' => ['css', 'lessc {from} {to} --no-color'],
                        'ts' => ['js', 'tsc --out {to} {from}'],
                    ],
                ],
            ],
        ],
    ];

Come riportato sopra, specifichiamo la sintassi estesa supportata tramite la proprietà ***yii \ web \ AssetConverter :: $ commands***. Le chiavi dell'array sono i nomi delle estensioni dei file (senza punto iniziale) e i valori dell'array sono i nomi delle estensioni dei file delle risorse risultanti e i comandi per eseguire la conversione degli asset. I token ```{from}``` e ```{to}``` verranno sostituiti con i percorsi dei file di asset di origine e i percorsi dei file di asset di destinazione.

!!!Info
    Esistono altri modi di lavorare con le risorse nella sintassi estesa, oltre a quella descritta sopra. Ad esempio, è possibile utilizzare strumenti di compilazione come ```grunt``` per monitorare e convertire automaticamente le risorse in sintassi estesa. In questo caso, è necessario elencare i file CSS / JavaScript risultanti in bundle di asset anziché nei file originali.


##Combinazione e compressione delle risorse


Una pagina Web può includere molti file CSS e / o JavaScript. Per ridurre il numero di richieste HTTP e la dimensione complessiva di download di questi file, è prassi comune combinare e comprimere più file CSS / JavaScript in uno o pochissimi file e quindi includere questi file compressi invece di quelli originali nel Web pagine.

!!!Info
    La combinazione e la compressione delle risorse sono in genere necessarie quando un'applicazione è in modalità di produzione. Nella modalità di sviluppo, l'utilizzo dei file CSS / JavaScript originali è spesso più conveniente ai fini del debug.

Di seguito, introduciamo un approccio per unire e comprimere i file delle risorse senza la necessità di modificare il codice dell'applicazione esistente.

1. Trovare tutti i pacchetti delle risorse nella nostra applicazione che vogliamo unire e comprimere.
2. Dividi questi pacchetti in uno o pochi gruppi. Si noti che ogni pacchetto può appartenere solo a un singolo gruppo.
3. Unire / comprimere i file CSS in ogni gruppo in un singolo file. Fai lo stesso per i file JavaScript.
4. Definire un nuovo pacchetto di risorse per ogni gruppo:
    - Impostare la proprietà ***css*** e ***js*** come file uniti rispettivamente di file CSS e file di JavaScript.

Utilizzando questo approccio, quando si registra un pacchetto di asset in una vista, viene eseguita la registrazione automatica del nuovo bundle di asset per il gruppo a cui appartiene il bundle originale. Di conseguenza, i file di asset uniti / compressi sono inclusi nella pagina, anziché quelli originali.


##Un esempio


Facciamo un esempio per spiegare ulteriormente l'approccio sopra.

Supponiamo che la tua applicazione abbia due pagine, X e Y. Pagina X utilizza i bundle di asset A, B e C, mentre Page Y utilizza i bundle di asset B, C e D.

Hai due modi per dividere questi pacchetti di risorse. Uno consiste nell'utilizzare un singolo gruppo per includere tutti i pacchetti di risorse, l'altro è mettere A nel Gruppo X, D nel Gruppo Y e (B, C) nel Gruppo S. Qual è il migliore? Dipende. Il primo modo ha il vantaggio che entrambe le pagine condividono gli stessi file combinati ( CSS e JavaScript), il che rende più efficace il caching HTTP. D'altra parte, poiché il gruppo singolo contiene tutti i bundle, la dimensione dei file combinati CSS e JavaScript sarà maggiore e quindi aumenterà il tempo di trasmissione del file iniziale. Per semplicità, in questo esempio, useremo il primo modo, utilizzare un singolo gruppo per contenere tutti i bundle.

!!!Info
    Dividere i raggruppamenti delle risorse in gruppi non è un compito banale. Di solito richiede analisi sui dati di traffico del mondo reale di varie risorse su pagine diverse. All'inizio, puoi iniziare con un singolo gruppo per semplicità.

Utilizza gli strumenti esistenti (ad esempio Closure Compiler , YUI Compressor ) per unire e comprimere i file CSS e JavaScript in tutti i bundle. Si noti che i file devono essere combinati nell'ordine che soddisfa le dipendenze tra i pacchetti. Ad esempio, se Bundle A dipende da B che dipende da C e D, allora dovresti elencare i file di asset a partire da C e D, seguiti da B e infine A.

Dopo l'unione e la compressione, otteniamo un file CSS e un file JavaScript. Si supponga di nomiare i file ```all-xyz.css``` e ```all-xyz.js```, dove ```xyz```sta per un timestamp o un hash che viene utilizzato per rendere il nome del file univoco per evitare problemi di caching HTTP.

Siamo all'ultimo passo ora. Configurare il gestore degli asset come segue nella configurazione dell'applicazione:

    return [
        'components' => [
            'assetManager' => [
                'bundles' => [
                    'all' => [
                        'class' => 'yii\web\AssetBundle',
                        'basePath' => '@webroot/assets',
                        'baseUrl' => '@web/assets',
                        'css' => ['all-xyz.css'],
                        'js' => ['all-xyz.js'],
                    ],
                    'A' => ['css' => [], 'js' => [], 'depends' => ['all']],
                    'B' => ['css' => [], 'js' => [], 'depends' => ['all']],
                    'C' => ['css' => [], 'js' => [], 'depends' => ['all']],
                    'D' => ['css' => [], 'js' => [], 'depends' => ['all']],
                ],
            ],
        ],
    ];

La suddetta configurazione modifica il comportamento predefinito di ciascun pacchetto. In particolare, i pacchetti A, B, C e D non hanno più file di risorse. Ora dipendono tutti dal pacchetto ```all``` che contiene i file combinati ```all-xyz.css``` e ```all-xyz.js```. Di conseguenza, per la Pagina X, invece di includere i file originali dal Bundle A, B e C, saranno inclusi solo questi due file combinati; la stessa cosa succede a Page Y.

C'è un trucco finale per rendere l'approccio spiegato in precedena più agevole. Invece di modificare direttamente il file di configurazione dell'applicazione, è possibile inserire l'array di personalizzazione del bundle in un file separato e includere condizionatamente questo file nella configurazione dell'applicazione. Per esempio,

    return [
        'components' => [
            'assetManager' => [
                'bundles' => require __DIR__ . '/' . (YII_ENV_PROD ? 'assets-prod.php' : 'assets-dev.php'),  
            ],
        ],
    ];

In altre parole, l'array di configurazione del bundle di asset viene salvato ```assets-prod.php``` per la modalità di produzione e ```assets-dev.php```per la modalità non di produzione.

!!!Warning
    Questo meccanismo di combinazione delle risorse si basa sulla capacità di poter sovrascrivere le proprietà dei bundle di asse registrati tramite ***yii \ web \ AssetManager :: $ bundle***. Tuttavia, come già detto sopra, questa abilità non copre gli aggiustamenti del bundle degli asset, che vengono eseguiti nel metodo ***yii \ web \ AssetBundle :: init ()*** o dopo che il bundle è stato registrato. Dovresti evitare l'uso di tali pacchetti dinamici durante la combinazione delle risorse.


##Comando ```asset```

Yii fornisce un comando console chiamato ```asset``` per automatizzare l'approccio che abbiamo appena descritto.

Per utilizzare questo comando, è necessario innanzitutto creare un file di configurazione per descrivere quali gruppi di risorse devono essere combinati e come devono essere raggruppati. È possibile utilizzare il sottocomando ```asset/template``` per generare un modello e quindi modificarlo per adattarlo alle proprie esigenze.

    yii asset/template assets.php

Il comando genera un file nominato ```assets.php``` nella directory corrente. Il contenuto di questo file è simile al seguente:

    <?php
    /**
    * Configuration file for the "yii asset" console command.
    * Note that in the console environment, some path aliases like '@webroot' and '@web' may not exist.
    * Please define these missing path aliases.
    */
    return [
        // Adjust command/callback for JavaScript files compressing:
        'jsCompressor' => 'java -jar compiler.jar --js {from} --js_output_file {to}',
        // Adjust command/callback for CSS files compressing:
        'cssCompressor' => 'java -jar yuicompressor.jar --type css {from} -o {to}',
        // Whether to delete asset source after compression:
        'deleteSource' => false,
        // The list of asset bundles to compress:
        'bundles' => [
            // 'yii\web\YiiAsset',
            // 'yii\web\JqueryAsset',
        ],
        // Asset bundle for compression output:
        'targets' => [
            'all' => [
                'class' => 'yii\web\AssetBundle',
                'basePath' => '@webroot/assets',
                'baseUrl' => '@web/assets',
                'js' => 'js/all-{hash}.js',
                'css' => 'css/all-{hash}.css',
            ],
        ],
        // Asset manager configuration:
        'assetManager' => [
        ],
    ];

È necessario modificare questo file e specificare i pacchetti che si intende combinare nell'opzione ```bundles```. Nell'opzione ```targets``` è necessario specificare come i fasci debbano essere divisi in gruppi. È possibile specificare uno o più gruppi, come sopra menzionato.

!!!Warning
    Poichè gli alia ```@webroot``` e ```@web``` non sono disponibili nella console, è necessario definire in modo esplicito nella configurazione.

I file JavaScript vengono uniti, compressi e scritti ```js/all-{hash}.js``` dove {hash} viene sostituito con l'hash del file risultante.

Le opzioni ```jsCompressor``` e ```cssCompressor``` specificano i comandi della console o i callback PHP per l'esecuzione di JavaScript e CSS. Per impostazione predefinita, Yii utilizza ***Closure Compiler*** per combinare i file JavaScript e YUI Compressor per combinare i file CSS. Dovresti installare questi strumenti manualmente o modificare queste opzioni per utilizzare i tuoi strumenti preferiti.

Con il file di configurazione, è possibile eseguire il comando ```asset``` per combinare e comprimere i file di asset e quindi generare un nuovo file di configurazione del bundle di asset ```assets-prod.php```:

    yii asset assets.php config/assets-prod.php

Il file di configurazione generato può essere incluso nella configurazione dell'applicazione, come descritto nell'ultima sottosezione.

!!!Warning
    Se si personalizzano i bundle delle risorse per la propria applicazione tramite ***yii \ web \ AssetManager :: $ bundles*** o ***yii \ web \ AssetManager :: $ assetMap*** e si desidera applicare questa personalizzazione per i file di origine della compressione, è necessario includere queste opzioni per la sezione ```assetManager``` all'interno del file di configurazione del comando asset.

!!!Warning
    Mentre si specifica la sorgente di compressione, si dovrebbe evitare l'uso di bundle di asset i cui parametri possono essere regolati dinamicamente (ad esempio al metodo ```init()``` o dopo la registrazione), poiché potrebbero funzionare in modo non corretto dopo la compressione.


##Raggruppamento di pacchetti di asset


Nell'ultima sottosezione, abbiamo spiegato come combinare tutti i pacchetti di risorse in uno solo per minimizzare le richieste HTTP per i file di risorsa a cui si fa riferimento in un'applicazione. Questo non è sempre auspicabile nella pratica. Ad esempio, immagina che la tua applicazione abbia un "front-end" e un "back-end", ognuno dei quali utilizza un set diverso di file JavaScript e CSS. In questo caso, la combinazione di tutti i bundle di asset non ha senso, perché i bundle di asset per il "front-end" non vengono utilizzati dal "back-end" e sarebbe uno spreco di larghezza di banda della rete da inviare le risorse "back-end" quando viene richiesta una pagina "front-end".

Per risolvere il problema precedente, è possibile dividere gruppi di risorse in gruppi e combinare raggruppamenti di risorse per ciascun gruppo. La seguente configurazione mostra come raggruppare i pacchetti di asset:

    return [
        ...
        // Specify output bundles with groups:
        'targets' => [
            'allShared' => [
                'js' => 'js/all-shared-{hash}.js',
                'css' => 'css/all-shared-{hash}.css',
                'depends' => [
                    // Include all assets shared between 'backend' and 'frontend'
                    'yii\web\YiiAsset',
                    'app\assets\SharedAsset',
                ],
            ],
            'allBackEnd' => [
                'js' => 'js/all-{hash}.js',
                'css' => 'css/all-{hash}.css',
                'depends' => [
                    // Include only 'backend' assets:
                    'app\assets\AdminAsset'
                ],
            ],
            'allFrontEnd' => [
                'js' => 'js/all-{hash}.js',
                'css' => 'css/all-{hash}.css',
                'depends' => [], // Include all remaining assets
            ],
        ],
        ...
    ];

Come si può vedere, i fasci di attività si dividono in tre gruppi: ```allShared```, ```allBackEnd``` e ```allFrontEnd```. Ognuno di essi dipende da un insieme appropriato di pacchetti di risorse. Ad esempio, ```allBackEnd``` dipende da ```app\assets\AdminAsset```. Quando si esegue il comando ```asset``` con questa configurazione, unirà i bundle di asset in base alle specifiche precedenti.

!!!Info
    Puoi lasciare la configurazione ```depends``` vuota per uno dei pacchetti di destinazione. In questo modo, quel particolare bundle di asset dipenderà da tutti i bundle di asset rimanenti su cui altri bundle target non dipendono.





