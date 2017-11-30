#Migrazione del Database


Durante lo sviluppo e il mantenimento di un'applicazione basata su database, la struttura del database in uso si evolve proprio come fa il codice sorgente. Ad esempio, durante lo sviluppo di un'applicazione, possiamo aver bisogno di una nuova tabella; dopo che l'applicazione è stata distribuita in produzione, è possibile che venga creato un indice per migliorare le prestazioni della query; e così via. Poiché una modifica della struttura del database richiede spesso alcune modifiche al codice sorgente, Yii supporta la cosiddetta funzione di migrazione del database che consente di tenere traccia delle modifiche del database in termini di migrazioni del database controllate dalla versione insieme al codice sorgente.

Le seguenti fasi mostrano come la migrazione del database può essere utilizzata da un team durante lo sviluppo:

1. Luca crea una nuova migrazione (ad esempio crea una nuova tabella, cambia una definizione di colonna, ecc.).
2. Luca usa la nuova migrazione nel sistema di controllo del codice sorgente (es. Git, Mercurial).
3. Andrea aggiorna il suo repository dal sistema di controllo del codice sorgente e riceve la nuova migrazione.
4. Andrea applica la migrazione al suo database di sviluppo locale, sincronizzando così il suo database per riflettere le modifiche apportate da Tim.

E i seguenti passaggi mostrano come distribuire una nuova versione con le migrazioni del database alla produzione:

1. Scott crea un tag di rilascio per il repository del progetto che contiene alcune nuove migrazioni del database.
2. Scott aggiorna il codice sorgente sul server di produzione sul tag di rilascio.
3. Scott applica eventuali migrazioni di database accumulate al database di produzione.

Yii fornisce una serie di strumenti per la riga di comando di migrazione che consentono di:

- creare nuove migrazioni;
- applicare le migrazioni;
- ripristinare le migrazioni;
- riapplicare le migrazioni;
- mostra la cronologia e lo stato della migrazione.

Tutti questi strumenti sono accessibili tramite il comando `yii migrate`. In questa sezione descriveremo in dettaglio come eseguire varie attività utilizzando questi strumenti. È inoltre possibile ottenere l'utilizzo di ogni strumento tramite il comando di aiuto `yii help migrate`.

!!!Tip
    Le migrazioni potrebbero influire non solo sullo schema del database, ma anche sui dati esistenti per adattarsi al nuovo schema, creare la gerarchia RBAC o pulire la cache.


##Creazione di una migrazione


Per creare una nuova migrazione, eseguire il seguente comando:

    yii migrate/create <name>

L'argomento `name` richiesto fornisce una breve descrizione della nuova migrazione. Ad esempio, se la migrazione riguarda la creazione di una nuova tabella denominata `notizie`, è possibile utilizzare il nome `create_news_table` ed eseguire il seguente comando:

    yii migrate/create create_news_table

!!!Nota
    Poiché l'argomento `name` verrà utilizzato come parte del nome della classe di migrazione generato, dovrebbe contenere solo lettere, cifre e / o caratteri di sottolineatura.

Il comando precedente creerà un nuovo file di classe PHP chiamato `m150101_185401_create_news_table.php` nella `@app/migrationsdirectory`. Il file contiene il seguente codice che dichiara principalmente una classe di migrazione `m150101_185401_create_news_table` con il codice scheletro:

    <?php

    use yii\db\Migration;

    class m150101_185401_create_news_table extends Migration{

        public function up(){
            
        }

        public function down(){

            echo "m101129_185401_create_news_table cannot be reverted.\n";

            return false;
        }

        /*
        // Use safeUp/safeDown to run migration code within a transaction
        public function safeUp(){

        }

        public function safeDown(){

        }
        */
    }

Ogni migrazione del database è definita come una classe PHP che si estende da **yii \ db \ Migration**. Il nome della classe di migrazione viene generato automaticamente nel formato di `m<YYMMDD_HHMMSS>_<Name>`, dove

- `<YYMMDD_HHMMSS>` fa riferimento al datetime UTC in cui viene eseguito il comando di creazione della migrazione.
- `<Name>` è uguale al valore dell'argomento `name` che fornisci al comando.

