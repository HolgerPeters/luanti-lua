---
title: Objekte, Spieler und Entities
label: map/objects
---

In diesem Kapitel lernst du, wie du Objekte veränderst und eigene definierst.

## Was sind Objekte, Spieler und Entities?

Spieler und Entities sind beides Objekte. Ein Objekt ist etwas, das sich
unabhängig vom Node-Gitter bewegen kann und Eigenschaften wie Geschwindigkeit
und Größe hat. Objekte sind keine Items und haben ein eigenes
Registrierungssystem.

Zwischen Spielern und Entities gibt es einige Unterschiede. Der wichtigste:
Spieler werden von Menschen gesteuert, Entities von Mods. Deshalb können Mods
die Geschwindigkeit eines Spielers nicht setzen – Spieler werden auf dem Client
berechnet, Entities auf dem Server. Ein weiterer Unterschied: Spieler sorgen
dafür, dass Mapblöcke geladen werden, Entities werden dagegen einfach gespeichert
und inaktiv.

Verwischt wird diese Unterscheidung dadurch, dass Entities über eine Tabelle
gesteuert werden, die *Lua-Entity* heißt; dazu später mehr.

## Position und Geschwindigkeit

Mit `get_pos` und `set_pos` liest und setzt du die Position eines Objekts.

```lua
local object = core.get_player_by_name("bob")
local pos    = object:get_pos()
object:set_pos({ x = pos.x, y = pos.y + 1, z = pos.z })
```

`set_pos` setzt die Position sofort, ohne Animation. Soll das Objekt sich
fließend an die neue Position bewegen, verwendest du `move_to`. Das funktioniert
leider nur bei Entities.

```lua
object:move_to({ x = pos.x, y = pos.y + 1, z = pos.z })
```

Bei Entities musst du immer an die Netzwerklatenz denken. Im Idealfall kämen
Nachrichten über Bewegungen sofort an, in der richtigen Reihenfolge und in
ähnlichen Abständen, wie du sie gesendet hast. Außerhalb des
Einzelspielermodus ist die Welt aber nicht ideal. Nachrichten brauchen eine
Weile. Positionsnachrichten können in falscher Reihenfolge ankommen, sodass
manche `set_pos`-Aufrufe übersprungen werden – es hat keinen Sinn, an eine
Position zu springen, die älter ist als die aktuell bekannte. Bewegungen kommen
womöglich nicht in gleichmäßigen Abständen an, was sie für Animationen schwer
nutzbar macht. All das führt dazu, dass der Client etwas anderes sieht als der
Server. Dessen solltest du dir bewusst sein.

## Objekteigenschaften

Objekteigenschaften sagen dem Client, wie er ein Objekt darstellen und behandeln
soll. Eigene Eigenschaften kannst du nicht festlegen, denn die Eigenschaften
sind per Definition für die Engine bestimmt.

Anders als Nodes haben Objekte kein festes, sondern ein veränderliches Aussehen.
Wie ein Objekt aussieht – und einiges mehr –, kannst du jederzeit ändern, indem
du seine Eigenschaften aktualisierst.

```lua
object:set_properties({
    visual      = "mesh",
    mesh        = "character.b3d",
    textures    = {"character_texture.png"},
    visual_size = {x=1, y=1},
})
```

Die geänderten Eigenschaften werden an alle Spieler in Reichweite geschickt. So
erreichst du sehr günstig viel Abwechslung, etwa unterschiedliche Skins für
jeden Spieler.

Wie der nächste Abschnitt zeigt, können Entities in ihrer Definition
Anfangseigenschaften haben. Die Standardeigenschaften von Spielern sind dagegen
in der Engine festgelegt; für neu beigetretene Spieler setzt du die
Eigenschaften deshalb mit `set_properties()` in `on_joinplayer`.

## Entities

Eine Entity hat eine Definitionstabelle, die einer Item-Definition ähnelt. Sie
kann Callback-Methoden, Anfangseigenschaften des Objekts und eigene Felder
enthalten.

```lua
local MyEntity = {
    initial_properties = {
        hp_max = 1,
        physical = true,
        collide_with_objects = false,
        collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
        visual = "wielditem",
        visual_size = {x = 0.4, y = 0.4},
        textures = {""},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
    },

    message = "Standardnachricht",
}

function MyEntity:set_message(msg)
    self.message = msg
end
```

