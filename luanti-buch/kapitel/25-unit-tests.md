---
title: Automatische Unit-Tests
label: quality/unit-testing
---

Unit-Tests sind ein unverzichtbares Werkzeug, um nachzuweisen und dich zu
vergewissern, dass dein Code korrekt ist. Dieses Kapitel zeigt, wie du mit
*Busted* Tests für Luanti-Mods und -Spiele schreibst. Funktionen zu testen, die
Luanti-Funktionen aufrufen, ist ziemlich schwierig. Zum Glück haben wir
[im vorigen Kapitel](../quality/clean_arch.html) besprochen, wie du deinen Code
so aufbaust, dass sich das vermeiden lässt.

## Busted installieren

Zuerst installierst du LuaRocks:

* Windows: Folge der
  [Installationsanleitung im LuaRocks-Wiki](https://github.com/luarocks/luarocks/wiki/Installation-instructions-for-Windows)
  (englisch).
* Debian/Ubuntu: `sudo apt install luarocks`

Dann installierst du Busted global:

    sudo luarocks install busted

Zum Schluss prüfst du, ob es installiert ist:

    busted --version

## Dein erster Test

Busted ist das führende Framework für Unit-Tests in Lua. Es sucht nach
Lua-Dateien, deren Name auf `_spec` endet, und führt sie in einer eigenständigen
Lua-Umgebung aus.

    mymod/
    ├── init.lua
    ├── api.lua
    └── tests
        └── api_spec.lua

### init.lua

```lua
mymod = {}

dofile(core.get_modpath("mymod") .. "/api.lua")
```

### api.lua

```lua
function mymod.add(x, y)
    return x + y
end
```

### tests/api_spec.lua

```lua
-- Benötigte Dateien im Mod-Verzeichnis suchen
package.path = "./?.lua;" .. package.path

-- Globale Tabelle mymod anlegen, in die die API schreibt
_G.mymod = {}
-- api.lua ausführen
require("api")

-- Tests
describe("add", function()
    it("addiert", function()
        assert.equals(2, mymod.add(1, 1))
    end)

    it("kann mit negativen Zahlen umgehen", function()
        assert.equals(0,  mymod.add(-1,  1))
        assert.equals(-2, mymod.add(-1, -1))
    end)
end)
```

Jetzt kannst du die Tests ausführen, indem du im Verzeichnis des Mods ein
Terminal öffnest und `busted .` aufrufst.

Wichtig ist, dass die API-Datei die Tabelle nicht selbst anlegt, denn globale
Variablen funktionieren in Busted anders. Jede Variable, die in Luanti global
wäre, ist in Busted lokal zur Datei. Das wäre auch für Luanti der bessere Weg
gewesen, aber dafür ist es jetzt zu spät.

Außerdem sollten die Dateien, die du testest, möglichst keine Funktionen aufrufen,
die nicht in ihnen selbst stehen. Meist schreibst du Tests jeweils nur für eine
einzelne Datei.

## Mocking: Externe Funktionen ersetzen

*Mocking* heißt, Funktionen zu ersetzen, von denen das Getestete abhängt. Das hat
zwei Zwecke: Zum einen steht die Funktion in der Testumgebung womöglich nicht zur
Verfügung, zum anderen möchtest du vielleicht Aufrufe der Funktion und ihre
Argumente mitschneiden.

Hast du die Ratschläge aus dem Kapitel
[Saubere Architektur](../quality/clean_arch.html) befolgt, hast du schon eine
recht saubere Datei zum Testen. Dinge außerhalb deines Bereichs musst du aber
trotzdem ersetzen – etwa die View, wenn du Controller oder API testest. Hast du
die Ratschläge nicht befolgt, wird es etwas schwieriger, weil du womöglich die
Luanti-API ersetzen musst.

```lua
-- Wie oben eine Tabelle anlegen
_G.core = {}

-- Die Mock-Funktion definieren
local chat_send_player_calls = {}
function core.chat_send_player(name, message)
    table.insert(chat_send_player_calls,
            { name = name, message = message })
end

-- Tests
describe("list_areas", function()
    it("gibt eine Zeile je Gebiet aus", function()
        chat_send_player_calls = {} -- Tabelle zurücksetzen

        mymod.list_areas_to_chat("singleplayer", "singleplayer")

        assert.equals(2, #chat_send_player_calls)
    end)

    it("sendet an den richtigen Spieler", function()
        chat_send_player_calls = {} -- Tabelle zurücksetzen

        mymod.list_areas_to_chat("singleplayer", "singleplayer")

        for _, call in pairs(chat_send_player_calls) do
            assert.equals("singleplayer", call.name)
        end
    end)

    -- Die beiden Tests oben sind eigentlich überflüssig,
    -- denn dieser prüft beides
    it("gibt das Richtige aus", function()
        chat_send_player_calls = {} -- Tabelle zurücksetzen

        mymod.list_areas_to_chat("singleplayer", "singleplayer")

        local expected = {
            { name = "singleplayer", message = "Rathaus (2,43,63)" },
            { name = "singleplayer", message = "Flughafen (43,45,63)" },
        }
        assert.same(expected, chat_send_player_calls)
    end)
end)
```

## Fazit

Gut eingesetzt, verbessern Unit-Tests die Qualität und Zuverlässigkeit deines
Projekts erheblich. Sie verlangen aber, dass du deinen Code anders aufbaust als
üblich.

Ein Beispiel für einen Mod mit vielen Unit-Tests ist
[crafting von rubenwardy](https://github.com/rubenwardy/crafting).
