#Risorse (Assets)


Una risorsa in Yii è un file a cui è possibile fare riferimento in una pagina Web. Può essere un file CSS, un file JavaScript, un'immagine o un file video, ecc.. Le risorse si trovano in directory accessibili dal Web e sono servite direttamente dai server Web.

Spesso è preferibile gestire le risorse a livello di programmazione. Ad esempio, quando si utilizza il widget ***yii \ jui \ DatePicker*** in una pagina, verranno automaticamente inclusi i file CSS e JavaScript richiesti, invece di chiedere di trovare manualmente questi file e includerli. E quando si aggiorna il widget a una nuova versione, verrà automaticamente utilizzata la nuova versione dei file di asset. In questo tutorial, descriveremo la potente capacità di gestione degli asset fornita da Yii.


##Definizione dei pacchetti di asset


I pacchetti di asset sono specificati come classi PHP che si estendono da ***yii \ web \ AssetBundle***. Il nome di un bundle è semplicemente il suo nome relativo alla classe PHP. una classe di asset bundle dovrebbe essere autoloadable. Solitamente specifica dove si trovano le risorse, quali file CSS e JavaScript, e ci dice anche quale pacchetto dipende da altri bundle.

Il seguente codice definisce il pacchetto di asset principale utilizzato dal progetto del modello base:

    <?php

    namespace app\assets;

    use yii\web\AssetBundle;

    class AppAsset extends AssetBundle{

        public $basePath = '@webroot';
        public $baseUrl = '@web';
        public $css = [
            'css/site.css',
            ['css/print.css', 'media' => 'print'],
        ];
        public $js = [
        ];
        public $depends = [
            'yii\web\YiiAsset',
            'yii\bootstrap\BootstrapAsset',
        ];
    }

La classe ```AppAsset``` specifica che il file di asset si trovano nella directory ```@webroot``` che corrisponde all'URL ```@web```; il pacchetto contiene un singolo file CSS ```css/site.css```. e nessun file JavaScript. Il pacchetto dipende da altri due bundle: ***yii \ base \ YiiAsset*** e ***yii \ bootstrap \ BootstrapAsset***. Una spiegazione più dettagliata della proprietà ***yii \ web \ AssetBundle*** può essere trovata nel modo seguente:

- ***sourcePath***: specifica la directory root che contiene i file di asset in questo pacchetto. Questa proprietà deve essere impostata se la directory principale non è accessibile dal Web. In caso contrario, è necessario impostare la proprietà ***basePath*** e  la proprietà ***baseurl***. Gli alias di percorso possono essere utilizzati.
- ***basePath***: specifica una directory accessibile dal Web che contiene i file di asset in questo pacchetto. Quando si specifica la proprietà ***sourcePath***, il gestore risorse pubblica le risorse di questo pacchetto in una directory accessibile dal Web, e sovrascrive di conseguenza questa proprietà. È necessario impostarla se i file delle risorse sono già in una directory accessibile dal Web e non è necessario pubblicare gli asset. Gli alias di percorso possono essere utilizzati.
- ***baseUrl***: specifica l'URL corrispondente alla directory basePath. Come basePath , se si specifica la proprietà sourcePath , il gestore risorse pubblicherà le risorse e sovrascriverà di conseguenza questa proprietà. Gli alias di percorso possono essere utilizzati.
- ***css***: specifica un array che elenca i file CSS contenuti in questo pacchetto. Si noti che solo la barra "/" deve essere utilizzata come separatore di directory. Ogni file può essere specificato da solo come stringa o in un array insieme ai tag di attributo e ai relativi valori.
- ***js***: specifica un array che elenca i file JavaScript contenuti in questo pacchetto. Il formato di questo array è lo stesso di quello del css . Ogni file JavaScript può essere specificato in uno dei seguenti due formati:
    1. un percorso relativo che rappresenta un file JavaScript locale (es js/main.js.). Il percorso effettivo del file può essere determinato anteponendo ***yii \ web \ AssetManager :: $ basePath*** al percorso relativo e l'URL effettivo del file può essere determinato anteponendo ***yii \ web \ AssetManager :: $ baseUrl*** al percorso relativo.
    2. un URL assoluto che rappresenta un file JavaScript esterno. Ad esempio ```http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js``` o ```//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js.```.

