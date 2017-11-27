#Contenitore Dependency Injection


Un contenitore DI (dependency injection) è un oggetto che sa istanziare e configurare oggetti e tutti i loro oggetti dipendenti. Qui spiegheremo principalmente l'utilizzo del contenitore DI fornito da Yii.


##Dependency Injection


Yii fornisce la funzione contenitore DI attraverso la classe **yii \ di \ Container**. Supporta i seguenti tipi di injection di dipendenza:

- Costructor Injection;
- Method Injection;
- Setter e property injection;
- PHP callable injection;


##Costructor Injection


Il contenitore DI supporta il costructor injection con l'aiuto del tipo `hint` per i parametri del costruttore. Gli hint del tipo indicano al contenitore quali classi o interfacce dipendono quando viene utilizzato per creare un nuovo oggetto. Il contenitore proverà a ottenere le istanze delle classi o interfacce dipendenti e quindi le inserirà nel nuovo oggetto tramite il costruttore. Per esempio,

    class Foo{

        public function __construct(Bar $bar){

        }
    }

    $foo = $container->get('Foo');
    // which is equivalent to the following:
    $bar = new Bar;
    $foo = new Foo($bar);


##Method Injection


Di solito le dipendenze di una classe vengono passate al costruttore e sono disponibili all'interno della classe durante l'intero ciclo di vita. Con il Method Injection è possibile fornire una dipendenza che è necessaria solo per un singolo metodo della classe e passarla al costruttore, e potrebbe non essere possibile o potrebbe causare un sovraccarico nella maggior parte dei casi d'uso.

Un metodo di classe può essere definito come il metodo `doSomething()` nel seguente esempio:

    class MyClass extends \yii\base\Component{

        public function __construct(/*Some lightweight dependencies here*/, $config = []){

            // ...
        }

        public function doSomething($param1, \my\heavy\Dependency $something){

            // do something with $something
        }
    }

Puoi chiamare quel metodo passando un'istanza di `\my\heavy\Dependencyt` e stesso o usando **yii \ di \ Container :: invoke()** come segue:

    $obj = new MyClass(/*...*/);
    Yii::$container->invoke([$obj, 'doSomething'], ['param1' => 42]); // $something will be provided by the DI container


##Setter e Property Injection


Il setter e il property injection sono supportati attraverso le configurazioni. Quando si registra una dipendenza o quando si crea un nuovo oggetto, è possibile fornire una configurazione che verrà utilizzata dal contenitore per iniettare le dipendenze tramite i setter o le proprietà corrispondenti. Per esempio,

    use yii\base\BaseObject;

    class Foo extends BaseObject{

        public $bar;

        private $_qux;

        public function getQux(){

            return $this->_qux;
        }

        public function setQux(Qux $qux){

            $this->_qux = $qux;
        }
    }

    $container->get('Foo', [], [
        'bar' => $container->get('Bar'),
        'qux' => $container->get('Qux'),
    ]);

!!!Info
    Il metodo **yii \ di \ Container :: get()** accetta il suo terzo parametro come array di configurazione da applicare all'oggetto che si sta creando. Se la classe implementa l' interfaccia **yii \ base \ Configurable** (es. **Yii \ base \ BaseObject** ), l'array di configurazione verrà passato come ultimo parametro al costruttore della classe; in caso contrario, la configurazione verrà applicata dopo la creazione dell'oggetto.


##PHP Callable Injection


In questo caso, il contenitore utilizzerà un PHP registrato callable per creare nuove istanze di una classe. Ogni volta che viene chiamato **yii \ di \ Container :: get()**, verrà richiamato il callable corrispondente. Il callable è responsabile di risolvere le dipendenze e iniettarle in modo appropriato sugli oggetti appena creati. Per esempio,

    $container->set('Foo', function () {
        $foo = new Foo(new Bar);
        // ... other initializations ...
        return $foo;
    });

    $foo = $container->get('Foo');

Per nascondere la logica complessa per la costruzione di un nuovo oggetto, è possibile utilizzare un metodo di classe statico come callable. Per esempio,

    class FooBuilder{

        public static function build(){

            $foo = new Foo(new Bar);
            // ... other initializations ...
            return $foo;
        }
    }

    $container->set('Foo', ['app\helper\FooBuilder', 'build']);

    $foo = $container->get('Foo');

In questo modo, la persona che desidera configurare la classe `Foo` non deve più essere consapevole di come è stata creata.


##Registrazione delle dipendenze


