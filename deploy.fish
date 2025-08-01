#!/usr/bin/env fish

./build.fish --optimize
and scp app.js index.html root@hub.nojs.de:/var/www/dedris.nojs.de/