Nella classe di migrazione, è previsto che si scriva codice nel metodo **up()** che apporta modifiche alla struttura del database. Si consiglia inoltre di scrivere il codice nel metodo **down()** per annullare le modifiche apportate da **up()**. Il metodo **up()** viene richiamato quando si aggiorna il database con questa migrazione, mentre il metodo **down()** viene richiamato quando si esegue il downgrade del database. Il codice seguente mostra come è possibile implementare la classe di migrazione per creare una tabella `news`:

    <?php

    use yii\db\Schema;
    use yii\db\Migration;

    class m150101_185401_create_news_table extends Migration{

        public function up(){

                $this->createTable('news', [
                'id' => Schema::TYPE_PK,
                'title' => Schema::TYPE_STRING . ' NOT NULL',
                'content' => Schema::TYPE_TEXT,
            ]);
        }

        public function down(){

            $this->dropTable('news');
        }
    }

!!!Info    
    Non tutte le migrazioni sono reversibili. Ad esempio, se il metodo **up()** elimina una riga di una tabella, potresti non essere in grado di recuperare questa riga nel metodo **down()**. A volte, potresti essere troppo pigro per implementare il metodo **down()**, perché non è molto comune ripristinare le migrazioni del database. In questo caso, è necessario tornare un valore `false` nel metodo **down()** per indicare che la migrazione non è reversibile.

La classe di migrazione di base **yii \ db \ Migration** espone una connessione al database tramite la proprietà `db`. È possibile utilizzarlo per manipolare lo schema del database utilizzando i metodi descritti in "Operazioni con lo schema del database".

Anziché utilizzare tipi fisici, durante la creazione di una tabella o colonna è necessario utilizzare i tipi astratti in modo che le migrazioni siano indipendenti da DBMS specifici. La classe **yii \ db \ Schema** definisce un insieme di costanti per rappresentare i tipi astratti supportati. Queste costanti sono denominate nel formato di `TYPE_<Name>`. Ad esempio, `TYPE_PK` si riferisce al tipo di chiave primaria auto-incrementale; `TYPE_STRING` si riferisce a un tipo di stringa. Quando una migrazione viene applicata a un determinato database, i tipi astratti verranno tradotti nei corrispondenti tipi fisici. Nel caso di MySQL, `TYPE_PK` verrà trasformato in `int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY`, mentre `TYPE_STRING`diventa `varchar(255)`.

È possibile aggiungere ulteriori vincoli quando si utilizzano i tipi astratti. Nell'esempio sopra, `NOT NULL` viene aggiunto a `Schema::TYPE_STRING` per specificare che la colonna non può essere `null`.

!!!Info
    La mappatura tra tipi astratti e tipi fisici è specificata dalla proprietà **$typeMap** in ogni clsse **QueryBuilder**.

Dalla versione 2.0.6, è possibile utilizzare il generatore di schemi appena introdotto che fornisce un modo più conveniente di definire lo schema di colonna. Quindi la migrazione sopra potrebbe essere scritta come la seguente:

    <?php

    use yii\db\Migration;

    class m150101_185401_create_news_table extends Migration{

        public function up(){

            $this->createTable('news', [
                'id' => $this->primaryKey(),
                'title' => $this->string()->notNull(),
                'content' => $this->text(),
            ]);
        }

        public function down(){

            $this->dropTable('news');
        }
    }

Un elenco di tutti i metodi disponibili per la definizione dei tipi di colonna è disponibile nella documentazione API di **yii \ db \ SchemaBuilderTrait**.


##Generare una migrazioni


La console di migrazione della versione 2.0.7 offre un modo conveniente per creare migrazioni.

Se il nome della migrazione è di un modulo speciale, ad esempio `create_xxx_table` o `drop_xxx_table` il file di migrazione generato conterrà codice aggiuntivo, in questo caso la creazione / eliminazione di tabelle. Di seguito sono descritte tutte le varianti di questa funzione.


##Creazione di una tabella


    yii migrate/create create_post_table

genera

    /**
    * Handles the creation for table `post`.
    */

    class m150811_220037_create_post_table extends Migration{

        /**
        * @inheritdoc
        */
        public function up(){

            $this->createTable('post', [
                'id' => $this->primaryKey()
            ]);
        }

        /**
        * @inheritdoc
        */
        public function down(){

            $this->dropTable('post');
        }
    }

Per creare subito i campi tabella, dobbiamo specificarli tramite l'opzione `--fields`.

    yii migrate/create create_post_table --fields="title:string,body:text"

genera

    /**
    * Handles the creation for table `post`.
    */
    class m150811_220037_create_post_table extends Migration{

        /**
        * @inheritdoc
        */
        public function up(){

            $this->createTable('post', [
                'id' => $this->primaryKey(),
                'title' => $this->string(),
                'body' => $this->text(),
            ]);
        }

        /**
        * @inheritdoc
        */
        public function down(){

            $this->dropTable('post');
        }
    }

È possibile specificare più parametri di campo.

    yii migrate/create create_post_table --fields="title:string(12):notNull:unique,body:text"

