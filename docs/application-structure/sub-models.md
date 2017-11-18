#Modelli  (Models)

I modelli sono parte dell'architettura MVC. Sono oggetti che rappresentano dati aziendali, regole e logica dell'applicazione. 

E' possibile creare classi model estendendo *** yii \ base \ Model *** o le sue classi figlio. Questa classe supporta molte funzioni utili:

- ***Attributi***: rappresentano i dati aziendali ed è possibile accedervi come proprietà di oggetti normali;
- ***Etichette di attributi***: permette di specificare le etichette di visualizzazione per gli attributi;
- ***Assegnazione massiva***: supporta la popolazione di attributi multipli in un solo passsaggio;
- ***Regole di convalida***: assicura che i dati di input vadano bene in base alle regole di convalida dichiarate;
- ***Esportazione dei dati***: consente di esportare i dati del modello in termini di matrici con formati personalizzabili.

La classe ```Model``` è anche la classe base per i modelli più avanzati, ad esempio *** Active Record ***.


##Attributi


Ogni attributo è come una proprietà accessibile a livello pubblico di un modello. Il metodo *** yii \ base \ Model :: attributes() *** specifica quali attributi ha una classe modello.

E' possibile accedere a un attributo come l'accesso a una proprietà di oggetto normale: 

Esempio:

    $model = new \app\models\ContactForm;

    // "name" is an attribute of ContactForm
    $model->name = 'example';
    echo $model->name;

E' inoltre possibile accedere agli attributi come l'accesso agli elementi dell'array, grazie al supporto per *** ArrayAccess *** e  Traversable ***.

    $model = new \app\models\ContactForm;

    // accessing attributes like array elements
    $model['name'] = 'example';
    echo $model['name'];

    // Model is traversable using foreach.
    foreach ($model as $name => $value) {
        echo "$name: $value\n";
    }


##Definizione degli attributi


Per impostazione predefinita, se la classe del modello si estende direttamente da *** yii \ base \ Model ***, tutte le sue variabili non statiche di membro pubblico sono attributi. Ad esempio, la classe del modello ```ContactForm``` sotto ha quattro attributi: ``name``, ```email```, ```subject``` e ```body```. Il modello ```ContactForm``` viene utilizzato per rappresentare i dati di input ricevuti da un modulo HTML.

    namespace app\models;

    use yii\base\Model;

    class ContactForm extends Model{

        public $name;
        public $email;
        public $subject;
        public $body;
    }


##Etichette di attributi


Quando si visualizzano valori o otteniamo input per gli attributi, spesso è necessario visualizzare alcune etichette associate agli attributi. Ad esempio, dato un attributo denominato, ```firstName```, e possibile visualizzare un'etichetta ```First Name``` che sia più facile da usare quando viene visualizzata per mandare all'utente messaggi di errore oppure etichette di input.

E' possibile ottenere l'etichetta di un attributo chiamando *** yii \ base \ Model :: getAttributeLabel() ***. Per esempio:

    $model = new \app\models\ContactForm;

    // displays "Name"
    echo $model->getAttributeLabel('name');

Per impostazione predefinita, le etichette degli attributi vengono generate automaticamente da nomi degli attributi. La generazione viene fatta con il metodo *** yii \ base \ Model :: generateAttributeLabel() ***. Alcuni esempi: ```username``` diventa ```Username```, ```firstName``` diventa ```First Name```.

Se non si desidare utilizzare etichette generate automaticamente, è possibile ignorare *** yii \ base \ Model :: attributeLabels() *** per dichiarare esplicitamente le etichette degli attributi.

Esempio:

    namespace app\models;

    use yii\base\Model;

    class ContactForm extends Model{

        public $name;
        public $email;
        public $subject;
        public $body;

        public function attributeLabels(){

            return [
                'name' => 'Your name',
                'email' => 'Your email address',
                'subject' => 'Subject',
                'body' => 'Content',
            ];
        }
    }

Per le applicazioni che supportano più lingue, è possibile tradurre le etichette degli attributi. Questo può essere fatto anche all'interno del metodo ```attributeLabels()```, come nel seguente esempio:

    public function attributeLabels(){

        return [
            'name' => \Yii::t('app', 'Your name'),
            'email' => \Yii::t('app', 'Your email address'),
            'subject' => \Yii::t('app', 'Subject'),
            'body' => \Yii::t('app', 'Content'),
        ];
    }

E' possibile definire anche etichette degli attributi. Ad esempio, in base allo scenario in cui è stato utilizzato il modello, è possibile restituire diverse etichette per lo stesso attributo

