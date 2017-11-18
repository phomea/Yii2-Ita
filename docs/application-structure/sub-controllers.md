#Controllori  (Controllers)

I controllori(controller) sono parte dell'architettura MVC. Sono oggetti di classi che si estendono da ***yii \ base \ Controller*** e sono responsabili delle richieste di elaborazione e della generazione di risposte. In particolare, dopo aver assunto il controllo delle applicazioni, i controller analizzeranno i dati ricevuti dalla richieste in entrata, li passano ai modelli, iniettano i risultati dei modelli nelle viste(view) e, infine, generano risposte in uscita.


##Azioni


I controller sono composti da azioni che sono le unità più semplici che gli utenti finali possono richiederne l'esecuzione. Un controller può avere una o più azioni.
L'esempio seguente mostra un controller ```post``` con due azioni: azione di vista ( ```view```) e azione di creazione ( ```create```):

    namespace app\controllers;

    use Yii;
    use app\models\Post;
    use yii\web\Controller;
    use yii\web\NotFoundHttpException;

    class PostController extends Controller{
        public function actionView($id){
            $model = Post::findOne($id);
            if ($model === null) {
                throw new NotFoundHttpException;
            }

            return $this->render('view', [
                'model' => $model,
            ]);
        }

        public function actionCreate(){
            $model = new Post;

            if ($model->load(Yii::$app->request->post()) && $model->save()) {
                return $this->redirect(['view', 'id' => $model->id]);
            } else {
                return $this->render('create', [
                    'model' => $model,
                ]);
            }
        }
    }

Nell'azione di vista( definita dal metodo ```actionView()```),carica il modello secondo l'ID del modello richiesto. Se il modello viene caricato correttamente, lo visualizzerà utilizzando un vista denominata ```view```. Altrimenti verrà lanciata un'eccezione.

Nell'azione di creazione( definita dal metodo ```actionCreate()```), carica il modello secondo l'ID del modello richiesto. In primo luogo cerca di popolare una nuova istanza del modello utilizzando i dati di richiesta e salvarli all'interno del modello. Se entrambe le azioni avvengono con successo, reindirizzerà il browser all'azione ```view``` con l'ID del modello appena creato. Altrimenti verrà visualizzata la vista di creazione (```create```) attraverso la quale gli utenti possono fornire l'input necessario.


##Itinerari


Gli utenti finali gestiscono le azioni attraverso i percorsi. Un percorso è una stringa che consiste nelle seguenti parti:

- un modulo ID: questo esiste solo se il controller appartiene a un modulo non applicativo;
- un controller ID: una stringa che identifica in modo univoco il controller tra tutti i controller della stessa applicazione;
- un ID d'azione: una stringa che identifica in modo univoco l'azione tra tutte le azioni all'interno dello stesso controller.

I percorsi hanno il seguente formato:

    ControllerID/ActionID

oppure il seguente formato se il controller appartiene a un modulo:

    ModuleID/ControllerID/ActionID