- ***depends***: specifica un array che elenca i nomi dei bundle di asset da cui dipende questo bundle (sarà spiegato nei prossimi paragrafi).
- ***jsOptions***: specifica le opzioni che verranno passate al metodo ***yii \ web \ View :: registerJsFile ()*** quando viene chiamato per registrare ogni file JavaScript in questo pacchetto.
- ***cssOptions***: specifica le opzioni che verranno passate al metodo ***yii \ web \ View :: registerCssFile ()*** quando viene chiamato per registrare ogni file CSS in questo pacchetto.
- ***publishOptions***: specifica le opzioni che verranno passate al metodo ***yii \ web \ AssetManager :: publish ()*** quando viene chiamato per pubblicare i file di risorse dall'origine in una directory Web. Viene utilizzato solo se si specifica la proprietà ***sourcePath***.


##Posizioni delle risorse


Le risorse, in base alla loro posizione, possono essere classificate come:

- ***source assets***: i file delle risorse si trovano insieme al codice sorgente PHP che non può essere direttamente accessibile via Web. Per utilizzare le source assets in una pagina, devono essere copiati in una directory Web e trasformati nelle cosiddette risorse pubbliche. Questo processo è chiamato ***asset publishing*** che verrà descritto nei paragrafi successivi.
- ***risorse pubblicate***: i file delle risorse si trovano in una directory Web e possono quindi essere accessibili direttamente via Web.
- ***risorse esterne***: i file delle risorse si trovano su un server Web diverso da quello che ospita la tua applicazione Web.

Quando si definisce una classe bundle di asset, se si specifica la proprietà ***sourcePath***, significa che tutte le risorse elencate, stanno utilizzando percorsi relativi e saranno considerate come source assets. Se non si specifica questa proprietà, significa che tali risorse sono risorse pubblicate (public assets) (è necessario specificare ***basePath*** e ***baseUrl*** per consentire a Yii di sapere dove si trovano).

Si consiglia di posizionare le risorse appartenenti a un'applicazione in una directory Web, per evitare il processo di pubblicazione di asset non necessario e non voluto. Questo è il motivo per cui ```AppAssetper``,nell'esempio precedente, gli viene specificato il ***basePath***, anziché il ***sourcePath***.

Per le estensioni, poiché le loro risorse si trovano insieme al loro codice sorgente nelle directory che non sono accessibili dal Web, è necessario specificare la proprietà ***sourcePath*** quando si definiscono le classi di pacchetti di asset relativi ad essi.

!!!Warning
    Non utilizzare il percorso di origine ```@webroot/assetscome```. Questa directory viene utilizzata come impostazione predefinita dal gestore risorse, per salvare i file di asset pubblicati dalla loro posizione di origine. Qualsiasi contenuto in questa directory, è considerato temporaneamente e potrebbe essere soggetto a rimozione.


##Dipendenze delle risorse


Quando includi più file CSS o JavaScript in una pagina Web, devono seguire un certo ordine per evitare problemi di sovrascrittura. Ad esempio, se si utilizza un widget dell'interfaccia utente jQuery in una pagina Web, è necessario assicurarsi che il file jQuery JavaScript sia incluso prima del file JavaScript dell'interfaccia jQuery. Chiamiamo questi controlli "dipendenze tra le risorse".

Le dipendenze delle risorse vengono principalmente specificate tramite la proprietà ***yii \ web \ AssetBundle :: $ depends***. Nell'esempio ```AppAsset```, il fascio di asset dipende da altri due fasci di attività:***Yii \ web \ YiiAsset*** e ***Yii \ bootstrap \ BootstrapAsset***, il che significa che i file CSS e JavaScript in ```AppAsset``` saranno incluse dopo quei file nei due pacchetti dipendenti.

Le dipendenze delle risorse sono transitive. Ciò significa che se il pacchetto A dipende da B, che dipende da C, A dipenderà anche da C.


##Opzioni degli asset


È possibile specificare le proprietà ***cssOptions*** e ***jsOptions*** per personalizzare il modo in cui i file CSS e JavaScript sono inclusi in una pagina. I valori di queste proprietà verranno passati ai metodi ***yii \ web \ View :: registerCssFile ()*** e ***yii \ web \ View :: registerJsFile ()***, quando verranno chiamati dalla view per includere file CSS e JavaScript.

