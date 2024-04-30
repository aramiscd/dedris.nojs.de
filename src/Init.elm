module Init exposing ( init )

import Model exposing ( Model )
import Msg exposing ( Msg )
import Cmd


init : () -> ( Model , Cmd Msg )
init () =
    ( Model.init
    , Cmd.batch
        -- todo: Warum geht das nicht richtig mit nur einem Aufruf?
        [ Cmd.generateNewTetromino
        , Cmd.generateNewTetromino
        , Cmd.getViewport
        ]
    )