genera

    /**
     * Handles the creation for table `post`.
    */
    class m150811_220037_create_post_table extends Migration{

        /**
        * @inheritdoc
        */
        public function up(){

            $this->createTable('post', [
                'id' => $this->primaryKey(),
                'title' => $this->string(12)->notNull()->unique(),
                'body' => $this->text()
            ]);
        }

        /**
        * @inheritdoc
        */
        public function down(){

            $this->dropTable('post');
        }
    }

!!!Nota    
    La chiave primaria viene aggiunta automaticamente e viene denominata `id` per impostazione predefinita. Se vuoi usare un altro nome, puoi specificarlo esplicitamente `--fields="name:primaryKey"`.


##Chiavi esterne (foreign key)


Dal momento che 2.0.8 il generatore supporta chiavi esterne utilizzando la la chiave `foreignKey`.

    yii migrate/create create_post_table --fields="author_id:integer:notNull:foreignKey(user),category_id:integer:defaultValue(1):foreignKey,title:string,body:text"

genera

    /**
    * Handles the creation for table `post`.
    * Has foreign keys to the tables:
    *
    * - `user`
    * - `category`
    */
    class m160328_040430_create_post_table extends Migration{

        /**
        * @inheritdoc
        */
        public function up(){

            $this->createTable('post', [
                'id' => $this->primaryKey(),
                'author_id' => $this->integer()->notNull(),
                'category_id' => $this->integer()->defaultValue(1),
                'title' => $this->string(),
                'body' => $this->text(),
            ]);

            // creates index for column `author_id`
            $this->createIndex(
                'idx-post-author_id',
                'post',
                'author_id'
            );

            // add foreign key for table `user`
            $this->addForeignKey(
                'fk-post-author_id',
                'post',
                'author_id',
                'user',
                'id',
                'CASCADE'
            );

            // creates index for column `category_id`
            $this->createIndex(
                'idx-post-category_id',
                'post',
                'category_id'
            );

            // add foreign key for table `category`
            $this->addForeignKey(
                'fk-post-category_id',
                'post',
                'category_id',
                'category',
                'id',
                'CASCADE'
            );
        }

        /**
        * @inheritdoc
        */
        public function down(){

            // drops foreign key for table `user`
            $this->dropForeignKey(
                'fk-post-author_id',
                'post'
            );

            // drops index for column `author_id`
            $this->dropIndex(
                'idx-post-author_id',
                'post'
            );

            // drops foreign key for table `category`
            $this->dropForeignKey(
                'fk-post-category_id',
                'post'
            );  

            // drops index for column `category_id`
            $this->dropIndex(
                'idx-post-category_id',
                'post'
            );

            $this->dropTable('post');
        }
    }

La posizione della parola chiave `foreignKey` nella descrizione della colonna non modifica il codice generato. Questo significa:

- `author_id:integer:notNull:foreignKey(user)`
- `author_id:integer:foreignKey(user):notNull`
- `author_id:foreignKey(user):integer:notNull`

Tutti generano lo stesso codice.

La parola chiave `foreignKey` può prendere un parametro tra parentesi che sarà il nome della tabella correlata per la chiave esterna generata. Se non viene passato alcun parametro, il nome della tabella sarà dedotto dal nome della colonna.

Nell'esempio sopra `author_id:integer:notNull:foreignKey(user)` genererà una colonna denominata `author_id` con una chiave esterna per la tabella `user` mentre `category_id:integer:defaultValue(1):foreignKey` genererà una colonna `category_id` con una chiave esterna per la tabella `category`.

Dalla 2.0.11, la parola chiave `foreignKey` accetta un secondo parametro, separato da uno spazio bianco. Accetta il nome della colonna correlata per la chiave esterna generata. Se non viene passato nessun secondo parametro, il nome della colonna verrà recuperato dallo schema della tabella. Se non esiste uno schema, la chiave primaria non è impostata o è composta, e verrà utilizzato il nome predefinito `id`.


##Drop Table


    yii migrate/create drop_post_table --fields="title:string(12):notNull:unique,body:text"

genera

    class m150811_220037_drop_post_table extends Migration{

        public function up(){

            $this->dropTable('post');
        }

        public function down(){

            $this->createTable('post', [
                'id' => $this->primaryKey(),
                'title' => $this->string(12)->notNull()->unique(),
                'body' => $this->text()
            ]);
        }
    }


##Aggiungere una colonna


Se il nome della migrazione è del modulo, il contenuto del file `add_xxx_column_to_yyy_table` conterrà `addColumn` e le istruzioni necessarie `dropColumn`.

