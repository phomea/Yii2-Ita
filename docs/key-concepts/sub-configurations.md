#Configurazioni


Le configurazioni sono ampiamente utilizzate in Yii. Per esempio quando si creano nuovi oggetti o si inizializzano oggetti esistenti. Le configurazioni di solito includono il nome della classe dell'oggetto che si sta creando e un elenco di valori iniziali che dovrebbero essere assegnati alle proprietà dell'oggetto. Le configurazioni possono anche includere un elenco di gestori che devono essere collegati agli eventi dell'oggetto e / o un elenco di comportamenti che devono essere collegati all'oggetto.

Di seguito, viene utilizzata una configurazione per creare e inizializzare una connessione al database:

    $config = [
        'class' => 'yii\db\Connection',
        'dsn' => 'mysql:host=127.0.0.1;dbname=demo',
        'username' => 'root',
        'password' => '',
        'charset' => 'utf8',
    ];

    $db = Yii::createObject($config);

Il metodo **Yii :: createObject()** accetta un array di configurazione come argomento e crea un oggetto creando un'istanza della classe chiamata nella configurazione. Quando l'oggetto viene istanziato, il resto della configurazione verrà utilizzato per inizializzare le proprietà dell'oggetto, i gestori di eventi e i comportamenti.

Se hai già un oggetto, puoi usare **Yii :: configure()** per inizializzare le proprietà dell'oggetto con un array di configurazione:

    Yii::configure($object, $config);

Si noti che, in questo caso, l'array di configurazione non deve contenere un elemento `class`.


##Formato delle configurazioni


Il formato di una configurazione può essere formalmente descritto come:

    [
        'class' => 'ClassName',
        'propertyName' => 'propertyValue',
        'on eventName' => $eventHandler,
        'as behaviorName' => $behaviorConfig,
    ]

dove:

- L'elemento `class` specifica un nome di classe completo per l'oggetto che si sta creando;
- Gli elementi `propertyName` specificano i valori iniziali per la proprietà denominata. Le chiavi sono i nomi delle proprietà e i valori sono i valori iniziali corrispondenti. Possono essere configurate solo variabili membro pubbliche e proprietà definite da getter / setter.
- Gli elementi `on eventName` speicficano quali gestori devonon essere collegati agli eventi dell'oggetto. Si noti che le chiavi dell'array sono formate dal prefisso dei nomi degli eventi con `on`. Fare riferimento alla sezione Eventi per i formati di gestori di eventi supportati.
- Gli elementi `as behaviorName` specificano quali comportamenti devono essere collegati all'oggetto. Si noti che le chiavi dell'array sono formate dal prefisso dei nomi degli eventi con `as`; il valore, `$behaviorConfig` rappresenta la configurazione per la creazione di un comportamento, come una configurazione normale descritta qui.

Di seguito è riportato un esempio che mostra una configurazione con valori di proprità iniziali, gestori di eventi e comportamenti:

    [
        'class' => 'app\components\SearchEngine',
        'apiKey' => 'xxxxxxxx',
        'on search' => function ($event) {
            Yii::info("Keyword searched: " . $event->keyword);
        },
        'as indexer' => [
            'class' => 'app\components\IndexerBehavior',
            // ... property init values ...
        ],
    ]


##Utilizzo delle configurazioni


Le configurazioni sono utilizzate in molti posti in Yii. All'inizio di questa sezione, abbiamo mostrato come creare un oggetto secondo una configurazione usando **Yii :: createObject()**. In questa sottosezione, descriveremo le configurazioni delle applicazioni e le configurazioni dei widget: due importanti usi delle configurazioni.


##Configurazioni dell'applicazione


La configurazione per un'applicazione è probabilmente uno degli array più complessi in Yii. Questo perché la classe dell'applicazione ha molte proprietà ed eventi configurabili. Ancora più importante, la sua proprietà **yii \ web \ Application :: components** può ricevere una serie di configurazioni per la creazione di componenti registrati tramite l'applicazione. Di seguito è riportato un estratto dal file di configurazione dell'applicazione per il modello di progetto di base.

    $config = [
        'id' => 'basic',
        'basePath' => dirname(__DIR__),
        'extensions' => require __DIR__ . '/../vendor/yiisoft/extensions.php',
        'components' => [
            'cache' => [
                'class' => 'yii\caching\FileCache',
            ],
            'mailer' => [
                'class' => 'yii\swiftmailer\Mailer',
            ],
            'log' => [
                'class' => 'yii\log\Dispatcher',
                'traceLevel' => YII_DEBUG ? 3 : 0,
                'targets' => [
                    [
                        'class' => 'yii\log\FileTarget',
                    ],
                ],
            ],
            'db' => [
                'class' => 'yii\db\Connection',
                'dsn' => 'mysql:host=localhost;dbname=stay2',
                'username' => 'root',
                'password' => '',
                'charset' => 'utf8',
            ],
        ],
    ];

La configurazione non ha una chaive `class`. Questo perché è usato come segue in uno script di entrata, dove il nome della classe è già stato dato,

    (new yii\web\Application($config))->run();

