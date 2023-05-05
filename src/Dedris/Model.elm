module Dedris.Model exposing ( Model )

import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower exposing ( Tower )
import Dedris.Motion as Motion exposing ( Motion )


type alias Model =
    { tower : Tower
    , tmino : Tetromino
    , next : Tetromino
    , anchor : { row : Int , col : Int }
    , score : Int
    , gameOver : Bool
    , tickerMillis : Float
    , pause : Bool
    , viewport : { height : Int , width : Int }
    , activeMotion : Motion
    }