Quindi, se un utente possa richiedere il seguente URL (http://hostname/index.php?r=site/index), verrà eseguita l'azione di ```index``` nel controller del ```site```.


##Creazione di un controller


Nelle applicazioni Web, i controller devono estendere ***yii \ web \ Controller***. Analogamente nelle applicazioni console,i controller devono estendersi da ***yii \ web \ Controller***. Il seguente codice definisce un controller ```site```.

    namespace app\controllers;

    use yii\web\Controller;

    class SiteController extends Controller{
    }

Di solito, un controllore è progettato per gestire le richieste relative a un particolare tipo di risorsa. Per questo motivo, gli ID controller sono spesso nomi che si riferiscono ai tipi delle risorse che gestiscono. Ad esempio, è possibile utilizzare ```article``` come ID di un controller che gestisce i dati dell'articolo.

Per impostazione predefinita, gli ID controller devono contenere solo questi caratteri: lettere minuscole, cifre, sottolineature, trattini e barre in avanti. Ad esempio, ```article``` e ```post-comment``` sono entrambi ID controller validi, mentre ```article?```,```PostComment```,```admin\post``` non lo sono.

Un ID controller può anche contenere un prefisso della sotto-directory. Ad esempio, ```admin/article``` sta per un controller ```article``` nella sotto-directory ```admin``` sotto lo spazio dei nomi del controller. I caratteri validi per i prefissi della sotto-directory includono: lettere maiuscole o minuscole, cifre, sottolineature, trattini, ect.


##Nome del codice dei controller


I nomi delle classi di controller possono essere derivati da un ID controller secondo la seguente procedura:

1. ruotare la prima lettera in ogni parola separata da trattini in maiuscolo. Notare che se l'ID del controller contiene barre di scorrimento, questa regola si applica solo alla parte dopo l'ultima barra dell'ID;
2. rimuovere i trattini e sostituire gli "slash" con i "backslash".
3. aggiungi il suffisso ```Controller```.
4. prendere il namespace del controller.

Di seguito sono riportati alcuni esempi, supponendo che i namespace dei controller prendano il valore predefinito ```app\controllers```:

- ```article``` diventa ```app\controllers\ArticleController```;
- ```post-comment``` diventa ```app\controllers\PostCommentController```;
- ```admin/post-comment``` diventa ```app\controllers\admin\PostCommentController```;
- ```adminPanels/post-comment``` diventa ```app\controllers\adminPanels\PostCommentController```.

Le classi del controllore devono essere ***autoloadable***. Per questo motivo, negli esempi precedenti, la classe controller ```article``` dovrebbe essere salvata dove lo pseudonimo è ```@app/controllers/ArticleController.php```; mentre il controller ```admin/post-comment``` dovrebbero essere in ```@app/controllers/admin/PostCommentController.php```.

!!!Info
    L'ultimo esempio ```admin/post-comment``` mostra come è possibile inserire un controller sotto una sotto-directory del namespace del controller. Questo è utile quando si desidera organizzare i controller in più categorie e non si desidera utilizzare i moduli.


##Mappa dei controller


E' possibile configurare la mappa del controller per superare i vincoli degli ID del controller e dei nomi di classe descritti in precedenza. Ciò è principalmente utile quando si utilizzano controllori di terze parti e non si ha il controllo sui nomi delle classi.
E' possibile configurare la mappa dei controller nella configurazione dell'applicazione.

Esempio:

    [
        'controllerMap' => [
            // declares "account" controller using a class name
            'account' => 'app\controllers\UserController',

            // declares "article" controller using a configuration array
            'article' => [
                'class' => 'app\controllers\PostController',
                'enableCsrfValidation' => false,
            ],
        ],
    ]


##Controller di default


Ogni applicazione dispone di un controller predefinito specificato tramite la proprietà ***yii \ base \ Application :: $ defaultRoute***. Quando una richiesta non specifica un percorso, verrà utilizzato il percorso specificato da questa proprietà. Per le applicazioni Web, il suo valore è ```site```, mentre per le applicazioni tramite console è ```help```.
E' possibile modificare il controller di default con la seguente configurazione dell'applicazione:

    [
        'defaultRoute' => 'main',
    ]


##Creazione delle azioni


La creazione delle azioni è semplice, come definite i cosiddetti "metodi di azione" in una classe controller. Un metodo di azione è un metodo "pubblico" il nome inizia con un ```action```. Il valore restituito da un metodo di azione rappresenta i dati di risposta che dovranno essere inviati poi all'utente finale. Il seguente codice definisce due azioni: l'azione ```index``` e l'azione ```hello-world```:

    namespace app\controllers;

    use yii\web\Controller;

    class SiteController extends Controller{

        public function actionIndex(){
        
            return $this->render('index');
        
        }
        public function actionHelloWorld(){

            return 'Hello World';
        
        }
    }



##ID dell'azione


Un'azione è spesso progettata per eseguire una particolare manipolazione di una risorsa. Per questo motivo, gli ID dell'azione sono solitamente verbi ( come per esempio ```view```, ```update```, ect..).

Per impostazione predefinita, l'ID dell'azione deve contenere solo questi caratteri: lettere minuscole,cifre,sottolineature,e trattini. Ad esempio, ```view```,```update2```, e ```comment-post``` sono tutti ID di azioni valide, mentre ```view?``` e ```Update``` non lo sono.

E' possibile creare azioni in due modi: azioni in linea e azioni autonome. Un'azione inline è definita come un metodo della classe controller, mentre un'azione autonoma è una classe che estende *** yii \ base \ Action *** o le sue classi figlio. Le azioni in linea sono più veloci e semplici da creare e sono spesso preferite se non si intende riutilizzarle. Le azioni autonome invece sono principalmente create per essere utilizzate in diversi controller o essere ridistribuite come estensioni.


##Azioni in linea (inline)



I nomi dei metodi di azione sono derivati dal proprio ID secondo la seguente procedura:
1. Ruotare la prima lettera in ogni parola dell'ID dell'azione in caso di maiuscolo.
2. Rimuovere i trattini.
3. Usare il prefisso ```action```.

Ad esempio ```index``` diventa ```actonIndex``` e ```hello-world``` diventa ```actionHelloWorld```.

!!!Warning
    I nomi dei metodi d'azione sono sensibili alla distinzione tra minuscole e maiuscole. Se si dispone di un metodo denominato ```ActionIndex```, non verrà considerato come un metodo di azione e pertanto la richiesta per l'azione ```index``` provocherà un'eccezione. Si noti inoltre che i metodi d'azione devono essere pubblici. Un metodo provato o privato ***NON*** definisce un'azione in linea.


##Azioni autonome (standalone)


Per utilizzare un'azione autonoma, devi dichiararla nella mappa d'azione prevenendo il metodo *** yii \ base \ Controller :: actions() *** nelle classi di controllo, come nel seguente esempio:

    public function actions(){
    
        return [
            // declares "error" action using a class name
            'error' => 'yii\web\ErrorAction',

            // declares "view" action using a configuration array
            'view' => [
                'class' => 'yii\web\ViewAction',
                'viewPrefix' => '',
            ],
        ];
    }

Come si può vedere, il metodo ```actions()``` dovrebbe restituire un array dove i valori sono l'ID delle azioni e il loro nome. A differenza delle azioni in linea, gli ID di azione per azioni autonome possono contenere caratteri arbitrari, a condizione che siano dichiarati nel metodo ```actions()```.

Per creare una classe di azioni autonome, è necessario estendere *** yii \ base \ Action *** o una sua classe figlia, e implementare un metodo denominato ```run()```.

    <?php
    namespace app\components;

    use yii\base\Action;

    class HelloWorldAction extends Action{

        public function run(){
    
            return "Hello World";
        }
    }


##Risultati dell'azione


Il valore restituito da un metodo di azione ( o del metodo ```run()```) è molto significativo. Questo valore può essere un oggetto di risposta che verrà inviato all'utente finale come risposta.

- Per applicazioni Web, il valore di ritorno può essere anche un dato arbitrario che verrà assegnato ai dati di *** yii \ web \ Response :: $ *** e deve essere ulteriormente convertito in una stringa che rappresenta il corpo della risposta.
- Per le applicazioni tramite console, il valore di ritorno può anche essere un intero che rappresenta lo stato di uscita dell'esecuzione del comando.

Negli esempi mostrati sopra, i risultati dell'azione sono tutte stringhe che saranno trattate come il corpo di risposta da inviare all'utente finale.
Il seguente esempio vi mostra come un'azione può reindirizzare il browser a un nuovo URL restituendo un oggetto di risposta ( perchè il metodo ***redirect()*** restituisce un oggetto in risposta).

    public function actionForward(){
    
        // redirect the user browser to http://example.com
        return $this->redirect('http://example.com');
    }


##Parametri dell'azione


I metodi di azione delle azioni in linea, dei metodi ```run()```, e per le azioni autonome possono assumere parametri, chiamati *** parametri d'azione ***. I loro valori sono ottenuti dalle richieste che vengono effettuate. Per le applicazioni Web, viene richiamato il valore di ogni parametro d'azione```$_GET``` più il nome del parametro come chiave, mentre per le applicazioni tramite console, questi parametri corrispondono agli argomenti della riga di comando.

Nell'esempio seguente, l'azione ```view``` ( azione in linea ) ha dichiarato due parametri: ```$id``` e ```$version```.

    namespace app\controllers;

    use yii\web\Controller;

    class PostController extends Controller{

        public function actionView($id, $version = null){

            // ...
        }
    }

I parametri della nostra azione saranno popolati come segue per le possibili richieste che possiamo effettuare:
- ```http://hostname/index.php?r=post/view&id=123```: il parametro ```$id``` verrà compilato con il valore ```123```, mentre ```$version``` è ancora ```null``` perchè non esiste alcun parametro di query ```version```.
- ```http://hostname/index.php?r=post/view&id=123&version=2```: I due parametri ```$id``` e ```$version``` sono riempiti con i valori di ```123``` e ```2```.
- ```http://hostname/index.php?r=post/view```: viene generata un'eccezione perchè il parametro ```$id``` richiesto non è fornito nella richiesta.
- ```http://hostname/index.php?r=post/view&id[]=123```: verrà generata anche quì un'eccezione perchè il parametro ```$id``` riceve un valore di array inaspettato, come ```['123']```.

Se desideriamo che un parametro di azione possa accettare valori come matrice,array, e necessario distinguerlo come segue:

    public function actionView(array $id, $version = null){

        // ...
    }

Ora se la richiesta fosse ```http://hostname/index.php?r=post/view&id[]=123```, il parametro ```$id``` prenderà il valore di ```['123']```. Se la richiesta fosse ```http://hostname/index.php?r=post/view&id=123``` il parametro ```$id``` riceverà ancora lo stesso valore dell'array perchè il valore scalare ```'123'``` verrà auomtaticamente trasformato in array.
Gli esempi precedenti mostrano principalmente come funzionano i parametri d'azione per le applicazioni Web.


##Azioni predefinite


Ogni controller ha un'azione predefinita specificata tramite la proprietà *** yii \ base \ Controller :: $defaultAction ***. Quando un percorso contiene solo il controller ID, significa che viene richiesta l'azione predefinita del controller specificato.
Per impostazione predefinita, questa azione è impostata come ```index```. Se si desidera modificare il valore predefinito, vi basterà sovrascrivere questa proprietà nella classe controller, come segue nell'esempio:

    namespace app\controllers;

    use yii\web\Controller;

    class SiteController extends Controller{

        public $defaultAction = 'home';

        public function actionHome(){

            return $this->render('home');
        }
    }


##Ciclo di vita del controllore


Quando si elabora una richiesta, un'applicazione creerà un controller di base al percorso richiesto. Il controllore sarà sottoposto al seguente ciclo di vita per soddisfare la richiesta:

1. Il metodo *** yii \ base \ Controller :: init() *** viene chiamato dopo che il controller viene creato e configurato.
2. Il controller crea un oggetto di azione in base all'ID dell'azione richiesta:
    - Se l'ID dell'azione non è specificato, verrà utilizzato l'ID dell'azione predefinita.
    - Se l'ID dell'azione si trova nella mappa d'azione, verrà creata un'azione autonoma.
    - Se l'ID dell'azione è il risultato corrispondente a un metodo d'azione, verrà creata una nuova azione in linea;
    - In caso contrario verrà generata un'eccezione.
3. Il controllore chiama sequenzialmente il metodo ```beforeAction()```  dell'applicazione.
    - Se una delle chiamate restituisce ```false```, il resto dei metodi ```beforeAction()``` non chiamati verranno ignorati e l'esecuzione dell'azione verrà annullata.
    - Per impostazione predefinita, ogni chiamata del metodo ```beforeAction()``` innescherà un evento ```beforeAction``` a cui è possibile associare un gestore.
4. Il controllore esegue l'azione.
    - I parametri dell'azione saranno analizzati e popolati dai dati di richiesta.
5. Il controllore chiama sequenzialmente il metodo del controller ```afterAction()```.
    - Per impostazione predefinita, ogni chiamata del metodo ```afterAction()``` innescherà un evento ```afterAction``` a cui è possibile associare un gestore.
6. L'applicazione prenderà il risultato dell'azione e lo assegnerà alla risposta.

    