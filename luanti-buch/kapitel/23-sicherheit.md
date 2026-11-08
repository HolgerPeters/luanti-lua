---
title: Sicherheit
label: quality/security
---

Sicherheit ist sehr wichtig, damit dein Mod nicht dazu führt, dass der
Serverbetreiber Daten oder die Kontrolle verliert.

## Grundprinzipien

Das wichtigste Prinzip der Sicherheit lautet: **Vertraue niemals dem Benutzer.**
Alles, was ein Benutzer übermittelt, ist als bösartig zu behandeln. Prüfe also
immer, ob seine Eingaben gültig sind, ob er die nötigen Rechte hat und ob er die
Aktion auch sonst ausführen darf (also etwa in Reichweite oder Besitzer ist).

Eine bösartige Aktion muss nicht unbedingt Daten verändern oder zerstören; sie
kann auch auf sensible Daten zugreifen, etwa auf Passwort-Hashes oder private
Nachrichten. Besonders schlimm ist das, wenn der Server Angaben wie E-Mail-Adressen
oder das Alter speichert, wie es manche zur Verifizierung tun.

## Formspecs

### Eingaben niemals vertrauen

Jeder Benutzer kann fast jede Formspec mit beliebigen Werten jederzeit
abschicken.

Hier echter Code aus einem Mod:

```lua
core.register_on_player_receive_fields(function(player,
        formname, fields)
    for key, field in pairs(fields) do
        local x,y,z = string.match(key,
                "goto_([%d-]+)_([%d-]+)_([%d-]+)")
        if x and y and z then
            player:set_pos({ x=tonumber(x), y=tonumber(y),
                    z=tonumber(z) })
            return true
        end
    end
end)
```

Siehst du das Problem? Ein bösartiger Benutzer kann eine Formspec mit eigenen
Positionswerten abschicken und sich so an jeden beliebigen Ort teleportieren. Mit
modifizierten Clients ließe sich das sogar automatisieren – praktisch ein
`/teleport` ganz ohne Privileg.

Die Lösung für solche Probleme ist ein
[Kontext](../players/formspecs.html#contexts), wie im Kapitel über Formspecs
gezeigt.

### Zeitpunkt der Prüfung ist nicht Zeitpunkt der Verwendung

Jeder Benutzer kann jede Formspec mit beliebigen Werten jederzeit abschicken,
außer wo die Engine es verhindert:

* Die Eingabe einer Node-Formspec wird blockiert, wenn der Benutzer zu weit
  entfernt ist.
* Seit Version 5.0 werden benannte Formspecs blockiert, die noch nicht angezeigt
  wurden.

Prüfe deshalb im Handler, ob der Benutzer die Bedingungen erfüllt, unter denen
die Formspec überhaupt angezeigt wird, und ebenso die Bedingungen für die
jeweiligen Aktionen.

Die Sicherheitslücke, die entsteht, wenn Rechte beim Anzeigen der Formspec, aber
nicht beim Verarbeiten geprüft werden, heißt *Time of Check is not Time of Use*
(TOCTOU).

## (Unsichere) Umgebungen

Luanti erlaubt Mods, eine Umgebung ohne Sandbox anzufordern, die Zugriff auf die
vollständige Lua-API gibt.

Siehst du die Sicherheitslücke im folgenden Code?

```lua
local ie = core.request_insecure_environment()
ie.os.execute(("path/to/prog %d"):format(3))
```

`string.format` ist eine Funktion in der global geteilten Tabelle `string`. Ein
bösartiger Mod könnte diese Funktion überschreiben und so etwas an `os.execute`
übergeben:

```lua
string.format = function()
    return "xdg-open 'http://example.com'"
end
```

Der Mod könnte dabei viel Bösartigeres übergeben, als eine Website zu öffnen,
etwa einem entfernten Angreifer die Kontrolle über den Rechner geben.

Einige Regeln für unsichere Umgebungen:

* Speichere sie immer in einer lokalen Variablen und übergib sie nie an eine
  Funktion.
* Stelle sicher, dass du allen Eingaben an unsichere Funktionen vertrauen
  kannst, um das obige Problem zu vermeiden. Vermeide also global
  überschreibbare Funktionen.
