#Responses


Quando un'applicazione termina la gestione di una richiesta, genera un oggetto risposta e lo invia all'utente finale. L'oggetto risposta contiene informazioni come il codice di stato HTTP, le intestazioni HTTP e il corpo. L'obiettivo finale dello sviluppo di applicazioni Web è essenzialmente quello di costruire tali oggetti di risposta su varie richieste.

Nella maggior parte dei casi dovresti occuparti principalmente del componente `response` dell'applicazione, che è un'istanza di ***yii \ web \ Response***, per impostazione predefinita. Tuttavia, Yii consente anche di creare i propri oggetti di risposta e inviarli agli utenti finali come spiegheremo di seguito.

In questa sezione, descriveremo come comporre e inviare risposte agli utenti finali.


##Stato del codice


Una delle prime cose che dovresti fare quando costruisci una risposta è dichiarare se la richiesta è gestita con successo. Questo viene fatto impostando la proprietà ***yii \ web \ Response :: statusCode*** che può assumere uno dei codici di stato HTTP validi . Ad esempio, per indicare che la richiesta è stata gestita correttamente, è possibile impostare il codice di stato su 200, come nell'esempio seguente:

    Yii::$app->response->statusCode = 200;

Tuttavia, nella maggior parte dei casi non è necessario impostare in modo esplicito il codice di stato. Ciò è dovuto al fatto che il valore predefinito di ***yii \ web \ Response :: statusCode*** è 200. E se si desidera indicare che la richiesta non ha esito positivo, è possibile generare un'eccezione HTTP appropriata come la seguente:

    throw new \yii\web\NotFoundHttpException;

Quando il gestore degli errori rileva un'eccezione, estrae il codice di stato dall'eccezione e lo assegna alla risposta. Per l'eccezione precedente ***yii \ web \ NotFoundHttpException***, è associato allo stato HTTP 404. Le seguenti eccezioni HTTP sono predefinite in Yii:

- ***yii \ web \ BadRequestHttpException***: codice di stato 400.
- ***yii \ web \ ConflictHttpException***: codice di stato 409.
- ***yii \ web \ ForbiddenHttpException***: codice di stato 403.
- ***yii \ web \ GoneHttpException***: codice di stato 410.
- ***yii \ web \ MethodNotAllowedHttpException***: codice di stato 405.
- ***yii \ web \ NotAcceptableHttpException***: codice di stato 406.
- ***yii \ web \ NotFoundHttpException***: codice di stato 404.
- ***yii \ web \ ServerErrorHttpException***: codice di stato 500.
- ***yii \ web \ TooManyRequestsHttpException***: codice di stato 429.
- ***yii \ web \ UnauthorizedHttpException***: codice di stato 401.
- ***yii \ web \ UnsupportedMediaTypeHttpException***: codice di stato 415.

Se l'eccezione che vuoi lanciare non è tra quelle elencate sopra, puoi crearne una estendendoti da ***yii \ web \ HttpException***, o lanciarla direttamente con un codice di stato, ad esempio,

    throw new \yii\web\HttpException(402);


##Intestazioni HTTP


È possibile inviare intestazioni HTTP manipolando le intestazioni ***yii \ web \ Response ::*** nel componente `response`. Per esempio,

    $headers = Yii::$app->response->headers;

    // add a Pragma header. Existing Pragma headers will NOT be overwritten.
    $headers->add('Pragma', 'no-cache');

    // set a Pragma header. Any existing Pragma headers will be discarded.
    $headers->set('Pragma', 'no-cache');

    // remove Pragma header(s) and return the removed Pragma header values in an array
    $values = $headers->remove('Pragma');

!!!Info
    I nomi delle intestazioni non fanno distinzione tra maiuscole e minuscole. E le intestazioni appena registrate non vengono inviate all'utente finché non viene chiamato il metodo ***yii \ web \ Response :: send ()***.


##Risposta da perte del Body


La maggior parte delle risposte dovrebbe avere un corpo che dia il contenuto che si desidera mostrare agli utenti finali.

Se si dispone già di una stringa di corpo formattata, è possibile assegnarla alla proprietà del contenuto ***yii \ web \ Response :: $*** della risposta. Per esempio,

    Yii::$app->response->content = 'hello world!';

Se i tuoi dati devono essere formattati prima di inviarli agli utenti finali, devi impostare sia il formato che le proprietà dei dati . La proprietà `format` specifica in quale formato i dati devono essere formattati. Per esempio,

    $response = Yii::$app->response;
    $response->format = \yii\web\Response::FORMAT_JSON;
    $response->data = ['message' => 'hello world'];

