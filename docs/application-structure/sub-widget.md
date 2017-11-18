#Widget


I widget sono blocchi predefiniti riutilizzabili utilizzati nelle viste per creare elementi dell'interfaccia utente complessi e configurabili in modo orientato agli oggetti. Ad esempio, un widget di selezione della data può generare una selezione data fantasia, che permette agli utenti di selezionare una data come input. Tutto quello che devi fare è quello di inserire il codice seguente in una vista:

    <?php
    use yii\jui\DatePicker;
    ?>
    <?= DatePicker::widget(['name' => 'date']) ?>

Ci sono un buon numero di widget in bundle con Yii, come active form, JQuery UI, Twitter Bootrstrap Widget, ecc.. 
Di seguito, introdurremo le conoscenze di base sui widget. Si prega di far riferimento alla documentazione della classe API se si desidera conoscere l'utilizzo di un particolare widget.


##Utilizzo dei widget


I widget vengono principalmente utilizzati nelle visualizzazioni. E' possibile chiamare il metodo ***yii \ base \Widget :: widget()*** per utilizzare un widget in una vista. Il metodo accetta un array di configurazione per inizializzare il widget e restituisce il risultato del rendering del widget. Ad esempio, il codice seguente inserisce un widget di selezione della data configurato per utilizzare la lingua russa e mantenere l'input ```from_date``` nell'attributo ```$model```.

    <?php
    use yii\jui\DatePicker;
    ?>
    <?= DatePicker::widget([
        'model' => $model,
        'attribute' => 'from_date',
        'language' => 'ru',
        'dateFormat' => 'php:Y-m-d',
    ]) ?>


Alcuni widget possono prendere un blocco riguardante un contenuto, e lo racchiude tra l'invocazione di ***yii \ base \ Widget :: begin()*** e ***yii \ base \ Widget :: end()***. Ad esempio, il seguente codice utilizza il widget ***yii \ widgets \ ActiveForm*** per generare un modulo di accesso. Il widget genererà l'apertura e chiusura del tag ```<form>``` dove viene chiamato il metodo ```begin()``` e il metodo ```end()```. Qualunque cosa nel mezzo sarà lasciata così com'è.

    <?php
    use yii\widgets\ActiveForm;
    use yii\helpers\Html;
    ?>

    <?php $form = ActiveForm::begin(['id' => 'login-form']); ?>

        <?= $form->field($model, 'username') ?>

        <?= $form->field($model, 'password')->passwordInput() ?>

        <div class="form-group">
            <?= Html::submitButton('Login') ?>
        </div>

    <?php ActiveForm::end(); ?>    

Si noti che a differenza di ***yii \ base \ Widget :: widget()*** che restituisce il risultato di rendering di un widget, il metodo ***yii \ base \ Widget :: begin()*** restituisce un'istanza del widget che è possibile utilizzare per creare il contenuto del widget stesso.

!!!Warning
    Alcuni widget utilizzeranno il buffering dell'output per regolare il contenuto incluso quando viene chiamato ***yii \ base \ Widget :: end()***. Per questo motivo è previsto che la chiamata di ***yii \ base \ Widget :: begin()*** e ***yii \ base \ Widget :: end()*** avvenga nello stesso file di visualizzazione. La mancata osservanza di questa regola può comportare un risultato inaspettato.

##Creazione di widget


Per creare un widget,dobbiamo estendere ***yii \ base \ Widget*** e dobbiamo sovrascrivere i metodi ***yii \ base \ Widget :: init()*** e / o ***yii \ base \ Widget :: run()***. In genere, il metodo ```init()``` deve contenere il codice che normalizza le proprietà widget, mentre il metodo ```run()``` deve contenere il codice che genera il risultato di rendering del widget. Il risultato del rendering può essere restituito direttamente o restituito come stringa dal metodo ```run()```.

Nell'esempio seguente, il codice HTML all'interno della classe ```HelloWidget``` visualizza il contenuto assegnato alla sua proprietà ```message```. Se la proprietà non è impostata, visualizzerà "Hello World" per impostazione predefinita.

    namespace app\components;

    use yii\base\Widget;
    use yii\helpers\Html;

    class HelloWidget extends Widget{

        public $message;

        public function init(){

            parent::init();
            if ($this->message === null) {
                $this->message = 'Hello World';
            }
        }

        public function run(){

            return Html::encode($this->message);
        }
    }

Per utilizzare questo widget, è sufficiente inserire il seguente codice in una vista:

    <?php
    use app\components\HelloWidget;
    ?>
    <?= HelloWidget::widget(['message' => 'Good morning']) ?>

Di seguito vi mostro una variante della classe ```HelloWidget``` che prende il contenuto racchiuso tra le chiamate del metodo ```begin()``` e ```end()```, con HTML-encode() per visualizzarlo.

    namespace app\components;

    use yii\base\Widget;
    use yii\helpers\Html;

    class HelloWidget extends Widget{

        public function init(){

            parent::init();
            ob_start();
        }

        public function run(){

            $content = ob_get_clean();
            return Html::encode($content);
        }
    }

Come puoi vedere, il buffer di output di PHP viene avviato all'interno del metodo ```init()``` in modo che qualsiasi output tra le chiamate dei metodi ```init()``` e ```run()``` possa essere catturato, elaborato e restituito da ```run()```.

!!!Note
    Quando chiamate il metodo ***yii \ base \ Widget :: begin()***, verrà creata una nuova istanza del widget e il metodo ```init()``` verrà chiamato alla fine del costruttore del widget. Quando chiamate ***yii \ base \ Widget :: end()***,```run()``` verrà chiamato dal metodo di cui verrà restituito il risultato del return().

Il seguente codice mostra come utilizzare questa nuova variante della classe ```HelloWidget```:

    <?php
    use app\components\HelloWidget;
    ?>
    <?php HelloWidget::begin(); ?>

        content that may contain <tag>'s

    <?php HelloWidget::end(); ?>

A volte, un widget potrebbe dover restituire una grande quantità di contenuti. Mentre puoi incorporare il contenuto del metodo ```run()```, un approccio migliore è quello di metterlo in una vista e chiamare ***yii \ base \ Widget :: render()*** per restituirlo. Per esempio:

    public function run(){

        return $this->render('hello');
    
    }

Per impostazione predefinita, le viste per un widget devono essere memorizzate in file nella directory ```WidgetPath(views```, dove ```WidgetPath``` trova la directory contenente il file della classe relatio al widget. Pertanto, l'esempio soprastante, renderizza il file di visualizzazione ```@app/components/views/hello.php```, assumendo che la classe del widget si trovi sotto ```@app/components```. E' possibile sovrascrivere il metodo ***yii \ base \ Widget :: getViewPath()*** per personalizzare la directory contenente il file di visualizzazione del widget.






