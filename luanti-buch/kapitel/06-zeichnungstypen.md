---
title: Zeichnungstypen von Nodes
label: items/node-drawtypes
---

Die Art, wie ein Node gezeichnet wird, heißt *Zeichnungstyp* (*drawtype*). Es
gibt viele davon. Das Verhalten eines Zeichnungstyps steuerst du über
Eigenschaften in der Definition des Node-Typs. Diese Eigenschaften gelten für
alle Instanzen dieses Nodes; manche lassen sich aber über `param2` auch je Node
steuern.

Im vorigen Kapitel wurden Nodes und Items eingeführt, eine vollständige
Definition eines Nodes fehlte aber noch. Die Luanti-Welt ist ein 3D-Gitter aus
Positionen. Jede Position heißt Node und besteht aus dem Node-Typ (Name) und
zwei Parametern (`param1` und `param2`). Der Name der Funktion
`core.register_node` ist etwas irreführend: Sie registriert nicht wirklich einen
Node, sondern einen neuen *Typ* von Node.

Die Node-Parameter steuern, wie ein einzelner Node dargestellt wird. `param1`
speichert die Beleuchtung eines Nodes; die Bedeutung von `param2` hängt von der
Eigenschaft `paramtype2` der Node-Typ-Definition ab.

## Würfelförmige Nodes: normal und allfaces

![Zeichnungstyp normal](bilder/drawtype_normal.png){width=4cm}

Der Zeichnungstyp `normal` wird typischerweise für würfelförmige Nodes
verwendet. Liegt eine Seite eines normalen Nodes an einer festen Seite an, wird
sie nicht gezeichnet. Das bringt einen großen Leistungsgewinn.

Der Zeichnungstyp `allfaces` zeichnet dagegen auch die Innenseite, wenn sie an
einem festen Node anliegt. Das eignet sich für Nodes mit teilweise transparenten
Seiten, etwa Blätter. Mit `allfaces_optional` können Benutzer das langsamere
Zeichnen abschalten; der Node verhält sich dann wie ein normaler Node.

```lua
core.register_node("mymod:diamond", {
    description = "Alien-Diamant",
    tiles = {"mymod_diamond.png"},
    groups = {cracky = 3},
})

core.register_node("default:leaves", {
    description = "Blätter",
    drawtype = "allfaces_optional",
    tiles = {"default_leaves.png"}
})
```

Hinweis: `normal` ist der Standard-Zeichnungstyp, du musst ihn also nicht
ausdrücklich angeben.

## Glasartige Nodes

Der Unterschied zwischen glasartigen (`glasslike`) und normalen Nodes: Steht ein
glasartiger Node neben einem normalen, wird die angrenzende Seite des normalen
Nodes trotzdem gezeichnet. Das ist nützlich, weil glasartige Nodes meist
transparent sind – mit dem Zeichnungstyp `normal` könnte man sonst durch die
Welt hindurchsehen.

![Kanten bei glasslike](bilder/drawtype_glasslike_edges.png){width=7cm}

```lua
core.register_node("default:obsidian_glass", {
    description = "Obsidianglas",
    drawtype = "glasslike",
    tiles = {"default_obsidian_glass.png"},
    paramtype = "light",
    is_ground_content = false,
    sunlight_propagates = true,
    sounds = default.node_sound_glass_defaults(),
    groups = {cracky=3,oddly_breakable_by_hand=3},
})
```

### glasslike_framed

Hier läuft der Rand mit einem 3D-Effekt um die gesamte zusammenhängende Fläche
statt um jeden einzelnen Node:

![Kanten bei glasslike\_framed](bilder/drawtype_glasslike_framed.png){width=7cm}

Mit dem Zeichnungstyp `glasslike_framed_optional` kann der Benutzer das gerahmte
Aussehen selbst *einschalten*.

```lua
core.register_node("default:glass", {
    description = "Glas",
    drawtype = "glasslike_framed",
    tiles = {"default_glass.png", "default_glass_detail.png"},
    inventory_image = core.inventorycube("default_glass.png"),
    paramtype = "light",
    sunlight_propagates = true, -- Sonnenlicht geht durch
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    sounds = default.node_sound_glass_defaults()
})
```

## Luftartige Nodes

Diese Nodes werden nicht gezeichnet und haben daher keine Texturen.