Yii supporta i seguenti formati pronti all'uso, ciascuno implementato da una classe di formattazione . È possibile personalizzare questi formattatori o aggiungerne di nuovi configurando la proprietà ***yii \ web \ Response :: $ formatters***.

- ***HTML***: implementato da **yii \ web \ HtmlResponseFormatter**.
- ***XML***:  implementato da **yii \ web \ XmlResponseFormatter**.
- ***JSON***: implementato da **yii \ web \ JsonResponseFormatter**.
- ***JSONP***: implementato da **yii \ web \ JsonResponseFormatter**.
- ***RAW***: utilizzare questo formato se si desidera inviare la risposta direttamente senza applicare alcuna formattazione.

Mentre il corpo della risposta può essere impostato esplicitamente come mostrato sopra, nella maggior parte dei casi è possibile impostarlo implicitamente dal valore di ritorno dei metodi di azione . Un caso d'uso comune è come il seguente:

    public function actionIndex(){

        return $this->render('index');
    
    }

L'azione `index` sopra indicata,restituisce il risultato del rendering della vista `index`. Il valore di ritorno sarà preso dal componente `response`, formattato e quindi inviato agli utenti finali.

Poiché,per impostazione predefinita, il formato di risposta è HTML , è necessario restituire una stringa solo in un metodo di azione. Se si desidera utilizzare un formato di risposta diverso, è necessario impostarlo prima di restituire i dati. Per esempio,

    public function actionInfo(){

        \Yii::$app->response->format = \yii\web\Response::FORMAT_JSON;
        return [
            'message' => 'hello world',
            'code' => 100,
        ];
    }

Come già accennato, oltre a utilizzare il componente predefinito dell'applicazione`response`, è anche possibile creare i propri oggetti di risposta e inviarli agli utenti finali. Puoi farlo restituendo tale oggetto in un metodo di azione, come il seguente,

    public function actionInfo(){

        return \Yii::createObject([
            'class' => 'yii\web\Response',
            'format' => \yii\web\Response::FORMAT_JSON,
            'data' => [
                'message' => 'hello world',
                'code' => 100,
            ],
        ]);
    }

!!!Warning
    Se si creano oggetti di risposta personalizzati, non sarà possibile sfruttare le configurazioni impostate per il componente `response` nella configurazione dell'applicazione. Tuttavia, è possibile utilizzare la "dependency injection" per applicare una configurazione comune ai nuovi oggetti risposta.


##Reindirizzamento del browser


Il reindirizzamento del browser si basa sull'invio dell'intestazione HTTP `Location`. Poiché questa funzione è comunemente utilizzata, Yii fornisce un supporto speciale per questo.

È possibile reindirizzare il browser utente a un URL chiamando il metodo ***yii \ web \ Response :: redirect()***. Il metodo imposta l'intestazione `Location` appropriata con l'URL specificato e restituisce l'oggetto risposta. In un metodo di azione, puoi chiamare la sua versione di collegamento **yii \ web \ Controller :: redirect()**. Per esempio,

    public function actionOld{

        return $this->redirect('http://example.com/new', 301);
    
    }

Nel codice precedente, il metodo `action` restituisce il risultato del metodo `redirect()`. Come spiegato in precedenza, l'oggetto risposta restituito da un metodo di azione verrà utilizzato come risposta inviata agli utenti finali.

In luoghi diversi da un metodo di azione, è necessario chiamare direttamente***yii \ web \ Response :: redirect()*** seguito da una chiamata concatenata al metodo **yii \ web \ Response :: send()** per garantire che nessun contenuto aggiuntivo venga aggiunto al risposta.

    \Yii::$app->response->redirect('http://example.com/new', 301)->send();


!!!Info
    Per impostazione predefinita, il metodo **yii \ web \ Response :: redirect ()** imposta il codice di stato della risposta su 302 che indica al browser che la risorsa richiesta è temporaneamente posizionata in un URL differente. Puoi passare un codice di stato 301 per dire al browser che la risorsa è stata trasferita permanentemente.

Quando la richiesta corrente è una richiesta AJAX, l'invio dell'intestazione `Location` non causerà automaticamente il reindirizzamento del browser. Per risolvere questo problema, il metodo **yii \ web \ Response :: redirect()** imposta un'intestazione `X-Redirect` con l'URL di reindirizzamento come valore. Sul lato client, è possibile scrivere codice JavaScript per leggere questo valore di intestazione e reindirizzare il browser di conseguenza.

