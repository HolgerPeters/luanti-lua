---
title: Node- und Item-Callbacks
label: items/callbacks
---

Luanti setzt beim Modding stark auf Callbacks. Ein Callback ist eine Funktion,
die du einer API übergibst und die aufgerufen wird, wenn ein Ereignis eintritt.
Du kannst zum Beispiel in einer Node-Definition eine Funktion `on_punch`
angeben, die aufgerufen wird, wenn ein Spieler den Node schlägt. Es gibt auch
globale Callbacks wie `core.register_on_punchnode`, die Ereignisse für alle
Nodes empfangen.

## Item-Callbacks

Hat ein Spieler einen Node, ein Craftitem oder ein Werkzeug im Inventar, kann er
damit bestimmte Ereignisse auslösen:

| Callback | Standardbelegung | Standardwert |
|--------------------------|----------------------|------------------------------|
| `on_use` | Linksklick | `nil` |
| `on_place` | Rechtsklick auf einen Node | `core.item_place` |
| `on_secondary_use` | Rechtsklick ins Leere | `core.item_secondary_use` (tut nichts) |
| `on_drop` | Q | `core.item_drop` |
| `after_use` | Abbauen eines Nodes | `nil` |

### on_use

Hat ein Item einen `on_use`-Callback, kann es nicht mehr zum Abbauen von Nodes
verwendet werden. Ein typischer Einsatz von `on_use` sind Lebensmittel:

```lua
core.register_craftitem("mymod:mudpie", {
    description = "Alien-Matschkuchen",
    inventory_image = "myfood_mudpie.png",
    on_use = core.item_eat(20),
})
```

Die Zahl, die du `core.item_eat` übergibst, ist die Anzahl der Lebenspunkte,
die der Verzehr heilt. Jedes Herz des Spielers ist zwei Lebenspunkte wert. Ein
Spieler hat normalerweise bis zu 10 Herzen, also 20 Lebenspunkte.

`core.item_eat()` ist eine Funktion, die eine Funktion zurückgibt; diese wird
als `on_use`-Callback eingetragen. Der Code oben ist also gleichbedeutend mit:

```lua
core.register_craftitem("mymod:mudpie", {
    description = "Alien-Matschkuchen",
    inventory_image = "myfood_mudpie.png",
    on_use = function(...)
        return core.do_item_eat(20, nil, ...)
    end,
})
```

Wenn du verstehst, dass `item_eat` einfach eine Funktion zurückgibt, kannst du
sie abwandeln und komplexeres Verhalten einbauen, etwa einen eigenen Sound
abspielen.

### on_place und on_secondary_use

`on_place` wird aufgerufen, wenn der Spieler auf einen Node zeigt,
`on_secondary_use`, wenn er das nicht tut.

Beide Callbacks werden für alle Item-Arten aufgerufen. `on_place` ist
standardmäßig `core.item_place`; diese Funktion ruft entweder den
`on_rightclick`-Callback des anvisierten Nodes auf oder platziert das gehaltene
Item, falls es ein Node ist.

### on_drop

`on_drop` wird aufgerufen, wenn der Spieler ein Item fallen lassen will, etwa
mit der Taste Q oder indem er es aus dem Inventar herauszieht. Standardmäßig ist
das `core.item_drop`, die das Fallenlassen übernimmt.

### after_use

`after_use` wird beim Abbauen eines Nodes aufgerufen und erlaubt dir, selbst
festzulegen, wie sich ein Werkzeug abnutzt. Fehlt `after_use`, entspricht das
diesem Code:

```lua
after_use = function(itemstack, user, node, digparams)
    itemstack:add_wear(digparams.wear)
    return itemstack
end
```

## item_place oder place_item?

Die Luanti-API bringt viele fertige Callback-Implementierungen mit, die du
verwenden kannst. Sie sind nach dem Schema *Typ zuerst* benannt, zum Beispiel
`core.item_place` und `core.node_dig`. Manche werden direkt eingesetzt, andere
sind Funktionen, die den Callback erst zurückgeben:

```lua
core.register_item("mymod:example", {
    on_place = core.item_place,
    on_use = core.item_eat(10),
})
```

Außerdem enthält die API Funktionen, die etwas *tun*. Sie heißen verwirrend
ähnlich wie die Callback-Implementierungen, beginnen aber mit dem Verb.
Beispiele sind `core.place_node` und `core.dig_node`: Mit ihnen kannst du Nodes
abbauen und platzieren, mit ähnlicher Wirkung, als täte es ein Spieler.

## Node-Callbacks

Solange ein Node in einem Inventar liegt, verwendet er wie oben beschrieben
Item-Callbacks. Ist er in der Welt platziert, verwendet er Node-Callbacks. Davon
gibt es sehr viele, zu viele für dieses Buch; einige davon kommen aber in
späteren Kapiteln vor.

Mehrere dieser Callbacks betreffen Node-Operationen wie das Platzieren und
Entfernen in der Welt. Wichtig: Aus Leistungsgründen werden sie bei
Massenänderungen – also wenn sehr viele Nodes auf einmal gesetzt werden – nicht
aufgerufen. Du kannst dich also nicht darauf verlassen, dass sie immer
ausgelöst werden.

### Rechtsklick und Platzieren

Klickt der Spieler mit einem Item rechts, während er auf einen Node zeigt, wird
der `on_place`-Callback des Items aufgerufen, standardmäßig `core.item_place`.
Hat der anvisierte Node einen `on_rightclick`-Callback und hält der Spieler die
Schleichtaste (Shift) *nicht* gedrückt, wird `on_rightclick` aufgerufen.
Andernfalls platziert `core.item_place` den Node.

Beim Platzieren eines Nodes werden sowohl `on_construct` als auch
`after_place_node` aufgerufen. `on_construct` wird bei jedem Setzen eines Nodes
außerhalb von Massenänderungen ausgelöst und erhält nur die Position des Nodes.
`after_place_node` wird nur beim Platzieren aufgerufen und bekommt daher mehr
Informationen, etwa den Platzierenden und den Itemstack.

Beachte, dass nicht nur Spieler Nodes platzieren können; auch Mobs und Mods tun
das häufig. Deshalb kann `placer` ein Spieler, eine Entity oder `nil` sein.

```lua
core.register_node("mymod:mynode", {
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker:is_player() then
            core.chat_send_player(clicker:get_player_name(), "Hallo Welt!")
        end
    end,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "Mein Node!")
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        -- placer immer prüfen
        if placer and placer:is_player() then
            local meta = core.get_meta(pos)
            meta:set_string("owner", placer:get_player_name())
        end
    end,
})
```

### Schlagen und Abbauen

Schlagen heißt, dass der Spieler kurz links klickt. Hat das gehaltene Item einen
`on_use`-Callback, wird dieser aufgerufen, andernfalls der `on_punch`-Callback
des anvisierten Nodes.

Versucht der Spieler, einen Node abzubauen, wird dessen `on_dig`-Callback
aufgerufen. Standardmäßig ist das `core.node_dig`: Die Funktion prüft den
Gebietsschutz, nutzt das Werkzeug ab, entfernt den Node und führt den
`after_dig_node`-Callback aus.

```lua
core.register_node("mymod:mynode", {
    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher:is_player() then
            core.chat_send_player(puncher:get_player_name(), "Au!")
        end
    end,
})
```

### … und mehr!

Eine Liste aller Node-Callbacks und weitere Details zu den oben genannten findest
du in der Lua-API-Referenz von Luanti.
