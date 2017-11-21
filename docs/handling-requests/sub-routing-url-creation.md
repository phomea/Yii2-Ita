#Routing e creazione degli URL


Quando un'applicazione Yii avvia l'elaborazione di una richiesta di URL, il primo passo necessario è analizzare l'URL in una ***route***. Il percorso viene quindi utilizzato per istanziare l' azione del controller corrispondente per gestire la richiesta. L'intero processo è chiamato ***routing***.

Il processo inverso di routing si chiama creazione di URL , che crea un URL da una determinata route e i parametri di query associati. Successivamente, quando viene richiesto l'URL creato, il processo di routing può risolverlo nel percorso originale e nei parametri della query associata.

Il pezzo centrale responsabile per il routing e la creazione di URL è il gestore degli URL , che è registrato come componente dell'applicazione ```urlManager```. Il gestore URL fornisce il metodo ```parseRequest()``` per analizzare una richiesta in entrata in una route e i parametri di query associati ad esso, e fornisce anche il metodo ```createUrl()``` per creare un URL da una determinata route e i relativi parametri di query associati.

Configurando il componente ```urlManager``` nella configurazione dell'applicazione, è possibile consentire all'applicazione di riconoscere i formati di URL arbitrari senza modificare il codice dell'applicazione esistente. Ad esempio, è possibile utilizzare il seguente codice per creare un URL per l'azione ```post/view```:

    use yii\helpers\Url;

    // Url::to() calls UrlManager::createUrl() to create a URL
    $url = Url::to(['post/view', 'id' => 100]);

A seconda della configurazione dell'```urlManager```, l'URL creato può apparire come uno degli esempi sottostanti. E se l'URL creato viene richiesto in seguito, verrà comunque analizzato nella route originale e nel valore del parametro di query.

    /index.php?r=post%2Fview&id=100
    /index.php/post/100
    /posts/100


##Formati degli URL


Il gestore degli URL supporta due formati:

- Il formato URL predefinito.
- Il formato URL più "grazioso".

Il formato URL predefinito utilizza un parametro di query denominato ```r``` per rappresentare la route e i normali parametri di query. Ad esempio, l'URL ```/index.php?r=post/view&id=100``` rappresenta il percorso ```post/view``` e il parametro ```id``` ha un valore di ```100```. Il formato URL predefinito non richiede alcuna configurazione del gestore URL e funziona in qualsiasi configurazione del server Web.

Il formato URL “grazioso“ utilizza il percorso aggiuntivo che segue il nome dello script della voce per rappresentare la route e i parametri di query associati. Ad esempio, il percorso aggiuntivo nell'URL ```/index.php/post/100``` è ```/post/100``` che può rappresentare il percorso ```post/view```e il parametro ```id``` che ha come valore della query ```100```con una regola URL appropriata . Per utilizzare il formato URL più grazioso, è necessario progettare un set di regole URL in base ai requisiti effettivi su come dovrebbe apparire l'URL.

È possibile passare tra i due formati di URL attivando la proprietà ```enablePrettyUrl``` del gestore URL senza modificare nessun codice nell'applicazione.


##Routing


Il routing prevede due passaggi:

- la richiesta in entrata viene analizzata in una route e i parametri di query associati;
- viene creata un'azione di controllo corrispondente al percorso analizzato per gestire la richiesta.

Quando si utilizza il formato URL predefinito, l'analisi di una richiesta in una route è semplice come ottenere il valore di un parametro GET di una query denominata ```r```.

Quando si utilizza il formato URL "grazioso", il gestore URL esaminerà le regole URL registrate per trovare quella corrispondente che possa risolvere la richiesta in una route. Se tale regola non può essere trovata, verrà generata un'eccezione ***yii \ web \ NotFoundHttpException***.

