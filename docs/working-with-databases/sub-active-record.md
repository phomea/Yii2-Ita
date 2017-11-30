#Active Record


Active Record fornisce un'interfaccia orientata agli oggetti per l'accesso e la manipolazione dei dati memorizzati nei database. Una classe di Active Record è associata a una tabella di database, un'istanza di Active Record corrisponde a una riga di tale tabella e un attributo di un'istanza di Active Record, rappresenta il valore di una determinata colonna in tale riga. Invece di scrivere istruzioni SQL non elaborate, è necessario accedere agli attributi di Active Record e chiamare i metodi per accedere e manipolare i dati memorizzati nelle tabelle del database.

Ad esempio, supponiamo che `Customer` sia una classe Active Record associata alla tabella `customer` e `name` sia una colonna della tabelle `customer`. Puoi scrivere il seguente codice per inserire una nuova riga nella tabelle `customer`:

    $customer = new Customer();
    $customer->name = 'Qiang';
    $customer->save();

Il codice precedente equivale a utilizzare la seguente istruzione SQL raw per MySQL, che è meno intuitiva, più incline agli errori e potrebbe persino presentare problemi di compatibilità se si utilizza un tipo diverso di database:

    $db->createCommand('INSERT INTO `customer` (`name`) VALUES (:name)', [
        ':name' => 'Qiang',
    ])->execute();

Yii fornisce il supporto Active Record per i seguenti database relazionali:

- MySQL 4.1 o versioni successive: tramite **yii \ db \ ActiveRecord**
- PostgreSQL 7.3 o successivo: tramite **yii \ db \ ActiveRecord**
- SQLite 2 e 3: tramite **yii \ db \ ActiveRecord**
- Microsoft SQL Server 2008 o versioni successive: tramite **yii \ db \ ActiveRecord**
- Oracle: tramite **yii \ db \ ActiveRecord**
- CUBRID 9.3 o successivo: tramite **yii \ db \ ActiveRecord** (si noti che a causa di un bug nell'estensione PDO cubrid, la citazione dei valori non funzionerà, quindi è necessario CUBRID 9.3 come client e server)
- Sfinge: tramite **yii \ sphinx \ ActiveRecord** , richiede l'estensione `yii2-sphinx`
- ElasticSearch: tramite **yii \ elasticsearch \ ActiveRecord**, richiede l'estensione `yii2-elasticsearch`

Inoltre, Yii supporta anche l'uso di Active Record con i seguenti database NoSQL:

- Redis 2.6.12 o successivo: tramite **yii \ redis \ ActiveRecord**, richiede l'estensione `yii2-redis`
- MongoDB 1.3.0 o versioni successive: tramite **yii \ mongodb \ ActiveRecord**, richiede l'estensione `yii2-mongodb`

In questo tutorial, descriveremo principalmente l'utilizzo di Active Record per i database relazionali. Tuttavia, la maggior parte dei contenuti descritti qui sono applicabili anche a Active Record per database NoSQL.


***Dichiarazione di classi di Active Record***

Per iniziare, dobbiamo dichiarare una classe Active Record estendendo *** yii \ db \ ActiveRecord ***.


##Impostare il nome della tabella

Per impostazione predefinita ogni classe Active Record è associata alla sua tabella di database. Il metodo `tableName()` restituisce il nome della tabella convertendo il nome della classe tramite **yii \ helpers \ Inflector :: camel2id()**. È possibile sovrascrivere questo metodo se la tabella non viene denominata dopo questa convenzione.

Può essere applicato anche un valore predefinito `tablePrefix`. Ad esempio se tablePrefix è `tbl_`, `Customer` diventa `tbl_customer` e `OrderItem` diventa `tbl_order_item`.

Se il nome di una tabella è dato come `{{%TableName}}`, allora il carattere percentuale `%` verrà sostituito con il prefisso della tabella. Ad esempio, `{{%post}}` diventa `{{tbl_post}}`. Le parentesi attorno al nome della tabella vengono utilizzate per la citazione in una query SQL.

Nell'esempio seguente, dichiariamo una classe Active Record chiamata `Customer` per la tabella `customer` del database.

    namespace app\models;

    use yii\db\ActiveRecord;

    class Customer extends ActiveRecord{

        const STATUS_INACTIVE = 0;
        const STATUS_ACTIVE = 1;
    
        /**
         * @return string the name of the table associated with this ActiveRecord class.
        */
        public static function tableName(){

            return '{{customer}}';
        }
    }


***Gli Active Record sono chiamati come "modelli"***


Le istanze di Active Record sono considerate come modelli. Per questo motivo, di solito mettiamo le classi di Active Record sotto il namespace `app\models` (o altri namespace per mantenere le classi del modello).

Poiché **yii \ db \ ActiveRecord** si estende da **yii \ base \ Model**, eredita tutte le funzionalità del modello, come attributi, regole di convalida, serializzazione dei dati, ecc. 


##Connessione al database


Per impostazione predefinita, Active Record utilizza il componente db dell'applicazione come connessione DB per accedere e manipolare i dati del database. Come spiegato in Database Access Objects, puoi configurare il componente db nella configurazione dell'applicazione come mostrato di seguito,

    return [
        'components' => [
            'db' => [
                'class' => 'yii\db\Connection',
                'dsn' => 'mysql:host=localhost;dbname=testdb',
                'username' => 'demo',
                'password' => 'demo',
            ],
        ],
    ];

Se si desidera utilizzare una connessione al database diversa dal dbcomponente, è necessario eseguire l'override del metodo `getDb()`:

    class Customer extends ActiveRecord{

        // ...

        public static function getDb(){

            // use the "db2" application component
            return \Yii::$app->db2;  
        }   
    }


##Dati nelle query


Dopo aver dichiarato una classe Active Record, è possibile utilizzarla per eseguire query sui dati dalla tabella di database corrispondente. Il processo solitamente richiede i seguenti tre passaggi:

- Creare un nuovo oggetto query chiamando il metodo **yii \ db \ ActiveRecord :: find()**;
- Costruire l'oggetto query chiamando i metodi di costruzione delle query;
- Chiama un metodo di query per recuperare i dati in termini di istanze di record attivo.

Come puoi vedere, questo è molto simile alla procedura con il generatore di query. L'unica differenza è che anziché utilizzare l'operatore `new` per creare un oggetto query, si chiama **yii \ db \ ActiveRecord :: find()** per restituire un nuovo oggetto query che è di classe **yii \ db \ ActiveQuery**.

Di seguito sono riportati alcuni esempi che mostrano come utilizzare la Query attiva per interrogare i dati:

    // return a single customer whose ID is 123
    // SELECT * FROM `customer` WHERE `id` = 123
    $customer = Customer::find()
        ->where(['id' => 123])
        ->one();

    // return all active customers and order them by their IDs
    // SELECT * FROM `customer` WHERE `status` = 1 ORDER BY `id`
    $customers = Customer::find()
        ->where(['status' => Customer::STATUS_ACTIVE])
        ->orderBy('id')
        ->all();

    // return the number of active customers
    // SELECT COUNT(*) FROM `customer` WHERE `status` = 1
    $count = Customer::find()
        ->where(['status' => Customer::STATUS_ACTIVE])
        ->count();

    // return all customers in an array indexed by customer IDs
    // SELECT * FROM `customer`
    $customers = Customer::find()
        ->indexBy('id')
        ->all();

In quanto spiegato sopra, `$customer` è un oggetto della class `Customer` mentre `$customers` è una matrice degli oggetti  `Customer`. Sono tutti popolati con i dati recuperati dalla tabella `customer`.

!!!Info
    Poiché **yii \ db \ ActiveQuery** si estende da **yii \ db \ Query**, è possibile utilizzare tutti i metodi di creazione di query e i metodi di query come descritto nella sezione Query Builder.

Poiché è un'attività comune per eseguire una query in base ai valori delle chiavi primarie o a un insieme di valori di colonna, Yii fornisce due metodi di scelta rapida per questo scopo:

- **yii \ db \ ActiveRecord :: findOne()**: restituisce una singola istanza del record attivo popolata con la prima riga del risultato della query.
- **yii \ db \ ActiveRecord :: findAll()**: restituisce una matrice di istanze di record attivo popolate con tutti i risultati della query.

Entrambi i metodi possono assumere uno dei seguenti formati di parametro:

- un valore scalare: il valore viene considerato come il valore della chiave primaria desiderato da cercare. Yii determinerà automaticamente quale colonna è la colonna della chiave primaria leggendo le informazioni sullo schema del database.
- una matrice di valori scalari: la matrice viene considerata come i valori della chiave primaria desiderati da cercare.
- un array associativo: le chiavi sono nomi di colonne e i valori sono i corrispondenti valori di colonna desiderati da cercare. Si prega di fare riferimento al formato hash per maggiori dettagli.

Il codice seguente mostra come utilizzare questi metodi:

    // returns a single customer whose ID is 123
    // SELECT * FROM `customer` WHERE `id` = 123
    $customer = Customer::findOne(123);

    // returns customers whose ID is 100, 101, 123 or 124
    // SELECT * FROM `customer` WHERE `id` IN (100, 101, 123, 124)
    $customers = Customer::findAll([100, 101, 123, 124]);

    // returns an active customer whose ID is 123
    // SELECT * FROM `customer` WHERE `id` = 123 AND `status` = 1
    $customer = Customer::findOne([
        'id' => 123,
        'status' => Customer::STATUS_ACTIVE,
    ]);

    // returns all inactive customers
    // SELECT * FROM `customer` WHERE `status` = 0
    $customers = Customer::findAll([
        'status' => Customer::STATUS_INACTIVE,
    ]);

!!!Nota
    Né **yii \ db \ ActiveRecord :: findOne()** né **yii \ db \ ActiveQuery :: one()** verranno aggiunti `LIMIT 1` all'istruzione SQL generata. Se la tua query potrebbe restituire molte righe di dati, dovresti chiamare il metodo `limit(1)` per migliorare le prestazioni, ad es `Customer::find()->limit(1)->one()`.

Oltre a utilizzare metodi di creazione di query, è anche possibile scrivere SQL raw per eseguire query sui dati e popolare i risultati in oggetti Active Record. È possibile farlo chiamando il metodo **yii \ db \ ActiveRecord :: findBySql()**:

    // returns all inactive customers
    $sql = 'SELECT * FROM customer WHERE status=:status';
    $customers = Customer::findBySql($sql, [':status' => Customer::STATUS_INACTIVE])->all();

Si consiglia di non chiamare metodi di creazione di query aggiuntivi dopo aver chiamato **findBySql()** poiché verranno ignorati.


##Accesso ai dati


Come indicato sopra, i dati richiamati dal database vengono popolati in istanze di Active Record e ogni riga del risultato della query corrisponde a una singola istanza dell'Active Record. È possibile accedere ai valori della colonna accedendo agli attributi delle sue istanze, ad esempio,

    // "id" and "email" are the names of columns in the "customer" table
    $customer = Customer::findOne(123);
    $id = $customer->id;
    $email = $customer->email;

!!!Nota    
    Gli attributi dell'Active Record vengono denominati in base alla distinzione tra maiuscole e minuscole della tabella associata. Yii definisce automaticamente un attributo in Active Record per ogni colonna della tabella associata. NON si deve ridichiarare nessuno degli attributi.

Poiché gli attributi di Active Record prendono il nome da colonne di tabelle, è possibile che si stia scrivendo codice PHP simile a `$customer->first_name`, che utilizza caratteri di sottolineatura per separare le parole nei nomi di attributi se le colonne della tabella vengono denominate in questo modo. Se sei preoccupato della coerenza dello stile del codice, dovresti rinominare le colonne della tabella di conseguenza (per usare `camelCase`, ad esempio).

##Trasformazione dei dati


Accade spesso che i dati inseriti e / o visualizzati siano in un formato diverso da quello utilizzato per la memorizzazione dei dati in un database. Ad esempio, nel database si memorizzano i compleanni dei clienti come timestamp UNIX (che però non è un buon design), mentre nella maggior parte dei casi si desidera manipolare i compleanni come stringhe nel formato di 'YYYY/MM/DD'. Per raggiungere questo obiettivo, è possibile definire i metodi di trasformazione dei dati nella Customer classe Active Record come segue:

    class Customer extends ActiveRecord{

        // ...

        public function getBirthdayText(){

            return date('Y/m/d', $this->birthday);
        }
    
        public function setBirthdayText($value){

            $this->birthday = strtotime($value);
        }
    }

Ora nel tuo codice PHP, invece di accedere a `$customer->birthday`, accederai a `$customer->birthdayText`, il che ti consentirà di inserire e visualizzare i compleanni dei clienti nel formato di 'YYYY/MM/DD'.

!!!Tip
    L'esempio sopra mostra un modo generico di trasformare i dati in diversi formati. Se stai lavorando con i valori di date, puoi utilizzare `DateValidator` e `DatePicker`, che sono più facili da usare e più potenti.

##Recupero dei dati nelle matrici


Mentre il recupero dei dati in termini di oggetti Active Record è comodo e flessibile, non è sempre consigliabile quando si deve riportare una grande quantità di dati a causa del grande ingombro di memoria. In questo caso, puoi recuperare i dati utilizzando matrici PHP chiamando il metodo **asArray()** prima di eseguire un metodo di query:

    // return all customers
    // each customer is returned as an associative array
    $customers = Customer::find()
        ->asArray()
        ->all();

!!!Nota
    Mentre questo metodo consente di risparmiare memoria e migliorare le prestazioni, è più vicino al livello di astrazione DB inferiore, e si perderanno la maggior parte delle funzionalità di Active Record. Una distinzione molto importante si trova nel tipo di dati dei valori delle colonne. Quando restituisci i dati nelle istanze di Active Record, i valori delle colonne verranno automaticamente tipizzati in base ai tipi di colonna effettivi; d'altra parte quando si restituiscono i dati nelle matrici, i valori delle colonne saranno stringhe (poiché sono il risultato di PDO senza elaborazione), indipendentemente dai loro effettivi tipi di colonna.


##Recupero dei dati in lotti


In Query Builder, abbiamo spiegato che è possibile utilizzare la query batch per ridurre al minimo l'utilizzo della memoria quando si esegue una query su una grande quantità di dati dal database. Puoi usare la stessa tecnica in Active Record. Per esempio,

    // fetch 10 customers at a time
    foreach (Customer::find()->batch(10) as $customers) {
        // $customers is an array of 10 or fewer Customer objects
    }

    // fetch 10 customers at a time and iterate them one by one
    foreach (Customer::find()->each(10) as $customer) {
        // $customer is a Customer object
    }

    // batch query with eager loading
    foreach (Customer::find()->with('orders')->each() as $customer) {
        // $customer is a Customer object with the 'orders' relation populated
    }


##Salvataggio dei dati

Usando Active Record, puoi facilmente salvare i dati nel database seguendo i seguenti passi:

1. Preparare un'istanza dell'Active Record
2. Assegnare nuovi valori agli attributi dell'Active Record
3. Chiamare **yii \ db \ ActiveRecord :: save()** per salvare i dati nel database.

Per esempio,

    // insert a new row of data
    $customer = new Customer();
    $customer->name = 'James';
    $customer->email = 'james@example.com';
    $customer->save();

    // update an existing row of data
    $customer = Customer::findOne(123);
    $customer->email = 'james@newexample.com';
    $customer->save();

Il metodo **save()** può inserire o aggiornare una riga di dati, a seconda dello stato dell'istanza dell'Active Record. Se l'istanza è stata appena creata dall'operatore `new`, la chiamata a **save()** causerà l'inserimento di una nuova riga; Se l'istanza è il risultato di un metodo di query, la chiamata a **save()** aggiornerà la riga associata all'istanza.

È possibile differenziare i due stati di un'istanza di Active Record controllando il valore della proprietà **yii \ db \ ActiveRecord :: isNewRecord**. Questa proprietà viene anche utilizzata internamente da **save()** come segue:

    public function save($runValidation = true, $attributeNames = null){

        if ($this->getIsNewRecord()) {
            return $this->insert($runValidation, $attributeNames);
        } else {
            return $this->update($runValidation, $attributeNames) !== false;
        }
    }

!!!Tip
    Puoi chiamare i metodi **insert()** o **update()** direttamente per inserire o aggiornare una riga.


##Convalida dei dati


Poiché **yii \ db \ ActiveRecord** si estende da **yii \ base \ Model**, condivide la stessa funzione di convalida dei dati . È possibile dichiarare regole di convalida sovrascrivendo il metodo **rules()** ed eseguire la convalida dei dati chiamando il metodo **validate()**.

Quando chiami **save()**, per impostazione predefinita chiamerà automaticamente **validate()**. Solo quando passa la convalida, in realtà salverà i dati; altrimenti verrà semplicemente restituito falsee sarà possibile controllare la proprietà **yii \ db \ ActiveRecord :: errors** per recuperare i messaggi di errore di convalida.

!!!Tip
    Se si è certi che i dati non necessitano di convalida (ad esempio, i dati provengono da fonti attendibili), è possibile chiamare `save` (false) per saltare la convalida.


##Assegnazione massiccia


Come i modelli normali , anche le istanze di Active Record godono della massiccia funzione di assegnazione. Utilizzando questa funzione, è possibile assegnare valori a più attributi di un'istanza di Active Record in una singola istruzione PHP, come mostrato di seguito. Ricorda che solo gli attributi sicuri possono essere assegnati in modo massiccio, però.

    $values = [
        'name' => 'James',
        'email' => 'james@example.com',
    ];

    $customer = new Customer();

    $customer->attributes = $values;
    $customer->save();


##Aggiornamento dei contatori


È un'attività comune incrementare o decrementare una colonna in una tabella di database. Chiamiamo queste colonne "counter columns". È possibile utilizzare **updateCounters()** per aggiornare una o più colonne contatore. Per esempio,

    $post = Post::findOne(100);

    // UPDATE `post` SET `view_count` = `view_count` + 1 WHERE `id` = 100
    $post->updateCounters(['view_count' => 1]);

!!!Nota    
    Se si utilizza **yii \ db \ ActiveRecord :: save()** per aggiornare una colonna contatore, si potrebbe finire con un risultato inaccurato, poiché è probabile che lo stesso contatore venga salvato da più richieste che leggono e scrivono lo stesso valore contatore.


##Attributi dirty (sporchi)


Quando si chiama il metodo **save()** per salvare un'istanza dell'Active Record, vengono salvati solo gli attributi dirty. Un attributo è considerato sporco se il suo valore è stato modificato poiché è stato caricato dal DB o salvato in DB più recentemente. Si noti che la convalida dei dati verrà eseguita indipendentemente dal fatto che l'istanza dell'Active Record abbia o meno attributi sporchi.

L'Active Record mantiene automaticamente l'elenco degli attributi dirty. Lo fa mantenendo una versione precedente dei valori degli attributi e confrontandoli con l'ultima. È possibile chiamare **yii \ db \ ActiveRecord :: getDirtyAttributes()** per ottenere gli attributi attualmente sporchi. Puoi anche chiamare **yii \ db \ ActiveRecord :: markAttributeDirty()** per contrassegnare esplicitamente un attributo come dirty.

Se sei interessato ai valori degli attributi prima della loro modifica più recente, puoi chiamare i metodi `getOldAttributes()` o `getOldAttribute()`.

!!!Nota
    Il confronto tra vecchi e nuovi valori verrà eseguito utilizzando l'operatore `===` in modo che un valore venga considerato sporco anche se ha lo stesso valore ma un tipo diverso. Questo è spesso il caso in cui il modello riceve input da moduli HTML in cui ogni valore è rappresentato come una stringa. Per assicurare che il tipo corretto per esempio valori interi si può applicare un filtro di convalida : `['attributeName', 'filter', 'filter' => 'intval']`. Funziona con tutte le funzioni di typecasting di PHP come `intval()` , `floatval()` , `boolval` , ecc ...


##Valori predefiniti di un attributo


Alcune delle colonne della tabella possono avere valori predefiniti definiti nel database. A volte, è possibile pre-compilare il modulo Web per un'istanza dell'Active Record con questi valori predefiniti. Per evitare di scrivere nuovamente gli stessi valori predefiniti, è possibile chiamare `loadDefaultValues ​()` per popolare i valori predefiniti definiti dal DB negli attributi del record attivo corrispondente:

    $customer = new Customer();
    $customer->loadDefaultValues();
    // $customer->xyz will be assigned the default value declared when defining the "xyz" column    


##Attributi Typecasting


Compilando i risultati della query **yii \ db \ ActiveRecord**, viene eseguito un typecast automatico per i suoi valori di attributo, utilizzando le informazioni dallo schema della tabella del database. Ciò consente ai dati recuperati dalla colonna della tabella dichiarata come numero intero di essere popolati nell'istanza dell'ActiveRecord con un valore PHP intero, booleano con booleano e così via. Tuttavia, il meccanismo di typecasting ha diverse limitazioni:

- I valori float non vengono convertiti e verranno rappresentati come stringhe, altrimenti potrebbero perdere precisione.
- La conversione dei valori interi dipende dalla capacità intera del sistema operativo che si utilizza. In particolare: i valori della colonna dichiarata come "intero senza segno" o "intero grande" saranno convertiti in intero PHP solo con il sistema operativo a 64 bit, mentre su quelli a 32 bit saranno rappresentati come stringhe.

Si noti che l'attributo `typecast` viene eseguito solo durante il popolamento dell'istanza ActiveRecord dal risultato della query. Non esiste conversione automatica per i valori caricati dalla richiesta HTTP o impostati direttamente tramite l'accesso alla proprietà. Lo schema della tabella verrà utilizzato anche durante la preparazione delle istruzioni SQL per il salvataggio dei dati di ActiveRecord, garantendo che i valori siano associati alla query con il tipo corretto. Tuttavia, i valori degli attributi dell'istanza di ActiveRecord non verranno convertiti durante il processo di salvataggio.

!!!Tip
    E' possibile utilizzare **yii \ behaviors \ AttributeTypecastBehavior** per facilitare i valori degli attributi typecasting sulla convalida o il salvataggio di ActiveRecord.


##Aggiornamento di più righe


I metodi descritti sopra funzionano tutti su singole istanze di Active Record, causando l'inserimento o l'aggiornamento di singole righe di tabella. Per aggiornare più righe contemporaneamente, è necessario chiamare il metodo `updateAll()` , invece, che è un metodo statico.

    // UPDATE `customer` SET `status` = 1 WHERE `email` LIKE `%@example.com%`
    Customer::updateAll(['status' => Customer::STATUS_ACTIVE], ['like', 'email', '@example.com']);

Allo stesso modo, puoi chiamare il metodo `updateAllCounters()` per aggiornare le colonne contatore di più righe contemporaneamente.

    // UPDATE `customer` SET `age` = `age` + 1
    Customer::updateAllCounters(['age' => 1]);


##Eliminazione dei dati


Per eliminare una singola riga di dati, dobbiamo recuperare prima l'istanza dell'Active Record corrispondente a quella riga e quindi chiamare il metodo **yii \ db \ ActiveRecord :: delete()**.

    $customer = Customer::findOne(123);
    $customer->delete();

È possibile chiamare **yii \ db \ ActiveRecord :: deleteAll()** per eliminare più o tutte le righe di dati. Per esempio,

    Customer::deleteAll(['status' => Customer::STATUS_INACTIVE]);

!!!Warning    
    Fai molta attenzione quando chiami `deleteAll()` perché potrebbe cancellare completamente tutti i dati dalla tua tabella se commetti un errore nel specificare la condizione.


##Cicli di vita dell'Active Record


È importante comprendere i cicli di vita dell'Active Record quando viene utilizzato per scopi diversi. Durante ciascun ciclo di vita, verrà invocata una determinata sequenza di metodi e sarà possibile ignorare questi metodi per ottenere la possibilità di personalizzare il ciclo di vita. Puoi anche rispondere a determinati eventi dell'Active Record attivati ​​durante un ciclo di vita per iniettare il tuo codice personalizzato. Questi eventi sono particolarmente utili quando si sviluppano comportamenti Active Record che devono personalizzare i cicli di vita di un determinato Active Record.

Di seguito, riassumeremo i vari cicli di vita dell'Active Record e i metodi / eventi coinvolti nei cicli di vita.  


***Nuovo ciclo di vita***


Quando si crea una nuova istanza Active Record tramite l'operatore `new`, si verificherà il seguente ciclo di vita:

1. Istanziare il costruttre della classe.
2. **init()**: il metodo deve attivave un evento **EVENT_INIT**.


***Interrogare il ciclo di vita sui dati richiesti***


Quando si interrogano i dati tramite uno dei metodi di query , ciascun Active Record popolato di recente, subirà il seguente ciclo di vita:

1. Istanziare il costruttre della classe.
2. **init()**: il metodo deve attivare un evento **EVENT_INIT**.
3. **afterFind()**: il metodo deve attivare un evento **EVENT_AFTER_FIND**.


***Salvataggio del ciclo di vita sui dati richiesti***


Quando si chiama il metodo **save()** per inserire o aggiornare un'istanza di Active Record, si verificherà il seguente ciclo di vita:

1. Si verifica l'evento **EVENT_BEFORE_VALIDATE**. Se il metodo restituisce `false` o **Yii \ base \ ModelEvent :: $ isValid** è `false`, il resto dei passaggi verrà ignorato.
2. Esegue la convalida dei dati. Se la convalida dei dati fallisce, i passaggi successivi al passaggio 3 verranno saltati.
3. Si verifica l'evento **EVENT_AFTER_VALIDATE**.
4. Si verifica l'evento **EVENT_BEFORE_INSERT** o **EVENT_BEFORE_UPDATE**. Se il metodo restituisce `false` o **Yii \ base \ ModelEvent :: $ isValid** è `false`, il resto dei passaggi verrà ignorato.
5. Esegue l'inserimento o l'aggiornamento dei dati effettivi.
6. Si verifica l'evento **EVENT_AFTER_INSERT** o **EVENT_AFTER_UPDATE**.


***Eliminazione del ciclo di vita sui dati richiesti***


Quando si chiama il metodo **delete()** per eliminare un'istanza di Active Record, si verificherà il seguente ciclo di vita:

1. Si verifica l'evento **EVENT_BEFORE_DELETE**. Se il metodo restituisce `false` o **Yii \ base \ ModelEvent :: $ isValid** è `false`, il resto dei passaggi verrà ignorato.
2. Esegue la cancellazione effettiva dei dati.
3. Si verifica l'evento **EVENT_AFTER_DELETE**.

!!!Warning
    La chiamata a uno dei seguenti metodi NON avvierà nessuno dei suddetti cicli di vita perché funzionano direttamente sul database e non su base record:

        - ***Yii \ db \ ActiveRecord :: updateAll()***
        - ***Yii \ db \ ActiveRecord :: CancTutti()***
        - ***Yii \ db \ ActiveRecord :: updateCounters()***
        - ***Yii \ db \ ActiveRecord :: updateAllCounters()***


***Refresh del ciclo di vita sui dati richiesti***

Quando si chiama il metodo **refresh()** per aggiornare un'istanza dell'Active Record, l' evento **EVENT_AFTER_REFRESH** viene attivato se l'aggiornamento ha esito positivo e il metodo restituisce `true`.


##Lavorare con le transazioni


Esistono due modi per utilizzare le transazioni mentre si lavora con l'Active Record.

Il primo modo è di includere esplicitamente le chiamate al metodo Active Record in un blocco transazionale, come mostrato di seguito,

    $customer = Customer::findOne(123);

    Customer::getDb()->transaction(function($db) use ($customer) {
        $customer->id = 200;
        $customer->save();
        // ...other DB operations...
    });

    // or alternatively

    $transaction = Customer::getDb()->beginTransaction();
    try {
        $customer->id = 200;
        $customer->save();
        // ...other DB operations...
        $transaction->commit();
    } catch(\Exception $e) {
        $transaction->rollBack();
        throw $e;
    } catch(\Throwable $e) {
        $transaction->rollBack();
        throw $e;
    }

!!!Warning
    Nel codice precedente abbiamo due blocchi di try - catch per la compatibilità con PHP 5.x e PHP 7.x. `\Exception` implementa l'interfaccia  `\Throwable` da PHP 7.0, quindi puoi saltare la parte `\Exceptions` e la tua app utilizza solo PHP 7.0 e versioni successive.

Il secondo modo è elencare le operazioni DB che richiedono il supporto transazionale nel metodo **yii \ db \ ActiveRecord :: transactions()**. Per esempio,

    class Customer extends ActiveRecord{

        public function transactions(){

            return [
                'admin' => self::OP_INSERT,
                'api' => self::OP_INSERT | self::OP_UPDATE | self::OP_DELETE,
                // the above is equivalent to the following:
                // 'api' => self::OP_ALL,
            ];
        }
    }

Il metodo **yii \ db \ ActiveRecord :: transactions()** dovrebbe restituire un array le cui chiavi sono nomi di scenario e i valori sono le operazioni corrispondenti che devono essere racchiuse tra le transazioni. È necessario utilizzare le seguenti costanti per fare riferimento a diverse operazioni DB:

- **OP_INSERT**: operazione di inserimento eseguita dal metodo **insert()**;
- **OP_UPDATE**: operazione di aggiornamento eseguita dal metodo **update()**;
- **OP_DELETE**: operazione di cancellazione eseguita dal metodo **delete()**.

Gli operatori `|` vengono usati per concatenare le costanti sopra indicate e anche per indicare più operazioni. È inoltre possibile utilizzare la costante di scelta rapida **OP_ALL** per fare riferimento a tutte e tre le operazioni precedenti.

Le transazioni create utilizzando questo metodo verranno avviate prima di chiamare **beforeSave()** e verranno eseguite dopo l'esecuzione di **afterSave()**.


##Optimistic Locks


Il blocco ottimistico ( o optimistic locks ) è un modo per prevenire i conflitti che possono verificarsi quando una singola riga di dati viene aggiornata da più utenti. Ad esempio, sia l'utente A che l'utente B stanno modificando lo stesso articolo wiki allo stesso tempo. Dopo che l'utente A ha salvato le sue modifiche, l'utente B fa clic sul pulsante "Salva" nel tentativo di salvare anche le sue modifiche. Poiché l'utente B stava effettivamente lavorando su una versione obsoleta dell'articolo, sarebbe auspicabile avere un modo per impedirgli di salvare l'articolo e mostrargli un messaggio di suggerimento.

L'optimistic locks risolve il problema precedente utilizzando una colonna per registrare il numero di versione di ogni riga. Quando una riga viene salvata con un numero di versione obsoleto, verrà generata un'eccezione **yii \ db \ StaleObjectException**, che impedisce il salvataggio della riga. L'optimistic locks è supportato solo quando si aggiorna o si elimina una riga di dati esistente utilizzando **yii \ db \ ActiveRecord :: update()** o **yii \ db \ ActiveRecord :: delete()**.

Per utilizzarel'optimistic locks dobbiamo:

- Creare una colonna nella tabella DB associata alla classe dell'Active Record, per memorizzare il numero di versione di ogni riga. La colonna dovrebbe essere di tipo "big integer" (in MySQL sarebbe `BIGINT DEFAULT 0`).
- Sostituire il metodo **yii \ db \ ActiveRecord :: optimisticLock()** per restituire il nome di questa colonna.
- Nel modulo Web che accetta gli input dell'utente, aggiungere un campo nascosto per memorizzare il numero di versione corrente della riga in aggiornamento. Assicurati che l'attributo della versione contenga regole di convalida dell'input e convalidi correttamente.
- Nell'azione del controller che aggiorna la riga utilizzando l'Active Record, prova a rilevare l' eccezione **yii \ db \ StaleObjectException**. Implementare la logica aziendale necessaria (ad esempio unire le modifiche, richiamando i dati staled) per risolvere il conflitto.

Ad esempio, supponi che la colonna della versione sia nominata come `version`. È possibile implementare il blocco ottimistico con il codice come il seguente.

    // ------ view code -------

    use yii\helpers\Html;

    // ...other input fields
    echo Html::activeHiddenInput($model, 'version');


    // ------ controller code -------

    use yii\db\StaleObjectException;

    public function actionUpdate($id){

        $model = $this->findModel($id);

        try {
            if ($model->load(Yii::$app->request->post()) && $model->save()) {
                return $this->redirect(['view', 'id' => $model->id]);
            } else {
                return $this->render('update', [
                    'model' => $model,
                ]);
            }
        } catch (StaleObjectException $e) {
            // logic to resolve the conflict
        }
    }


##Lavorare con i dati relazionali


Oltre a lavorare con le singole tabelle del database, l'Active Record è anche in grado di riunire i dati correlati, rendendoli facilmente accessibili attraverso i dati primari. Ad esempio, i dati del cliente sono correlati ai dati dell'ordine poiché un cliente potrebbe aver effettuato uno o più ordini. Con un'adeguata dichiarazione di questa relazione, sarete in grado di accedere alle informazioni sull'ordine di un cliente utilizzando l'espressione `$customer->orders` che restituisce le informazioni sull'ordine del cliente in termini di una serie di instanze `Order` dell'Active Record.


##Dichiarare le relazioni


Per lavorare con i dati relazionali utilizzando l'Active Record, è necessario innanzitutto dichiarare le relazioni nelle classi dell'Active Record. Il compito è semplice come dichiarare un metodo di relazione per ogni relazione interessata, come il seguente,

    class Customer extends ActiveRecord{

        // ...

        public function getOrders(){

            return $this->hasMany(Order::className(), ['customer_id' => 'id']);
        }
    }

    class Order extends ActiveRecord{

        // ...

        public function getCustomer(){

            return $this->hasOne(Customer::className(), ['id' => 'customer_id']);
        }
    }

Nel codice precedente, abbiamo dichiarato una relazione `orders` per la classe `Customer` e una relazione `customer` per la classe `Order`.

Ogni metodo di relazione deve essere nominato come `getXyz`. Chiamiamo `xyz`(la prima lettera è in minuscolo) il nome della relazione. Nota che i nomi delle relazioni sono case sensitive .

Durante la dichiarazione di una relazione, è necessario specificare le seguenti informazioni:

- la molteplicità della relazione: specificata chiamando i metodi **hasMany()** o **hasOne()**. Nell'esempio sopra puoi leggere facilmente nelle dichiarazioni di relazione che un cliente ha molti ordini mentre un ordine ha un solo cliente.
- il nome della classe Active Record correlata: specificato come primo parametro su **hasMany()** o **hasOne()**. Si consiglia di chiamare `Xyz::className()` per ottenere la stringa del nome della classe in modo da poter ricevere il supporto per il completamento automatico IDE e il rilevamento degli errori in fase di compilazione.
- il collegamento tra i due tipi di dati: specifica le colonne attraverso le quali i due tipi di dati sono correlati. I valori dell'array sono le colonne dei dati primari (rappresentati dalla classe Active Record che stai dichiarando nelle relazioni), mentre le chiavi dell'array sono le colonne dei dati correlati.

Una regola facile da ricordare è, come vedi nell'esempio sopra, che scrivi la colonna che appartiene al relativo Active Record direttamente accanto ad essa. Vedi lì che `customer_id` è una proprietà di `Order` ed `id` è una proprietà di `Customer`.


##Accesso ai dati relazionali


Dopo aver dichiarato le relazioni, puoi accedere ai dati relazionali attraverso i loro nomi. Questo è come accedere a una proprietà dell'oggetto definita dal metodo di una relazione. Per questo motivo, lo chiamiamo "proprietà relazionale". Per esempio,

    // SELECT * FROM `customer` WHERE `id` = 123
    $customer = Customer::findOne(123);

    // SELECT * FROM `order` WHERE `customer_id` = 123
    // $orders is an array of Order objects
    $orders = $customer->orders;

!!!Info
    Quando dichiari una relazione denominata `xyz` tramite un metodo getter `getXyz()`, sarai in grado di accedere `xyz` come una proprietà dell'oggetto . Si noti che il nome è case sensitive.

Se una relazione è dichiarata con **hasMany()**, l'accesso a questa proprietà di relazione restituirà una matrice delle istanze relative all'Active Record;se una relazione viene dichiarata con il metodo **hasOne()**, l'accesso alla proprietà della relazione restituirà l'istanza relativa all'Active Record o  valore `null` se non viene trovato alcun dato correlato.

Quando si accede a una proprietà di relazione per la prima volta, verrà eseguita un'istruzione SQL, come mostrato nell'esempio precedente. Se si accede nuovamente alla stessa proprietà, il risultato precedente verrà restituito senza rieseguire l'istruzione SQL. Per forzare la ri-esecuzione dell'istruzione SQL, è necessario eliminare la proprietà: `unset($customer->orders)`.

!!!Nota
    Sebbene questo concetto sia simile alla funzione della proprietà dell'oggetto, esiste una differenza importante. Per le normali proprietà il valore della proprietà è dello stesso tipo del metodo getter definitivo. Un metodo di relazione tuttavia restituisce un'istanza **yii \ db \ ActiveQuer**, mentre l'accesso a una proprietà di relazione restituirà un'istanza **yii \ db \ ActiveRecord** o una matrice di questi.

    $customer->orders; // is an array of `Order` objects
    $customer->getOrders(); // returns an ActiveQuery instance

Questo è utile per creare query personalizzate, come descritto nella prossima sezione.


##Query con relazioni dinamiche


Poiché un metodo di relazione restituisce un'istanza di **yii \ db \ ActiveQuery**, è possibile creare ulteriormente questa query utilizzando i metodi di creazione di query prima di eseguire la query DB. Per esempio,

    $customer = Customer::findOne(123);

    // SELECT * FROM `order` WHERE `customer_id` = 123 AND `subtotal` > 200 ORDER BY `id`
    $orders = $customer->getOrders()
        ->where(['>', 'subtotal', 200])
        ->orderBy('id')
        ->all();

Ogni volta che si esegue una query relazionale dinamica tramite un metodo di relazione, verrà eseguita un'istruzione SQL, anche se prima veniva eseguita la stessa query relazionale dinamica.

A volte potresti persino voler parametrizzare una dichiarazione di relazione in modo da poter eseguire più facilmente query relazionali dinamiche. Ad esempio, puoi dichiarare una relazione `bigOrders` come segue,

    class Customer extends ActiveRecord{

        public function getBigOrders($threshold = 100){

            return $this->hasMany(Order::className(), ['customer_id' => 'id'])
                ->where('subtotal > :threshold', [':threshold' => $threshold])
                ->orderBy('id');
        }
    }

Quindi sarai in grado di eseguire le seguenti query relazionali:

    // SELECT * FROM `order` WHERE `customer_id` = 123 AND `subtotal` > 200 ORDER BY `id`
    $orders = $customer->getBigOrders(200)->all();

    // SELECT * FROM `order` WHERE `customer_id` = 123 AND `subtotal` > 100 ORDER BY `id`
    $orders = $customer->bigOrders;


##Relazioni tramite una Junction Table


Nella modellazione di database, quando la molteplicità tra due tabelle correlate è molti-a-molti, viene generalmente introdotta una tabella di giunzione . Ad esempio, la order tabel e la item tabel possono essere correlate tramite una tabella di giunzione denominata `order_item`. Un ordine corrisponderà quindi a più articoli dell'ordine, mentre un articolo prodotto corrisponderà anche a più articoli dell'ordine.

Quando si dichiarano tali relazioni, si può chiamare **via()** o **viaTabella()** per specificare la tabella di giunzione. La differenza tra **via()** e **viaTable()** è che il primo specifica la tabella di congiunzione in termini di un nome di relazione esistente, mentre il secondo utilizza direttamente la tabella di giunzione. Per esempio,

    class Order extends ActiveRecord{
    
    public function getItems(){

            return $this->hasMany(Item::className(), ['id' => 'item_id'])
                ->viaTable('order_item', ['order_id' => 'id']);
        }
    }

o in alternativa,

    class Order extends ActiveRecord{

        public function getOrderItems(){

            return $this->hasMany(OrderItem::className(), ['order_id' => 'id']);
        }

        public function getItems(){

            return $this->hasMany(Item::className(), ['id' => 'item_id'])
                ->via('orderItems');
        }
    }

L'uso delle relazioni dichiarate con una tabella di giunzione è uguale a quello delle relazioni normali. Per esempio,

    // SELECT * FROM `order` WHERE `id` = 100
    $order = Order::findOne(100);

    // SELECT * FROM `order_item` WHERE `order_id` = 100
    // SELECT * FROM `item` WHERE `item_id` IN (...)
    // returns an array of Item objects
    $items = $order->items;


##Concatenare le definizioni delle relazioni tramite più tabelle


È inoltre possibile definire le relazioni tramite più tabelle concatenando le definizioni di relazione usando il metodo **via()**. Considerando gli esempi precedenti, abbiamo classi `Customer`, `Order` e `Item`. Possiamo aggiungere una relazione alla classe `Customer` che elenca tutti gli articoli da tutti gli ordini che hanno inserito e nominarla `getPurchasedItems()`, il concatenamento delle relazioni è mostrato nel seguente esempio di codice:

    class Customer extends ActiveRecord{

        // ...

        public function getPurchasedItems(){

            // customer's items, matching 'id' column of `Item` to 'item_id' in OrderItem
            return $this->hasMany(Item::className(), ['id' => 'item_id'])
                        ->via('orderItems');
        }

        public function getOrderItems(){

            // customer's order items, matching 'id' column of `Order` to 'order_id' in OrderItem
            return $this->hasMany(OrderItem::className(), ['order_id' => 'id'])
                        ->via('orders');
        }

        public function getOrders(){

            // same as above
            return $this->hasMany(Order::className(), ['customer_id' => 'id']);
        }
    }


##Lazy Loading e Eager Loading


IN precedenza, quando abbiamo parlato all'accesso ai dati relazionali, abbiamo spiegato che è possibile accedere a una proprietà di relazione di un'istanza dell'Active Record come l'accesso a una normale proprietà dell'oggetto. Un'istruzione SQL verrà eseguita solo quando si accede alla proprietà della relazione la prima volta. Chiamiamo questo tipo di dati relazionali che accedono al metodo di "caricamento lazy". Per esempio,

    // SELECT * FROM `customer` WHERE `id` = 123
    $customer = Customer::findOne(123);

    // SELECT * FROM `order` WHERE `customer_id` = 123
    $orders = $customer->orders;

    // no SQL executed
    $orders2 = $customer->orders;

Il caricamento lento è molto comodo da usare. Tuttavia, potrebbe verificarsi un problema di prestazioni quando è necessario accedere alla stessa proprietà di relazione in più istanze dell'Active Record. Considera il seguente esempio di codice. Quante istruzioni SQL saranno eseguite?

    // SELECT * FROM `customer` LIMIT 100
    $customers = Customer::find()->limit(100)->all();

    foreach ($customers as $customer) {
        // SELECT * FROM `order` WHERE `customer_id` = ...
        $orders = $customer->orders;
    }

Come puoi vedere dal commento del codice sopra, ci sono 101 istruzioni SQL in esecuzione! Questo perché ogni volta che si accede alla proprietà di relazione `orders` di un oggetto `Customer` diverso nel ciclo for, verrà eseguita un'istruzione SQL.

Per risolvere questo problema di prestazioni, è possibile utilizzare il cosiddetto "Eager Loading" come mostrato di seguito,

    // SELECT * FROM `customer` LIMIT 100;
    // SELECT * FROM `orders` WHERE `customer_id` IN (...)
    $customers = Customer::find()
        ->with('orders')
        ->limit(100)
        ->all();

    foreach ($customers as $customer) {
        // no SQL executed
        $orders = $customer->orders;
    }

Chiamando **yii \ db \ ActiveQuery :: with()**, si istruisce l'Active Record per riportare gli ordini per i primi 100 clienti in una singola istruzione SQL. Di conseguenza, riduci il numero delle istruzioni SQL eseguite da 101 a 2!

Puoi caricare avidamente una o più relazioni. Puoi anche caricare avidamente relazioni nidificate. Una relazione nidificata è una relazione dichiarata all'interno di una classe Active Record correlata. Ad esempio, `Customer` è correlato con `Order` attraverso la relazione `orders` ed `Order` è correlato con `Item` attraverso la relazione `items`. Quando si esegue una query per `Customer`, è possibile caricare `items` con impazienza utilizzando la notazione della relazione nidificata `orders.items`.

Il seguente codice mostra l'uso differente di **with()**. Assumiamo che la classe `Customer` abbia due relazioni `orders` e `country`, mentre la classe `Order` ha una relazione `items`.

    // eager loading both "orders" and "country"
    $customers = Customer::find()->with('orders', 'country')->all();
    // equivalent to the array syntax below
    $customers = Customer::find()->with(['orders', 'country'])->all();
    // no SQL executed 
    $orders= $customers[0]->orders;
    // no SQL executed 
    $country = $customers[0]->country;

    // eager loading "orders" and the nested relation "orders.items"
    $customers = Customer::find()->with('orders.items')->all();
    // access the items of the first order of the first customer
    // no SQL executed
    $items = $customers[0]->orders[0]->items;
    
Puoi caricare le relazioni in modo eagerly in modo annidato, come ad esempio `a.b.c.d`. Cioè, quando si chiama **with()** utilizzando `a.b.c.d`, avrai un caricamento lento come segue: `a`, `a.b`, `a.b.c` e `a.b.c.d`.

!!!Info
    In generale, quando si caricano in modo "eagerly (aviademnte) le `N` relazioni tra le quali le `M` relazioni vengono definite con una tabella di giunzione, `N+M+1` verrà eseguito un numero totale di istruzioni SQL. Si noti che una relazione nidificata `a.b.c.d` conta come 4 relazioni.

Quando si carica in modo eagerly una relazione, è possibile personalizzare la query relazionale corrispondente utilizzando una funzione anonima. Per esempio,

    // find customers and bring back together their country and active orders
    // SELECT * FROM `customer`
    // SELECT * FROM `country` WHERE `id` IN (...)
    // SELECT * FROM `order` WHERE `customer_id` IN (...) AND `status` = 1
    $customers = Customer::find()->with([
        'country',
        'orders' => function ($query) {
            $query->andWhere(['status' => Order::STATUS_ACTIVE]);
        },
    ])->all();

Quando si personalizza la query relazionale per una relazione, è necessario specificare il nome della relazione come chiave di array e utilizzare una funzione anonima come valore dell'array corrispondente. La funzione anonima riceverà un parametro `$query` che rappresenta l'oggetto **yii \ db \ ActiveQuery** utilizzato per eseguire la query relazionale per la relazione. Nell'esempio di codice sopra, stiamo modificando la query relazionale aggiungendo una condizione aggiuntiva sullo stato dell'ordine.

!!!Nota
    Se viene chiamato il metodo **select()**, dovete assicurarvi che le colonne referenziate nelle dichiarazioni di relazione siano selezionate. In caso contrario, i relativi modelli potrebbero non essere caricati correttamente. Per esempio,
        
        $orders = Order::find()->select(['id', 'amount'])->with('customer')->all();
        // $orders[0]->customer is always `null`. To fix the problem, you should do the following:
        $orders = Order::find()->select(['id', 'amount', 'customer_id'])->with('customer')->all();


##Joining with relations


!!!Nota
    Il contenuto descritto in questa sottosezione è applicabile solo ai database relazionali, come MySQL, PostgreSQL, ecc.

Le query relazionalali che abbiamo descritto finora fanno riferimento solo alle colonne della tabella principale quando si esegue una query per i dati primari. In realtà spesso è necessario fare riferimento alle colonne nelle tabelle correlate. Ad esempio, potremmo voler riportare i clienti che hanno almeno un ordine attivo. Per risolvere questo problema, possiamo creare una query di join come la seguente:

    // SELECT `customer`.* FROM `customer`
    // LEFT JOIN `order` ON `order`.`customer_id` = `customer`.`id`
    // WHERE `order`.`status` = 1
    // 
    // SELECT * FROM `order` WHERE `customer_id` IN (...)
    $customers = Customer::find()
        ->select('customer.*')
        ->leftJoin('order', '`order`.`customer_id` = `customer`.`id`')
        ->where(['order.status' => Order::STATUS_ACTIVE])
        ->with('orders')
        ->all();

!!!Nota        
    E' importante togliere l'ambiguità ai nomi delle colonne quando si creano query relazionali che coinvolgono istruzioni SQL `JOIN`. Una pratica comune è di anteporre i nomi delle colonne ai loro nomi di tabelle corrispondenti.

Tuttavia, un approccio migliore è quello di sfruttare le dichiarazioni di relazione esistenti chiamando **yii \ db \ ActiveQuery :: joinWith()**:

    $customers = Customer::find()
        ->joinWith('orders')
        ->where(['order.status' => Order::STATUS_ACTIVE])
        ->all();

Entrambi gli approcci eseguono lo stesso insieme di istruzioni SQL. Quest'ultimo approccio è molto più pulito e asciutto, però.

Per impostazione predefinita, nel metodo **joinWith()** verrà utilizzato il comando `LEFT JOIN` per unirsi alla tabella primaria con la tabella correlata. È possibile specificare un tipo di join diverso (ad esempio `RIGHT JOIN`) tramite il terzo parametro `$joinType`. Se il tipo di join desiderato è `INNER JOIN`, puoi semplicemente chiamare il metodo **innerJoinWith()**.

Chiamare **joinWith()** caricherà avidamente i dati relativi per impostazione predefinita. Se non vuoi inserire i dati relativi, puoi specificare il suo secondo parametro `$eagerLoading` a `false`.

!!!Nota
    Anche quando si utilizza **joinWith()** o **innerJoinWith()** con l'eager loading attivato, i dati correlati non verranno popolati dal risultato della query `JOIN`. Quindi c'è ancora una query aggiuntiva per ogni relazione unita.

Come con il metodo **with()**, puoi unirti a una o più relazioni; puoi personalizzare le query di relazione al volo; puoi unirti a relazioni nidificate; e puoi mescolare l'uso di **with()** e **joinWith()**. Per esempio,

    $customers = Customer::find()->joinWith([
        'orders' => function ($query) {
            $query->andWhere(['>', 'subtotal', 100]);
        },
    ])->with('country')
        ->all();
        
A volte quando si uniscono due tabelle, potrebbe essere necessario specificare alcune condizioni aggiuntive nella parte `ON` della query `JOIN`. Questo può essere fatto chiamando il metodo **yii \ db \ ActiveQuery :: onCondition()** come il seguente:

    // SELECT `customer`.* FROM `customer`
    // LEFT JOIN `order` ON `order`.`customer_id` = `customer`.`id` AND `order`.`status` = 1 
    // 
    // SELECT * FROM `order` WHERE `customer_id` IN (...)
    $customers = Customer::find()->joinWith([
        'orders' => function ($query) {
            $query->onCondition(['order.status' => Order::STATUS_ACTIVE]);
        },
    ])->all();

Questa query sopra riportata riporta tutti i clienti e per ogni cliente riporta tutti gli ordini attivi. Si noti che questo differisce dal nostro esempio precedente che riporta solo i clienti che hanno almeno un ordine attivo.

!!!Info
    Quando **yii \ db \ ActiveQuery** viene specificato con una condizione tramite il metodo **onCondition()**, la condizione verrà inserita nella parte `ON` se la query implica una query `JOIN`. Se la query non coinvolge un `JOIN`, la condizione `on` verrà automaticamente aggiunta alla parte `WHERE` della query. Pertanto può contenere solo condizioni comprese tra le colonne della tabella correlata.


##Alias della tabella nelle relazioni


Come notato in precedenza, quando si utilizza `JOIN` in una query, è necessario distinguere i nomi delle colonne. Per questo un alias è definito per una tabella. Impostare un alias per la query relazionale sarebbe possibile personalizzando la query di relazione nel seguente modo:

    $query->joinWith([
        'orders' => function ($q) {
            $q->from(['o' => Order::tableName()]);
        },
    ])

Ciò sembra molto complicato e comporta l'hardcoding del nome della tabella degli oggetti correlati o delle chiamate `Order::tableName()`. Dalla versione 2.0.7, Yii fornisce una scorciatoia per questo. Ora puoi definire e utilizzare l'alias per la tabella delle relazioni come segue:

    // join the orders relation and sort the result by orders.id
    $query->joinWith(['orders o'])->orderBy('o.id');

La sintassi precedente funziona per relazioni semplici. Se hai bisogno di un alias per una tabella intermedia quando ti unisci alle relazioni annidate [`$query->joinWith(['orders.product'])`], per esempio, puoi nidificare le chiamate **joinWith** come nell'esempio seguente:

    $query->joinWith(['orders o' => function($q) {
            $q->joinWith('product p');
        }])
        ->where('o.amount > 100');


##Relazioni inverse


Le dichiarazioni di relazione sono spesso reciproche tra due classi Active Record. Ad esempio, `Customer` è correlato a `Order` tramite la relazione `orders` ed `Order` è correlato a `Customer` tramite la relazione `customer`.

    class Customer extends ActiveRecord{
        public function getOrders(){

            return $this->hasMany(Order::className(), ['customer_id' => 'id']);
        }
    }

    class Order extends ActiveRecord{

        public function getCustomer(){

            return $this->hasOne(Customer::className(), ['id' => 'customer_id']);
        }
    }

Ora considera il seguente pezzo di codice:

    // SELECT * FROM `customer` WHERE `id` = 123
    $customer = Customer::findOne(123);

    // SELECT * FROM `order` WHERE `customer_id` = 123
    $order = $customer->orders[0];

    // SELECT * FROM `customer` WHERE `id` = 123
    $customer2 = $order->customer;

    // displays "not the same"
    echo $customer2 === $customer ? 'same' : 'not the same';

A questo punto, penseremmo che `$customer` e `$customer2` siano uguali, ma non lo sono! In realtà contengono gli stessi dati dei clienti, ma sono oggetti diversi. Durante l'accesso `$order->customer`, viene eseguita un'istruzione SQL aggiuntiva per popolare un nuovo oggetto `$customer2`.

Per evitare l'esecuzione ridondante dell'ultima istruzione SQL nell'esempio precedente, dovremmo dire a Yii che `customer` è una relazione inversa di `orders` chiamando il metodo **inverseOf()** come mostrato di seguito:

    class Customer extends ActiveRecord{

        public function getOrders(){

            return $this->hasMany(Order::className(), ['customer_id' => 'id'])->inverseOf('customer');
        }
    }

Con questa dichiarazione di relazione modificata, avremo:

    // SELECT * FROM `customer` WHERE `id` = 123
    $customer = Customer::findOne(123);

    // SELECT * FROM `order` WHERE `customer_id` = 123
    $order = $customer->orders[0];

    // No SQL will be executed
    $customer2 = $order->customer;

    // displays "same"
    echo $customer2 === $customer ? 'same' : 'not the same';

!!!Nota    
    Le relazioni inverse non possono essere definite relazioni che coinvolgono una junction table. Cioè, se una relazione è definita con il metodo **via()** o **viaTable()**, non c'è bisogno di chiamare il metodo **inverseOf()**.


##Salvataggio delle relazioni


Quando si lavora con dati relazionali, è spesso necessario stabilire relazioni tra dati diversi o distruggere relazioni esistenti. Ciò richiede l'impostazione di valori appropriati per le colonne che definiscono le relazioni. Usando Active Record, potresti finire per scrivere il codice come segue:

    $customer = Customer::findOne(123);
    $order = new Order();
    $order->subtotal = 100;
    // ...

    // setting the attribute that defines the "customer" relation in Order
    $order->customer_id = $customer->id;
    $order->save();

Active Record fornisce il metodo **link()** che consente di svolgere questo compito in modo più efficace:

    $customer = Customer::findOne(123);
    $order = new Order();
    $order->subtotal = 100;
    // ...

    $order->link('customer', $customer);

Il metodo **link()** richiede di specificare il nome della relazione e l'istanza dell'Active Record di destinazione con cui deve essere stabilita la relazione. Il metodo modificherà i valori degli attributi che collegano due istanze Active Record e li salvano nel database. Nell'esempio sopra, imposterà l'attributo `customer_id` dell'istanza `Order` come valore dell'attributio `id` dell'istanza `Customer` e quindi lo salverà nel database.

!!!Nota
    Non è possibile collegare due istanze Active Record appena create.

Il vantaggio dell'uso del metodo **link()** è ancora più evidente quando una relazione viene definita tramite una tabella di giunzione. Ad esempio, è possibile utilizzare il codice seguente per collegare un'istanza `Order` con un'istanza `Item`:

    $order->link('items', $item);

Il codice scritto sopra inserirà automaticamente una riga nella tabella di giunzione `order_item` per mettere in relazione l'ordine con l'articolo.

!!!Info
    Il metodo **link()** NON esegue alcuna convalida dei dati durante il salvataggio dell'istanza Active Record interessata. È tua responsabilità convalidare qualsiasi dato di input prima di chiamare questo metodo.

L'operazione opposta a **link()** è **unlink()** che interrompe una relazione esistente tra due istanze Active Record. Per esempio,

    $customer = Customer::find()->with('orders')->where(['id' => 123])->one();
    $customer->unlink('orders', $customer->orders[0]);

Per impostazione predefinita, il metodo **unlink()** imposterà i valori della chiave esterna che specificano la relazione esistente a `null`. Tuttavia, è possibile scegliere di eliminare la riga della tabella che contiene il valore della chiave esterna passando il parametro `$delete` con valore `true` al metodo.

Quando una tabella di giunzione è coinvolta in una relazione, la chiamata di **unlink()** provoca la cancellazione delle chiavi esterne nella tabella di giunzione o la cancellazione della riga corrispondente nella tabella di giuntura, se il valore di `$delete` è `true`.


##Relazioni tra database


Active Record consente di dichiarare le relazioni tra classi Active Record alimentate da diversi database. I database possono essere di tipi diversi (ad esempio MySQL e PostgreSQL, o MS SQL e MongoDB) e possono essere eseguiti su server diversi. È possibile utilizzare la stessa sintassi per eseguire query relazionali. Per esempio,

    // Customer is associated with the "customer" table in a relational database (e.g. MySQL)
    class Customer extends \yii\db\ActiveRecord{

        public static function tableName(){

            return 'customer';
        }

        public function getComments(){

            // a customer has many comments
            return $this->hasMany(Comment::className(), ['customer_id' => 'id']);
        }
    }

    // Comment is associated with the "comment" collection in a MongoDB database
    class Comment extends \yii\mongodb\ActiveRecord{

        public static function collectionName(){

            return 'comment';
        }

        public function getCustomer(){

            // a comment has one customer
            return $this->hasOne(Customer::className(), ['id' => 'customer_id']);
        }
    }

    $customers = Customer::find()->with('comments')->all();

È possibile utilizzare la maggior parte delle funzioni di query relazionali descritte in questa sezione.

!!!Nota     
    L'utilizzo del metodo **joinWith()** è limitato ai database che consentono query `JOIN` tra database. Per questo motivo, non è possibile utilizzare questo metodo nell'esempio precedente poiché MongoDB non supporta la `JOIN`.


##Personalizzazione delle classi di query


Per impostazione predefinita, tutte le query degli Active Record sono supportate da **yii \ db \ ActiveQuery**. Per utilizzare una classe di query personalizzata in una classe Active Record, è necessario eseguire l'override del metodo **yii \ db \ ActiveRecord :: find()** e restituire un'istanza della classe di query personalizzata. Per esempio,

    // file Comment.php
    namespace app\models;

    use yii\db\ActiveRecord;

    class Comment extends ActiveRecord{

        public static function find(){

            return new CommentQuery(get_called_class());
        }
    }

Ora, quando si esegue una query (ad esempio **find()**, **findOne()**) o si definisce una relazione (ad esempio **hasOne()**) la classe `Comment`, si chiamerà un'istanza `CommentQuery` anziché `ActiveQuery`.

Ora devi definire la classe `CommentQuery`, che può essere personalizzata in molti modi creativi per migliorare la tua esperienza nella creazione di query. Per esempio,

    // file CommentQuery.php
    namespace app\models;

    use yii\db\ActiveQuery;

    class CommentQuery extends ActiveQuery{

        // conditions appended by default (can be skipped)
        public function init(){

            $this->andOnCondition(['deleted' => false]);
            parent::init();
        }

        // ... add customized query methods here ...

        public function active($state = true){

            return $this->andOnCondition(['active' => $state]);
        }
    }

!!!Nota    
    Invece di chiamare **onCondition()**, di solito si dovrebbe chiamare il metodo **andOnCondition()** o **orOnCondition()** per aggiungere ulteriori condizioni al momento di definire nuovi metodi di costruzione di query in modo che le eventuali condizioni esistenti non vengono sovrascritti.

Questo ti permette di scrivere il codice di costruzione della query come il seguente:

    $comments = Comment::find()->active()->all();
    $inactiveComments = Comment::find()->active(false)->all();

!!!Tip    
    Nei progetti di grandi dimensioni, si consiglia di utilizzare classi di query personalizzate per conservare la maggior parte del codice relativo alle query in modo che le classi Active Record possano essere mantenute pulite.

È inoltre possibile utilizzare i nuovi metodi di creazione di query quando si definiscono relazioni `Comment` e si esegue una query relazionale:

    class Customer extends \yii\db\ActiveRecord{

        public function getActiveComments(){

            return $this->hasMany(Comment::className(), ['customer_id' => 'id'])->active();
        }
    }

    $customers = Customer::find()->joinWith('activeComments')->all();

    // or alternatively
    class Customer extends \yii\db\ActiveRecord{

        public function getComments(){

            return $this->hasMany(Comment::className(), ['customer_id' => 'id']);
        }
    }

    $customers = Customer::find()->joinWith([
        'comments' => function($q) {
            $q->active();
        }
    ])->all();

!!!Info    
    In Yii 1.1, c'è un concetto chiamato **scope** . L'ambito non è più supportato direttamente in Yii 2.0 e per raggiungere lo stesso obiettivo è necessario utilizzare classi di query e metodi di query personalizzati.


##Selezione di campi aggiuntivi


Quando l'istanza Active Record viene popolata dai risultati della query, i relativi attributi vengono riempiti dai corrispondenti valori di colonna dal set di dati ricevuti.

È possibile recuperare ulteriori colonne o valori dalla query e memorizzarli all'interno dell'Active Record. Ad esempio, supponiamo di avere una tabella di nome `room`, che contiene informazioni sulle camere disponibili nell'hotel. Ogni camera memorizza le informazioni sulle sue dimensioni geometriche utilizzando i campi `length`, `width`, `height`. Immagina di dover recuperare l'elenco di tutte le stanze disponibili con il loro volume in ordine discendente. Quindi non puoi calcolare il volume usando PHP, perché abbiamo bisogno di ordinare i record in base al suo valore, ma tu vuoi anche che il volume possa essere visualizzato nella lista. Per raggiungere l'obiettivo, è necessario dichiarare un campo aggiuntivo nella classe `Room` Active Record,che memorizzerà il valore `volume`:

    class Room extends \yii\db\ActiveRecord
    {
        public $volume;

        // ...
    }

Quindi è necessario comporre una query, che calcola il volume della stanza ed esegue l'ordinamento:

    $rooms = Room::find()
        ->select([
            '{{room}}.*', // select all columns
            '([[length]] * [[width]] * [[height]]) AS volume', // calculate a volume
        ])
        ->orderBy('volume DESC') // apply sort
        ->all();

    foreach ($rooms as $room) {
        echo $room->volume; // contains value calculated by SQL
    }

La possibilità di selezionare campi aggiuntivi può essere eccezionalmente utile per le query di aggregazione. Supponiamo di dover visualizzare un elenco di clienti con il conteggio degli ordini effettuati. Prima di tutto, è necessario dichiarare una classe `Customer` con una relazione `orders` e campo aggiuntivo per la memorizzazione dei conteggi:

    class Customer extends \yii\db\ ActiveRecord{

        public $ordersCount;

        // ...

        public function getOrders(){

            return $this->hasMany(Order::className(), ['customer_id' => 'id']);
        }
    }

Quindi puoi comporre una query, che unisce gli ordini e calcola il loro conteggio:

    $customers = Customer::find()
        ->select([
            '{{customer}}.*', // select all customer fields
            'COUNT({{order}}.id) AS ordersCount' // calculate orders count
        ])
        ->joinWith('orders') // ensure table junction
        ->groupBy('{{customer}}.id') // group the result to ensure aggregation function works
        ->all();

Uno svantaggio dell'utilizzo di questo metodo sarebbe che, se l'informazione non è caricata nella query SQL, deve essere calcolata separatamente. Pertanto, se hai trovato record particolari tramite query regolari senza istruzioni select extra, non sarà in grado di restituire il valore effettivo per il campo extra. Lo stesso accadrà per il record appena salvato.

    $room = new Room();
    $room->length = 100;
    $room->width = 50;
    $room->height = 2;

$   room->volume; // this value will be `null`, since it was not declared yet

Usando i metodi magici `__get()` e `__set()` possiamo emulare il comportamento di una proprietà:

    class Room extends \yii\db\ActiveRecord{

        private $_volume;
    
        public function setVolume($volume){

            $this->_volume = (float) $volume;
        }
    
        public function getVolume(){

            if (empty($this->length) || empty($this->width) || empty($this->height)) {
                return null;
            }
        
            if ($this->_volume === null) {
                $this->setVolume(
                    $this->length * $this->width * $this->height
                );
            }
        
            return $this->_volume;
        }

        // ...
    }

Quando la query di selezione non fornisce il volume, il modello sarà in grado di calcolarlo automaticamente utilizzando gli attributi del modello.

Puoi anche calcolare i campi di aggregazione usando le relazioni definite:

    class Customer extends \yii\db\ActiveRecord{

        private $_ordersCount;

        public function setOrdersCount($count){

            $this->_ordersCount = (int) $count;
        }

        public function getOrdersCount(){

            if ($this->isNewRecord) {
                return null; // this avoid calling a query searching for null primary keys
            }

            if ($this->_ordersCount === null) {
                $this->setOrdersCount($this->getOrders()->count()); // calculate aggregation on demand from relation
            }

            return $this->_ordersCount;
        }

        // ...

        public function getOrders(){

            return $this->hasMany(Order::className(), ['customer_id' => 'id']);
        }
    }

Con questo codice, nel caso in cui `'ordersCount'` sia presente nell'istruzione `'select' - Customer::ordersCount`, verrà popolato dai risultati dell'interrogazione, altrimenti verrà calcolato su richiesta utilizzando la relazione `Customer::orders`.

Questo approccio può essere utilizzato anche per la creazione delle scorciatoie per alcuni dati relazionali, in particolare per l'aggregazione. Per esempio:

    class Customer extends \yii\db\ActiveRecord{

        /**
        * Defines read-only virtual property for aggregation data.
        */
        public function getOrdersCount(){

            if ($this->isNewRecord) {
                return null; // this avoid calling a query searching for null primary keys
            }
        
            return empty($this->ordersAggregation) ? 0 : $this->ordersAggregation[0]['counted'];
        }

        /**
        * Declares normal 'orders' relation.
        */
        public function getOrders(){

            return $this->hasMany(Order::className(), ['customer_id' => 'id']);
        }

        /**
        * Declares new relation based on 'orders', which provides aggregation.
        */
        public function getOrdersAggregation(){

            return $this->getOrders()
                ->select(['customer_id', 'counted' => 'count(*)'])
                ->groupBy('customer_id')
                ->asArray(true);
        }

        // ...
    }   

    foreach (Customer::find()->with('ordersAggregation')->all() as $customer) {
        echo $customer->ordersCount; // outputs aggregation data from relation without extra query due to eager loading
    }

    $customer = Customer::findOne($pk);
    $customer->ordersCount; // output aggregation data from lazy loaded relation

