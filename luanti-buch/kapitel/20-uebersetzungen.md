---
title: Übersetzungen
label: quality/translations
---

Wenn deine Mods und Spiele übersetzt werden können, haben mehr Menschen Freude
daran. Laut Google Play haben 64 % der Luanti-Nutzer unter Android nicht
Englisch als Hauptsprache. Für alle Plattformen zusammen erhebt Luanti keine
Statistik zu den Sprachen der Nutzer, aber der Anteil nicht englischsprachiger
Spieler dürfte hoch sein.

In Luanti schreibst du deine Texte auf Englisch und bildest sie mit
Übersetzungsdateien auf andere Sprachen ab. Übersetzt wird auf dem Client jedes
Spielers, sodass jeder Spieler eine andere Sprache sehen kann.

## Wie funktioniert die Übersetzung auf dem Client?

### Markierter Text

Der Server muss den Clients mitteilen, wie Text übersetzt werden soll. Dazu
werden Steuerzeichen in den Text eingefügt, die Luanti sagen, wo und wie
übersetzt werden soll. Das nennt man *markierten Text* (*marked up text*);
dazu später mehr.

Um Text als übersetzbar zu markieren, verwendest du eine Übersetzerfunktion
(`S()`), die du mit `core.get_translator(textdomain)` erhältst:

```lua
local S = core.get_translator("mymod")

core.register_craftitem("mymod:item", {
    description = S("My Item"),
})
```

Das erste Argument von `get_translator` ist die *Textdomain*, eine Art
Namensraum. Statt alle Übersetzungen einer Sprache in einer Datei zu sammeln,
werden sie nach Textdomains getrennt, mit einer Datei je Textdomain und Sprache.
Die Textdomain sollte dem Mod-Namen entsprechen, um Konflikte zwischen Mods zu
vermeiden.

Markierten Text kannst du fast überall verwenden, wo lesbarer Text erwartet
wird, etwa in Formspecs, Feldern von Item-Definitionen, `infotext` und vielem
mehr. In Formspecs musst du markierten Text mit `core.formspec_escape` maskieren.

Trifft der Client auf übersetzbaren Text, etwa in `description`, sucht er ihn in
der Übersetzungsdatei für die Sprache des Spielers. Findet er keine Übersetzung,
verwendet er den englischen Text.

Übersetzbarer markierter Text enthält den englischen Ausgangstext, die
Textdomain und alle weiteren Argumente von `S()`. Er ist im Grunde eine
Textkodierung des `S`-Aufrufs mit allen nötigen Informationen.

Eine weitere Art markierten Texts liefert `core.colorize`.

::: {.tip title="Kodierung von markiertem Text"}
Das genaue Format von markiertem Text musst du nicht kennen, es hilft aber beim
Verständnis.

```
"\27(T@mymod)Hello everyone!\27E"
```

* `\27` ist das Escape-Zeichen. Es sagt Luanti, dass etwas Besonderes folgt.
  Es wird sowohl für Übersetzungen als auch für das Einfärben von Text verwendet.
* `(T@mymod)` besagt, dass der folgende Text mit der Textdomain `mymod`
  übersetzbar ist.
* `Hello everyone!` ist der übersetzbare englische Text, wie er der
  Übersetzerfunktion übergeben wurde.
* `\27E` ist wieder das Escape-Zeichen, gefolgt von `E`; es markiert das Ende.
:::

### Übersetzungsdateien

Übersetzungsdateien sind Mediendateien im Ordner `locale` des jeweiligen Mods.

Luanti unterstützt derzeit zwei Formate: *gettext* und ein eigenes, älteres
Format. Seit Luanti 5.10 gibt es gettext, ein verbreitetes und bewährtes Format.
Wenn möglich, solltest du gettext verwenden. Einziger Nachteil: Luanti-Clients
vor Version 5.10 können damit noch nicht umgehen.

