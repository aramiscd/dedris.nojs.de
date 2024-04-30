module Subscriptions exposing ( subscriptions )

import Browser.Events
import Dedris.Motion as Motion
import Json.Decode
import Keyboard.Event exposing ( decodeKeyboardEvent )
import Model exposing ( Model )
import Msg exposing ( Msg )
import Time


subscriptions : Model -> Sub Msg
subscriptions mdl =
    Sub.batch
        [ Browser.Events.onKeyDown ( Json.Decode.map Msg.KeyDown decodeKeyboardEvent )
        , Time.every mdl.tickerMillis ( \ _ -> Msg.Tick )
        , Browser.Events.onResize
            ( \ width height -> Msg.Viewport { height = height , width = width } )
        , case mdl.activeMotion of
            Motion.None -> Sub.none
            Motion.MoveLeft -> Time.every 200 ( always Msg.MoveLeft )
            Motion.MoveRight -> Time.every 200 ( always Msg.MoveRight )
            Motion.MoveDown -> Time.every 50 ( always Msg.MoveDown )
            Motion.RotateLeft -> Time.every 200 ( always Msg.RotateLeft )
            Motion.RotateRight -> Time.every 200 ( always Msg.RotateRight )
        ]