Dalla versione 2.0.11, la configurazione dell'applicazione supporta la configurazione del contenitore di iniezione delle dipendenze utilizzando la proprietà `container`. Per esempio:

    $config = [
        'id' => 'basic',
        'basePath' => dirname(__DIR__),
        'extensions' => require __DIR__ . '/../vendor/yiisoft/extensions.php',
        'container' => [
            'definitions' => [
                'yii\widgets\LinkPager' => ['maxButtonCount' => 5]
            ],
            'singletons' => [
                // Dependency Injection Container singletons configuration
            ]
        ]
    ];


##Configurazioni di widget


Quando si utilizzano i widget , è spesso necessario utilizzare le configurazioni per personalizzare le proprietà del widget. Entrambi i metodi **yii \ base \ Widget :: widget()** e **yii \ base \ Widget :: begin()** possono essere utilizzati per creare un widget. Prendono un array di configurazione, come il seguente,

    use yii\widgets\Menu;

    echo Menu::widget([
        'activateItems' => false,
        'items' => [
            ['label' => 'Home', 'url' => ['site/index']],
            ['label' => 'Products', 'url' => ['product/index']],
            ['label' => 'Login', 'url' => ['site/login'], 'visible' => Yii::$app->user->isGuest],
        ],
    ]);

Il codice sopra crea un widget `Menu` e inizializza la sua proprietà `activateItems`al valore `false`. La proprietà `items` è configurata anche con voci di menu da visualizzare.

Si noti che poichè il nome della classe è già stato dato, l'array di configurazione NON deve avere la chiave `class`.


##File di configurazione


Quando una configurazione è molto complessa, è prassi comune memorizzarla in uno o più file PHP, noti come file di configurazione. Un file di configurazione restituisce un array PHP che rappresenta la configurazione. Ad esempio, è possibile mantenere una configurazione dell'applicazione in un file denominato `web.php`, come il seguente,

    return [
        'id' => 'basic',
        'basePath' => dirname(__DIR__),
        'extensions' => require __DIR__ . '/../vendor/yiisoft/extensions.php',
        'components' => require __DIR__ . '/components.php',
    ];

Poiché anche la configurazione `components` è complessa, la si archivia in un file separato chiamato `components.php` e "richiede" questo file `web.php` come mostrato sopra. Il contenuto di `components.php` è come segue,

    return [
        'cache' => [
            'class' => 'yii\caching\FileCache',
        ],
        'mailer' => [
            'class' => 'yii\swiftmailer\Mailer',
        ],
        'log' => [
            'class' => 'yii\log\Dispatcher',
            'traceLevel' => YII_DEBUG ? 3 : 0,
            'targets' => [
                [
                    'class' => 'yii\log\FileTarget',
                ],
            ],
        ],
        'db' => [
            'class' => 'yii\db\Connection',
            'dsn' => 'mysql:host=localhost;dbname=stay2',
            'username' => 'root',
            'password' => '',
            'charset' => 'utf8',
        ],
    ];

Per ottenere una configurazione memorizzata in un file di configurazione, è sufficiente "richiederla", come la seguente:

    $config = require 'path/to/web.php';
    (new yii\web\Application($config))->run();


##Configurazioni predefinite


Il metodo **Yii :: createObject()** è implementato in base a un contenitore di input delle dipendenze. Ti consente di specificare un insieme di configurazioni predefinite che verranno applicate a TUTTE le istanze delle classi specificate quando vengono create utilizzando **Yii :: createObject()**. Le configurazioni predefinite possono essere specificate chiamando **Yii::$container->set()** nel codice di bootstrap.

Ad esempio, se si desidera personalizzare **yii \ widgets \ LinkPager** in modo che TUTTI i pager di collegamento mostrino al massimo 5 pulsanti di pagina (il valore predefinito è 10), è possibile utilizzare il seguente codice per raggiungere questo obiettivo:

    \Yii::$container->set('yii\widgets\LinkPager', [
        'maxButtonCount' => 5,
    ]);

Senza usare le configurazioni di default, dovresti configurare `maxButtonCount` in ogni posto dove usi i cercapersone.


##Costanti ambientali


Le configurazioni variano spesso in base all'ambiente in cui viene eseguita un'applicazione. Ad esempio, nell'ambiente di sviluppo, potresti voler utilizzare un database chiamato `mydb_dev`, mentre sul server di produzione potresti voler utilizzare il `mydb_prod` database. Per facilitare gli ambienti di passaggio, Yii fornisce una costante denominata **YII_ENV** che è possibile definire nello script di entrata della propria applicazione. Per esempio,

    defined('YII_ENV') or define('YII_ENV', 'dev');

Puoi definire `YII_ENV` uno dei seguenti valori:

- `prod`: ambiente di produzione. La costante `YII_ENV_PROD` avrà un valore `true`. Questo è il valore predefinito di `YII_ENV` se non lo definisci.
- `dev`: sviluppo dell'ambiente di programmazione. La costante `YII_ENV_DEV` avrà un valore `true`.
- `test`: ambiente di test. La costante `YII_ENV_TEST` avrà un valore `true`.

Con queste costanti di ambiente, è possibile specificare le configurazioni in modo condizionale in base all'ambiente corrente. Ad esempio, la configurazione dell'applicazione potrebbe contenere il seguente codice per abilitare la barra degli strumenti di debug e il debugger nell'ambiente di sviluppo.

    $config = [...];

    if (YII_ENV_DEV) {
        // configuration adjustments for 'dev' environment
        $config['bootstrap'][] = 'debug';
        $config['modules']['debug'] = 'yii\debug\Module';
    }

    return $config;