Una volta che la richiesta viene analizzata in una route, è il momento di creare l'azione del controller identificata dalla route stessa. Il percorso è suddiviso in più parti con le barre in esso contenute. Ad esempio, ```site/index``` sarà suddiviso in ```site```e ```index```. Ogni parte è un ID che può riferirsi a un modulo, a un controllore o a un'azione. A partire dalla prima parte del percorso, l'applicazione effettua le seguenti operazioni per creare i moduli (se presenti), il controller e l'azione:

1. Imposta l'applicazione come modulo corrente
2. Verificare se il "controller map" del modulo corrente contiene l'ID giusto. In tal caso, verrà creato un oggetto controller in base alla configurazione trovata nella mappa e verrà eseguito il passaggio "5" per gestire la parte restante del percorso.
3. Verifica se l'ID fa riferimento a un modulo elencato nella proprietà ***yii \ base \ Module :: modules*** del modulo corrente. In tal caso, viene creato un modulo in base alla configurazione trovata nell'elenco dei moduli e il passaggio "2" verrà utilizzato per gestire la parte successiva del percorso nel contesto del modulo appena creato.
4. Tratta l'ID come un' "ID controller" e crea un oggetto controller. Fai il prossimo passo con la parte restante del percorso.
5. Il controller cerca l'ID corrente nella sua mappa d'azione. Se trovato, crea un'azione in base alla configurazione trovata nella mappa. In caso contrario, il controller tenterà di creare un'azione in linea definita da un metodo di azione corrispondente all'ID azione corrente.

Tra i passaggi precedenti, se si verifica un errore, verrà generata un'eccezione ***yii \ web \ NotFoundHttpException***, che indica l'errore del processo di routing.


##Percorso predefinito


Quando una richiesta viene analizzata in una route vuota, verrà utilizzata la cosiddetta "route predefinita". Per impostazione predefinita, la route predefinita è ```site/index```, che si riferisce all'azione ```index``` del ***sitecontroller***. È possibile personalizzarlo configurando la proprietà ```defaultRoute``` dell'applicazione nella configurazione dell'app come la seguente:

    [
        // ...
        'defaultRoute' => 'main/index',
    ];

Simile al percorso predefinito dell'applicazione, vi è anche un percorso predefinito per i moduli, così per esempio se vi è un modulo ```user``` e la richiesta viene analizzata nella route ```user``` del modulo ***defaultroute*** è utilizzato per determinare il controller. Per impostazione predefinita, il nome del controller è ```default```. Se non si specifica un'azione ***defaultroute***, la proprietà ```DefaultAction``` del controller verrà utilizzata per determinare l'azione. In questo esempio, il percorso completo sarà ```user/default/index```.


##Itinerario ```CatchAll```


A volte, potresti voler mettere temporaneamente in pausa la tua applicazione Web e visualizzare la stessa pagina informativa per tutte le richieste. Ci sono molti modi per raggiungere questo obiettivo. Ma uno dei modi più semplici è configurare la proprietà ***yii \ web \ Application :: $ catchAll*** come segue nella configurazione dell'applicazione:

    [
        // ...
        'catchAll' => ['site/offline'],
    ];

Con la configurazione sopra indicata, l'azione ```site/offline``` verrà utilizzata per gestire tutte le richieste in arrivo.

La proprietà ```catchAll``` dovrebbe prendere una matrice,il cui primo elemento specifica una rotta, e il resto degli elementi (coppie nome-valore) specificano i parametri da associare all'azione stessa.

!!!Info
    La barra degli strumenti di debug nell'ambiente di sviluppo non funzionerà quando questa proprietà è abilitata.


##Creazione di URL


Yii fornisce un metodo di supporto ***yii \ helpers \ Url :: to()*** per creare vari tipi di URL dai percorsi specificati e i relativi parametri di query associati. Per esempio,

    use yii\helpers\Url;

    // creates a URL to a route: /index.php?r=post%2Findex
    echo Url::to(['post/index']);

    // creates a URL to a route with parameters: /index.php?r=post%2Fview&id=100
    echo Url::to(['post/view', 'id' => 100]);

    // creates an anchored URL: /index.php?r=post%2Fview&id=100#content
    echo Url::to(['post/view', 'id' => 100, '#' => 'content']);

    // creates an absolute URL: http://www.example.com/index.php?r=post%2Findex
    echo Url::to(['post/index'], true);

    // creates an absolute URL using the https scheme: https://www.example.com/index.php?r=post%2Findex
    echo Url::to(['post/index'], 'https');