!!!Note
    Le etichette degli attributi fanno parte delle stesse view(viste). Ma la dichiarazione di etichette nei modelli è spesso molto conveniente ed è molto comodo per avere un codice più pulito e riutilizzabile.


##Scenari


Un modello puà essere utilizzato in diversi scenari. Ad esempio, un modello ```User``` può essere utilizzato per raccogliere gli ingressi di login utente, ma può essere utilizzato anche per la registrazione di utenti. In diversi scenari, un modello può utilizzare regole e logiche differenti. Ad esempio, l'attributo ```email``` può essere richiesto sia durante la registrazione degli utenti, ma non è così durante la fase di login.

Un modello utilizza la proprietà *** scenario yii \ base \ Model :: *** per tenere traccia dello scenario in cui viene utilizzato. Per impostazione predefinita, un modello supporta solo un singolo scenario denominato ```default```. Il seguente codice mostra due modi per impostare lo scenario di un modello:

    // scenario is set as a property
    $model = new User;
    $model->scenario = User::SCENARIO_LOGIN;

    // scenario is set through configuration
    $model = new User(['scenario' => User::SCENARIO_LOGIN]);

Per impostazione predefinita, gli scenari supportati da un modello sono determinati dalle regole di convalida dichiarate nel modello. Tuttavia, è possivile personalizzare questo comportamento prevenendo il meodo *** yii \ base \ Model :: scenari() ***, ad esempio:

    namespace app\models;

    use yii\db\ActiveRecord;

    class User extends ActiveRecord{

        const SCENARIO_LOGIN = 'login';
        const SCENARIO_REGISTER = 'register';

        public function scenarios(){

            return [
                self::SCENARIO_LOGIN => ['username', 'password'],
                self::SCENARIO_REGISTER => ['username', 'email', 'password'],
            ];
        }
    }

Il metodo ```scenarios()``` restituisce un array le cui chiavi sono i nomi di scenari e valori relativi agli attributi attivi. Un attributo attivo può essere assegnato massicciamente e soggetto alla convalida. Nell'esempio precedente, gli attributi ```username``` e ```password``` sono attivi nello scenario ```login```; mentre nello scenario ```register```, ```email```è lo stesso attivo oltre a ```username``` e ```password```.

L'implementazione predefinita ```scenarios()```restituira tutti gli scenari trovati nel metodo di dichiarazione della regola valid *** yii \ base \ Model :: rules() ***. Quando si sceglie ```scenarios()```, se si desidare introdurre nuovi scenari in aggiunta a quelli predefiniti, è possibile scrivere un codice come segue:

    namespace app\models;

    use yii\db\ActiveRecord;

    class User extends ActiveRecord{

        const SCENARIO_LOGIN = 'login';
        const SCENARIO_REGISTER = 'register';

        public function scenarios(){

            $scenarios = parent::scenarios();
            $scenarios[self::SCENARIO_LOGIN] = ['username', 'password'];
            $scenarios[self::SCENARIO_REGISTER] = ['username', 'email', 'password'];
            return $scenarios;
        }
    }
 

##Regole di convalida


Quando i dati di un modello vengono ricevuti dagli utenti finali, deve essere convalidati per assicrarsi che soddisfino determinate regole ( chiamate *** regole di convalida ***). Ad esempio, dato un modello ```ContactForm```, è possibile assicurarsi che tutti gli attributi non siano vuoti e che l'attributo ```email``` contenga un indirizzo email valido. Se i valori di alcuni attributi non soddisfano le regole corrispondenti, è necessario visualizzare i messaggi di errore appropriati per aiutare l'utente a correggere gli errori.

Puoi chiamare il metodo ***yii \ base \ Model :: validate()*** per convalidare i dati ricevuti. Il metodo utilizzerà le regole di convalida dichiarate all'interno del nostro modello. Se non viene trovato alcun errore, esso restituirà ```true```. In caso contrario, manterrà gli errori nella proprietà *** yii \ base \ Model :: errors *** e restituirà ```false```. Per esempio:

    $model = new \app\models\ContactForm;

    // populate model attributes with user inputs
    $model->attributes = \Yii::$app->request->post('ContactForm');

    if ($model->validate()) {
        // all inputs are valid
    } else {
        // validation failed: $errors is an array containing error messages
        $errors = $model->errors;
    }

