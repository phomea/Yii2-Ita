#Comportamenti (Behaviors)


I comportamenti ( o Behaviors) sono istanze di **yii \ base \ Behavior** o di una classe figlio. I comportamenti, noti anche come "mixins", consentono di migliorare la funzionalità di una classe che ha componenti già esistenti, senza dover modificare l'ereditarietà della classe stessa. Il collegamento di un behaviors a un componente, "inietta" i metodi e le proprietà del comportamento stesso nel componente, rendendo accessibili tali metodi e proprietà come se fossero definiti nella classe del componente stesso. Inoltre, un comportamento può rispondere agli eventi innescati dal componente che gli consente di personalizzare la normale esecuzione del codice.


##Definizione dei comportamenti


Per definire un comportamento, dobbiamo creare una classe che estende **yii \ base \ Behavior** oppure che venga estesa da una classe figlio.

Per esempio:

    namespace app\components;

    use yii\base\Behavior;

    class MyBehavior extends Behavior{

        public $prop1;

        private $_prop2;

        public function getProp2(){

            return $this->_prop2;
        }

        public function setProp2($value){

            $this->_prop2 = $value;
        }

        public function foo(){

            // ...
        }
    }

Il codice soprastante, definisce la classe di comportamento `app\components\MyBehavior`, con due proprietà - `prop1` e `prop2` - e un metodo `foo()`. Nota che la proprietà `prop2` è definita tramite il getter `getProp2()` e il setter `setProp2()`. Questo è il caso in cui **yii \ base \ Behavior** estende **yii \ base \ BaseObject** e quindi supporta la definizione delle proprietà tramite getter e setter.

Poiché questa classe è un comportamento, quando è attaccato ad un componente, questo avrà quindi anche le proprietà `prop1` e `prop2` e il metodo `foo()`.

!!!Tip
    All'interno di un comportamento, è possibile accedere al componente a cui è collegato il comportamento tramite la proprietà **yii \ base \ Behavior :: $ owner**.

!!!Warning
    Nel caso in cui il metodo di comportamento **yii \ base \ Behavior :: __ get ()** e / o **yii \ base \ Behavior :: __ set()** sia sovrascritto, è necessario eseguire l'override di **yii \ base \ Behavior :: canGetProperty()** e / o **yii \ base \ Behavior :: canSetProperty()**.


##Gestione degli eventi nei componenti


Se un comportamento deve rispondere agli eventi innnescati dal componente a cui è collegato, dovrebbe sovrascrivere il metodo **yii \ base \ Behavior :: events()**.

Per esempio:

    namespace app\components;

    use yii\db\ActiveRecord;
    use yii\base\Behavior;

    class MyBehavior extends Behavior{

        // ...

        public function events(){

            return [
                ActiveRecord::EVENT_BEFORE_VALIDATE => 'beforeValidate',
            ];
        }

        public function beforeValidate($event){

            // ...
        }
    }

Il metodo **events()** dovrebbe restituire un elenco di eventi e i relativi gestori. L'esempio scritto sopra, dichiara che  l'evento **l'EVENT_BEFORE_VALIDATE** esiste e definisce il suo gestore, `beforeValidate()`. Quando si specifica un gestore di eventi, è possibile utilizzare uno dei seguenti formati:

- una stringa che fa riferimento al nome di un metodo della classe di un comportamento, come nell'esempio precedente.
- una matrice di un oggetto o nome di classe e un nome di un metodo come una stringa (senza parentesi), ad esempio `[$object, 'methodName']`.
- una funziona anonima.

La firma di un gestore d ieventi dovrebbe essere la seguente, dove l'evento `$event` si riferisce al parametro dell'evento stesso.

    function ($event) {
    }


##Allegare i comportamenti


E' possibile associare un comportamento a un cmoponente in modo statico o dinamico. Il primo è il più comune.