È possibile utilizzare **yii \ di \ Container :: set()** per registrare le dipendenze. La registrazione richiede un nome di dipendenza e una definizione di dipendenza. Un nome di dipendenza può essere un nome di classe, un nome di interfaccia o un nome di alias; e una definizione di dipendenza può essere un nome di classe, un array di configurazione o un callable PHP.

    $container = new \yii\di\Container;

    // register a class name as is. This can be skipped.
    $container->set('yii\db\Connection');

    // register an interface
    // When a class depends on the interface, the corresponding class
    // will be instantiated as the dependent object
    $container->set('yii\mail\MailInterface', 'yii\swiftmailer\Mailer');

    // register an alias name. You can use $container->get('foo')
    // to create an instance of Connection
    $container->set('foo', 'yii\db\Connection');

    // register a class with configuration. The configuration
    // will be applied when the class is instantiated by get()
    $container->set('yii\db\Connection', [
        'dsn' => 'mysql:host=127.0.0.1;dbname=demo',
        'username' => 'root',
        'password' => '',
        'charset' => 'utf8',
    ]);

    // register an alias name with class configuration
    // In this case, a "class" element is required to specify the class
    $container->set('db', [
        'class' => 'yii\db\Connection',
        'dsn' => 'mysql:host=127.0.0.1;dbname=demo',
        'username' => 'root',
        'password' => '',
        'charset' => 'utf8',
    ]);

    // register a PHP callable
    // The callable will be executed each time when $container->get('db') is called
    $container->set('db', function ($container, $params, $config) {
        return new \yii\db\Connection($config);
    });

    // register a component instance
    // $container->get('pageCache') will return the same instance each time it is called
    $container->set('pageCache', new FileCache);

!!!Tip
    Se il nome di una dipendenza è uguale alla definizione di dipendenza corrispondente, non è necessario registrarlo con il contenitore DI.

Una dipendenza registrata tramite `set()` genererà un'istanza ogni volta che è necessaria la dipendenza. È possibile utilizzare **yii \ di \ Container :: setSingleton()** per registrare una dipendenza che genera solo una singola istanza:

    $container->setSingleton('yii\db\Connection', [
        'dsn' => 'mysql:host=127.0.0.1;dbname=demo',
        'username' => 'root',
        'password' => '',
        'charset' => 'utf8',
    ]);


##Risolvere le dipendenze


Dopo aver registrato le dipendenze, è possibile utilizzare il contenitore DI per creare nuovi oggetti e il contenitore risolverà automaticamente le dipendenze istanziandole e inserendole negli oggetti appena creati. La risoluzione delle dipendenze è ricorsiva, il che significa che se una dipendenza ha altre dipendenze, anche queste dipendenze verranno risolte automaticamente.

Puoi usare `get()` per creare o ottenere istanze di oggetti. Il metodo accetta un nome di dipendenza, che può essere un nome di classe, un nome di interfaccia o un nome alias. Il nome della dipendenza può essere registrato tramite `set()` o `setSingleton()`. Opzionalmente è possibile fornire un elenco di parametri del costruttore della classe e una configurazione per configurare l'oggetto appena creato.

Per esempio:

    // "db" is a previously registered alias name
    $db = $container->get('db');

    // equivalent to: $engine = new \app\components\SearchEngine($apiKey, $apiSecret, ['type' => 1]);
    $engine = $container->get('app\components\SearchEngine', [$apiKey, $apiSecret], ['type' => 1]);

Dietro la scena, il contenitore DI fa molto più lavoro rispetto alla semplice creazione di un nuovo oggetto. Il contenitore, prima ispezionerà il costruttore della classe per scoprire i nomi di classe o interfaccia dipendenti, e dopo risolverà automaticamente tali dipendenze in modo ricorsivo.

