module Update exposing ( update )

import Dedris.Motion as Motion exposing ( Motion )
import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower
import Model exposing ( Model )
import Msg as Msg exposing ( Msg )
import Random


-- Reagiere auf interne Nachrichten
update : Msg -> Model -> ( Model , Cmd Msg )
update msg mdl =
    if mdl.pause
    then
        case msg of
            Msg.KeyDown _ -> togglePause mdl
            _ -> ( mdl , Cmd.none )
    else
        case msg of
            Msg.ActiveMotion motion -> activeMotion motion mdl
            Msg.MoveDown -> moveDown mdl
            Msg.MoveLeft -> moveLeft mdl
            Msg.MoveRight -> moveRight mdl
            Msg.NewTmino tmino -> newTmino tmino mdl
            Msg.Reload -> reload mdl
            Msg.RotateLeft -> rotateLeft mdl
            Msg.RotateRight -> rotateRight mdl
            Msg.Tick -> moveDown mdl
            Msg.Viewport vp -> viewport vp mdl
            Msg.KeyDown { key , shiftKey } ->
                case ( key , shiftKey ) of
                    -- Pfeiltasten
                    ( Just "ArrowUp" , False ) -> rotateRight mdl
                    ( Just "ArrowUp" , True ) -> rotateLeft mdl
                    ( Just "ArrowLeft" , False ) -> moveLeft mdl
                    ( Just "ArrowRight" , False ) -> moveRight mdl
                    ( Just "ArrowDown" , False ) -> moveDown mdl
                    -- hjkl
                    ( Just "k" , False ) -> rotateRight mdl
                    ( Just "K" , True ) -> rotateLeft mdl
                    ( Just "h" , False ) -> moveLeft mdl
                    ( Just "l" , False ) -> moveRight mdl
                    ( Just "j" , False ) -> moveDown mdl
                    -- Leertaste
                    ( Just " " , False ) -> togglePause mdl
                    --
                    _ -> ( mdl , Cmd.none )


-- Bewege Tetromino im Spielturm um eine Position nach unten oder lege ihn ab
-- und hole den nächsten
moveDown : Model -> ( Model , Cmd Msg )
moveDown mdl =
    if canMoveDown mdl
    then move { row = mdl.anchor.row + 1 , col = mdl.anchor.col } mdl.tmino mdl
    else ( tminoDone mdl , Random.generate Msg.NewTmino Tmino.random )


-- Bewege Tetromino im Spielturm nach links
moveLeft : Model -> ( Model , Cmd Msg )
moveLeft mdl =
    move { row = mdl.anchor.row , col = mdl.anchor.col - 1 } mdl.tmino mdl


-- Bewege Tetromino im Spielturm nach rechts
moveRight : Model -> ( Model , Cmd Msg )
moveRight mdl =
    move { row = mdl.anchor.row , col = mdl.anchor.col + 1 } mdl.tmino mdl


-- Bewege Tetromino wenn möglich im Spielturm an eine andere Position
move : { row : Int , col : Int } -> Tetromino -> Model -> ( Model , Cmd Msg )
move anchor tmino mdl =
    if Tower.fits anchor mdl.tower tmino && not mdl.gameOver
    then ( { mdl | anchor = anchor , tmino = tmino } , Cmd.none )
    else ( mdl , Cmd.none )


-- Rotiere Tetromino im Spielturm im Uhrzeigersinn
rotateRight : Model -> ( Model , Cmd Msg )
rotateRight mdl =
    let
        tmino = Tmino.rotate mdl.tmino
        anchor1 = { row = mdl.anchor.row , col = mdl.anchor.col + 1 }
        anchor2 = { row = mdl.anchor.row , col = mdl.anchor.col - 1 }
        anchor3 = { row = mdl.anchor.row , col = mdl.anchor.col + 2 }
        anchor4 = { row = mdl.anchor.row , col = mdl.anchor.col - 2 }
    in
        if Tower.fits mdl.anchor mdl.tower tmino then move mdl.anchor tmino mdl
        else if Tower.fits anchor1 mdl.tower tmino then move anchor1 tmino mdl
        else if Tower.fits anchor2 mdl.tower tmino then move anchor2 tmino mdl
        else if Tower.fits anchor3 mdl.tower tmino then move anchor3 tmino mdl
        else move anchor4 tmino mdl


