#Eventi


Gli eventi consentono di inserire codice personalizzato nel codice esistente in determinati punti di esecuzione. È possibile associare un codice personalizzato a un evento in modo che quando viene attivato l'evento, il codice venga eseguito automaticamente. Ad esempio, un oggetto **mailer** può attivare un evento `messageSent` quando invia correttamente un messaggio. Se si desidera tenere traccia dei messaggi inviati correttamente, è possibile semplicemente allegare il codice di monitoraggio all'evento `messageSent`.

Yii introduce una classe base chiamata **yii \ base \ Component** per supportare gli eventi. Se una classe ha bisogno di attivare eventi, dovrebbe estendersi da **yii \ base \ Component** o da una classe figlio.


##Gestore degli eventi


Un gestore di eventi è un **callback PHP** che viene eseguito quando viene attivato l'evento a cui è collegato. È possibile utilizzare uno dei seguenti callback:

- una funzione PHP globale specificata come una stringa (senza parentesi), ad esempio ``'trim'``;
- un metodo oggetto specificato come matrice di un oggetto e un nome di metodo come una stringa (senza parentesi), ad esempio ``[$object, 'methodName']``;
- un metodo di classe statica specificato come matrice di un nome di classe e un nome di metodo come una stringa (senza parentesi), ad esempio ``['ClassName', 'methodName']``;
- una funzione anonima, ad es ``function ($event) { ... }``.

La firma di un gestore di eventi è:

    function ($event) {
        // $event is an object of yii\base\Event or a child class
    }

Attraverso il paraemtro ``$event``, un gestore di eventi può ottenere le seguenti informazioni sull'evento che si è verificato:

- nome dell'evento;
- mittente dell'evento: l'oggetto che chiama il metodo ``trigger()``;
- dati personalizzati: i dati che vengono forniti quando si collega il gestore degli eventi (spiegato in seguito).


##Associazione tra gestori di eventi


È possibile associare un gestore a un evento chiamando il metodo **yii \ base \ Component :: on ()**. Per esempio:

    $foo = new Foo;

    // this handler is a global function
    $foo->on(Foo::EVENT_HELLO, 'function_name');

    // this handler is an object method
    $foo->on(Foo::EVENT_HELLO, [$object, 'methodName']);

    // this handler is a static class method
    $foo->on(Foo::EVENT_HELLO, ['app\components\Bar', 'methodName']);

    // this handler is an anonymous function
    $foo->on(Foo::EVENT_HELLO, function ($event) {
        // event handling logic
    });

È inoltre possibile associare gestori di eventi tramite configurazioni.

Quando si allega un gestore di eventi, è possibile fornire dati aggiuntivi come un terzo parametro per **yii \ base \ Component :: on()**. I dati saranno resi disponibili al gestore quando l'evento viene attivato e il gestore viene chiamato. Per esempio:

    // The following code will display "abc" when the event is triggered
    // because $event->data contains the data passed as the 3rd argument to "on"
    $foo->on(Foo::EVENT_HELLO, 'function_name', 'abc');

    function function_name($event) {
        echo $event->data;
    }


##Ordine del gestore di eventi


Puoi associare uno o più gestori a un singolo evento. Quando viene attivato un evento, i gestori collegati verranno richiamati nell'ordine in cui sono stati associati all'evento. Se un gestore deve interrompere l'invocazione dei gestori che lo seguono, può impostare la proprietà manipolata **yii \ base \ Event :: $** del parametro ``$event`` con il valore  `true`:

    $foo->on(Foo::EVENT_HELLO, function ($event) {
        $event->handled = true;
    });

Per impostazione predefinita, un gestore appena collegato viene aggiunto alla coda del gestore esistente per l'evento. Di conseguenza, il gestore verrà chiamato all'ultimo posto quando viene attivato l'evento. Per inserire il nuovo gestore all'inizio della coda del gestore in modo che il gestore venga chiamato per primo, puoi chiamare **yii \ base \ Component :: on()**, passando il valore `false` per il quarto parametro `$append`:

    $foo->on(Foo::EVENT_HELLO, function ($event) {
        // ...
    }, $data, false);


##Eventi Triggering


Gli eventi Triggering vengono attivati ​​chiamando il metodo **yii \ base \ Component :: trigger()**. Il metodo richiede un nome evento e facoltativamente un oggetto evento che descrive i parametri da passare ai gestori eventi. Per esempio:

    namespace app\components;

    use yii\base\Component;
    use yii\base\Event;

    class Foo extends Component{

        const EVENT_HELLO = 'hello';

        public function bar(){

            $this->trigger(self::EVENT_HELLO);
        }
    }

