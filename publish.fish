#!/usr/bin/env fish

git push origin
git push origin --tags

git push git@git.sr.ht:~aramis/elm-dedris
git push git@git.sr.ht:~aramis/elm-dedris --tags

elm make src/Main.elm --optimize --output=index.html
scp index.html root@hub.nojs.de:/var/www/dedris.nojs.de/
