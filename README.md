# Games App

## Descrizione
Un'applicazione mobile e desktop sviluppata in Flutter che include tre giochi: Trivia, Super Tris e Kakuro. L'app permette agli utenti di registrarsi, effettuare il login e giocare in modalità single-player o multiplayer online.

## Struttura del progetto
lib/
├── main.dart // Entry point dell'applicazione
├── screens/
│ ├── SetGames.dart // Schermata principale per la selezione del gioco
│ ├── LoginScreen.dart // Schermata di login e registrazione
│ ├── Trivia/
│ │ ├── TriviaDifficulty.dart // Selezione difficoltà e categoria
│ │ ├── TriviaGame.dart // Gioco vero e proprio
│ │ └── TriviaLeaderboard.dart // Classifica Trivia
│ ├── SuperTris/
│ │ ├── SuperTrisChoiceScreen.dart // Scelta modalità Super Tris
│ │ ├── SuperTrisLocal.dart // Versione locale del gioco
│ │ └── SuperTrisOnline.dart // Versione multiplayer online
│ └── Kakuro/
│ └── KakuroPuzzle.dart // Gioco Kakuro
├── models/
│ ├── TriviaQuestion.dart // Modello per le domande di Trivia
│ └── Score.dart // Modello per i punteggi
├── services/
│ ├── ApiClient.dart // Gestione API REST per backend PHP
│ └── DatabaseHelper.dart // Gestione database locale SQLite
├── repositories/
│ └── TriviaRepository.dart // Repository per caricamento domande
└── utils/
└── constants.dart // Costanti globali

## Avvio del progetto
Assicurati di avere Flutter installato (versione >= 3.0 consigliata).

#### **1. Clona o scarica il progetto**
```bash
git clone https://github.com/utente/GamesApp.git
```

#### 2. Installa le dipendenze
```bash
flutter pub get
```

#### 3. Avvia l'app
```bash
flutter run
```

## Backend
L'app utilizza un backend PHP + MySQL per autenticazione e salvataggio punteggi.

## Avvio del server PHP
```bash
cd C:\xampp\htdocs\games_db
xampp-control.exe
```
Avvia Apache e MySQL da XAMPP Control Panel.

## Avvio del server Python per Super Tris Online

Raggiungi la cartella server e attiva l'ambiente virtuale, poi esegui il comando:

```bash
python serverSuperTrisTCP.py
```

## Come funziona la logica dei giochi

### Trivia
Il gioco carica domande dal server remoto tramite API REST. Ogni partita consiste di 10 domande casuali. I risultati vengono salvati nel database.

#### Caricamento domande
```bash
final q = await TriviaRepository.loadRandomQuestionByDifficultyAndCategory(widget.difficulty, widget.category, askedQuestions);
```

#### Salvataggio punteggio
```bash
ApiClient.saveTriviaScore(
  nickname: loggedUser,
  difficulty: widget.difficulty,
  category: widget.category,
  time: totalTime,
  correctAnswers: correctAnswers,
  totalQuestions: totalQuestions,
);
```

### Super Tris
Implementa la versione classica del Super Tris (Ultimate Tic Tac Toe) in due modalità: locale e online.

#### Logica del turno online
```bash
if (currentPlayer != mySymbol) return; // Blocca mossa se non è il tuo turno
```

#### Comunicazione con il server Socket.IO
```bash
socket!.emit('move', {
  'roomCode': roomCode,
  'bigIndex': bigIndex,
  'cellIndex': cellIndex
});
```

### Kakuro
Versione classica del gioco Kakuro con generazione di puzzle casuali.

## Interfaccia
- Design moderno con gradienti e ombre
- Navigazione tra giochi tramite griglia
- Sistema di login/registrazione integrato
- Visualizzazione classifiche in tempo reale

## Dipendenze principali
Nel ```pubspec.yaml```:

- ```http```: per chiamate API REST
- ```sqflite```: per database SQLite locale
- ```socket_io_client```: per connessioni multiplayer
- ```flutter_svg```: per icone SVG

## Requisiti
- Flutter SDK
- Dart SDK >= 2.18
- Ambiente Android/iOS/Windows/Linux/Web
- XAMPP per il backend PHP
- Python 3.x per il server multiplayer

## Licenza
MIT License



