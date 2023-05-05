module Dedris.View exposing ( app )

import Ari.Css as Css exposing ( css )
import Ari.Events exposing ( onClick , onTouchStart , onTouchEnd )
import Ari.Html as Html
import Browser
import Dedris.Model as Model exposing ( Model )
import Dedris.Motion as Motion exposing ( Motion )
import Dedris.Msg as Msg exposing ( Msg )
import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower exposing ( Tower )
import Html as ElmHtml exposing ( Html )


{-| View für die gesamte Anwendung.
-}
app : Model -> Browser.Document Msg
app mdl =
    { title = "Dedris"
    , body =
        [ Html.div
            { css | height = Css.Px mdl.viewport.height , bgColor = "#212121" , justifyContent = Css.JcCenter
            , alignItems = Css.AiCenter , fontFamily = "monospace" , userSelect = Css.UsNone } []
            [ tower mdl
            , touchOverlay mdl
            ]
        ]
    }


{-| View für den Spielstand.
-}
msgScore : Int -> Html Msg
msgScore score = Html.div { css | marginRight = Css.Px 10 , marginTop = Css.Px 5 } []
    [ Html.text ( "Score " ++ String.fromInt score ) ]


{-| View für Pausenmeldung.
-}
msgPause : Bool -> Html Msg
msgPause pause = Html.div { css | marginLeft = Css.Px 10 , marginTop = Css.Px 5 } []
    [ Html.text ( if pause then "Pause" else "" ) ]


{-| View für die "Game over"-Meldung
-}
msgGameOver : Html Msg
msgGameOver = Html.div
    { css
        | color = "#f50057" , fontSize = Css.FsXXXLarge , marginBottom = Css.Px 60 , bgColor = "rgb(0,0,0,0.6)"
        , paddingBottom = Css.Px 20 , paddingLeft = Css.Px 40 , paddingRight = Css.Px 40 , paddingTop = Css.Px 20
    } [] [ Html.text "Game over!" ]


{-| View für den Tetromino, der als nächstes ins Spiel geholt wird.
Wird gerade nicht verwendet, weil dafür in der mobilen Ansicht kein Platz ist.
TODO: Zeige das an, wenn dafür Platz ist.
-}
next : Tetromino -> Html Msg
next tmino =
    let
        t = Tower.set { row = 0 , col = 0 } tmino Tower.new
    in
        List.range 0 3
            |> List.map
                ( \ row -> List.range 0 3
                    |> List.map ( \ col -> t |> Tower.get { row = row , col = col } |> blockPreview )
                    |> Html.div css []
                )
            |> Html.div { css | flexDirection = Css.FdColumn , marginTop = Css.Px 30 } []


{-| View für den Spielturm.
-}
tower : Model -> Html Msg
tower mdl = List.range 0 19 |> List.map
    ( \ row -> List.range 0 9 |> List.map
        ( \ col -> mdl.tower |> Tower.set mdl.anchor mdl.tmino |> Tower.get { row = row , col = col }
            |> block ( blockSize mdl )
        ) |> Html.div css []
    )
    |> ( \ blocks -> Html.div { css | bgColor = "#424242" } []
        [ Html.div css [] [ Html.div { css | flexDirection = Css.FdColumn } [] blocks ]
        , Html.div
            { css
                | position = Css.PAbsolute , width = Css.Px ( Tower.width * blockSize mdl )
                , bgColor = "transparent" , color = "white" , justifyContent = Css.JcSpaceBetween
                , fontSize = fontSize mdl
            } []
            [ msgPause mdl.pause
            , msgScore mdl.score
            ]
        ]
       )


{-| View für eine Position im Spielturm.
-}
block : Int -> Maybe Tmino.Type -> Html Msg
block size tmino = Html.div
    { css
        | width = Css.Px size
        , height = Css.Px size
        , bgColor = case tmino of
            Nothing -> "inherit"
            Just Tmino.I -> "#00b8d4"
            Just Tmino.J -> "#2962ff"
            Just Tmino.L -> "#ff6d00"
            Just Tmino.O -> "#ffd600"
            Just Tmino.S -> "#00c853"
            Just Tmino.T -> "#aa00ff"
            Just Tmino.Z -> "#d50000"
        }
        []
        []