Per aggiungere una colonna:

    yii migrate/create add_position_column_to_post_table --fields="position:integer"

genera

    class m150811_220037_add_position_column_to_post_table extends Migration{

        public function up(){

            $this->addColumn('post', 'position', $this->integer());
        }

        public function down(){

            $this->dropColumn('post', 'position');
        }
    }

È possibile specificare più colonne come segue:

    yii migrate/create add_xxx_column_yyy_column_to_zzz_table --fields="xxx:integer,yyy:text"


##Drop Column


Se il nome della migrazione è del modulo, il contenuto del file `drop_xxx_column_from_yyy_table` conterrà `addColumn` e le istruzioni necessarie `dropColumn`.

    yii migrate/create drop_position_column_from_post_table --fields="position:integer"

genera

    class m150811_220037_drop_position_column_from_post_table extends Migration{

        public function up(){

            $this->dropColumn('post', 'position');
        }

        public function down(){

            $this->addColumn('post', 'position', $this->integer());
        }
    }


##Aggiungi tuan "Junction Table"


Se il nome della migrazione è nella forma `create_junction_table_for_xxx_and_yyy_tables` o `create_junction_xxx_and_yyy_tables`, significa che è necessario creare una tabella di collegamento.

    yii migrate/create create_junction_table_for_post_and_tag_tables --fields="created_at:dateTime"

genera

    /**
    * Handles the creation for table `post_tag`.
    * Has foreign keys to the tables:
    *
    * - `post`
    * - `tag`
    */
    class m160328_041642_create_junction_table_for_post_and_tag_tables extends Migration{

        /**
        * @inheritdoc
        */
        public function up(){

            $this->createTable('post_tag', [
                'post_id' => $this->integer(),
                'tag_id' => $this->integer(),
                'created_at' => $this->dateTime(),
            'PRIMARY KEY(post_id, tag_id)',
            ]); 

            // creates index for column `post_id`
            $this->createIndex(
                'idx-post_tag-post_id',
                'post_tag',
                'post_id'
            );

            // add foreign key for table `post`
            $this->addForeignKey(
                'fk-post_tag-post_id',
                'post_tag',
                'post_id',
                'post',
                'id',
                'CASCADE'
            );

            // creates index for column `tag_id`
            $this->createIndex(
                'idx-post_tag-tag_id',
                'post_tag',
                'tag_id'
            );

            // add foreign key for table `tag`
            $this->addForeignKey(
                'fk-post_tag-tag_id',
                'post_tag',
                'tag_id',
                'tag',
                'id',
                'CASCADE'
            );
        }

        /**
        * @inheritdoc
        */
        public function down(){

            // drops foreign key for table `post`
            $this->dropForeignKey(
                'fk-post_tag-post_id',
                'post_tag'
            );

            // drops index for column `post_id`
            $this->dropIndex(
                'idx-post_tag-post_id',
                'post_tag'
            );

            // drops foreign key for table `tag`
            $this->dropForeignKey(
                'fk-post_tag-tag_id',
            'post_tag'
            );  

            // drops index for column `tag_id`
            $this->dropIndex(
                'idx-post_tag-tag_id',
                'post_tag'
            );

            $this->dropTable('post_tag');
        }
    }

Nel caso in cui la tabella non sia definita nello schema o la chiave primaria non sia impostata o sia composta, viene utilizzato il nome predefinito `id`.


##Migrazioni transazionali


Durante l'esecuzione di migrazioni di DB complesse, è importante garantire che ogni migrazione abbia esito positivo o negativo nel suo insieme, in modo che il database possa mantenere integrità e coerenza. Per raggiungere questo obiettivo,si consiglia di includere le operazioni DB di ogni migrazione in una transazione .

Un modo ancora più semplice di implementare le migrazioni transazionali è inserire il codice di migrazione nei metodi **safeUp()** e **safeDown()**. Questi due metodi differiscono da **up()** e **down()** in quanto sono inclusi implicitamente in una transazione. Di conseguenza, se qualsiasi operazione in questi metodi fallisce, tutte le operazioni precedenti verranno automaticamente ripristinate.

Nell'esempio seguente, oltre a creare la tabella `news`, inseriamo anche una riga iniziale in questa tabella.

    <?php

    use yii\db\Migration;

    class m150101_185401_create_news_table extends Migration{

        public function safeUp(){

            $this->createTable('news', [
                'id' => $this->primaryKey(),
                'title' => $this->string()->notNull(),
                'content' => $this->text(),
            ]);

            $this->insert('news', [
                'title' => 'test 1',
                'content' => 'content 1',
            ]);
        }

        public function safeDown(){

            $this->delete('news', ['id' => 1]);
            $this->dropTable('news');
        }
    }