Nota che nell'esempio indicato sopra, assumiamo per esempio, che venga utilizzato il formato URL predefinito. Se il formato URL "pretty"(grazioso) è abilitato, gli URL creati saranno diversi, in base alle regole URL in uso.

Il percorso passato al metodo ***yii \ helpers \ Url :: to ()*** è sensibile al contesto. Può essere una route relativa o una route assoluta, che sarà normalizzata secondo le seguenti regole:

- Se la route è una stringa vuota, verrà utilizzata la route *** yii \ web \ Controller :: *** attualmente richiesta;
- Se il percorso non contiene alcuna barra, viene considerato un ID d'azione del controller corrente e verrà anteposto al valore ***yii \ web \ Controller :: uniqueId*** del controller corrente;
- Se la route non ha una barra iniziale, viene considerata una route relativa al modulo corrente e verrà anteposta al valore ***yii \ base \ Module :: uniqueId*** del modulo corrente.

A partire dalla versione 2.0.2, è possibile specificare un percorso in termini di ```alias```. In questo caso, l'alias verrà convertito nel percorso effettivo trasformandolo in un percorso assoluto in base alle regole precedenti.

Ad esempio, supponiamo che il modulo corrente sia ```admin``` e il controller corrente sia ```post```,

    use yii\helpers\Url;

    // currently requested route: /index.php?r=admin%2Fpost%2Findex
    echo Url::to(['']);

    // a relative route with action ID only: /index.php?r=admin%2Fpost%2Findex
    echo Url::to(['index']);

    // a relative route: /index.php?r=admin%2Fpost%2Findex
    echo Url::to(['post/index']);

    // an absolute route: /index.php?r=post%2Findex
    echo Url::to(['/post/index']);

    // using an alias "@posts", which is defined as "/post/index": /index.php?r=post%2Findex
    echo Url::to(['@posts']);

Il metodo ***yii \ helpers \ Url :: to ()*** viene implementato chiamando i metodi ```createUrl()``` e ```createAbsoluteUrl()``` del gestore URL. Nelle prossime sottosezioni, spiegheremo come configurare il gestore URL per personalizzare il formato degli URL creati.

Il metodo ***yii \ helpers \ Url :: to ()*** supporta anche la creazione di URL che non sono correlati a percorsi particolari. Invece di passare un array come primo parametro, dovresti passare una stringa in questo caso. Per esempio,

    use yii\helpers\Url;

    // currently requested URL: /index.php?r=admin%2Fpost%2Findex
    echo Url::to();

    // an aliased URL: http://example.com
    Yii::setAlias('@example', 'http://example.com/');
    echo Url::to('@example');

    // an absolute URL: http://example.com/images/logo.gif
    echo Url::to('/images/logo.gif', true);

Oltre al metodo ```to()```, la classe ``helper`` ***yii \ helpers \ Url*** fornisce anche altri metodi di creazione di URL convenienti. Per esempio,

    use yii\helpers\Url;

    // home page URL: /index.php?r=site%2Findex
    echo Url::home();

    // the base URL, useful if the application is deployed in a sub-folder of the Web root
    echo Url::base();

    // the canonical URL of the currently requested URL
    // see https://en.wikipedia.org/wiki/Canonical_link_element
    echo Url::canonical();

    // remember the currently requested URL and retrieve it back in later requests
    Url::remember();
    echo Url::previous();


##Utilizziamo gli URL "graziosi" (pretty)

Per utilizzare gli URL "graziosi", dobbiamo configurare il componente ***urlManager*** nella configurazione dell'applicazione come segue:

    [
        'components' => [
            'urlManager' => [
                'enablePrettyUrl' => true,
                'showScriptName' => false,
                'enableStrictParsing' => false,
                'rules' => [
                    // ...
                ],
            ],
        ],
    ]

