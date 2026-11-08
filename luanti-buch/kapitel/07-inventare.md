---
title: ItemStacks und Inventare
label: items/inventories
---

In diesem Kapitel lernst du, wie man Inventare verwendet und verändert – egal ob
Spielerinventar, Node-Inventar oder freistehendes Inventar.

## Was sind ItemStacks und Inventare?

Ein ItemStack sind die Daten hinter einem einzelnen Feld eines Inventars.

Ein *Inventar* ist eine Sammlung von *Inventarlisten*, von denen jede ein
2D-Gitter aus ItemStacks ist. Im Zusammenhang mit Inventaren heißen
Inventarlisten einfach *Listen*.

Spieler und Nodes haben jeweils nur ein einziges Inventar; Listen erlauben
mehrere Gitter innerhalb dieses Inventars. Standardmäßig hat der Spieler die
Liste `main` für den Großteil seines Inventars und einige Listen für das
Crafting.

## ItemStacks

ItemStacks bestehen aus vier Teilen: `name`, `count`, `wear` und Metadaten.

Der Itemname kann der Name eines registrierten Items, ein Alias oder ein
unbekannter Itemname sein. Unbekannte Items entstehen häufig, wenn Benutzer
Mods deinstallieren oder Mods Items ohne Vorkehrungen wie Aliase entfernen.

```lua
print(stack:get_name())
stack:set_name("default:dirt")

if not stack:is_known() then
    print("Unbekanntes Item!")
end
```

Die Anzahl ist immer 0 oder größer. Im normalen Spielverlauf sollte sie die
maximale Stapelgröße des Items, `stack_max`, nicht überschreiten. Admin-Befehle
und fehlerhafte Mods können aber dazu führen, dass Stacks größer werden.

```lua
print(stack:get_stack_max())
```

Ein ItemStack kann leer sein; dann ist die Anzahl 0.

```lua
print(stack:get_count())
stack:set_count(10)
```

ItemStacks lassen sich mit der Funktion `ItemStack` auf verschiedene Weise
erzeugen:

```lua
ItemStack() -- name="", count=0
ItemStack("default:pick_stone") -- count=1
ItemStack("default:stone 30")
ItemStack({ name = "default:wood", count = 10 })
```

Item-Metadaten sind ein unbegrenzter Schlüssel-Wert-Speicher für Daten zum Item.
Schlüssel-Wert heißt: Über einen Namen (den Schlüssel, *key*) greifst du auf die
Daten (den Wert, *value*) zu. Manche Schlüssel haben eine besondere Bedeutung,
etwa `description`, mit dem ein Stack eine eigene Beschreibung bekommt. Mehr dazu
im Kapitel [Speicherung und Metadaten](../map/storage.html).

## Inventarorte

Der Inventarort legt fest, wo und wie ein Inventar gespeichert wird. Es gibt drei
Arten: Spieler, Node und freistehend. Ein Inventar ist fest an genau einen Ort
gebunden – Änderungen am Inventar wirken sofort.

### Node-Inventare

