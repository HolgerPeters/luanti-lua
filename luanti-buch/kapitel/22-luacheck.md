---
title: Automatische Fehlersuche mit LuaCheck
label: quality/luacheck
---

In diesem Kapitel lernst du, wie du deinen Mod mit dem Werkzeug LuaCheck
automatisch nach Fehlern durchsuchst. LuaCheck lässt sich mit deinem Editor
verbinden, der dich dann auf Fehler hinweist.

## LuaCheck installieren

### Windows

Lade einfach `luacheck.exe` von der
[Release-Seite auf GitHub](https://github.com/lunarmodules/luacheck/releases)
herunter.

### Linux

Installiere zuerst LuaRocks:

    sudo apt install luarocks

Dann installierst du LuaCheck global:

    sudo luarocks install luacheck

Mit diesem Befehl prüfst du, ob die Installation geklappt hat:

    luacheck -v

## LuaCheck ausführen

Beim ersten Durchlauf meldet LuaCheck wahrscheinlich viele Fehler, die keine
sind. Das liegt daran, dass es noch nicht eingerichtet ist.

Unter Windows öffnest du PowerShell oder Bash im Hauptordner deines Projekts und
führst `path\to\luacheck.exe .` aus.

Unter Linux führst du im Hauptordner deines Projekts `luacheck .` aus.

## LuaCheck einrichten

Lege im Hauptordner deines Projekts eine Datei `.luacheckrc` an. Das kann der
Hauptordner deines Spiels, Mod-Pakets oder Mods sein.

Schreib Folgendes hinein:

```lua
unused_args = false
allow_defined_top = true

globals = {
    "core",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Eingebaut
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- Minetest Game
    "default", "sfinv", "creative",
}
```

Verwendest du in älterem Code noch den Namensraum `minetest`, nimm ihn
zusätzlich in `globals` auf.

Prüfe dann mit einem neuen Durchlauf, ob es funktioniert. Diesmal solltest du
deutlich weniger Fehler bekommen. Arbeite dich ab dem ersten Fehler durch:
Behebe das Problem im Code oder passe die Konfiguration an, wenn der Code
korrekt ist. Hilfe dazu gibt die folgende Liste.

### Fehlerbehebung

* **accessing undefined variable foobar** – Soll `foobar` eine globale Variable
  sein, nimm sie in `read_globals` auf. Andernfalls ergänze die fehlenden
  `local`.
* **setting non-standard global variable foobar** – Soll `foobar` eine globale
  Variable sein, nimm sie in `globals` auf und entferne sie gegebenenfalls aus
  `read_globals`. Andernfalls ergänze die fehlenden `local`.
* **mutating read-only global variable 'foobar'** – Verschiebe `foobar` von
  `read_globals` nach `globals` oder schreib nicht mehr in `foobar`.

## Im Editor verwenden

Es ist sehr zu empfehlen, für deinen Editor eine Erweiterung zu installieren,
die Fehler anzeigt, ohne dass du einen Befehl ausführen musst. Für die meisten
Editoren gibt es eine.

* **VSCode** – Strg+P drücken und dann einfügen:
  `ext install dwenegar.vscode-luacheck`
* **Sublime Text** – Über Package Control installieren:
  [SublimeLinter](https://github.com/SublimeLinter/SublimeLinter) und
  [SublimeLinter-luacheck](https://github.com/SublimeLinter/SublimeLinter-luacheck).
