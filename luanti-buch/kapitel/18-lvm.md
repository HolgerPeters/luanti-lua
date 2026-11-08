---
title: Lua Voxel Manipulators
label: advmap/lvm
---

Die Funktionen aus dem Kapitel
[Grundlegende Kartenoperationen](../map/environment.html) sind bequem und
einfach zu benutzen, für große Bereiche aber ineffizient. Bei jedem Aufruf von
`set_node` oder `get_node` muss dein Mod mit der Engine kommunizieren. Das führt
zu ständigen einzelnen Kopiervorgängen zwischen Engine und Mod, was langsam ist
und die Leistung deines Spiels schnell verschlechtert. Ein *Lua Voxel
Manipulator* (LVM) kann hier die bessere Wahl sein.

## Konzept

Mit einem LVM lädst du große Bereiche der Karte in den Speicher deines Mods.
Diese Daten kannst du dann lesen und schreiben, ohne weiter mit der Engine zu
kommunizieren und ohne dass Callbacks laufen – diese Operationen sind also sehr
schnell. Danach schreibst du den Bereich zurück in die Engine und lässt die
Beleuchtung berechnen.

## Daten in den LVM lesen

In einen LVM kannst du nur einen Quader laden. Du musst also die kleinste und
größte Position ermitteln, die du verändern willst. Dann erzeugst du einen LVM
und liest den Bereich ein, zum Beispiel so:

```lua
local vm         = core.get_voxel_manip()
local emin, emax = vm:read_from_map(pos1, pos2)
```

Aus Leistungsgründen liest ein LVM fast nie genau den angegebenen Bereich,
sondern meist einen größeren. Diesen größeren Bereich geben `emin` und `emax`
an (*emerged min pos* und *emerged max pos*). Der LVM lädt den Bereich für dich –
egal ob dafür aus dem Arbeitsspeicher, von der Festplatte gelesen oder der
Kartengenerator aufgerufen werden muss.

::: {.warning title="LVMs und Kartengenerierung"}
Verwende `core.get_voxel_manip()` nicht in der Kartengenerierung, das kann zu
Fehlern führen. Verwende dort stattdessen
`core.get_mapgen_object("voxelmanip")`.
:::

## Nodes lesen

Um die Node-Typen an bestimmten Positionen zu lesen, verwendest du `get_data()`.
Die Methode gibt ein flaches Array zurück, in dem jeder Eintrag für den Typ eines
Nodes steht.

```lua
local data = vm:get_data()
```

`param2` und Lichtwerte erhältst du mit `get_light_data()` und
`get_param2_data()`.

Mit `emin` und `emax` berechnest du, wo ein Node in diesen flachen Arrays liegt.
Die Hilfsklasse `VoxelArea` übernimmt die Berechnung für dich.

```lua
local a = VoxelArea:new{
    MinEdge = emin,
    MaxEdge = emax
}

-- Index des Nodes ermitteln
local idx = a:index(x, y, z)

-- Node lesen
print(data[idx])
```

Dabei fällt auf, dass `data[idx]` eine ganze Zahl ist. Die Engine speichert Nodes
aus Leistungsgründen nicht als Strings, sondern als Zahl, die *Content-ID*
heißt. Die Content-ID eines Node-Typs erhältst du mit `get_content_id()`:

```lua
local c_stone = core.get_content_id("default:stone")
```

Dann kannst du prüfen, ob der Node Stein ist:

```lua
local idx = a:index(x, y, z)
if data[idx] == c_stone then
    print("Ist Stein!")
end
```

Die Content-IDs von Node-Typen können sich während der Ladezeit noch ändern.
Ermittle sie deshalb nicht während dieser Zeit.

Die Nodes im Datenarray eines LVM liegen in umgekehrter Koordinatenreihenfolge.
Iteriere deshalb immer in der Reihenfolge `z, y, x`:

```lua
for z = pos1.z, pos2.z do
    for y = pos1.y, pos2.y do
        for x = pos1.x, pos2.x do
            -- vi (voxel index) ist ein üblicher Name
            local vi = a:index(x, y, z)
            if data[vi] == c_stone then
                print("Ist Stein!")
            end
        end
    end
end
```

Der Grund dafür liegt in der Rechnerarchitektur. Aus dem Arbeitsspeicher zu
lesen, ist recht teuer, deshalb haben Prozessoren mehrere Cache-Ebenen. Liegen die
angeforderten Daten im Cache, sind sie sehr schnell verfügbar. Liegen sie nicht
dort, kommt es zu einem *Cache-Miss*, und die Daten werden aus dem
Arbeitsspeicher geholt. Dabei werden auch die umliegenden Daten mitgeholt und
ersetzen Daten im Cache, weil das Programm sehr wahrscheinlich bald Daten aus der
Nähe anfordert. Eine gute Optimierungsregel ist daher, Daten der Reihe nach zu
lesen und *Cache-Thrashing* zu vermeiden.

## Nodes schreiben

Zuerst setzt du die neue Content-ID im Datenarray:

```lua
local c_air = core.get_content_id("air")

for z = pos1.z, pos2.z do
    for y = pos1.y, pos2.y do
        for x = pos1.x, pos2.x do
            local vi = a:index(x, y, z)
            if data[vi] == c_stone then
                data[vi] = c_air
            end
        end
    end
end
```

Bist du mit dem Setzen fertig, lädst du das Datenarray zurück in die Engine:

```lua
vm:set_data(data)
vm:write_to_map(true)
```

Für Licht- und `param2`-Daten gibt es die passend benannten Methoden
`set_light_data()` und `set_param2_data()`.

`write_to_map()` erwartet einen Wahrheitswert: `true`, wenn die Beleuchtung
berechnet werden soll. Übergibst du `false`, musst du die Beleuchtung später mit
`core.fix_light` neu berechnen.

## Beispiel

```lua
local function grass_to_dirt(pos1, pos2)
    local c_dirt  = core.get_content_id("default:dirt")
    local c_grass = core.get_content_id("default:dirt_with_grass")

    -- Daten in den LVM lesen
    local vm = core.get_voxel_manip()
    local emin, emax = vm:read_from_map(pos1, pos2)
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    local data = vm:get_data()

    -- Daten ändern
    for z = pos1.z, pos2.z do
        for y = pos1.y, pos2.y do
            for x = pos1.x, pos2.x do
                local vi = a:index(x, y, z)
                if data[vi] == c_grass then
                    data[vi] = c_dirt
                end
            end
        end
    end

    -- Daten schreiben
    vm:set_data(data)
    vm:write_to_map(true)
end
```

## Jetzt bist du dran

* Schreibe `replace_in_area(from, to, pos1, pos2)`, das im angegebenen Bereich
  jedes Vorkommen von `from` durch `to` ersetzt; `from` und `to` sind
  Node-Namen.
* Schreibe eine Funktion, die alle Truhen um 90° dreht.
* Schreibe eine Funktion, die mit einem LVM bemoosten Bruchstein auf benachbarten
  Stein und Bruchstein übergreifen lässt. Breitet sich der Moosbewuchs bei deiner
  Umsetzung jedes Mal weiter als einen Node aus? Wenn ja, wie könntest du das
  verhindern?
