---
title: Speicherung und Metadaten
label: map/storage
---

In diesem Kapitel lernst du, wie du Daten speichern kannst.

## Metadaten

### Was sind Metadaten?

Metadaten sind in Luanti ein Schlüssel-Wert-Speicher, mit dem du eigene Daten
an etwas anhängst. Du kannst damit Informationen zu einem Node, einem Spieler
oder einem ItemStack speichern.

Alle Arten von Metadaten verwenden genau dieselbe API. Metadaten speichern
Werte als Strings, es gibt aber eine Reihe von Methoden, um andere einfache
Datentypen umzuwandeln und zu speichern.

Manche Schlüssel haben eine besondere Bedeutung. So speichert `infotext` in
Node-Metadaten den Tooltip, der erscheint, wenn man mit dem Fadenkreuz auf den
Node zeigt. Um Konflikte mit anderen Mods zu vermeiden, solltest du für
Schlüssel die übliche Namensraum-Konvention verwenden: `modname:keyname`.
Ausnahme sind gebräuchliche Angaben wie der Name des Besitzers, der als `owner`
gespeichert wird.

Metadaten sind Daten über Daten. Die Daten selbst, etwa der Typ eines Nodes oder
die Anzahl in einem Stack, sind keine Metadaten.

### Ein Metadaten-Objekt holen

Kennst du die Position eines Nodes, kannst du seine Metadaten abrufen:

```lua
local meta = core.get_meta({ x = 1, y = 2, z = 3 })
```

Spieler- und ItemStack-Metadaten erhältst du mit `get_meta()`:

```lua
local pmeta = player:get_meta()
local imeta = stack:get_meta()
```

### Lesen und Schreiben

Meist liest und schreibst du Metadaten mit den Methoden `get_<typ>()` und
`set_<typ>()`. Da Metadaten Strings speichern, setzen und lesen die
String-Methoden den Wert direkt.

```lua
print(meta:get_string("foo")) --> ""
meta:set_string("foo", "bar")
print(meta:get_string("foo")) --> "bar"
```

Alle typisierten Getter geben einen neutralen Standardwert zurück, wenn der
Schlüssel nicht existiert, etwa `""` oder `0`. Mit `get()` erhältst du einen
String oder `nil`.

Metadaten-Objekte sind Referenzen; Änderungen landen also automatisch an der
Quelle. ItemStacks sind dagegen keine Referenzen; nach einer Änderung musst du
den ItemStack wieder ins Inventar setzen.

Die Getter und Setter für andere Typen wandeln von und nach String um:

```lua
print(meta:get_int("count"))    --> 0
meta:set_int("count", 3)
print(meta:get_int("count"))    --> 3
print(meta:get_string("count")) --> "3"
```

### Besondere Schlüssel

`infotext` zeigt in Node-Metadaten einen Tooltip an, wenn das Fadenkreuz auf
den Node zeigt. Das ist nützlich, um Besitzer oder Zustand eines Nodes
anzuzeigen.

`description` überschreibt in ItemStack-Metadaten die Beschreibung, die beim
Überfahren des Stacks im Inventar erscheint. Farben kannst du mit
`core.colorize()` einfügen.

`owner` ist ein gebräuchlicher Schlüssel für den Namen des Spielers, dem das
Item oder der Node gehört.

### Tabellen speichern

Tabellen müssen in Strings umgewandelt werden, bevor du sie speichern kannst.
Luanti bietet dafür zwei Formate: Lua und JSON.

Das Lua-Format ist meist deutlich schneller und entspricht der
Tabellenschreibweise von Lua. JSON ist ein verbreiteterer Standard, besser
strukturiert und gut geeignet, wenn du Daten mit einem anderen Programm
austauschen musst. Für JSON gibt es `core.write_json()` und
`core.parse_json()`.

```lua
local data = { username = "player1", score = 1234 }
meta:set_string("foo", core.serialize(data))

data = core.deserialize(meta:get_string("foo"))
```

### Private Metadaten

Standardmäßig werden alle Node-Metadaten an den Client geschickt. Um das zu
verhindern, kannst du Schlüssel als privat markieren:

```lua
meta:set_string("secret", "asd34dn")
meta:mark_as_private("secret")
```