{-| View für einen Block in der Vorschau für den nächsten Tetromino.
-}
blockPreview : Maybe Tmino.Type -> Html Msg
blockPreview tmino = Html.div
    { css
        | width = Css.Px 35
        , height = Css.Px 35
        , bgColor = case tmino of
            Nothing -> "inherit"
            Just Tmino.I -> "#00b8d4"
            Just Tmino.J -> "#2962ff"
            Just Tmino.L -> "#ff6d00"
            Just Tmino.O -> "#ffd600"
            Just Tmino.S -> "#00c853"
            Just Tmino.T -> "#aa00ff"
            Just Tmino.Z -> "#d50000"
        }
        []
        []


{-| Größe eines Bausteins.
-}
blockSize : Model -> Int
blockSize mdl =  min ( mdl.viewport.width // Tower.width ) ( mdl.viewport.height // Tower.height )


{-| Schriftgröße in Abhängigkeit von der Größe eines Bausteins.
-}
fontSize : Model -> Css.FontSize
fontSize mdl =
    if blockSize mdl < 15
    then Css.FsXXSmall
    else if blockSize mdl < 20 then Css.FsXSmall
    else if blockSize mdl < 25 then Css.FsSmall
    else if blockSize mdl < 30 then Css.FsMedium
    else if blockSize mdl < 35 then Css.FsLarge
    else if blockSize mdl < 40 then Css.FsXLarge
    else if blockSize mdl < 45 then Css.FsXXLarge
    else Css.FsXXXLarge


{-| Transparente Oberfläche für Touch-Bedienung auf mobilen Endgeräten.
-}
touchOverlay : Model -> Html Msg
touchOverlay mdl = Html.div
    { css | position = Css.PAbsolute , flexDirection = Css.FdColumn , width = Css.Px mdl.viewport.width
    , height = Css.Px mdl.viewport.height , justifyContent = Css.JcCenter , alignItems = Css.AiCenter
    , bgColor = if mdl.gameOver then "rgb(0,0,0,0.7)" else "transparent"
    } []
    ( if mdl.gameOver
      then [ msgGameOver , btnRestart ]
      else
        [ Html.div css []
            [ Html.div
                { css | width = Css.Px ( mdl.viewport.width // 2 ) , height = Css.Px ( mdl.viewport.height // 2 ) }
                [ onTouchStart ( Msg.ActiveMotion Motion.RotateLeft ) , onTouchEnd ( Msg.ActiveMotion Motion.None ) ]
                []
            , Html.div
                { css | width = Css.Px ( mdl.viewport.width // 2 ) , height = Css.Px ( mdl.viewport.height // 2 ) }
                [ onTouchStart ( Msg.ActiveMotion Motion.RotateRight ) , onTouchEnd ( Msg.ActiveMotion Motion.None ) ]
                []
            ]
        , Html.div css []
            [ Html.div
                { css | width = Css.Px ( mdl.viewport.width // 2 ) , height = Css.Px ( mdl.viewport.height // 3 ) }
                [ onTouchStart ( Msg.ActiveMotion Motion.MoveLeft ) , onTouchEnd ( Msg.ActiveMotion Motion.None ) ]
                []
            , Html.div
                { css | width = Css.Px ( mdl.viewport.width // 2 ) , height = Css.Px ( mdl.viewport.height // 3 ) }
                [ onTouchStart ( Msg.ActiveMotion Motion.MoveRight ) , onTouchEnd ( Msg.ActiveMotion Motion.None ) ]
                []
            ]
        , Html.div { css | width = Css.Px mdl.viewport.width , height = Css.Px ( mdl.viewport.height // 6 ) }
            [ onTouchStart ( Msg.ActiveMotion Motion.MoveDown ) , onTouchEnd ( Msg.ActiveMotion Motion.None ) ]
            []
        ]
    )


{-| Button für den Neustart des Spiels.
-}
btnRestart : Html Msg
btnRestart = Html.div
    { css
        | paddingBottom = Css.Px 30 , paddingLeft = Css.Px 60 , paddingRight = Css.Px 60 , paddingTop = Css.Px 30
        , bgColor = "#388e3c" , color = "white" , cursor = "pointer" , fontSize = Css.FsXXXLarge
    }
    [ onClick Msg.Reload ] [ Html.text "Restart" ]