La proprietà ```enablePrettyUrl``` è obbligatoria in quanto attiva il formato URL grazioso. Il resto della proprietà è facoltativo. Tuttavia, la loro configurazione indicata di sopra è la più usata.

- ***showScriptName***: questa proprietà determina se lo script in entrata deve essere incluso negli URL creati. Ad esempio, invece di creare un URL ```/index.php/post/100```, impostando questa proprietà a ```false```, verrà generato un URL ```/post/100```.
- ***enableStrictParsing***: questa proprietà determina se abilitare l'analisi rigorosa delle richieste. Se l'analisi rigorosa è abilitata, l'URL richiesto in entrata deve corrispondere ad almeno una delle regole per essere trattato come una richiesta valida, altrimenti verrà generata una eccezione ***yii \ web \ NotFoundHttpException***. Se l'analisi rigorosa è disabilitata, quando nessuna delle regole corrisponde all'URL richiesto, la parte di informazioni sul percorso dell'URL verrà considerata come la route richiesta.
- ***rules***: questa proprietà contiene un elenco di regole che specificano come analizzare e creare URL. È la proprietà principale con cui dovresti lavorare per creare URL il cui formato soddisfa i tuoi particolari requisiti applicativi.

!!!Note
    Al fine di nascondere il nome dello script di entrata negli URL creati, oltre al valore ```false``` di ```showScriptName```, potrebbe anche essere necessario configurare il server Web in modo che possa identificare correttamente quale script PHP dovrebbe essere eseguito quando un URL richiesto non viene specificato.


##Regole dell'URL


Una regola associata all'URL è una classe che implementa ***yii \ web \ UrlRuleInterface***, in genere ***yii \ web \ UrlRule***. Ogni regola URL consiste in un modello utilizzato per la corrispondenza della parte di informazioni sul percorso degli URL, una route e alcuni parametri di query. Una regola URL può essere utilizzata per analizzare una richiesta,se il suo modello corrisponde all'URL richiesto. È possibile utilizzare una regola URL per creare un URL se i relativi nomi dei parametri di route e query corrispondono a quelli forniti.

Quando il formato URL pretty(grazioso) è abilitato, il gestore URL utilizza le regole dichiarate nella sua proprietà ```rules``` per analizzare le richieste in arrivo e creare l'URL. In particolare, per analizzare una richiesta in arrivo, il gestore URL esamina le regole nell'ordine dichiarate in precedenza e cerca la prima regola che corrisponde all'URL richiesto. La regola di corrispondenza viene quindi utilizzata per analizzare l'URL in una route e i relativi parametri associati. Allo stesso modo, per creare un URL, il gestore URL cerca la prima regola che corrisponde al percorso e ai parametri specificati e la utilizza per creare un URL.

È possibile configurare le regole ***yii \ web \ UrlManager :: $*** come una matrice, composta con le chiavi come modelli e i relativi percorsi. Ogni coppia "percorso-itinerario" costruisce una regola URL. Ad esempio, la seguente configurazione dichiara due regole URL. La prima regola corrisponde a un URL ```post``` se lo mappa nella route ```post/index```. La seconda regola corrisponde a un URL indicato dall'espressione ```post/(\d+)``` e lo mappa nella route ```post/view``` e nello stesso momento definisce un parametro associato all'```id```.

    'rules' => [
        'posts' => 'post/index',
        'post/<id:\d+>' => 'post/view',
    ]

Oltre a dichiarare le regole dell'URL come coppie di "pattern-route", puoi anche dichiararle come array di configurazione. Ogni array di configurazione viene utilizzato per configurare un singolo oggetto per la regola dell'URL. Questo è spesso necessario quando si desidera configurare altre proprietà di una regola URL. Per esempio,

    'rules' => [
        // ...other url rules...
        [
            'pattern' => 'posts',
            'route' => 'post/index',
            'suffix' => '.json',
        ],
    ]

