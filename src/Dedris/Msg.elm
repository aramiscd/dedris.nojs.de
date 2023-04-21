module Dedris.Msg exposing ( Msg (..) )

import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Keyboard.Event exposing ( KeyboardEvent )
import Time


type Msg
    = KeyDown KeyboardEvent
    | NewTmino Tmino.Type
    | Reload
    | Tick
