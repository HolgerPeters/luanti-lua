---
title: Chat und Befehle
label: players/chat
---

Mods können mit dem Spielerchat arbeiten: Nachrichten senden, Nachrichten
abfangen und Chatbefehle registrieren.

## Nachrichten senden

### An alle Spieler

Um eine Nachricht an alle Spieler im Spiel zu senden, rufst du
`chat_send_all` auf:

```lua
core.chat_send_all("Das ist eine Chatnachricht an alle Spieler")
```

Im Spiel sieht das zum Beispiel so aus:

    <player1> Schau dir diesen Eingang an
    Das ist eine Chatnachricht an alle Spieler
    <player2> Was ist damit?

Die Nachricht steht in einer eigenen Zeile, damit man sie vom Chat der Spieler
unterscheiden kann.

### An bestimmte Spieler

Um eine Nachricht an einen bestimmten Spieler zu senden, rufst du
`chat_send_player` auf:

```lua
core.chat_send_player("player1", "Diese Nachricht ist für player1")
```

Die Nachricht wird genauso angezeigt wie Nachrichten an alle Spieler, ist aber
nur für den genannten Spieler sichtbar, hier also für `player1`.

## Chatbefehle

Einen Chatbefehl, zum Beispiel `/foo`, registrierst du mit
`register_chatcommand`:

```lua
core.register_chatcommand("foo", {
    params = "<text>",
    description = "Wiederholt den Text",
    privs = {
        interact = true,
    },
    func = function(name, param)
        return true, "Du hast " .. param .. " gesagt!"
    end,
})
```

Hier ist `interact` als nötiges [Privileg](../players/privileges.html)
angegeben; nur Spieler mit dem Privileg `interact` können den Befehl also
ausführen. `params` und `description` erscheinen in der Hilfe, die `/help`
anzeigt.

`param` ist ein String mit allem, was der Spieler nach dem Namen des Befehls
schreibt. Tippt jemand zum Beispiel `/grantme one,two,three`, ist `param` gleich
`one,two,three`.

Chatbefehle können bis zu zwei Werte zurückgeben: zuerst einen Wahrheitswert,
der angibt, ob der Befehl erfolgreich war, und dann eine Nachricht an den
Benutzer.

::: {.warning title="Auch Offline-Spieler können Befehle ausführen"}
Statt eines Spielerobjekts wird ein Spielername übergeben, weil Mods Befehle im
Namen von Spielern ausführen können, die nicht online sind. Die IRC-Brücke
erlaubt Spielern zum Beispiel, Befehle auszuführen, ohne dem Spiel beizutreten.

Geh also nicht davon aus, dass der Spieler online ist. Das kannst du prüfen,
indem du schaust, ob `core.get_player_by_name` einen Spieler zurückgibt.
:::

### Mehrere Argumente

`param` enthält alle Argumente eines Chatbefehls in einem einzigen String. Oft
muss ein Befehl daraus mehrere Argumente herauslösen. Dafür gibt es zwei Wege:
die String-Funktion `split` von Luanti oder Lua-Patterns.

#### Mit string.split

Mit `string.split(" ")` zerlegst du einen String in Wörter:

```lua
local parts = param:split(" ")
local cmd = parts[1]

if cmd == "join" then
    local team_name = parts[2]
    team.join(name, team_name)
    return true, "Team beigetreten!"
elseif cmd == "max_users" then
    local team_name = parts[2]
    local max_users = tonumber(parts[3])
    if team_name and max_users then
        return true, "Maximale Spielerzahl von " .. team_name ..
            " auf " .. max_users .. " gesetzt"
    else
        return false, "Aufruf: /team max_users <team_name> <zahl>"
    end
else
    return false, "Befehl fehlt"
end
```

#### Mit Lua-Patterns

Mit [Lua-Patterns](https://www.lua.org/pil/20.2.html) (englisch) ziehst du
anhand von Regeln Teile aus einem Text heraus. Sie eignen sich am besten, wenn
Argumente Leerzeichen enthalten können oder du genauer steuern willst, wie
Parameter erfasst werden.

```lua
local to, msg = param:match("^([%a%d_-]+) (.+)$")
```

Dieser Code setzt `/msg <an> <nachricht>` um. Gehen wir ihn von links nach
rechts durch:

* `^` passt auf den Anfang des Strings.
* `()` ist eine Gruppe – was darin passt, gibt `string.match` zurück.
* `[]` akzeptiert die Zeichen in dieser Liste.
* `%a` akzeptiert jeden Buchstaben, `%d` jede Ziffer.
* `[%a%d_-]` akzeptiert also jeden Buchstaben, jede Ziffer, `_` und `-`.
* `+` passt, wenn das Vorherige ein- oder mehrmals vorkommt.
* `.` passt hier auf jedes beliebige Zeichen.
* `$` passt auf das Ende des Strings.

Kurz gesagt: Das Pattern erfasst den Namen (ein Wort nur aus Buchstaben,
Ziffern, `-` und `_`), dann ein Leerzeichen, dann die Nachricht (ein oder mehr
beliebige Zeichen). Name und Nachricht werden zurückgegeben, weil sie in
Klammern stehen.

So setzen die meisten Mods komplexe Chatbefehle um. Ausführlichere Anleitungen
zu Lua-Patterns sind das
[Tutorial auf lua-users.org](http://lua-users.org/wiki/PatternsTutorial)
(englisch) und die [Dokumentation in PIL](https://www.lua.org/pil/20.2.html)
(englisch).

## Nachrichten abfangen

Um Nachrichten abzufangen, verwendest du `register_on_chat_message`:

```lua
core.register_on_chat_message(function(name, message)
    print(name .. " sagt " .. message)
    return false
end)
```

Mit `return false` lässt du zu, dass die Nachricht wie üblich gesendet wird. Du
könntest die Zeile `return false` auch weglassen, ohne dass sich etwas ändert,
denn dann wird implizit `nil` zurückgegeben, und das wird wie `false`
behandelt.

::: {.warning title="Privilegien und Chatbefehle"}
Ein Spieler braucht das Privileg `shout` nicht, um diesen Callback auszulösen.
Chatbefehle sind nämlich in Lua umgesetzt und einfach Chatnachrichten, die mit
`/` beginnen.
:::

Berücksichtige also, dass es sich um einen Chatbefehl handeln kann oder dass dem
Spieler `shout` fehlt.

```lua
core.register_on_chat_message(function(name, message)
    if message:sub(1, 1) == "/" then
        print(name .. " hat einen Chatbefehl ausgeführt")
    elseif core.check_player_privs(name, { shout = true }) then
        print(name .. " sagt " .. message)
    else
        print(name .. " wollte " .. message ..
                " sagen, hat aber kein shout")
    end

    return false
end)
```
