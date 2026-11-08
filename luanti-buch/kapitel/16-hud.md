---
title: HUD
label: players/hud
---

Mit HUD-Elementen (*Heads-up-Display*) zeigst du Text, Bilder und andere
grafische Elemente an.

Das HUD nimmt keine Eingaben entgegen; dafür verwendest du eine
[Formspec](../players/formspecs.html).

::: {.tip title="type statt hud_elem_type"}
Seit Luanti 5.9 heißt die Eigenschaft für den Elementtyp `type`. Der alte Name
`hud_elem_type` funktioniert noch, gilt aber als veraltet. Dieses Kapitel
verwendet durchgehend `type`.
:::

## Positionierung

### Position und Versatz

![Ein zentriertes Textelement](bilder/hud_diagram_center.pdf){width=6cm}

Bildschirme gibt es in vielen Größen und Auflösungen, und das HUD muss auf allen
gut funktionieren.

Luanti löst das, indem die Lage eines Elements aus einer prozentualen Position
und einem Versatz (*offset*) bestimmt wird. Die prozentuale Position bezieht
sich auf die Bildschirmgröße. Um ein Element in der Bildschirmmitte zu
platzieren, gibst du also die halbe Bildschirmgröße als Position an, etwa
(50 %, 50 %), und einen Versatz von (0, 0).

Mit dem Versatz verschiebst du das Element dann relativ zur prozentualen
Position.

### Ausrichtung

Die Ausrichtung (*alignment*) legt fest, wo am Element der aus Position und
Versatz berechnete Punkt liegt. Mit `{x = -1.0, y = 0.0}` zeigt dieser Punkt
zum Beispiel auf den linken Rand des Elements. Das ist besonders nützlich, um
Text links, mittig oder rechts auszurichten.

![Ausrichtung](bilder/hud_diagram_alignment.pdf){width=10cm}

Das Diagramm zeigt drei Fenster (blau) mit jeweils einem HUD-Element (gelb) und
unterschiedlicher Ausrichtung. Der Pfeil ist das Ergebnis aus Position und
Versatz.

### Punkteanzeige

In diesem Kapitel lernst du, eine Punkteanzeige wie diese zu positionieren und
zu aktualisieren:

![So soll das HUD am Ende aussehen](bilder/hud_final.png){width=5cm}

Im Bild haben alle Elemente dieselbe prozentuale Position (100 %, 50 %), aber
unterschiedliche Versätze. So ist das Ganze am rechten Fensterrand verankert und
bleibt beim Ändern der Fenstergröße intakt.

## Textelemente

Sobald du das Spielerobjekt hast, kannst du ein HUD-Element anlegen:

```lua
local player = core.get_player_by_name("username")
local idx = player:hud_add({
     type      = "text",
     position  = {x = 0.5, y = 0.5},
     offset    = {x = 0,   y = 0},
     text      = "Hallo Welt!",
     alignment = {x = 0, y = 0},  -- zentriert
     scale     = {x = 100, y = 100}, -- siehe unten
})
```

`hud_add` gibt eine Element-ID zurück, mit der du das HUD-Element später ändern
oder entfernen kannst.

### Parameter

Den Elementtyp gibst du mit der Eigenschaft `type` in der Definitionstabelle an.
Die Bedeutung der übrigen Eigenschaften hängt vom Typ ab.

`scale` ist der maximale Bereich für den Text; Text außerhalb wird
abgeschnitten, z.\ B. `{x=100, y=100}`.

`number` ist die Textfarbe als Hexadezimalzahl, z.\ B. `0xFF0000`.

### Unser Beispiel

Platzieren wir nun alle Texte unserer Punkteanzeige:

```lua
-- Zähler aus dem Speicher holen, Standard 0
local meta        = player:get_meta()
local digs_text   = "Abgebaut: " .. meta:get_int("score:digs")
local places_text = "Platziert: " .. meta:get_int("score:places")

player:hud_add({
    type      = "text",
    position  = {x = 1, y = 0.5},
    offset    = {x = -120, y = -25},
    text      = "Statistik",
    alignment = {x = 0, y = 0},
    scale     = {x = 100, y = 30},
    number    = 0xFFFFFF,
})

player:hud_add({
    type      = "text",
    position  = {x = 1, y = 0.5},
    offset    = {x = -180, y = 0},
    text      = digs_text,
    alignment = {x = -1, y = 0},
    scale     = {x = 50, y = 10},
    number    = 0xFFFFFF,
})

player:hud_add({
    type      = "text",
    position  = {x = 1, y = 0.5},
    offset    = {x = -70, y = 0},
    text      = places_text,
    alignment = {x = -1, y = 0},
    scale     = {x = 50, y = 10},
    number    = 0xFFFFFF,
})
```