Il seguente codice mostra un esempio più sofisticato. La classe `UserLister` dipende da un oggetto che implementa l'interfaccia `UserFinderInterface`; la classe `UserFinder` implementa questa interfaccia e dipende da un oggetto `Connection`. Tutte queste dipendenze sono dichiarate tramite il suggerimento sul tipo dei parametri del costruttore della classe. Con la registrazione delle dipendenze delle proprietà, il contenitore DI è in grado di risolvere automaticamente queste dipendenze e crea una nuova istanza `UserLister` con una semplice chiamata di `get('userLister')`.

    namespace app\models;

    use yii\base\BaseObject;
    use yii\db\Connection;
    use yii\di\Container;

    interface UserFinderInterface{

        function findUser();
    }

    class UserFinder extends BaseObject implements UserFinderInterface{

        public $db;

        public function __construct(Connection $db, $config = []){

            $this->db = $db;
            parent::__construct($config);
        }

        public function findUser(){

        }
    }

    class UserLister extends BaseObject{

        public $finder;

        public function __construct(UserFinderInterface $finder, $config = []){

            $this->finder = $finder;
            parent::__construct($config);
        }
    }

    $container = new Container;
    $container->set('yii\db\Connection', [
        'dsn' => '...',
    ]);
    $container->set('app\models\UserFinderInterface', [
        'class' => 'app\models\UserFinder',
    ]);
    $container->set('userLister', 'app\models\UserLister');

    $lister = $container->get('userLister');

    // which is equivalent to:

    $db = new \yii\db\Connection(['dsn' => '...']);
    $finder = new UserFinder($db);
    $lister = new UserLister($finder);


##Uso pratico


Yii crea un contenitore DI quando si include il file `Yii.php` nell'entry script della propria applicazione. Il contenitore DI è accessibile tramite il contenitore **Yii :: $**. Quando chiamate **Yii :: createObject()**, il metodo chiamerà effettivamente il metodo `get()` del contenitore per creare un nuovo oggetto. Come sopra indicato, il contenitore DI risolverà automaticamente le dipendenze (se presenti) e le inietterà nell'oggetto ottenuto. Poiché Yii usa **Yii :: createObject()** nella maggior parte del suo codice per creare nuovi oggetti, questo significa che puoi personalizzare gli oggetti globalmente trattando con **Yii :: $ container**.

Ad esempio, personalizziamo globalmente il numero predefinito di pulsanti di impaginazione di **yii \ widgets \ LinkPager**.

    \Yii::$container->set('yii\widgets\LinkPager', ['maxButtonCount' => 5]);

Ora se si utilizza il widget in una vista con il seguente codice, la proprietà `maxButtonCount` verrà inizializzata come 5 invece del valore predefinito 10 come definito nella classe.

    echo \yii\widgets\LinkPager::widget();

E' comunque possibile sovrascrivere il valore impostato tramite il contenitore DI, tuttavia:

    echo \yii\widgets\LinkPager::widget(['maxButtonCount' => 20]);



Un altro esempio è quello di sfruttare l'injection del costruttore in modo automatico. Supponiamo che la classe del controller dipenda da altri oggetti, come un servizio di prenotazione di un hotel. È possibile dichiarare la dipendenza tramite un parametro del costruttore e lasciare che il contenitore DI lo risolva automaticamente.

    namespace app\controllers;

    use yii\web\Controller;
    use app\components\BookingInterface;

    class HotelController extends Controller{

        protected $bookingService;

        public function __construct($id, $module, BookingInterface $bookingService, $config = []){

            $this->bookingService = $bookingService;
            parent::__construct($id, $module, $config);
        }
    }

Se accedi a questo controller dal browser, vedrai un errore `BookingInterface` che non può essere istanziato. Questo perché è necessario indicare al contenitore DI come gestire questa dipendenza:

    \Yii::$container->set('app\components\BookingInterface', 'app\components\BookingService');

Ora, se si accede nuovamente al controller, `app\components\BookingService` verrà creata e iniettata un'istanza come terzo parametro per il costruttore del controllore.


##Uso pratico avanzato


Supponiamo che lavoriamo sull'applicazione API e abbiamo:

- la classe `app\components\Request` che si estende `yii\web\Request` e fornisce funzionalità aggiuntive;
- la classe `app\components\Response` che si estende `yii\web\Response` e dovrebbe avere la proprietà `format` impostata `json` sulla creazione;
- le classi `app\storage\FileStorage` e `app\storage\DocumentsReader` che implementano alcune logiche sul lavoro con i documenti che si trovano in qualche archivio di file:

    class FileStorage{

        public function __construct($root) {
            // whatever
        }
    }
  
    class DocumentsReader{

        public function __construct(FileStorage $fs) {
            // whatever
        }
    }

È possibile configurare più definizioni contemporaneamente, passando l'array di configurazione al metodo `setDefinitions()` o `setSingletons()`. Iterando sull'array di configurazione, i metodi chiameranno `set()` o `setSingleton()` rispettivamente per ciascun elemento.

Il formato dell'array di configurazione è:

