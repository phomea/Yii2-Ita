#Viste (views)

Le viste sono parte dell'architettura MVC. Essi sono responsabili del codice per la presentazione dei dati agli utenti finali. In un'applicazione Web, le visualizzazioni vengono generalmente create in termini di modelli di visualizzazione che sono file di script PHP contenenti principalmente codice HTML e codice PHP. Sono gestiti dalla "view application component“ che fornisce metodi comunemente utilizzati per facilitare la composizione e la visualizzazione delle view.


##Creazione di viste


Come già detto, una vista è semplicemente uno script PHP mescolato con codice HTML e PHP. Di seguito è riportata una vista che presenta un modulo di accesso. Come potete vedere, il codice PHP viene visualizzato per generare contenuto dinamico, come il titolo della pagina e il modulo, mentre il codice HTML li organizza in una pagina HTML presentabile.

    <?php
    use yii\helpers\Html;
    use yii\widgets\ActiveForm;

    /* @var $this yii\web\View */
    /* @var $form yii\widgets\ActiveForm */
    /* @var $model app\models\LoginForm */

    $this->title = 'Login';
    ?>
    <h1><?= Html::encode($this->title) ?></h1>

    <p>Please fill out the following fields to login:</p>

    <?php $form = ActiveForm::begin(); ?>
        <?= $form->field($model, 'username') ?>
        <?= $form->field($model, 'password')->passwordInput() ?>
        <?= Html::submitButton('Login') ?>  
    <?php ActiveForm::end(); ?>

All'interno di una vista, è possibile accedere a alla variabile ```$this```, che si riferisce alla gestione della struttura di visualizzazione e al rendering di questo modello di visualizzazione.

Oltre a ```this```, ci possono essere altre variabili predefinite in una vista, come ```$model``` nell'esempio precedente. 

!!!Tip
    Le variabili predefinite sono elencate in un blocco di commento all'inizio di una vista in modo che possano essere riconosciute da IDE. E' anche un buon modo per documentare le tue opinioni.


##Sicurezza


Quando si creano viste che generano pagine HTML, è importante che i dati provenienti dagli utenti finali siano controllati. Altrimenti la tua applicazione potrebbe essere soggetta agli attachi di *** scripting cross-site ***.

Per visualizzare un testo semplice, abbiamo bisogno di codificarlo come prima cosa chiamando *** yii \ helpers \ Html :: encode() ***. Ad esempio, il seguente codice codifica il nome utente prima di visualizzarlo:

    <?php
    use yii\helpers\Html;
    ?>

    <div class="username">
        <?= Html::encode($user->name) ?>
    </div>

Per visualizzare il contenuto HTML, utilizzare *** yii \ helpers \ HtmlPurifier *** per filtrare prima il contenuto. Ad esempio, il codice seguente filtra il contenuto postale prima di visualizzarlo:

    <?php
    use yii\helpers\HtmlPurifier;
    ?>

    <div class="post">
        <?= HtmlPurifier::process($post->text) ?>
    </div>


!!!Tip
    Mentre HTML Purifier fa un ottimo lavoro per rendere l'output sicuro, non è veloce. E' opportuno considerare la memorizzazione nella cache del risultato di filtraggio se la tua applicazione richiede elevate prestazioni.


##Organizzazione delle viste


Come controllers e models, ci sono convenzioni per organizzare le viste:

- Per le visualizzazioni rese da un controller, dovrebbero essere posizionate sotto la directory ```@app/views/ControllerID``` per impostazione predefinita, dove ```ControllerID``` si riferisce all'ID del controller. Ad esempio, se la classe controller è ```PostController```, la directory sarebbe ```@app/views/post```; se è ```PostCommentController```, la directory sarebbe ```app/views/post-comment```. Nel caso in cui il controller appartiene a un modulo della directory si troverebbe ```views/ControllerID``` sotto *** yii \ base \ Module :: basePath ***.
- Per le viste rese da un widget, dovrebbero essere posizionate sotto la ```WidgetPath/views``` directory per impostazione predefinita, dove si trova la directory ```WidgetPath``` contenente il file della classe widget.
- Per le visualizzazioni rese da altri oggetti, si consiglia di seguire la convenzione simile a quella relativa ai widget.