Per impostazione predefinita, se non si specifica l'opzione ```class``` per una configurazione di regole, verrà utilizzata la classe predefinita ***yii \ web \ UrlRule***, che è il valore predefinito definito in ***yii \ web \ UrlManager :: $ ruleConfig***.

##Parametri nominati


Una regola URL può essere associata ai parametri di query denominati che sono specificati nel modello del formato di ``<ParamName:RegExp>``, dove ```ParamName``` specifica il nome del parametro e ```RegExp``` è un'espressione regolare facoltativa utilizzata per abbinare i valori dei parametri. Se ```RegExp``` non è specificato, significa che il valore del parametro dovrà essere una stringa senza alcuna barra.

Quando una regola viene utilizzata per analizzare un URL, riempirà i parametri associati con valori corrispondenti ai componenti che formano l'URL e questi parametri saranno resi disponibili in seguito ad un componente ```request``` che effettuerà una chiamata in ```$_GET```. Quando la regola viene utilizzata per creare un URL, prenderà i valori dei parametri forniti e li inserirà nei punti in cui sono stati dichiarati i parametri.

Illustriamo alcuni esempi per vedere come funzionano i parametri denominati. Supponiamo di aver dichiarato le seguenti tre regole URL:

    'rules' => [
        'posts/<year:\d{4}>/<category>' => 'post/index',
        'posts' => 'post/index',
        'post/<id:\d+>' => 'post/view',
    ]

Quando le regole vengono utilizzate per analizzare gli URL:

- ```/index.php/posts``` viene analizzato nel percorso ``post/index``usando la seconda regola;
- ``/index.php/posts/2014/php`` viene analizzato nel percorso `post/index`, il parametro ```year``` (il cui valore è 2014) e il parametro ```category``` (il cui valore è php) utilizzano la prima regola;
- ``/index.php/post/100`` viene analizzato nel percorso ``post/view`` e il parametro `id` (il cui valore è 100) utilizza la terza regola;
- ```/index.php/posts/php``` causerà un'eccezione ***yii \ web \ NotFoundHttpException*** quando ***yii \ web \ UrlManager :: $ enableStrictParsing*** è ``true``, perché non corrisponde a nessuno dei pattern. Se ***yii \ web \ UrlManager :: $ enableStrictParsing*** è ``false``(il valore predefinito), la parte di informazioni sul percorso ```posts/php``` verrà restituita come route. Ciò eseguirà l'azione corrispondente se esiste o non genera un'eccezione ***yii \ web \ NotFoundHttpException*** in un'altro modo.

- ```Url::to(['post/index'])```crea ```/index.php/posts``` usando la seconda regola;
- ```Url::to(['post/index', 'year' => 2014, 'category' => 'php'])``` crea ``/index.php/posts/2014/php`` usando la prima regola;
- ```Url::to(['post/view', 'id' => 100])```crea ``/index.php/post/100`` usando la terza regola;
- ```Url::to(['post/view', 'id' => 100, 'source' => 'ad'])``` crea ``/index.php/post/100?source=ad`` usando la terza regola. Poiché il parametro ``source`` non è specificato nella regola, viene aggiunto come parametro di query nell'URL creato.
- ```Url::to(['post/index', 'category' => 'php'])```crea ``/index.php/post/index?category=php`` non usando nessuna delle regole. Si noti che poiché non si applica nessuna regola, l'URL viene creato aggiungendo semplicemente il percorso come informazione sul percorso e tutti i parametri come parte della stringa di query.

##Percorsi di parametrizzazione


È possibile incorporare i nomi dei parametri nel percorso di un'URL. Ciò consente di utilizzare una regola URL per la corrispondenza di più percorsi. Ad esempio, le seguenti regole incorporano ``controller`` e  il parametro ``action``all'interno delle route.

    'rules' => [
        '<controller:(post|comment)>/create' => '<controller>/create',
        '<controller:(post|comment)>/<id:\d+>/<action:(update|delete)>' => '<controller>/<action>',
        '<controller:(post|comment)>/<id:\d+>' => '<controller>/view',
        '<controller:(post|comment)>s' => '<controller>/index',
    ]


