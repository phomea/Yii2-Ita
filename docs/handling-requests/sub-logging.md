#Registrazione


Yii fornisce un potente framework di registrazione che è altamente personalizzabile ed estensibile. Utilizzando questo framework, puoi facilmente registrare vari tipi di messaggi, filtrarli e riunirli a target diversi, come file, database, e-mail.

L'utilizzo del framework di registrazione Yii prevede i passaggi seguenti:

- Registra i messaggi di log in vari punti del tuo codice;
- Configurare le destinazioni dei registri nella configurazione dell'applicazione per filtrare ed esportare i messaggi di registro;
- Esaminare i messaggi registrati filtrati esportati da destinazioni diverse (ad esempio il debugger Yii ).

In questa sezione, descriveremo principalmente i primi due passaggi.


##Registrazione dei messaggi


Registrare i messaggi di registro è semplice, come chiamare uno dei seguenti metodi di registrazione:

- ***Yii :: trace()***: registra un messaggio per tracciare come funziona un pezzo di codice. Questo è principalmente per uso di sviluppo.
- ***Yii :: info()***: registra un messaggio che trasmette alcune informazioni utili.
- ***Yii :: warning()***: registra un messaggio di avviso che indica che è accaduto qualcosa di inaspettato;
- ***Yii :: error()***: registra un errore fatale che dovrebbe essere esaminato il prima possibile.

Questi metodi di registrazione, permettono di reigstrare i messaggi di registro a vari livelli e categorie di gravità. Condividono la stessa firma di funzione `function` (`$message`, `$category = 'application'`), dove `$message` sta per il messaggio di registro da registrare, mentre `$category` è la categoria del messaggio di registro. Il codice nell'esempio seguente registra un messaggio di traccia sotto la categoria predefinita application:

    Yii::trace('start calculating average revenue');

!!!Info
    I messaggi di registro possono essere stringhe e anche dati complessi, come matrici o oggetti. È responsabilità degli obiettivi di registro gestire adeguatamente i messaggi di registro. Per impostazione predefinita, se un messaggio di registro non è una stringa, verrà esportato come stringa chiamando ***yii \ helpers \ VarDumper :: export()***.

Per organizzare e filtrare meglio i messaggi di registro, si consiglia di specificare una categoria appropriata per ciascun messaggio di registro. È possibile scegliere uno schema di denominazione gerarchico per categorie, che renderà più semplice per le destinazioni di registro filtrare i messaggi in base alle loro categorie. Uno schema di denominazione semplice ma efficace consiste nell'utilizzare la costante magica PHP ***__METHOD__*** per i nomi delle categorie. Questo è anche l'approccio utilizzato nel codice del core Yii. Per esempio,

    Yii::trace('start calculating average revenue', __METHOD__);

La costante ***__METHOD__***  viene valutata come il nome del metodo (preceduto dal nome completo della classe) in cui appare la costante. Ad esempio, è uguale alla stringa `'app\controllers\RevenueController::calculate'` se la suddetta linea di codice è chiamata all'interno di questo metodo.


##Registrare gli obiettivi


Una destinazione del log è un'istanza della classe ***yii \ log \ Target*** o della sua classe figlio. Filtra i messaggi di registro in base ai livelli di gravità e alle categorie e quindi li esporta su un supporto. Ad esempio, una destinazione del database esporta i messaggi di log filtrati in una tabella di database, mentre una destinazione di posta elettronica esporta i messaggi di registro in indirizzi di posta elettronica specificati.

È possibile registrare più destinazioni di registro in un'applicazione configurandole tramite il componente `log` dell'applicazione nella configurazione dell'applicazione, come nell'esempio seguente:

    return [
        // the "log" component must be loaded during bootstrapping time
        'bootstrap' => ['log'],
    
        'components' => [
            'log' => [
                'targets' => [
                    [
                        'class' => 'yii\log\DbTarget',
                        'levels' => ['error', 'warning'],
                    ],
                    [
                        'class' => 'yii\log\EmailTarget',
                        'levels' => ['error'],
                        'categories' => ['yii\db\*'],
                        'message' => [
                        'from' => ['log@example.com'],
                        'to' => ['admin@example.com', 'developer@example.com'],
                        'subject' => 'Database errors at example.com',
                        ],
                    ],
                ],
            ],
        ],
    ];


