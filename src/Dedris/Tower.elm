module Dedris.Tower exposing
    ( Tower
    , new
    , get
    , set
    , fits
    , shrink
    , height
    , width
    )

import Array exposing ( Array )
import Dedris.Tetromino as Tmino exposing ( Tetromino )


{-| Dedris Spielturm.
-}
type Tower = Tower ( Array ( Array ( Maybe Tmino.Type ) ) )


{-| Höhe des Spielturms.
-}
height = 20


{-| Breite des Spielturms.
-}
width = 10


{-| Erzeuge einen neuen Spielturm.
-}
new : Tower
new = Tower ( Array.initialize height ( \ _ -> Array.initialize width ( \ _ -> Nothing ) ) )


{-| Die Belegung einer Position im Spielturm.
-}
get : { row : Int , col : Int } -> Tower -> Maybe Tmino.Type
get { row , col } tower = unpack tower |> Array.get row |> Maybe.withDefault Array.empty
    |> Array.get col |> Maybe.withDefault Nothing


{-| Lege den aktiven Tetromino und seine Position im Spielturm fest.
-}
set : { row : Int , col : Int } -> Tetromino -> Tower -> Tower
set anchor tmino tower = tmino.blocks |> List.foldr
    ( \ block -> setBlock { row = anchor.row + block.row , col = anchor.col + block.col } tmino.type_ ) tower


{-| Prüfe, ob ein Tetromino an einer bestimmten Position in den Spielturm passt.
-}
fits : { row : Int, col : Int } -> Tower -> Tetromino -> Bool
fits anchor tower tmino = tmino.blocks |> List.all
    ( \ block -> anchor.row + block.row >= 0
        && anchor.row + block.row < height
        && anchor.col + block.col >= 0
        && anchor.col + block.col < width
        && get { row = anchor.row + block.row , col = anchor.col + block.col } tower == Nothing
    )


{-| Entferne volle Zeilen aus dem Spielturm und rücke darüberliegende Zeilen nach unten nach.
-}
shrink : Tower -> ( Tower , Int )
shrink tower =
    let
        remaining = unpack tower |> Array.filter ( any ( (==) Nothing ) )
        eliminated = height - Array.length remaining
        newRows = Array.repeat eliminated ( Array.repeat width Nothing )
    in
        ( Tower ( Array.append newRows remaining ) , eliminated )



-- Helpers


{-| Lege die Belegung einer Position im Spielturm fest.
-}
setBlock : { row : Int , col : Int } -> Tmino.Type -> Tower -> Tower
setBlock { row , col } tmino tower = unpack tower |> Array.get row |> Maybe.withDefault Array.empty
    |> Array.set col ( Just tmino ) |> ( \ r -> Array.set row r ( unpack tower ) ) |> Tower


{-| Verwirf den `Tower` Datenkonstruktor.
-}
unpack : Tower -> Array ( Array ( Maybe Tmino.Type ) )
unpack ( Tower t ) = t


{-| Prüfe, ob alle Elemente in einem Array eine bestimmte Bedingung erfüllen.
-}
all : ( a -> Bool ) -> Array a -> Bool
all pred elems = Array.filter ( pred >> not ) elems == Array.empty


{-| Prüfe, ob mindestens ein Element in einem Array eine bestimmte Bedingung erfüllt.
-}
any : ( a -> Bool ) -> Array a -> Bool
any pred elems = Array.filter pred elems /= Array.empty
