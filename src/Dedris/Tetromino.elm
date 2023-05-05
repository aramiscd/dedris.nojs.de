module Dedris.Tetromino exposing
    ( Tetromino
    , Type (..)
    , i
    , j
    , l
    , o
    , s
    , t
    , z
    , new
    , rotate
    , random
    )

import Random


{-| Tetromino mit Formbezeichnung und Blockmatrix.
 -}
type alias Tetromino = { type_ : Type , blocks : List { row : Int , col : Int } }


{-| Formbezeichnungen für Tetrominos.
-}
type Type = I | J | L | O | S | T | Z


{-| Tetromino in I-Form.
-}
i : Tetromino
i = { type_ = I , blocks = fromTuples [ (2,0) , (2,1) , (2,2) , (2,3) ] }


{-| Tetromino in J-Form.
-}
j : Tetromino
j = { type_ = J , blocks = fromTuples [ (1,0) , (1,1) , (1,2) , (2,2) ] }


{-| Tetromino in L-Form.
-}
l : Tetromino
l = { type_ = L , blocks = fromTuples [ (1,0) , (1,1) , (1,2) , (2,0) ] }


{-| Tetromino in O-Form.
-}
o : Tetromino
o = { type_ = O , blocks = fromTuples [ (0,0) , (0,1) , (1,0) , (1,1) ] }


{-| Tetromino in S-Form.
-}
s : Tetromino
s = { type_ = S , blocks = fromTuples [ (0,1) , (0,2) , (1,0) , (1,1) ] }


{-| Tetromino in T-Form.
-}
t : Tetromino
t = { type_ = T , blocks = fromTuples [ (1,0) , (1,1) , (1,2) , (2,1) ] }


{-| Tetromino in Z-Form.
-}
z : Tetromino
z = { type_ = Z , blocks = fromTuples [ (1,0) , (1,1) , (2,1) , (2,2) ] }


{-| Erzeuge einen Tetromino.
-}
new : Type -> Tetromino
new type_ = case type_ of
    I -> i
    J -> j
    L -> l
    O -> o
    S -> s
    T -> t
    Z -> z


{-| Rotiere einen Tetromino im Uhrzeigersinn.
-}
rotate : Tetromino -> Tetromino
rotate tmino = case tmino.type_ of
    I ->
        if List.member { row = 0 , col = 1 } tmino.blocks
        then { tmino | blocks = fromTuples [ (2,0) , (2,1) , (2,2) , (2,3) ] }
        else if List.member { row = 2 , col = 0 } tmino.blocks
        then { tmino | blocks = fromTuples [ (0,1) , (1,1) , (2,1) , (3,1) ] }
        else tmino
    J ->
        if List.member { row = 0 , col = 0 } tmino.blocks
        then { tmino | blocks = fromTuples [ (0,1) , (0,2) , (1,1) , (2,1) ] }
        else if List.member { row = 0 , col = 2 } tmino.blocks
        then { tmino | blocks = fromTuples [ (1,0) , (1,1) , (1,2) , (2,2) ] }
        else if List.member { row = 2 , col = 2 } tmino.blocks
        then { tmino | blocks = fromTuples [ (0,1) , (1,1) , (2,0) , (2,1) ] }
        else { tmino | blocks = fromTuples [ (0,0) , (1,0) , (1,1) , (1,2) ] }
    L ->
        if List.member { row = 0 , col = 2 } tmino.blocks
        then { tmino | blocks = fromTuples [ (0,1) , (1,1) , (2,1) , (2,2) ] }
        else if List.member { row = 2 , col = 2 } tmino.blocks
        then { tmino | blocks = fromTuples [ (1,0) , (1,1) , (1,2) , (2,0) ] }
        else if List.member { row = 2 , col = 0 } tmino.blocks
        then { tmino | blocks = fromTuples [ (0,0) , (0,1) , (1,1) , (2,1) ] }
        else { tmino | blocks = fromTuples [ (0,2) , (1,0) , (1,1) , (1,2) ] }
    O ->
        tmino
    S ->
        if List.member { row = 0 , col = 2 } tmino.blocks
        then { tmino | blocks = fromTuples [ (0,0) , (1,0) , (1,1) , (2,1) ] }
        else { tmino | blocks = fromTuples [ (0,1) , (0,2) , (1,0) , (1,1) ] }
    T ->
        if not ( List.member { row = 0 , col = 1 } tmino.blocks )
        then { tmino | blocks = fromTuples [ (0,1) , (1,0) , (1,1) , (2,1) ] }
        else if not ( List.member { row = 1 , col = 2 } tmino.blocks )
        then { tmino | blocks = fromTuples [ (0,1) , (1,0) , (1,1) , (1,2) ] }
        else if not ( List.member { row = 2 , col = 1 } tmino.blocks )
        then { tmino | blocks = fromTuples [ (0,1) , (1,1) , (1,2) , (2,1) ] }
        else { tmino | blocks = fromTuples [ (1,0) , (1,1) , (1,2) , (2,1) ] }
    Z ->
        if List.member { row = 2 , col = 2 } tmino.blocks
        then { tmino | blocks = fromTuples [ (0,1) , (1,0) , (1,1) , (2,0) ] }
        else { tmino | blocks = fromTuples [ (1,0) , (1,1) , (2,1) , (2,2) ] }


{-| Erzeuge einen (pseudo)zufällig gewählten Tetromino.
-}
random : Random.Generator Type
random = Random.int 0 6 |> Random.map
    ( \ n -> case n of
        0 -> I
        1 -> J
        2 -> L
        3 -> O
        4 -> S
        5 -> T
        _ -> Z
    )



-- Helpers


{-| Übersetze eine List von Koordinatenpaaren in eine Liste von Koordinaten-Records.
-}
fromTuples : List ( Int , Int ) -> List { row : Int , col : Int }
fromTuples pairs = List.map ( \ ( row , col ) -> { row = row , col = col } ) pairs
