# elm-dedris

Variante des beliebten Blockspiels.

https://dedris.nojs.de/

Ich wollte schon länger mal ein \*e\*ris in Elm schreiben.  2023 bin ich endlich dazu gekommen, das ernsthaft anzugehen.  Es war nicht völlig trivial, aber auch nicht besonders schwer: definitiv eine lohnenswerte Freizeitaktivität.

Es gibt in meiner Variante keine Level aber das Spiel beschleunigt mit der Zeit.  Ich nehme an, dass es bis in den mittleren vierstelligen Punktebereich spielbar ist bevor es zu schnell wird.


## Einschränkungen/ Bugs/ Todo

- Vorschau auf das nächste Tetromino ist noch nicht implementiert.
- Wenn man nach dem Spielende ein weiteres Spiel beginnt, ist das erste Tetromino des neuen Spiels das letzte des alten Spiels.  Das war so nicht von mir beabsichtigt.
- Ein Verweis au den Source Code könnte auch noch irgendwo untergebracht werden.
- Touch-UI benötigt mindestens ein paar Hinweise zur Bedienung.  Es scheint, so wie es jetzt ist, ohne Erklärung nicht spielbar zu sein.
- Performance verbessern, z.B. Subscriptions verringern
