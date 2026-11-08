---
title: Biome und Dekorationen
label: advmap/biomesdeco
---

Biome und Dekorationen registrieren zu können, ist entscheidend für eine
interessante und abwechslungsreiche Spielwelt. Dieses Kapitel zeigt, wie du
Biome registrierst, ihre Verteilung steuerst und Dekorationen in Biomen
platzierst.

## Was sind Biome?

Ein Biom ist in Luanti eine bestimmte Umgebung in der Spielwelt. Beim
Registrieren eines Bioms legst du fest, welche Nodes bei der Kartengenerierung
darin vorkommen. Zu den Node-Arten, die sich am häufigsten von Biom zu Biom
unterscheiden, gehören:

* Oberflächen-Node (*top node*): der Node, der an der Oberfläche am häufigsten
  vorkommt. Ein bekanntes Beispiel ist „Erde mit Gras“ aus Minetest Game.
* Füll-Node (*filler node*): die Schicht direkt unter dem Oberflächen-Node. In
  Biomen mit Gras ist das oft Erde.
* Stein-Node: der Node, den man unter der Erde am häufigsten sieht.
* Wasser-Node: meist eine Flüssigkeit; dieser Node erscheint dort, wo man
  Gewässer erwartet.

Auch andere Node-Arten können sich zwischen Biomen unterscheiden. So lassen sich
im selben Spiel sehr unterschiedliche Umgebungen schaffen.

## Platzierung von Biomen

### Wärme und Feuchtigkeit

Ein Biom nur zu registrieren, genügt nicht; du musst auch festlegen, wo es im
Spiel vorkommen kann. Dazu bekommt jedes Biom einen Wert für Wärme (*heat*) und
Feuchtigkeit (*humidity*).

Überlege dir diese Werte gut, denn sie bestimmen, welche Biome aneinandergrenzen
können. Bei schlechter Wahl grenzt eine heiße Wüste womöglich an einen Gletscher,
und es entstehen andere unwahrscheinliche Kombinationen, die du lieber vermeiden
möchtest.

Im Spiel liegen Wärme und Feuchtigkeit an jedem Punkt der Karte meist zwischen
0 und 100. Die Werte ändern sich allmählich, während man sich über die Karte
bewegt. An jedem Punkt entsteht das registrierte Biom, dessen Wärme- und
Feuchtigkeitswerte denen an dieser Stelle der Karte am nächsten kommen.

Da sich Wärme und Feuchtigkeit nur allmählich ändern, solltest du die Werte
eines Bioms an dem ausrichten, was man von seiner Umgebung erwarten würde. Zum
Beispiel:

* Eine Wüste hat hohe Wärme und niedrige Feuchtigkeit.
* Ein verschneiter Wald hat niedrige Wärme und mittlere Feuchtigkeit.
* Ein Sumpf hat meist hohe Feuchtigkeit.

Solange du eine vielfältige Auswahl an Biomen hast, ergibt sich so in der Praxis
meist ein logischer Übergang zwischen benachbarten Biomen.

### Grenzen mit Voronoi-Diagrammen veranschaulichen

![Voronoi-Diagramm: Jede Fläche enthält die Punkte, die ihrem Mittelpunkt am nächsten liegen. Bild: Balu Ertl, CC BY-SA 4.0](bilder/biomes_voronoi.png){width=5cm}

Wärme- und Feuchtigkeitswerte lassen sich leichter feinabstimmen, wenn du die
Beziehungen zwischen deinen Biomen sichtbar machst. Das ist besonders wichtig,
wenn du einen kompletten eigenen Satz an Biomen erstellst, kann aber auch beim
Ergänzen eines bestehenden Satzes helfen.

Am einfachsten machst du sichtbar, welche Biome aneinandergrenzen können, mit
einem Voronoi-Diagramm. Es zeigt für jede Stelle eines zweidimensionalen
Diagramms, welchem Punkt sie am nächsten liegt.

Ein Voronoi-Diagramm zeigt, wo Biome, die aneinandergrenzen sollten, es nicht
tun – und wo Biome aneinandergrenzen, die es nicht sollten. Außerdem gibt es
einen groben Eindruck davon, wie häufig Biome im Spiel sein werden: Große und
zentral liegende Biome sind häufiger als kleine oder solche am Rand des
Diagramms.

Dazu setzt du für jedes Biom einen Punkt anhand seiner Wärme und Feuchtigkeit,
mit der Wärme auf der x-Achse und der Feuchtigkeit auf der y-Achse. Dann teilst
du das Diagramm in Flächen ein, sodass jede Stelle einer Fläche näher an deren
Punkt liegt als an jedem anderen Punkt des Diagramms.

Jede Fläche steht für ein Biom. Haben zwei Flächen eine gemeinsame Grenze, können
die zugehörigen Biome im Spiel nebeneinander liegen. Wie lang die gemeinsame
Grenze im Vergleich zu den Grenzen mit anderen Flächen ist, verrät, wie häufig
die beiden Biome voraussichtlich nebeneinander vorkommen.

### Voronoi-Diagramme mit GeoGebra erstellen