##Valori dei parametri predefiniti


Per impostazione predefinita, sono richiesti tutti i parametri dichiarati in una regola. Se un URL richiesto non contiene un particolare parametro, o se un URL viene creato senza un particolare parametro, la regola non verrà applicata. Per rendere facoltativi alcuni parametri, è possibile configurare le proprietà dei valori predefiniti di una regola. I parametri elencati in questa proprietà sono facoltativi e prenderanno i valori specificati quando non vengono forniti.

Nella seguente dichiarazione di regole, i parametri ``page`` e ``tag`` sono entrambi opzionali e assumeranno il valore 1 e la stringa vuota, rispettivamente, quando non vengono forniti.

    'rules' => [
        // ...other rules...
        [
            'pattern' => 'posts/<page:\d+>/<tag>',
            'route' => 'post/index',
            'defaults' => ['page' => 1, 'tag' => ''],
        ],
    ]

La regola precedente può essere utilizzata per analizzare o creare uno dei seguenti URL:

- ``/index.php/posts: page``: il valore è 1, e tag è ''.
- ``/index.php/posts/2``: il valore di page è 2, e tag è ''.
- ``/index.php/posts/2/news``: il valore di page è 2, e tag è 'news'.
- ``/index.php/posts/news``: il valore di page è 1, e tag è 'news'.

Senza usare parametri opzionali, dovresti creare 4 regole per ottenere lo stesso risultato.

!!!Warning
    Se pattern contiene solo parametri e barre opzionali, il primo parametro può essere omesso solo se tutti gli altri parametri vengono omessi.


##Regole con nomi dei server


È possibile includere i nomi dei server Web negli schemi delle regole URL. Ciò è utile soprattutto quando l'applicazione deve comportarsi diversamente per i diversi nomi di server Web. Ad esempio, le seguenti regole analizzeranno l'URL ```http://admin.example.com/login``` nel percorso ``admin/user/login``e ```http://www.example.com/login``` in `site/login`.

    'rules' => [
        'http://admin.example.com/login' => 'admin/user/login',
        'http://www.example.com/login' => 'site/login',
    ]

È inoltre possibile incorporare parametri nei nomi dei server per estrarre informazioni dinamiche da essi. Ad esempio, la seguente regola analizzerà l'URL `http://en.example.com/posts` nel percorso `post/index` e nel parametro `language=en`.

    'rules' => [
        'http://<language:\w+>.example.com/posts' => 'post/index',
    ]

Dalla versione 2.0.11, è possibile utilizzare anche modelli relativi al protocollo che funzionano per entrambi `http` e `https`. La sintassi è lo stesso, ma saltando la parte `http:`, ad esempio: ``'//www.example.com/login' => 'site/login'``.


##Suffissi degli URL


Si consiglia di aggiungere suffissi agli URL per vari scopi. Ad esempio, puoi aggiungere `.html` agli URL in modo che sembrino URL per pagine HTML statiche; puoi anche aggiungere `.json`agli URL per indicare il tipo di contenuto previsto della risposta. È possibile raggiungere questo obiettivo configurando la proprietà ***yii \ web \ UrlManager :: $*** come segue nella configurazione dell'applicazione:

    [
        // ...
        'components' => [
            'urlManager' => [
                'enablePrettyUrl' => true,
                // ...
                'suffix' => '.html',
                'rules' => [
                    // ...
                ],
            ],
        ],
    ]

La configurazione sopra descritta consentirà al gestore URL di riconoscere gli URL richiesti e anche di creare URL con il suffisso di `.html`.

!!!Tip
    Puoi impostare ``/`` come suffisso URL in modo che gli URL finiscano tutti con una barra.

