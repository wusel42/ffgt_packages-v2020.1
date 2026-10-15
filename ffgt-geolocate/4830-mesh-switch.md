# 4830-mesh-switch.sh

## Einbau und Größe

Die SH-Datei ersetzt
`ffgt-geolocate/files/lib/gluon/ffgt-geolocate/4830-mesh-switch.sh`.
Ausführungsrechte beibehalten. Diese Dokumentation und die Hosttests gehören
nicht ins Firmware-Image. Es werden keine neuen Laufzeitpakete benötigt:
POSIX-Shell, vorhandene BusyBox-Werkzeuge, UCI und gluon-switch-domain genügen.

Original: 5.212 Byte. Überarbeitung: 3.025 Byte, 2.187 Byte bzw. 42,0 % weniger.
Das ist die unkomprimierte Skriptgröße; die Einsparung im SquashFS hängt vom
Gesamtimage und dessen Kompressor ab.

## Initialisierung: locode hat Vorrang

Nach der Uptime-Prüfung (mindestens 900 Sekunden) und dem Setzen der Sperre
wird der wirksame locode bestimmt. Vor jeder externen Abfrage gilt:

| UCI-locode | UCI-domain | Verhalten |
| --- | --- | --- |
| gesetzt | beliebig, auch fehlend | locode beibehalten und dessen JSON-Datei prüfen |
| leer oder fehlend | gesetzt | domain als Kandidaten nehmen; dessen JSON-Datei prüfen; nur bei Erfolg als locode setzen und committen |
| leer oder fehlend | leer oder fehlend | Abbruch ohne Abfrage und ohne Commit |

Die Prüfung verlangt einen Namen aus ASCII-Buchstaben, Ziffern, `_` und `-`
sowie eine reguläre Datei `/lib/gluon/domains/<locode>.json`. Fehlt sie, wird
ohne Abfrage und ohne Konfigurationsänderung abgebrochen. Ein vorhandener
ungültiger locode wird auch bei gültiger domain nicht ersetzt.

Der so ermittelte locode ist im Skript `c`. Er wird im Query als `loc` gesendet
und für Zielvergleiche verwendet. Es gibt keinen allgemeinen Abgleich von
locode an gluon.core.domain. Die Sonderbehandlung beim tatsächlichen Wechsel
ist unten beschrieben.

Nach erfolgreicher Initialisierung wird ein bereits erfüllter Auftrag
(`tgtloc == locode`) aufgeräumt: tgtloc und switchtime werden gelöscht, sofern
vorhanden, und die Änderungen gemeinsam committed. Dann folgen die
MAC-basierte Verzögerung und die externe Abfrage.

## Abfrage und Antwort

IPv6 wird zuerst versucht, IPv4 nur nach einem Downloadfehler. Ein erfolgreicher
Download mit ungültigem Inhalt löst keinen IPv4-Versuch aus. Ohne gültige
Koordinaten oder lokal definierten aktuellen Branch entfällt die Abfrage.

Beispiel einer Antwort:

```text
DST: gt
FRM: 1792000000
AUB: stable
```

- DST ist genau einmal erforderlich und muss eine lokal vorhandene Domain sein.
- FRM und AUB dürfen fehlen oder leer sein, dürfen aber nicht mehrfach auftreten.
- Unbekannte Felder und andere unbekannte Zeilen werden ignoriert. Damit bleiben
  ältere Clients mit erweiterten Antworten kompatibel.
- Bekannte Felder müssen als `DST:`, `FRM:` oder `AUB:` am Zeilenanfang stehen.
  Nach dem Feldnamen darf höchstens ein durch Whitespace getrenntes Wort folgen.
  Doppelte bekannte Felder oder zusätzliche Wörter machen die Antwort ungültig.
- Leerzeilen sind zulässig. Das Format verwendet LF-Zeilenenden; CRLF wird
  nicht normalisiert. Antworten ohne gültiges DST werden verworfen.
- Domain- und Branchnamen dürfen nur ASCII-Buchstaben, Ziffern, `_` und `-` enthalten.
- Ein Branch ist nur erlaubt, wenn `uci -q get autoupdater.<name>` den
  Section-Typ `branch` liefert. Ohne AUB bleibt der bisherige Branch bestehen.
- FRM ist ein dezimaler Unix-Zeitstempel mit höchstens zehn Ziffern im Bereich
  0 bis 2147483647. Die Grenze berücksichtigt ältere 32-Bit-Systeme.
  Zeitmodell und Firmware müssen vor 2038 überprüft werden.

Koordinaten müssen Dezimalzahlen mit optionalem Vorzeichen sein. Breitengrad
liegt zwischen -90 und 90, Längengrad zwischen -180 und 180. Nullwerte sind
zulässig; Exponentialnotation nicht. LC_ALL=C legt den Dezimalpunkt fest.

Die MAC-Systemdatei gilt als vertrauenswürdig. Ihre letzte Oktette wird für
die Verzögerung geprüft. Für die URL gibt es keinen zusätzlichen Encoder;
Koordinatenformatierung und lokale Namensprüfungen begrenzen die anderen Werte.

## Auftrag und Wechsel

Nur eine erfolgreich heruntergeladene, gültige Antwort verändert den Auftrag:

