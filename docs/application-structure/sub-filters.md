#Filtri (filters)

I filtri sono oggetti che vengono eseguiti prima e / o dopo le azioni del controllore. Ad esempio, un filtro di controllo dell'accesso può essere eseguito dalle azioni per garantire che sia loro consentito l'accesso da parte di determinati utenti finali; un filtro di compressione del contenuto può essere eseguito dopo le azioni per comptrimere il contenuto della risposta prima di inviarlo agli utenti finali.

Un filtro può consistere in un pre-filtro (logica di filtraggio applicata prima delle azioni) e / o un post-filtro (logica applicata dopo le azioni).


##Utilizzando i filtri


I filtri ahnno un comportamente abbastanza particolare. Pertanto, l'uso dei filtri è uguale all'utilizzo dei "behaviors".E' possibile dichiarare i filtri di una classe controller sovrascrivendo il suo metodo ***behaviors()*** come il seguente:

    public function behaviors(){

        return [
            [
                'class' => 'yii\filters\HttpCache',
                'only' => ['index', 'view'],
                'lastModified' => function ($action, $params) {
                    $q = new \yii\db\Query();
                    return $q->from('user')->max('updated_at');
                },
            ],
        ];
    }

Per impostazione predefinita, i filtri dichiarati in una classe controller verranno applicati a tutte le azioni in quel controller. Tuttavia, è possibile specificare esplicitamente a quali azioni applicare il filtro configurando la proprietà ***only***. Nell'esempio soprastante, il filtro ```HttpCache``` si applica solo alle azioni ```index``` e ```view```. E' anche possibile configurare la proprietà ***except*** per mettere in blacklist alcune azioni dell'essere filtrate.

oltre ai controller, puoi anche dichiarare i filtri in un modulo o in un'applicazione. Quando lo fa, i filtri verranno applicate tutte le azioni di controllo che appartengono a tale modulo o applicazione, a meno che non si configurano i filtri "only" e "except" come descritto sopra.

!!!Warning
    Quando si dichiara filtri in moduli o applicazioni, è necessario utilizzare percorsi invece di ID di azione nelle proprietà ***only*** e ***except***. Questo perchè gli ID d'azione da solo non possono specificare completamente le azioni nell'ambito di un modulo o di un'applicazione.

Quando più filtri sono configurati per una singola azione, vengnono applicati in base alle regole descritte di seguito:

1. Pre-filtraggio
    - Applicare i filtri dichiarati nell'applicazione nell'ordine in cui sono elencati ```behaviors()```.
    - Applicare i filtri dichiarati nel modulo nell'ordine in cui sono elencati ```behaviors()```.
    - Applicare i filtri dichiarati nel controller nell'ordine in cui sono elencati ```behaviors()```.
    - Se uno qualsiasi dei filtri annulla l'esecuzione dell'azione, i filtri (prefiltri e post-filtri) non verranno applicati.
2. Esecuzione dell'azione de passa per il pre-filtro.
3. Post-filtraggio
    - Applicare i filtri dichiarati nel controller nell'ordine inverso in cui sono elencati ```behaviors()```.
    - Applicare i filtri dichiarati nel modulo nell'ordine inverso in cui sono elencati ```behaviors()```.
    - Applicare i filtri dichiarati nell'applicazione nell'ordine inverso in cui sono elencati ```behaviors()```.


##Creazione di filtri

Per creare un nuovo filtro azione, dobbiamo estenderlo da ***yii \ base \ ActionFilter*** e sovrascrivi i metodi ***beforeAction()*** e / o ***afterAction()***. Il primo verrà eseguito prima dell'esecuzione di un'azione mentre il secondo dopo l'esecuzione di un'azione. Il valore di ritorno di ***beforeAction()*** determina se un'azione deve essere eseguita o meno. Se il valore è ```false```, i filtri dopo questo verranno saltati e l'azione non verrà eseguita.

L'esempio seguente mostra un filtro che registra il tempo di esecuzione dell'azione:

    namespace app\components;

    use Yii;
    use yii\base\ActionFilter;

    class ActionTimeFilter extends ActionFilter{

        private $_startTime;

        public function beforeAction($action){

            $this->_startTime = microtime(true);
            return parent::beforeAction($action);
        }

        public function afterAction($action, $result){

            $time = microtime(true) - $this->_startTime;
            Yii::trace("Action '{$action->uniqueId}' spent $time second.");
            return parent::afterAction($action, $result);
        }
    }


##Filtri principali

Yii fornisce un set di filtri comunemente usati, trovati principalmente sotto il namespace ```yii\filters```. Di seguit, introdurremo brevemente questi filtri.


##Controllo all'accesso


