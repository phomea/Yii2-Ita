#Accesso ai dati tramite oggetti


Costruito su PDO , Yii DAO (Database Access Objects) fornisce un'API orientata agli oggetti per l'accesso ai database relazionali. È la base per altri metodi di accesso al database più avanzati, tra cui il generatore di query e l'Active Record.

Quando si utilizza Yii DAO, si ha principalmente bisogno di gestire semplici SQL e array PHP. Di conseguenza, è il modo più efficiente per accedere ai database. Tuttavia, poiché la sintassi SQL può variare per diversi database, l'uso di Yii DAO significa anche che è necessario uno sforzo maggiore per creare un'applicazione indipendente dal database.

Yii DAO supporta i seguenti database:

- MySQL
- MariaDB
- SQLite
- PostgreSQL: versione 8.4 o superiore
- CUBRID: verisone 9.3 o superiore
- Oracle
- MSSQL: versione 2008 o superiore

!!!Nota
    La nuova versione di pdo_oci per PHP 7 attualmente esiste solo come codice sorgente. Seguire le istruzioni fornite dalla comunità per compilarlo o utilizzare il livello di emulazione PDO.


##Creazione di connesisoni DB


Per accedere a un database, è innanzitutto necessario connettersi ad esso creano un'istanza di **yii \ db \ Connection ::**:

    $db = new yii\db\Connection([
        'dsn' => 'mysql:host=localhost;dbname=example',
        'username' => 'root',
        'password' => '',
        'charset' => 'utf8',
    ]);

Poichè è spesso necessario accedere a una connessione DB in luoghi diversi del nostro progetto, è prassi comune configurarla in termini di un componente dell'applicazione, come il seguente:

    return [
        // ...
        'components' => [
            // ...
            'db' => [
                'class' => 'yii\db\Connection',
                'dsn' => 'mysql:host=localhost;dbname=example',
                'username' => 'root',
                'password' => '',
                'charset' => 'utf8',
            ],
        ],
        // ...
    ];

E' quindi possibile accedere alla connessione DB tramite l'espressione `Yii::$app->db`.

!!!Tip
    E' possibile configurare più componenti dell'applicazione DB se l'applicazione deve accedere a più database.

Quando si configura una connessione DB, è necessario specificare sempre il suo Database Source Name (DSN) tramite la proprietà `dsn`. Il formato di DSN varia per diversi database. Di seguito sono riportati alcuni esempi:

- MySQL, MariaDB: `mysql:host=localhost;dbname=mydatabase`
- SQLite: `sqlite:/path/to/database/file`
- PostgreSQL: `pgsql:host=localhost;port=5432;dbname=mydatabase`
- cubrid: `cubrid:dbname=demodb;host=localhost;port=33000`
- MS SQL Server (tramite driver sqlsrv): `sqlsrv:Server=localhost;Database=mydatabase`
- MS SQL Server (tramite driver dblib): `dblib:host=localhost;dbname=mydatabase`
- MS SQL Server (tramite driver mssql): `mssql:host=localhost;dbname=mydatabase`
- Oracle: `oci:dbname=//localhost:1521/mydatabase`

Si noti che se ci si connette a un database tramite ODBC, è necessario configurare la proprietà **yii \ db \ Connection :: driverName** in modo che Yii possa conoscere il tipo di database effettivo. Per esempio,

    'db' => [
        'class' => 'yii\db\Connection',
        'driverName' => 'mysql',
        'dsn' => 'odbc:Driver={MySQL};Server=localhost;Database=test',
        'username' => 'root',
        'password' => '',
    ],

Oltre alla prorpietà `dsn`, è spesso necessario configurare nome utente e password per accedervi.

!!!Tip
    A volte potresti voler eseguire alcune query subito dopo aver stabilito la connessione al database per inizializzare alcune variabili di ambiente (ad esempio, per impostare il fuso orario o il set di caratteri). È possibile farlo registrando un gestore di eventi per l' evento `afterOpen` nella connessione al database. Puoi registrare il gestore direttamente nella configurazione dell'applicazione in questo modo:

        'db' => [
            // ...
            'on afterOpen' => function($event) {
                // $event->sender refers to the DB connection
                $event->sender->createCommand("SET time_zone = 'UTC'")->execute();
            }
        ],


