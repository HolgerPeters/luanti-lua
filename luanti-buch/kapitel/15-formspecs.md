---
title: GUIs (Formspecs)
label: players/formspecs
---

In diesem Kapitel lernst du, wie du eine Formspec erstellst und dem Spieler
anzeigst. Eine Formspec ist der Beschreibungscode für ein Formular. Formulare
sind in Luanti Fenster wie das Spielerinventar und können verschiedene Elemente
enthalten, etwa Beschriftungen, Schaltflächen und Eingabefelder.

![Formspec eines Ofens mit Beschriftung der Elemente](bilder/formspec_example.png){width=5cm}

Musst du keine Eingaben vom Spieler entgegennehmen, sondern ihm nur
Informationen anzeigen, solltest du statt eines Formulars lieber
[HUD-Elemente](../players/hud.html) verwenden. Unerwartet aufgehende Fenster
stören nämlich meist das Spiel.

## Echte oder alte Koordinaten

In älteren Versionen von Luanti waren Formspecs uneinheitlich. Elemente wurden
auf unerwartet unterschiedliche Weise positioniert; es war schwer
vorherzusagen, wo sie landen, und sie aneinander auszurichten. Luanti 5.1.0
führte daher *echte Koordinaten* (*real coordinates*) ein, ein einheitliches
Koordinatensystem. Echte Koordinaten sind sehr zu empfehlen, deshalb verwendet
dieses Kapitel ausschließlich sie.

Ab `formspec_version` 2 sind echte Koordinaten eingeschaltet.

## Aufbau einer Formspec

### Elemente

Formspec ist eine domänenspezifische Sprache mit einem ungewöhnlichen Format.
Sie besteht aus Elementen dieser Form:

    typ[param1;param2]

Zuerst steht der Elementtyp, dann folgen die Parameter in eckigen Klammern.
Mehrere Elemente können direkt aneinandergehängt oder auf mehrere Zeilen
verteilt werden:

    foo[param1]bar[param1]
    bo[param1]