***AccessControl*** fornisce un semplice controllo degli accessi basato su un insieme di regole. In particolare, prima che un'azione venga eseguita, AccessControl esaminerà le regole elencate e troverà il primo che corrisponde alle variabili di contesto correnti (come l'indirizzo IP dell'utente, lo stato di accesso dell'utente, ecc..). La regola di corrispondenza determinerà se consentire o negare l'esecuzione dell'azione richiesta. Se nessuna regola corrisponde, l'accesso verrà negato.

L'esempio seguente mostra come consentire agli utenti autenticati di accedere alle azione ```create``` e ```update```, mentre negando tutti gli altri utenti di accedere a queste due azioni.

    use yii\filters\AccessControl;

    public function behaviors(){

        return [
            'access' => [
                'class' => AccessControl::className(),
                'only' => ['create', 'update'],
                'rules' => [
                    // allow authenticated users
                    [
                        'allow' => true,
                        'roles' => ['@'],
                    ],
                    // everything else is denied by default
                ],
            ],
        ];
    }


##Filtri del metodo di autenticazione


I filtri del metodo di autenticazione vengono utilizzati per autenticare un utente utilizzando vari metodi, come ***HTTP Basic Auth***, ***OAuth 2***. Queste classi di filtri sono tutte sotto il namespace ```yii\filters\auth```.

L'esempio seguente mostra come utilizzare ***yii \ filters \ auth \ HttpBasicAuth*** per autenticare un utente utilizzando un token di accesso basato sul metodo di autenticazione HTTP di base. Si noti che affinchè funzioni, la classe di identità dell'utente deve implementare il metodo ***findIdentityByAccessToken()***.

    use yii\filters\auth\HttpBasicAuth;

    public function behaviors(){

        return [
            'basicAuth' => [
                'class' => HttpBasicAuth::className(),
            ],
        ];
    }
    
I filtri del metodo di autenticazione sono comunemente usati nell'implementazione delle API Restful.


##ContentNegotiator


***ContentNegotiator*** supporta la negoziazione del formato di risposta e la negoziazione della lingua dell'applicazione. Proverà a determinare il formato di risposta e / o la lingua esaminando i parametri ```GET``` e l'intestazione HTTP ```Accept```.

Nell'esempio seguente, ContentNegotiator è configurato per supportare i formati di risposta JSON e XML e le lingue inglese (Stati Uniti) e tedesca.

use yii\filters\ContentNegotiator;
use yii\web\Response;

    public function behaviors(){

        return [
            [
                'class' => ContentNegotiator::className(),
                'formats' => [
                    'application/json' => Response::FORMAT_JSON,
                    'application/xml' => Response::FORMAT_XML,
                ],
                'languages' => [
                    'en-US',
                    'de',
                ],
            ],
        ];
    }

Spesso i formati e le lingue di risposta devono essere determinati molto prima durante il ciclo di vita dell'applicazione. Per questo motivo, ContentNegotiator è progettato in modo tale da poter essere utilizzato anche come componente di bootstrap oltre a essere utilizzato come filtro. Ad esempio, puoi configurarlo nella configurazione dell'applicazione come segue:

    use yii\filters\ContentNegotiator;
    use yii\web\Response;

    [
        'bootstrap' => [
            [
                'class' => ContentNegotiator::className(),
                'formats' => [
                    'application/json' => Response::FORMAT_JSON,
                    'application/xml' => Response::FORMAT_XML,
                ],
                'languages' => [
                    'en-US',
                    'de',
                ],
            ],
        ],
    ];
    
!!!Note
    Nel caso in cui il tipo di contenuto e la lingua preferiti non possano essere determinati da una richiesta, verranno utilizzati il primo formato e la lingua elencati nei campi ***formats*** e ***languages***.


##HttpCache


***HttpCache*** implementa il caching sul lato client utilizzando le intestazioni HTTP ```Last-Modified``` e ```Etag```.
Per esempio:

    use yii\filters\HttpCache;

    public function behaviors(){

        return [
            [
                'class' => HttpCache::className(),
                'only' => ['index'],
                'lastModified' => function ($action, $params) {
                    $q = new \yii\db\Query();
                    return $q->from('user')->max('updated_at');
                },
            ],
        ];
    }


##PageCache


***PageCache*** implementa il catching lato server di pagine intere. Nell'esempio seguente, PageCache viene applicato all'azione ```index``` per memorizzare nella cache l'intera pagina per un massimo di 60 secondi o finchè il conteggio delle voci nella tabella ```post``` non cambia. Memorizza anche diverse versioni della pagina a seconda della lingua dell'applicazione scelta.

    use yii\filters\PageCache;
    use yii\caching\DbDependency;

    public function behaviors(){

        return [
            'pageCache' => [
                'class' => PageCache::className(),
                'only' => ['index'],
                'duration' => 60,
                'dependency' => [
                    'class' => DbDependency::className(),
                    'sql' => 'SELECT COUNT(*) FROM post',
                ],
                'variations' => [
                    \Yii::$app->language,
                ]
            ],
        ];
    }


