---
title: Spiele erstellen
label: games/games
---

Die Stärke von Luanti liegt darin, dass sich Spiele einfach entwickeln lassen,
ohne eigene Voxel-Grafik, Voxel-Algorithmen oder ausgefeilten Netzwerkcode
schreiben zu müssen.

## Was ist ein Spiel?

Ein Spiel ist eine Sammlung von Mods, die zusammen ein stimmiges Ganzes ergeben.
Ein gutes Spiel hat ein durchgängiges Thema und eine Richtung: Es kann zum
Beispiel ein klassisches Bau- und Abbauspiel mit harten Überlebenselementen sein
oder eine Weltraumsimulation mit Steampunk-Automatisierung.

Spieldesign ist ein komplexes Thema und ein eigenes Fachgebiet. Dieses Buch kann
es nur kurz streifen.

## Spielverzeichnis

Aufbau und Ort eines Spiels kommen dir nach der Arbeit mit Mods recht vertraut
vor. Spiele liegen in einem Spielverzeichnis, etwa `minetest/games/foo_game`.

    foo_game
    ├── game.conf
    ├── menu
    │   ├── header.png
    │   ├── background.png
    │   └── icon.png
    ├── minetest.conf
    ├── mods
    │   └── ... Mods
    ├── README.txt
    └── settingtypes.txt

Nötig ist nur der Ordner `mods`; `game.conf` und `menu/icon.png` werden aber
empfohlen. Eine einfache `game.conf` sieht so aus:

```
title = Foo Game
description = Ein Spiel über Foo.
```

## Kompatibilität zwischen Spielen

### API-Kompatibilität

Es lohnt sich, so viel API-Kompatibilität mit Minetest Game zu wahren, wie es
sich einrichten lässt. Dann lassen sich Mods viel leichter auf ein anderes Spiel
übertragen.

Am besten wahrst du die Kompatibilität mit einem anderen Spiel, indem du die
API-Kompatibilität mit gleichnamigen Mods wahrst. Trägt ein Mod denselben Namen
wie ein anderer – auch wie ein Mod von Dritten –, sollte er also eine kompatible
API haben. Enthält ein Spiel zum Beispiel einen Mod namens `doors`, sollte er
dieselbe API haben wie `doors` in Minetest Game.

Die API-Kompatibilität eines Mods setzt sich zusammen aus:

* der Lua-API-Tabelle – alle dokumentierten oder beworbenen Funktionen in der
  gleichnamigen globalen Tabelle, zum Beispiel `mobs.register_mob`;
* den registrierten Nodes und Items – also dass diese vorhanden sind.

Kleine Brüche sind nicht so schlimm, etwa wenn eine beiläufige Hilfsfunktion
fehlt, die eigentlich nur intern verwendet wurde. Größere Brüche bei
Kernfunktionen sind dagegen sehr schlecht.

Mit einem riesigen Alleskönner-Mod wie *default* in Minetest Game ist
API-Kompatibilität kaum zu wahren. In diesem Fall sollte das Spiel keinen Mod
namens `default` enthalten.

API-Kompatibilität betrifft auch andere Mods und Spiele von Dritten. Achte also
darauf, dass neue Mods einen eindeutigen Namen haben. Ob ein Mod-Name schon
vergeben ist, findest du mit einer Suche auf
[content.luanti.org](https://content.luanti.org/) heraus.

### Gruppen und Aliase

Gruppen und Aliase helfen beide, die Kompatibilität zwischen Spielen zu wahren,
denn mit ihnen dürfen sich Itemnamen zwischen Spielen unterscheiden. Häufige
Nodes wie Stein und Holz sollten Gruppen haben, die das Material angeben. Es ist
außerdem sinnvoll, Aliase von `default`-Nodes auf ihre direkten Entsprechungen
anzulegen.

## Jetzt bist du dran

* Erstelle ein einfaches Spiel, in dem der Spieler Punkte bekommt, wenn er
  besondere Blöcke abbaut.
