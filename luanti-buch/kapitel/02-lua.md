---
title: Lua-Skripting
label: basics/lua
---

In diesem Kapitel lernst du die Skripterstellung in Lua kennen, die Werkzeuge,
die dir dabei helfen, und einige Techniken, die du nützlich finden wirst.

## Programmierung

Beim Programmieren geht es darum, ein Problem – etwa das Sortieren einer Liste –
in Schritte zu zerlegen, die ein Computer verstehen kann. Den logischen Prozess
des Programmierens zu vermitteln, würde den Rahmen dieses Buches sprengen; die
folgenden Angebote sind dafür aber sehr hilfreich:

* [Codecademy](http://www.codecademy.com/) (englisch) ist eine der besten
  Quellen, um Programmieren zu lernen. Sie bietet interaktive Lerneinheiten.
* [Scratch](https://scratch.mit.edu) eignet sich gut, um bei den absoluten
  Grundlagen anzufangen und die Problemlösungstechniken zu erlernen, die man zum
  Programmieren braucht. Besonders gut geeignet für Kinder und Jugendliche.
* [The Morpheus](https://www.youtube.com/@TheMorpheusTutorials) ist ein guter
  YouTube-Kanal, um programmieren zu lernen.

### Programmieren in Lua

Auch Lua selbst zu lehren, würde über dieses Buch hinausgehen. Das Buch
[Programming in Lua (PiL)](https://www.lua.org/pil/contents.html) (englisch)
ist jedoch eine ausgezeichnete Einführung in die Programmierung mit Lua.

## Code-Editoren

Zum Schreiben von Lua-Skripten genügt ein Code-Editor mit Syntaxhervorhebung.
Dabei werden Wörter und Zeichen je nach Bedeutung unterschiedlich eingefärbt.
So fallen Fehler und Ungereimtheiten leicht auf.

Zum Beispiel:

```lua
function ctf.post(team,msg)
    if not ctf.team(team) then
        return false
    end
    if not ctf.team(team).log then
        ctf.team(team).log = {}
    end

    table.insert(ctf.team(team).log,1,msg)
    ctf.save()

    return true
end
```

In diesem Beispiel sind die Schlüsselwörter hervorgehoben, darunter `if`,
`then`, `end` und `return`. Funktionen, die Lua standardmäßig mitbringt, etwa
`table.insert`, werden ebenfalls hervorgehoben.

Für den Einstieg empfehlen sich diese Editoren:

* [VSCode](https://code.visualstudio.com/) bzw. die quelloffene Variante
  [VSCodium](https://vscodium.com/): verbreitet und für alle Betriebssysteme
  erhältlich. Installiere dazu die Erweiterung
  [Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
  (Lua Language Server). Sie vervollständigt Code automatisch, zeigt Fehler
  schon beim Tippen an und springt auf Wunsch zur Definition einer Funktion.
  Ergänzend gibt es
  [Erweiterungen speziell für Luanti](https://marketplace.visualstudio.com/items?itemName=GreenXenith.minetest-tools).
* [Notepad++](http://notepad-plus-plus.org/) (englisch): schlicht, nur für
  Windows.

Es gibt auch andere geeignete Editoren.

## Lokaler und globaler Gültigkeitsbereich

Ob eine Variable lokal oder global ist, bestimmt, von wo aus sie gelesen und
beschrieben werden kann. Auf globale Variablen kann von überall in der
Skriptdatei und auch von jedem anderen Mod aus zugegriffen werden:

```lua
function one()
    foo = "bar"
end

function two()
    print(dump(foo))  -- Ausgabe: "bar"
end

one()
two()
```

Auf eine lokale Variable kann dagegen nur dort zugegriffen werden, wo sie
definiert ist. In Lua sind Variablen standardmäßig global; du musst daher
ausdrücklich das Schlüsselwort `local` verwenden:

```lua
-- Innerhalb dieser Skriptdatei zugänglich
local one = 1

function myfunc()
    -- Innerhalb dieser Funktion zugänglich
    local two = one + one

    if two == one then
        -- Innerhalb dieser if-Anweisung zugänglich
        local three = one + two
    end
end
```

### Möglichst lokale Variablen verwenden

Wann immer möglich, sollten lokale Variablen verwendet werden. Ein Mod sollte
höchstens eine globale Variable anlegen, und zwar mit demselben Namen wie der
Mod. Weitere globale Variablen sind unsauberer Programmierstil, und Luanti warnt
davor:

    Assignment to undeclared global 'foo' inside function
    at init.lua:2

Sinngemäß: Zuweisung an die nicht deklarierte globale Variable `foo` innerhalb
einer Funktion in `init.lua`, Zeile 2.

Um das zu beheben, verwende `local`:

```lua
function one()
    local foo = "bar"
end

function two()
    print(dump(foo))  -- Ausgabe: nil
end

one()
two()
```

Denk daran, dass `nil` **nicht initialisiert** bedeutet: Der Variablen
wurde noch kein Wert zugewiesen, sie existiert nicht, oder ihr Wert wurde
entfernt (also auf `nil` gesetzt).

Funktionen sind Variablen eines besonderen Typs, sollten aber ebenfalls lokal
sein, weil andere Mods Funktionen mit demselben Namen haben könnten.

```lua
local function foo(bar)
    return bar * 2
end
```

Damit andere Mods deine Funktionen aufrufen können, lege eine Tabelle mit
demselben Namen wie der Mod an und füge deine Funktionen dort ein. Diese Tabelle
wird oft als API-Tabelle oder Namensraum (*namespace*) bezeichnet.

```lua
mymod = {}

function mymod.foo(bar)
    return "foo" .. bar
end

-- In einem anderen Mod oder Skript:
mymod.foo("foobar")
```

Die Schreibweise `function mymod.foo()` ist gleichbedeutend mit
`mymod.foo = function()`, nur etwas lesbarer.

## Andere Lua-Skripte einbinden

Andere Lua-Skripte bindet man in einen Mod am besten mit *dofile* ein.

```lua
dofile(core.get_modpath("modname") .. "/script.lua")
```

Ein Skript kann einen Wert zurückgeben. Damit lassen sich private lokale
Variablen gezielt weitergeben:

```lua
-- script.lua
local module = {}
module.message = "Hallo Welt!"
return module
```

```lua
-- init.lua
local ret = dofile(core.get_modpath("modname") .. "/script.lua")
print(ret.message) -- Hallo Welt!
```

Wie man den Code eines Mods am besten aufteilt, wird
[in einem späteren Kapitel](../quality/clean_arch.html) erklärt.
