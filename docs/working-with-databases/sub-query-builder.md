#Generatore di Query (Query Builder)


Basato sul DBO (Database Access Objects), il generatore di query consente di costruire una query SQL in modo programmatico e indipendente dal DBMS. Rispetto alla scrittura di istruzioni SQL non elaborate, l'utilizzo del query builder consente di scrivere codice SQL più leggibile e generare istruzioni SQL più sicure.

L'utilizzo di Generatore di query prevede in genere due passaggi:

- Costruisci un oggetto **yii \ db \ Query** per rappresentare parti diverse (ad es SELECT. FROM) di un'istruzione SELECT SQL.
- Esegui un metodo di query (es. `all()`) di **yii \ db \ Query** per recuperare i dati dal database.

Il codice seguente mostra un modo tipico di utilizzare il generatore di query:

    $rows = (new \yii\db\Query())
        ->select(['id', 'email'])
        ->from('user')
        ->where(['last_name' => 'Smith'])
        ->limit(10)
        ->all();

Il codice precedente genera ed esegue la seguente query SQL, in cui il parametro `:last_name` è associato alla stringa `'Smith'`.

    SELECT `id`, `email` 
    FROM `user`
    WHERE `last_name` = :last_name
    LIMIT 10

!!!Info
    Di solito si lavora principalmente con **yii \ db \ Query** invece di **yii \ db \ QueryBuilder**. Quest'ultimo viene invocato dal primo implicitamente quando si chiama uno dei metodi di query. **yii \ db \ QueryBuilder** è la classe responsabile della generazione di istruzioni SQL dipendenti da DBMS (ad esempio, citando in modo diverso nomi di tabelle / colonne) da oggetti **yii \ db \ Query** indipendenti da DBMS.


##Costruzione di una query


Per costruire un oggetto **yii \ db \ Query**, si chiamano diversi metodi di creazione per specificare parti diverse di una query SQL. I nomi di questi metodi sono simili alle parole chiave SQL utilizzate nelle parti corrispondenti dell'istruzione. Ad esempio, per specificare la parte `FROM` di una query SQL, dobbiamo chiamare il metodo **from()**. Tutti i metodi di creazione query restituiscono l'oggetto query stesso, che consente di concatenare più chiamate contemporaneamente.

Di seguito, descriveremo l'utilizzo di ciascun metodo di creazione di query.


##SELECT()


Il metodo **select()** specifica il frammentro `SELECT` di un'istruzione SQL. È possibile specificare le colonne da selezionare in una matrice o in una stringa, come nell'esempio seguente. I nomi delle colonne selezionati verranno automaticamente quotati quando l'istruzione SQL viene generata da un oggetto query.

    $query->select(['id', 'email']);

    // equivalent to:

    $query->select('id, email');

I nomi delle colonne selezionate possono includere prefissi di tabelle e / o alias di colonne, come quando si scrivono query SQL non elaborate. Per esempio,

    $query->select(['user.id AS user_id', 'email']);

    // equivalent to:

    $query->select('user.id AS user_id, email');

Se si utilizza il formato della matrice per specificare le colonne, è anche possibile utilizzare i tasti della matrice per specificare gli alias di colonna. Ad esempio, il codice sopra riportato può essere riscritto come segue,

    $query->select(['user_id' => 'user.id', 'email']);

Se non si chiama il metodo **select()** durante la creazione di una query, con `*` verranno selezionate tutte le colonne.

Oltre ai nomi delle colonne, è anche possibile selezionare le espressioni DB. È necessario utilizzare il formato di matrice quando si seleziona un'espressione DB che contiene virgole, per evitare virgolette automatiche errate. Per esempio,

    $query->select(["CONCAT(first_name, ' ', last_name) AS full_name", 'email']); 

Come per tutti i punti in cui è coinvolto l'SQL non elaborato, è possibile utilizzare **DBMS agnostic quoting syntax** per i nomi di tabelle e colonne quando si scrivono espressioni DB in select.