- `key`: nome della classe, nome dell'interfaccia o nome di un alias. La chiave verrà passata al metodo `set()` come primo argomento `$class`.
- `value`: la definizione associata a `$class`. I valori possibili sono descritti nella documentazione `set()` per il parametro `$definition`. Sarà passato al metodo `set()` come secondo argomento `$definition`.

Ad esempio, configuriamo il nostro contenitore per seguire i requisiti sopra citati:

    $container->setDefinitions([
        'yii\web\Request' => 'app\components\Request',
        'yii\web\Response' => [
            'class' => 'app\components\Response',
            'format' => 'json'
        ],
        'app\storage\DocumentsReader' => function () {
            $fs = new app\storage\FileStorage('/var/tempfiles');
            return new app\storage\DocumentsReader($fs);
        }
    ]);

    $reader = $container->get('app\storage\DocumentsReader'); 
    // Will create DocumentReader object with its dependencies as described in the config 

!!!Tip
    Il contenitore può essere configurato in stile dichiarativo utilizzando la configurazione dell'applicazione dalla versione 2.0.11.

Tutto funziona, ma nel caso avessimo bisogno di creare una classe `DocumentWriter`, dovremmo copiare e incollare la linea che crea l'oggetto  `FileStorage`, che non è il modo più intelligente, ovviamente.

Come descritto nella sottosezione Resolving Dependencies ,`set()` e `setSingleton()` possono facoltativamente assumere i parametri del costruttore della dipendenza come terzo argomento. Per impostare i parametri del costruttore, è possibile utilizzare il seguente formato di matrice di configurazione:

- `key`: nome della classe, nome dell'interfaccia o nome di un alias. La chiave verrà passata al metodo `set()` come primo argomento `$class`.
- `value`: array di due elementi. Il primo elemento sarà passato al metodo `set()` come secondo argomento `$definition`, mentre il secondo sarà `$params`.

Modifichiamo il nostro esempio:

    $container->setDefinitions([
        'tempFileStorage' => [ // we've created an alias for convenience
            ['class' => 'app\storage\FileStorage'],
            ['/var/tempfiles'] // could be extracted from some config files
        ],
        'app\storage\DocumentsReader' => [
            ['class' => 'app\storage\DocumentsReader'],
            [Instance::of('tempFileStorage')]
        ],
        'app\storage\DocumentsWriter' => [
            ['class' => 'app\storage\DocumentsWriter'],
            [Instance::of('tempFileStorage')]
        ]
    ]);

    $reader = $container->get('app\storage\DocumentsReader); 
    // Will behave exactly the same as in the previous example.

Potresti notare la notazione `Instance::of('tempFileStorage')`. Significa che il Container fornirà implicitamente una dipendenza registrata con il nome `tempFileStorage` e la passerà come primo argomento del costruttore `app\storage\DocumentsWriter`.

Un altro passo sull'ottimizzazione della configurazione consiste nel registrare alcune dipendenze come singleton. Una dipendenza registrata tramite `set()` verrà istanziata ogni volta che è necessario. Alcune classi non cambiano lo stato durante il runtime, pertanto possono essere registrate come singleton per aumentare le prestazioni dell'applicazione.

Un buon esempio potrebbe essere la classe `app\storage\FileStorage`, che esegue alcune operazioni sul file system con una semplice API (ad esempio `$fs->read()`, `$fs->write()`). Queste operazioni non cambiano lo stato della classe interna, quindi possiamo creare la sua istanza una volta e usarla più volte.

    $container->setSingletons([
        'tempFileStorage' => [
            ['class' => 'app\storage\FileStorage'],
            ['/var/tempfiles']
        ],
    ]);

    $container->setDefinitions([
        'app\storage\DocumentsReader' => [
            ['class' => 'app\storage\DocumentsReader'],
            [Instance::of('tempFileStorage')]
        ],
        'app\storage\DocumentsWriter' => [
            ['class' => 'app\storage\DocumentsWriter'],
            [Instance::of('tempFileStorage')]
        ]
    ]);

    $reader = $container->get('app\storage\DocumentsReader');


##Quando registrare le dipendenze


Poiché le dipendenze sono necessarie quando vengono creati nuovi oggetti, la loro registrazione dovrebbe essere fatta il prima possibile. Le seguenti sono le pratiche raccomandate:

- Se sei lo sviluppatore di un'applicazione, puoi registrare le tue dipendenze usando la configurazione dell'applicazione.
- Se sei lo sviluppatore di un'estensione ridistribuibile , puoi registrare le dipendenze nella classe di avvio automatico dell'estensione.