Elemente sind zum Beispiel Textfelder oder Schaltflächen, können aber auch
Metadaten wie Größe oder Hintergrund sein. Eine Liste aller Elemente findest du
in der [Lua-API-Referenz](https://api.luanti.org/formspec/).

### Kopf

Der Kopf einer Formspec enthält Angaben, die zuerst stehen müssen: die Größe
der Formspec, ihre Position, den Anker und ob das spielweite Theme angewendet
werden soll.

Die Elemente im Kopf müssen in einer bestimmten Reihenfolge stehen, sonst gibt
es einen Fehler. Diese Reihenfolge ist die im vorigen Absatz genannte; sie ist,
wie immer, auch in der Lua-API-Referenz dokumentiert.

Die Größe wird in Formspec-Feldern angegeben, einer Maßeinheit von ungefähr
64 Pixeln, die aber je nach Bildschirmdichte und Skalierungseinstellungen des
Clients schwankt. Hier eine Formspec der Größe `2,2`:

    formspec_version[4]
    size[2,2]

Beachte, dass wir die Sprachversion der Formspec ausdrücklich angegeben haben.
Ohne sie wird das alte System verwendet, und du kannst weder die einheitliche
Positionierung noch andere neue Funktionen nutzen.

Mit `position` und `anchor` platzierst du die Formspec auf dem Bildschirm.
`position` legt fest, wo auf dem Bildschirm die Formspec erscheint; Standard ist
die Mitte (`0.5,0.5`). `anchor` legt fest, welcher Punkt der Formspec an dieser
Position liegt; so kannst du sie am Bildschirmrand ausrichten. Am linken Rand
platzierst du die Formspec so:

    formspec_version[4]
    size[2,2]
    position[0,0.5]
    anchor[0,0.5]

Damit liegt der Anker in der Mitte des linken Rands der Formspec, und dieser
Anker wird an den linken Bildschirmrand gesetzt.

## Ein Ratespiel

Am besten lernt man, indem man etwas baut. Bauen wir also ein Ratespiel. Das
Prinzip ist einfach: Der Mod denkt sich eine Zahl aus, und der Spieler rät. Der
Mod sagt dann, ob der Tipp zu hoch oder zu niedrig war.

![Die Formspec des Ratespiels](bilder/formspec_guessing.png){width=5cm}

Zuerst schreiben wir eine Funktion, die den Formspec-Code erzeugt. Das ist gute
Praxis, weil sich der Code so leichter an anderer Stelle wiederverwenden lässt.

```lua
guessing = {}

function guessing.get_formspec(name)
    -- TODO: anzeigen, ob der Tipp zu hoch/niedrig war
    local text = "Ich denke an eine Zahl ... Rate mal!"

    local formspec = {
        "formspec_version[4]",
        "size[6,3.476]",
        "label[0.375,0.5;", core.formspec_escape(text), "]",
        "field[0.375,1.25;5.25,0.8;number;Zahl;]",
        "button[1.5,2.3;3,0.8;guess;Raten]"
    }

    -- table.concat ist schneller als Verkettung mit `..`
    return table.concat(formspec, "")
end
```

Hier platzieren wir ein Eingabefeld, eine Beschriftung und eine Schaltfläche. In
das Feld kann man Text eingeben, die Schaltfläche schickt das Formular ab. Die
Elemente sind sorgfältig positioniert, um Innenabstand und Zwischenraum zu
erzeugen; das wird gleich erklärt.

Als Nächstes soll der Spieler die Formspec öffnen können. Der übliche Weg dafür
ist `show_formspec`:

```lua
function guessing.show_to(name)
    core.show_formspec(name, "guessing:game", guessing.get_formspec(name))
end

core.register_chatcommand("game", {
    func = function(name)
        guessing.show_to(name)
    end,
})
```

`show_formspec` erwartet einen Spielernamen, den Namen der Formspec und die
Formspec selbst. Der Name der Formspec sollte ein gültiger Itemname sein, also
im Format `modname:itemname`.

### Innenabstand und Zwischenraum

![Innenabstand (rot) und Zwischenraum (blau)](bilder/formspec_padding_spacing.png){width=5cm}

Der Innenabstand (*padding*, rot) ist der Abstand zwischen dem Rand der
Formspec und ihrem Inhalt oder zwischen Elementen, die nicht zusammengehören.
Der Zwischenraum (*spacing*, blau) ist der Abstand zwischen zusammengehörenden
Elementen.

Üblich sind ein Innenabstand von `0.375` und ein Zwischenraum von `0.25`.

### Eingaben empfangen

Beim Aufruf von `show_formspec` wird die Formspec zum Client geschickt und dort
angezeigt. Nützlich wird sie aber erst, wenn Informationen vom Client zum Server
zurückkommen. Dieser Vorgang heißt *Formspec field submission*; bei
`show_formspec` empfängst du die Eingaben mit einem globalen Callback:

```lua
core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "guessing:game" then
        return
    end

    if fields.guess then
        local pname = player:get_player_name()
        core.chat_send_all(pname .. " hat " .. fields.number .. " geraten")
    end
end)
```

Die an `core.register_on_player_receive_fields` übergebene Funktion wird
jedes Mal aufgerufen, wenn ein Spieler ein Formular abschickt. Die meisten
Callbacks müssen den übergebenen Formularnamen prüfen und abbrechen, wenn es
nicht das richtige Formular ist; manche Callbacks arbeiten aber auch mit
mehreren oder allen Formularen.

Der Parameter `fields` ist eine Tabelle mit den Werten, die der Spieler
abgeschickt hat, indiziert mit Strings. Benannte Elemente erscheinen je nach
Ereignis unter ihrem eigenen Namen. Manche Elemente, etwa Schaltflächen, werden
nur übermittelt, wenn sie das Ereignis ausgelöst haben; andere, etwa
Eingabefelder, sind immer dabei.

::: {.warning title="Bösartige Clients können jederzeit alles schicken"}
Vertraue niemals den abgeschickten Daten einer Formspec. Ein bösartiger Client
kann jederzeit alles Mögliche schicken – selbst wenn du ihm die Formspec nie
angezeigt hast. Prüfe also Privilegien und stelle sicher, dass der Spieler die
Aktion wirklich ausführen darf.
:::

Die Formspec wird jetzt also zum Client geschickt, und der Client schickt
Informationen zurück. Als Nächstes müssen wir die Zielzahl irgendwie erzeugen und
uns merken und die Formspec abhängig von den Tipps aktualisieren. Dafür gibt es
das Konzept der *Kontexte*.

### Kontexte

Oft soll `core.show_formspec` dem Callback Informationen mitgeben, die der
Client nicht sehen soll – etwa, mit welchen Argumenten ein Chatbefehl aufgerufen
wurde oder worum es in dem Dialog geht. Hier ist es die Zielzahl, die wir uns
merken müssen.

Ein Kontext ist eine Tabelle je Spieler, in der Informationen gespeichert
werden. Die Kontexte aller Spieler, die gerade online sind, liegen in einer
lokalen Variablen der Datei:

```lua
local _contexts = {}
local function get_context(name)
    local context = _contexts[name] or {}
    _contexts[name] = context
    return context
end

core.register_on_leaveplayer(function(player)
    _contexts[player:get_player_name()] = nil
end)
```

Nun ändern wir den Code zum Anzeigen so, dass er den Kontext aktualisiert, bevor
er die Formspec anzeigt:

```lua
function guessing.show_to(name)
    local context = get_context(name)
    context.target = context.target or math.random(1, 10)

    local fs = guessing.get_formspec(name, context)
    core.show_formspec(name, "guessing:game", fs)
end
```

Auch der Code, der die Formspec erzeugt, muss den Kontext verwenden:

```lua
function guessing.get_formspec(name, context)
    local text
    if not context.guess then
        text = "Ich denke an eine Zahl ... Rate mal!"
    elseif context.guess == context.target then
        text = "Hurra, richtig geraten!"
    elseif context.guess > context.target then
        text = "Zu hoch!"
    else
        text = "Zu niedrig!"
    end

    -- … weiter wie oben
end
```

Es ist gute Praxis, dass `get_formspec` den Kontext nur liest und nie
verändert. Das hält die Funktion einfacher und leichter testbar.

Zum Schluss muss der Handler den Kontext mit dem Tipp aktualisieren:

```lua
if fields.guess then
    local name = player:get_player_name()
    local context = get_context(name)
    context.guess = tonumber(fields.number)
    guessing.show_to(name)
end
```

## Wege zur Formspec

Eine Formspec kann auf drei Wegen zum Client gelangen:

* [show_formspec](#ein-ratespiel): der oben verwendete Weg; die Eingaben
  empfängt `register_on_player_receive_fields`.
* [Formspecs in Node-Metadaten](#formspecs-in-node-metadaten): Der Node hat eine
  Formspec in seinen Metadaten, und der Client zeigt sie *sofort* an, wenn der
  Spieler rechts klickt. Die Eingaben empfängt die Methode `on_receive_fields`
  in der Node-Definition.
* [Formspecs im Spielerinventar](#formspecs-im-spielerinventar): Die Formspec
  wird irgendwann zum Client geschickt und sofort angezeigt, wenn der Spieler
  `i` drückt. Die Eingaben empfängt `register_on_player_receive_fields`.

### Formspecs in Node-Metadaten

`core.show_formspec` ist nicht der einzige Weg, eine Formspec anzuzeigen; du
kannst Formspecs auch in die [Metadaten eines Nodes](../map/storage.html)
schreiben. Truhen machen das zum Beispiel, damit sie schneller aufgehen – man
muss nicht warten, bis der Server die Formspec der Truhe schickt.

```lua
core.register_node("mymod:rightclick", {
    description = "Klick mich mit rechts!",
    tiles = {"mymod_rightclick.png"},
    groups = {cracky = 1},
    after_place_node = function(pos, placer)
        -- Läuft, wenn der Node platziert wird, und setzt
        -- die Formspec in den Metadaten des Nodes.
        local meta = core.get_meta(pos)
        meta:set_string("formspec",
                "formspec_version[4]" ..
                "size[5,5]" ..
                "label[1,1;Erscheint beim Rechtsklick]" ..
                "field[1,2;2,1;x;x;]")
    end,
    on_receive_fields = function(pos, formname, fields, player)
        if fields.quit then
            return
        end

        print(fields.x)
    end
})
```

So gesetzte Formspecs lösen nicht denselben Callback aus. Um Eingaben aus
Formspecs in Metadaten zu empfangen, musst du bei der Registrierung des Nodes
einen Eintrag `on_receive_fields` angeben.

Dieser Callback wird auch ausgelöst, wenn du in einem Feld die Eingabetaste
drückst, was mit `core.show_formspec` nicht möglich ist. Dafür lässt sich diese
Art von Formular nur durch einen Rechtsklick auf den Node öffnen, nicht per
Programmcode.

### Formspecs im Spielerinventar

Die Formspec des Spielerinventars erscheint, wenn der Spieler `i` drückt. Ihre
Ereignisse empfängst du mit dem globalen Callback; der Formularname ist dabei
`""`.

Es gibt verschiedene Mods, mit denen mehrere Mods gemeinsam das Spielerinventar
anpassen können. Minetest Game verwendet
[SFINV](https://github.com/rubenwardy/sfinv/blob/master/Tutorial.md).

### Jetzt bist du dran

* Erweitere das Ratespiel so, dass es sich für jeden Spieler die Bestleistung
  merkt, also mit wie wenigen Tipps er die Zahl erraten hat.
* Erstelle einen Node „Briefkasten“, in dem Spieler über eine Formspec
  Nachrichten hinterlassen können. Der Node soll den Namen des Platzierenden als
  `owner` in den Metadaten speichern und mit `show_formspec` unterschiedlichen
  Spielern unterschiedliche Formspecs zeigen.
