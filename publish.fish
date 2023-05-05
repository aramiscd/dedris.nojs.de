#!/usr/bin/env fish

git push git@git.eee.gg:aramis/elm-dedris
git push git@git.eee.gg:aramis/elm-dedris --tags
git push git@git.sr.ht:~aramis/elm-dedris
git push git@git.sr.ht:~aramis/elm-dedris --tags

elm make src/Main.elm --optimize --output=app.js
scp app.js index.html root@nojs.de:/var/www/dedris.nojs.de/
