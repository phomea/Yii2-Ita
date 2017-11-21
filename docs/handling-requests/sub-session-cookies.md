#Session e Cookies


Le sessioni e i cookie consentono di mantenere i dati su più richieste degli utenti. In semplice PHP è possibile accedervi tramite le variabili globali `$_SESSION` e `$_COOKIE`. Yii incapsula sessioni e cookie come oggetti e quindi ti consente di accedervi in ​​modo orientato agli oggetti con ulteriori utili miglioramenti.


##Sessioni


Come le request e le responses , è possibile accedere alle sessioni tramite il componente `session` dell'applicazione, che è un'istanza di ***yii \ web \ Session***, per impostazione predefinita.


##Apertura e chiusura delle sessioni

Per aprire e chiudere una sessione, puoi fare quanto segue:

    $session = Yii::$app->session;

    // check if a session is already open
    if ($session->isActive) ...

    // open a session
    $session->open();

    // close a session
    $session->close();

    // destroys all data registered to a session.
    $session->destroy();

Puoi chiamare ***open()*** e ***close()*** più volte,senza causare errori; internamente i metodi controlleranno prima se la sessione è già aperta.


##Accesso ai dati della sessione


Per accedere ai dati memorizzati nella sessione, è possibile effettuare le seguenti operazioni:

    $session = Yii::$app->session;

    // get a session variable. The following usages are equivalent:
    $language = $session->get('language');
    $language = $session['language'];
    $language = isset($_SESSION['language']) ? $_SESSION['language'] : null;

    // set a session variable. The following usages are equivalent:
    $session->set('language', 'en-US');
    $session['language'] = 'en-US';
    $_SESSION['language'] = 'en-US';

    // remove a session variable. The following usages are equivalent:
    $session->remove('language');
    unset($session['language']);
    unset($_SESSION['language']);

    // check if a session variable exists. The following usages are equivalent:
    if ($session->has('language')) ...
    if (isset($session['language'])) ...
    if (isset($_SESSION['language'])) ...

    // traverse all session variables. The following usages are equivalent:
    foreach ($session as $name => $value) ...
    foreach ($_SESSION as $name => $value) ...


!!!Info
    Quando si accede ai dati della sessione attraverso il componente `session`, una sessione verrà aperta automaticamente se non è stata eseguita in precedenza. Questo è diverso dall'accedere ai dati della sessione attraverso `$_SESSION`, che richiede un esplicito richiamo di `session_start()`.

Quando si lavora con dati di sessione che sono matrici, il componente `session` presenta una limitazione che impedisce di modificare direttamente un elemento dell'array. Per esempio,

    $session = Yii::$app->session;

    // the following code will NOT work
    $session['captcha']['number'] = 5;
    $session['captcha']['lifetime'] = 3600;

    // the following code works:
    $session['captcha'] = [
        'number' => 5,
        'lifetime' => 3600,
    ];

    // the following code also works:
    echo $session['captcha']['lifetime'];

È possibile utilizzare uno dei seguenti metodi per risolvere questo problema:

    $session = Yii::$app->session;

    // directly use $_SESSION (make sure Yii::$app->session->open() has been called)
    $_SESSION['captcha']['number'] = 5;
    $_SESSION['captcha']['lifetime'] = 3600;

    // get the whole array first, modify it and then save it back
    $captcha = $session['captcha'];
    $captcha['number'] = 5;
    $captcha['lifetime'] = 3600;
    $session['captcha'] = $captcha;

    // use ArrayObject instead of array
    $session['captcha'] = new \ArrayObject;
    ...
    $session['captcha']['number'] = 5;
    $session['captcha']['lifetime'] = 3600;

    // store array data by keys with a common prefix
    $session['captcha.number'] = 5;
    $session['captcha.lifetime'] = 3600;


Per migliorare le prestazioni e la leggibilità del codice, consigliamo l'ultima soluzione. Cioè, invece di memorizzare una matrice come una singola variabile di sessione, si memorizza ogni elemento dell'array come una variabile di sessione che condivide lo stesso prefisso chiave con altri elementi dell'array.


##Archiviazione personalizzata di una sessione


La classe predefinita ***yii \ web \ Session*** memorizza i dati di sessione come file sul server. Yii fornisce inoltre le seguenti classi di sessione che implementano diverse sessioni di archiviazione:

- ***yii \ web \ DbSession***: memorizza i dati di sessione in una tabella di database.
- ***yii \ web \ CacheSession***: memorizza i dati della sessione in una cache con l'aiuto di un componente configurato della cache.
- ***yii \ redis \ Session***: memorizza i dati della sessione usando ***redis*** come supporto di memorizzazione.
- ***yii \ mongodb \ Session***: memorizza i dati della sessione in un MongoDB.