In einem sehr wichtigen Punkt unterscheiden sich Entity-Definitionen von
Item-Definitionen: Wird eine Entity *emerged* (also geladen oder erzeugt), wird
für sie eine neue Tabelle angelegt, die von der Definitionstabelle *erbt*.

Über das ObjectRef kommst du an die Entity-Tabelle und umgekehrt:

```lua
local entity = object:get_luaentity()
local object = entity.object
print("Entity ist bei " .. core.pos_to_string(object:get_pos()))
```

Für Entities gibt es eine Reihe von Callbacks. Eine vollständige Liste findest
du in der
[Lua-API-Referenz](https://api.luanti.org/minetest-namespace-reference/#registered-definition-tables).

```lua
function MyEntity:on_step(dtime)
    local pos      = self.object:get_pos()
    local pos_down = vector.subtract(pos, vector.new(0, 1, 0))

    local delta
    if core.get_node(pos_down).name == "air" then
        delta = vector.new(0, -1, 0)
    elseif core.get_node(pos).name == "air" then
        delta = vector.new(0, 0, 1)
    else
        delta = vector.new(0, 1, 0)
    end

    delta = vector.multiply(delta, dtime)

    self.object:move_to(vector.add(pos, delta))
end

function MyEntity:on_punch(hitter)
    core.chat_send_player(hitter:get_player_name(), self.message)
end
```

Wenn du diese Entity erzeugst und benutzt, fällt dir auf, dass die Nachricht
vergessen wird, sobald die Entity inaktiv und wieder aktiv wird. Das liegt
daran, dass die Nachricht nicht gespeichert wird. Statt einfach die ganze
Entity-Tabelle zu speichern, überlässt Luanti dir, was gespeichert wird.
*Staticdata* ist ein String mit allen eigenen Informationen, die gespeichert
werden müssen.

```lua
function MyEntity:get_staticdata()
    return core.write_json({
        message = self.message,
    })
end

function MyEntity:on_activate(staticdata, dtime_s)
    if staticdata ~= "" and staticdata ~= nil then
        local data = core.parse_json(staticdata) or {}
        self:set_message(data.message)
    end
end
```

Luanti darf `get_staticdata()` beliebig oft und zu jedem Zeitpunkt aufrufen.
Luanti wartet nämlich nicht, bis ein Mapblock inaktiv wird, um ihn zu speichern,
denn das könnte zu Datenverlust führen. Mapblöcke werden ungefähr alle 18
Sekunden gespeichert; in ähnlichen Abständen wird also auch `get_staticdata()`
aufgerufen.

`on_activate()` wird dagegen nur aufgerufen, wenn eine Entity aktiv wird –
entweder weil ihr Mapblock aktiv wird oder weil sie neu erzeugt wird. Staticdata
kann deshalb leer sein.

Zum Schluss registrierst du die Typ-Tabelle mit der passend benannten Funktion
`register_entity`.

```lua
core.register_entity("mymod:entity", MyEntity)
```

Ein Mod kann die Entity so erzeugen:

```lua
local pos = { x = 1, y = 2, z = 3 }
local obj = core.add_entity(pos, "mymod:entity", nil)
```

Der dritte Parameter sind die anfänglichen Staticdata. Die Nachricht setzt du
über die Methode der Entity-Tabelle:

```lua
obj:get_luaentity():set_message("Hallo!")
```

Spieler mit dem [Privileg](../players/privileges.html) *give* können Entities
mit einem [Chatbefehl](../players/chat.html) erzeugen:

    /spawnentity mymod:entity

## Lebenspunkte und Schaden

### Lebenspunkte (HP)

Jedes Objekt hat einen Wert für Lebenspunkte (*health points*, HP), der seine
aktuelle Gesundheit angibt. Die maximalen HP legt die Objekteigenschaft
`hp_max` fest. Fallen die HP auf 0, stirbt das Objekt.

```lua
local hp = object:get_hp()
object:set_hp(hp + 3)
```

### Schläge, Schadensgruppen und Rüstungsgruppen

Schaden verringert die HP eines Objekts. Ein Objekt kann ein anderes *schlagen*
(*punch*), um ihm Schaden zuzufügen. Ein Schlag muss kein echter Schlag sein –
es kann auch eine Explosion, ein Schwerthieb oder etwas anderes sein.

Der Gesamtschaden ergibt sich, indem die Schadensgruppen des Schlags mit der
Verwundbarkeit des Ziels multipliziert werden. Das Ergebnis wird dann begrenzt,
je nachdem, wie kurz der letzte Schlag zurückliegt. Gleich rechnen wir das an
einem Beispiel durch.

Wie die
[Abbautypen von Nodes](../items/nodes_items_crafting.html#tools-capabilities-and-dig-types)
können diese Gruppen beliebige Namen haben und müssen nicht registriert werden.
Üblich ist aber, dieselben Gruppennamen wie beim Abbauen von Nodes zu verwenden.

Wie verwundbar ein Objekt für bestimmte Schadensarten ist, hängt von seinen
`armor_groups` ab. Trotz des irreführenden Namens geben `armor_groups` an,
wie viel Prozent Schaden das Objekt von einer Schadensgruppe erleidet – nicht,
wie viel es abwehrt. Fehlt eine Schadensgruppe in den Rüstungsgruppen eines
Objekts, ist es gegen diese völlig unverwundbar.

```lua
target:set_armor_groups({
    fleshy = 90,
    crumbly = 50,
})
```

Im Beispiel erleidet das Objekt 90 % des `fleshy`-Schadens und 50 % des
`crumbly`-Schadens.

Schlägt ein Spieler ein Objekt, kommen die Schadensgruppen von dem Item, das er
gerade in der Hand hält. In anderen Fällen legen Mods fest, welche
Schadensgruppen verwendet werden.

### Beispiel für eine Schadensberechnung

Schlagen wir das Objekt `target`:

```lua
local tool_capabilities = {
    full_punch_interval = 0.8,
    damage_groups = { fleshy = 5, choppy = 10 },

    -- Nur fürs Abbauen von Nodes, aber trotzdem nötig
    max_drop_level=1,
    groupcaps={
        fleshy={times={[1]=2.5, [2]=1.20, [3]=0.35}, uses=30, maxlevel=2},
    },
}

local time_since_last_punch = tool_capabilities.full_punch_interval
target:punch(object, time_since_last_punch, tool_capabilities)
```

Jetzt berechnen wir den Schaden. Die Schadensgruppen des Schlags sind
`fleshy=5` und `choppy=10`; `target` erleidet 90 % des `fleshy`-Schadens und
0 % des `choppy`-Schadens.

Zuerst multiplizieren wir die Schadensgruppen mit der Verwundbarkeit und addieren
die Ergebnisse. Dann multiplizieren wir mit einer Zahl zwischen 0 und 1, die von
`time_since_last_punch` abhängt.

    t = limit(time_since_last_punch / full_punch_interval, 0, 1)
      = 1

    Schaden = (5*90/100 + 10*0/100) * t
            = 4.5

Da HP ganze Zahlen sind, wird der Schaden auf 5 Punkte gerundet.

## Anhängen

Angehängte Objekte bewegen sich mit, wenn sich das Elternobjekt – das Objekt, an
das sie angehängt sind – bewegt. Ein angehängtes Objekt heißt Kind des
Elternobjekts. Ein Objekt kann beliebig viele Kinder, aber höchstens ein
Elternobjekt haben.

```lua
child:set_attach(parent, bone, position, rotation)
```

`get_pos()` gibt immer die globale Position eines Objekts zurück, egal ob es
angehängt ist oder nicht. `set_attach` erwartet eine relative Position, aber
nicht so, wie man es erwarten würde: Die Position bezieht sich auf den Ursprung
des Elternobjekts, mit dem Faktor 10 skaliert. `0,5,0` ist also einen halben
Node über dem Ursprung des Elternobjekts.

::: {.warning title="Grad und Bogenmaß"}
Die Drehung beim Anhängen wird in Grad angegeben, die Drehung von Objekten
dagegen im Bogenmaß. Achte darauf, in die richtige Einheit umzurechnen.
:::

Bei animierten 3D-Modellen hängst du die Entity mit dem Argument `bone` an einen
Knochen. 3D-Animationen basieren auf Skeletten – einem Netz aus Knochen im
Modell, denen jeweils eine Position und Drehung gegeben werden kann, um das
Modell zu verändern, etwa um den Arm zu bewegen. Das Anhängen an einen Knochen
ist nützlich, wenn eine Figur etwas in der Hand halten soll:

```{.lua .keep}
obj:set_attach(player,
    "Arm_Right",           -- Standardknochen
    {x=0.2, y=6.5, z=3},   -- Standardposition
    {x=-100, y=225, z=90}) -- Standarddrehung
```

## Jetzt bist du dran

* Baue eine Windmühle aus Nodes und einer Entity.
* Erstelle einen Mob deiner Wahl (nur mit der Entity-API und ohne andere Mods).