A partire dalla versione 2.0.1, è possibile selezionare anche le sottoquery. È necessario specificare ogni sottoquery in termini di un oggetto **yii \ db \ Query**. Per esempio,

    $subQuery = (new Query())->select('COUNT(*)')->from('user');

    // SELECT `id`, (SELECT COUNT(*) FROM `user`) AS `count` FROM `post`
    $query = (new Query())->select(['id', 'count' => $subQuery])->from('post');

Per selezionare righe distinte, puoi chiamare il metodo **distinct()** , come il seguente:

    // SELECT DISTINCT `user_id` ...
    $query->select('user_id')->distinct();

Puoi chiamare **addSelect()** per selezionare colonne aggiuntive. Per esempio,

    $query->select(['id', 'username'])
        ->addSelect(['email']);


##FROM()


Il metodo **from()** specifica il frammento `FROM` di un'istruzione SQL. Per esempio,

    // SELECT * FROM `user`
    $query->from('user');

È possibile specificare la / le tabella / i selezionata / i in una stringa o in una matrice. I nomi delle tabelle possono contenere prefissi dello schema e / o alias di tabelle, come quando si scrivono istruzioni SQL non elaborate. Per esempio,

    $query->from(['public.user u', 'public.post p']);

    // equivalent to:

    $query->from('public.user u, public.post p');

Se si utilizza il formato di matrice, è anche possibile utilizzare le chiavi della matrice per specificare gli alias di tabella, come i seguenti:

    $query->from(['u' => 'public.user', 'p' => 'public.post']);

Oltre ai nomi delle tabelle, è anche possibile selezionare delle subquery specificandole in termini di oggetti **yii \ db \ Query**. Per esempio,

    $subQuery = (new Query())->select('id')->from('user')->where('status=1');

    // SELECT * FROM (SELECT `id` FROM `user` WHERE status=1) u 
    $query->from(['u' => $subQuery]);


##WHERE()


Il metodo **where()** specifica il frammento `WHERE` di una query SQL. È possibile utilizzare uno dei tre formati per specificare una WHEREcondizione:

- formato stringa, ad es. `'status=1'`
- formato hash, ad es `['status' => 1, 'type' => 2]`
- formato operatore, ad es `['like', 'name', 'test']`


***Formato della stringa***


Il formato stringa è il modo migliore per specificare condizioni molto semplici o se è necessario utilizzare le funzioni integrate del DBMS. Funziona come se si stesse scrivendo un SQL raw. Per esempio,

    $query->where('status=1');

    // or use parameter binding to bind dynamic parameter values
    $query->where('status=:status', [':status' => $status]);

    // raw SQL using MySQL YEAR() function on a date field
    $query->where('YEAR(somedate) = 2015');

NON incorporare le variabili direttamente nella condizione come le seguenti, soprattutto se i valori delle variabili provengono da input dell'utente finale, poiché ciò renderà l'applicazione soggetta agli attacchi di SQL injection.

    // Dangerous! Do NOT do this unless you are very certain $status must be an integer.
    $query->where("status=$status");

Quando si utilizza l'associazione dei parametri, è possibile chiamare il metodo `params()` o `addParams()` per specificare i parametri separatamente.

    $query->where('status=:status')
        ->addParams([':status' => $status]);

Come per tutti i punti in cui è coinvolto l'SQL non elaborato, è possibile utilizzare la "DBMS agnostic quoting syntax" per i nomi di tabelle e colonne quando si scrivono le condizioni nel formato stringa.


***Formato hash***


Il formato hash viene utilizzato per specificare le sotto-condizioni concatenate come `AND`, ognuna delle quali è una semplice affermazione di uguaglianza. È scritto come un array le cui chiavi sono nomi di colonne e valori i valori corrispondenti che dovrebbero essere le colonne. Per esempio,

    // ...WHERE (`status` = 10) AND (`type` IS NULL) AND (`id` IN (4, 8, 15))
    $query->where([
        'status' => 10,
        'type' => null,
        'id' => [4, 8, 15],
    ]);