Das ergibt Folgendes:

![Die Textelemente der Punkteanzeige](bilder/hud_text.png){width=6cm}

## Bildelemente

Bildelemente legst du ganz ähnlich an wie Textelemente:

```lua
player:hud_add({
    type      = "image",
    position  = {x = 1, y = 0.5},
    offset    = {x = -220, y = 0},
    text      = "score_background.png",
    scale     = {x = 1, y = 1},
    alignment = {x = 1, y = 0},
})
```

Jetzt sieht es so aus:

![Die Punkteanzeige mit Hintergrundbild](bilder/hud_background_img.png){width=5cm}

### Parameter

Im Feld `text` steht der Name des Bildes.

Ist eine Koordinate von `scale` positiv, ist sie ein Skalierungsfaktor: 1 ist
die Originalgröße, 2 die doppelte Größe und so weiter. Ist sie negativ, ist sie
ein Prozentwert der Bildschirmgröße; `x=-100` bedeutet zum Beispiel 100 % der
Breite.

### Skalierung

Als Beispiel für die Skalierung bauen wir den Fortschrittsbalken der
Punkteanzeige:

```lua
local percent = tonumber(meta:get("score:score") or 0.2)

player:hud_add({
    type      = "image",
    position  = {x = 1, y = 0.5},
    offset    = {x = -215, y = 23},
    text      = "score_bar_empty.png",
    scale     = {x = 1, y = 1},
    alignment = {x = 1, y = 0},
})

player:hud_add({
    type      = "image",
    position  = {x = 1, y = 0.5},
    offset    = {x = -215, y = 23},
    text      = "score_bar_full.png",
    scale     = {x = percent, y = 1},
    alignment = {x = 1, y = 0},
})
```

Jetzt sieht das HUD aus wie das am Anfang des Kapitels! Ein Problem gibt es
allerdings: Es aktualisiert sich nicht, wenn sich die Werte ändern.

## Ein Element ändern

Mit der ID, die `hud_add` zurückgibt, kannst du das Element später ändern oder
entfernen.

```lua
local idx = player:hud_add({
     type = "text",
     text = "Hallo Welt!",
     -- weitere Parameter der Kürze halber weggelassen
})

player:hud_change(idx, "text", "Neuer Text")
player:hud_remove(idx)
```

`hud_change` erwartet die Element-ID, die zu ändernde Eigenschaft und den neuen
Wert. Der Aufruf oben ändert die Eigenschaft `text` von „Hallo Welt!“ in „Neuer
Text“.

`hud_change` direkt nach `hud_add` aufzurufen, hat also dieselbe Wirkung wie
Folgendes, nur deutlich umständlicher:

```lua
local idx = player:hud_add({
     type = "text",
     text = "Neuer Text",
})
```

## IDs speichern

```lua
score = {}
local saved_huds = {}

function score.update_hud(player)
    local player_name = player:get_player_name()

    -- Zähler aus dem Speicher holen, Standard 0
    local meta        = player:get_meta()
    local digs_text   = "Abgebaut: " .. meta:get_int("score:digs")
    local places_text = "Platziert: " .. meta:get_int("score:places")
    local percent     = tonumber(meta:get("score:score") or 0.2)

    local ids = saved_huds[player_name]
    if ids then
        player:hud_change(ids["places"], "text", places_text)
        player:hud_change(ids["digs"],   "text", digs_text)
        player:hud_change(ids["bar_foreground"],
                "scale", { x = percent, y = 1 })
    else
        ids = {}
        saved_huds[player_name] = ids

        -- HUD-Elemente anlegen, IDs in `ids` merken
    end
end

core.register_on_joinplayer(score.update_hud)

core.register_on_leaveplayer(function(player)
    saved_huds[player:get_player_name()] = nil
end)
```

## Weitere Elemente

Eine vollständige Liste der HUD-Elemente findest du in der
[Lua-API-Referenz](https://api.luanti.org/hud/).