Per associare staticamente un comportamento, eseguire l'override del metodo **behaviors()** della classe del componente a cui è collegato il comportamento. Il metodo **behavior()** dovrebbe restituire un elenco di configurazioni di comportamento. Ogni configurazione di comportamento può essere un nome di classe di comportamento o un array di configurazione:

    namespace app\models;

    use yii\db\ActiveRecord;
    use app\components\MyBehavior;

    class User extends ActiveRecord{

        public function behaviors(){

            return [
                // anonymous behavior, behavior class name only
                MyBehavior::className(),

                // named behavior, behavior class name only
                'myBehavior2' => MyBehavior::className(),

                // anonymous behavior, configuration array
                [
                    'class' => MyBehavior::className(),
                    'prop1' => 'value1',
                    'prop2' => 'value2',
                ],

                // named behavior, configuration array
                'myBehavior4' => [
                    'class' => MyBehavior::className(),
                    'prop1' => 'value1',
                    'prop2' => 'value2',
                ]
            ];
        }
    }
    

È possibile associare un nome a un comportamento specificando la chiave dell'array corrispondente alla configurazione del suo comportamento. In questo caso, il comportamento è chiamato "comportamento denominato". Nell'esempio fatto sopra, ci sono due comportamenti denominati: `myBehavior2` e `myBehavior4`. Se un comportamento non è associato a un nome, viene chiamato comportamento anonimo.

Per allegare un comportamento in modo dinamico, chiamare il metodo **yii \ base \ Component :: attachBehavior()** del componente a cui viene collegato il comportamento:

    use app\components\MyBehavior;

    // attach a behavior object
    $component->attachBehavior('myBehavior1', new MyBehavior);

    // attach a behavior class
    $component->attachBehavior('myBehavior2', MyBehavior::className());

    // attach a configuration array
    $component->attachBehavior('myBehavior3', [
        'class' => MyBehavior::className(),
        'prop1' => 'value1',
        'prop2' => 'value2',
    ]);

Puoi collegare più comportamenti contemporaneamente usando il metodo **yii \ base \ Component :: attachBehaviors()**:

    $component->attachBehaviors([
        'myBehavior1' => new MyBehavior,  // a named behavior
        MyBehavior::className(),          // an anonymous behavior  
    ]);

E' inoltre possibile allegare comportamenti tramite configurazioni, come la seguente:

    [
        'as myBehavior2' => MyBehavior::className(),

        'as myBehavior3' => [
            'class' => MyBehavior::className(),
            'prop1' => 'value1',
            'prop2' => 'value2',
        ],
    ]


##Uso dei comportamenti


Per usare un comportamento, per prima cosa dobbiamo collegarlo a un componente, seguendo le istruzioni elencate sopra. Una volta che un comportamento è collegato a un componente, il suo utilizzo è immediato.

E' possibile accedere a una variabile membro "pubblica" o a una proprietà definita da un getter e / o setter del comportamento tramite il componente a cui è collegato:

    // "prop1" is a property defined in the behavior class
    echo $component->prop1;
    $component->prop1 = $value;

Puoi anche chiamare un metodo pubblico del comportamento, come segue:

    // foo() is a public method defined in the behavior class
    $component->foo();

Come puoi vedere, anche `$component` se non definisce `prop1` e `foo()`, possono essere utilizzati come se facessero parte della definizione del componente a causa del comportamento allegato.

Se due comportamenti definiscono una stessa proprietà o metodo e sono entrambi collegati alla stessa componente, il comportamento che è collegato al componente, prima prevarrà quando la proprietà o il metodo verrà effettuato l'accesso.

Un comportamento può essere associato a un nome quando è collegato a un componente. Se questo è il caso, puoi accedere all'oggetto comportamentale usando il nome:

    $behavior = $component->getBehavior('myBehavior');

Puoi anche ottenere tutti i comportamenti collegati a un determinato componente:

    $behaviors = $component->getBehaviors();

    
##Scollegare i comportamenti


Per scollegare un comportamento, dobbiamo chiamare **yii \ base \ Component :: detachBehavior ()** con il nome associato al comportamento:

    $component->detachBehavior('myBehavior1');

Puoi anche scollegare tutti i comportamenti:

    $component->detachBehaviors();


##Utilizzo di `TimestampBehavior`


