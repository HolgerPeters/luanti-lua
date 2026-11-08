---
title: Spielerphysik
label: players/player-physics
---

Die Physik eines Spielers lässt sich mit *Physik-Overrides* verändern. Damit
setzt du Gehgeschwindigkeit, Sprungkraft und Schwerkraft. Physik-Overrides
gelten jeweils für einen einzelnen Spieler und sind Faktoren: Ein Wert von 2 für
die Schwerkraft macht sie zum Beispiel doppelt so stark.

## Ein einfaches Beispiel

Hier ein Befehl `/antigravity`, der den aufrufenden Spieler in geringe
Schwerkraft versetzt:

```lua
core.register_chatcommand("antigravity", {
    func = function(name, param)
        local player = core.get_player_by_name(name)
        if not player then
            return false, "Nur für Spieler im Spiel"
        end
        player:set_physics_override({
            gravity = 0.1, -- 10 % der normalen Schwerkraft
        })
    end,
})
```

## Verfügbare Overrides

`player:set_physics_override()` bekommt eine Tabelle mit Overrides. Laut
[Lua-API-Referenz](https://api.luanti.org/class-reference/#player-only-no-op-for-other-objects)
sind die wichtigsten:

* `speed`: Faktor für die Gehgeschwindigkeit (Standard: 1)
* `jump`: Faktor für die Sprungkraft (Standard: 1)
* `gravity`: Faktor für die Schwerkraft (Standard: 1)
* `sneak`: ob der Spieler schleichen kann (Standard: `true`)

Seit Luanti 5.8 gibt es weitere Overrides, etwa `speed_climb`,
`speed_crouch`, `liquid_fluidity`, `liquid_sink`, `acceleration_default` und
`acceleration_air`. Die vollständige Liste steht in der Lua-API-Referenz.

### Altes Bewegungsverhalten

Vor Version 0.4.16 gab es den *Sneak-Glitch*, der verschiedene Bewegungstricks
erlaubte. So konnte man mit einer bestimmten Anordnung von Nodes einen
„Aufzug“ hochklettern, indem man schlich (Shift) und dabei die Leertaste
drückte. Das Verhalten war zwar unbeabsichtigt, ist aber in den Overrides
erhalten geblieben, weil viele Server es nutzen.

Um das alte Bewegungsverhalten vollständig wiederherzustellen, braucht es zwei
Overrides:

* `new_move`: ob der Spieler die neue Bewegung verwendet (Standard: `true`)
* `sneak_glitch`: ob der Spieler „Schleich-Aufzüge“ nutzen kann
  (Standard: `false`)

## Unverträglichkeit zwischen Mods

Achtung: Mods, die denselben Physikwert eines Spielers überschreiben, vertragen
sich meist nicht miteinander. Ein Override überschreibt alle zuvor gesetzten.
Setzen also mehrere Mods die Geschwindigkeit eines Spielers, gilt nur der zuletzt
gesetzte Wert.

## Jetzt bist du dran

* **Sonic**: Setze den Geschwindigkeitsfaktor auf einen hohen Wert
  (mindestens 6), wenn ein Spieler dem Spiel beitritt.
* **Superfeder**: Erhöhe die Sprungkraft, sodass der Spieler 20 Meter hoch
  springen kann (1 Meter entspricht 1 Node).
* **Weltraum**: Lass die Schwerkraft abnehmen, je höher der Spieler kommt.