Node-Inventare gehören zur Position eines bestimmten Nodes, etwa einer Truhe.
Der Node muss geladen sein, weil das Inventar in den
[Node-Metadaten](../map/storage.html#metadata) gespeichert wird.

```lua
on_punch = function(pos, node)
    local inv = core.get_inventory({ type="node", pos=pos })
    -- jetzt das Inventar verwenden
end,
```

So erhältst du eine *Inventar-Referenz*, meist *InvRef* genannt. Mit
Inventar-Referenzen veränderst du ein Inventar. *Referenz* bedeutet, dass die
Daten nicht im Objekt selbst liegen; das Objekt ändert die Daten direkt an Ort
und Stelle.

Den Ort einer Inventar-Referenz ermittelst du so:

```lua
local location = inv:get_location()
```

### Spielerinventare

Spielerinventare erhältst du auf ähnliche Weise oder über eine
Spieler-Referenz. Der Spieler muss online sein, damit du auf sein Inventar
zugreifen kannst.

```lua
local inv = core.get_inventory({ type="player", name="player1" })
-- oder
local inv = player:get_inventory()
```

### Freistehende Inventare

Ein freistehendes Inventar (*detached inventory*) ist unabhängig von Spielern
und Nodes. Es wird bei einem Neustart nicht gespeichert.

```lua
local inv = core.get_inventory({
    type="detached", name="inventory_name" })
```

Anders als die anderen Inventararten musst du ein freistehendes Inventar erst
anlegen, bevor du darauf zugreifst:

```lua
core.create_detached_inventory("inventory_name")
```

`create_detached_inventory` nimmt drei Argumente entgegen, von denen nur das
erste – der Inventarname – Pflicht ist. Das zweite ist eine Tabelle mit
Callbacks, mit denen du steuerst, wie Spieler mit dem Inventar umgehen können:

```lua
-- Freistehendes Inventar, in das man nur hineinlegen kann
core.create_detached_inventory("inventory_name", {
    allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
        return count -- Verschieben erlauben
    end,

    allow_put = function(inv, listname, index, stack, player)
        return stack:get_count() -- Hineinlegen erlauben
    end,

    allow_take = function(inv, listname, index, stack, player)
        return 0 -- Herausnehmen verbieten
    end,

    on_put = function(inv, listname, index, stack, player)
        core.chat_send_all(player:get_player_name() ..
            " hat " .. stack:to_string() ..
            " in die Spendenkiste gelegt, von " ..
            core.pos_to_string(player:get_pos()))
    end,
})
```

Berechtigungs-Callbacks – also die mit `allow_` am Anfang – geben die Anzahl der
zu übertragenden Items zurück; 0 verhindert die Übertragung ganz.

Aktions-Callbacks – die mit `on_` am Anfang – haben dagegen keinen Rückgabewert.

## Listen

Mit Inventarlisten lassen sich mehrere Gitter an einem einzigen Ort speichern.
Das ist vor allem für Spieler nützlich, denn es gibt einige Listen, die alle
Spiele haben, etwa das Hauptinventar (`main`) und die Craftingfelder (`craft`).

### Größe und Breite

Listen haben eine Größe, also die Gesamtzahl der Felder, und eine Breite, die
nur intern in der Engine verwendet wird. Beim Anzeigen des Inventars in einem
Fenster spielt die Breite der Liste keine Rolle, weil der Code des Fensters die
Breite selbst festlegt.

```lua
if inv:set_size("main", 32) then
    inv:set_width("main", 8)
    print("Größe:  " .. inv:get_size("main"))
    print("Breite: " .. inv:get_width("main"))
else
    print("Fehler: ungültige Liste oder Größe")
end
```

`set_size` schlägt fehl und gibt `false` zurück, wenn der Listenname oder die
Größe ungültig ist – etwa wenn die neue Größe zu klein für die Items ist, die
gerade im Inventar liegen.

### Inhalt prüfen

Mit `is_empty` prüfst du, ob eine Liste überhaupt Items enthält:

```lua
if inv:is_empty("main") then
    print("Die Liste ist leer!")
end
```

Mit `contains_item` prüfst du, ob eine Liste ein bestimmtes Item enthält:

```lua
if inv:contains_item("main", "default:stone") then
    print("Ich habe Stein gefunden!")
end
```

## Inventare und ItemStacks verändern

### Zu einer Liste hinzufügen

`add_item` fügt Items zu einer Liste hinzu (hier `"main"`). Im folgenden
Beispiel wird dabei auch die maximale Stapelgröße beachtet:

```lua
local stack    = ItemStack("default:stone 99")
local leftover = inv:add_item("main", stack)
if leftover:get_count() > 0 then
    print("Inventar ist voll! " ..
            leftover:get_count() .. " Items wurden nicht hinzugefügt")
end
```

### Items herausnehmen

So entfernst du Items aus einer Liste:

```lua
local taken = inv:remove_item("main", stack)
print("Herausgenommen: " .. taken:get_count())
```

### Stacks verändern

Einzelne Stacks veränderst du, indem du sie zuerst holst:

```lua
local stack = inv:get_stack(listname, 1)
```

Dann änderst du sie, indem du Eigenschaften setzt oder Methoden verwendest, die
die Stapelgröße beachten:

```lua
local stack    = ItemStack("default:stone 50")
local to_add   = ItemStack("default:stone 100")
local leftover = stack:add_item(to_add)
local taken    = stack:take_item(19)

print("Konnte " .. leftover:get_count() .. " Items nicht hinzufügen.")
-- ^ ergibt 51

print("Habe " .. stack:get_count() .. " Items")
-- ^ ergibt 80
--   min(50+100, stack_max) - 19 = 80
--     mit stack_max = 99
```

`add_item` fügt einem ItemStack Items hinzu und gibt alles zurück, was nicht
hineingepasst hat. `take_item` nimmt höchstens die angegebene Anzahl heraus,
eventuell auch weniger, und gibt den herausgenommenen Stack zurück.

Zum Schluss setzt du den ItemStack wieder ein:

```lua
inv:set_stack(listname, 1, stack)
```

Die Felder einer Liste werden, wie in Lua üblich, ab 1 gezählt.

## Abnutzung

Werkzeuge können sich abnutzen. Die Abnutzung wird als Balken angezeigt, und
ist das Werkzeug vollständig abgenutzt, zerbricht es. Die Abnutzung ist eine Zahl
bis 65535; je höher sie ist, desto stärker ist das Werkzeug abgenutzt.

Du veränderst sie mit `add_wear()`, `get_wear()` und `set_wear(wear)`.

```lua
local stack = ItemStack("default:pick_mese")
local max_uses = 10

-- Passiert automatisch beim Abbauen mit einem Werkzeug:
-- erhöht die Abnutzung um eine Benutzung.
stack:add_wear(65535 / (max_uses - 1))
```

Beim Abbauen kann die Abnutzung eines Werkzeugs vom abgebauten Node abhängen;
`max_uses` ist also je nach Node verschieden.

## Lua-Tabellen

ItemStacks und Inventare lassen sich in Tabellen umwandeln und umgekehrt. Das
ist praktisch zum Kopieren und für Massenoperationen.

```lua
-- Ganzes Inventar
local data = inv1:get_lists()
inv2:set_lists(data)

-- Eine Liste
local listdata = inv1:get_list("main")
inv2:set_list("main", listdata)
```

Die von `get_lists()` zurückgegebene Tabelle sieht so aus:

```lua
{
    list_one = {
        ItemStack,
        ItemStack,
        ItemStack,
        ItemStack,
        -- inv:get_size("list_one") Elemente
    },
    list_two = {
        ItemStack,
        ItemStack,
        ItemStack,
        ItemStack,
        -- inv:get_size("list_two") Elemente
    }
}
```

`get_list()` gibt eine einzelne Liste zurück, also einfach eine Liste von
ItemStacks.

Wichtig: Die `set`-Methoden oben verändern die Größe der Listen nicht. Du kannst
eine Liste also leeren, indem du sie auf eine leere Tabelle setzt, ohne dass
sie kleiner wird:

```lua
inv:set_list("main", {})
```