Come puoi vedere, il generatore di query è abbastanza intelligente da gestire correttamente i valori null o array.

Puoi anche utilizzare sottoquery con formato hash come il seguente:

    $userQuery = (new Query())->select('id')->from('user');

    // ...WHERE `id` IN (SELECT `id` FROM `user`)
    $query->where(['id' => $userQuery]);

Usando il formato hash, Yii usa internamente il binding dei parametri, quindi in contrasto con il formato stringa. In questo caso non devi aggiungere parametri manualmente.


***Formato dell'operatore***


Il formato operatore consente di specificare condizioni arbitrarie in modo programmatico. Prende il seguente formato:

    [operator, operand1, operand2, ...]

dove gli operandi possono essere specificati ciascuno in formato stringa, formato hash o formato operatore in modo ricorsivo, mentre l'operatore può essere uno dei seguenti:

- `and`: gli operandi dovrebbero essere concatenati insieme usando `AND`. Ad esempio, `['and', 'id=1', 'id=2']` genererà `id=1 AND id=2`. Se un operando è un array, verrà convertito in una stringa usando le regole descritte qui. Ad esempio,`['and', 'type=1', ['or', 'id=1', 'id=2']]` genererà `type=1 AND (id=1 OR id=2)`. Il metodo NON farà alcuna citazione o fuga.

- `or`: simile all'operatore `and` tranne per il fatto che gli operandi sono concatenati usando `OR`.

- `not`: richiede solo l'operando 1, che verrà incluso con `NOT()`. Ad esempio, `['not', 'id=1']genererà NOT (id=1)`. Operando 1 può anche essere una matrice per descrivere più espressioni. Ad esempio `['not', ['status' => 'draft', 'name' => 'example']]` genererà `NOT ((status='draft') AND (name='example'))`.

- `between`: l'operando 1 dovrebbe essere il nome della colonna e l'operando 2 e 3 dovrebbe essere il valore iniziale e finale dell'intervallo in cui si trova la colonna. Ad esempio, `['between', 'id', 1, 10]` genererà `id BETWEEN 1 AND 10`.

- `not between`: simile a `between`tranne che `BETWEEN` viene sostituito con `NOT BETWEEN` nella condizione generata.

- `in`: l'operando 1 dovrebbe essere una colonna o un'espressione DB. L' operando 2 può essere un array o un oggetto `Query`. Genererà una condizione `IN` se l'operando 2 è una matrice, rappresenterà l'intervallo dei valori che dovrebbe essere la colonna o l'espressione DB; se l'operando 2 è un oggetto `Query`, verrà generata una sottoquery e utilizzata come intervallo della colonna o dell'espressione DB. Ad esempio, `['in', 'id', [1, 2, 3]]` genererà `id IN (1, 2, 3)`. Il metodo citerà correttamente il nome della colonna e i valori di escape nell'intervallo. L'operatore `in` supporta anche colonne composite. In questo caso, l'operando 1 dovrebbe essere una matrice delle colonne, mentre l'operando 2 dovrebbe essere una matrice di matrici o un oggetto `Query` che rappresenta l'intervallo delle colonne.

- `not in`: simile all'operatore `in` tranne che `IN` viene sostituito con `NOT IN` nella condizione generata.

- `like`: l'operando 1 deve essere una colonna o un'espressione DB e l'operando 2 deve essere una stringa o una matrice che rappresenta i valori che la colonna o l'espressione DB deve avere. Ad esempio, `['like', 'name', 'tester']` genererà `name LIKE '%tester%'`. Quando l'intervallo di valori viene fornito come matrice, i `LIKE` saranno di più e verranno concatenati utilizzando `AND`. Ad esempio, `['like', 'name', ['test', 'sample']]` genererà `name LIKE '%test%' AND name LIKE '%sample%'`. È anche possibile fornire un terzo operando opzionale per specificare come evitare caratteri speciali nei valori. L'operando dovrebbe essere una matrice di mapping dai caratteri speciali alle loro controparti fuggite. Se questo operando non viene fornito, verrà utilizzata una mappatura di escape predefinita. Puoi usare il valore `false` o una matrice vuota per indicare che i valori sono già stati presi e che non è necessario applicare alcuna escape. Si noti che quando si utilizza una mappatura di escape (o il terzo operando non è fornito), i valori saranno automaticamente racchiusi all'interno di una coppia di caratteri percentuali.

