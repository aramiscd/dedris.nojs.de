module Dedris.Model exposing ( Model )

import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower exposing ( Tower )


type alias Model =
    { tower : Tower
    , tmino : Tetromino
    , next : Tetromino
    , anchor : { row : Int , col : Int }
    , score : Int
    , gameOver : Bool
    , tickerMillis : Float
    }
