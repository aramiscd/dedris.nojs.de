module Main exposing ( main )

import Browser
import Browser.Dom
import Browser.Events
import Dedris.Model exposing ( Model )
import Dedris.Motion as Motion exposing ( Motion )
import Dedris.Msg as Msg exposing ( Msg )
import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower
import Dedris.Update as Update
import Dedris.View as View
import Json.Decode
import Keyboard.Event exposing ( decodeKeyboardEvent )
import Random
import Task
import Time


{-| Hauptprogramm.
-}
main : Program () Model Msg
main = Browser.document
    { init = init
    , subscriptions = subscriptions
    , update = update
    , view = View.app
    }


{-| Initialer Wert des Datenmodells.
-}
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
      , viewport = { height = 0 , width = 0 }
      , activeMotion = Motion.None
      }
    , Cmd.batch
        [ Random.generate Msg.NewTmino Tmino.random
        , Random.generate Msg.NewTmino Tmino.random
        , Task.perform ( Msg.Viewport << viewportShim ) Browser.Dom.getViewport
        ]
    )


{-| Warte und reagiere auf externe Ereignisse.
-}
subscriptions : Model -> Sub Msg
subscriptions mdl = Sub.batch
    [ Browser.Events.onKeyDown ( Json.Decode.map Msg.KeyDown decodeKeyboardEvent )
    , Time.every mdl.tickerMillis ( \ _ -> Msg.Tick )
    , Browser.Events.onResize ( \ width height -> Msg.Viewport { height = height , width = width } )
    , case mdl.activeMotion of
        -- todo
        Motion.None -> Sub.none
        Motion.MoveLeft -> Time.every 200 ( \ _ -> Msg.MoveLeft )
        Motion.MoveRight -> Time.every 200 ( \ _ -> Msg.MoveRight )
        Motion.MoveDown -> Time.every 50 ( \ _ -> Msg.MoveDown )
        Motion.RotateLeft -> Time.every 200 ( \ _ -> Msg.RotateLeft )
        Motion.RotateRight -> Time.every 200 ( \ _ -> Msg.RotateRight )
    ]


{-| Reagiere auf interne Nachrichten.
-}
update : Msg -> Model -> ( Model , Cmd Msg )
update msg mdl =
    if mdl.pause
    then case msg of
        Msg.KeyDown _ -> Update.togglePause mdl
        _ -> ( mdl , Cmd.none )
    else case msg of
        Msg.ActiveMotion motion -> Update.activeMotion motion mdl
        Msg.MoveDown -> Update.moveDown mdl
        Msg.MoveLeft -> Update.moveLeft mdl
        Msg.MoveRight -> Update.moveRight mdl
        Msg.NewTmino tmino -> Update.newTmino tmino mdl
        Msg.Reload -> Update.reload mdl
        Msg.RotateLeft -> Update.rotateLeft mdl
        Msg.RotateRight -> Update.rotateRight mdl
        Msg.Tick -> Update.moveDown mdl
        Msg.Viewport vp -> Update.viewport vp mdl
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


-- update_ : Msg -> Model -> ( Model , Cmd Msg )
-- update_ msg mdl = update ( Debug.log "msg" msg ) mdl



-- Helpers


{-| Extrahiere die relevanten Daten aus einem `Browser.Dom.Viewport`.
-}
viewportShim : Browser.Dom.Viewport -> { height : Int , width : Int }
viewportShim vp = { height = floor vp.viewport.height , width = floor vp.viewport.width }