!!!Nota 
    Quando si utilizza PostgreSQL è possibile utilizzare `ilike` al posto della corrispondenza `like` senza distinzione tra maiuscole e minuscole.

- `or like`: simile all'operatore `like` tranne che `OR` è usato per concatenare i `LIKE` predicati quando l'operando 2 è una matrice.

- `not like`: simile all'operatore `lik` tranne che `LIKE` viene sostituito con `NOT LIKE` nella condizione generata.

- `or not like`: simile all'operatore `not like` tranne che `OR` è usato per concatenare i predicati `NOT LIKE`.

- `exists`: richiede un operando che deve essere un'istanza di **yii \ db \ Query** che rappresenta la sottoquery. Costruirà un'espressione `EXISTS (sub-query)`.

- `not exists`: simile all'operatore `exists` e crea un'espressione `NOT EXISTS (sub-query)`.

- `>, <=` o qualsiasi altro operatore DB valido che accetta due operandi: il primo operando deve essere un nome di colonna mentre il secondo operando un valore. Ad esempio, `['>', 'age', 10]` genererà `age>10`.

Utilizzando il formato operatore, Yii utilizza internamente il binding dei parametri, in contrasto con il formato stringa , in questo caso non è necessario aggiungere parametri manualmente.


***Aggiunta delle condizioni***


È possibile utilizzare **andWhere()** o **orWhere()** per aggiungere condizioni aggiuntive a una esistente. Puoi chiamarli più volte per aggiungere più condizioni separatamente. Per esempio,

    $status = 10;
    $search = 'yii';

    $query->where(['status' => $status]);

    if (!empty($search)) {
        $query->andWhere(['like', 'title', $search]);
    }

Se `$search` non è vuoto, dalla proprietà `WHERE` verrà generata la seguente condizione:

    WHERE (`status` = 10) AND (`title` LIKE '%yii%')


***Condizioni associati ai filtri***


Quando si costruiscono le condizioni `WHERE` in base all'input degli utenti finali, in genere si desidera ignorare quei valori di input, che sono vuoti. Ad esempio, in un modulo di ricerca che consente di effettuare ricerche per nome utente ed e-mail, si desidera ignorare la condizione se l'utente non inserisce nulla nel campo di inserimento nome utente / email. È possibile raggiungere questo obiettivo utilizzando il metodo `filterWhere()`:

    // $username and $email are from user inputs
    $query->filterWhere([
        'username' => $username,
        'email' => $email,
    ]);

L'unica differenza tra `filterWhere()` e `where()` è che il primo ignorerà i valori vuoti forniti nella condizione in formato hash. Quindi se `$email` è vuoto mentre `$username` non lo è, il codice sopra comporterà la condizione `SQL WHERE username=:username`.

!!!Info
   Un valore è considerato vuoto se ha come valore `null`, un array vuoto, una stringa vuota o una stringa composta solo da spazi bianchi.


Come **andWhere()** e **orWhere()**, è possibile utilizzare i metodi `andFilterWhere()` e `orFilterWhere()` per aggiungere condizioni di filtro aggiuntive a quella esistente.
Inoltre, vi è **yii \ db \ Query :: andFilterCompare()** che può determinare in modo intelligente l'operatore in base a cosa c'è nel valore:

    $query->andFilterCompare('name', 'John Doe');
    $query->andFilterCompare('rating', '>9');
    $query->andFilterCompare('value', '<=100');

Puoi anche specificare esplicitamente l'operatore:

    $query->andFilterCompare('name', 'Doe', 'like');
    
Yii 2.0.11 offre metodi simili per la condzione `HAVING`:

- **filterHaving()**
- **andFilterHaving()**
- **orFilterHaving()**


##OrderBy()


Il metodo **orderBy()** specifica il frammento `ORDER BY` di una query SQL. Per esempio,

    // ... ORDER BY `id` ASC, `name` DESC
    $query->orderBy([
        'id' => SORT_ASC,
        'name' => SORT_DESC,
    ]);

Nel codice precedente, le chiavi dell'array sono nomi di colonne, mentre i valori dell'array sono l'ordine corrispondente per direzioni. La costante PHP `SORT_ASC` specifica l'ordinamento crescente, mentre la costante `SORT_DESC` specifica quello decrescente.

Se `ORDER BY` riguarda solo nomi di colonne semplici, è possibile specificarlo utilizzando una stringa, proprio come quando si scrivono istruzioni SQL non elaborate. Per esempio,

    $query->orderBy('id ASC, name DESC');

!!!Nota
    E' necessario utilizzare il formato dell'array se `ORDER BY` include alcune espressioni DB.
    
Puoi chiamare il metodo `addOrderBy()` per aggiungere ulteriori colonne al frammento `ORDER BY`. Per esempio,

    $query->orderBy('id ASC')
        ->addOrderBy('name DESC');


##GroupBy()


Il metodo **groupBy()** specifica il frammento `GROUP BY` di una query SQL. Per esempio,

    // ... GROUP BY `id`, `status`
    $query->groupBy(['id', 'status']);

Se `GROUP BY` riguarda solo nomi di colonne semplici, è possibile specificarlo utilizzando una stringa, proprio come quando si scrivono istruzioni SQL non elaborate. Per esempio,

    $query->groupBy('id, status');

!!!Nota
    E' necessario utilizzare il formato dell'array se `GROUP BY` include alcune espressioni DB.

È possibile chiamare il metodo `addGroupBy()` per aggiungere ulteriori colonne al frammento `GROUP BY`. Per esempio,

    $query->groupBy(['id', 'status'])
        ->addGroupBy('age');


##Having()


Il metodo **having()** specifica il frammento `HAVING` di una query SQL. Prende una condizione che può essere specificata al solito modo di ***where()***. Per esempio,

    // ... HAVING `status` = 1
    $query->having(['status' => 1]);

Fare riferimento alla documentazione di where () per ulteriori dettagli su come specificare una condizione.

È possibile chiamare i metodi `andHaving()` o `orHaving()` per aggiungere condizioni aggiuntive al frammento `HAVING`. Per esempio,

    // ... HAVING (`status` = 1) AND (`age` > 30)
    $query->having(['status' => 1])


##Limit() e Offset()


I metodi `limit()` e `offset()` specificano i frammenti `LIMIT` e `OFFSET` di una query SQL. Per esempio,

    // ... LIMIT 10 OFFSET 20
    $query->limit(10)->offset(20);

Se si specifica un limite o offset non valido (ad es. Un valore negativo), verrà ignorato.

!!!Info
    Per DBMS che non supportano questi due frammenti (ad esempio MSSQL), il generatore di query genererà un'istruzione SQL che emula il comportamento di `LIMIT/ OFFSET`.


##Join()


Il metodo **join()** specifica il frammento `JOIN` di una query SQL. Per esempio,

    // ... LEFT JOIN `post` ON `post`.`user_id` = `user`.`id`
    $query->join('LEFT JOIN', 'post', 'post.user_id = user.id');

Il metodo **join()** accetta quattro parametri:

- `$type`: indica tipo di join, ad es . `'INNER JOIN'`, `'LEFT JOIN'`.
- `$table`: indica il nome del table da usare nella join.
- `$on`: (facoltativo), indica la condizione di join, ovvero il frammento `ON`. Si prega di fare riferimento a **where()** per i dettagli su come specificare una condizione. Si noti che la sintassi dell'array non funziona per specificare una condizione basata su colonne, ad es. `['user.id' => 'comment.userId']`. Si verificherà una condizione in cui l'id dell'utente deve essere uguale alla stringa `'comment.userId'`. Dovresti invece utilizzare la sintassi della stringa e specificare la condizione come `'user.id = comment.userId'`.
- `$params`: (facoltativo), indica i parametri da associare alla condizione di join.

