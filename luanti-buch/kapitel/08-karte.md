---
title: Grundlegende Kartenoperationen
label: map/environment
---

In diesem Kapitel lernst du grundlegende Operationen auf der Karte kennen, etwa
Nodes hinzufügen, entfernen und finden.

## Aufbau der Karte

Die Luanti-Karte ist in Mapblöcke aufgeteilt; jeder Mapblock ist ein Würfel mit
der Kantenlänge 16. Während Spieler sich über die Karte bewegen, werden
Mapblöcke erzeugt, geladen, aktiviert und wieder entladen. Noch nicht geladene
Bereiche der Karte sind mit *ignore*-Nodes gefüllt, einem unpassierbaren,
nicht auswählbaren Platzhalter. Leerer Raum ist mit *air*-Nodes gefüllt,
unsichtbaren Nodes, durch die man hindurchgehen kann.

Ein aktiver Mapblock ist einer, der geladen ist und auf dem Aktualisierungen
laufen.

Geladene Mapblöcke werden oft *aktive Blöcke* genannt. Mods und Spieler können
aus aktiven Blöcken lesen und in sie schreiben, und sie enthalten aktive
Entities. Auch die Engine führt Operationen auf der Karte aus, etwa die
Flüssigkeitsphysik.

Mapblöcke werden entweder aus der Weltdatenbank geladen oder neu generiert.
Generiert werden sie bis zur Kartengenerierungsgrenze (`mapgen_limit`), die
standardmäßig auf ihren Höchstwert 31000 eingestellt ist. Bereits vorhandene
Mapblöcke können aber auch jenseits dieser Grenze aus der Weltdatenbank geladen
werden.

## Lesen

### Nodes lesen

Sobald du eine Position hast, kannst du aus der Karte lesen:

```lua
local node = core.get_node({ x = 1, y = 3, z = 4 })
print(dump(node)) --> { name=.., param1=.., param2=.. }
```

Ist die Position keine ganze Zahl, wird sie auf den Node gerundet, in dem sie
liegt. Die Funktion gibt immer eine Tabelle mit den Node-Informationen zurück:

* `name` – der Node-Name; *ignore*, wenn der Bereich nicht geladen ist.
* `param1` – siehe Node-Definition; meist die Beleuchtung.
* `param2` – siehe Node-Definition.

Beachte, dass die Funktion einen inaktiven Block nicht lädt, sondern eine
Tabelle mit dem Namen `ignore` zurückgibt.

Stattdessen kannst du `core.get_node_or_nil` verwenden; sie gibt dann `nil`
zurück statt einer Tabelle mit dem Namen `ignore`. Auch sie lädt den Block
nicht. Sie kann trotzdem `ignore` zurückgeben, wenn ein Block tatsächlich
*ignore* enthält – das passiert am Rand der Karte, wie ihn die
Kartengenerierungsgrenze (`mapgen_limit`) festlegt.

### Nodes finden

Luanti bietet eine Reihe von Hilfsfunktionen, die häufige Kartenoperationen
beschleunigen. Am häufigsten werden die Funktionen zum Finden von Nodes
verwendet.

Angenommen, du möchtest eine Pflanze erstellen, die in der Nähe von Mese besser
wächst. Dann musst du nach Mese-Nodes in der Umgebung suchen und die
Wachstumsrate entsprechend anpassen.

`core.find_node_near` gibt den ersten gefundenen Node in einem bestimmten
Radius zurück, der zu den angegebenen Node-Namen oder Gruppen passt. Im
folgenden Beispiel suchen wir einen Mese-Node im Umkreis von 5 Nodes um die
Position:

```lua
local grow_speed = 1
local node_pos   = core.find_node_near(pos, 5, { "default:mese" })
if node_pos then
    core.chat_send_all("Node gefunden bei: " .. dump(node_pos))
    grow_speed = 2
end
```

Angenommen, die Wachstumsrate soll umso höher sein, je mehr Mese in der Nähe
ist. Dann brauchst du eine Funktion, die mehrere Nodes in einem Bereich findet:

```lua
local pos1       = vector.subtract(pos, { x = 5, y = 5, z = 5 })
local pos2       = vector.add(pos, { x = 5, y = 5, z = 5 })
local pos_list   =
        core.find_nodes_in_area(pos1, pos2, { "default:mese" })
local grow_speed = 1 + #pos_list
```

Dieser Code zählt die Nodes in einem *Quader*. Das unterscheidet sich von
`find_node_near`, das den Abstand zur Position verwendet (also eine *Kugel*).
Um das zu korrigieren, müssen wir den Abstand selbst prüfen:

```lua
local pos1       = vector.subtract(pos, { x = 5, y = 5, z = 5 })
local pos2       = vector.add(pos, { x = 5, y = 5, z = 5 })
local pos_list   =
        core.find_nodes_in_area(pos1, pos2, { "default:mese" })
local grow_speed = 1
for i=1, #pos_list do
    local delta = vector.subtract(pos_list[i], pos)
    if delta.x*delta.x + delta.y*delta.y + delta.z*delta.z <= 5*5 then
        grow_speed = grow_speed + 1
    end
end
```

Jetzt erhöht der Code `grow_speed` korrekt anhand der Mese-Nodes im Umkreis.

Beachte, dass wir den *quadrierten* Abstand vergleichen, statt die Wurzel zu
ziehen und den echten Abstand zu berechnen. Wurzeln sind für Computer
rechenaufwendig und sollten daher möglichst vermieden werden.

Es gibt weitere Varianten der beiden Funktionen, etwa `find_nodes_with_meta`
und `find_nodes_in_area_under_air`. Sie funktionieren ähnlich und sind in
anderen Situationen nützlich.

## Schreiben

### Nodes schreiben

Mit `set_node` schreibst du in die Karte. Jeder Aufruf von `set_node` führt
dazu, dass die Beleuchtung neu berechnet wird und Node-Callbacks laufen. Für
viele Nodes ist `set_node` deshalb recht langsam.

```lua
core.set_node({ x = 1, y = 3, z = 4 }, { name = "default:mese" })

local node = core.get_node({ x = 1, y = 3, z = 4 })
print(node.name) --> default:mese
```

`set_node` entfernt alle Metadaten und das Inventar an dieser Position. Das ist
nicht immer erwünscht, besonders wenn du mehrere Node-Definitionen für einen
einzigen gedachten Node verwendest. Ein Beispiel ist der Ofen: Man denkt sich
ihn als einen Node, tatsächlich sind es aber zwei.

So setzt du einen Node, ohne Metadaten und Inventar zu löschen:

```lua
core.swap_node({ x = 1, y = 3, z = 4 }, { name = "default:mese" })
```

### Nodes entfernen

An jeder Position muss ein Node sein. Um einen Node zu entfernen, setzt du die
Position auf `air`.

Die folgenden beiden Zeilen entfernen beide einen Node und sind gleichwertig:

```lua
core.remove_node(pos)
core.set_node(pos, { name = "air" })
```

`remove_node` ist tatsächlich nur eine Hilfsfunktion, die `set_node` mit `"air"`
aufruft.

## Mapblöcke laden

Mit `core.emerge_area` lädst du Mapblöcke. Das geschieht asynchron, die Blöcke
sind also nicht sofort geladen. Sie werden in Kürze geladen, und für jeden Block
wird der Callback aufgerufen.

```lua
-- Einen Bereich von 20×20×20 laden
local halfsize = { x = 10, y = 10, z = 10 }
local pos1 = vector.subtract(pos, halfsize)
local pos2 = vector.add     (pos, halfsize)

local context = {} -- Daten zwischen den Callback-Aufrufen
core.emerge_area(pos1, pos2, emerge_callback, context)
```

Luanti ruft `emerge_callback` jedes Mal auf, wenn ein Block geladen wurde, und
übergibt dabei Informationen zum Fortschritt. Die Funktion muss definiert sein,
bevor `emerge_area` aufgerufen wird:

```lua
local function emerge_callback(pos, action,
        num_calls_remaining, context)
    -- Beim ersten Aufruf die Anzahl der Blöcke merken
    if not context.total_blocks then
        context.total_blocks  = num_calls_remaining + 1
        context.loaded_blocks = 0
    end

    -- Anzahl der geladenen Blöcke erhöhen
    context.loaded_blocks = context.loaded_blocks + 1

    -- Fortschritt melden
    if context.total_blocks == context.loaded_blocks then
        core.chat_send_all("Alle Blöcke geladen!")
    else
        local perc = 100 * context.loaded_blocks / context.total_blocks
        local msg  = string.format("Lade Blöcke %d/%d (%.2f%%)",
                context.loaded_blocks, context.total_blocks, perc)
        core.chat_send_all(msg)
    end
end
```

Das ist nicht die einzige Möglichkeit, Blöcke zu laden: Auch ein
[Lua Voxel Manipulator (LVM)](../advmap/lvm.html) lädt die betroffenen Blöcke,
und zwar synchron.

## Mapblöcke löschen

Mit `core.delete_area` löschst du einen Bereich von Mapblöcken:

```lua
-- Einen Bereich von 20×20×20 löschen
local halfsize = { x = 10, y = 10, z = 10 }
local pos1 = vector.subtract(pos, halfsize)
local pos2 = vector.add     (pos, halfsize)

core.delete_area(pos1, pos2)
```

Dabei werden alle Mapblöcke in diesem Bereich gelöscht, und zwar *einschließlich*
der Ränder. Es werden also auch Nodes außerhalb des Bereichs gelöscht, wenn sie
in einem Mapblock liegen, der über die Bereichsgrenzen hinausragt.
