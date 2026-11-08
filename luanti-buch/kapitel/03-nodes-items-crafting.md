---
title: Nodes, Items und Craften
label: items/nodes-items-crafting
---

Neue Nodes und Craftitems zu registrieren und Craftingrezepte anzulegen, gehört
zu den Grundlagen vieler Mods.

## Was sind Nodes und Items?

Nodes, Craftitems und Werkzeuge sind alles Items. Ein Item ist etwas, das sich
in einem Inventar befinden kann – selbst wenn das im normalen Spielverlauf nicht
möglich ist.

Ein Node ist ein Item, das platziert oder in der Welt gefunden werden kann.
Jede Position in der Welt ist mit genau einem Node belegt – scheinbar leere
Positionen sind normalerweise Luft-Nodes.

Ein Craftitem kann nicht platziert werden. Es kommt nur in Inventaren oder als
fallengelassenes Item in der Welt vor.

Ein Werkzeug ist wie ein Craftitem, kann sich aber abnutzen. Während du das
Werkzeug benutzt, sinkt der Abnutzungsbalken, bis das Werkzeug zerbricht.
Werkzeuge lassen sich außerdem nie stapeln. Vermutlich werden Craftitems und
Werkzeuge künftig zu einer einzigen Item-Art verschmelzen, da die Unterscheidung
zwischen ihnen recht künstlich ist.

## Items registrieren

Eine Item-Definition besteht aus einem *Itemnamen* und einer
*Definitionstabelle*. Die Definitionstabelle enthält Attribute, die das
Verhalten des Items bestimmen.

```lua
core.register_craftitem("modname:itemname", {
    description = "Mein besonderes Item",
    inventory_image = "modname_itemname.png"
})
```

### Itemnamen

Jedes Item hat einen Itemnamen, über den es angesprochen wird. Er hat folgendes
Format:

    modname:itemname

`modname` ist der Name des Mods, in dem das Item registriert wird, `itemname`
der Name des Items selbst. Der Itemname sollte beschreiben, was das Item ist,
und darf nicht bereits registriert sein.

Sowohl `modname` als auch `itemname` sollten nur Kleinbuchstaben, Ziffern und
Unterstriche enthalten.

### Item-Aliase

Items können auch *Aliase* haben, die auf ihren Namen verweisen. Ein *Alias* ist
ein Pseudo-Itemname: Die Engine behandelt jedes Vorkommen des Alias so, als
stünde dort der eigentliche Itemname. Dafür gibt es zwei häufige
Anwendungsfälle:

* Entfernte Items umbenennen. Wird ein Item ohne Korrekturcode aus einem Mod
  entfernt, können unbekannte Nodes in der Welt und in Inventaren
  zurückbleiben.
* Abkürzungen anlegen. `/giveme dirt` ist einfacher als
  `/giveme default:dirt`.

Einen Alias zu registrieren, ist einfach. Die Reihenfolge der Argumente merkst
du dir am besten als `von → nach`, wobei *von* der Alias und *nach* das Ziel
ist.

```lua
core.register_alias("dirt", "default:dirt")
```

Mods müssen Aliase selbst auflösen, bevor sie direkt mit Itemnamen arbeiten,
denn die Engine tut das nicht. Das geht aber ganz einfach:

```lua
itemname = core.registered_aliases[itemname] or itemname
```

### Texturen

Texturen gehören in den Ordner `textures/` und tragen Namen im Format
`modname_itemname.png`. JPEG-Texturen werden unterstützt, können aber keine
Transparenz und sehen bei niedrigen Auflösungen meist schlecht aus. Meist ist
PNG die bessere Wahl.

Texturen in Luanti sind in der Regel 16 × 16 Pixel groß. Sie können jede
Auflösung haben, empfohlen sind aber Zweierpotenzen, etwa 16, 32, 64 oder 128.
Andere Auflösungen werden auf älteren Geräten, besonders auf Smartphones,
möglicherweise nicht richtig unterstützt und verschlechtern dann die Leistung.

## Einen einfachen Node registrieren

Nodes werden ähnlich wie Items registriert, nur mit einer anderen Funktion:

```lua
core.register_node("mymod:diamond", {
    description = "Alien-Diamant",
    tiles = {"mymod_diamond.png"},
    is_ground_content = true,
    groups = {cracky=3, stone=1}
})
```

Node-Definitionen können jede Eigenschaft einer Item-Definition enthalten und
haben zusätzlich eigene, node-spezifische Eigenschaften.

