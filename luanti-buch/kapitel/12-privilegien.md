---
title: Privilegien
label: players/privileges
---

Privilegien, kurz *Privs*, erlauben Spielern bestimmte Aktionen.
Serverbetreiber können Privilegien vergeben und entziehen und so steuern, was
jeder Spieler darf.

## Wann sind Privilegien sinnvoll?

Ein Privileg sollte einem Spieler erlauben, etwas zu *tun*. Privilegien sind
**nicht** dazu da, eine Klasse oder einen Rang anzuzeigen.

**Gute Privilegien:**

* `interact`
* `shout`
* `noclip`
* `fly`
* `kick`
* `ban`
* `vote`
* `worldedit`
* `area_admin` – Admin-Funktionen eines einzelnen Mods sind in Ordnung

**Schlechte Privilegien:**

* `moderator`
* `admin`
* `elf`
* `dwarf`

## Privilegien deklarieren

Ein neues Privileg legst du mit `register_privilege` an:

```lua
core.register_privilege("vote", {
    description = "Darf abstimmen",
    give_to_singleplayer = true
})
```

`give_to_singleplayer` ist standardmäßig `true`; in der Definition oben wäre es
also eigentlich nicht nötig.

## Privilegien prüfen

So prüfst du schnell, ob ein Spieler alle nötigen Privilegien hat:

```lua
local has, missing = core.check_player_privs(player_or_name,  {
    interact = true,
    vote = true })
```

Hier ist `has` gleich `true`, wenn der Spieler alle nötigen Privilegien hat. Ist
`has` gleich `false`, enthält `missing` eine Schlüssel-Wert-Tabelle der
fehlenden Privilegien.

```lua
local has, missing = core.check_player_privs(name, {
        interact = true,
        vote = true })

if has then
    print("Spieler hat alle Privilegien!")
else
    print("Spieler fehlen Privilegien: " .. dump(missing))
end
```

Brauchst du die fehlenden Privilegien nicht, kannst du `check_player_privs`
direkt in die `if`-Anweisung schreiben.

```lua
if not core.check_player_privs(name, { interact=true }) then
    return false, "Dafür brauchst du interact!"
end
```

## Privilegien lesen und setzen

Die Privilegien eines Spielers kannst du lesen und ändern, egal ob er online ist
oder nicht.

```lua
local privs = core.get_player_privs(name)
print(dump(privs))

privs.vote = true
core.set_player_privs(name, privs)
```

Privilegien werden immer als Schlüssel-Wert-Tabelle angegeben: Der Schlüssel ist
der Name des Privilegs, der Wert ein Wahrheitswert.

```lua
{
    fly = true,
    interact = true,
    shout = true
}
```

## Privilegien zu basic_privs hinzufügen

Spieler mit dem Privileg `basic_privs` dürfen eine begrenzte Auswahl an
Privilegien vergeben und entziehen. Üblicherweise bekommen Moderatoren dieses
Privileg, damit sie `interact` und `shout` vergeben und entziehen können, sich
selbst oder anderen aber keine leichter missbrauchbaren Privilegien wie `give`
oder `server` geben können.

Welche Privilegien deine Moderatoren vergeben und entziehen dürfen, legst du über
die Einstellung `basic_privs` fest.

Standardmäßig hat `basic_privs` diesen Wert:

    basic_privs = interact, shout

Um `vote` hinzuzufügen, änderst du ihn so:

    basic_privs = interact, shout, vote

Damit dürfen Spieler mit `basic_privs` das Privileg `vote` vergeben und
entziehen.
