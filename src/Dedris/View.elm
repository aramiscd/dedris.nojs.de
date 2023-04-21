module Dedris.View exposing ( app )

import Ari.Css as Css exposing ( css )
import Ari.Html as Html
import Ari.Events exposing ( onClick )
import Browser
import Dedris.Model as Model exposing ( Model )
import Dedris.Msg as Msg exposing ( Msg )
import Dedris.Tetromino as Tmino exposing ( Tetromino )
import Dedris.Tower as Tower exposing ( Tower )
import Html as ElmHtml exposing ( Html )


app : Model -> Browser.Document Msg
app mdl =
    { title = "Dedris"
    , body =
        [ Html.div { css | minHeight = Css.Vh 100 , bgColor = "#212121" , justifyContent = Css.JcCenter } []
            [ Html.div { css | marginTop = Css.Px 100 , fontFamily = "monospace" } []
                [ Html.div
                    { css
                        | marginRight = Css.Px 100 , width = Css.Px 300 , color = "#888" , fontSize = Css.FsXXLarge
                    }
                    [] [ Html.text "" ]
                , Html.div css [] [ tower mdl.tower mdl.anchor mdl.tmino ]
                , Html.div
                    { css
                        | marginLeft = Css.Px 100 , width = Css.Px 300 , color = "#888" , fontSize = Css.FsXXLarge
                        , flexDirection = Css.FdColumn
                    }
                    []
                    [ Html.div css [] [ Html.text ( "Score " ++ String.fromInt mdl.score ) ]
                    , if mdl.gameOver
                      then Html.div { css | flexDirection = Css.FdColumn } []
                        [ Html.div { css | color = "#f50057" , marginTop = Css.Px 30 } [] [ Html.text "Game Over!" ]
                        , Html.div
                            { css
                                | bgColor = "#388e3c"
                                , color = "white"
                                , marginTop = Css.Px 30
                                , paddingBottom = Css.Px 10
                                , paddingLeft = Css.Px 20
                                , paddingRight = Css.Px 20
                                , paddingTop = Css.Px 10
                                , cursor = "pointer"
                            }
                            [ onClick Msg.Reload ] [ Html.text "Restart" ]
                        ]


                      else next mdl.next
                    ]
                ]
            ]
        ]
    }


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


tower : Tower -> { row : Int , col : Int } -> Tetromino -> Html Msg
tower t anchor tmino = List.range 0 19
    |> List.map
        ( \ row -> List.range 0 9
            |> List.map ( \ col -> t |> Tower.set anchor tmino |> Tower.get { row = row , col = col } |> block )
            |> Html.div css []
        )
    |> Html.div { css | flexDirection = Css.FdColumn } []


block : Maybe Tmino.Type -> Html Msg
block tmino = Html.div
    { css
        | width = Css.Px 35
        , height = Css.Px 35
        , bgColor = case tmino of
            Nothing -> "#424242"
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
