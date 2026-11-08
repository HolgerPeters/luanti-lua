---
title: Häufige Fehler
label: quality/common-mistakes
---

Dieses Kapitel beschreibt häufige Fehler und wie du sie vermeidest.

## Vorsicht beim Speichern von ObjectRefs

Ein ObjectRef (also ein Spieler oder eine Entity) wird ungültig, wenn der
Spieler oder die Entity, für die es steht, das Spiel verlässt. Das passiert,
wenn der Spieler offline geht oder die Entity entladen oder entfernt wird.

Seit Luanti 5.2 geben die Methoden eines ungültigen ObjectRefs immer `nil`
zurück; jeder Aufruf wird im Grunde ignoriert.

Speichere ObjectRefs möglichst nicht. Wenn du es doch tust, prüfe vor der
Verwendung, ob das ObjectRef noch gültig ist:

```lua
-- Funktioniert erst ab Luanti 5.2
if obj:get_pos() then
    -- ist gültig!
end
```

## Formspec-Eingaben nicht vertrauen

Bösartige Clients können Formspecs jederzeit und mit beliebigem Inhalt
abschicken.

Der folgende Code hat zum Beispiel eine Sicherheitslücke, durch die Spieler sich
selbst Moderatorrechte geben können:

```lua
local function show_formspec(name)
    if not core.check_player_privs(name, { privs = true }) then
        return false
    end

    core.show_formspec(name, "modman:modman", [[
        size[3,2]
        field[0,0;3,1;target;Name;]
        button_exit[0,1;3,1;sub;Promote]
    ]])
    return true
end

core.register_on_player_receive_fields(function(player,
        formname, fields)
    -- SCHLECHT! Hier fehlt die Prüfung der Privilegien!

    local privs = core.get_player_privs(fields.target)
    privs.kick  = true
    privs.ban   = true
    core.set_player_privs(fields.target, privs)
    return true
end)
```

Mit einer Prüfung der Privilegien ist die Lücke geschlossen:

```lua
core.register_on_player_receive_fields(function(player,
        formname, fields)
    local name = player:get_player_name()
    if not core.check_player_privs(name, { privs = true }) then
        return false
    end

    -- Code
end)
```

## ItemStacks nach dem Ändern zurücksetzen

Ist dir aufgefallen, dass es in der API einfach `ItemStack` heißt und nicht
`ItemStackRef`, analog zu `InvRef`? Ein `ItemStack` ist nämlich keine Referenz,
sondern eine Kopie. Du arbeitest mit einer Kopie der Daten, nicht mit dem Stack
im Inventar. Änderst du den Stack, ändert sich der Stack im Inventar also nicht.

Mach das zum Beispiel nicht:

```lua
local inv = player:get_inventory()
local stack = inv:get_stack("main", 1)
stack:get_meta():set_string("description", "Angebissen")
-- SCHLECHT! Die Änderung geht verloren
```

Sondern so:

```lua
local inv = player:get_inventory()
local stack = inv:get_stack("main", 1)
stack:get_meta():set_string("description", "Angebissen")
inv:set_stack("main", 1, stack)
-- Richtig! Der ItemStack wird gesetzt
```

Bei Callbacks ist es etwas komplizierter. Änderst du einen übergebenen
`ItemStack`, ändert er sich auch für den Aufrufer und alle folgenden Callbacks.
In der Engine gespeichert wird er aber nur, wenn der Aufrufer des Callbacks ihn
setzt.

```lua
core.register_on_item_eat(function(hp_change, replace_with_item,
        itemstack, user, pointed_thing)
    itemstack:get_meta():set_string("description", "Angebissen")
    -- Fast richtig! Die Daten gehen verloren,
    -- wenn ein anderer Callback das Verhalten abbricht
end)
```

Bricht kein Callback ab, wird der Stack gesetzt und die Beschreibung
aktualisiert. Bricht aber ein Callback ab, kann die Änderung verloren gehen.

Besser ist es so:

```lua
core.register_on_item_eat(function(hp_change, replace_with_item,
        itemstack, user, pointed_thing)
    itemstack:get_meta():set_string("description", "Angebissen")
    user:get_inventory():set_stack("main", user:get_wield_index(),
            itemstack)
    -- Richtig, die Beschreibung wird immer gesetzt!
end)
```

Brechen die Callbacks ab oder setzt der Aufrufer den Stack nicht, wird die
Änderung trotzdem übernommen. Setzen die Callbacks oder der Aufrufer den Stack,
schadet das zusätzliche `set_stack` nicht.