A volte potresti voler utilizzare diversi suffissi per URL diversi. Questo può essere ottenuto configurando la proprietà suffisso delle singole regole URL. Quando una regola URL ha questa proprietà impostata, sovrascriverà l'impostazione del suffisso a livello di gestore URL. Ad esempio, la seguente configurazione contiene una regola URL personalizzata che utilizza l'estensione `.json` come suffisso invece del suffisso `.html`.

    [
        'components' => [
            'urlManager' => [
                'enablePrettyUrl' => true,
                // ...
                'suffix' => '.html',
                'rules' => [
                    // ...
                    [
                        'pattern' => 'posts',
                        'route' => 'post/index',
                        'suffix' => '.json',
                    ],
                ],
            ],
        ],
    ]


##Metodi HTTP


Quando si implementano le API RESTful, è comunemente necessario analizzare lo stesso URL in percorsi diversi in base ai metodi HTTP utilizzati. Questo può essere facilmente ottenuto anteponendo i metodi HTTP supportati ai pattern delle regole. Se una regola supporta più metodi HTTP, conviene separare i nomi dei metodi con virgole. Ad esempio, le seguenti regole hanno lo stesso modello ``post/<id:\d+>`` con supporto del metodo HTTP diverso. Una richiesta di ``PUT post/100`` sarà analizzato in `post/update`, mentre la richiesta di ```GET post/100``` verrà analizzato in `post/view`.

    'rules' => [
        'PUT,POST post/<id:\d+>' => 'post/update',
        'DELETE post/<id:\d+>' => 'post/delete',
        'post/<id:\d+>' => 'post/view',
    ]

!!!Note
    Se una regola URL contiene metodi HTTP nel suo pattern, la regola verrà utilizzata solo per scopi di analisi a meno che `GET` sia tra i verbi specificati. Verrà saltato quando viene chiamato il gestore URL per creare URL.

!!!Tip
    Per semplificare il routing delle API RESTful, Yii fornisce una classe di regole URL speciale ***yii \ rest \ UrlRule*** che è molto efficiente e supporta alcune funzioni di fantasia come la pluralizzazione automatica degli ID controller. Per maggiori dettagli, fai riferimento alla sezione Routing nel capitolo API RESTful.


##Agigunta di regole in modo dinamico


Le regole URL possono essere aggiunte dinamicamente al gestore URL. Questo è spesso necessario per i moduli ridistribuibili che vogliono gestire le proprie regole URL. Affinché le regole aggiunte dinamicamente abbiano effetto durante il processo di routing, è necessario aggiungerle durante la fase di avvio dell'applicazione. Ciò significa che i moduli devono implementare ***yii \ base \ BootstrapInterface*** e aggiungere le regole nel metodo ``bootstrap()`` come segue:

    public function bootstrap($app){

        $app->getUrlManager()->addRules([
            // rule declarations here
        ], false);
    }

Nota che dovresti anche elencare questi moduli in ***yii \ web \ Application :: bootstrap()*** in modo che possano partecipare al processo di bootstrap.


##Creazione regole associate alle classi


Nonostante la classe di default ***yii \ web \ UrlRule*** sia abbastanza flessibile per la maggior parte dei progetti, ci sono situazioni in cui devi creare le tue classi di regole. Ad esempio, in un sito Web di un rivenditore di automobili, è possibile che si desideri supportare il formato dell'URL come `/Manufacturer/Model`, dove entrambi `Manufacturer` e `Model` devono abbinare alcuni dati memorizzati in una tabella di database. La classe di regole predefinita non funzionerà qui perché si basa su pattern dichiarati staticamente.

