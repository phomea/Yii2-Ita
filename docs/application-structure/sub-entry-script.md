#Entry Script

Gli "Entry Scipt" ( oppure "script di accesso") sono il primo passo nel processo di avvio dell'applicazione. Questi script devono essere memorizzati nelle directory accessibili al Web, in modo tale che possano essere accessibili dagli utenti finali. Sono spesso chiamati ```index.php```, ma possono anche utilizzare altri nomi,

Gli script di accesso effettuano principalmente i seguenti lavori:
- Definire costanti globali;
- Registra il "Composer autoloader";
- Include il file della classe Yii;
- Carica la configurazione dell'applicazione;
- Crea e configura un'istanza dell'applicazione;
- Chiama ```yii \ base \ Application ::run()``` per elaborare la richiesta di entrata.

##Applicazioni Web

Di seguito è riportato il codice dello script di accesso per il modello di progetto di un'applicazione Web:

    <?php

    defined('YII_DEBUG') or define('YII_DEBUG', true);
    defined('YII_ENV') or define('YII_ENV', 'dev');

    // register Composer autoloader
    require(__DIR__ . '/../vendor/autoload.php');

    // include Yii class file
    require(__DIR__ . '/../vendor/yiisoft/yii2/Yii.php');

    // load application configuration
    $config = require(__DIR__ . '/../config/web.php');

    // create, configure and run application
    (new yii\web\Application($config))->run();

##Applicazioni tramite Console

Analogamente, il seguente codice è lo script di accesso per il modello di progetto di un'applicazione console:

    #!/usr/bin/env php
    <?php
    /**
     * Yii console bootstrap file.
     *
     * @link http://www.yiiframework.com/
     * @copyright Copyright (c) 2008 Yii Software LLC
     * @license http://www.yiiframework.com/license/
     */

    defined('YII_DEBUG') or define('YII_DEBUG', true);
    defined('YII_ENV') or define('YII_ENV', 'dev');

    // register Composer autoloader
    require(__DIR__ . '/vendor/autoload.php');

    // include Yii class file
    require(__DIR__ . '/vendor/yiisoft/yii2/Yii.php');

    // load application configuration
    $config = require(__DIR__ . '/config/console.php');

    $application = new yii\console\Application($config);
    $exitCode = $application->run();
    exit($exitCode);

##Definizione di costanti

Gli script di inserimento sono il luogo migliore per definire le costanti globali. Yii supporta le seguenti 3 costanti:

- ```YII_DEBUG```: specifica se l'applicazione è in esecuzione in modalità di debug. Quando la modalità debug sarà attiva ( cioè settata a ```true```) manterrò ulteriori informazioni sul registro e rivelerà gli stack di chiamata degli errori dettagliata se vengono prelevate eccezioni. Per questo questa modalità andrebbe sempre attivata durante lo sviluppo. Il valore predefinito è ```false```.
- ```YII_ENV```: specifica l'ambiente in cui è in esecuzione l'applicazione. Il valore predefinitodi ```YII_ENV``` è ```'prod'```, il che significa che l'applicazione è in esecuzione in ambiente di produzione.
- ```YII_ENABLE_HERROR_HANDLER```: specifica se abilitare il gestore di errori fornito da Yii. Il valore predefinito di questa costante è ```true```.

Quando si definisce una costante, utilizziamo spesso il seguente codice:

    defined('YII_DEBUG') or define('YII_DEBUG', true);

Le definizioni di costanti dovrebbero essere eseguite nell'entry script in modo che possano avere effetto quando altri file PHP vengano inclusi.