Die Eigenschaft `tiles` ist eine Tabelle mit den Texturnamen, die der Node
verwendet. Gibt es nur eine Textur, wird sie auf allen Seiten verwendet. Für
eine eigene Textur je Seite gibst du die Namen von sechs Texturen in dieser
Reihenfolge an:

    oben (+Y), unten (-Y), rechts (+X), links (-X),
    hinten (+Z), vorne (-Z)

Denk daran, dass +Y in Luanti nach oben zeigt, wie in den meisten
3D-Computerspielen üblich.

```lua
core.register_node("mymod:diamond", {
    description = "Alien-Diamant",
    tiles = {
        "mymod_diamond_up.png",    -- y+
        "mymod_diamond_down.png",  -- y-
        "mymod_diamond_right.png", -- x+
        "mymod_diamond_left.png",  -- x-
        "mymod_diamond_back.png",  -- z+
        "mymod_diamond_front.png", -- z-
    },
    is_ground_content = true,
    groups = {cracky = 3},
    drop = "mymod:diamond_fragments"
    -- ^ statt des Diamanten Fragmente fallen lassen
})
```

Das Attribut `is_ground_content` erlaubt es, Höhlen durch diesen Node zu
graben. Das ist wichtig für jeden Node, der bei der Kartengenerierung unter der
Erde platziert werden kann. Höhlen werden aus der Welt herausgeschnitten,
nachdem alle anderen Nodes eines Gebiets generiert wurden.

## Crafting

Es gibt mehrere Arten von Craftingrezepten; welche gemeint ist, gibt die
Eigenschaft `type` an.

* `shaped` – Die Zutaten müssen an der richtigen Stelle liegen.
* `shapeless` – Es ist egal, wo die Zutaten liegen; nur die Menge muss stimmen.
* `cooking` – Rezepte für den Ofen.
* `fuel` – Legt fest, welche Items in Öfen verbrannt werden können.
* `tool_repair` – Legt fest, welche Items sich als Werkzeug reparieren lassen.

Craftingrezepte sind keine Items und haben daher keinen Itemnamen, der sie
eindeutig kennzeichnet.

### Shaped

Bei Shaped-Rezepten müssen die Zutaten in der richtigen Form, also im richtigen
Muster, angeordnet sein. Im folgenden Beispiel müssen die Fragmente wie ein
Stuhl angeordnet sein, damit das Rezept funktioniert. Die lokale Variable
`frag` hält das Rezept übersichtlich.

```{.lua .keep}
local frag = "mymod:diamond_fragments"

core.register_craft({
    type = "shaped",
    output = "mymod:diamond_chair 99",
    recipe = {
        { frag, "",   "" },
        { frag, frag, "" },
        { frag, frag, "" },
    },
})
```

Beachte die leere Spalte auf der rechten Seite. Sie bedeutet, dass rechts von
der Form eine leere Spalte vorhanden sein *muss*, sonst funktioniert das Rezept
nicht. Soll diese leere Spalte nicht nötig sein, lässt du die leeren Strings
einfach weg:

```{.lua .keep}
core.register_craft({
    output = "mymod:diamond_chair 99",
    recipe = {
        { frag, ""   },
        { frag, frag },
        { frag, frag },
    },
})
```

Das Feld `type` wird für Shaped-Rezepte eigentlich nicht gebraucht, da `shaped`
der Standardtyp ist.

### Shapeless

Shapeless-Rezepte verwendest du, wenn es egal ist, wo die Zutaten liegen –
Hauptsache, sie sind da.

```lua
core.register_craft({
    type = "shapeless",
    output = "mymod:diamond 3",
    recipe = {
        "mymod:diamond_fragments",
        "mymod:diamond_fragments",
        "mymod:diamond_fragments",
    },
})
```

### Cooking und Fuel

Rezepte vom Typ `cooking` werden nicht im Craftinggitter hergestellt, sondern
in Öfen oder anderen Kochgeräten gekocht, die es in Mods geben kann.

```lua
core.register_craft({
    type = "cooking",
    output = "mymod:diamond_fragments",
    recipe = "default:coalblock",
    cooktime = 10,
})
```

Der einzige echte Unterschied im Code ist, dass `recipe` nur ein einzelnes Item
ist statt einer Tabelle (in geschweiften Klammern). Optional gibt es den
Parameter `cooktime`, der festlegt, wie lange das Item zum Kochen braucht.
Ohne Angabe sind es 3 Sekunden.