Possiamo creare la seguente classe di regole URL per risolvere questo problema.

    <?php

    namespace app\components;

    use yii\web\UrlRuleInterface;
    use yii\base\BaseObject;

    class CarUrlRule extends BaseObject implements UrlRuleInterface{

        public function createUrl($manager, $route, $params){

            if ($route === 'car/index') {
                if (isset($params['manufacturer'], $params['model'])) {
                    return $params['manufacturer'] . '/' . $params['model'];
                } elseif (isset($params['manufacturer'])) {
                    return $params['manufacturer'];
                }
            }
            return false; // this rule does not apply
        }

        public function parseRequest($manager, $request){

            $pathInfo = $request->getPathInfo();
            if (preg_match('%^(\w+)(/(\w+))?$%', $pathInfo, $matches)) {
                // check $matches[1] and $matches[3] to see
                // if they match a manufacturer and a model in the database.
                // If so, set $params['manufacturer'] and/or $params['model']
                // and return ['car/index', $params]
            }
            return false; // this rule does not apply
        }
    }

E usa la nuova classe di regole nella configurazione delle regole sia **yii \ web \ UrlManager :: $**:

    'rules' => [
        // ...other rules...
        [
            'class' => 'app\components\CarUrlRule',
            // ...configure other properties...
        ],
    ]


##Normalizzazione dell'URL


Dalla versione 2.0.10 l'UrlManager può essere configurato per utilizzare `UrlNormalizer` per gestire le variazioni dello stesso URL, ad esempio con e senza una barra finale. Perché tecnicamente `http://example.com/path` e `http://example.com/path/` sono URL diversi, offrire lo stesso contenuto per entrambi può degradare il ranking SEO. Normalmente il normalizzatore comprime le barre consecutive, aggiunge o rimuove le barre finali a seconda che il suffisso abbia o meno una barra finale e reindirizza alla versione normalizzata dell'URL utilizzando il reindirizzamento permanente . Il normalizzatore può essere configurato globalmente per il gestore URL o singolarmente per ogni regola: per impostazione predefinita ogni regola utilizzerà il normalizzatore dal gestore URL. È possibile impostare ***UrlRule :: $ normalizer*** su `false` per disabilitare la normalizzazione per una regola URL specifica.

Il codice sotto stante mostra una configurazione di esempio per l'UrlNormalizer:

    'urlManager' => [
        'enablePrettyUrl' => true,
        'showScriptName' => false,
        'enableStrictParsing' => true,
        'suffix' => '.html',
        'normalizer' => [
            'class' => 'yii\web\UrlNormalizer',
            // use temporary redirection instead of permanent for debugging
            'action' => UrlNormalizer::ACTION_REDIRECT_TEMPORARY,
        ],
        'rules' => [
            // ...other rules...
            [
                'pattern' => 'posts',
                'route' => 'post/index',
                'suffix' => '/',
                'normalizer' => false, // disable normalizer for this rule
            ],
            [
                'pattern' => 'tags',
                'route' => 'tag/index',
                'normalizer' => [
                    // do not collapse consecutive slashes for this rule
                    'collapseSlashes' => false,
                ],
            ],
        ],
    ]

!!!Note
    Per impostazione predefinita ***UrlManager :: $ normalizer*** è disabilitato. È necessario configurarlo in modo esplicito per abilitare la normalizzazione degli URL.


##Considerazioni sulle prestazioni


Durante lo sviluppo di un'applicazione Web complessa, è importante ottimizzare le regole degli URL in modo che sia necessario meno tempo per analizzare le richieste e creare URL.

Utilizzando route parametrizzate, è possibile ridurre il numero di regole URL, che possono migliorare significativamente le prestazioni.

Durante l'analisi o la creazione di URL, il gestore URL esamina le regole URL nell'ordine in cui sono dichiarate. Pertanto, si può prendere in considerazione la possibilità di modificare l'ordine delle regole dell'URL in modo che le regole più specifiche e / o più comunemente usate siano poste prima di quelle meno utilizzate.

Se alcune regole URL condividono lo stesso prefisso nei propri pattern o percorsi, è possibile considerare l'utilizzo di ***yii \ web \ GroupUrlRule*** in modo che possano essere esaminati in modo più efficiente dal gestore URL come gruppo. Questo è spesso il caso in cui l'applicazione è composta da moduli, ciascuno con il proprio set di regole URL con l'ID del modulo come prefisso comune.


