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