Per dichiarare regole di convalida associate a un modello, dovete aggiungere il metodo *** yii \ base \ Model :: rules() *** restituendo le regole che gli attributi del modello devono soddisfare. L'esempio seguente mostra le regole di convalida dichiarate per il modello ```ContactForm```:

    public function rules(){

        return [
            // the name, email, subject and body attributes are required
            [['name', 'email', 'subject', 'body'], 'required'],

            // the email attribute should be a valid email address
            ['email', 'email'],
        ];
    }

Una regola può essere utilizzata per convalidare uno o più attributi, e un attributo può essere convalidato da una o più regole.
A volte, è possibile che una regola venga applicata solo in alcuni scenari. A tal fine, è possibile specificare la proprietà ```on``` ad una regola.

Esempio:

    public function rules(){

        return [
            // username, email and password are all required in "register" scenario
            [['username', 'email', 'password'], 'required', 'on' => self::SCENARIO_REGISTER],

            // username and password are required in "login" scenario
            [['username', 'password'], 'required', 'on' => self::SCENARIO_LOGIN],
        ];
    }

Se non si specifica la proprietà ```on```, questa regola verrà applicata in tutti gli scenari. Una regola, viene definita *** attiva *** se può essere applicata nello scenario del modello corrente.

Un attributo verrà convalidato se e solo se è un attributo attivo dichiarato nel metodo ```scenarios()``` e associato a una o più regole attive dichiarate nel metodo ```rules()```.


##Assegnazione massiva


L'assegnazione massiva è un modo conveniente per popolare un modello con gli ingressi utente utilizzando una sola riga di codice. Consente di popolare gli attributi di un modello  assegnando i dati di input direttamente alla proprietà del nostro modulo. Le seguenti due righe di codice sono equivalenti, entrambi associano i dati del modulo inviati dagli utenti finali agli attributi del modello ```ContactForm```. Chiaramente, il primo, è più pulito e meno erroneo del secondo:

    $model = new \app\models\ContactForm;
    $model->attributes = \Yii::$app->request->post('ContactForm');

    $model = new \app\models\ContactForm;
    $data = \Yii::$app->request->post('ContactForm', []);
    $model->name = isset($data['name']) ? $data['name'] : null;
    $model->email = isset($data['email']) ? $data['email'] : null;
    $model->subject = isset($data['subject']) ? $data['subject'] : null;
    $model->body = isset($data['body']) ? $data['body'] : null;


##Attributi sicuri


L'assegnazione massiva si applica solo ai cosiddetti  *** attributi sicuri *** che sono gli attributi elencati negli scenari del modello corrente. Ad esempio, se il modello ```User``` ha la seguente dichiarazione di scenari, allora quando lo scenario corrente è ```login```, solo l'```username``` e ```password``` può essere assegnato massivamente. Qualsiasi altro attributo sarà mantenuto intatto.

    public function scenarios(){

        return [
            self::SCENARIO_LOGIN => ['username', 'password'],
            self::SCENARIO_REGISTER => ['username', 'email', 'password'],
        ];
    }

!!!Note
    Il motivo per cui l'assegnazione di massa si applica solo agli attributi sicuri, è perchè si desidera controllare quali attributi possono essere modificati dagli utenti finali. Ad esempio, se il modello ```User``` dispone di un attributo ```permission``` che determina l'autorizzazione assegnata all'utente, si desidera modificare tale attributo dagli amministratori solo tramite un'interfaccia backend.

Per rendere un attributo sicuro, viene fornito un alias chiamato ```safe```. E' un alias di validazione speciale in modo da poter dichiarare un attributo sicuro senza effettuare la convalida. Ad esempio, le seguenti regole dichiarano che sia ```title``` che ```description``` siano attributi sicuri.

    public function rules(){

        return [
            [['title', 'description'], 'safe'],
    
        ];
    }


##Attributi non sicuri


Come detto in precedenza, il metodo ```scenarios()``` serve per due scopi: determinare quali attributi devono essere convalidati e determinare quali attributi sono sicuri. In alcuni casi rari, si potrebbe desiderare di convalidare un attributo, ma non si desidera contrassegnarlo. Puoi farlo configurando un punto esclamativo ```!``` al nome dell'attributo quando lo dichiari all'interno del metodo ```scenarios()```, come l'esempio dell'attributo ```secret``` nel seguente esempio:

    public function scenarios(){

        return [
            self::SCENARIO_LOGIN => ['username', 'password', '!secret'],
    
        ];
    }

Quando il modello è nello scenario ```login```, tutti e tre gli attributi verranno convalidati. Tuttavia, solo gli attributi ```username``` e ```password``` possono essere assegnati in modo massivo. Per assegnare un valore di input all'attributo ```secret```, dobbiamo farlo in modo esplicito

    $model->secret = $secret;