Per concludere, diamo un'occhiata a **yii \ behaviors \ TimestampBehavior**. Questo comportamento supporta l'aggiornamento automatico degli attributi di timestamp relativo ad un modello di record attivo. Ogni volta che il modello viene salvato tramite il metodo `insert()`, `update()` o `save()`.

Innanzitutto, allega questo comportamento alla classe **ActiveRecord** che prevedi di utilizzare:

    namespace app\models\User;

    use yii\db\ActiveRecord;
    use yii\behaviors\TimestampBehavior;

    class User extends ActiveRecord{

        // ...

        public function behaviors(){

            return [
                [
                    'class' => TimestampBehavior::className(),
                    'attributes' => [
                        ActiveRecord::EVENT_BEFORE_INSERT => ['created_at', 'updated_at'],
                        ActiveRecord::EVENT_BEFORE_UPDATE => ['updated_at'],
                    ],
                    // if you're using datetime instead of UNIX timestamp:
                    // 'value' => new Expression('NOW()'),
                ],
            ];
        }
    }

Con questo codice in atto, se si dispone di un oggetto `User` e si tenta di salvarlo, lo si troverà `created_at` e `updated_at` verranno automaticamente riempito con il timestamp UNIX corrente:

    $user = new User;
    $user->email = 'test@example.com';
    $user->save();
    echo $user->created_at;  // shows the current timestamp

Il **TimestampBehavior** offre anche un metodo utile **touch()**, che assegnerà il timestamp corrente a un attributo specificato e lo salverà nel database:

    $user->touch('login_time');


##Altri comportamenti 


Sono disponibili diversi comportamenti interni ed esterni:

- **yii \ behaviors \ BlameableBehavior**: riempie automaticamente gli attributi specificati con l'ID utente corrente.
- **yii \ behaviors \ SluggableBehavior**: riempie automaticamente l'attributo specificato con un valore che può essere utilizzato come slug in un URL.
- **yii \ behaviors \ AttributeBehavior**: assegna automaticamente un valore specificato a uno o più attributi di un oggetto ActiveRecord quando si verificano determinati eventi.
- **yii2tech \ ar \ softdelete \ SoftDeleteBehavior** - fornisce metodi per l'eliminazione soft e il ripristino graduale di ActiveRecord, ovvero imposta flag o stato che contrassegna il record come eliminato.
- **yii2tech \ ar \ position \ PositionBehavior** - consente di gestire l'ordine dei record in un campo intero fornendo metodi di riordino.

##Confronto tra Behaviors e Traits (comportamenti e tratti)


Sebbene i Behaviors siano simili ai Traits in quanto entrambi "iniettano" le loro proprietà e i loro metodi nella classe primaria, differiscono in molti aspetti. Come spiegato di seguito, entrambi hanno pro e contro. Sono più simili ai complementi l'un l'altro piuttosto che alle alternative.


##Ragioni per usare i Behaviors


Le classi Behaviors, come le normali classi, supportano l'ereditarietà. I Traits, d'altra parte, possono essere considerati copia e incolla supportati dalla lingua. Non supportano l'ereditarietà.

I Behaviors possono essere collegati e scollegati a un componente in modo dinamico senza richiedere modifiche della classe del componente. Per utilizzare un Trait, è necessario modificare il codice della classe che lo utilizza.

I Behaviors sono configurabili mentre i Traits non lo sono.

I Behaviors possono personalizzare l'esecuzione del codice di un componente rispondendo ai suoi eventi.

Quando possono esserci conflitti di nomi tra diversi Behaviors collegati allo stesso componente, i conflitti vengono risolti automaticamente dando la precedenza al comportamento collegato al componente. I conflitti di nome causati da diversi caratteri richiedono la risoluzione manuale rinominando le proprietà oi metodi interessati.


##Ragioni per usare i Traits

I Traits sono molto più efficienti dei comportamenti in quanto i comportamenti sono oggetti che richiedono tempo e memoria.

Gli IDE sono più amichevoli ai Traits in quanto sono un costrutto di madrelingua.