Das Rezept oben funktioniert, wenn der Kohleblock im Eingabefeld liegt und
darunter irgendein Brennstoff. Nach 10 Sekunden entstehen Diamantfragmente!

Der Typ `fuel` ergänzt den Typ `cooking`: Er legt fest, was in Öfen und anderen
Kochgeräten aus Mods verbrannt werden kann.

```lua
core.register_craft({
    type = "fuel",
    recipe = "mymod:diamond",
    burntime = 300,
})
```

Fuel-Rezepte haben kein Ergebnis wie andere Rezepte, dafür aber eine Brenndauer
in Sekunden, die angibt, wie lange sie als Brennstoff reichen. Der Diamant
brennt also 300 Sekunden lang!

## Gruppen

Items können Mitglied in vielen Gruppen sein, und Gruppen können viele
Mitglieder haben. Gruppen werden mit der Eigenschaft `groups` in der
Definitionstabelle festgelegt und haben jeweils einen zugehörigen Wert.

```lua
groups = {cracky = 3, wood = 1}
```

Gruppen haben mehrere Zwecke. Erstens beschreiben sie Eigenschaften wie
Abbautyp und Brennbarkeit. Zweitens kann in einem Craftingrezept statt eines
Itemnamens eine Gruppe stehen; dann passt jedes Item dieser Gruppe.

```lua
core.register_craft({
    type = "shapeless",
    output = "mymod:diamond_thing 3",
    recipe = {"group:wood", "mymod:diamond"}
})
```

## Werkzeuge, Fähigkeiten und Abbautypen

Abbautypen sind Gruppen, die festlegen, wie widerstandsfähig ein Node beim
Abbauen mit verschiedenen Werkzeugen ist. Ein höherer Wert in einer
Abbautyp-Gruppe bedeutet, dass sich der Node leichter und schneller abbauen
lässt. Mehrere Abbautypen lassen sich kombinieren, damit verschiedene
Werkzeugarten effizient eingesetzt werden können. Ein Node ohne Abbautyp kann
mit keinem Werkzeug abgebaut werden.

| Gruppe | Bestes Werkzeug | Beschreibung |
|--------|-----------------|--------------|
| `crumbly` | Schaufel | Erde, Sand |
| `cracky` | Spitzhacke | Zähes (aber sprödes) Material wie Stein |
| `snappy` | *beliebig* | Lässt sich mit feinen Werkzeugen schneiden, z.\ B. Blätter, kleine Pflanzen, Draht, Blech |
| `choppy` | Axt | Lässt sich mit scharfer Kraft schneiden, z.\ B. Bäume, Holzbretter |
| `fleshy` | Schwert | Lebewesen wie Tiere und der Spieler; kann Bluteffekte beim Treffen nahelegen |
| `explody` | ? | Besonders anfällig für Explosionen |
| `oddly_breakable_by_hand` | *beliebig* | Fackeln und Ähnliches – sehr schnell abzubauen |

Jedes Werkzeug hat eine Werkzeugfähigkeit (*tool capability*). Sie umfasst eine
Liste der unterstützten Abbautypen und für jeden Typ zugehörige Eigenschaften
wie Abbauzeiten und Abnutzung. Werkzeuge können außerdem je Typ eine maximale
Härte haben; so lässt sich verhindern, dass schwächere Werkzeuge härtere Nodes
abbauen. Sehr häufig enthalten Werkzeuge alle Abbautypen in ihren Fähigkeiten,
wobei die weniger geeigneten sehr ineffiziente Werte haben. Hat das Item, das
ein Spieler gerade in der Hand hält, keine eigene Werkzeugfähigkeit, wird
stattdessen die Fähigkeit der Hand verwendet.

```lua
core.register_tool("mymod:tool", {
    description = "Mein Werkzeug",
    inventory_image = "mymod_tool.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            crumbly = {
                maxlevel = 2,
                uses = 20,
                times = { [1]=1.60, [2]=1.20, [3]=0.80 }
            },
        },
        damage_groups = {fleshy=2},
    },
})
```

`groupcaps` ist die Liste der Abbautypen, mit denen das Werkzeug Nodes abbauen
kann. Schadensgruppen (*damage groups*) steuern, wie Werkzeuge Objekten Schaden
zufügen; das wird später im Kapitel „Objekte, Spieler und Entities“ behandelt.