- DST gleich wirksamem locode: tgtloc und switchtime löschen.
- Anderes DST: tgtloc setzen; FRM als switchtime übernehmen.
- Fehlendes oder leeres FRM: bisherige switchtime löschen; das andere Ziel bleibt
  ohne Ausführungsfreigabe vorgemerkt.

Der Branch wird wie im Original unmittelbar nach gültiger Antwort geändert,
auch wenn der Meshwechsel erst später stattfinden soll.

Ein gespeicherter Auftrag wird nach der Abfrage erneut gelesen. Er wird nur
bei gültigem, abweichendem Ziel, gültiger switchtime und `now >= switchtime`
ausgeführt. Das Original verwendete `now > switchtime`.

Vor gluon-switch-domain wird locode auf das Ziel gesetzt, bei tatsächlicher
Änderung committed und sync ausgeführt. Das ist notwendig, weil das
Boot-Migrationsskript 004-migrate-ffgt-locode aus locode die Gluon-Domain setzt.
Der Wechselauftrag bleibt erhalten. Meldet der Wechselbefehl einen Fehler
zurück, stellt das Skript den vorherigen locode wieder her und committed die
Wiederherstellung nur bei Änderung. Beim nächsten Lauf wird ein Auftrag mit
`tgtloc == locode` aufgeräumt; eine zusätzliche Verifikation der Gluon-Domain
findet dabei nicht statt.

Downloadfehler und ungültige Antworten verändern den gespeicherten Auftrag
nicht. Ein zuvor gespeicherter fälliger Auftrag darf dann weiterhin ausgeführt
werden. Gleiches gilt bei fehlenden Koordinaten. Diese Offline-Ausführung
entspricht dem bisherigen Verhalten. Ein Fehler ist kein Widerruf.

## Commits, Sperre und Fehler

Vor Set wird der Wert verglichen, vor Delete die Existenz geprüft. Nur eine
erfolgreiche tatsächliche Änderung setzt das Änderungsflag. Standortänderungen
werden pro Arbeitsschritt gemeinsam committed; bei unveränderten Werten
entfällt der Commit. Auch der Branch wird nur bei Änderung committed.
UCI-Set-, Delete- und Commitfehler brechen den Lauf ab.

Die Sperre `/tmp/mesh-switch.lock` wird atomar mit mkdir angelegt. Antwortdateien
liegen darin. Normales Ende sowie HUP, INT und TERM entfernen sie. Nach SIGKILL
bleibt sie bis zum Neustart bestehen und kann nach Prüfung auf laufende
Instanzen manuell entfernt werden.

Es gibt keine vollständige Transaktion über Standortpaket, Autoupdater-Paket,
Gluon-Domain und Neustart. Flashfehler, Stromausfall oder fremde UCI-Schreiber
können Zwischenzustände hinterlassen. Insbesondere kann ein Boot nach dem
Commit des Ziel-locode bereits die Zieldomain übernehmen, bevor der Aufruf von
gluon-switch-domain erfolgt ist. Ein pauschales uci revert wird vermieden, um
keine Änderungen anderer Programme zu verwerfen.

Die Commit-Vermeidung gilt für dieses Skript. Das unveränderte Boot-Migrationsskript
committed gluon selbst auch ohne Wertänderung; Writes innerhalb externer
Programme werden hier nicht gesteuert.

HTTP bleibt wegen der Platzvorgabe erhalten. Werteprüfung authentisiert den
Server nicht; zusätzliche Kryptografie ist nicht enthalten.

## Variablen und Funktionen

| Name | Bedeutung |
| --- | --- |
| q / g / s | UCI-Aufruf / Standortoption lesen / bei geändertem Wert setzen |
| e / save / h | vorhandene Option löschen / bei Änderung committen / Änderungsflag |
| num / domain / branch | Zeitstempel / lokale Domain-Datei / lokalen Branch prüfen |
| c / l | wirksamer locode / vorheriger locode zur Fehlerwiederherstellung |
| t / u | Ziel / Umschaltzeit |
| b / a | bisheriger / angeforderter Branch |
| d | empfangene Zieldomain |
| m / x | MAC / letzte MAC-Oktette |
| p / f | Koordinatenparameter / Antwortdatei |

## Prüfung

`sh -n 4830-mesh-switch.sh` prüft die Shellsyntax.
`python3 test-mesh-switch.py` führt isolierte Hosttests mit simulierten
UCI-, Download-, Zeit-, Warte- und Wechselbefehlen aus. Echte Routerkonfiguration
und Netzwerk werden nicht verändert.

48 Assertions prüfen insbesondere alle Initialisierungsfälle aus der Tabelle,
abweichende oder fehlende domain bei gültigem locode, fehlende JSON-Dateien,
Abbruch ohne Query und Commit, den loc-Queryparameter, gültige und ungültige
Antworten, unbekannte Felder, Wechsel und Fehlerwiederherstellung, Offline-Aufträge,
Koordinaten sowie unnötige Commits.

Vor dem Einsatz auf der konkreten Firmware sind Domain-Dateipfade,
UCI-Branchdefinitionen und das Verhalten von gluon-switch-domain zu prüfen.
Die Hosttests laufen nicht mit der konkreten Router-BusyBox und ersetzen keinen
Hardwaretest einschließlich Neustart.

Referenz für den Boot-Ablauf:
https://raw.githubusercontent.com/wusel42/ffgt_packages-v2020.1/refs/heads/master/ffgt-config-mode-wizard/files/lib/gluon/upgrade/004-migrate-ffgt-locode
