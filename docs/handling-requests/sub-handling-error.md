#Gestione degli errori


Yii include un gestore di errori incorporato che rende la gestione degli errori un'esperienza molto più piacevole di prima. In particolare, il gestore degli errori Yii effettua le seguenti operazioni per migliorare la gestione degli errori:

- Tutti gli errori PHP non fatali (ad es. avvertimenti, notifiche) vengono convertiti in eccezioni ***Catchable***.
- Eccezioni e errori fatali di PHP vengono visualizzati con informazioni dettagliate sullo stack di chiamata e linee di codice sorgente in modalità di debug.
- Supporta l'utilizzo di un'azione del controller dedicata per visualizzare gli errori.
- Supporta diversi formati di risposta agli errori.

Il gestore degli errori è abilitato per impostazione predefinita. Si può disabilitarlo definendo la costante `YII_ENABLE_ERROR_HANDLER` di essere `false` nell'entry script della vostra applicazione.


##Utilizziamo l'Error Handle


Il gestore degli errori è registrato come un componente dell'applicazione denominato `errorHandler`. Puoi configurarlo nella configurazione dell'applicazione come segue:

    return [
        'components' => [
            'errorHandler' => [
                'maxSourceLines' => 20,
            ],
        ],
    ];

Con la configurazione di cui sopra indicata, il numero di linee di codice sorgente da visualizzare nelle pagine delle eccezioni sarà fino a 20.

Come già detto, il gestore degli errori trasforma tutti gli errori PHP non fatali in eccezioni ***Catchable***. Ciò significa che è possibile utilizzare il seguente codice per gestire gli errori PHP:

    use Yii;
    use yii\base\ErrorException;

    try {
        10/0;
    } catch (ErrorException $e) {
        Yii::warning("Division by zero.");
    }

    // execution continues...

Se vuoi mostrare una pagina di errore che informa l'utente che la sua richiesta non è valida o inaspettata, puoi semplicemente lanciare un'eccezione HTTP , come ***yii \ web \ NotFoundHttpException***. Il gestore degli errori imposterà correttamente il codice di stato HTTP della risposta e utilizzerà una vista di errore appropriata per visualizzare il messaggio di errore.

    use yii\web\NotFoundHttpException;

    throw new NotFoundHttpException();


##Personalizzazione della visualizzazione degli errori


Il gestore degli errori regola la visualizzazione degli errori in base al valore della costante `YII_DEBUG`. Quando `YII_DEBUG` è a `true`(ovvero in modalità di debug), il gestore degli errori visualizza eccezioni con informazioni dettagliate sullo stack delle chiamate e linee del codice sorgente per facilitare il debugging. E quando `YII_DEBUG` è a `false`, verrà visualizzato solo il messaggio di errore per evitare di rivelare informazioni sensibili sull'applicazione.

!!!Info
    Se un'eccezione è discendente da ***yii \ base \ UserException***, non verrà visualizzato alcuno stack di chiamate indipendentemente dal valore di `YII_DEBUG`. Questo perché tali eccezioni sono considerate causate da errori dell'utente e gli sviluppatori non hanno bisogno di aggiustare nulla.

Per impostazione predefinita, il gestore errori visualizza gli errori utilizzando due viste :

- ```@yii/views/errorHandler/error.php```: usato quando devono essere visualizzati gli errori SENZA informazioni sullo stack di chiamata. Quando `YII_DEBUG` è a `false`, questa è l'unica visualizzazione di errore da visualizzare.
- ```@yii/views/errorHandler/exception.php```: usato quando devono essere visualizzati gli errori CON le informazioni sullo stack delle chiamate.

