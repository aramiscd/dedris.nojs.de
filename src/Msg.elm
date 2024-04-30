module Msg exposing ( Msg (..) )

import Dedris.Motion exposing ( Motion )
import Dedris.Tetromino as Tetromino
import Keyboard.Event exposing ( KeyboardEvent )


type Msg
    = ActiveMotion Motion
    | KeyDown KeyboardEvent
    | MoveDown
    | MoveLeft
    | MoveRight
    | NewTmino Tetromino.Type
    | Reload
    | RotateLeft
    | RotateRight
    | Tick
    | Viewport { height : Int , width : Int }