##RateLimiter


***RateLimiter*** implementa un algoritmo di limitazione della velocità basato sull'algoritmo ***leaky bucket***. Viene principalmente utilizzato nell'implementazione di ApiRESTful.


##VerbFilter


***VerbFilter*** controlla se i metodi di richiesta HTTP sono consentiti dalle azioni richieste. Se non è consentito, genererà un'eccezione HTTP 405. Nell'esempio seguente, VerbFIlter viene dichiarato per specificare un set tipico di metodi di richiesta consentiti per le azioni CRUD.

    use yii\filters\VerbFilter;

    public function behaviors(){

        return [
            'verbs' => [
                'class' => VerbFilter::className(),
                'actions' => [
                    'index'  => ['get'],
                    'view'   => ['get'],
                    'create' => ['get', 'post'],
                    'update' => ['get', 'put', 'post'],
                    'delete' => ['post', 'delete'],
                ],
            ],
        ];
    }


##Cors


Condivisione delle risorse tra origini ***CORS*** è un meccanismo che consente a molte risorse (ad es. Caratters, JavaScript, ecc..). Su una pagina Web di essere richieste da un altro dominio al di fuori del dominio da cui proviene la risorsa. In particolare, le chiamate AJAX di JavaScript possono utilizzare il meccanismo XMLHttpRequest. Tali richieste "interdominio" sarebbero altrimenti vietate dai browser Web, secondo la stessa politica di sicurezza dell'origine. CORS definisce un modo in cui il browser e il server possono interagire per determinare se consentire o meno la richiesta di origine incrociata.

Il ***filtro Cors*** deve essere definito prima dei filtri di autenticazione / autorizzazione per assicurarsi che le intestazioni CORS vengano sempre inviate.

    use yii\filters\Cors;
    use yii\helpers\ArrayHelper;

    public function behaviors(){

        return ArrayHelper::merge([
            [
                'class' => Cors::className(),
            ],
        ], parent::behaviors());
    }

Controllare anche la sezione sui controller REST se si desidera aggiungere il filtro CORS a una classe ***yii \ rest \ ActiveController*** nella propria API.

Il filtraggio Cors può essere ottimizzato usando la proprietà ***$Cors***.

- ```cors['Origin']```: array utilizzato per definire le origini consentite. Può essere ```['*']```(tutti) o ```['http://www.myserver.net', 'http://www.myotherserver.com']```. Predefinito a ```['*']```.
- ```cors['Access-Control-Request-Method']```: rappresenta un array di verbi che sono consentiti da Yii come ```['GET', 'OPTIONS', 'HEAD']```. L'array predefinito è ```['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS']```.
- ```cors['Access-Control-Request-Headers']```: matrice di intestazioni consentite da Yii. Possono essere ```['*']``` tutte le intestazioni o specifiche ```['X-Request-With']```. Predefinito a ```['*']```.
- ```cors['Access-Control-Allow-Credentials']```: questa regola controlla se la richiesta corrente può essere fatta usando le credenziali. Può essere ```true```, ```false``` o ```null```(non impostato). Predefinito a ```null```.
- ```cors['Access-Control-Max-Age']```: definisce la durata della richiesta pre-flight. Il valore predefinito è ```86400```.

Ad esempio, consentendo CORS come URL di origine (```http://www.myserver.net```) con il metodo ```GET```, ```HEAD``` e ```OPTIONS```:

    use yii\filters\Cors;
    use yii\helpers\ArrayHelper;

    public function behaviors(){
        return ArrayHelper::merge([
            [
                'class' => Cors::className(),
                'cors' => [
                    'Origin' => ['http://www.myserver.net'],
                    'Access-Control-Request-Method' => ['GET', 'HEAD', 'OPTIONS'],
                ],
            ],
        ], parent::behaviors());
    }

E' possibile ottimizzare le intestazioni CORS sostituendo i parametri predefiniti in base all'azione. Ad esempio aggiungendo ```Access-Control-Allow-Credentials``` per l'azione di ```login``` potrebbe essere fatto in questo modo:

    use yii\filters\Cors;
    use yii\helpers\ArrayHelper;

    public function behaviors(){

        return ArrayHelper::merge([
            [
                'class' => Cors::className(),
                'cors' => [
                    'Origin' => ['http://www.myserver.net'],
                    'Access-Control-Request-Method' => ['GET', 'HEAD', 'OPTIONS'],
                ],
                'actions' => [
                    'login' => [
                        'Access-Control-Allow-Credentials' => true,
                    ]
                ]
            ],
        ], parent::behaviors());
    }