##Esecuzione di query SQL


Una volta che si dispone di un'istanza di connessione al database, è possibile eseguire una query SQL effettuando le seguenti operazioni:

1. Creare un comando ** yii \ db** con una semplice query SQL;
2. Parametri di binding (opzionale)
3. Chiama uno dei metodi di esecuzione SQL in *** yii \ db \ Command ***.

L'esempio seguente mostra vari modi di recuperare i dati da un database:

    // return a set of rows. each row is an associative array of column names and values.
    // an empty array is returned if the query returned no results
    $posts = Yii::$app->db->createCommand('SELECT * FROM post')
                ->queryAll();

    // return a single row (the first row)
    // false is returned if the query has no result
    $post = Yii::$app->db->createCommand('SELECT * FROM post WHERE id=1')
               ->queryOne();

    // return a single column (the first column)
    // an empty array is returned if the query returned no results
    $titles = Yii::$app->db->createCommand('SELECT title FROM post')
                 ->queryColumn();

    // return a scalar value
    // false is returned if the query has no result
    $count = Yii::$app->db->createCommand('SELECT COUNT(*) FROM post')
                 ->queryScalar();


##Parametri Bindings


Quando si crea un comando DB da un SQL con parametri, si dovrebbe quasi sempre utilizzare l'approccio dei parametri di binding per prevenire attacchi di SQL injection. Per esempio,

    $post = Yii::$app->db->createCommand('SELECT * FROM post WHERE id=:id AND status=:status')
               ->bindValue(':id', $_GET['id'])
               ->bindValue(':status', 1)
               ->queryOne();

Nell'istruzione SQL, è possibile incorporare uno o più segnaposti dei parametri (ad esempio :`id` nell'esempio precedente). Un segnaposto di parametro dovrebbe essere una stringa che inizia con due punti. È quindi possibile chiamare uno dei seguenti metodi di associazione dei parametri per associare i valori dei parametri:

- **bindValue()**: associa un valore di parametro singolo
- **bindValues()**: associa più valori di parametro in una chiamata
- **bindParam()**: simile a **binadValue()** ma supporta anche i riferimenti ai parametri di bind.

L'esempio seguente mostra metodi alternativi per i parametri di binding:

    $params = [':id' => $_GET['id'], ':status' => 1];

    $post = Yii::$app->db->createCommand('SELECT * FROM post WHERE id=:id AND status=:status')
               ->bindValues($params)
               ->queryOne();
           
    $post = Yii::$app->db->createCommand('SELECT * FROM post WHERE id=:id AND status=:status', $params)

Il binding dei parametri viene implementato tramite dichiarazioni preparate. Oltre a prevenire attacchi di SQL injection, può anche migliorare le prestazioni preparando una dichiarazione SQL una volta e eseguendola più volte con parametri diversi. Per esempio,

    $command = Yii::$app->db->createCommand('SELECT * FROM post WHERE id=:id');

    $post1 = $command->bindValue(':id', 1)->queryOne(); 
    $post2 = $command->bindValue(':id', 2)->queryOne();
    // ...

Poichè **bindParam()** supporta i parametri di associazione per riferimento, il codice precedente può anche essere scritto come segue:

    $command = Yii::$app->db->createCommand('SELECT * FROM post WHERE id=:id')
                  ->bindParam(':id', $id);

    $id = 1;
    $post1 = $command->queryOne();

    $id = 2;
    $post2 = $command->queryOne();
    // ...

Si noti che si lega il segnaposto alla variabile `$id` prima dell'esecuzione e quindi si modifica il valore di tale variabile prima di ogni esecuzione successiva (spesso con loop). L'esecuzione di query in questo modo può essere notevolmente più efficiente rispetto all'esecuzione di una nuova query per ogni valore di parametro diverso.

!!!Info
    Il collegamento dei parametri viene utilizzato solo in luoghi in cui è necessario inserire valori in stringhe che contengono SQL semplice. In molti posti in livelli di astrazione più alti, come il generatore di query e l'Active Record, si specifica spesso una serie di valori che verranno trasformati in SQL. In questi punti il ​​binding dei parametri viene eseguito internamente da Yii, quindi non è necessario specificare i parametri manualmente.


##Esecuzione di query non SELECT