Si noti che di solito quando si eseguono più operazioni DB in **safeUp()**, è necessario invertire il loro ordine di esecuzione **safeDown()**. Nell'esempio sopra, prima creiamo la tabella e poi inseriamo una riga in **safeUp()**; mentre in **safeDown()** prima eliminiamo la riga e poi rilasciamo la tabella.

!!!Warning
    Non tutti i DBMS supportano le transazioni. E alcune query DB non possono essere inserite in una transazione. Per alcuni esempi, fai riferimento a commit impliciti. Se questo è il caso, dovresti comunque implementare **up()** e **down()**, invece.


##Metodi di accesso al database


La classe di migrazione di base **yii \ db \ Migration** fornisce un insieme di metodi per consentire l'accesso e la manipolazione dei database. È possibile che questi metodi vengano denominati in modo simile ai metodi DAO forniti dalla classe **yii \ db \ Command**. Ad esempio, il metodo **yii \ db \ Migration :: createTable()** consente di creare una nuova tabella, proprio come fa **yii \ db \ Command :: createTable()**.

Il vantaggio dell'utilizzo dei metodi forniti da **yii \ db \ Migration** è che non è necessario creare esplicitamente istanze **yii \ db \ Command** e l'esecuzione di ogni metodo mostrerà automaticamente messaggi utili che indicano quali operazioni di database sono eseguite e quanto tempo prendere.

Di seguito è riportato l'elenco di tutti questi metodi di accesso al database:

- **execute()**: esecuzione di un'istruzione SQL
- **insert()**: inserimento di una singola riga
- **batchInsert()**: inserimento di più righe
- **update()**: aggiornamento delle righe
- **delete()**: eliminazione di righe
- **createTable()**: creazione di una tabella
- **renameTable()**: rinomina una tabella
- **dropTable()**: rimozione di una tabella
- **truncateTable()**: rimuove tutte le righe in una tabella
- **addColumn()**: aggiunta di una colonna
- **renameColumn()**: rinomina una colonna
- **dropColumn()**: rimuovendo una colonna
- **alterColumn()**: modifica di una colonna
- **addPrimaryKey()**: aggiunta di una chiave primaria
- **dropPrimaryKey()**: rimozione di una chiave primaria
- **addForeignKey()**: aggiunta di una chiave esterna
- **dropForeignKey()**: rimozione di una chiave esterna
- **createIndex()**: creazione di un indice
- **dropIndex()**: rimozione di un indice
- **addCommentOnColumn()**: aggiunta di commenti alla colonna
- **dropCommentFromColumn()**: eliminazione del commento dalla colonna
- **addCommentOnTable()**: aggiunta di commenti alla tabella
- **dropCommentFromTable()**: eliminazione del commento dalla tabella

!!!Info
    **yii \ db \ Migration** non fornisce un metodo di query del database. Questo perché normalmente non è necessario visualizzare un messaggio aggiuntivo sul recupero dei dati da un database. È anche possibile utilizzare il potente generatore di query per creare ed eseguire query complesse. L'utilizzo di Query Builder in una migrazione potrebbe essere simile a questo:

        // update status field for all users
        foreach((new Query)->from('users')->each() as $user) {
            $this->update('users', ['status' => 1], ['id' => $user['id']]);
        }

!!!Nota
    Quando si manipolano i dati utilizzando una migrazione, è possibile che l'utilizzo delle classi Active Record, possa essere utile poiché parte della logica è già implementata lì. Tuttavia, tenere presente che, contrariamente al codice scritto nelle migrazioni, la cui natura è di rimanere costante per sempre, la logica dell'applicazione è soggetta a modifiche. Pertanto, quando si utilizza l'Active Record nel codice di migrazione, le modifiche apportate alla logica nel livello Active Record possono interrompere accidentalmente le migrazioni esistenti. Per questo motivo il codice di migrazione dovrebbe essere tenuto indipendente da altre logiche applicative come le classi di record attivi.


##Applicazione delle migrazioni


Per aggiornare un database alla sua ultima struttura, è necessario applicare tutte le nuove migrazioni disponibili utilizzando il seguente comando:

    yii migrate

Questo comando elencherà tutte le migrazioni che non sono state applicate finora. Se confermi di voler applicare queste migrazioni, eseguirà il metodo **up()** o **safeUp()** in ogni nuova classe di migrazione, una dopo l'altra, nell'ordine dei loro valori di timestamp. Se una qualsiasi delle migrazioni fallisce, il comando si chiude senza applicare il resto delle migrazioni.