Con il codice precedente, tutte le chiamate a `bar()` faranno scattare un evento chiamato **hello**.

!!!Tip
    Si consiglia di utilizzare le costanti di classe per rappresentare i nomi degli eventi. Nell'esempio sopra, la costante ***EVENT_HELLO*** rappresenta l'evento `hello`. Questo approccio ha tre vantaggi. In primo luogo, impedisce errori di battitura. In secondo luogo, può rendere gli eventi riconoscibili per il supporto di completamento automatico IDE. Terzo, puoi dire quali eventi sono supportati in una classe semplicemente controllando le sue dichiarazioni costanti.

A volte, quando si attiva un evento, è possibile passare informazioni aggiuntive ai gestori di eventi. Ad esempio, un mailer potrebbe voler passare le informazioni del messaggio ai gestori dell'evento `messageSent` in modo che possano conoscere i dettagli dei messaggi inviati. Per fare ciò, è possibile fornire un oggetto evento come secondo parametro al metodo **yii \ base \ Component :: trigger()**. L'oggetto evento deve essere un'istanza della classe **yii \ base \ Event** o di una classe figlio. Per esempio:

    namespace app\components;

    use yii\base\Component;
    use yii\base\Event;

    class MessageEvent extends Event{

        public $message;
    }

    class Mailer extends Component{

        const EVENT_MESSAGE_SENT = 'messageSent';

        public function send($message){

            // ...sending $message...

            $event = new MessageEvent;
            $event->message = $message;
            $this->trigger(self::EVENT_MESSAGE_SENT, $event);
        }
    }

Quando viene chiamato il metodo **yii \ base \ Component :: trigger()**, chiamerà tutti i gestori collegati all'evento denominato.


##Scollegare i gestori degli eventi


Per scollegare un gestore da un evento, chiamare il metodo **yii \ base \ Component :: off()**. Per esempio:

    // the handler is a global function
    $foo->off(Foo::EVENT_HELLO, 'function_name');

    // the handler is an object method
    $foo->off(Foo::EVENT_HELLO, [$object, 'methodName']);

    // the handler is a static class method
    $foo->off(Foo::EVENT_HELLO, ['app\components\Bar', 'methodName']);

    // the handler is an anonymous function
    $foo->off(Foo::EVENT_HELLO, $anonymousFunction);

Si noti che in generale non si dovrebbe provare a staccare una funzione anonima a meno che non la si memorizzi da qualche parte quando è collegata all'evento. Nell'esempio sopra, si presume che la funzione anonima sia memorizzata come variabile `$anonymousFunction`.

Per rimuovere tutti i gestori da un evento, è sufficiente chiamare **yii \ base \ Component :: off()** senza il secondo parametro:

    $foo->off(Foo::EVENT_HELLO);


##Gestori di eventi al livello di una classe


Le sottosezioni sopra descritte descrivono come allegare un gestore a un evento a livello di un'istanza. A volte, potresti voler rispondere a un evento attivato da ogni istanza di una classe anziché solo da un'istanza specifica. Invece di collegare un gestore di eventi a ogni istanza, è possibile associare il gestore a livello di classe chiamando il metodo statico **yii \ base \ Event :: on ()**.

Ad esempio, un oggetto **ActiveRecord** attiverà un evento **EVENT_AFTER_INSERT** ogni volta che inserisce un nuovo record nel database. Per tenere traccia degli inserimenti effettuati da ogni oggetto Active Record, è possibile utilizzare il seguente codice:

    use Yii;
    use yii\base\Event;
    use yii\db\ActiveRecord;

    Event::on(ActiveRecord::className(), ActiveRecord::EVENT_AFTER_INSERT, function ($event) {
        Yii::trace(get_class($event->sender) . ' is inserted');
    });

Il gestore eventi verrà richiamato ogni volta che un'istanza di ActiveRecord (o una delle sue classi secondarie) attiva l' evento **EVENT_AFTER_INSERT**. Nel gestore, puoi ottenere l'oggetto che ha attivato l'evento ``$event->sender``.

Quando un oggetto attiva un evento, chiamerà prima i gestori a livello di istanza, seguiti dai gestori a livello di classe.

È possibile attivare un evento a livello di classe chiamando il metodo statico **yii \ base \ Event :: trigger()**. Un evento a livello di classe non è associato a un particolare oggetto. Di conseguenza, causerà solo l'invocazione di gestori di eventi a livello di classe. Per esempio:

    use yii\base\Event;

    Event::on(Foo::className(), Foo::EVENT_HELLO, function ($event) {
        var_dump($event->sender);  // displays "null"
    });

    Event::trigger(Foo::className(), Foo::EVENT_HELLO);