I metodi `queryXyz()` introdotti nelle sezioni precedenti riguardano tutti le query SELECT che prelevano i dati dai database. Per le query che non restituiscono dati, è necessario chiamare invece il metodo **yii \ db \ Command :: execute()**. Per esempio,

    Yii::$app->db->createCommand('UPDATE post SET status=1 WHERE id=1')
    ->execute();

Il metodo **yii \ db \ Command :: execute()** restituisce il numero di righe interessate dall'esecuzione SQL.

Per le query INSERT, UPDATE e DELETE, invece di scrivere semplici SQL, è possibile chiamare **insert()**, **update()** , **delete()**, per creare gli SQL corrispondenti. Questi metodi indicheranno correttamente i nomi di tabelle e colonne e i valori dei parametri di bind. Per esempio,

    // INSERT (table name, column values)
    Yii::$app->db->createCommand()->insert('user', [
        'name' => 'Sam',
        'age' => 30,
    ])->execute();

    // UPDATE (table name, column values, condition)
    Yii::$app->db->createCommand()->update('user', ['status' => 1], 'age > 30')->execute();

    // DELETE (table name, condition)
    Yii::$app->db->createCommand()->delete('user', 'status = 0')->execute();

Puoi anche chiamare **batchInsert()** per inserire più righe in un colpo, che è molto più efficiente dell'inserimento di una riga per volta:

    // table name, column names, column values
    Yii::$app->db->createCommand()->batchInsert('user', ['name', 'age'], [
        ['Tom', 30],
        ['Jane', 20],
        ['Linda', 25],
    ])->execute();

Nota che i metodi sopra menzionati creano solo la query e devi sempre richiamare il metodo **execute()** per eseguirli.


##Citazione dei noim relativi a tabelle e colonne


Durante la scrittura di codice indipendente dal database, la citazione corretta dei nomi di tabelle e colonne è spesso un problema perché diversi database hanno regole di quoting diverse. Per superare questo problema, è possibile utilizzare la seguente sintassi di citazione introdotta da Yii:

- `[[column name]]`: racchiude il nome di una colonna da citare tra parentesi quadre;
- `{{table name}}`: racchiude il nome di una tabella da quotare tra parentesi graffe doppie.

Yii DAO convertirà automaticamente tali costrutti nella colonna o nei nomi di tabella citati corrispondenti, utilizzando la sintassi specifica DBMS. Per esempio,

    // executes this SQL for MySQL: SELECT COUNT(`id`) FROM `employee`
    $count = Yii::$app->db->createCommand("SELECT COUNT([[id]]) FROM {{employee}}")
                ->queryScalar();


##Utilizzo del prefisso tabella


Se la maggior parte dei nomi delle tabelle DB condivide un prefisso comune, è possibile utilizzare la funzione **tablePrefix** fornita da Yii DAO.

Per prima cosa, specifica il prefisso della tabella tramite la proprietà **yii \ db \ Connection :: $ tablePrefix** nella configurazione dell'applicazione:

    return [
        // ...
        'components' => [
            // ...
            'db' => [
                // ...
                'tablePrefix' => 'tbl_',
            ],
        ],
    ];

Quindi nel codice, ogni volta che è necessario fare riferimento a una tabella il cui nome contiene tale prefisso, utilizzare la sintassi `{{%table_name}}`. Il carattere percentuale verrà automaticamente sostituito con il prefisso tabella specificato durante la configurazione della connessione DB. Per esempio,

    // executes this SQL for MySQL: SELECT COUNT(`id`) FROM `tbl_employee`
    $count = Yii::$app->db->createCommand("SELECT COUNT([[id]]) FROM {{%employee}}")
                ->queryScalar();


##Esecuzione di transazioni


Quando si eseguono più query correlate in una sequenza, potrebbe essere necessario includerle in una transazione per garantire l'integrità e la coerenza del database. Se una qualsiasi delle query non riesce, il database verrà riportato allo stato come se nessuna di queste query fosse stata eseguita.

Il codice seguente mostra un modo tipico di utilizzare le transazioni:

    Yii::$app->db->transaction(function($db) {
        $db->createCommand($sql1)->execute();
        $db->createCommand($sql2)->execute();
        // ... executing other SQL statements ...
    });