!!!Tip
    Nel caso in cui tu non abbia una linea di comando sul tuo server puoi provare l' estensione della **web shell**.

Per ogni migrazione che è stata applicata correttamente, il comando inserirà una riga in una tabella di database chiamata `migration` per registrare l'applicazione corretta della migrazione. Ciò consentirà allo strumento di migrazione di identificare quali migrazioni sono state applicate e quali no.

!!!Info
    Lo strumento di migrazione crea automaticamente la tabella `migration` nel database specificato dall'opzione `db` del comando. Per impostazione predefinita, il database è specificato dal componente dell'applicazione `db`.

A volte, puoi solo applicare una o alcune nuove migrazioni, invece di tutte le migrazioni disponibili. È possibile farlo specificando il numero di migrazioni che si desidera applicare durante l'esecuzione del comando. Ad esempio, il seguente comando proverà ad applicare le successive tre migrazioni disponibili:

    yii migrate 3

È inoltre possibile specificare in modo esplicito una migrazione particolare a cui il database deve essere migrato utilizzando il migrate/tocomando in uno dei seguenti formati:

    yii migrate/to 150101_185401                      # using timestamp to specify the migration
    yii migrate/to "2015-01-01 18:54:01"              # using a string that can be parsed by strtotime()
    yii migrate/to m150101_185401_create_news_table   # using full name
    yii migrate/to 1392853618                         # using UNIX timestamp

Se sono presenti migrazioni non applicate precedenti a quella specificata, verranno tutte applicate prima che venga applicata la migrazione specificata.

Se la migrazione specificata è già stata applicata in precedenza, tutte le successive migrazioni applicate verranno ripristinate.


##Ripristino delle migrazioni


Per annullare una o più migrazioni precedentemente applicate, è possibile eseguire il seguente comando:

    yii migrate/down     # revert the most recently applied migration
    yii migrate/down 3   # revert the most 3 recently applied migrations

!!!Warning
    Non tutte le migrazioni sono reversibili. Il tentativo di annullare tali migrazioni causerà un errore e interromperà l'intero processo di ripristino.


##Ripristino delle migrazioni


Ripristinare le migrazioni significa innanzitutto ripristinare le migrazioni specificate e quindi applicare nuovamente. Questo può essere fatto come segue:

    yii migrate/redo        # redo the last applied migration
    yii migrate/redo 3      # redo the last 3 applied migrations

!!!Warning
    Se una migrazione non è reversibile, non sarà possibile ripristinarla.


##Refreshing delle migrazioni


Dal momento che Yii 2.0.13 è possibile eliminare tutte le tabelle e le chiavi esterne dal database e applicare tutte le migrazioni dall'inizio.

    yii migrate/fresh       # Truncate the database and 


##Elenco delle migrazioni


Per elencare quali migrazioni sono state applicate e quali no, puoi utilizzare i seguenti comandi:

    yii migrate/history     # showing the last 10 applied migrations
    yii migrate/history 5   # showing the last 5 applied migrations
    yii migrate/history all # showing all applied migrations

    yii migrate/new         # showing the first 10 new migrations
    yii migrate/new 5       # showing the first 5 new migrations
    yii migrate/new all     # showing all new migrations


##Modifica della cronologia delle migrazioni


Invece di applicare o ripristinare le migrazioni, a volte potresti semplicemente voler segnalare che il tuo database è stato aggiornato a una particolare migrazione. Ciò accade spesso quando si modifica manualmente il database in uno stato particolare e non si desidera che le migrazioni per tale modifica vengano applicate nuovamente in un secondo momento. È possibile raggiungere questo obiettivo con il seguente comando:

    yii migrate/mark 150101_185401                      # using timestamp to specify the migration
    yii migrate/mark "2015-01-01 18:54:01"              # using a string that can be parsed by strtotime()
    yii migrate/mark m150101_185401_create_news_table   # using full name
    yii migrate/mark 1392853618                         # using UNIX timestamp

Il comando modificherà la tabella `migration` aggiungendo o eliminando determinate righe per indicare che il database ha applicato le migrazioni a quella specificata. Nessuna migrazione verrà applicata o ripristinata da questo comando.


##Personalizzazione delle migrazioni


Esistono diversi modi per personalizzare il comando di migrazione.


***Utilizzo delle opzioni della riga di comando***


Il comando di migrazione viene fornito con alcune opzioni della riga di comando che possono essere utilizzate per personalizzare i suoi comportamenti:

