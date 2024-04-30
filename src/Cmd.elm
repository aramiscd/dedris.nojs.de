module Cmd exposing
    ( generateNewTetromino
    , getViewport
    )

import Browser.Dom
import Dedris.Tetromino as Tetromino
import Msg exposing ( Msg )
import Random
import Task


generateNewTetromino : Cmd Msg
generateNewTetromino =
    Random.generate Msg.NewTmino Tetromino.random


getViewport : Cmd Msg
getViewport =
    Task.perform
        ( \ vp ->
            Msg.Viewport
                { height = floor vp.viewport.height
                , width = floor vp.viewport.width
                }
        )
        Browser.Dom.getViewport