E' possibile personalizzare queste directory di visualizzazione predefinite, usando il metodo *** yii \ base \ ViewContextInterface :: getViewPath() *** dei controller o dei widget.


##Viste di rendering


E' possibile restituire visualizzazioni in controller, widget o in qualsiasi altro luogo chiamando metodi di rendering delle visualizzazioni. Questi metodi condividono una firma simile mostrata come segue.

    /**
    * @param string $view view name or file path, depending on the actual rendering method
    * @param array $params the data to be passed to the view
    * @return string rendering result
    */
    methodName($view, $params = [])


##Rendering nei controllori (controller)


All'interno dei controllori, è possibile chiamare i seguenti metodi di controllo per restituire le view:

- ***render()***: restituisce una vista denominata e gli applica un layout al risultato di rendering.
- ***renderPartial()***: restituisce una vista denominata senza alcun layout.
- ***renderAjax()***: restituisce una vista denominata senza alcun layout e ci aggiunge tutti gli script e file JS / CSS registrati. Viene di solito usato come risposta alle richieste Web di AJAX.
- ***renderFile()***: restituisce una vista specificata in termini di percorso o alias del file di visualizzazione.
- ***renderContent()***: restituisce una stringa statica incorporandola nel layout attualmente applicabile.

Per esempio:

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

            // renders a view named "view" and applies a layout to it
            return $this->render('view', [
                'model' => $model,
            ]);
        }
    }


##Rendering nei widget


Nei widget è possibile chiamare i seguneti widget per restituire le view:

- ***render()***: restituisce una vista denominata.
- ***renderFile()***: restituisce una vista specificata in termini di percorso o alias del file di visualizzazione.

Per esempio:

    namespace app\components;

    use yii\base\Widget;
    use yii\helpers\Html;

    class ListWidget extends Widget{

        public $items = [];

        public function run(){

            // renders a view named "list"
            return $this->render('list', [
                'items' => $this->items,
            ]);
        }
    }


##Rendering nelle viste (view)


E' possibile eseguire una visualizzazione in un'altra visione chiamando uno dei seguenti metodi forniti dal "view component":

- ***render()***: restituisce una vista denominata.
- ***renderAjax()***: restituisce una vista denominata e ci aggiunge tutti gli script e file JS / CSS registrati. Viene di solito usato come risposta alle richieste Web di AJAX.
- ***renderFile()***: restituisce una vista specificata in termini di percorso o alias del file di visualizzazione.

Ad esempio, il codice riportato di seguito in una visualizzazione restituisce il file di visualizzazione ```_overview.php``` nella stessa directory della view attualmente resa. Ricorda che ```$this``` si riferisce al componente stesso di view:

    <?= $this->render('_overview') ?>


##Viste denominate


Un nome di visualizzazione viene convertito nel percorso del file di viisualizzazzione corrispondente in base alle seguenti regole:

- Un nome di visualizzazione può omettere il nome dell'estensione del file. In questo caso, ```.php``` verrà utilizzato come estensione. Ad esempio, il nome della vista ```about``` corrisponde al nome del file ```about.php```.
- Se il nome della visualizzazione inizia con ```//```, il percorso del file corrispondente dovrebbe essere ```@app/views/ViewName```. Cioè, la vista viene visualizzata sotto il metodo ```viewPath()```. Ad esempio,```//site/about``` verrà convertito in ```@app/views/site/about.php```.
- Se il nome della visualizzione inizia con ```/```, il percorso del file viene formato prefigurando il nome della vista con il metodo ```viewPath()``` del modulo attualmente attivo. Se non esiste un modulo attivo, verrà utilizzato ```@app/views/ViewName```. Ad esempio, ```/user/create``` verrà convertito in ```@aap/modules/views/user/create.php``` se attualmente il modulo attivo è ```user```. Se non esiste un modulo attivo, il percorso del file di visualizzazione sarà ```@app/views/user/create.php```.
- Se la vista viene eseguita con un "context" e implementa *** yii \ base \ ViewContextInterface ***, il percorso del file di visualizzazione viene formato prefigurando il percorso di visualizzazione del context con il nome della vista. Questo principalmente si applica ai punti di vista resti all'interno di controller e widget. Ad esempio, ```about``` verrà convertito ```@app/views/site/about.php``` se il contesto è il controller ```SiteController```.
- Se una vista viene visualizzata in un'altra visualizzazione, la directory contenente l'altro file di visualizzazione sarà il prefisso al nuovo nome di visualizzazione per formare il percorso effettivo. Ad esempio, ```item``` verrà convertito in ```@app/views/site/about.php``` se viene visualizzato nella vista ```@app/views/post/index.php```.