Bei gettext erwartet Luanti Übersetzungsdateien im Format
`[textdomain].[sprache].po` im Ordner `locale`. Zum Erstellen und Pflegen kannst
du externe Werkzeuge verwenden. Die Luanti-Dokumentation enthält einen
[Artikel über Weblate](https://docs.luanti.org/for-creators/translation/weblate/)
(englisch).

Lies außerdem die offizielle
[Luanti-Dokumentation zu Übersetzungen](https://api.luanti.org/translations/)
(englisch).

Um Strings automatisch aus deinem Quellcode zu ziehen und `.pot`-Vorlagen zu
erzeugen, kannst du `gettext` installieren und diesen Befehl anpassen:

```
xgettext -L lua -kS -kPS:1,2 \
  -kcore.translate:1c,2 -kcore.translate_n:1c,2,3 \
  -d your_textdomain -o locale/your_textdomain.pot *.lua
```

Für jeden verwendeten Funktionsnamen kannst du ein weiteres `-k` angeben. Die
Angaben nach dem Funktionsnamen betreffen Pluralformen; Einzelheiten stehen im
Handbuch von gettext.

#### Altes Format

Übersetzungsdateien im alten Format heißen `[textdomain].[sprache].tr`.

Sie beginnen mit einem Kommentar, der die Textdomain angibt; die weiteren Zeilen
bilden den englischen Ausgangstext auf die Übersetzung ab.

Zum Beispiel `mymod.de.tr`:

```
# textdomain: mymod
Hello everyone!=Hallo zusammen!
I like grapefruit=Ich mag Grapefruit
```

Übersetzungsdateien solltest du aus dem Quellcode deines Mods oder Spiels
erzeugen, etwa mit
[update_translations](https://github.com/minetest-tools/update_translations).
Das Werkzeug sucht in deinem Lua-Code nach `S(` und erstellt automatisch eine
Vorlage, die Übersetzer in ihre Sprache übertragen können. Es aktualisiert die
Übersetzungsdateien auch, wenn sich dein Quellcode ändert.

Schreib in `S()` immer wörtlichen Text (in `"`) statt einer Variablen; so finden
Werkzeuge die zu übersetzenden Texte.

## Platzhalter

Oft müssen variable Informationen in einen übersetzbaren Text. Dabei darf der
Text nicht einfach verkettet werden, denn sonst können Übersetzer die
Reihenfolge der Variablen im Satz nicht ändern. Verwende stattdessen das
Platzhaltersystem der Übersetzung:

```lua
core.register_on_joinplayer(function(player)
    core.chat_send_all(S("Everyone, say hi to @1!", player:get_player_name()))
end)
```

Ein wörtliches `@` schreibst du in einer Übersetzung als `@@`.

Innerhalb eines Satzes solltest du nicht verketten, mehrere Sätze verkettest du
aber am besten. Das hilft Übersetzern, weil die Strings kürzer bleiben.

```lua
S("Hello @1!", player_name) .. " " .. S("You have @1 new messages.", #msgs)
```

## Gute Praxis und verbreitete Irrtümer

* Verkette keinen Text, sondern verwende Platzhalter. So haben Übersetzer volle
  Kontrolle über die Reihenfolge.
* Variablen verändern oft den umgebenden Text, etwa durch Geschlecht und
  Pluralbildung. Das ist schwer zu handhaben und wird deshalb oft übergangen oder
  mit geschlechtsneutralen Formulierungen umgangen.
* Übersetzungen können viel länger oder kürzer sein als der englische Text. Lass
  genug Platz.
* Andere Sprachen schreiben Zahlen womöglich anders, etwa mit Komma als
  Dezimaltrennzeichen: `1.000,23`, `1'000'000,32`.
* Geh nicht davon aus, dass andere Sprachen Groß- und Kleinschreibung genauso
  verwenden wie Englisch.

## Übersetzung auf dem Server

Manchmal brauchst du die Übersetzung eines Textes auf dem Server, etwa um Text
zu sortieren oder zu durchsuchen. Die Sprache eines Spielers erhältst du mit
`get_player_information`, und mit `get_translated_string` übersetzt du
markierten Text.

```lua
local list = {
    S("Hello world!"),
    S("Potato")
}

core.register_chatcommand("find", {
    func = function(name, param)
        local info = core.get_player_information(name)
        local language = info and info.language or "en"

        for _, line in ipairs(list) do
            local trans = core.get_translated_string(language, line)
            if trans:find(param, 1, true) then
                return true, line
            end
        end
        return false, S("Nothing found.")
    end,
})
```

## Fazit

Mit der Übersetzungs-API machst du Mods und Spiele mehr Menschen zugänglich. Sie
richtig einzusetzen, erfordert aber etwas Sorgfalt.