È possibile configurare le proprietà `errorView`` e `exceptionView` del gestore degli errori per utilizzare le proprie visualizzazioni per personalizzare la visualizzazione degli errori.


##Utilizzo delle azioni di errori


Un modo migliore per personalizzare la visualizzazione degli errori consiste nell'utilizzare azioni di errore dedicati. Per fare ciò, dobbiamo configurare innanzitutto la proprietà `errorAction` del componente `errorHandler` come segue:

    return [
        'components' => [
            'errorHandler' => [
                'errorAction' => 'site/error',
            ],
        ]
    ];

La proprietà `errorAction` prende una rotta verso un'azione. La configurazione precedente indica che quando è necessario visualizzare un errore senza informazioni sullo stack di chiamata, l'azione `site/error` deve essere eseguita.

È possibile creare l'azione `site/error` come segue,

    namespace app\controllers;

    use Yii;
    use yii\web\Controller;

    class SiteController extends Controller{

        public function actions(){

            return [
                'error' => [
                    'class' => 'yii\web\ErrorAction',
                ],
            ];
        }
    }

Il codice precedente definisce l'azione `error` utilizzando la classe ***yii \ web \ ErrorAction*** che esegue il rendering di un errore utilizzando una vista denominata `error`.

Oltre a usare ***yii \ web \ ErrorAction***, puoi anche definire l'azione `error` usando un metodo di azione come il seguente,

    public function actionError(){

        $exception = Yii::$app->errorHandler->exception;
        if ($exception !== null) {
            return $this->render('error', ['exception' => $exception]);
        }
    }

Ora dovresti creare un file di visualizzazione situato in `views/site/error.php`. In questo file di visualizzazione, è possibile accedere alle seguenti variabili se l'azione di errore è definita come ***yii \ web \ ErrorAction***:

- `name`: il nome dell'errore;
- `message`: il messaggio di errore;
- `exception`: l'oggetto di eccezione attraverso il quale è possibile recuperare informazioni più utili, come codice di stato HTTP, codice di errore, stack di chiamate di errore, ecc.

!!!Warning
    Se è necessario reindirizzare la pagina in un gestore errori, conviene farlo nel seguente modo:
        Yii::$app->getResponse()->redirect($url)->send();
        return;

    
##Personalizzazione del formato di risposta degli errori


Il gestore degli errori visualizza gli errori in base all'impostazione del formato della risposta. Se il formato della risposta è html, utilizzerà l'errore o la visualizzazione delle eccezioni per visualizzare gli errori, come descritto nell'ultima sottosezione. Per altri formati di risposta, il gestore degli errori assegnerà la rappresentazione dell'array dell'eccezione alla proprietà dei dati ***yii \ web \ Response :: $*** che verrà quindi convertita in diversi formati di conseguenza. Ad esempio, se il formato della risposta è `json`, potresti vedere la seguente risposta:

    HTTP/1.1 404 Not Found
    Date: Sun, 02 Mar 2014 05:31:43 GMT
    Server: Apache/2.2.26 (Unix) DAV/2 PHP/5.4.20 mod_ssl/2.2.26 OpenSSL/0.9.8y
    Transfer-Encoding: chunked
    Content-Type: application/json; charset=UTF-8

    {
        "name": "Not Found Exception",
        "message": "The requested resource was not found.",
        "code": 0,
        "status": 404
    }

È possibile personalizzare il formato di risposta dell'errore rispondendo all'evento `beforeSend` del componente `response` nella configurazione dell'applicazione:

    return [
        // ...
        'components' => [
            'response' => [
                'class' => 'yii\web\Response',
                'on beforeSend' => function ($event) {
                    $response = $event->sender;
                    if ($response->data !== null) {
                        $response->data = [
                            'success' => $response->isSuccessful,
                            'data' => $response->data,
                        ];
                        $response->statusCode = 200;
                    }
                },
            ],
        ],
    ];

Il codice sopra indicato riformatterà la risposta all'errore come la seguente:

    HTTP/1.1 200 OK
    Date: Sun, 02 Mar 2014 05:31:43 GMT
    Server: Apache/2.2.26 (Unix) DAV/2 PHP/5.4.20 mod_ssl/2.2.26 OpenSSL/0.9.8y
    Transfer-Encoding: chunked
    Content-Type: application/json; charset=UTF-8

    {
        "success": false,
        "data": {
            "name": "Not Found Exception",
            "message": "The requested resource was not found.",
            "code": 0,
            "status": 404
        }
    }







