#Panoramica

Le applicazioni Yii sono organizzate in base al modello MVC ( model - view - controller ). I model (modelli) rappresentano i dati, la logica aziendale e le regole; le view (viste) rappresentano la rappresentazione dei modelli; e i controller (controllori) prendono l'input e lo trasformano in comandi per i model e le view.

Oltre al MVC, le applicazioni Yii hanno anche le seguenti entità:

- **Entry script**: sono script PHP che sono direttamente accessibili dagli utenti finali. Sono responsabili dell'avvio di un ciclo che permette la gestione delle richieste da parte dell'utente.
- **Application**: sono oggetti accessibili a livello globale che gestiscono i componenti dell'applicazione e le coordinano per soddisfare le richieste.
- **Application component**: sono oggetti registrati con applicazioni e forniscono veri servizi per soddisfare le richieste.
- **Module**: sono pacchetti autonomi che contengono pattern MVC completi da soli. Un'applicazione può essere organizzata in termini di moduli multipli.
- **Filtri**: rappresentano il codice che deve essere richiamato prima e dopo la gestione effettiva di ogni richiesta da parte dei controllori.
- **Widget**: sono oggetti che possono essere incorporati nelle view (viste).Possono contenere la logica dei controller e possono essere anche riutilizzati in viste diverse.

Il seguente schema mostra la struttura statica di un'applicazione:

![Screenshot](../img/application-structure/Struttura-statica-applicazione.png) 