È possibile utilizzare i seguenti metodi di scelta rapida per specificare `INNER JOIN`, `LEFT JOIN` e `RIGHT JOIN`.

- **innerJoin()**
- **leftJoin()**
- **rightJoin()**

Per esempio,

    $query->leftJoin('post', 'post.user_id = user.id');

Per unire più tabelle, chiama più volte i metodi join, una volta per ogni tabella.

Oltre a unirti alle tabelle, puoi anche unirti alle sottoquery. Per fare ciò, specificare le sottoquery da unire come oggetti di **yii \ db \ Query**. Per esempio,

    $subQuery = (new \yii\db\Query())->from('post');
    $query->leftJoin(['u' => $subQuery], 'u.id = author_id');

In questo caso, è necessario inserire la sottoquery in una matrice e utilizzare la chiave dell'array per specificare l'alias.


##Union()


Il metodo **union()** specifica il frammento `UNION` di una query SQL. Per esempio,

    $query1 = (new \yii\db\Query())
        ->select("id, category_id AS type, name")
        ->from('post')
        ->limit(10);

    $query2 = (new \yii\db\Query())
        ->select('id, type, name')
        ->from('user')
        ->limit(10);

    $query1->union($query2);

Puoi chiamare il metodo `union()` più volte per aggiungere altri frammneti `UNION`.


##Metodi di ricerca


**yii \ db \ Query** fornisce un insieme completo di metodi per diversi scopi di ricerca:

- **all()**: restituisce una matrice di righe dove ogni riga è vista come una matrice associativa di coppie nome-valore.
- **one()**: restituisce la prima riga del risultato.
- **column()**: restituisce la prima colonna del risultato.
- **scalar()**: restituisce un valore scalare situato nella prima riga e nella prima colonna del risultato.
- **exists()**: restituisce un valore che ci permette di capire se il valore della query esiste o meno.
- **count()**: restituisce il risultato di una query `COUNT`.

Altri metodi di aggregazione, tra cui `somma($ q)` , `media($ q)` , `max($ q)` , `min($ q)` . Il parametro `$q` è obbligatorio per questi metodi e può essere un nome di colonna o un'espressione DB.
Per esempio,

    // SELECT `id`, `email` FROM `user`
    $rows = (new \yii\db\Query())
        ->select(['id', 'email'])
        ->from('user')
        ->all();
    
    // SELECT * FROM `user` WHERE `username` LIKE `%test%`
    $row = (new \yii\db\Query())
        ->from('user')
        ->where(['like', 'username', 'test'])
        ->one();

!!!Nota        
    Il metodo **one()** restituisce solo la prima riga del risultato della query. NON aggiunge `LIMIT 1` all'istruzione SQL generata. Questo va bene ed è preferito se sai che la query restituirà solo una o poche righe di dati (ad esempio se stai interrogando con alcune chiavi primarie). Tuttavia, se la query potrebbe potenzialmente generare molte righe di dati, è necessario chiamare in modo esplicito `limit(1)` per migliorare le prestazioni, ad es `(new \yii\db\Query())->from('user')->limit(1)->one()`.

Tutti questi metodi di interrogazione richiedono un parametro `$db` facoltativo che rappresenta la connessione DB da utilizzare per eseguire una query DB. Se si omette questo parametro, il componente db dell'applicazione verrà utilizzato come connessione DB. Di seguito è riportato un altro esempio che utilizza il metodo di query **count()**:

    // executes SQL: SELECT COUNT(*) FROM `user` WHERE `last_name`=:last_name
    $count = (new \yii\db\Query())
        ->from('user')
        ->where(['last_name' => 'Smith'])
        ->count();