Nota che, in questo caso, l'`$event->sender` è posto a `null` all'interno dell'istanza dell'oggetto stesso.

!!!Warning
    Poiché un gestore a livello di classe risponderà a un evento attivato da qualsiasi istanza di quella classe, o qualsiasi classe figlia, dovresti usarlo attentamente, specialmente se la classe è una classe base di basso livello, come **yii \ base \ BaseObject**.

Per scollegare un gestore di eventi a livello di classe, chiamare **yii \ base \ Event :: off ()**. Per esempio:

    // detach $handler
    Event::off(Foo::className(), Foo::EVENT_HELLO, $handler);

    // detach all handlers of Foo::EVENT_HELLO
    Event::off(Foo::className(), Foo::EVENT_HELLO);


##Eventi che utilizzano le interfacce


C'è anche un modo più astratto per gestire gli eventi. Puoi creare un'interfaccia separata per l'evento speciale e implementarla nelle classi, dove ne hai bisogno.

Ad esempio, possiamo creare la seguente interfaccia:

    namespace app\interfaces;

    interface DanceEventInterface{

        const EVENT_DANCE = 'dance';
    }

E due classi, che lo implementano:

    class Dog extends Component implements DanceEventInterface{

        public function meetBuddy(){

            echo "Woof!";
            $this->trigger(DanceEventInterface::EVENT_DANCE);
        }
    }

    class Developer extends Component implements DanceEventInterface{

        public function testsPassed(){

            echo "Nau!";
            $this->trigger(DanceEventInterface::EVENT_DANCE);
        }
    }

Per gestire l'evento `EVENT_DANCE`, attivato da una di queste classi, chiamare **Event :: on()** e passare il nome della classe dell'interfaccia come primo argomento:

    Event::on('app\interfaces\DanceEventInterface', DanceEventInterface::EVENT_DANCE, function ($event) {
        Yii::trace(get_class($event->sender) . ' just danced'); // Will log that Dog or Developer danced
    });

Puoi attivare l'evento di tali classi:

    // trigger event for Dog class
    Event::trigger(Dog::className(), DanceEventInterface::EVENT_DANCE);

    // trigger event for Developer class
    Event::trigger(Developer::className(), DanceEventInterface::EVENT_DANCE);

Ma si noti che non è possibile attivare tutte le classi che implementano l'interfaccia:

    // DOES NOT WORK. Classes that implement this interface will NOT be triggered.
    Event::trigger('app\interfaces\DanceEventInterface', DanceEventInterface::EVENT_DANCE);

Per staccare il gestore di eventi, dovrete chiamare il metodo **Event :: off()**. Per esempio:

    // detaches $handler
    Event::off('app\interfaces\DanceEventInterface', DanceEventInterface::EVENT_DANCE, $handler);

    // detaches all handlers of DanceEventInterface::EVENT_DANCE
    Event::off('app\interfaces\DanceEventInterface', DanceEventInterface::EVENT_DANCE);


##Eventi globali


Yii supporta un cosiddetto evento globale, che in realtà è un trucco basato sul meccanismo degli eventi descritto sopra. L'evento globale richiede un "Singleton" accessibile a livello globale, come l' istanza dell'applicazione stessa.

Per creare l'evento globale, un mittente dell'evento chiama il metodo Singleton `trigger()` per attivare l'evento, invece di chiamare il metodo `trigger()` del mittente . Allo stesso modo, i gestori di eventi sono collegati all'evento sul Singleton. Per esempio:

    use Yii;
    use yii\base\Event;
    use app\components\Foo;

    Yii::$app->on('bar', function ($event) {
        echo get_class($event->sender);  // displays "app\components\Foo"
    });

    Yii::$app->trigger('bar', new Event(['sender' => new Foo]));

Un vantaggio dell'utilizzo di eventi globali è che non è necessario un oggetto quando si collega un gestore all'evento che verrà attivato dall'oggetto. Invece, l'allegato del gestore e l'attivazione dell'evento vengono entrambi eseguiti tramite Singleton (ad esempio l'istanza dell'applicazione).

Tuttavia, poiché lo spazio dei nomi degli eventi globali è condiviso da tutte le parti, è necessario nominare saggiamente gli eventi globali, ad esempio introducendo una sorta di spazio dei nomi (ad esempio "frontend.mail.sent", "backend.mail.sent").
