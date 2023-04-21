module Dedris.Update exposing
    ( moveDown
    , moveLeft
    , moveRight
    , rotateLeft
    , rotateRight
    , newTmino
    , reload
    )

import Dedris.Model exposing ( Model )
import Dedris.Msg as Msg exposing ( Msg )
import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower
import Random


moveDown : Model -> ( Model , Cmd Msg )
moveDown mdl =
    if canMoveDown mdl
    then move { row = mdl.anchor.row + 1 , col = mdl.anchor.col } mdl.tmino mdl
    else ( tminoDone mdl , Random.generate Msg.NewTmino Tmino.random )


moveLeft : Model -> ( Model , Cmd Msg )
moveLeft mdl = move { row = mdl.anchor.row , col = mdl.anchor.col - 1 } mdl.tmino mdl


moveRight : Model -> ( Model , Cmd Msg )
moveRight mdl = move { row = mdl.anchor.row , col = mdl.anchor.col + 1 } mdl.tmino mdl


move : { row : Int , col : Int } -> Tetromino -> Model -> ( Model , Cmd Msg )
move anchor tmino mdl =
    if Tower.fits anchor mdl.tower tmino && not mdl.gameOver
    then ( { mdl | anchor = anchor , tmino = tmino } , Cmd.none )
    else ( mdl , Cmd.none )


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


rotateLeft : Model -> ( Model , Cmd Msg )
rotateLeft mdl = case mdl.tmino.type_ of
    Tmino.I -> rotateRight mdl
    Tmino.J -> rotateRight { mdl | tmino = Tmino.rotate ( Tmino.rotate mdl.tmino ) }
    Tmino.L -> rotateRight { mdl | tmino = Tmino.rotate ( Tmino.rotate mdl.tmino ) }
    Tmino.O -> rotateRight mdl
    Tmino.S -> rotateRight mdl
    Tmino.T -> rotateRight { mdl | tmino = Tmino.rotate ( Tmino.rotate mdl.tmino ) }
    Tmino.Z -> rotateRight mdl


newTmino : Tmino.Type -> Model -> ( Model , Cmd Msg )
newTmino type_ mdl =
    if Tower.fits initialAnchor mdl.tower mdl.next
    then
        ( { mdl
            | tmino = mdl.next
            , next = Tmino.new type_
            , anchor = initialAnchor
            , tickerMillis = mdl.tickerMillis * 0.99
          }
        , Cmd.none
        )
    else
        ( { mdl | gameOver = True } , Cmd.none )


reload : Model -> ( Model , Cmd Msg )
reload mdl =
    ( { tower = Tower.new
      , tmino = mdl.tmino
      , next = mdl.next
      , anchor = initialAnchor
      , score = 0
      , gameOver = False
      , tickerMillis = 1000
      }
    , Cmd.none
    )



-- Helpers


canMoveDown : Model -> Bool
canMoveDown mdl = Tower.fits { row = mdl.anchor.row + 1 , col = mdl.anchor.col } mdl.tower mdl.tmino


tminoDone : Model -> Model
tminoDone mdl =
    let
        ( newTower , eliminated ) = mdl.tower |> Tower.set mdl.anchor mdl.tmino |> Tower.shrink
        score = eliminated * ( if eliminated < 4 then 10 else 20 )
    in
        { mdl | tower = newTower , score = mdl.score + score }


initialAnchor : { row : Int , col : Int }
initialAnchor = { row = 0 , col = 3 }