!!!Warning
    Il componente `log` deve essere caricato durante il tempo in cui è attivo il componente `bootstrap`,in modo che possa inviare prontamente messaggi di log alle destinazioni. Questo è il motivo per cui è elencato nella matrice `bootstrap` come nell'esempio mostrato sopra.

Nel codice precedente, due destinazioni di registro sono registrate nella proprietà ***yii \ log \ Dispatcher :: $ target***:

- il primo target seleziona i messaggi di errore e di avviso e li salva in una tabella del database;
- il secondo target seleziona i messaggi di errore nelle categorie di cui iniziano i nomi `yii\db\` e li invia in un messaggio di posta elettronica a entrambi `admin@example.com` e `developer@example.com`.

Yii viene fornito con i seguenti obiettivi di registro incorporati.

- **yii \ log \ DbTarget**: memorizza i messaggi di log in una tabella di database.
- **yii \ log \ EmailTarget**: invia messaggi di log a indirizzi di posta elettronica pre-specificati.
- **yii \ log \ FileTarget**: salva i messaggi di log nei file.
- **yii \ log \ SyslogTarget**: salva i messaggi di log in syslog chiamando la funzione PHP `syslog()`.

Di seguito, descriveremo le caratteristiche comuni a tutti gli obiettivi di registro.


##Filtro dei messaggi


Per ciascuna destinazione del registro, è possibile configurare le proprietà dei livelli e delle categorie **yii \ log \ Target ::** per specificare i livelli di gravità e le categorie dei messaggi che l'obiettivo deve elaborare.

La proprietà **yii \ log \ Target :: levels** accettano una matrice costituita da uno o più dei seguenti valori:

- `error`: corrispondente ai messaggi registrati da **Yii :: error ()**.
- `warning`: corrispondente ai messaggi registrati da **Yii :: warning ()**.
- `info`: corrispondente ai messaggi registrati da **Yii :: info ()**.
- `trace`: corrisponde ai messaggi registrati da **Yii :: trace ()**.
- `profile`: corrispondente ai messaggi registrati da **Yii :: beginProfile ()** e **Yii :: endProfile ()** , che verranno spiegati in maggior dettaglio nella sottosezione "Profiling".

Se non si specifica la proprietà **yii \ log \ Target :: levels**, significa che la destinazione elaborerà i messaggi di qualsiasi livello di gravità.

La proprietà **categories** accetta un array costituito da nomi o pattern di categorie messaggi. Una destinazione elaborerà solo i messaggi la cui categoria può essere trovata o corrispondere a uno dei modelli in questo array. Un modello di categoria è un prefisso del nome della categoria con un asterisco `*` all'estremità. Un nome di categoria corrisponde a un modello di categoria se inizia con lo stesso prefisso del modello. Ad esempio, **yii\db\Command::execute** e **yii\db\Command::query** vengono utilizzati come nomi di categorie per i messaggi di registro registrati nella classe **yii \ db \ Command**. Entrambi corrispondono allo schema *** yii\db\* ***.

Se non si specifica la proprietà delle categorie, significa che la destinazione elaborerà i messaggi di qualsiasi categoria.

Oltre a inserire nella **whitelist** le categorie in base alla loro proprietà, è possibile aggiungere anche determinate categorie per la proprietà `except`. Se la categoria di un messaggio viene trovata o corrisponde a uno dei pattern in questa proprietà, NON verrà elaborata dalla destinazione.

La seguente configurazione specifica che la destinazione deve elaborare solo i messaggi di errore e di avvertimento nelle categorie i cui nomi corrispondono a ***yii\db\**** o *** yii\web\HttpException:* ***, ma non a quelli *** yii\web\HttpException:404 ***.

    [
        'class' => 'yii\log\FileTarget',
        'levels' => ['error', 'warning'],
        'categories' => [
            'yii\db\*',
            'yii\web\HttpException:*',
        ],
        'except' => [
            'yii\web\HttpException:404',
        ],
    ]

!!!Note
    Quando viene rilevata un'eccezione HTTP dal gestore degli errori , verrà registrato un messaggio di errore con il nome della categoria nel formato di **yii\web\HttpException:ErrorCode**. Ad esempio, **yii \ web \ NotFoundHttpException** causerà un messaggio di errore di categoria **yii\web\HttpException:404**.


##Formattazione del messaggio


Le destinazioni log esportano i messaggi di log filtrati in un determinato formato. Ad esempio, se si installa una destinazione del registro della classe **yii \ log \ FileTarget**, è possibile trovare un messaggio di registro simile al seguente nel `runtime/log/app.logfile`:

    2014-10-04 18:10:15 [::1][][-][trace][yii\base\Module::getModule] Loading module: debug

Per impostazione predefinita, i messaggi di registro verranno formattati come segue da **yii \ log \ Target :: formatMessage ()**:

    Timestamp [IP address][User ID][Session ID][Severity Level][Category] Message Text

È possibile personalizzare questo formato configurando la proprietà **yii \ log \ Target :: $** che accetta una chiamata PHP restituendo un prefisso con un messaggio personalizzato. Ad esempio, il codice seguente configura una destinazione del registro per aggiungere un prefisso a ciascun messaggio con l'ID utente corrente (l'indirizzo IP e l'ID sessione vengono rimossi per motivi di riservatezza).

    [
        'class' => 'yii\log\FileTarget',
        'prefix' => function ($message) {
            $user = Yii::$app->has('user', true) ? Yii::$app->get('user') : null;
            $userID = $user ? $user->getId(false) : '-';
            return "[$userID]";
        }
    ]

Oltre ai prefissi dei messaggi, gli obiettivi di registro aggiungono anche alcune informazioni di contesto a ciascun batch relativo ai messaggi di registro. Per impostazione predefinita, sono inclusi i valori di queste variabili PHP globali: `$_GET`, `$_POST`, `$_FILES`, `$_COOKIE`, `$_SESSION` e `$_SERVER`. È possibile modificare questo comportamento configurando la proprietà **yii \ log \ Target :: $ logVars** con i nomi delle variabili globali che si desidera includere dalla destinazione del registro. Ad esempio, la seguente configurazione di destinazione del registro specifica che solo il valore della variabile `$_SERVER` verrà aggiunta ai messaggi di registro.

    [
        'class' => 'yii\log\FileTarget',
        'logVars' => ['_SERVER'],
    ]

È possibile configurare `logVars` così che sia una matrice vuota per disabilitare completamente l'inclusione delle informazioni di contesto. Altrimenti se si desidera implementare il proprio modo di fornire informazioni di contesto, è possibile sovrascrivere il metodo **yii \ log \ Target :: getContextMessage ()**.


##Traccia dei messaggi tramite livelli


Durante lo sviluppo, è spesso preferibile vedere da dove proviene ogni messaggio di registro. Questo può essere ottenuto configurando la proprietà **yii \ log \ Dispatcher :: traceLevel** del componente `log` come la seguente:

    return [
        'bootstrap' => ['log'],
        'components' => [
            'log' => [
                'traceLevel' => YII_DEBUG ? 3 : 0,
                'targets' => [...],
            ],
        ],
    ];

La configurazione dell'applicazione sopra imposta **yii \ log \ Dispatcher :: traceLevel** può essere 3 se `YII_DEBUG` è a 0 e se `YII_DEBUG` è off. Ciò significa che, se `YII_DEBUG` è attivo, ogni messaggio di registro verrà aggiunto con almeno 3 livelli dello stack di chiamate a cui viene registrato il messaggio di registro; e se `YII_DEBUG` è disattivato,non verranno incluse le informazioni sullo stack di chiamata.


##Flushing e esportazione dei messaggi


Come già detto, i messaggi di log sono mantenuti in un array dall'oggetto `logger`. Per limitare il consumo di memoria da parte di questo array, il registratore scaricherà i messaggi registrati sugli obiettivi del registro ogni volta che l'array accumula un certo numero di messaggi di registro. È possibile personalizzare questo numero configurando la proprietà **yii \ log \ Dispatcher :: flushInterval** del componente `log`:

    return [
        'bootstrap' => ['log'],
        'components' => [
            'log' => [
                'flushInterval' => 100,   // default is 1000
                'targets' => [...],
            ],
        ],
    ];

Quando l' oggetto `logger` scarica i messaggi di log per registrare gli obiettivi , non vengono esportati immediatamente. Invece, l'esportazione del messaggio si verifica solo quando una destinazione del registro accumula un certo numero di messaggi filtrati. È possibile personalizzare questo numero configurando la proprietà **exportInterval** dei singoli target di registro , come il seguente,

    [
        'class' => 'yii\log\FileTarget',
        'exportInterval' => 100,  // default is 1000
    ]

A causa dell'impostazione del livello di scarico e di esportazione, per impostazione predefinita quando si chiama **Yii::trace()** o qualsiasi altro metodo di registrazione, NON si vedrà immediatamente il messaggio di registro nelle destinazioni del registro. Questo potrebbe essere un problema per alcune applicazioni per console di lunga durata. Per visualizzare immediatamente ciascun messaggio di registro nelle destinazioni del registro, è necessario impostare sia **yii \ log \ Dispatcher :: flushInterval** che **exportInterval** a 1, come mostrato di seguito:

    return [
        'bootstrap' => ['log'],
        'components' => [
            'log' => [
                'flushInterval' => 1,
                'targets' => [
                    [
                        'class' => 'yii\log\FileTarget',
                        'exportInterval' => 1,
                    ],
                ],
            ],
        ],
    ];

!!!Warning
    Il flusso e l'esportazione frequente di messaggi, peggiora le prestazioni dell'applicazione.


##Attivare i registri del registro


È possibile abilitare o disabilitare una destinazione del registro configurando la proprietà **yii \ log \ Target :: enabled**. Puoi farlo tramite la configurazione di destinazione del registro o la seguente istruzione PHP nel tuo codice:

    Yii::$app->log->targets['file']->enabled = false;

Il codice sopra richiede di nominare un target come `file`, come illustrato di seguito, utilizzando le chiavi stringa `targets` nell'array:

    return [
        'bootstrap' => ['log'],
        'components' => [
            'log' => [
                'targets' => [
                    'file' => [
                        'class' => 'yii\log\FileTarget',
                    ],
                    'db' => [
                        'class' => 'yii\log\DbTarget',
                    ],
                ],
            ],
        ],
    ];

Dalla versione 2.0.13, è possibile configurare **yii \ log \ Target ::** abilitato con una metodo callable per definire una condizione dinamica per l'eventuale abilitazione o meno della destinazione del registro. 


##Creazione di nuovi obiettivi


La creazione di una nuova classe di destinazione del registro è molto semplice. È principalmente necessario implementare il metodo **yii \ log \ Target :: export ()** che invia il contenuto della matrice **yii \ log \ Target :: $** a un supporto designato. È possibile chiamare il metodo **yii \ log \ Target :: formatMessage()** per formattare ciascun messaggio. 

!!!Tip
    Invece di creare i propri logger, è possibile provare qualsiasi programma di registrazione compatibile con **PSR-3** come **Monolog**,utilizzando l'estensione di destinazione del registro PSR.


##Performance profiling


Il **performance profiling** è un tipo speciale di registrazione dei messaggi che viene utilizzato per misurare il tempo impiegato da determinati blocchi di codice e individuare i colli di bottiglia delle prestazioni. Ad esempio, la classe **yii \ db \ Command** utilizza il profilo delle prestazioni per individuare il tempo impiegato da ciascuna query DB.

Per utilizzare il profilo delle prestazioni, identificare innanzitutto i blocchi di codice che devono essere profilati. Quindi racchiudi ciascun blocco di codice come segue:

    \Yii::beginProfile('myBenchmark');

    ...code block being profiled...

    \Yii::endProfile('myBenchmark');

dove `myBenchmark` sta per un token univoco che identifica un blocco di codice. Successivamente, quando si esamina il risultato del profilo, si utilizzerà questo token per individuare il tempo trascorso dal blocco di codice corrispondente.

È importante assicurarsi che le coppie di `beginProfile` e `endProfile` siano correttamente annidate. Per esempio,

    \Yii::beginProfile('block1');

        // some code to be profiled

        \Yii::beginProfile('block2');
            // some other code to be profiled
        \Yii::endProfile('block2');

    \Yii::endProfile('block1');

Se per caso ti dimentichi di inserire `\Yii::endProfile('block1')` o cambi l'ordine di `\Yii::endProfile('block1')` e `\Yii::endProfile('block2')`, il profilo delle prestazioni non funzionerà.

Per ogni blocco di codice che viene profilato, viene registrato un messaggio di registro con il livello di gravità profile. È possibile configurare un obiettivo di registro per raccogliere tali messaggi ed esportarli. Il debugger Yii ha un pannello di profilazione delle prestazioni integrato che mostra i risultati del profilo.