---
title: Erste Schritte
label: basics/getting-started
---

Den grundlegenden Aufbau eines Mod-Verzeichnisses zu verstehen, ist beim
Erstellen von Mods unerlässlich. In diesem Kapitel erfährst du, wie Modding in
Luanti funktioniert, und erstellst deinen ersten Mod.

## Was sind Spiele und Mods?

Die Stärke von Luanti liegt darin, dass sich Spiele einfach entwickeln lassen,
ohne eigene Voxel-Grafik, Voxel-Algorithmen oder ausgefeilten Netzwerkcode
schreiben zu müssen.

In Luanti ist ein Spiel eine Sammlung von Modulen, die zusammenarbeiten, um den
Inhalt und das Verhalten des Spiels bereitzustellen. Ein Modul, allgemein als
Mod bezeichnet, ist eine Sammlung von Skripten und Ressourcen. Es ist möglich,
ein Spiel mit nur einem Mod zu erstellen, aber das wird selten gemacht, weil
sich dann Teile des Spiels nicht mehr so einfach unabhängig voneinander
anpassen oder ersetzen lassen.

Ebenso ist es möglich, Mods außerhalb eines Spiels zu verbreiten. Dann sind sie
ebenfalls *Mods*, aber im traditionelleren Sinn: *Modifikationen*. Diese Mods
verändern oder erweitern die Eigenschaften eines Spiels.

Sowohl die Mods, die in einem Spiel enthalten sind, als auch Mods von Dritten
nutzen dieselbe API (Programmierschnittstelle).

Dieses Buch behandelt die wichtigsten Teile der Luanti-API und richtet sich
gleichermaßen an Spieleentwickler und Modder.

## Wo werden die Mods gespeichert?

Jeder Mod hat sein eigenes Verzeichnis, in dem sich seine Lua-Quelltexte,
Texturen, Modelle und Tondateien befinden. Luanti sucht an verschiedenen Orten
nach Mods. Diese Orte werden allgemein *Mod-Ladepfade* genannt.

Für eine bestimmte Welt werden drei Mod-Speicherorte geprüft, und zwar in
dieser Reihenfolge:

1. Spiel-Mods. Das sind die Mods des Spiels, in dem die Welt läuft.\
   Z.\ B.: `minetest/games/minetest_game/mods/` oder\
   `/usr/share/minetest/games/minetest/`
2. Globale Mods. Der Ort, an dem Mods fast immer installiert werden.
   Im Zweifelsfall legst du Mods hier ab.\
   Z.\ B.: `minetest/mods/`
3. Welt-Mods. Der Ort für Mods, die zu einer bestimmten Welt gehören.\
   Z.\ B.: `minetest/worlds/world/worldmods/`

`minetest` ist das Benutzerdatenverzeichnis. Seinen Ort findest du, indem du
Luanti öffnest und in der Registerkarte „Über“ auf „Benutzerdatenverzeichnis
öffnen“ klickst. Wurde Luanti über Flathub installiert, passiert bei diesem
Klick unter Umständen nichts. Das Verzeichnis liegt dann normalerweise unter
`~/.var/app/org.luanti.luanti/.minetest/`.

Beim Laden prüft Luanti die oben genannten Orte der Reihe nach. Stößt es auf
einen Mod mit demselben Namen wie ein zuvor gefundener, wird der spätere anstelle
des früheren geladen. Du kannst also Spiel-Mods überschreiben, indem du einen
gleichnamigen Mod in das globale Mod-Verzeichnis legst.

## Deinen ersten Mod erstellen

### Mod-Verzeichnis

Geh in das globale Mod-Verzeichnis (Über > Benutzerdatenverzeichnis
öffnen > mods) und lege einen neuen Ordner namens `mymod` an. `mymod` ist
der Name des Mods.