Quando si chiama un metodo di query di **yii \ db \ Query**, in realtà esegue internamente il seguente lavoro:

- Chiamare **yii \ db \ QueryBuilder** per generare un'istruzione SQL in base al costrutto corrente di **yii \ db \ Query**;
- Creare un oggetto **yii \ db \ Command** con l'istruzione SQL generata;
- Chiamare un metodo di query (ad es. `QueryAll()` ) di **yii \ db \ Command** per eseguire l'istruzione SQL e recuperare i dati.

A volte, potresti voler esaminare o usare l'istruzione SQL creata da un oggetto **yii \ db \ Query**. È possibile raggiungere questo obiettivo con il seguente codice:

    $command = (new \yii\db\Query())
        ->select(['id', 'email'])
        ->from('user')
        ->where(['last_name' => 'Smith'])
        ->limit(10)
        ->createCommand();
    
    // show the SQL statement
    echo $command->sql;
    // show the parameters to be bound
    print_r($command->params);

    // returns all rows of the query result
    $rows = $command->queryAll();


##Risultati di una query da indicizzare


Quando si chiama il metodo **all()**, verrà restituita una matrice di righe che sono indicizzate da numeri interi consecutivi. A volte potresti voler indicizzarli in modo diverso, come l'indicizzazione di una particolare colonna o valori di espressione. È possibile raggiungere questo obiettivo chiamando `indexBy()` prima di all() . Per esempio,

    // returns [100 => ['id' => 100, 'username' => '...', ...], 101 => [...], 103 => [...], ...]
    $query = (new \yii\db\Query())
        ->from('user')
        ->limit(10)
        ->indexBy('id')
        ->all();

Per indicizzare per valori di espressione, passare una funzione anonima al metodo **indexBy()**:

    $query = (new \yii\db\Query())
        ->from('user')
        ->indexBy(function ($row) {
            return $row['id'] . $row['username'];
        })->all();

La funzione anonima accetta un parametro `$row` che contiene i dati della riga corrente e deve restituire un valore scalare che verrà utilizzato come valore di indice.

!!!Warning
    Contrariamente ai metodi di query come **groupBy()** o **orderBy()** che vengono convertiti in SQL e fanno parte della query, questo metodo funziona dopo che i dati sono stati recuperati dal database. Ciò significa che possono essere utilizzati solo i nomi di colonna che sono stati parte di `SELECT` nella query. Inoltre, se hai selezionato una colonna con prefisso tabella, ad esempio `customer.id`, il set di risultati conterrà solo `id`, così che bisogna chiamare `->indexBy('id')` senza prefisso tabella.


##Batch Query


Quando si lavora con grandi quantità di dati, metodi come **yii \ db \ Query :: all()** non sono adatti perché richiedono il caricamento dell'intero risultato della query nella memoria del client. Per risolvere questo problema, Yii fornisce supporto per query in batch. Il server mantiene il risultato della query e il client utilizza un cursore per scorrere il set di risultati un batch alla volta.

!!!Warning
    Esistono limiti noti e soluzioni alternative per l'implementazione MySQL di query batch. Vedi sotto.

La query batch può essere utilizzata come la seguente:

    use yii\db\Query;

    $query = (new Query())
        ->from('user')
        ->orderBy('id');

    foreach ($query->batch() as $users) {
        // $users is an array of 100 or fewer rows from the user table
    }

    // or to iterate the row one by one
    foreach ($query->each() as $user) {
        // data is being fetched from the server in batches of 100,
        // but $user represents one row of data from the user table
    }

Il metodo **yii \ db \ Query :: batch()** e **yii \ db \ Query :: each()** restituiscono un oggetto **yii \ db \ BatchQueryResult** che implementa l'interfaccia `Iterator` e quindi può essere utilizzato nel costrutto `foreach`. Durante la prima iterazione, viene eseguita una query SQL sul database. I dati vengono quindi recuperati in lotti nelle restanti iterazioni. Per impostazione predefinita, la dimensione del batch è 100, ovvero 100 file di dati vengono recuperati in ogni batch. È possibile modificare le dimensioni del batch passando il primo parametro al metodo **batch()** o **each()**.

