#Requests


Le richieste fatte ad un'applicazione sono rappresentate in termini di oggetti ***yii \ web \ Request*** che forniscono informazioni come parametri di richiesta, intestazioni HTTP, cookie, ecc. Per una determinata richiesta, è possibile accedere all'oggetto di richiesta corrispondente tramite il componente `request` dell'applicazione che è un'istanza di ***yii \ web \ Request***, per impostazione predefinita. In questa sezione, descriveremo come puoi utilizzare questo componente nelle tue applicazioni.


##Richiesta dei parametri


Per ottenere i parametri da una richiesta, puoi chiamare i metodi `get()` e `post()` del componente `request`. Restituiscono i valori di `$_GET` e `$_POST`. Per esempio,

    $request = Yii::$app->request;

    $get = $request->get();
    // equivalent to: $get = $_GET;

    $id = $request->get('id');
    // equivalent to: $id = isset($_GET['id']) ? $_GET['id'] : null;

    $id = $request->get('id', 1);
    // equivalent to: $id = isset($_GET['id']) ? $_GET['id'] : 1;

    $post = $request->post();
    // equivalent to: $post = $_POST;

    $name = $request->post('name');
    // equivalent to: $name = isset($_POST['name']) ? $_POST['name'] : null;

    $name = $request->post('name', '');
    // equivalent to: $name = isset($_POST['name']) ? $_POST['name'] : '';

!!!Info
    Invece di accedere direttamente a `$_GET` e `$_POST` e recuperare i parametri della richiesta, è consigliabile ottenerli tramite il componente `request` come mostrato sopra. Ciò renderà più facili i test di scrittura perché è possibile creare un componente di richiesta fittizia con dati di richiesta falsi.

Quando si implementano le API RESTful , è spesso necessario recuperare i parametri inviati tramite PUT, PATCH o altri metodi di richiesta. È possibile ottenere questi parametri chiamando i metodi ***yii \ web \ Request :: getBodyParam()***. Per esempio,

    $request = Yii::$app->request;

    // returns all parameters
    $params = $request->bodyParams;

    // returns the parameter "id"
    $param = $request->getBodyParam('id');

!!!Info
    A differenza dei parametri `GET`, i parametri inviati via POST, PUT, PATCH ecc.. vengono inviati nel corpo della richiesta. Il componente `request` analizzerà questi parametri quando li accederai attraverso i metodi descritti sopra. È possibile personalizzare il modo in cui vengono analizzati questi parametri configurando la proprietà ***yii \ web \ Request :: $ parsers***.


##Metodi relativi alle richieste


È possibile ottenere il metodo HTTP utilizzato la richiesta corrente tramite l'espressione ***Yii::$app->request->method***. È inoltre disponibile un intero set di proprietà booleane per verificare se il metodo corrente è di un certo tipo. Per esempio,

    $request = Yii::$app->request;

    if ($request->isAjax) { /* the request is an AJAX request */ }
    if ($request->isGet)  { /* the request method is GET */ }
    if ($request->isPost) { /* the request method is POST */ }
    if ($request->isPut)  { /* the request method is PUT */ }


##Richiesta degli URL


Il componente `request` offre molti modi per ispezionare l'URL attualmente richiesto.

Supponendo che l'URL richiesto sia `http://example.com/admin/index.php/product?id=100`, puoi ottenere varie parti di questo URL come riepilogato di seguito:

- `yii \ web \ Request :: url`: restituisce `/admin/index.php/product?id=100`, che è l'URL senza la parte di informazione dell'host.
- `yii \ web \ Request :: absoluteUrl`: restituisce `http://example.com/admin/index.php/product?id=100`, che è l'URL intero che include la parte di informazioni sull'host.
- `yii \ web \ Request :: hostInfo`: restituisce `http://example.com`, che è la parte di informazioni sull'host dell'URL.
- `yii \ web \ Request :: pathInfo`: restituisce `/product`, che è la parte dopo lo script di immissione e prima del punto interrogativo (stringa di query).
- `yii \ web \ Request :: queryString`: restituisce `id=100`, che è la parte dopo il punto interrogativo.
- `yii \ web \ Request :: baseUrl`: restituisce `/admin`, che è la parte dopo le informazioni sull'host e prima del nome dello script di immissione.
- `yii \ web \ Request :: scriptUrl`: restituisce `/admin/index.php`, che è l'URL senza informazioni sul percorso e stringa di query.
- `yii \ web \ Request :: serverName`: restituisce `example.com`, che è il nome host nell'URL.
- `yii \ web \ Request :: serverPort`: restituisce 80, che è la porta utilizzata dal server Web.


##Intestazioni HTTP