```lua
core.register_node("myair:air", {
    description = "MyAir (du Hacker, du!)",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,

    walkable     = false, -- sonst kollidiert der Spieler
    pointable    = false, -- Node kann nicht ausgewählt werden
    diggable     = false, -- Node kann nicht abgebaut werden
    buildable_to = true,  -- Nodes können diesen Node ersetzen
                          -- (man kann einen Node an seine Stelle
                          -- setzen, die Luft verschwindet dann)

    air_equivalent = true,
    drop = "",
    groups = {not_in_creative_inventory=1}
})
```

## Beleuchtung und Ausbreitung des Sonnenlichts

Die Beleuchtung eines Nodes wird in `param1` gespeichert. Um zu berechnen, wie
eine Seite eines Nodes schattiert wird, nimmt Luanti den Lichtwert des
benachbarten Nodes. Deshalb haben feste Nodes keine Lichtwerte – sie blockieren
das Licht ja.

Standardmäßig erlaubt ein Node-Typ nicht, Licht in seinen Instanzen zu
speichern. Bei manchen Nodes wie Glas und Luft soll Licht aber durchgehen. Dazu
müssen zwei Eigenschaften gesetzt werden:

```lua
paramtype = "light",
sunlight_propagates = true,
```

Die erste Zeile bedeutet, dass `param1` tatsächlich den Lichtwert speichert. Die
zweite, dass Sonnenlicht ohne Abschwächung durch den Node hindurchgeht.

## Flüssige Nodes

![Zeichnungstyp liquid](bilder/drawtype_liquid.png){width=4cm}

Jede Flüssigkeit braucht zwei Node-Definitionen: eine für die Quelle und eine
für die fließende Flüssigkeit.

```lua
-- Einige Eigenschaften wurden weggelassen, weil sie über
-- dieses Kapitel hinausgehen.
core.register_node("default:water_source", {
    drawtype = "liquid",
    paramtype = "light",

    inventory_image = core.inventorycube("default_water.png"),
    -- ^ nötig, damit das Inventarbild nicht animiert wird

    tiles = {
        {
            name = "default_water_source_animated.png",
            animation = {
                type     = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length   = 2.0
            }
        }
    },

    special_tiles = {
        -- Wasserquellen neuen Typs (kaum genutzt)
        {
            name      = "default_water_source_animated.png",
            animation = {type = "vertical_frames", aspect_w = 16,
                aspect_h = 16, length = 2.0},
            backface_culling = false,
        }
    },

    --
    -- Verhalten
    --
    walkable     = false, -- Spieler fällt hindurch
    pointable    = false, -- Spieler kann es nicht auswählen
    diggable     = false, -- Spieler kann es nicht abbauen
    buildable_to = true,  -- Nodes können diesen Node ersetzen

    alpha = 160,

    --
    -- Flüssigkeitseigenschaften
    --
    drowning = 1,
    liquidtype = "source",

    liquid_alternative_flowing = "default:water_flowing",
    -- ^ wenn die Flüssigkeit fließt

    liquid_alternative_source = "default:water_source",
    -- ^ wenn die Flüssigkeit eine Quelle ist

    liquid_viscosity = WATER_VISC,
    -- ^ wie schnell

    liquid_range = 8,
    -- ^ wie weit

    post_effect_color = {a=64, r=100, g=100, b=200},
    -- ^ Bildschirmfarbe unter Wasser
})
```

Fließende Nodes werden ähnlich definiert, nur mit anderem Namen und anderer
Animation. Ein vollständiges Beispiel ist `default:water_flowing` im Mod
`default` von Minetest Game.

## Nodeboxen

![Zeichnungstyp nodebox](bilder/drawtype_nodebox.png){width=4cm}

Mit Nodeboxen erstellst du Nodes, die nicht würfelförmig sind, sondern aus
beliebig vielen Quadern bestehen.

```lua
core.register_node("stairs:stair_stone", {
    drawtype = "nodebox",
    paramtype = "light",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
            {-0.5, 0, 0, 0.5, 0.5, 0.5},
        },
    }
})
```

Der wichtigste Teil ist die Nodebox-Tabelle:

```{.lua .keep}
{-0.5, -0.5, -0.5,       0.5,    0,  0.5},
{-0.5,    0,    0,       0.5,  0.5,  0.5}
```

Jede Zeile ist ein Quader; zusammen ergeben sie einen einzigen Node. Die ersten
drei Zahlen sind die Koordinaten (von −0,5 bis einschließlich 0,5) der unteren,
vorderen, linken Ecke, die letzten drei die der gegenüberliegenden Ecke. Die
Reihenfolge ist X, Y, Z, wobei Y nach oben zeigt.