Il codice riportato sopra è equivalente al seguente, che offre un maggior controllo sul codice gestendo gli errori:

    $db = Yii::$app->db;
    $transaction = $db->beginTransaction();
    try {
        $db->createCommand($sql1)->execute();
        $db->createCommand($sql2)->execute();
        // ... executing other SQL statements ...
    
        $transaction->commit();
    } catch(\Exception $e) {
        $transaction->rollBack();
        throw $e;
    } catch(\Throwable $e) {
        $transaction->rollBack();
        throw $e;
    }

Chiamando il metodo **beginTransaction()**, viene avviata una nuova transazione. La transazione è rappresentata come un oggetto ***yii \ db \ Transaction*** memorizzato nella variabile `$transaction`. Quindi, le query eseguite sono racchiuse in un blocco `try...catch...`. Se tutte le query vengono eseguite correttamente, il metodo ***commit()*** viene chiamato per eseguire il commit della transazione. Altrimenti, se verrà attivata e rilevata un'eccezione , viene chiamato il metodo **rollBack()** per eseguire il rollback delle modifiche apportate dalle query prima di quella query non riuscita nella transazione `throw $`. Quindi rilanciamo l'eccezione come se non l'avessimo catturata, e a questo punto il normale processo di gestione degli errori si prenderà cura di esso.

!!!Warning
    Nel codice precedente abbiamo due blocchi di cattura per la compatibilità con PHP 5.x e PHP 7.x. `\Exception` implementa l'interfaccia `\Throwable` da PHP 7.0, quindi puoi saltare la parte `\Exceptions` e la tua app utilizza solo PHP 7.0 e versioni successive.


##Specifica dei livelli di isolamento


Yii supporta anche l'impostazione dei livelli di isolamento per le tue transazioni. Per impostazione predefinita, quando si avvia una nuova transazione, verrà utilizzato il livello di isolamento predefinito impostato dal sistema di database. È possibile sovrascrivere il livello di isolamento predefinito come segue,

    $isolationLevel = \yii\db\Transaction::REPEATABLE_READ;

    Yii::$app->db->transaction(function ($db) {
        ....
    }, $isolationLevel);
 
    // or alternatively

    $transaction = Yii::$app->db->beginTransaction($isolationLevel);

Yii fornisce quattro costranti per i livelli di isolamento più comuni:

- **yii \ db \ Transaction :: READ_UNCOMMITTED** - il livello più debole. Possono esserci letture sporche o letture non ripetibili.
- **yii \ db \ Transaction ::READ_COMMITTED** - evita le letture sporche.
- **yii \ db \ Transaction :: REPETABLE_READ** - evita le letture sporche e letture non ripetibili.
- **yii \ db \ Transction :: SERIALIZABLE** - il livello più forte, evita tutti i problemi sopra citati.

Oltre a utilizzare le costanti sopra indicate per specificre i livelli di isolamento, è possibile utilizzare anche stringhe con una sintassi valida supportata dal DBMS che si sta utilizzando. Ad esempio, in PostgreSQL, puoi usare `"SERIALIZABLE READ ONLY DEFERRABLE"`.

Si noti che alcuni DBMS consentono di impostare il livello di isolamento solo per l'intera connessione. Qualsiasi transazione successiva otterrà lo stesso livello di isolamento anche se non ne specifichiamo altre. Quando si utilizza questa funzione, potrebbe essere necessario impostare il livello di isolamento per tutte le transazioni in modo esplicito per evitare impostazioni in conflitto. Al momento della stesura di questo limite, solo MSSQL e SQLite sono interessati da questa limitazione.

!!!Warning
    SQLite supporta solo due livelli di isolamento, quindi è possibile utilizzare solo `READ UNCOMMITTED` e `SERIALIZABLE`. L'utilizzo di altri livelli si tradurrà in un'eccezione generata.

!!!Nota
    PostgreSQL non consente di impostare il livello di isolamento prima dell'inizio della transazione, quindi non è possibile specificare direttamente il livello di isolamento quando si avvia la transazione. Devi chiamare **yii \ db \ Transaction :: setIsolationLevel()** in questo caso dopo l'avvio della transazione.


##Annidamento delle transazioni