Rispetto a **yii \ db \ Query :: all()**, la query batch carica solo 100 righe di dati alla volta nella memoria.

Se si specifica il risultato della query da indicizzare per alcune colonne tramite yii \ db \ Query :: indexBy () , la query batch manterrà comunque l'indice corretto.

Per esempio:

    $query = (new \yii\db\Query())
        ->from('user')
        ->indexBy('username');

    foreach ($query->batch() as $users) {
        // $users is indexed by the "username" column
    }

    foreach ($query->each() as $username => $user) {
        // ...
    }


##Limitazioni della query batch in MySQL


L'implementazione MySQL di query batch si basa sulla libreria di driver PDO. Per impostazione predefinita, le query MySQL sono `buffered`. Ciò elimina lo scopo di utilizzare il cursore per ottenere i dati, poiché non impedisce che l'intero set di risultati venga caricato nella memoria del client dal driver.

!!!Warning
    Quando `libmysqlclient` viene utilizzato (tipico di PHP5), il limite di memoria di PHP non conterà la memoria utilizzata per i set di risultati. Potrebbe sembrare che le query batch funzionino correttamente, ma in realtà l'intero set di dati viene caricato nella memoria del client e ha il potenziale per utilizzarlo.

Per disabilitare il buffering e ridurre i requisiti di memoria del client, è necessario impostare la proprietà di connessione PDO `PDO::MYSQL_ATTR_USE_BUFFERED_QUERY` al valore di `false`. Tuttavia, fino a quando non viene recuperato l'intero set di dati, non è possibile effettuare altre query tramite la stessa connessione. Ciò potrebbe impedire all'ActiveRecord di creare una query per ottenere lo schema della tabella quando necessario. Se questo non è un problema (lo schema della tabella è già memorizzato nella cache), è possibile passare la connessione originale in modalità `unbuffered` e quindi eseguire il rollback al termine della query batch.

    Yii::$app->db->pdo->setAttribute(\PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, false);

    // Do batch query

    Yii::$app->db->pdo->setAttribute(\PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, true);

!!!Nota
    Nel caso di MyISAM, per la durata della query batch, la tabella potrebbe bloccarsi, ritardare o negare l'accesso in scrittura per altre connessioni. Quando si utilizzano query senza buffer, provare a mantenere il cursore aperto per il minor tempo possibile.

Se lo schema non è memorizzato nella cache o è necessario eseguire altre query mentre viene elaborata la query batch, è possibile creare una connessione unbuffered separata al database:

    $unbufferedDb = new \yii\db\Connection([
        'dsn' => Yii::$app->db->dsn,
        'username' => Yii::$app->db->username,
        'password' => Yii::$app->db->password,
        'charset' => Yii::$app->db->charset,
    ]);
    $unbufferedDb->open();
    $unbufferedDb->pdo->setAttribute(\PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, false);

Se vuoi assicurarti che `$unbufferedDb` abbia esattamente gli stessi attributi PDO come il buffer originale, il valore di `PDO::MYSQL_ATTR_USE_BUFFERED_QUERY` deve essere `false`.

Quindi, le query vengono create normalmente. La nuova connessione viene utilizzata per eseguire query batch e recuperare i risultati in batch o uno per uno:

    // getting data in batches of 1000
    foreach ($query->batch(1000, $unbufferedDb) as $users) {
        // ...
    }

    // data is fetched from server in batches of 1000, but is iterated one by one 
    foreach ($query->each(1000, $unbufferedDb) as $user) {
        // ...
    }

Quando la connessione non è più necessaria e il set di risultati è stato recuperato, può essere chiuso:

    $unbufferedDb->close();

!!!Nota
    La query senza buffer utilizza meno memoria sul lato PHP, ma può aumentare il carico sul server MySQL. Si consiglia di progettare il proprio codice con la propria pratica di produzione per ottenere dati straordinari.
