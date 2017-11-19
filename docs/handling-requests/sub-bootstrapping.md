#Bootstrapping


Il bootstrap fa riferimento al processo di preparazione dell'ambiente prima che un'applicazione inizi a risolvere e ad elaborare una richiesta in entrata. Il bootstrap viene eseguito in due punti: lo script di immissione (entry scrpit) e nell' applicazione.

Nell'entry script, vengono registrati i caricatori automatici di classi per diverse librerie. Ciò include il caricatore automatico ***Composer*** tramite il relativo file ```autoload.php``` e il caricatore automatico Yii, attraverso il relativo file della classe ```Yii```. L'entry script carica quindi la configurazione dell'applicazione e crea un'istanza dell'applicazione.

Nel costruttore dell'applicazione, viene eseguito il seguente lavoro di bootstrap:

1. viene chiamato il metodo ```preInit()```, che configura alcune proprietà dell'applicazione ad alta priorità, come ***yii \ base \ Application :: basePath***.
2. Registrare ***yii \ base \ Application :: errorHandler***.
3. Inizializza le proprietà dell'applicazione utilizzando la configurazione dell'applicazione specificata.
4. Viene chiamato il metodo ```init()``` che a sua volta chiama il metodo ```bootstrap()``` per eseguire componenti bootstrap.
    - Includi il file manifest dell'estensione ```vendor/yiisoft/extensions.php```.
    - Crea ed esegui i componenti bootstrap dichiarati dalle estensioni.
    - Dobbiamo creare ed eseguire componenti e / o moduli dell'applicazione dichiarati nella proprietà bootstrap dell'applicazione .

Poiché bootstrap deve essere eseguito prima di gestire ogni richiesta, è molto importante mantenere questo processo leggero e ottimizzarlo il più possibile.

Adesso dobbiamo cercare di non registrare troppi componenti bootstrap. Un componente bootstrap è necessario solo se vuole partecipare all'intero ciclo di vita della gestione richiesta. Ad esempio,se un modulo deve registrare regole di analisi URL aggiuntive, dovrebbe essere elencato nella proprietà bootstrap in modo che le nuove regole URL possano avere effetto prima che vengano utilizzate per risolvere le richieste.

In modalità di produzione dell'applicazione, possiamo abilitare una cache bytecode, come ***OPcache*** o ***APC***, per ridurre al minimo il tempo necessario per includere e analizzare i file PHP.

Alcune applicazioni di grandi dimensioni hanno configurazioni molto complesse e suddivise in molti file di configurazione più piccoli. In tal caso, ci conviene prendere in considerazione la memorizzazione nella cache di un intero array di configurazione.










