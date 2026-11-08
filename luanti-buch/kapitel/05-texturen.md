---
title: Texturen erstellen
label: items/creating-textures
---

Texturen erstellen und optimieren zu können, ist bei der Entwicklung für Luanti
sehr nützlich. Für Pixel-Art-Texturen gibt es viele hilfreiche Techniken, und
wer sie versteht, verbessert die Qualität seiner Texturen erheblich.

Ausführliche Anleitungen für gute Pixel-Art würden den Rahmen dieses Buches
sprengen; hier geht es nur um die wichtigsten Grundtechniken. Es gibt viele
[gute Online-Tutorials](http://www.photonstorm.com/art/tutorials-art/16x16-pixel-art-tutorial)
(englisch), die Pixel-Art viel ausführlicher behandeln.

## Techniken

### Mit dem Stift arbeiten

Das Stiftwerkzeug gibt es in den meisten Editoren. Auf die kleinste Größe
eingestellt, bearbeitest du damit ein Pixel nach dem anderen, ohne andere Teile
des Bildes zu verändern. So entstehen klare, scharfe Texturen ohne ungewollte
Unschärfe. Außerdem hast du damit viel Präzision und Kontrolle.

### Kacheln

Texturen für Nodes sollten in der Regel kachelbar sein. Das heißt: Setzt du
mehrere Nodes mit derselben Textur nebeneinander, passen die Kanten nahtlos
aneinander.

Passen die Kanten nicht zusammen, sieht das Ergebnis deutlich weniger
ansprechend aus.

### Transparenz

Transparenz ist wichtig für die Texturen fast aller Craftitems und mancher
Nodes, etwa Glas. Nicht jeder Editor unterstützt Transparenz; achte also
darauf, einen Editor zu wählen, der zu deinen Texturen passt.

### Farbpaletten

Eine einheitliche Farbpalette ist ein einfacher Weg, deine Grafiken deutlich
besser aussehen zu lassen. Verwende am besten eine Palette mit wenigen Farben,
höchstens etwa 32. Fertige Paletten findest du auf
[lospec.com](https://lospec.com/palette-list).

## Editoren

### MS Paint

MS Paint ist ein einfacher Editor, der für grundlegendes Texturdesign
ausreichen kann; Transparenz unterstützt er allerdings nicht. Für die Seiten von
Nodes spielt das meist keine Rolle, brauchst du aber Transparenz, solltest du
einen anderen Editor wählen.

### Aseprite / LibreSprite

[Aseprite](https://www.aseprite.org/) ist ein proprietärer Pixel-Art-Editor. Er
bringt von Haus aus viele nützliche Funktionen mit, etwa Farbpaletten und
Animationswerkzeuge.

[LibreSprite](https://libresprite.github.io/) ist ein quelloffener Fork von
Aseprite aus der Zeit, bevor Aseprite proprietär wurde.

### GIMP

GIMP ist in der Luanti-Community weit verbreitet. Die Einarbeitung dauert recht
lange, weil viele Funktionen nicht sofort ersichtlich sind.

Verwende in GIMP das Stiftwerkzeug mit dem Pinsel „Pixel“ und der Größe 1.
Außerdem empfiehlt es sich, beim Radierer die Option „Harte Kanten“ zu
aktivieren.
