#Proprietà


In PHP, le variabili dei membri all'interno di una classe, sono anche chiamate "proprietà". Queste variabili fanno parte della definizione di classe e sono utilizzate per rappresentare lo stato di un'istanza di classe (ad esempio, per differenziare un'istanza della classe da un'altra). In pratica, potresti spesso voler gestire la lettura o la scrittura di proprietà in modi speciali. Ad esempio, si consiglia di tagliare sempre una stringa quando viene assegnata a una proprietà ``label``. È possibile utilizzare il codice seguente per ottenere questo compito:

    $object->label = trim($label);

Lo svantaggio del codice precedente è che dovresti chiamare `trim()` ovunque nel tuo codice, dove potresti impostare la proprietà `label`. Se, in futuro, questa proprietà ottiene un nuovo requisito, ad esempio la prima lettera deve essere in maiuscolo, sarà necessario modificare nuovamente ogni bit di codice a cui viene assegnato un valore label. La ripetizione del codice porta a bug ed è una pratica che si vuole evitare il più possibile.

Per risolvere questo problema, Yii introduce una classe base chiamata **yii \ base \ BaseObject** che supporta la definizione delle proprietà basate sui metodi delle classi getter e setter. Se una classe ha bisogno di quella funzionalità, dovrebbe estendersi da **yii \ base \ BaseObject** o da una classe figlio.

Un metodo getter è un metodo il cui nome inizia con la parola **get**; un metodo setter inizia con **set**. Il nome dopo il prefisso get o set definisce il nome di una proprietà. Ad esempio, un getter ``getLabel()`` e / o un setter ``setLabel()`` definisce una proprietà denominata label, come mostrato nel seguente codice:

    namespace app\components;

    use yii\base\BaseObject;

    class Foo extends BaseObject{

        private $_label;

        public function getLabel(){

            return $this->_label;
        }

        public function setLabel($value){

            $this->_label = trim($value);
        }
    }

Per essere chiari, i metodi getter e setter creano la proprietà label, che in questo caso si riferisce internamente a una proprietà privata denominata ``_label``.

Le proprietà definite da getter e setter possono essere utilizzate come le variabili dei membri della classe. La differenza principale è che quando tale proprietà viene letta, verrà chiamato il metodo getter corrispondente; quando alla proprietà viene assegnato un valore, verrà chiamato il metodo setter corrispondente. Per esempio:

    // equivalent to $label = $object->getLabel();
    $label = $object->label;

    // equivalent to $object->setLabel('abc');
    $object->label = 'abc';

Una proprietà definita da un getter senza setter è di sola lettura . Provare ad assegnare un valore a tale proprietà causerà un'eccezione come ``InvalidCallException``. Allo stesso modo, una proprietà definita da un setter senza un getter è solo scrivibile, e il tentativo di leggere tale proprietà causerà anche un'eccezione. Non è comune avere proprietà di sola scrittura.

Esistono diverse regole speciali per e limitazioni sulle proprietà definite dai getter e setter:

- I nomi di tali proprietà sono case-insensitive. Ad esempio, `$object->label`e `$object->Label` sono uguali. Questo perché i nomi dei metodi in PHP non fanno distinzione tra maiuscole e minuscole.
- Se il nome di tale proprietà è uguale a una variabile di una classe, quest'ultimo avrà la precedenza. Ad esempio, se la classe precedente `Foo` ha una variabile `label`, l'assegnazione `$object->label = 'abc'` interesserà la variabile membro label ; quella linea non chiamerebbe il metodo setter `setLabel()`.
- Queste proprietà non supportano la visibilità. Non fa alcuna differenza con il metodo getter o setter definitivo se la proprietà è pubblica, protetta o privata.
- Le proprietà possono essere definite solo da getter non statici e / o setter. I metodi statici non saranno trattati allo stesso modo.
- Una normale chiamata a `property_exists()` non funziona per determinare le proprietà magiche. Dovresti chiamare rispettivamente `canGetProperty()` o `canSetProperty()`.

Ritornando al problema descritto all'inizio di questa guida, invece di chiamare `trim()` ovunque, deve essere richiamato solo nel setter `setLabel()`. E se un nuovo requisito rende necessario che l'etichetta sia inizialmente in maiuscolo, il metodo `setLabel()` può essere rapidamente modificato senza toccare alcun altro codice. L'unico cambiamento riguarderà universalmente ogni incarico label.