È possibile ottenere le informazioni dell'intestazione HTTP attraverso la raccolta dell'intestazione restituita dalla proprietà ***yii \ web \ Request ::***. Per esempio,

    // $headers is an object of yii\web\HeaderCollection 
    $headers = Yii::$app->request->headers;

    // returns the Accept header value
    $accept = $headers->get('Accept');

    if ($headers->has('User-Agent')) { /* there is User-Agent header */ }

Il componente `request` fornisce inoltre supporto per l'accesso rapido ad alcune intestazioni comunemente utilizzate, tra cui:

- `yii \ web \ Request :: userAgent`: restituisce il valore ***User-Agent*** dell'intestazione.
- `yii \ web \ Request :: contentType`: restituisce il valore **Content-Type** dell'intestazione che indica il tipo MIME dei dati nel corpo della richiesta.
- `yii \ web \ Request :: acceptableContentTypes`: restituisce i tipi MIME di contenuto accettabili dagli utenti. I tipi restituiti sono ordinati in base al loro punteggio di qualità. I tipi con i punteggi più alti verranno restituiti per primi.
- `yii \ web \ Request :: acceptableLingue`: restituisce le lingue accettabili dagli utenti. Le lingue restituite sono ordinate in base al loro livello di preferenza. Il primo elemento rappresenta la lingua più preferita.

Se l'applicazione supporta più lingue e si desidera visualizzare le pagine nella lingua che è la più preferita dall'utente finale, è possibile utilizzare il metodo di negoziazione della lingua ***yii \ web \ Request :: getPreferredLanguagd()***. Questo metodo prende un elenco di lingue supportate dall'applicazione, le confronta con **yii \ web \ Request :: acceptable** e restituisce la lingua più appropriata.

!!!Tip
    E' anche possibile utilizzare il filtro **ContentNegotiator** per determinare in modo dinamico quale tipo di contenuto e lingua devono essere utilizzati nella risposta. Il filtro implementa la negoziazione del contenuto in cima alle proprietà e ai metodi descritti sopra.

##Informazioni sul cliente


È possibile ottenere il nome host e l'indirizzo IP del computer client tramite ***yii \ web \ Request :: userHost*** e ***yii \ web \ Request :: userIP***. Per esempio,

    $userHost = Yii::$app->request->userHost;
    $userIP = Yii::$app->request->userIP;


##Proxy e intestazioni affidabili


Nella sezione precedente hai visto come ottenere informazioni utente come host e indirizzo IP. Questo funzionerà immediatamente in una configurazione normale in cui un singolo server web viene utilizzato per servire il sito web. Tuttavia, se l'applicazione Yii funziona dietro un proxy inverso, è necessario aggiungere ulteriore configurazione per recuperare queste informazioni poiché il client diretto ora è il proxy e l'indirizzo IP dell'utente viene passato all'applicazione Yii da un'intestazione impostata dal proxy.

Non dovresti fidarti ciecamente delle intestazioni fornite dai proxy, a meno che tu non ti fidi esplicitamente del proxy. Dal momento che Yii 2.0.13 supporta la configurazione di proxy fidati tramite le proprietà `trustedHosts`, `secureHeaders`, `ipHeaders` e `secureProtocolHeaders` del componente `request`.

Di seguito è riportata una richiesta di configurazione per un'applicazione che viene eseguita dietro una matrice di proxy inversi, che si trovano nella rete IP `10.0.2.0/24`:

    'request' => [
        // ...
        'trustedHosts' => [
            '/^10\.0\.2\.\d+$/',
        ],
    ],

L'IP viene inviato dal proxy `X-Forwarded-For` nell'intestazione per impostazione predefinita e viene inviato il protocollo ( `http` o `https`) `X-Forwarded-Proto`.

Nel caso in cui i proxy utilizzino intestazioni diverse, è possibile utilizzare la configurazione della richiesta per regolarle, ad esempio:

    'request' => [
        // ...
        'trustedHosts' => [
            '/^10\.0\.2\.\d+$/' => [
                'X-ProxyUser-Ip',
                'Front-End-Https',
            ],
        ],
        'secureHeaders' => [
                 'X-Forwarded-For',
                 'X-Forwarded-Host',
                'X-Forwarded-Proto',
                'X-Proxy-User-Ip',
                'Front-End-Https',
            ];
        'ipHeaders' => [
            'X-Proxy-User-Ip',
        ],
        'secureProtocolHeaders' => [
            'Front-End-Https' => ['on']
        ],
    ],

Con la configurazione di cui sopra indicata, tutte le intestazioni elencate `secureHeaders` sono filtrate dalla richiesta, ad eccezione delle intestazioni `X-ProxyUser-Ip` e `Front-End-Https` nel caso in cui la richiesta venga effettuata dal proxy. In questo caso il primo viene utilizzato per recuperare l'IP dell'utente come configurato in `ipHeaders` e quest'ultimo verrà utilizzato per determinare il risultato di ***yii \ web \ Request :: getIsSecureConnection()***.



















