- `interactive`: booleano (predefinito su `true`), specifica se eseguire le migrazioni in modalità interattiva. Quando questo è `true`, l'utente verrà richiesto prima che il comando esegua determinate azioni. Si consiglia di impostarlo su `false` se il comando viene utilizzato in un processo in background.

- `migrationPath`: string | array (predefinito su `@app/migrations`), specifica la directory che memorizza tutti i file classe di migrazione. Questo può essere specificato come un percorso di directory o un alias di percorso. Si noti che la directory deve esistere o che il comando potrebbe generare un errore. Dalla versione 2.0.12 è possibile specificare un array per il caricamento delle migrazioni da più origini.

- `migrationTable`: string (predefinito su `migration`), specifica il nome della tabella del database per la memorizzazione delle informazioni sulla cronologia della migrazione. La tabella verrà automaticamente creata dal comando se non esiste. Puoi anche crearlo manualmente usando la struttura `version varchar(255) primary key, apply_time integer`.

- `db`: string (predefinito su `db`), specifica l'ID del componente dell'applicazione di database. Rappresenta il database che verrà migrato utilizzando questo comando.

- `templateFile`: string (predefinito su `@yii/views/migration.php`), specifica il percorso del file modello utilizzato per generare file di classe di migrazione scheletro. Questo può essere specificato come percorso del file o alias del percorso. Il file modello è uno script PHP in cui è possibile utilizzare una variabile predefinita denominata $classNameper ottenere il nome della classe di migrazione.

- `generatorTemplateFiles`: array (predefinito su `[

    'create_table' => '@yii/views/createTableMigration.php',
    'drop_table' => '@yii/views/dropTableMigration.php',
    'add_column' => '@yii/views/addColumnMigration.php',
    'drop_column' => '@yii/views/dropColumnMigration.php',
    'create_junction' => '@yii/views/createTableMigration.php'

] `), specifica i file modello per generare il codice di migrazione.

- `fields`: array di stringhe di definizione della colonna utilizzate per la creazione del codice di migrazione. Predefinito a `[]`. Il formato di ciascuna definizione è `COLUMN_NAME:COLUMN_TYPE:COLUMN_DECORATOR`. Ad esempio, `--fields=name:string(12):notNull` produce una colonna di stringa di dimensioni 12 che non lo è `null`.

L'esempio seguente mostra come è possibile utilizzare queste opzioni.

Ad esempio, se vogliamo migrare un modulo `forum` i cui file di migrazione si trovano all'interno della directory `migrations` del modulo , quindi possiamo usare il seguente comando:

    # migrate the migrations in a forum module non-interactively
    yii migrate --migrationPath=@app/modules/forum/migrations --interactive=0


##Configurazione del comando a livello globale


Invece di immettere gli stessi valori di opzione ogni volta che si esegue il comando di migrazione, è possibile configurarlo una volta per tutte nella configurazione dell'applicazione come mostrato di seguito:

    return [
        'controllerMap' => [
            'migrate' => [
                'class' => 'yii\console\controllers\MigrateController',
                'migrationTable' => 'backend_migration',
            ],
        ],
    ];

Con la configurazione precedente, ogni volta che si esegue il comando di migrazione, la tabella `backend_migration` verrà utilizzata per registrare la cronologia di migrazione. Non è più necessario specificarlo tramite l'opzione `migrationTable` della riga di comando.


##Migrazioni con i namespace


Dalla versione 2.0.10 è possibile utilizzare i namespace per le classi di migrazione. È possibile specificare l'elenco dei namespace di migrazione tramite `migrationNamespaces`. L'utilizzo dei namespace per le classi di migrazione consente l'utilizzo delle diverse posizioni di origine per le migrazioni. Per esempio:

    return [
        'controllerMap' => [
            'migrate' => [
                'class' => 'yii\console\controllers\MigrateController',
                'migrationPath' => null, // disable non-namespaced migrations if app\migrations is listed below
                'migrationNamespaces' => [
                    'app\migrations', // Common migrations for the whole application
                    'module\migrations', // Migrations for the specific project's module
                    'some\extension\migrations', // Migrations for the specific extension
                ],
            ],
        ],
    ];

!!!Nota
    Le migrazioni applicate da diversi namespace creeranno un'unica cronologia di migrazione, ad esempio potresti non essere in grado di applicare o ripristinare le migrazioni da un determinato namespace.

