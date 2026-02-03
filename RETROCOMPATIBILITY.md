# Retrocompatibilità dei Deck

## Panoramica

Questo documento descrive le modifiche implementate per garantire la retrocompatibilità con i vecchi formati di deck.

## Formati Supportati

### Formato Corrente (v1.0.5+)
- **File**: JSON o XML singolo
- **Immagini**: Embedded come stringhe Base64 nel JSON/XML
- **Struttura JSON**:
  ```json
  {
    "deckName": "Nome Deck",
    "cards": [
      {
        "front_text": "Testo fronte",
        "back_text": "Testo retro",
        "front_media": "base64_string_or_empty",
        "back_media": "base64_string_or_empty"
      }
    ]
  }
  ```

### Formato Legacy (pre-v1.0.5)

#### Formato 1: ZIP con JSON/XML + Immagini
- **File**: ZIP contenente:
  - Un file JSON o XML con i dati delle carte
  - File immagini PNG/JPEG separati
- **Struttura JSON Legacy**:
  ```json
  {
    "deckName": "Nome Deck",
    "length": 10,
    "cards": [
      {
        "front_text": "Testo fronte",
        "back_text": "Testo retro",
        "front_media": ["1_front.png"],
        "back_media": ["2_back.jpg"]
      }
    ]
  }
  ```
- **Struttura XML Legacy**: Include tag `<media>` con riferimenti ai file esterni

#### Formato 2: JSON/XML standalone con array di immagini
- **File**: JSON o XML singolo
- **Immagini**: Array di nomi file (senza immagini effettive)
- Questo formato viene ora gestito ignorando gli array vuoti

## Implementazione

### Modifiche ai File

#### 1. `file_uploader.dart`
- Aggiunto supporto per file `.zip` nelle estensioni consentite
- Implementato metodo `_loadLegacyZipDeck()` per:
  - Estrarre il contenuto dello ZIP in una directory temporanea
  - Identificare il file JSON/XML e le immagini
  - Convertire le immagini da file a Base64
  - Pulire i file temporanei dopo il caricamento

#### 2. `extension_handler.dart`
- **`parseJson()`**: Aggiornato per gestire sia stringhe che array nel campo media
- **`parseLegacyJson()`**: Nuovo metodo per parsing di JSON da ZIP con conversione immagini
- **`parseLegacyXml()`**: Nuovo metodo per parsing di XML da ZIP con conversione immagini

#### 3. `pubspec.yaml`
- Aggiunta dipendenza `archive: ^3.6.1` per gestire file ZIP

### Flusso di Caricamento

```
Utente seleziona file
    |
    ├─> File .zip?
    |   └─> _loadLegacyZipDeck()
    |       ├─> Estrae ZIP in temp
    |       ├─> Identifica JSON/XML e immagini
    |       ├─> Converte immagini a Base64
    |       ├─> parseLegacyJson() o parseLegacyXml()
    |       └─> Pulisce temp
    |
    └─> File .json o .xml?
        └─> parseJson() o parseXml()
            └─> Gestisce sia string che array nei campi media
```

## Conversione Automatica

Quando un deck legacy viene caricato:

1. **Immagini esterne** (da ZIP) → Convertite in Base64 e embedded
2. **Array di immagini** → Convertiti in stringa singola (primo elemento) o vuoti
3. **Campo "length"** → Utilizzato se presente, altrimenti calcolato da array cards
4. **Riferimenti file** → Risolti e convertiti in dati inline

## Benefici

✅ I vecchi deck possono essere aperti senza errori  
✅ Le immagini dei deck legacy vengono preservate  
✅ Nessuna modifica richiesta ai deck esistenti  
✅ Formato corrente rimane invariato  
✅ Migrazione automatica al caricamento  

## Limitazioni

⚠️ Deck legacy JSON/XML standalone con array di nomi file ma senza ZIP:
- I nomi file vengono ignorati (immagini non disponibili)
- Le carte vengono caricate senza immagini

⚠️ Directory temporanea:
- Su Android richiede permessi storage
- Viene pulita dopo il caricamento ma potrebbero rimanere file in caso di errori

## Testing

Per testare la retrocompatibilità:

1. Creare o utilizzare un deck ZIP legacy
2. Aprirlo nell'app
3. Verificare che:
   - Le carte vengano caricate correttamente
   - Le immagini siano visibili
   - Nessun crash o errore

## Manutenzione Futura

- Il supporto legacy può essere rimosso in versioni future (es. v2.0.0)
- Considerare l'aggiunta di un tool di migrazione batch
- Monitorare l'uso dei formati legacy tramite analytics
