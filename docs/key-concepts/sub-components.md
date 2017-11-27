#Componenti


I componenti sono gli elementi principali delle applicazioni Yii. I componenti sono istanze di ***yii \ base \ Componente*** o una classe estesa. Le tre funzionalità principali che i componenti forniscono ad altre classi sono:

- Proprietà,
- Eventi,
- Comportamenti.

Separatamente e combinate, queste caratteristiche rendono le classi Yii molto più personalizzabili e più facili da usare. Ad esempio, il widget per la selezione della data (un componente dell'interfaccia utente),  può essere utilizzato in una vista per generare un selettore di date interattivo:

    use yii\jui\DatePicker;

    echo DatePicker::widget([
        'language' => 'ru',
        'name'  => 'country',
        'clientOptions' => [
            'dateFormat' => 'yy-mm-dd',
        ],
    ]);

Le proprietà del widget sono facilmente scrivibili perché la classe estende **yii \ base \ Component**.

Sebbene i componenti siano molto potenti, sono un po 'più pesanti degli oggetti normali, poiché richiedono in particolare memoria e tempo di CPU aggiuntivi per supportare le funzionalità di eventi e comportamenti. Se i tuoi componenti non hanno bisogno di queste due funzionalità, potresti prendere in considerazione l'estensione della classe del componente da ***yii \ base \ BaseObject*** anziché ***yii \ base \ Component***. In questo modo i tuoi componenti saranno efficienti come normali oggetti PHP, ma con un supporto aggiuntivo per le proprietà.

Quando estendi la tua classe da **yii \ base \ Component** o **yii \ base \ BaseObject**, ti consigliamo di seguire queste convenzioni:

- Se si esegue l'override del costruttore, ci conviene specificare un parametro ``$config`` come ultimo parametro del costruttore e quindi passarlo al costruttore genitore.
- Chiamare sempre il costruttore genitore alla fine del tuo costruttore override.
- Se si esegue l'override del metodo **yii \ base \ BaseObject :: init ()**, assicurarsi di chiamare l'implementazione genitore ``init()`` all'inizio del metodo ``init()``.

Per esempio:

    <?php

    namespace yii\components\MyClass;

    use yii\base\BaseObject;

    class MyClass extends BaseObject{

        public $prop1;
        public $prop2;

        public function __construct($param1, $param2, $config = []){

            // ... initialization before configuration is applied

            parent::__construct($config);
        }

        public function init(){

            parent::init();

            // ... initialization after configuration is applied
        }
    }

Seguendo queste linee guida, i tuoi componenti saranno configurabili al momento della loro creazione. Per esempio:

    $component = new MyClass(1, 2, ['prop1' => 3, 'prop2' => 4]);
    // alternatively
    $component = \Yii::createObject([
        'class' => MyClass::className(),
        'prop1' => 3,
        'prop2' => 4,
    ], [1, 2]);

!!!Info
    Mentre l'approccio per chiamare **Yii :: createObject()** sembra complicato, non è così.Questo metodo è più potente perché è implementato su un contenitore di dipendenze.

La classe **yii \ base \ BaseObject** impone il seguente ciclo di vita dell'oggetto:

1. Pre-inizializzazione all'interno del costruttore. È possibile impostare i valori delle proprietà di default qui.
2. Configurazione dell'oggetto tramite l'attributo ``$config``. La configurazione può sovrascrivere i valori predefiniti impostati all'interno del costruttore.
3. Post-inizializzazione all'interno del metodo ``init()``. È possibile sovrascrivere questo metodo per eseguire controlli di integrità e normalizzazione delle proprietà.
4. Chiamare il metodo relativo all'oggetto utilizzato.

I primi tre passaggi avvengono tutti all'interno del costruttore dell'oggetto. Ciò significa che una volta ottenuta un'istanza di classe (cioè un oggetto), quell'oggetto è già stato inizializzato in uno stato corretto e affidabile.





