La stessa cosa può essere fatta nel metodo ```rules()```.

    public function rules(){

        return [
            [['username', 'password', '!secret'], 'required', 'on' => 'login']
        ];
    }

In questo caso gli attributi ```username```, ```password``` e ```secret``` sono necessari, ma ```secret``` deve essere assegnato in modo esplicito.


##Esportazione dei dati


I modelli spesso devono essere esportati in diversi formati. Ad esempio, è possibile convertire una raccolta di modeli in formato JSON o Excel. Il processo di esportazione può essere suddiviso in due fasi indipendenti:
- i modelli vengono convertiti in array;
- gli array vengono convertiti in formati di destinazione.

Puoi concentrarti solo sul primo passo, perchè il secondo può essere raggiungo da formattatori di dati generici, come *** yii \ web \ JsonResponseFormatter ***.

Il modo più semplice per convertire un modello in un array è quello di utilizzare la proprietà *** yii \ base \ Model :: $attributes ***. Per esempio:

    $post = \app\models\Post::findOne(100);
    $array = $post->attributes;

Per impostazione predefinita, la proprietà ***attributes*** restituirà i valori di tutti gli attributi dichiarati in *** yii \ base \ Model :: () ***.

Un modo più flessibile e potente per convertire un modello in un array è quello di utilizzare il metodo ***yii\ base \ Model :: to Array()***. Il suo comportamento predefinito è lo stesso di quello del metodo ***attributes***. Tuttavia, consente di scegliere quali elementi di dati ( chiamati ***campi***), bisogna inserire nell'array risultante e come dovrebbero essere formattati.


##Campi


Un campo è semplicemente un elemento denominato nell'array ottenuto chiamando il metodo ***yii \ base \ Model :: toArray()*** di un modello.

Per impostazione predefinita, i nomi dei campi sono equivalenti ai nomi degli attributi. Tuttavia, è possibile modificare questo comportamento dichiarando i metodi ***fields()*** e / o ***extraFields()***. Entrambi i metodi devono restituire un elenco delle definizione dei campi. I campi definiti da ```fields()``` sono campi predefiniti, il che significa che ```toArray()``` restituirà questi campi per impostazione predefinita. Il metodo ```extraFields()``` definisce campi aggiuntivi disponibili che possono anche essere restituiti dal metodo ```toArray()``` affinchè si specifichi tramite il parametro ```$expand```. Ad esempio, il codice riportato di seguito restituirà tutti i campi definiti ```fields()``` e i campi ```prettyName``` e ```fullAddress``` se sono definiti ```extraFields()```.

    $array = $model->toArray([], ['prettyName', 'fullAddress']);

E' possibile ignorare ```fields()``` per aggiungere,rimuovere, rinominare o ridefinire i campi. Il valore restituito dal metodo ```fields()`` dovrà essere un array. I nomi dell'array sono i nomi dei campi e i valori dell'array sono le corrispondenti definizioni dei campi che possono essere nomi di proprietà/attributi o funzioni anonime che restituiscono i valori del campo corrispondente. Nel caso speciale quando un nome di un campo è uguale al suo nome dell'attributo, è possibile ignorare il nome dell'array. Per esempio:

    // explicitly list every field, best used when you want to make sure the changes
    // in your DB table or model attributes do not cause your field changes (to keep API backward compatibility).
    public function fields(){

        return [
            // field name is the same as the attribute name
            'id',

            // field name is "email", the corresponding attribute name is "email_address"
            'email' => 'email_address',

            // field name is "name", its value is defined by a PHP callback
            'name' => function () {
                return $this->first_name . ' ' . $this->last_name;
            },
        ];
    }

    // filter out some fields, best used when you want to inherit the parent implementation
    // and blacklist some sensitive fields.
    public function fields(){

        $fields = parent::fields();

        // remove fields that contain sensitive information
        unset($fields['auth_key'], $fields['password_hash'], $fields['password_reset_token']);

        return $fields;
    }

!!!Warning
    Per impostazione predefinita tutti gli attributi di un modello saranno inclusi nell'array esportato, è necessario esaminare i dati per assicurarsi di non contenere informazioni sensibili. Se ci sono tali informazioni, dovresti ignorare il metodo ```fields()``` per filtrarli. Nell'esempio sopra, abbiamo scelto di filtrare ```auth_key```, ```password_hash``` e ```password_reset_token```.

    