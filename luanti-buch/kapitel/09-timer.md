---
title: Node-Timer und ABMs
label: map/timers
---

Eine Funktion regelmäßig auf bestimmten Nodes auszuführen, ist eine häufige
Aufgabe. Luanti bietet dafür zwei Wege: *Active Block Modifiers* (ABMs) und
Node-Timer.

ABMs durchsuchen alle geladenen Mapblöcke nach Nodes, die bestimmte Kriterien
erfüllen. Sie eignen sich am besten für Nodes, die in der Welt häufig
vorkommen, etwa Gras. Sie kosten viel Rechenzeit, aber wenig Arbeits- und
Speicherplatz.

Für seltene Nodes oder solche, die ohnehin Metadaten verwenden, etwa Öfen und
Maschinen, solltest du stattdessen Node-Timer verwenden. Node-Timer merken sich
die anstehenden Timer in jedem Mapblock und führen sie aus, sobald sie ablaufen.
Sie müssen also nicht alle geladenen Nodes nach Treffern durchsuchen, brauchen
dafür aber etwas mehr Arbeits- und Speicherplatz, um die anstehenden Timer zu
verwalten.

## Node-Timer

Node-Timer sind direkt an einen einzelnen Node gebunden. Du steuerst sie über
ein `NodeTimerRef`-Objekt:

```lua
local timer = core.get_node_timer(pos)
timer:start(10.5) -- in Sekunden
```

Läuft ein Node-Timer ab, wird die Methode `on_timer` in der Definitionstabelle
des Nodes aufgerufen. Sie bekommt nur einen Parameter, die Position des Nodes:

```lua
core.register_node("autodoors:door_open", {
    on_timer = function(pos)
        core.set_node(pos, { name = "autodoors:door" })
        return false
    end
})
```

Gibt `on_timer` `true` zurück, läuft der Timer mit demselben Intervall erneut.
Du kannst auch innerhalb von `on_timer` `get_node_timer(pos)` verwenden; gib
dann aber `false` zurück, um Konflikte zu vermeiden.

Timer haben eine Einschränkung: Aus Optimierungsgründen gibt es je Node-Typ nur
eine Art von Timer, und je Node kann nur ein Timer laufen.

## Active Block Modifiers

Alien-Gras ist für dieses Kapitel eine Grasart, die mit einer gewissen
Wahrscheinlichkeit in der Nähe von Wasser erscheint.

```lua
core.register_node("aliens:grass", {
    description = "Alien-Gras",
    light_source = 3, -- Der Node leuchtet; min. 0, max. 14
    tiles = {"aliens_grass.png"},
    groups = {choppy=1},
    on_use = core.item_eat(20)
})

core.register_abm({
    nodenames = {"default:dirt_with_grass"},
    neighbors = {"default:water_source", "default:water_flowing"},
    interval = 10.0, -- alle 10 Sekunden ausführen
    chance = 50, -- jeder Node wird mit Chance 1:50 gewählt
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        local above = {x = pos.x, y = pos.y + 1, z = pos.z}
        core.set_node(above, {name = "aliens:grass"})
    end
})
```

Dieser ABM läuft alle zehn Sekunden, und für jeden passenden Node wird er mit
einer Wahrscheinlichkeit von 1 zu 50 ausgeführt. Läuft der ABM auf einem Node,
wird darüber ein Alien-Gras-Node gesetzt. Achtung: Dabei wird jeder Node
gelöscht, der sich vorher an dieser Stelle befand. Um das zu verhindern, solltest
du mit `core.get_node` prüfen, ob dort Platz für das Gras ist.

Die Angabe von Nachbarn (`neighbors`) ist optional. Gibst du mehrere Nachbarn an,
genügt es, wenn einer davon vorhanden ist.

Auch `chance` ist optional. Ohne Angabe läuft der ABM immer, wenn die übrigen
Bedingungen erfüllt sind.

## Jetzt bist du dran

* Midas-Berührung: Lass Wasser alle 5 Sekunden mit einer Wahrscheinlichkeit
  von 1 zu 100 zu Goldblöcken werden.
* Verfall: Lass Holz zu Erde werden, wenn Wasser angrenzt.
* Lauffeuer: Lass jeden Luft-Node in Flammen aufgehen. (Tipp: `"air"` und
  `"fire:basic_flame"`.) Warnung: Rechne damit, dass das Spiel abstürzt.
