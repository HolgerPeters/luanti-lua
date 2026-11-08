---
title: Saubere Architektur
label: quality/clean-arch
---

Hat dein Mod eine ordentliche Größe erreicht, wird es immer schwerer, den Code
sauber und fehlerfrei zu halten. Bei einer dynamisch typisierten Sprache wie Lua
ist das ein besonders großes Problem, denn der Compiler hilft dir kaum dabei,
etwa Typen richtig zu verwenden.

Dieses Kapitel behandelt wichtige Konzepte, die deinen Code sauber halten, und
verbreitete Entwurfsmuster dafür. Es ist nicht als Vorschrift gemeint, sondern
soll dir zeigen, welche Möglichkeiten es gibt. Den einen richtigen Weg, einen
Mod zu entwerfen, gibt es nicht; was guter Mod-Entwurf ist, ist sehr subjektiv.

## Kohäsion, Kopplung und Trennung der Belange

Ohne Planung verkommt ein Programmierprojekt mit der Zeit zu Spaghetticode.
Spaghetticode zeichnet sich durch fehlende Struktur aus – aller Code ist
zusammengewürfelt, ohne klare Grenzen. Am Ende ist das Projekt nicht mehr
wartbar und wird aufgegeben.

Das Gegenteil ist, dein Projekt als Sammlung kleinerer, zusammenwirkender
Programme oder Codebereiche zu entwerfen.

> Inside every large program, there is a small program trying to get out.
>
> In jedem großen Programm steckt ein kleines, das herauswill.
>
> — C. A. R. Hoare

Dabei solltest du eine *Trennung der Belange* (*separation of concerns*)
erreichen: Jeder Bereich ist klar abgegrenzt und kümmert sich um eine eigene
Aufgabe.

Diese Programme oder Bereiche sollten zwei Eigenschaften haben:

* **Hohe Kohäsion** – was in einem Bereich steht, gehört eng zusammen.
* **Geringe Kopplung** – halte die Abhängigkeiten zwischen Bereichen so gering
  wie möglich und verlass dich nicht auf interne Umsetzungen. Geringe Kopplung
  ist sehr sinnvoll, denn dann lassen sich die APIs einzelner Bereiche leichter
  ändern.

Das gilt sowohl für die Beziehungen zwischen Mods als auch für die Beziehungen
zwischen Bereichen innerhalb eines Mods.

## Beobachter

Ein einfacher Weg, Codebereiche voneinander zu trennen, ist das
Beobachter-Muster (*Observer*).

Nehmen wir als Beispiel eine Errungenschaft, die freigeschaltet wird, wenn ein
Spieler zum ersten Mal ein seltenes Tier erlegt. Der naive Ansatz wäre,
Errungenschaftscode in die Funktion für den Tod eines Mobs zu schreiben, die den
Mob-Namen prüft und bei Übereinstimmung die Errungenschaft freischaltet. Das ist
aber keine gute Idee, denn damit ist der Mob-Mod an den Errungenschaftscode
gekoppelt. Machst du so weiter – fügst etwa auch noch Erfahrungspunkte in den
Code für den Tod eines Mobs ein –, entsteht schnell ein Gewirr von
Abhängigkeiten.

Hier kommt das Beobachter-Muster ins Spiel. Statt dass sich der Mod `mymobs` um
Errungenschaften kümmert, bietet er anderen Codebereichen die Möglichkeit, ihr
Interesse an einem Ereignis anzumelden und Daten dazu zu erhalten.

```lua
mymobs.registered_on_death = {}
function mymobs.register_on_death(func)
    table.insert(mymobs.registered_on_death, func)
end

-- im Code für den Tod eines Mobs
for i=1, #mymobs.registered_on_death do
    mymobs.registered_on_death[i](entity, reason)
end
```

Der andere Code meldet dann sein Interesse an:

```lua
mymobs.register_on_death(function(mob, reason)
    if reason.type == "punch" and reason.object and
            reason.object:is_player() then
        awards.notify_mob_kill(reason.object, mob.name)
    end
end)
```

Vielleicht denkst du jetzt: Moment, das kommt mir bekannt vor. Richtig! Die
Luanti-API baut stark auf dem Beobachter-Muster auf, damit sich die Engine nicht
darum kümmern muss, wer auf etwas wartet.

## Model-View-Controller

Im nächsten Kapitel geht es darum, deinen Code automatisch zu testen. Eine
Schwierigkeit dabei ist, die Logik (Berechnungen, was getan werden soll)
möglichst weit von API-Aufrufen (`core.*`, andere Mods) zu trennen.

Ein Weg dahin ist, dir Folgendes zu überlegen:

* Welche **Daten** hast du?
* Welche **Aktionen** kannst du mit diesen Daten ausführen?
* Wie lösen **Ereignisse** (etwa Formspecs oder Schläge) diese Aktionen aus, und
  wie bewirken die Aktionen etwas in der Engine?

Nehmen wir einen Mod zum Schutz von Grundstücken. Die Daten sind die
Grundstücke und die zugehörigen Metadaten. Die Aktionen sind `create`, `edit` und
`delete`. Ausgelöst werden sie durch Chatbefehle und Formspec-Eingaben. Diese drei
Bereiche lassen sich meist gut voneinander trennen.

In deinen Tests kannst du dann sicherstellen, dass eine ausgelöste Aktion das
Richtige mit den Daten macht. Dass ein Ereignis eine Aktion auslöst, musst du
nicht testen – dafür bräuchtest du die Luanti-API, und dieser Codebereich sollte
ohnehin so klein wie möglich sein.