Mit dem [NodeBoxEditor](https://forum.luanti.org/viewtopic.php?f=14&t=2840)
kannst du Nodeboxen erstellen, indem du die Kanten ziehst. Das ist anschaulicher
als die Arbeit von Hand.

### Nodeboxen für Wandmontage

Manchmal braucht man unterschiedliche Nodeboxen, je nachdem, ob der Node auf dem
Boden, an der Wand oder an der Decke platziert wird, etwa bei Fackeln.

```lua
core.register_node("default:sign_wall", {
    drawtype = "nodebox",
    node_box = {
        type = "wallmounted",

        -- Decke
        wall_top    = {
            {-0.4375, 0.4375, -0.3125, 0.4375, 0.5, 0.3125}
        },

        -- Boden
        wall_bottom = {
            {-0.4375, -0.5, -0.3125, 0.4375, -0.4375, 0.3125}
        },

        -- Wand
        wall_side   = {
            {-0.5, -0.3125, -0.4375, -0.4375, 0.3125, 0.4375}
        }
    },
})
```

## Mesh-Nodes

Nodeboxen sind zwar meist einfacher zu erstellen, bestehen aber nur aus Quadern.
Außerdem sind sie nicht optimiert: Innenflächen werden auch dann gezeichnet,
wenn sie vollständig verdeckt sind.

Eine Fläche (*face*) ist eine ebene Oberfläche eines Meshs. Eine Innenfläche
entsteht, wenn sich die Flächen zweier Nodeboxen überlappen. Teile des Modells
sind dann unsichtbar, werden aber trotzdem gezeichnet.

So registrierst du einen Mesh-Node:

```lua
core.register_node("mymod:meshy", {
    drawtype = "mesh",

    -- Enthält die Textur für jedes „Material“
    tiles = {
        "mymod_meshy.png"
    },

    -- Pfad zum Mesh
    mesh = "mymod_meshy.b3d",
})
```

Achte darauf, dass das Mesh in einem Verzeichnis `models` liegt. Meist gehört es
in den Ordner deines eigenen Mods; du kannst aber auch ein Mesh aus einem
anderen Mod verwenden, von dem deiner abhängt. Ein Mod, der weitere Möbel
hinzufügt, kann zum Beispiel die Modelle eines grundlegenden Möbel-Mods
mitnutzen.

## Signlike-Nodes

Signlike-Nodes sind flache Nodes, die an den Seiten anderer Nodes angebracht
werden. Trotz des Namens verwenden Schilder meist nicht `signlike`, sondern
`nodebox`, um einen 3D-Effekt zu erzielen. Leitern dagegen nutzen häufig
`signlike`.

```lua
core.register_node("default:ladder_wood", {
    drawtype = "signlike",

    tiles = {"default_ladder_wood.png"},

    -- Erforderlich: Drehung in param2 speichern
    paramtype2 = "wallmounted",

    selection_box = {
        type = "wallmounted",
    },
})
```

## Plantlike-Nodes

![Zeichnungstyp plantlike](bilder/drawtype_plantlike.png){width=4cm}

Plantlike-Nodes zeichnen ihre Textur in einem X-förmigen Muster.

```lua
core.register_node("default:papyrus", {
    drawtype = "plantlike",

    -- Nur eine Textur
    tiles = {"default_papyrus.png"},

    selection_box = {
        type = "fixed",
        fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
    },
})
```

## Firelike-Nodes

`firelike` ähnelt `plantlike`, ist aber so gestaltet, dass es an Wänden und
Decken „haftet“.

![Firelike-Nodes](bilder/drawtype_firelike.png){width=7cm}

```lua
core.register_node("mymod:clinger", {
    drawtype = "firelike",

    -- Nur eine Textur
    tiles = { "mymod_clinger.png" },
})
```

## Weitere Zeichnungstypen

Die Liste ist nicht vollständig; es gibt noch weitere Typen, darunter:

* `fencelike`
* `plantlike_rooted` – für Unterwasserpflanzen
* `raillike` – für Schienen
* `torchlike` – für 2D-Nodes an Wand, Boden oder Decke.
  Die Fackeln in Minetest Game verwenden allerdings Mesh-Nodes mit drei
  getrennten Definitionen (`default:torch`, `default:torch_wall` und
  `default:torch_ceiling`).

Die vollständige Liste findest du wie immer in der
[Lua-API-Dokumentation](https://api.luanti.org/nodes/#node-drawtypes).
