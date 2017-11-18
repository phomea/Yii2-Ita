rm -rf site

if [ "$1" = "release" ]; then
    echo "🌻   >>>  Pulizia vecchi enviroments"
    rm -rf yii2docs
    echo "🌸   >>>  Creazione enviroments"
    python3 -m venv yii2docs
    echo "🌺   >>>  Attivazione enviroments"
    . yii2docs/bin/activate
    echo "🌼   >>>  Installazione requirements"
    pip install -r requirements.txt
else
    . yii2docs/bin/activate
fi
mkdocs build
mkdocs serve