Jeder Mod sollte einen eindeutigen *Mod-Namen* haben, eine technische Kennung
(ID), über die auf den Mod verwiesen wird. Mod-Namen dürfen Buchstaben, Ziffern
und Unterstriche enthalten. Ein guter Name beschreibt, was der Mod tut. Das
Verzeichnis mit den Bestandteilen eines Mods muss genauso heißen wie der Mod.
Ob ein Mod-Name noch frei ist, findest du mit einer Suche auf
[content.luanti.org](https://content.luanti.org) heraus.

    mymod
    ├── textures
    │   └── mymod_node.png
    ├── init.lua
    └── mod.conf

Ein Mod benötigt nur eine `init.lua`. Eine `mod.conf` wird jedoch empfohlen, und
je nach Funktionsumfang können weitere Bestandteile nötig sein.

### mod.conf

Lege eine Datei `mod.conf` mit folgendem Inhalt an:

```
name = mymod
description = Fügt foo, bar und bo hinzu.
depends = default
```

Diese Datei enthält die Metadaten des Mods, darunter seinen Namen, seine
Beschreibung und weitere Angaben.

### init.lua

Lege eine Datei `init.lua` mit folgendem Inhalt an:

```lua
print("Diese Datei wird beim Laden ausgeführt!")

core.register_node("mymod:node", {
    description = "Das ist ein Node",
    tiles = {"mymod_node.png"},
    groups = {cracky = 1}
})

core.register_craft({
    type = "shapeless",
    output = "mymod:node 3",
    recipe = { "default:dirt", "default:stone" },
})
```

Die `init.lua` ist der Einstiegspunkt eines Mods und wird ausgeführt, wenn der
Mod geladen wird.

### Zusammenfassung

Dieser Mod heißt „mymod“. Er besteht aus zwei Textdateien: `init.lua` und
`mod.conf`. Das Skript gibt eine Nachricht aus und registriert dann einen Node
und ein Handwerksrezept – beides wird später erklärt. Es gibt eine einzige
Abhängigkeit, den [default-Mod](https://content.luanti.org/metapackages/default/),
der normalerweise in Minetest Game enthalten ist. Außerdem liegt in `textures/`
eine Textur für den Node.

## Abhängigkeiten

Eine Abhängigkeit besteht, wenn ein Mod einen anderen Mod benötigt, der vor ihm
geladen werden muss. Ein Mod kann darauf angewiesen sein, dass Code, Gegenstände
oder andere Ressourcen eines anderen Mods verfügbar sind.

Es gibt zwei Arten von Abhängigkeiten: feste und optionale. Bei beiden wird der
andere Mod zuerst geladen. Ist der Mod, von dem abgehangen wird, nicht
verfügbar, führt eine feste Abhängigkeit dazu, dass der eigene Mod nicht geladen
wird, während eine optionale Abhängigkeit höchstens dazu führt, dass weniger
Funktionen zur Verfügung stehen.

Eine optionale Abhängigkeit ist nützlich, wenn du einen anderen Mod optional
unterstützen möchtest; so lassen sich zusätzliche Inhalte aktivieren, wenn der
Benutzer beide Mods gleichzeitig verwendet.

Abhängigkeiten werden in der `mod.conf` als kommagetrennte Liste angegeben:

    depends = modeins, modzwei
    optional_depends = moddrei

## Mod-Pakete

Mods lassen sich zu Mod-Paketen (Modpacks) zusammenfassen, sodass mehrere Mods
gemeinsam verpackt und verschoben werden können. Das ist nützlich, wenn du
einem Spieler mehrere Mods bereitstellen möchtest, ohne dass er jeden einzeln
herunterladen muss.

    modpack1
    ├── modpack.conf (erforderlich, kennzeichnet Mod-Paket)
    ├── mod1
    │   └── ... Mod-Dateien
    └── mymod (optional)
        └── ... Mod-Dateien

Beachte, dass ein Mod-Paket kein *Spiel* ist. Spiele haben eine eigene
Verzeichnisstruktur, die im Kapitel „Spiele“ erklärt wird.
