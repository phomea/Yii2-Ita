#Moduli  (Modules)


I moduli sono unità software autonome costituite da modelli, viste, controller e altri componenti di supporto. Gli utenti finali possono accedere ai controller di un modulo quando è installato nell'applicazione. Per questi motivi, i moduli sono spesso visti come mini-applicazioni. I moduli differiscono dalle applicazioni in quanto i moduli non possono essere distribuiti da soli e devono risiedere all'interno dell'applicazioni.


##Creazione di moduli


Un modulo è organizzato come una directory chiamata ***yii \ base \ Module :: base Path*** del modulo. All'interno della directory, ci sono sub-directory, ad esempio ```controllers```,```models```,```views```, che detengono i controller, i modelli, le viste e altro codice, proprio come in un'applicazione. L'esempio seguente mostra il contenuto all'interno di un modulo:

    forum/
        Module.php                   the module class file
        controllers/                 containing controller class files
            DefaultController.php    the default controller class file
        models/                      containing model class files
        views/                       containing controller view and layout files
            layouts/                 containing layout view files
            default/                 containing view files for DefaultController
                index.php            the index view file


##Classi del modulo


Ogni modulo dovrebbe avere una classe di modulo univoca che si estende dai ***yii \ base \ Module***. La classe dovrebbe trovarsi direttamente sotto il modulo ***yii \ base \ Module :: basePath*** e dovrebbe essere caricabile automaticamente. Quando si accede a un modulo, verrà creata una singola istanza della classe modulo corrispondente. Come le istanze dell'applicazione, le istanze del modulo vengono utilizzate per condividere dati e componenti per il codice all'interno dei moduli.

Quello che segue è un esempio di come può essere una classe di modulo:

    namespace app\modules\forum;

    class Module extends \yii\base\Module{

        public function init(){

            parent::init();

            $this->params['foo'] = 'bar';
            // ...  other initialization code ...
        }
    }

Se il metodo ```init()``` contiene molto codice che inizializza la proprietà del modulo, è possibile salvarle anche in termini di configurazione e caricarlo con il seguente codice in ```init()```:

    public function init(){

        parent::init();
        // initialize the module with the configuration loaded from config.php
        \Yii::configure($this, require __DIR__ . '/config.php');
    }

dove il file di configurazione ```config.php``` può contenere il seguente contenuto, simile a quello in una configurazione dell'applicazione.

    <?php
    return [
        'components' => [
            // list of component configurations
        ],
        'params' => [
            // list of parameters
        ],
    ];


##Controller nei moduli


Quando si creano i controller in un modulo, una convenzione consiste nel mettere le classi controller sotto il namespace ```controllers```. Ciò significa anche che i file di classe del controller devono essere inseriti nella directory ```controller``` all'interno del modulo ***yii \ base \ Module :: basePath***. Ad esempio, per creare un controller ```post``` nel modulo ```forum``` mostrato nell'ultima sottosezione, è necessario dichiarare la classe controller come segue:

    namespace app\modules\forum\controllers;

    use yii\web\Controller;

    class PostController extends Controller{

        // ...
    
    }

E' possibile personalizzare i namespace delle classi controller configurando la proprietà ***yii \ base \ Module :: $controllerNamespace***. Nel caso in cui alcuni controller si trovino al di fuori di questi namespaces, è possibile renderli accessibili configurando la proprietà ***yii \ base \ Module :: $controllerMap***, in modo simile a ciò che si fa in un'applicazione.


##Viste nei moduli


Le viste in un modulo dovrebbero essere inserite nella directory ```views``` all'interno del modulo ***yii \ base \ Module :: basePath***. Per le viste visualizzate da un controller nel modulo, devono essere inserite nella directory ```views/ControllerID```, dove ```ControllerID``` fa riferimento all'ID del controller. Ad esempio, se la classe controller è ```PostController```, la directory dpvrebbe trovarsi in ```views/post``` all'interno del modulo ***yii \ base \ Module :: basePath***.

Un modulo può specificare un layout che viene applicato alle viste visualizzate dai controller del modulo. Il layout deve essere inserito nella directory ```views/layouts``` per impostazione predefinita e è necessario configurare la proprietà ***yii \ base \ Module :: $layout*** in modo che punti al nome del layout. Se non si configura la proprietà ```layout```, verrà utilizzato il layout dell'applicazione.


##Comandi della console nei moduli


Il tuo modulo potrebbe anche dichiarare comandi, che saranno disponibili attraverso la modalità Console. Affinchè l'utilità della riga di comando visualizzi i comandi, sarà necessario modificare la proprietà ***yii \ base \ Module :: $controllerNamespace***, quando Yii viene eseguito in modalità console e puntarlo verso i namespace dei comandi.

Un modo per ottenerlo è testare il tipo di istanza dell'applicazione Yii nel metodo ```init()``` del modulo:

    public function init(){

        parent::init();
        if (Yii::$app instanceof \yii\console\Application) {
            $this->controllerNamespace = 'app\modules\forum\commands';
        }
    }

I tuoi comandi saranno quindi disponibili dalla riga di comando utilizzando il seguente percorso:

    yii <module_id>/<command>/<sub_command>


##Utilizzo dei moduli


Per utilizzare un modulo in un'applicazione, è sufficiente configurare l'applicazione elencando il modulo nella proprietà ***yii \ base \ Application :: modules*** dell'applicazione. Il seguente codice nella configurazione dell'applicazione utilizza il modulo ```forum```:

    [
        'modules' => [
            'forum' => [
                'class' => 'app\modules\forum\Module',
                // ... other configurations for the module ...
            ],
        ],
    ]

