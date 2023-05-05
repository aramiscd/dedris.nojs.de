module Dedris.Msg exposing ( Msg (..) )

import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Motion as Motion exposing ( Motion )
import Keyboard.Event exposing ( KeyboardEvent )
import Time


type Msg
    = ActiveMotion Motion
    | KeyDown KeyboardEvent
    | MoveDown
    | MoveLeft
    | MoveRight
    | NewTmino Tmino.Type
    | Reload
    | RotateLeft
    | RotateRight
    | Tick
    | Viewport { height : Int , width : Int }