Tutte queste classi di sessione supportano lo stesso insieme di metodi API. Di conseguenza, è possibile passare a una classe di archiviazione di sessione diversa senza la necessità di modificare il codice dell'applicazione che utilizza le sessioni.

!!!Warning
    Se si desidera accedere ai dati della sessione `$_SESSION` durante l'utilizzo della memorizzazione della sessione personalizzata, è necessario assicurarsi che la sessione sia già stata avviata da ***yii \ web \ Session :: open()***. Questo perché i gestori di archiviazione di sessione personalizzati sono registrati all'interno di questo metodo.

Per informazioni su come configurare e utilizzare queste classi di componenti, fare riferimento alla relativa documentazione API. Di seguito è riportato un esempio che mostra come configurare ***yii \ web \ DbSession*** nella configurazione dell'applicazione per utilizzare una tabella di database per l'archiviazione di sessione:

    return [
        'components' => [
            'session' => [
                'class' => 'yii\web\DbSession',
                // 'db' => 'mydb',  // the application component ID of the DB connection. Defaults to 'db'.
                // 'sessionTable' => 'my_session', // session table name. Defaults to 'session'.
            ],
        ],
    ];

È inoltre necessario creare la seguente tabella del database per memorizzare i dati della sessione:

    CREATE TABLE session
    (
        id CHAR(40) NOT NULL PRIMARY KEY,
        expire INTEGER,
        data BLOB
    )

dove 'BLOB' si riferisce al tipo BLOB del tuo DBMS preferito. Di seguito sono riportati i tipi di BLOB che possono essere utilizzati per alcuni DBMS popolari:

- MySQL: LONGBLOB
- PostgreSQL: BYTEA
- MSSQL: BLOB

!!!Warning
    In base all'impostazione `php.ini` di `session.hash_function`, potrebbe essere necessario regolare la lunghezza della colonna `id`. Ad esempio, se `session.hash_function=sha256`, dovresti usare una lunghezza 64 invece di 40.

In alternativa, questo può essere realizzato con la seguente migrazione:

    <?php

    use yii\db\Migration;

    class m170529_050554_create_table_session extends Migration{

        public function up(){

            $this->createTable('{{%session}}', [
                'id' => $this->char(64)->notNull(),
                'expire' => $this->integer(),
                'data' => $this->binary()
            ]);
            $this->addPrimaryKey('pk-id', '{{%session}}', 'id');
        }

        public function down(){

            $this->dropTable('{{%session}}');
        
        }
    }


##Dati flash


I dati Flash sono un tipo speciale di dati di sessione che, una volta impostati in una richiesta, saranno disponibili solo durante la richiesta successiva e verranno automaticamente eliminati in seguito. I dati flash vengono comunemente utilizzati per implementare i messaggi che devono essere visualizzati una sola volta agli utenti finali, ad esempio un messaggio di conferma visualizzato dopo che un utente ha inviato correttamente un modulo.

È possibile impostare e accedere ai dati flash tramite il componente `session` dell'applicazione. Per esempio,

    $session = Yii::$app->session;

    // Request #1
    // set a flash message named as "postDeleted"
    $session->setFlash('postDeleted', 'You have successfully deleted your post.');

    // Request #2
    // display the flash message named "postDeleted"
    echo $session->getFlash('postDeleted');

    // Request #3
    // $result will be false since the flash message was automatically deleted
    $result = $session->hasFlash('postDeleted');

Come i normali dati di sessione, è possibile memorizzare dati arbitrari come dati flash.

Quando chiami ***yii \ web \ Session :: setFlash()***, sovrascriverà tutti i dati flash esistenti che hanno lo stesso nome. Per aggiungere nuovi dati flash a un messaggio esistente con lo stesso nome, è possibile chiamare ***yii \ web \ Session :: addFlash()***. Per esempio:

    $session = Yii::$app->session;

    // Request #1
    // add a few flash messages under the name of "alerts"
    $session->addFlash('alerts', 'You have successfully deleted your post.');
    $session->addFlash('alerts', 'You have successfully added a new friend.');
    $session->addFlash('alerts', 'You are promoted.');

    // Request #2
    // $alerts is an array of the flash messages under the name of "alerts"
    $alerts = $session->getFlash('alerts');

!!!Warning
    Cerca di non utilizzare ***yii \ web \ Session :: setFlash ()*** insieme a ***yii \ web \ Session :: addFlash ()*** per i dati flash con lo stesso nome. Questo perché il secondo metodo trasformerà automaticamente i dati flash in una matrice in modo che possa aggiungere nuovi dati flash con lo stesso nome. Di conseguenza, quando chiami ***yii \ web \ Session :: getFlash ()***, potresti trovare a volte una matrice mentre a volte ottieni una stringa, a seconda dell'ordine di invocazione di questi due metodi.