Secondo le regole precedenti, la chiamata ```$this->render('view')``` in un controller ```app\controllers\PostController``` restituirà effettivamente il file di visualizzazione ```@app/views/post/view.php```, mentre quando richiamiamo ```$this->render('_overview')``` di quella vista restituirà il file di visualizzazione ```@app/views/post/_overview.php```.


##Accesso ai dati nelle viste


Esistono due approcci per accedere ai dati all'interno di una vista: push e pull.

Passando i dati come secondo parametro ai metodi di views, significa che si sta utilizzando l'approccio push. I dati dovrebbero essere rappresentati come una matrice di coppie nome-valore. Quando viene eseguito il rendering della view, la funzione PHP ```extract()``` viene usata quando voglia che il nostro array venga estratto e associato a variabili distinte nella nostra vista. Ad esempio, il seguente codice di rendering della vista di un controller invierà due varabili alla views ```report```: ```$foo = \ ``` e ```$bar = 2```.

    echo $this->render('report', [
        'foo' => 1,
        'bar' => 2,
    ]);

L'approccio pull permetterà di recuperare attivamente i dati dalla componente di visualizzazione o da altri oggetti accessibili nelle viste ( ad esempio ```Yii::$app```). Utilizzando il seguente codice come esempio, all'interno della vista è possibile ottenere l'oggetto controller dall'espressione ```$this->context```. Di conseguenza, è possibile accedere a qualsiasi proprietà o metodo del controller nella views di ```report```, ad esempio l'ID del controller come mostrato di seguito:

    The controller ID is: <?= $this->context->id ?>  

L'approccio push è solitamente il modo preferito perchè permette di accedere ai dati delle viste, poichè rende le visualizzazioni meno dipendenti dagli oggetti di contesto. Il suo svantaggio è che è necessario costruire manualmente l'array di dati tutto il tempo, che potrebbe diventare noioso e soggetto a errori se una vista è condivisa e resa in luoghi diversi.


##Condivisione dei dati tra le viste


Il componente di visualizzazione fornisce la proprietà ***params*** che è possibile utilizzare per condividere i dati tra le viste. 
Ad esempio, in una view ```about```, è possibile avere il seguente codice che specifica il segmento corrente dei breadcrumb.

    $this->params['breadcrumbs'][] = 'About Us';

Quando nel file di layout puoi visualizzare i breadcrumb usando i dati passati attraverso parametri:

    <?= yii\widgets\Breadcrumbs::widget([
        'links' => isset($this->params['breadcrumbs']) ? $this->params['breadcrumbs'] : [],
    ]) ?>


##Layout


I layout sono un tipo speciale di viste che rappresentano le parti comune di più viste. Ad esempio, le pagine per la maggior parte delle applicazioni Web condividono la stessa intestazione e il piè di pagina, Mentre è possibile ripetere la stessa intestazione e il piè di pagina ad ogni vista, un modo migliore è quello di farlo una volta in un layout e poi incorporarlo ad esso.


##Creazioen di un layout


I layout sono anche viste, ed essendo delle viste possono essere create come in modo molto simile. Per impostazione predefinita, i layout sono memorizzati nella directory ```@app/views/layouts```. Per i layout utilizzati all'interno di una modulo, devono essere memorizzati nella directory ```views/layouts``` sotto ```yii \ base \ Module :: basePath ```. E' possibile personalizzare la directory di layout predefinita configurando la proprietà ``` yii \ base \ Module :: layoutPath ``` dell'applicazione o dei moduli.