### Lua-Tabellen

Mit `to_table` und `from_table` wandelst du Metadaten in Lua-Tabellen um und
zurück:

```lua
local tmp = meta:to_table()
tmp.foo = "bar"
meta:from_table(tmp)
```

## Mod-Speicher

Der Mod-Speicher (*mod storage*) verwendet genau dieselbe API wie Metadaten,
auch wenn er technisch gesehen keine Metadaten sind. Er gehört jeweils zu einem
Mod und kann nur während der Ladezeit abgerufen werden, damit Luanti weiß,
welcher Mod ihn anfordert.

```lua
local storage = core.get_mod_storage()
```

Jetzt kannst du den Speicher genau wie Metadaten verwenden:

```lua
storage:set_string("foo", "bar")
```

## Datenbanken

Wird ein Mod wahrscheinlich auf Servern eingesetzt und speichert er viele Daten,
lohnt es sich, eine Datenbank als Speicher anzubieten. Mach das optional, indem
du trennst, *wie* die Daten gespeichert werden und *wo* sie verwendet werden.

```lua
local backend
if use_database then
    backend =
        dofile(core.get_modpath("mymod") .. "/backend_sqlite.lua")
else
    backend =
        dofile(core.get_modpath("mymod") .. "/backend_storage.lua")
end

backend.get_foo("a")
backend.set_foo("a", { score = 3 })
```

Die Datei `backend_storage.lua` enthält dann eine Umsetzung mit dem
Mod-Speicher:

```lua
local storage = core.get_mod_storage()
local backend = {}

function backend.set_foo(key, value)
    storage:set_string(key, core.serialize(value))
end

function backend.get_foo(key)
    return core.deserialize(storage:get_string(key))
end

return backend
```

`backend_sqlite.lua` macht dasselbe, verwendet aber statt des Mod-Speichers die
Lua-Bibliothek *lsqlite3*.

Für eine Datenbank wie SQLite brauchst du eine unsichere Umgebung (*insecure
environment*). Das ist eine Tabelle, die nur Mods zur Verfügung steht, die der
Benutzer ausdrücklich freigegeben hat. Sie enthält eine weniger eingeschränkte
Kopie der Lua-API, die von bösartigen Mods missbraucht werden könnte. Mehr dazu
im Kapitel [Sicherheit](../quality/security.html).

```lua
local ie = core.request_insecure_environment()
if not ie then
    error("Bitte mymod zu secure.trusted_mods hinzufügen")
end

local _sql = ie.require("lsqlite3")
-- globale sqlite3-Bibliothek vor anderen Mods verbergen
if sqlite3 then
    sqlite3 = nil
end
```

SQL oder die Bibliothek lsqlite3 zu erklären, würde den Rahmen dieses Buches
sprengen.

## Was soll ich verwenden?

Welche Methode passt, hängt davon ab, worauf sich die Daten beziehen, wie sie
aufgebaut sind und wie groß sie sind. Als Faustregel: Kleine Datenmengen gehen
bis 10 KB, mittlere bis 10 MB, alles darüber ist groß.

Node-Metadaten sind eine gute Wahl für Daten, die zu einem Node gehören.
Mittlere Datenmengen lassen sich recht effizient speichern, wenn du sie privat
markierst.

Item-Metadaten solltest du nur für kleine Datenmengen verwenden, denn sie werden
immer an den Client geschickt. Außerdem werden die Daten jedes Mal kopiert, wenn
der Stack bewegt oder aus Lua darauf zugegriffen wird.

Der Mod-Speicher eignet sich für mittlere Datenmengen; große Datenmengen zu
schreiben, kann aber ineffizient sein. Für große Datenmengen nimmst du besser
eine Datenbank, damit nicht bei jedem Speichern alle Daten geschrieben werden
müssen.

Datenbanken kommen nur für Server in Frage, weil der Mod für die unsichere
Umgebung freigegeben werden muss. Für große Datenmengen sind sie gut geeignet.

## Jetzt bist du dran

* Erstelle einen Node, der verschwindet, nachdem er fünfmal geschlagen wurde.
  (Verwende `on_punch` in der Node-Definition und `core.set_node`.)
