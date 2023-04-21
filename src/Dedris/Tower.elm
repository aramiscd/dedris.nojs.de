module Dedris.Tower exposing
    ( Tower
    , new
    , get
    , set
    , fits
    , shrink
    )

import Array exposing ( Array )
import Dedris.Tetromino as Tmino exposing ( Tetromino )


type Tower = Tower ( Array ( Array ( Maybe Tmino.Type ) ) )


height = 20
width = 10


new : Tower
new = Tower ( Array.initialize height ( \ _ -> Array.initialize width ( \ _ -> Nothing ) ) )


get : { row : Int , col : Int } -> Tower -> Maybe Tmino.Type
get { row , col } tower = unpack tower |> Array.get row |> Maybe.withDefault Array.empty
    |> Array.get col |> Maybe.withDefault Nothing


set : { row : Int , col : Int } -> Tetromino -> Tower -> Tower
set anchor tmino tower = tmino.blocks |> List.foldr
    ( \ block -> setBlock { row = anchor.row + block.row , col = anchor.col + block.col } tmino.type_ ) tower


fits : { row : Int, col : Int } -> Tower -> Tetromino -> Bool
fits anchor tower tmino = tmino.blocks |> List.all
    ( \ block -> anchor.row + block.row >= 0
        && anchor.row + block.row < height
        && anchor.col + block.col >= 0
        && anchor.col + block.col < width
        && get { row = anchor.row + block.row , col = anchor.col + block.col } tower == Nothing
    )


shrink : Tower -> ( Tower , Int )
shrink tower =
    let
        remaining = unpack tower |> Array.filter ( any ( (==) Nothing ) )
        eliminated = height - Array.length remaining
        newRows = Array.repeat eliminated ( Array.repeat width Nothing )
    in
        ( Tower ( Array.append newRows remaining ) , eliminated )



-- Helpers


setBlock : { row : Int , col : Int } -> Tmino.Type -> Tower -> Tower
setBlock { row , col } tmino tower = unpack tower |> Array.get row |> Maybe.withDefault Array.empty
    |> Array.set col ( Just tmino ) |> ( \ r -> Array.set row r ( unpack tower ) ) |> Tower


unpack : Tower -> Array ( Array ( Maybe Tmino.Type ) )
unpack ( Tower t ) = t


all : ( a -> Bool ) -> Array a -> Bool
all pred elems = Array.filter ( pred >> not ) elems == Array.empty


any : ( a -> Bool ) -> Array a -> Bool
any pred elems = Array.filter pred elems /= Array.empty
