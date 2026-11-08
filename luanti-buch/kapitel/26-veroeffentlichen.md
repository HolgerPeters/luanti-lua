---
title: Einen Mod veröffentlichen
label: quality/releasing
---

Wenn du einen Mod veröffentlichst, können andere ihn nutzen. Ein veröffentlichter
Mod wird womöglich in Einzelspielerwelten oder auf Servern verwendet, auch auf
öffentlichen.

## Eine Lizenz wählen

Du musst für deinen Mod eine Lizenz angeben. Sie sagt anderen, auf welche Weise
sie dein Werk nutzen dürfen. Hat dein Mod keine Lizenz, wissen andere nicht, ob
sie ihn verändern, weitergeben oder auf einem öffentlichen Server einsetzen
dürfen.

Code und Grafiken stellen unterschiedliche Anforderungen an ihre Lizenzen.
Creative-Commons-Lizenzen solltest du zum Beispiel nicht für Quellcode
verwenden; für künstlerische Werke wie Bilder, Texte und Meshes können sie aber
gut geeignet sein.

Du darfst jede Lizenz verwenden. Mods, die keine Bearbeitungen erlauben, sind im
offiziellen Luanti-Forum allerdings nicht zugelassen. (Damit ein Mod im Forum
erlaubt ist, müssen andere Entwickler ihn verändern und die veränderte Fassung
veröffentlichen dürfen.)

Beachte, dass **Gemeinfreiheit (*public domain*) keine gültige Lizenz ist**,
weil sie in verschiedenen Ländern unterschiedlich definiert ist.

Von der WTFPL wird
[dringend abgeraten](https://content.luanti.org/help/wtfpl/) (englisch); manche
verzichten auf deinen Mod, wenn er unter dieser Lizenz steht.

### LGPL und CC BY-SA

Diese Kombination ist in der Luanti-Community verbreitet; auch Luanti und
Minetest Game verwenden sie.

Du stellst deinen Code unter die LGPL 2.1 und deine Grafiken unter CC BY-SA.

Das bedeutet:

* Jeder darf veränderte und unveränderte Fassungen bearbeiten, weitergeben und
  verkaufen.
* Wer deinen Mod verändert, muss seine Fassung unter dieselbe Lizenz stellen.
* Dein Urheberrechtsvermerk muss erhalten bleiben.

### CC0

Diese Lizenz eignet sich für Code und Grafiken und erlaubt jedem, mit deinem
Werk zu tun, was er will. Andere dürfen es also verändern, weitergeben,
verkaufen und auch ohne Namensnennung verwenden.

### MIT

Eine verbreitete Lizenz für Code. Die einzige Bedingung für Nutzer deines Codes
ist, dass sie in allen Kopien des Codes oder wesentlicher Teile davon denselben
Urheberrechtsvermerk und dieselbe Lizenz beifügen.

## Verpacken

Einige Dateien solltest du deinem Mod oder Spiel vor der Veröffentlichung
beilegen.

### README.txt

Die README sollte angeben:

* was der Mod oder das Spiel tut und wie man ihn benutzt,
* unter welcher Lizenz er steht,
* optional:
  * wo man Probleme melden oder Hilfe bekommen kann,
  * Danksagungen.

### mod.conf / game.conf

Füge unbedingt einen Schlüssel `description` hinzu, der erklärt, was dein Mod
oder Spiel tut. Fasse dich kurz, ohne vage zu werden. Die Beschreibung sollte kurz
sein, weil sie im Inhaltsinstaller angezeigt wird, wo wenig Platz ist.

Gutes Beispiel:

    description = Fügt Suppen, Kuchen, Gebäck und Säfte hinzu.

Vermeide so etwas:

    description = Der Essens-Mod für Luanti.

Das ist zu vage.

### screenshot.png

Screenshots sollten das Seitenverhältnis 3:2 haben (3 Pixel Breite auf 2 Pixel
Höhe) und mindestens 300 × 200 Pixel groß sein.

Der Screenshot wird in Luanti als Vorschaubild für den Inhalt angezeigt.

## Hochladen

Damit Interessierte deinen Mod herunterladen können, musst du ihn an einem
öffentlich zugänglichen Ort hochladen. Dafür gibt es mehrere Wege. Nimm den, der
für dich am besten passt, solange er diese Anforderungen erfüllt (und alle
weiteren, die Forenmoderatoren vielleicht noch hinzufügen):

* **Beständig** – Die Website sollte nicht ohne Vorwarnung abgeschaltet werden.
* **Direkter Link** – Ein Klick auf einen Link sollte die Datei herunterladen,
  ohne dass man erst eine andere Seite ansehen muss.
* **Virenfrei** – Unseriöse Upload-Dienste enthalten womöglich unsichere Werbung.

Bei ContentDB kannst du ZIP-Dateien hochladen; ContentDB erfüllt diese
Anforderungen.

### Versionsverwaltung

Ein Versionsverwaltungssystem (*Version Control System*, VCS) verwaltet
Änderungen an Software und macht es oft leichter, sie zu verbreiten und
Beiträge anderer anzunehmen.

Die meisten Luanti-Modder verwenden Git und eine Plattform wie GitHub, um ihren
Code zu verbreiten.

Git kann anfangs schwierig sein. Hilfe findest du hier:

* [Pro Git](https://git-scm.com/book/de/v2) – kostenlos online lesbar, auch auf
  Deutsch.

## Auf ContentDB veröffentlichen

ContentDB ist der offizielle Ort, um Inhalte wie Mods, Spiele und Texturpakete
zu finden und zu verbreiten. Benutzer finden Inhalte über die Website oder laden
und installieren sie direkt über das Hauptmenü von Luanti.

Registriere dich bei [ContentDB](https://content.luanti.org) und füge deinen
Inhalt hinzu. Lies unbedingt die Hinweise im Hilfebereich.

## Forenthema

Du kannst auch ein Forenthema anlegen, in dem Benutzer über dein Werk sprechen
können.

Themen für Mods gehören ins Forum
[„WIP Mods“](https://forum.luanti.org/viewforum.php?f=9) (*Work in Progress*),
Themen für Spiele ins Forum
[„WIP Games“](https://forum.luanti.org/viewforum.php?f=50). Wenn dein Mod für
dich nicht mehr in Arbeit ist, kannst du
[beantragen, dass das Thema verschoben wird](https://forum.luanti.org/viewtopic.php?f=11&t=10418),
und zwar nach „Mod Releases“.

Das Forenthema sollte ähnliche Inhalte wie die README haben, aber werbender
formuliert sein und einen Link zum Herunterladen enthalten. Wenn möglich, zeig
Screenshots deines Mods in Aktion.

Der Titel des Themas muss eines dieser Formate haben:

* [Mod] Titel des Mods [modname]
* [Mod] Titel des Mods [Versionsnummer] [modname]

Zum Beispiel:

* [Mod] More Blox [0.1] [moreblox]