L'esempio seguente mostra come appare un layout. Si noti che a scopo illustrativo, abbiamo notevolmente semplificato il codice nel layout. In pratica, potresti voler aggiungere più contenuti ad esso, come "head tag", menu principale, ecc.

    <?php
    use yii\helpers\Html;

    /* @var $this yii\web\View */
    /* @var $content string */
    ?>
    <?php $this->beginPage() ?>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <?= Html::csrfMetaTags() ?>
        <title><?= Html::encode($this->title) ?></title>
        <?php $this->head() ?>
    </head>
    <body>
    <?php $this->beginBody() ?>
        <header>My Company</header>
        <?= $content ?>
        <footer>&copy; 2014 by My Company</footer>
    <?php $this->endBody() ?>
    </body>
    </html>
    <?php $this->endPage() ?>

Come puoi vedere, il layout genera i tag HTML comuni a tutte le pagine. All'interno della sezione ```<body>```, il layout richiama la variabile ```$content``` che rappresenta il risultato del rendering delle viste del contenuto e viene inserito nel layout quando viene chiamato ***yii \ base \ Controller :: render()***.

La maggior parte dei layout dovrebbe chiamare i seguenti metodi come mostrato nel codice sopra. Questi metodi attivano principalmente eventi relativi al processo di rendering in modo che gli script e i tag registrati in altri luoghi possano essere iniettati correttamente nelle posizioni in cui vengono chiamati questi metodi.

- ***beginPage()***: questo metodo dovrebbe essere chiamato all'inizio del layout. Si innesca l'evento ***l'EVENT_BEGIN_PAGE***  che indica l'inizio di una pagina.
- ***endPage()***: questo metodo dovrebbe essere chiamato alla file del layout. Si innesca l'evento ***l'EVENT_END_PAGE*** che indica la fine di una partita.
- ***head()***: questo metodo dovrebbe essere chiamato all'interno del tag ```<head>``` nella sezione di una pagina HTML. Genera un segnaposto che verrà sostituito con il codice HTML head registrato ( ad es. Tag link, meta tag) quando una pagina termina in rendering.
- ***beginBody()***: questo metodo dovrebbe essere chiamato all'inizio della sezione ```<body>```. Si innesca l'evento ***l'EVENT_BEGIN_BODY*** e genera una segnaposto che sarà sostituito dal codice HTML registrato ( ad es. Javascript()) destinato al corpo del nostro programma.
- ***endBody()***: questo metodo dovrebbe essere chiamato alla fine della sezione ```<body>```. Si innesca l'evento ***l'EVENT_END_BODY*** e genera un segnaposto che sarà sostituito dal codice HTML registrato  ( ad es. Javascript()) destinato alla posizione finale del corpo del programma.


##Accesso ai dati nei layout


All'interno di un layout, hai accesso a due variabili predefinite: ```$this``` e ```$content```, Il primo si riferisce alla componente della vista, come nelle viste normali, mentre il secondo contiene il risultato del rendering di una vista del contenuto che viene renderizzata chiamando il metodo ```render()``` nei controller.

