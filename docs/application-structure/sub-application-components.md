#Componenti applicativi

Le applicazioni sono localizzatori di servizi. Essi ospitano un insieme di componenti dell'applicazione che forniscono diversi servizi per le richieste di elaborazione. Ad esempio, il componente ```urlManager``` è responsabile dell'instradamento delle richieste Web ai vai controller appropriati; il componente ```db``` fornisce servizi correlati al DB, e così via.
Ogni componente di applicazione ha un ID che lo identifica in modo univoco tra gli altri componenti dell'applicazione. E' possibile accedere ad ogni componente applicativo tramite la seguente espressione:

    \Yii::$app->componentID

Ad esempio, è possibile utilizzare ```\Yii::$app->db``` per ottenere la connessione al DB e ```\Yii::$app->cache``` per ottenere la cache primaria registrata con l'applicazione.

Una componente di applicazione viene creata la prima volta che viene acceduto tramite l'espressione indicata in precedenza. Tutti gli altri accsessi restituiranno la stessa istanza di componente.
I componenti dell'applicazione possono essere oggetti. E' possibile registrarli configurando la proprietà ***yii \ base \ Application :: $*** nella parte in cui avviene la configurazione della nostra applicazione.

Esempio:

    [
        'components' => [
            // register "cache" component using a class name
            'cache' => 'yii\caching\ApcCache',

            // register "db" component using a configuration array
            'db' => [
                'class' => 'yii\db\Connection',
                'dsn' => 'mysql:host=localhost;dbname=demo',
                'username' => 'root',
                'password' => '',
            ],

            // register "search" component using an anonymous function
            'search' => function () {
                return new app\components\SolrService;
            },
        ],
    ]

!!!Info
    Mentre è possibile registrare quanti componenti voi vogliate, devi fare questo giudizio. I componenti dell'applicazione sono come variabili globali. L'utilizzo di troppi componenti dell'applicazione può potenzialmente rendere il codice più difficile da testare. In molti casi, è possibile creare una componente locale e utilizzarlo quando necessario.


##Componenti di avvio


Come accennato in precedenza, una componente dell'applicazione verrà istanziata solo quando viene visualizzata la prima volta. Se non è affatto accessibile durante una richiesta, non verrà istanziata. A volte, però si può desiderare di creare un'istanza di un componente applicativo per ogni richiesta, anche se non è esplicitamente accessibile. A tal fine, è possibile elencare l'ID nella proprietà d'avvio dell'applicazione.

Ad esempio, la seguente configurazione dell'applicazione assicura che il componente di ```log``` sia sempre caricato:

    [
        'bootstrap' => [
            'log',
        ],
        'components' => [
            'log' => [
                // configuration for "log" component
            ],
        ],
    ]


##Componenti dell'applicazione di base


Yii definisce un insieme di componenti dell'applicazione "principali" con ID fisse e configurazioni predefinite. Ad esempio, la componente di ***request(richiesta)*** viene utilizzata per raccogliere informazioni su una richiesta di utente e risolverla in una ***route(percorso)***; il componente ***db*** rappresenta una connessione di database tramite cui è possibile eseguire query di database. Con l'aiuto di questi componenti principali, le applicazioni Yii sono in grado di gestire le richieste degli utenti.
Di seguito viene riportato l'elenco dei componenti predefiniti dell'applicazione di base. Puoi configurarli e personalizzarli come fai con i componenti di applicazione normali. Quando si configura una componente dell'applicazione principale, se non si specifica la classe, verrà utilizzato il valore predefinito.

- ***assetManager***: gestisce i bundle di asset e asset per la pubblicazione di informazioni(publishing);
- ***db***: rappresenta una connessione di database tramite cui è possibile eseguire query DB. Notare che quando si configura questo componente, è necessario specificare la classe del componente e altre proprietà richieste ( ad esempio ***yii \ db \ Connection :: $ dsn);
- ***yii \ base \ Application :: errorHandler***: gestisce errori e eccezioni PHP;
- ***formatter***: formatta i dati quando vengono visualizzati agli utenti finali. Ad esempio, una data può essere formattata in formato long;
- ***i18n***: supporta la traduzione e la formattazione dei messaggi;
- ***log***: gestisce gli obiettivi di log;
- ***mailer***: supporta la composizione e l'invio di posta;
- ***yii \ base \ Application :: response***: rappresenta la risposta inviata agli utenti finali;
- ***yii \ base \ Application :: request***: rappresenta la richiesta ricevuta dagli utenti finali;
- ***session(sessione)***: rappresenta le informazioni sulla sessione. Questo componente è disponibile solo nelle applicazioni Web;
- ***urlManager***: supporta l'analisi e la creazione di URL;
- ***user(utente)***: rappresenta le informazioni di autenticazione utente. Questo componente è disponibile solo nelle applicazioni Web;
- ***view(vista)***: supporta la visualizzazione delle view.