!!!Note
    Le opzioni impostate in una classe di bundle di asset, si applicano a ogni file CSS / JavaScript nel pacchetto. Se si desidera utilizzare diverse opzioni per file diversi, è necessario utilizzare il formato indicato sopra o creare pacchetti di risorse separati e utilizzare un set di opzioni in ciascun pacchetto.

Ad esempio, per includere in modo condizionale un file CSS per i browser con IE9 (Internet Explorer 9) o inferiore, è possibile utilizzare la seguente opzione:

    public $cssOptions = ['condition' => 'lte IE9'];

Ciò causerà l'inclusione di un file CSS nel pacchetto utilizzando i seguenti tag HTML:

    <!--[if lte IE9]>
    <link rel="stylesheet" href="path/to/foo.css">
    <![endif]-->

Per racchiudere i tag di collegamento CSS generati all'interno di ```noscript>```, puoi configurare ```cssOptions``` come segue:

    public $cssOptions = ['noscript' => true];

Per includere un file JavaScript nella sezione head di una pagina, puoi utilizzare la seguente opzione:

    public $jsOptions = ['position' => \yii\web\View::POS_HEAD];

Per impostazione predefinita, quando un pacchetto di risorse viene pubblicato, tutti i contenuti nella directory specificata da ***yii \ web \ AssetBundle :: $ sourcePath*** verranno pubblicati. È possibile personalizzare questo comportamento configurando la proprietà ***publishOptions***. Ad esempio, per pubblicare solo una o alcune sottodirectory di ***yii \ web \ AssetBundle :: $ sourcePath***, è possibile effettuare quanto segue nella classe bundle degli asset:

    <?php
    namespace app\assets;

    use yii\web\AssetBundle;

    class FontAwesomeAsset extends AssetBundle {

        public $sourcePath = '@bower/font-awesome'; 
        public $css = [ 
            'css/font-awesome.min.css', 
        ];
        public $publishOptions = [
            'only' => [
                'fonts/',
                'css/',
            ]
        ];
    }

L'esempio precedente definisce un pacchetto di risorse per il pacchetto "fontawesome" . Specificando l'opzione di pubblicazione ```only```, verranno pubblicate solo le sottodirectory ```fonts```e ```css```.


##Utilizzo dei pacchetti di asset


Per utilizzare un pacchetto di risorse, dobbiamo registrarlo con una vista chiamando il metodo ***yii \ web \ AssetBundle :: register ()***. Ad esempio, in un modello di vista è possibile registrare un pacchetto di asset come il seguente:  

    use app\assets\AppAsset;
    AppAsset::register($this);  // $this represents the view object

!!!Tip
    Il metodo ***yii \ web \ AssetBundle :: register()*** restituisce un oggetto bundle di asset contenente le informazioni sulle risorse pubblicate, come  ***basePath*** e ***baseUrl***.

Se si sta registrando un pacchetto di risorse in altri luoghi, è necessario fornire l'oggetto di visualizzazione necessario. Ad esempio, per registrare un pacchetto di risorse in una classe widget , è possibile ottenere l'oggetto vista per ```$this->view```.

Quando un bundle di asset è registrato con una view, Yii registrerà tutti i suoi bundle di asset dipendenti. Se un pacchetto di risorse si trova in una directory inaccessibile attraverso il Web, verrà pubblicato in una directory Web. Successivamente, quando la vista esegue il rendering di una pagina, genererà tag ```<link>```e  ```<script>``` per i file CSS e JavaScript elencati nei pacchetti registrati. L'ordine di questi tag è determinato dalle dipendenze tra i bundle registrati e dall'ordine delle risorse elencate nelle proprietà ***yii \ web \ AssetBundle :: $ css*** e ***yii \ web \ AssetBundle :: $ js***.


##Bundle di asset dinamici


Essendo un normale pacchetto di risorse di classe PHP, è possibile avere alcune logiche aggiuntive ad esso correlate e può modificare dinamicamente i parametri interni. Ad esempio: è possibile utilizzare una sofisticata libreria JavaScript, che fornisce internazionalizzazione in file di origine separati: ciascuno per ciascuna lingua supportata. Quindi dovrai aggiungere un particolare file ".js" alla tua pagina per far funzionare la traduzione della libreria. Questo può essere ottenuto sovrascrivendo il metodo yii \ web \ AssetBundle :: init () :