Voronoi-Diagramme kannst du von Hand zeichnen oder mit Programmen wie
[GeoGebra](https://www.geogebra.org) erstellen.

1. Lege Punkte an, indem du in der Werkzeugleiste das Punktwerkzeug wählst
   (Symbol: ein Punkt mit „A“) und in das Diagramm klickst. Du kannst Punkte
   verschieben oder ihre Position in der linken Seitenleiste genau eingeben.
   Gib jedem Punkt außerdem eine Beschriftung, das macht es übersichtlicher.

2. Erzeuge dann das Voronoi-Diagramm, indem du in das Eingabefeld der linken
   Seitenleiste diese Funktion eingibst:

   ```
   Voronoi({ A, B, C, D, E })
   ```

   In den geschweiften Klammern stehen alle Punkte, durch Kommas getrennt.

3. Fertig! Du hast jetzt ein Voronoi-Diagramm, dessen Punkte du verschieben
   kannst.

## Ein Biom registrieren

Der folgende Code registriert ein einfaches Biom namens `grasslands`:

```lua
core.register_biome({
    name = "grasslands",
    node_top = "default:dirt_with_grass",
    depth_top = 1,
    node_filler = "default:dirt",
    depth_filler = 3,
    y_max = 1000,
    y_min = -3,
    heat_point = 50,
    humidity_point = 50,
})
```

Dieses Biom hat an der Oberfläche eine Schicht „Erde mit Gras“ und darunter
drei Schichten Erde. Es gibt keinen Stein-Node an; unter der Erde liegt daher
der Node, der als Mapgen-Alias `mapgen_stone` registriert ist.

Beim Registrieren eines Bioms gibt es viele Optionen; sie sind wie immer in der
[Lua-API-Referenz](https://api.luanti.org/definition-tables/#biome-definition)
dokumentiert.

Du musst nicht für jedes Biom jede Option angeben. Fehlt aber eine bestimmte
Option oder ein passender Mapgen-Alias, kann es zu Fehlern bei der
Kartengenerierung kommen.

## Was sind Dekorationen?

Dekorationen sind Nodes oder Schematics, die bei der Kartengenerierung auf der
Karte platziert werden. Typische Beispiele sind Blumen, Büsche und Bäume.
Kreativere Einsätze sind etwa Eiszapfen oder Stalagmiten in Höhlen, unterirdische
Kristallformationen oder sogar kleine Gebäude.

Dekorationen lassen sich auf bestimmte Biome, Höhen oder Untergrund-Nodes
beschränken. Oft gestalten sie die Umgebung eines Bioms, indem sie für bestimmte
Pflanzen, Bäume oder andere Merkmale sorgen.

## Eine einfache Dekoration registrieren

Einfache Dekorationen platzieren bei der Kartengenerierung einzelne Nodes. Du
gibst an, welcher Node als Dekoration platziert wird, wo er platziert werden
darf und wie häufig er vorkommt.

Zum Beispiel:

```lua
core.register_decoration({
    deco_type = "simple",
    place_on = {"base:dirt_with_grass"},
    sidelen = 16,
    fill_ratio = 0.1,
    biomes = {"grassy_plains"},
    y_max = 200,
    y_min = 1,
    decoration = "plants:grass",
})
```

Hier wird der Node `plants:grass` im Biom `grassy_plains` auf
`base:dirt_with_grass` platziert, zwischen den Höhen `y = 1` und `y = 200`.

`fill_ratio` bestimmt, wie häufig die Dekoration vorkommt; höhere Werte bis 1
führen zu sehr vielen Dekorationen. Alternativ kannst du die Platzierung über
Rauschparameter (*noise parameters*) steuern.

## Eine Schematic-Dekoration registrieren

Schematic-Dekorationen funktionieren ganz ähnlich wie einfache Dekorationen,
platzieren aber eine Schematic statt eines einzelnen Nodes. Zum Beispiel:

```lua
core.register_decoration({
    deco_type = "schematic",
    place_on = {"base:desert_sand"},
    sidelen = 16,
    fill_ratio = 0.0001,
    biomes = {"desert"},
    y_max = 200,
    y_min = 1,
    schematic = core.get_modpath("plants") .. "/schematics/cactus.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})
```

Hier wird die Schematic `cactus.mts` in Wüstenbiomen platziert. Du musst den
Pfad zu einer Schematic angeben; in diesem Fall liegt sie in einem eigenen
Schematic-Verzeichnis innerhalb des Mods.

Das Beispiel setzt außerdem Flags, um die Schematic mittig zu platzieren, und
eine zufällige Drehung. Zufällig gedrehte Schematics sorgen für mehr
Abwechslung, wenn sie nicht symmetrisch sind.

## Mapgen-Aliase

Bestehende Spiele bringen bereits passende Mapgen-Aliase mit. Eigene musst du
nur registrieren, wenn du ein eigenes Spiel entwickelst.

Mapgen-Aliase geben dem Kartengenerator der Engine Informationen und werden so
registriert:

```lua
core.register_alias("mapgen_stone", "base:smoke_stone")
```

Mindestens diese solltest du registrieren:

* `mapgen_stone`
* `mapgen_water_source`
* `mapgen_river_water_source`

Legst du nicht für alle Biome Höhlenflüssigkeiten fest, solltest du außerdem
registrieren:

* `mapgen_lava_source`