-- Rotiere Tetromino im Spielturm gegen den Uhrzeigersinn
rotateLeft : Model -> ( Model , Cmd Msg )
rotateLeft mdl =
    case mdl.tmino.type_ of
        Tmino.I -> rotateRight mdl
        Tmino.J -> rotateRight { mdl | tmino = Tmino.rotate ( Tmino.rotate mdl.tmino ) }
        Tmino.L -> rotateRight { mdl | tmino = Tmino.rotate ( Tmino.rotate mdl.tmino ) }
        Tmino.O -> rotateRight mdl
        Tmino.S -> rotateRight mdl
        Tmino.T -> rotateRight { mdl | tmino = Tmino.rotate ( Tmino.rotate mdl.tmino ) }
        Tmino.Z -> rotateRight mdl


-- Hole neuen Tetromino ins Spiel oder beende das laufende Spiel
newTmino : Tmino.Type -> Model -> ( Model , Cmd Msg )
newTmino type_ mdl =
    if Tower.fits initialAnchor mdl.tower mdl.next
    then
        ( { mdl
            | tmino = mdl.next
            , next = Tmino.new type_
            , anchor = initialAnchor
            , tickerMillis = mdl.tickerMillis * 0.999
          }
        , Cmd.none
        )
    else
        ( { mdl | gameOver = True }
        , Cmd.none
        )


-- Beginne ein neues Spiel
reload : Model -> ( Model , Cmd Msg )
reload mdl =
    ( { tower = Tower.new
      , tmino = mdl.tmino
      , next = mdl.next
      , anchor = initialAnchor
      , score = 0
      , gameOver = False
      , tickerMillis = 1000
      , pause = False
      , viewport = { height = mdl.viewport.height , width = mdl.viewport.width }
      , activeMotion = Motion.None
      }
    , Cmd.none
    )


-- Wechsle zwischen Pause und laufendem Spiel
togglePause : Model -> ( Model , Cmd Msg )
togglePause mdl =
    ( { mdl | pause = not mdl.pause }
    , Cmd.none
    )


-- Speichere die Höhe und Breite der Anzeige
viewport : { height : Int , width : Int } -> Model -> ( Model , Cmd Msg )
viewport vp mdl =
    ( { mdl | viewport = vp }
    , Cmd.none
    )


-- Lege fest, welche Bewegung gerade aktiv ist
activeMotion : Motion -> Model -> ( Model , Cmd Msg )
activeMotion motion mdl =
    case motion of
        Motion.None -> ( { mdl | activeMotion = Motion.None } , Cmd.none )
        Motion.MoveLeft -> moveLeft { mdl | activeMotion = Motion.MoveLeft }
        Motion.MoveRight -> moveRight { mdl | activeMotion = Motion.MoveRight }
        Motion.MoveDown -> moveDown { mdl | activeMotion = Motion.MoveDown }
        Motion.RotateLeft -> rotateLeft { mdl | activeMotion = Motion.RotateLeft }
        Motion.RotateRight -> rotateRight { mdl | activeMotion = Motion.RotateRight }



-- Helpers


-- Prüfe, ob der Tetromino sich im Spielfeld um eine Position nach unten
-- bewegen kann
canMoveDown : Model -> Bool
canMoveDown mdl =
    Tower.fits
        { row = mdl.anchor.row + 1
        , col = mdl.anchor.col
        }
        mdl.tower
        mdl.tmino


-- Lege die Blöcke des aktiven Tetromino auf den Blockstapel und hole einen
-- neuen Tetromino ins Spiel
tminoDone : Model -> Model
tminoDone mdl =
    let
        ( newTower , eliminated ) =
            mdl.tower |> Tower.set mdl.anchor mdl.tmino |> Tower.shrink
        score =
            eliminated * ( if eliminated < 4 then 10 else 20 )
    in
        { mdl
            | tower = newTower
            , score = mdl.score + score
        }


-- Die Startposition für neu ins Spiel geholte Tetrominos
initialAnchor : { row : Int , col : Int }
initialAnchor =
    { row = 0
    , col = 3
    }