!!!Info
    Yii viene fornito con un file Javascript chiamato `yii.js` che fornisce un insieme di utilità JavaScript comunemente utilizzate, incluso il reindirizzamento del browser basato sull'intestazione `X-Redirect`. Pertanto, se si utilizza questo file JavaScript (registrando il bundle asset **yii \ web \ YiiAsset** ), non è necessario scrivere nulla per supportare il reindirizzamento AJAX.


##Invio di file


Come il reindirizzamento del browser, l'invio di file è un'altra funzionalità che si basa su intestazioni HTTP specifiche. Yii fornisce una serie di metodi per supportare varie esigenze di invio di file. Hanno tutti il ​​supporto integrato per l'intestazione della gamma HTTP.

- ***yii \ web \ Response :: sendFile()***: invia un file esistente a un client.
- ***yii \ web \ Response :: sendContentAsFile()***: invia una stringa di testo come file a un client.
- ***yii \ web \ Response :: sendStreamAsFile()***: invia un flusso di file esistente come file a un client.

Questi metodi hanno la stessa firma del metodo con l'oggetto di risposta come valore di ritorno. Se il file da inviare è molto grande, dovresti considerare l'utilizzo di ***yii \ web \ Response :: sendStreamAsFile()*** perché è più efficiente in termini di memoria. L'esempio seguente mostra come inviare un file in un'azione del controllore:

    public function actionDownload(){

        return \Yii::$app->response->sendFile('path/to/file.txt');
    
    }

Se si chiama il metodo di invio del file in posizioni diverse da un metodo di azione, è necessario chiamare anche il metodo ***yii \ web \ Response :: send()*** in seguito per garantire che alla risposta non vengano aggiunti ulteriori contenuti.

    \Yii::$app->response->sendFile('path/to/file.txt')->send();

Alcuni server Web hanno un supporto speciale per l'invio di file chiamato `X-Sendfile`. L'idea è di reindirizzare la richiesta di un file al server Web che servirà direttamente il file. Di conseguenza, l'applicazione Web può terminare prima mentre il server Web sta inviando il file. Per utilizzare questa funzione, è possibile chiamare ***yii \ web \ Response :: xSendFile()***. Il seguente elenco riepiloga come abilitare la funzione `X-Sendfile` per alcuni server Web popolari:

- Apache: ***X-Sendfile***
- Lighttpd v1.4: ***X-LIGHTTPD-send-file***
- Lighttpd v1.5: ***X-Sendfile***
- Nginx: ***X-Accel-Redirect***
- Cherokee: ***X-Sendfile*** e ***X-Accel-Redirect***


##Invio della risposta


Il contenuto di una risposta non viene inviato all'utente finché non viene chiamato il metodo ***yii \ web \ Response :: send ()***. Per impostazione predefinita, questo metodo verrà chiamato automaticamente alla fine di **yii \ base \ Application :: run()**. Tuttavia, è possibile chiamare esplicitamente questo metodo per forzare l'invio della risposta immediatamente.

Il metodo ***yii \ web \ Response :: send()*** esegue i seguenti passi per inviare una risposta:

1. Innescare l'evento ***Yii \ web \ Response :: EVENT_BEFORE_SEND***.
2. Chiama il metodo **yii \ web \ Response :: prepare()** per formattare i dati di risposta nel contenuto della risposta .
3. Innescare l'evento ***Yii \ web \ Response :: EVENT_AFTER_PREPARE***.
4. Chiama il metodo ***Yii \ web \ Response :: sendHeaders ()*** per inviare le intestazioni HTTP registrate.
5. Chiamare il metodo ***yii \ web \ Response :: sendContent ()*** per inviare il contenuto del corpo della risposta.
6. Innescare l'evento ***Yii \ web \ Response :: EVENT_AFTER_SEND***.

Dopo che il metodo ***yii \ web \ Response :: send ()*** viene chiamato una volta, qualsiasi ulteriore chiamata a questo metodo verrà ignorata. Ciò significa che una volta inviata la risposta,non potrai aggiungere altro contenuto ad essa.

Come puoi vedere, il metodo ***yii \ web \ Response :: send()*** attiva numerosi eventi utili. Rispondendo a questi eventi, è possibile regolare o decorare la risposta.















































