Die Datenschicht schreibst du in reinem Lua. „Rein“ heißt hier, dass die
Funktionen auch außerhalb von Luanti laufen könnten – keine Funktion der Engine
wird aufgerufen.

```lua
-- Daten
function land.create(name, area_name)
    land.lands[area_name] = {
        name  = area_name,
        owner = name,
        -- weitere Angaben
    }
end

function land.get_by_name(area_name)
    return land.lands[area_name]
end
```

Auch die Aktionen sollten rein sein, wobei Aufrufe anderer Funktionen hier eher
vertretbar sind als oben.

```lua
-- Controller
function land.handle_create_submit(name, area_name)
    -- Verarbeitung (etwa Überschneidungen,
    -- Kontingente und Rechte prüfen)

    land.create(name, area_name)
end

function land.handle_creation_request(name)
    -- Ein schlechtes Beispiel, wie später erklärt
    land.show_create_formspec(name)
end
```

Die Ereignis-Handler müssen mit der Luanti-API arbeiten. Halte die Berechnungen
hier so gering wie möglich, denn diesen Bereich kannst du nur schwer testen.

```lua
-- View
function land.show_create_formspec(name)
    -- Hier gibt es keine komplexen Berechnungen!
    core.show_formspec(name, "land:create", [[
        size[4,3]
        label[1,0;Das ist ein Beispiel]
        field[0,1;3,1;area_name;]
        button_exit[0,2;1,1;exit;Beenden]
    ]])
end

core.register_chatcommand("land", {
    privs = { land = true },
    func = function(name)
        land.handle_creation_request(name)
    end,
})

core.register_on_player_receive_fields(function(player,
            formname, fields)
    if formname ~= "land:create" then
        return
    end
    land.handle_create_submit(player:get_player_name(),
            fields.area_name)
end)
```

Das ist das Model-View-Controller-Muster. Das *Model* ist eine Sammlung von Daten
mit möglichst wenigen Funktionen. Die *View* ist eine Sammlung von Funktionen,
die auf Ereignisse warten und sie an den Controller weitergeben; außerdem nimmt
sie Aufrufe des Controllers entgegen, um etwas mit der Luanti-API zu tun. Im
*Controller* fallen die Entscheidungen, und hier finden die meisten Berechnungen
statt.

Der Controller sollte nichts über die Luanti-API wissen – beachte, dass es dort
keine Luanti-Aufrufe gibt und auch keine View-Funktionen, die ihnen ähneln. Eine
Funktion wie `view.hud_add(player, def)` sollte es *nicht* geben. Stattdessen
legt die View Aktionen fest, die der Controller bei ihr anstoßen kann, etwa
`view.add_hud(info)`, wobei `info` ein Wert oder eine Tabelle ist, die nichts mit
der Luanti-API zu tun hat.

![Model, View und Controller und ihre Verbindungen](bilder/mvc_diagram.pdf){width=12cm}

Wichtig ist, dass jeder Bereich nur mit seinen direkten Nachbarn kommuniziert,
wie im Diagramm gezeigt. So musst du weniger ändern, wenn du das Innere oder die
Schnittstelle eines Bereichs änderst. Um die Formspec zu ändern, musst du zum
Beispiel nur die View anpassen. Um die API der View zu ändern, musst du nur View
und Controller anpassen, das Model aber gar nicht.

In der Praxis wird dieser Entwurf selten verwendet, weil er die Komplexität
erhöht und den meisten Mods nicht viel bringt. Häufiger sieht man einen weniger
formalen und strengen Entwurf – Varianten von API-View.

### API-View

In einer idealen Welt wären die drei Bereiche oben sauber getrennt, und alle
Ereignisse gingen erst durch den Controller, bevor sie zur View zurückkehren.
Die Welt ist aber nicht ideal. Ein guter Kompromiss ist, den Mod in zwei Teile zu
gliedern:

* **API** – Das waren oben Model und Controller. Hier sollte `core.` nirgends
  vorkommen.
* **View** – Das war auch oben die View. Am besten teilst du sie in eigene Dateien
  für jede Art von Ereignis auf.

rubenwardys [crafting-Mod](https://github.com/rubenwardy/crafting) folgt ungefähr
diesem Entwurf. `api.lua` besteht fast nur aus reinen Lua-Funktionen für die
Datenhaltung und Berechnungen im Stil eines Controllers. `gui.lua` ist die View
für Formspecs und deren Eingaben, und `async_crafter.lua` ist View und
Controller für eine Node-Formspec und Node-Timer.

So aufgeteilt, lässt sich der API-Teil sehr einfach testen, weil er keine
Luanti-APIs verwendet – wie im [nächsten Kapitel](../quality/unit_testing.html)
gezeigt und im crafting-Mod zu sehen.

## Fazit

Guter Code-Entwurf ist subjektiv und hängt stark vom jeweiligen Projekt ab. Als
Faustregel gilt: Halte die Kohäsion hoch und die Kopplung gering. Anders gesagt:
Halte zusammen, was zusammengehört, trenne, was nicht zusammengehört, und halte
die Abhängigkeiten einfach.

Sehr zu empfehlen ist das Buch
[Game Programming Patterns](http://gameprogrammingpatterns.com/) (englisch). Es
ist kostenlos [online lesbar](http://gameprogrammingpatterns.com/contents.html)
und geht viel ausführlicher auf verbreitete Programmiermuster für Spiele ein.