Se si desidera accedere ad altri dati nei layout, è necessario utilizzare il metodo pull ( come descritto nella sottosezione "Accesso ai dati nella vista ). Se si desidera trasferire dati da una vista di contenuto a un layout, è possibile utilizzare il metodo descritto nella sottosezione "Viste di condivisione dati".


##Utilizzando i layout


Come descritto nella sottosezione "Rendering nei Controller, quando si esegue il rendering di una vista chiamando il metodo ***render()*** in un controller, verrà applicato un layout al risultato del rendering. Per impostazione predefinita, verrà utilizzato il layout ```@app/views/layouts/main.php```.

E' possibile utilizzare un layout diverso configurando il layout ***yii \ base \ Application :: $*** o ***yii \ base \ Controller :: $***. Il primo regola il layout utilizzato da tutti i controller, mentre il secondo sovrascrive il primo per i singoli controller. Ad esempio, il codice seguente rende il controller ```post``` da utilizzare come layout durante il rendering delle sue viste. ( url file: ```@app/views/layouts/post.php```). Altri controller, supponendo che la loro proprietà ```layout``` non sia stata modificata, utilizzeranno comunque ```@app/views/layouts/main.php``` il layout di default.

    namespace app\controllers;

    use yii\web\Controller;

    class PostController extends Controller{

        public $layout = 'post';
    
        // ...
    }

Per i controllori appartenenti a un modulo, è possibile configurare anche la proprietà di layout del modulo per utilizzare un particolare layout per questi controller.

Poichè la proprietà ```layout``` può essere configurata a diversi livelli ( controller,moduli,applicazione ), dietro la scena, Yii prende due passaggi per determinare qual è il file di layout effettivo utilizzato per un particolare controller.

Nel primo passaggio, determina il valore di layout e il modulo di contesto:

- Se la proprietà di layout del controller *** yii \ base \ Controller :: $ *** non è ```null```, è consigliabile usarlo come valore di layout e il modulo del controller come modulo del contesto.
- Se la proprietà di layout del controller *** yii \ base \ Controller :: $ *** è ```null```, conviene cercare tra tutti i moduli degli antenati ( inclusa l'applicazione stessa ) del controller e trovare il primo modulo la cui proprietà layout non è ```null```. Usa quel modulo e il suo valore di layout come modulo di contesto e valore scelto. Se tale modulo non può essere trovato, significa che non verrà applicato alcun layout.

Nella seconda fase, determina il file di layout effettivo di base al valore di layout e al modulo di contesto determinato nel primo passaggio. Il valore di layout può essere:

- un percorso alias ( es. ```@app/views/layouts/main```).
- un percorso assoluto ( es. ```/main```): il valore del layout inizia con una barra. Il file di layout effettivo verrà cercato sotto *** yii \ base \ Application :: layoutPath *** dell'applicazione che viene impostato automaticamente ```@app/views/layouts```.
- un percorso relativo (es. ```main```): il file di layout effettivo verrà cercato sotto ***yii \ base \ Module :: layoutPath*** del modulo di contesto, che per impostazione predefinita si trova nella directory ```views/layouts``` sotto *** yii \ base \ Module :: basePath ***.
- il valore booleano ```false```: non verrà applicato alcun layout.

Se il valore di layout non contiene un'estensione di file, utilizzerà quella predefinita ```.php```.


##Layout nidificati


A volte potresti voler annidare un layout in un altro. Ad esempio, in diverse sezioni di un sito Web, se si desidera utilizzare layout diversi, mentre tutti questi layout condividono lo stesso layout di base che genera la struttura generale della pagina HTML5. E' possibile raggiungere questo obiettivo chiamando il metodo ***beginContent()*** e ***endContent()*** nei layout figli come il seguente:

    <?php $this->beginContent('@app/views/layouts/base.php'); ?>

    ...child layout content here...

    <?php $this->endContent(); ?>

Come mostrato sopra, il contenuto del layout figlio deve essere racchiuso tra ***beginContent()*** e ***endContent()***. Il parametro passato a ***beginContent()*** specifica qual è il layout principale. Può essere un file di layout o un alias. 

Utilizzando l'approccio sopra, è possibile nidificare i layout in più livelli.


##Usare i blocchi


I blocchi consentono di specificare il contenuto della vista in un punto mentre lo si visualizza in un altro. Sono spesso usati insieme ai layout. Ad esempio, è possibile definire un blocco in una vista del contenuto e visualizzarlo nel layout.

I metodi si chiamano ***beginBlock()*** e ***endBlock()***. E' possibile accedere al blocco tramite ```$view->blocks[$blockID]```, dove a ```$blockID``` verrà assegnato un ID univoco al momento della sua definizione.

L'esempio seguente mostra come utilizzare i blocchi per personalizzare parti specifiche di un layout in una vista del contenuto.

Innanzitutto, in una vista del contenuto, possiamo definire uno o più blocchi ( come segue ):

    ...

    <?php $this->beginBlock('block1'); ?>

    ...content of block1...

    <?php $this->endBlock(); ?>

    ...

    <?php $this->beginBlock('block3'); ?>

    ...content of block3...

    <?php $this->endBlock(); ?>


Quindi nella vista layout possiamo visualizzare i blocchi se sono disponibili o visualizzare i contenuti predefiniti se un blocco non è definito.

    ...
    <?php if (isset($this->blocks['block1'])): ?>
        <?= $this->blocks['block1'] ?>
    <?php else: ?>
        ... default content for block1 ...
    <?php endif; ?>

    ...

    <?php if (isset($this->blocks['block2'])): ?>
        <?= $this->blocks['block2'] ?>
    <?php else: ?>
        ... default content for block2 ...
    <?php endif; ?>

    ...

    <?php if (isset($this->blocks['block3'])): ?>
        <?= $this->blocks['block3'] ?>
    <?php else: ?>
        ... default content for block3 ...
    <?php endif; ?>
    ...


##Utilizzo del "View Components"


Visualizza componenti ( o View COmponents) offre molte funzionalità relative alla vista. Mentre è possibile ottenere i componenti di visualizzazione creando singole istanze di *** yii \ base \ View *** o della relativa classe figlio, nella maggior parte dei casi si utilizzerà principalmente il componente ```view``` dell'applicazione. E' possibile configurare questo componente nella configurazione dell'applicazione come la seguente:

    [
        // ...
        'components' => [
            'view' => [
                'class' => 'app\components\View',
            ],
            // ...
        ],
    ]

i componenti View forniscono le seguenti utili funzionalità relative alla vista, ciascuna descritta in maggiori dettagli in una sezione separata:

- ***tematizzazione(theming)***: consente di sviluppare e modificare il tema per il proprio sito Web.
- ***catching dei frammenti***: consente di memorizzare nella cache un frammento all'interno di una pagina Web.
- ***gestione degli script client***: supporta la registrazione e il rendering di CSS e JavaScript.
- ***gestione dei pacchetti di asset***: supporta la registrazione e il rendering di pacchetti e di risorse.
- ***motori di template alternativi***: consente di utilizzare altri motori di template, come ***Twig***, ***Smarty***.

E' inoltre possibile utilizzare frequentamente le seguenti funzionalità secondarie ma utili durante lo sviluppo di pagine Web.


##Impostazione dei titoli delle pagine


Ogni pagina Web dovrebbe avere un titolo. Normalmente il tag del titolo viene visualizzato in un layout. Tuttavia, in pratica il titolo è spesso determinato nelle visualizzazioni del contenuto piuttosto che nei layout. Per risolvere questo problema, ***yii \ web \ View*** fornisce la proprietà ***title*** per consentire il passaggio delle informazioni sul titolo dalle viste del contenuto ai layout.

Per utilizzare questa funzione, in ciascuna vista del contenuto, è possibile impostare il titolo della pagina come segue:

    <?php
    $this->title = 'My page title';
    ?>

Quindi, nei layout, assicurati di avere il seguente codice nella sezione ```<head>```:

    <title><?= Html::encode($this->title) ?></title>


##Registrazione dei meta tag


Le pagine Web di solito hanno bisogno di generare vari meta tag richiesti da parti diverse. Come i titoli di pagina, i meta tag compaiono nella sezione ```<head>``` e di solito sono generati nei layout.

Se si desidera specificare quali metatag generati nelle viste del contenuto, è possibile chiamare ***yii \ web \ View :: registerMetaTag()*** in una vista del contenuto, come la seguente:

    <?php
    $this->registerMetaTag(['name' => 'keywords', 'content' => 'yii, framework, php']);
    ?>

Il codice sopra riportato registrerà un meta tag "keywords" con il componente di visualizzazione. Il meta tag registrato viene visualizzato dopo che il layout ha completato il rendering. Il seguente codice HTML verrà generato e inserito nel punto in cui si chiama *** yii \ web \ View :: head() *** nei layout:

    <meta name="keywords" content="yii, framework, php">

Nota che se chiami più volte *** yii \ web \ View :: registerMetaTag() ***, registrerà più meta tag, indipendentemente dal fatto che i meta tag siano uguali o meno.
Per assicurarti che ci sia solo una singola istanza di un tipo di meta tag, puoi specificare una chiave come secondo parametro quando chiami il metodo. Ad esempio, il seguente codice registra due meta tag "description".
Tuttavia, verrà reso solo il secondo.

    $this->registerMetaTag(['name' => 'description', 'content' => 'This is my cool website made with Yii!'], 'description');
    $this->registerMetaTag(['name' => 'description', 'content' => 'This website is about funny raccoons.'], 'description');


##Registrazione dei tag nei collegamenti


Come i meta tag, i tag di collegamento sono utili in molti casi, come personalizzare le favicon, puntare al feed RSS. Puoi lavorare con tag di collegamento in modo simile ai meta tag usando *** yii \ web \ View :: registerLinkTag() ***. Ad esempio, in una vista del contenuto, puoi registrare un tag link come segue:

    $this->registerLinkTag([
        'title' => 'Live News for Yii',
        'rel' => 'alternate',
        'type' => 'application/rss+xml',
        'href' => 'http://www.yiiframework.com/rss.xml/',
    ]);

Il codice precedente comporterà

    <link title="Live News for Yii" rel="alternate" type="application/rss+xml" href="http://www.yiiframework.com/rss.xml/">

Simile al metodo ***registerMetaTag()***, è possibile specificare una chiave quando si chiama ***registerLinkTag()*** per evitare di generare tag di collegamento ripetuti.


##Visualizzazione degli eventi


I componenti di visualizzazione attivano numerosi eventi durante il processo di visualizzazione della vista. E' possibile rispondere a questi eventi per iniettare il contenuto di viste o elaborare i risultati del rendering prima che vengano inviati agli utenti finali.

-***EVENT_BEFORE_RENDER***: attivato dall'inizio del rendering di un file in un controller. I gestori di questo evento possono impostare ***yii \ base \ ViewEvent :: $isValid*** ad essere ```false``` per annullare il processo di rendering. 
- ***EVENT_AFTER_RENDER***: attivato dopo il rendering di un file tramite la chiamata del metodo ***yii \ base \ View :: afterRender()***. I gestori di questo evento possono ottenere il risultato del rendering tramite l'output ***yii \ base \ ViewEvent :: $*** e possono modificare questa proprietà per modificare il risultato del rendering.
- ***EVENT_BEGIN_PAGE***: attivato dalla chiamata del metodo ***yii \ base \ View :: beginPage()*** nei layout.
- ***EVENT_END_PAGE***: attivato dalla chiamata del metodo ***yii \ base \ View :: endPage()*** nei layout.
- ***EVENT_BEGIN_BODY***: attivato dalla chiamata del metodo ***yii \ base \ View :: beginBody()*** nei layout.
- ***EVENT_END_BODY***: attivato dalla chiamata del metodo ***yii \ base \ View :: endBody()*** nei layout. 

Ad esempio, il codice seguente applica la data corrente alla fine del corpo della pagina:

    \Yii::$app->view->on(View::EVENT_END_BODY, function () {
        echo date('Y-m-d');
    });


##Rendering di pagine statiche


Le pagine statiche si riferiscono a quelle pagine Web il cui contenuto principale è per lo più statico senza la necessità di accedere ai dati dinamici trasferiti dai controller.

E' possibile generare pagine statiche inserendo il proprio codice nella vista e quindi utilizzando il codice come segue in un controller:

    public function actionAbout(){

        return $this->render('about');
    
    }

Se un sito Web contiene molte pagine statiche, sarebbe molto noioso ripetere il codice simile molte volte. Per risolvere questo problema, è possibile introdurre un'azione autonoma denominata *** yii \ base \ ViewAction *** in un controller. Per esempio:

    namespace app\controllers;

    use yii\web\Controller;

    class SiteController extends Controller{

        public function actions(){

            return [
                'page' => [
                    'class' => 'yii\web\ViewAction',
                ],
            ];
        }
    }

Ora se crei una vista ```about``` sotto la directory ```@app/views/site/pages```, sarai in grado di visualizzare questa vista con il seguente URL:

    http://localhost/index.php?r=site%2Fpage&view=about

Il parametro ```view``` passato in modo ```GET``` dice al metodo ***yii \ web \ ViewAction*** quale vista è richiesta. L'azione cercherà quindi questa vista sotto la directory ```@app/views/site/pages```. E' possibile configurare ***yii \ web \ ViewAction :: $viewPrefix*** per modificare la directory per la ricerca di queste viste.