Durante l'esecuzione delle migrazioni con namespace: possiamo crearne uno nuovo, ripristinarne uno,  e così via. E' necessario specificare il namespace completo prima del nome della migrazione. Si noti che il simbolo `\` è solitamente considerato un carattere speciale nella shell, quindi è necessario eseguirlo correttamente per evitare errori di shell o comportamenti scorretti. Per esempio:

    yii migrate/create 'app\\migrations\\createUserTable'

!!!Nota
    Le migrazioni specificate tramite `migrationPath` non possono contenere un namespace, quindi la migrazione dei namespace può essere applicata solo tramite la proprietà **yii \ console \ controllers \ MigrateController :: $ migrationNamespaces**.

Dalla versione 2.0.12 la proprietà `migrationPath` accetta anche una matrice per specificare più directory che contengono migrazioni senza un namespace. Questo è principalmente aggiunto per essere utilizzato in progetti esistenti che utilizzano migrazioni da luoghi diversi. Queste migrazioni provengono principalmente da fonti esterne, come le estensioni Yii sviluppate da altri sviluppatori, che non possono essere modificate per utilizzare facilmente spazi dei nomi quando si inizia a utilizzare il nuovo approccio.


##Migrazioni separate


A volte l'utilizzo di un'unica cronologia di migrazione per tutte le migrazioni di progetto non è auspicabile. Ad esempio: è possibile installare alcune estensioni "blog", che contengono funzionalità completamente separate e contengono le proprie migrazioni, che non dovrebbero influire su quelle dedicate alle funzionalità del progetto principale.

Se si desidera che diverse migrazioni vengano applicate e tracciate completamente separate l'una dall'altra, è possibile configurare più comandi di migrazione che utilizzeranno diversi spazi dei nomi e tabelle della cronologia delle migrazioni:

    return [
        'controllerMap' => [
            // Common migrations for the whole application
            'migrate-app' => [
                'class' => 'yii\console\controllers\MigrateController',
                'migrationNamespaces' => ['app\migrations'],
                'migrationTable' => 'migration_app',
                'migrationPath' => null,
            ],
            // Migrations for the specific project's module
            'migrate-module' => [
                'class' => 'yii\console\controllers\MigrateController',
                'migrationNamespaces' => ['module\migrations'],
                'migrationTable' => 'migration_module',
                'migrationPath' => null,
            ],
            // Migrations for the specific extension
            'migrate-rbac' => [
                'class' => 'yii\console\controllers\MigrateController',
                'migrationPath' => '@yii/rbac/migrations',
                'migrationTable' => 'migration_rbac',
            ],
        ],
    ];


Nota che per sincronizzare il database ora devi eseguire più comandi invece di uno:

    yii migrate-app
    yii migrate-module
    yii migrate-rbac


##Migrazione di più database


Per impostazione predefinita, le migrazioni vengono applicate allo stesso database specificato dal componente `db` dell'applicazione. Se vuoi che vengano applicati a un altro database, puoi specificare l'opzione `db` della riga di comando come mostrato di seguito,

    yii migrate --db=db2

Il comando precedente applicherà le migrazioni al database `db2`. 

A volte può succedere che si voglia applicare alcune delle migrazioni a un database, mentre altre ad un altro database. Per raggiungere questo obiettivo, quando si implementa una classe di migrazione, è necessario specificare esplicitamente l'ID del componente DB utilizzato dalla migrazione, come nel seguente esempio:

    <?php

    use yii\db\Migration;

    class m150101_185401_create_news_table extends Migration{

        public function init(){

            $this->db = 'db2';
            parent::init();
        }
    }

La suddetta migrazione verrà applicata a `db2` anche se si specifica un altro database tramite l'opzione `db` della riga di comando. Si noti che la cronologia delle migrazioni verrà comunque registrata nel database specificato dall'opzione `db` della riga di comando.

Se si dispone di più migrazioni che utilizzano lo stesso database, si consiglia di creare una classe di migrazione di base con il codice precedente **init()**. Quindi ogni classe di migrazione può estendersi da questa classe base.

!!!Tip
    Oltre a impostare la proprietà db, puoi anche operare su diversi database creando nuove connessioni database nelle classi di migrazione. Quindi si utilizzano i metodi DAO con queste connessioni per manipolare diversi database.

Un'altra strategia che è possibile eseguire per migrare più database consiste nel mantenere le migrazioni per diversi database in diversi percorsi di migrazione. Quindi è possibile migrare questi database in comandi separati come il seguente:

    yii migrate --migrationPath=@app/migrations/db1 --db=db1
    yii migrate --migrationPath=@app/migrations/db2 --db=db2
    ...

Il primo comando si applicherà migrazioni in `@app/migrations/db1` al database `db1`, il secondo comando si applicherà migrazioni in `@app/migrations/db2` a `db2`, e così via.
