#!/usr/bin/env fish

gren make src/Main.gren --optimize --output=index.html
scp index.html root@hub.nojs.de:/var/www/dedris.nojs.de/