Se il DBMS supporta Savepoint, è possibile nidificare più transazioni come le seguenti:

    Yii::$app->db->transaction(function ($db) {
        // outer transaction
    
        $db->transaction(function ($db) {
            // inner transaction
        });
    });

O in alternativa,

    $db = Yii::$app->db;
    $outerTransaction = $db->beginTransaction();
    try {
        $db->createCommand($sql1)->execute();

        $innerTransaction = $db->beginTransaction();
        try {
            $db->createCommand($sql2)->execute();
            $innerTransaction->commit();
        } catch (\Exception $e) {
            $innerTransaction->rollBack();
            throw $e;
        } catch (\Throwable $e) {
            $innerTransaction->rollBack();
            throw $e;
        }

        $outerTransaction->commit();
    } catch (\Exception $e) {
        $outerTransaction->rollBack();
        throw $e;
    } catch (\Throwable $e) {
        $outerTransaction->rollBack();
        throw $e;


## Duplicazione e divisione tra lettura / scrittura


Molti DBMS supportano la replica del database per ottenere una migliore disponibilità del database e tempi di risposta del server più rapidi. Con la replica del database, i dati vengono replicati dai cosiddetti server master ai server slave . Tutte le scritture e gli aggiornamenti devono essere eseguiti sui server master, mentre le letture possono anche avvenire sui server slave.

Per sfruttare la replica del database e ottenere la divisione read-write, è possibile configurare un componente **yii \ db \ Connection** come il seguente:

    [
        'class' => 'yii\db\Connection',

        // configuration for the master
        'dsn' => 'dsn for master server',
        'username' => 'master',
        'password' => '',

        // common configuration for slaves
        'slaveConfig' => [
            'username' => 'slave',
            'password' => '',
            'attributes' => [
                // use a smaller connection timeout
                PDO::ATTR_TIMEOUT => 10,
            ],
        ],

        // list of slave configurations
        'slaves' => [
            ['dsn' => 'dsn for slave server 1'],
            ['dsn' => 'dsn for slave server 2'],
            ['dsn' => 'dsn for slave server 3'],
            ['dsn' => 'dsn for slave server 4'],
        ],
    ]

La configurazione scritta sopra, specifica un'impostazione con un singolo master e più slave. Uno degli slave verrà connesso e utilizzato per eseguire query di lettura, mentre il master verrà utilizzato per eseguire query di scrittura. Tale suddivisione in lettura-scrittura viene eseguita automaticamente con questa configurazione. Per esempio,

    // create a Connection instance using the above configuration
    Yii::$app->db = Yii::createObject($config);

    // query against one of the slaves
    $rows = Yii::$app->db->createCommand('SELECT * FROM user LIMIT 10')->queryAll();

    // query against the master
    Yii::$app->db->createCommand("UPDATE user SET username='demo' WHERE id=1")->execute();

!!!Info
    Le query eseguite chiamando **yii \ db \ Command :: execute()** sono considerate query di scrittura, mentre tutte le altre query eseguite tramite uno dei metodi "query" di **yii \ db \ Command** sono query di lettura. È possibile ottenere la connessione slave attualmente attiva tramite `Yii::$app->db->slave`.

Il componente `Connection` supporta il bilanciamento del carico e il failover tra slave. Quando si esegue una query di lettura per la prima volta, il componente `Connection` sceglierà in modo casuale uno slave e prova a connettersi ad esso. Se lo slave viene trovato "morto" (cioè non dà nessuna risposta), ne prova un altro. Se nessuno degli slave è disponibile, si collegherà al master. Configurando una cache di stato del server, un server "morto" può essere ricordato in modo che non venga più provato durante un certo periodo di tempo .

E' inoltre possibile configurare più master con più slave. Per esempio:

    [
        'class' => 'yii\db\Connection',

        // common configuration for masters
        'masterConfig' => [
            'username' => 'master',
            'password' => '',
            'attributes' => [
                // use a smaller connection timeout
                PDO::ATTR_TIMEOUT => 10,
            ],
        ],

        // list of master configurations
        'masters' => [
            ['dsn' => 'dsn for master server 1'],
            ['dsn' => 'dsn for master server 2'],
        ],

        // common configuration for slaves
        'slaveConfig' => [
            'username' => 'slave',
            'password' => '',
            'attributes' => [
                // use a smaller connection timeout
                PDO::ATTR_TIMEOUT => 10,
            ],
        ],

        // list of slave configurations
        'slaves' => [
            ['dsn' => 'dsn for slave server 1'],
            ['dsn' => 'dsn for slave server 2'],
            ['dsn' => 'dsn for slave server 3'],
            ['dsn' => 'dsn for slave server 4'],
        ],

La configurazione soprastante specifica due master e quattro slave. Il componente `Connection` supporta anche il bilanciamento del carico e il failover tra i master esattamente come avviene tra gli slave. Una differenza è che quando nessuno dei master è disponibile viene lanciata un'eccezione.

!!!Warning
    Quando si utilizza le proprietà per configurare uno o più master, tutte le altre proprietà per la specifica di una connessione al database (ad esempio dsn, username, password) con l'oggetto stesso `Connection` verrà ignorato.

Per impostazione predefinita, le transazioni utilizzano la connessione principale. E all'interno di una transazione, tutte le operazioni DB utilizzeranno la connessione principale. Per esempio,

    $db = Yii::$app->db;
    // the transaction is started on the master connection
    $transaction = $db->beginTransaction();

    try {
        // both queries are performed against the master
        $rows = $db->createCommand('SELECT * FROM user LIMIT 10')->queryAll();
        $db->createCommand("UPDATE user SET username='demo' WHERE id=1")->execute();

        $transaction->commit();
    } catch(\Exception $e) {
        $transaction->rollBack();
        throw $e;
    } catch(\Throwable $e) {
        $transaction->rollBack();
        throw $e;
    }

Se si desidera avviare una transazione con la connessione slave, è necessario farlo in modo esplicito. Come il seguente:

    $transaction = Yii::$app->db->slave->beginTransaction();

A volte, potresti voler forzare l'uso della connessione principale per eseguire una query di lettura. Questo può essere ottenuto con il metodo `useMaster()`:

    $rows = Yii::$app->db->useMaster(function ($db) {
        return $db->createCommand('SELECT * FROM user LIMIT 10')->queryAll();
    });

Si può anche impostare direttamente `Yii::$app->db.>enableSlaves` di essere a `false` a indirizzare tutte le query al collegamento master.


##Lavorare con lo schema del proprio database


Yii DAO fornisce un intero set di metodi per consentire la manipolazione dello schema del database, come la creazione di nuove tabelle, il rilascio di una colonna da una tabella, ecc. Questi metodi sono elencati come segue:

- **createTable()**: creazione di una tabella;
- **renameTable()**: rinomina una tabella;
- **dropTable()**: rimozione di una tabella;
- **truncateTable()**: rimuove tutte le righe in una tabella;
- **addColumn()**: aggiunta di una colonna;
- **renameColumn()**: rinomina una colonna;
- **dropColumn()**: rimuovendo una colonna;
- **alterColumn()**: modifica di una colonna;
- **addPrimaryKey()**: aggiunta di una chiave primaria;
- **dropPrimaryKey()**: rimozione di una chiave primaria;
- **addForeignKey()**: aggiunta di una chiave esterna;
- **dropForeignKey()**: rimozione di una chiave esterna;
- **createIndex()**: creazione di un indice;
- **dropIndex()**: rimozione di un indice.

Questi metodi possono essere utilizzati come i seguenti:

    // CREATE TABLE
    Yii::$app->db->createCommand()->createTable('post', [
        'id' => 'pk',
        'title' => 'string',
        'text' => 'text',
    ]);

L'array sopra descritto descrive il nome e i tipi delle colonne da creare. Per i tipi di colonna, Yii fornisce un set di tipi di dati astratti, che consentono di definire uno schema agnostico del database. Questi vengono convertiti in definizioni accessibili dal DBMS dipendente dal database.

Oltre a modificare lo schema del database, è anche possibile recuperare le informazioni sulla definizione di una tabella tramite il metodo **getTableSchema()** di una connessione DB. Per esempio,

    $table = Yii::$app->db->getTableSchema('post');

Il metodo restituisce un oggetto **yii \ db \ TableSchema** che contiene le informazioni sulle colonne della tabella, le chiavi primarie, le chiavi esterne e così via. Tutte queste informazioni sono principalmente utilizzate dal generatore di query e dall'Active Record per consentire la scrittura del codice agnostico del database.