La proprietà ***yii \ base \ Application :: modules*** accetta una serie di configurazioni dei moduli. Ogni chiave dell'array rappresenta un ID modulo che identifica in modo univoco il modulo tra tutti i moduli dell'applicazione e il valore dell'array corrispondente è una configurazione per la creazione del modulo.


##Itinerari


Come riusciamo ad accedere ai controller in un'applicazione, allora stesso modo, i percorsi vengono utilizzati per indirizzare i controller in un modulo. Una rotta per un controller all'interno di un modulo deve ininziare con l'ID modulo seguito dall'ID controller e dall'ID azione. Ad esempio, se un'applicazione utilizza un modulo denominato ```forum```, la rotta ```forum/post/index``` rappresenterebbe l'azione ```index``` del ```post``` controller nel modulo. Se la route contiene solo l'ID del modulo, la proprietà ***yii \ base \ Module :: $defaultRoute***, che per impostazione predefinità sarà ```default```, determinerà quale controller/azione deve essere utilizzato. Ciò significa che un percorso ```forum``` rappresenterebbe il ```default```controller nel modulo ```forum```.


##Accesso ai moduli


All'interno di un modulo, potrebbe essere spesso necessario ottenere l'istanza della classe del modulo in modo che sia possibile accedere all'ID del modulo, ai parametri del modulo, ai componenti del modulo, ecc. E' possibile farlo utilizzando la seguente dichiarazione:

    $module = MyModuleClass::getInstance();

dove ```MyModuleClass``` si riferisce al nome della classe del modulo a cui sei interessato. Il metodo ```getIstance()``` restituirà l'istanza attualmente richiesta della classe del modulo. Se il modulo non viene richiesto, il metodo restituirà ```null```. Si noti che non si desidera creare manualmente una nuova istanza della classe modulo perchè sarà diversa da quella creata da Yii in risposta a una richiesta.

!!!Note
    Quando si sviluppa un modulo, non si deve presumente che il modulo utilizzerà un ID fisso. Questo perchè un modulo può essere associato a un ID arbitrario quando viene utilizzato in un'applicazione o in un altro modulo. Per ottenere l'ID del modulo, è necessario utilizzare l'approccio descritto in precedenza per ottenere prima l'istanza del modulo, e quindi ottenere l'ID tramite ```$module->id```.

Puoi anche accedere all'istanza di un modulo usando i seguenti approcci:

    // get the child module whose ID is "forum"
    $module = \Yii::$app->getModule('forum');

    // get the module to which the currently requested controller belongs
    $module = \Yii::$app->controller->module;

Il primo approccio è utile solo quando si conosce l'ID del modulo, mentre il secondo approccio è più utile quando si conoscono i controller richiesti.

Una volta ottenuta l'istanza del modulo, è possibile accedere ai parametri e ai componenti registrati con il modulo.
Per esempio:

    $maxPostCount = $module->params['maxPostCount'];


##Moduli di bootstrap


Alcuni moduli potrebbero essere eseguiti per ogni richiesta. Il modulo di debug è un esempio. Per fare ciò, dobbiamo elencare gli ID di tali moduli nella proprietà ***bootstrap*** dell'applicazione.

Ad esempio, la seguente configurazione dell'applicazione assicura che il modulo ```debug``` sia sempre caricato:

    [
        'bootstrap' => [
            'debug',
        ],

        'modules' => [
            'debug' => 'yii\debug\Module',
        ],
    ]


##Moduli annidati


I moduli possono essere annidati a livelli illimitati. Cioè, un modulo può contenere un altro modulo che può contenere a sua volta un altro modulo. Chiamiamo il precedente "modulo padre" mentre il secondo "modulo figlio". I moduli figli devono essere dichiarati nella proprietà ***yii \ base \ Module :: modules*** dei rispettivi moduli genitori. 

Per esempio:

    namespace app\modules\forum;

    class Module extends \yii\base\Module{

        public function init(){

            parent::init();

            $this->modules = [
                'admin' => [
                    // you should consider using a shorter namespace here!
                    'class' => 'app\modules\forum\modules\admin\Module',
                ],
            ];
        }
    }
    
Per un controller al'interno di un modulo nidificato, la sua route dovrebbe includere gli ID di tutti i suoi moduli antenati. Ad esempio, la rotta ```forum/admin/dashboard/index``` rappresenta l'azione ```index``` del controller ```dashboard``` nel modulo ```admin``` che è un modulo figlio del modulo ```forum```.

!!!Note
    il metodo ***getModule()*** restituisce solo il modulo figlio che appartiene direttamente al suo genitore. La proprietà ***yii \ base \ Application :: $loadedModules*** mantiene un elenco di moduli caricati, compresi i bambini diretti e quelli nidificati, indicizzati dai loro nomi di classe.


##Accessi ai componenti all'interno dei moduli


La versione 2.0.13 supporta l'attraversamento dell'albero. Ciò consente agli sviluppatori di fare riferimento a componenti (applicazioni) tramite il localizzatore di servizio che è il loro modulo. Ciò significa che è preferibile utilizzare ```$module->get('db')``` oltre ```Yii::$app->get('db')```. L'utente di un modulo è in grado di specificare un componente specifico da utilizzare per il modulo nel caso sia necessario un componente diverso (configurazione).

Ad esempio, considera questa configurazione dell'applicazione:

    'components' => [
        'db' => [
            'tablePrefix' => 'main_',
        ],
    ],
    'modules' => [
        'mymodule' => [
            'components' => [
                'db' => [
                    'tablePrefix' => 'module_',
                ],
            ],
        ],
    ],

Le tabelle del database dell'applicazione saranno precedute da prefisso con ```main_``` tutte le tabelle dei moduli ```module_```.

 