!!!Tip
    Per la visualizzazione dei messaggi Flash è possibile utilizzare il widget `Alert` di avvio nel seguente modo:
            
        echo Alert::widget([
            'options' => ['class' => 'alert-info'],
            'body' => Yii::$app->session->getFlash('postDeleted'),
        ]);


##Cookies


Yii rappresenta ciascun cookie come oggetto di ***yii \ web \ Cookie***. Sia ***yii \ web \ Request*** che ***yii \ web \ Response*** gestiscono una raccolta di cookie tramite la proprietà denominata cookies. La raccolta di cookie nel primo, rappresenta i cookie inviati in una richiesta,mentre la raccolta di cookie in quest'ultimo, rappresenta i cookie che devono essere inviati all'utente.

La parte dell'applicazione che riguarda direttamente la richiesta e la risposta è il controller. Pertanto, i cookie devono essere letti e inviati nel controller.


##Lettura dei cookie


È possibile ottenere i cookie nella richiesta corrente utilizzando il seguente codice:

    // get the cookie collection (yii\web\CookieCollection) from the "request" component
    $cookies = Yii::$app->request->cookies;

    // get the "language" cookie value. If the cookie does not exist, return "en" as the default value.
    $language = $cookies->getValue('language', 'en');

    // an alternative way of getting the "language" cookie value
    if (($cookie = $cookies->get('language')) !== null) {
        $language = $cookie->value;
    }

    // you may also use $cookies like an array
    if (isset($cookies['language'])) {
        $language = $cookies['language']->value;
    }

    // check if there is a "language" cookie
    if ($cookies->has('language')) ...
    if (isset($cookies['language'])) ...


##Invio dei cookies


Puoi inviare cookie agli utenti finali utilizzando il seguente codice:

    // get the cookie collection (yii\web\CookieCollection) from the "response" component
    $cookies = Yii::$app->response->cookies;

    // add a new cookie to the response to be sent
    $cookies->add(new \yii\web\Cookie([
        'name' => 'language',
        'value' => 'zh-CN',
    ]));

    // remove a cookie
    $cookies->remove('language');
    // equivalent to the following
    unset($cookies['language']);

Oltre al nome, alle proprietà del valore mostrate negli esempi precedenti, la classe ***yii \ web \ Cookie*** definisce anche altre proprietà per rappresentare completamente tutte le informazioni sui cookie disponibili, come il dominio, la scadenza, ecc.. È possibile configurare queste proprietà come necessario per preparare un cookie e quindi aggiungerlo alla raccolta di cookie della risposta.


##Convalida dei cookier


Durante la lettura e l'invio di cookie tramite i componenti `request` e `response` come mostrato nelle ultime due sottosezioni, si gode della maggiore sicurezza della convalida dei cookie che protegge i cookie dalla modifica sul lato client. Ciò si ottiene firmando ogni cookie con una stringa **hash**, che consente all'applicazione di stabilire se un cookie è stato modificato sul lato client. In tal caso, il cookie NON sarà accessibile tramite i cookie ***yii \ web \ Request ::*** del componente `request`.

!!!Warning
    La convalida dei cookie protegge solo i valori dei cookie dalla modifica. Se un cookie non supera la convalida, puoi comunque accedervi `$_COOKIE`. Ciò è dovuto al fatto che le librerie di terze parti possono manipolare i cookie a modo loro, il che non implica la convalida dei cookie.

La convalida dei cookie è abilitata per impostazione predefinita. È possibile disabilitarlo impostando la proprietà ***Yii \ web \ Request :: $ enableCookieValidation***  di essere `false`, anche se si consiglia vivamente di non farlo.

!!!Warning
    I cookie che vengono letti direttamente / inviati tramite `$_COOKIE` e `setcookie()` NON saranno convalidati.

Quando si utilizza la convalida dei cookie, è necessario specificare un ***yii \ web \ Request :: $ cookieValidationKey*** che verrà utilizzato per generare le stringhe `hash` summenzionate. È possibile farlo configurando il componente `request` nella configurazione dell'applicazione:

    return [
        'components' => [
            'request' => [
                'cookieValidationKey' => 'fill in a secret key here',
            ],
        ],
    ];

!!!Info
    ***cookieValidationKey*** è fondamentale per la sicurezza dell'applicazione. Dovrebbe essere noto solo alle persone di cui ti fidi. Non memorizzarlo nel sistema di controllo della versione.

























