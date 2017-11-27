#Localizzatore di servizi (Service Locator)


Un localizzatore di servizi (o service locator) è un oggetto che sa come fornire tutti i tipi di servizi (o componenti) di cui un'applicazione potrebbe aver bisogno. All'interno di un localizzatore di servizi, ogni componente esiste come unica istanza, identificata univocamente da un ID. Si utilizza l'ID per recuperare un componente dal localizzatore di servizi.

In Yii, un localizzatore di servizi è semplicemente un'istanza di **yii \ di \ ServiceLocator** o di una classe figlia.

Il localizzatore di servizi più utilizzato in Yii è l' oggetto dell'applicazione a cui è possibile accedere tramite `\Yii::$app`. I servizi offerti sono chiamati componenti di applicazioni, come la `request`, `response`e i componenti `urlManager`. È possibile configurare questi componenti, o addirittura sostituirli con le proprie implementazioni, attraverso la funzionalità fornita dal localizzatore di servizi.

Oltre all'oggetto dell'applicazione, ogni oggetto modulo è anche un localizzatore di servizi. I moduli implementano l' attraversamento dell'albero .

Per utilizzare un localizzatore di servizi, il primo passo è registrare i componenti con esso. Un componente può essere registrato tramite **yii \ di \ ServiceLocator :: set()**. Il seguente codice mostra diversi modi di registrare i componenti:

    use yii\di\ServiceLocator;
    use yii\caching\FileCache;

    $locator = new ServiceLocator;

    // register "cache" using a class name that can be used to create a component
    $locator->set('cache', 'yii\caching\ApcCache');

    // register "db" using a configuration array that can be used to create a component
    $locator->set('db', [
        'class' => 'yii\db\Connection',
        'dsn' => 'mysql:host=localhost;dbname=demo',
        'username' => 'root',
        'password' => '',
    ]);

    // register "search" using an anonymous function that builds a component
    $locator->set('search', function () {
        return new app\components\SolrService;
    });

    // register "pageCache" using a component
    $locator->set('pageCache', new FileCache);

Una volta che un componente è stato registrato, è possibile accedervi utilizzando il suo ID, in uno dei due seguenti modi:

    $cache = $locator->get('cache');
    // or alternatively
    $cache = $locator->cache;


Come mostrato sopra, **yii \ di \ ServiceLocator** consente di accedere a un componente come una proprietà, utilizzando l'ID del componente. Quando si accede a un componente per la prima volta, **yii \ di \ ServiceLocator** utilizzerà le informazioni di registrazione del componente stesso per creare una sua nuova istanza.
Successivamente, se si accede nuovamente al componente, il localizzatore di servizi restituirà la stessa istanza.

È possibile utilizzare **yii \ di \ ServiceLocator :: has()** per verificare se un componente ID è già stato registrato. Se chiami **yii \ di \ ServiceLocator :: get()** con un ID non valido, verrà generata un'eccezione.

Poiché i localizzatori di servizi vengono spesso creati con configurazioni , viene fornita una proprietà scrivibile denominata **components**. Ciò consente di configurare e registrare più componenti contemporaneamente. Il codice seguente mostra un array di configurazione che può essere utilizzato per configurare un localizzatore di servizi (ad esempio un'applicazione ) con `db`, `cache`, `tz` e componenti di `search`:

    return [
        // ...
        'components' => [
            'db' => [
                'class' => 'yii\db\Connection',
                'dsn' => 'mysql:host=localhost;dbname=demo',
                'username' => 'root',
                'password' => '',
            ],
            'cache' => 'yii\caching\ApcCache',
            'tz' => function() {
                return new \DateTimeZone(Yii::$app->formatter->defaultTimeZone);
            },
            'search' => function () {
                $solr = new app\components\SolrService('127.0.0.1');
                // ... other initializations ...
                return $solr;
            },
        ],
    ];

Quanto mostrato sopra, c'è un modo alternativo per configurare il componente di `search`. Invece di scrivere direttamente un callback PHP che costruisce l'istanza `SolrService`, è possibile utilizzare un metodo di classe statico per restituire tale callback, come mostrato di seguito:

    class SolrServiceBuilder{

        public static function build($ip){

            return function () use ($ip) {
                $solr = new app\components\SolrService($ip);
                // ... other initializations ...
                return $solr;
            };
        }
    }

    return [
        // ...
        'components' => [
            // ...
            'search' => SolrServiceBuilder::build('127.0.0.1'),
        ],
    ];


Questo approccio alternativo è  preferibile quando si rilascia un componente Yii che incapsula alcune librerie di terze parti non Yii. Si utilizza il metodo statico come mostrato sopra per rappresentare la complessa logica della creazione dell'oggetto di terze parti e l'utente del componente deve solo chiamare il metodo statico per configurare il componente.


##Attraversamento di alberi


I moduli consentono l'annidamento arbitrario; un'applicazione Yii è essenzialmente un albero di moduli. Poiché ciascuno di questi moduli è un localizzatore di servizi, ha senso che i bambini abbiano accesso ai loro genitori. Ciò consente ai moduli di utilizzare `$this->get('db')` invece di fare riferimento al localizzatore del servizio di root `Yii::$app->get('db')`. Il vantaggio aggiunto è l'opzione per uno sviluppatore di sovrascrivere la configurazione in un modulo.

Qualsiasi richiesta di recupero di un servizio da un modulo verrà passata al suo genitore nel caso in cui il modulo non sia in grado di soddisfarlo.
