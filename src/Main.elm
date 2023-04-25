module Main exposing ( main )

import Browser
import Browser.Events
import Dedris.Model exposing ( Model )
import Dedris.Msg as Msg exposing ( Msg )
import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower
import Dedris.Update as Update
import Dedris.View as View
import Json.Decode
import Keyboard.Event exposing ( decodeKeyboardEvent )
import Random
import Time


main : Program () Model Msg
main = Browser.document
    { init = init
    , subscriptions = subscriptions
    , update = update
    , view = View.app
    }


init : () -> ( Model , Cmd Msg )
init () =
    ( { tower = Tower.new
      , tmino = Tmino.i
      , next = Tmino.i
      , anchor = { row = 0 , col = 3 }
      , score = 0
      , gameOver = False
      , tickerMillis = 1000
      , pause = False
      }
    , Cmd.batch
        [ Random.generate Msg.NewTmino Tmino.random
        , Random.generate Msg.NewTmino Tmino.random
        ]
    )


subscriptions : Model -> Sub Msg
subscriptions mdl = Sub.batch
    [ Browser.Events.onKeyDown ( Json.Decode.map Msg.KeyDown decodeKeyboardEvent )
    , Time.every mdl.tickerMillis ( \ _ -> Msg.Tick )
    ]


update : Msg -> Model -> ( Model , Cmd Msg )
update msg mdl =
    if mdl.pause
    then case msg of
        Msg.KeyDown _ -> Update.togglePause mdl
        _ -> ( mdl , Cmd.none )
    else case msg of
        Msg.KeyDown { key , shiftKey } -> case ( key , shiftKey ) of
            -- Pfeiltasten
            ( Just "ArrowUp" , False ) -> Update.rotateRight mdl
            ( Just "ArrowUp" , True ) -> Update.rotateLeft mdl
            ( Just "ArrowLeft" , False ) -> Update.moveLeft mdl
            ( Just "ArrowRight" , False ) -> Update.moveRight mdl
            ( Just "ArrowDown" , False ) -> Update.moveDown mdl
            -- hjkl
            ( Just "k" , False ) -> Update.rotateRight mdl
            ( Just "K" , True ) -> Update.rotateLeft mdl
            ( Just "h" , False ) -> Update.moveLeft mdl
            ( Just "l" , False ) -> Update.moveRight mdl
            ( Just "j" , False ) -> Update.moveDown mdl
            -- Leertaste
            ( Just " " , False ) -> Update.togglePause mdl
            --
            _ -> ( mdl , Cmd.none )
        Msg.NewTmino tmino -> Update.newTmino tmino mdl
        Msg.Tick -> Update.moveDown mdl
        Msg.Reload -> Update.reload mdl


-- update_ : Msg -> Model -> ( Model , Cmd Msg )
-- update_ msg mdl = update ( Debug.log "msg" msg ) mdl
