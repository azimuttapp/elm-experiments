module Libs.Markdown exposing (Markdown, render)

import Html exposing (Html)
import Html.Attributes as Attr
import Markdown.Block as Block
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
import Path


type alias Markdown =
    String


render : String -> Renderer (Html msg)
render imgBase =
    { defaultHtmlRenderer
        | heading =
            \{ level, children } ->
                case level of
                    Block.H1 ->
                        Html.h2 [] children

                    Block.H2 ->
                        Html.h3 [] children

                    Block.H3 ->
                        Html.h4 [] children

                    Block.H4 ->
                        Html.h5 [] children

                    Block.H5 ->
                        Html.h6 [] children

                    Block.H6 ->
                        Html.h6 [] children
        , image =
            \imageInfo ->
                case imageInfo.title of
                    Just title ->
                        Html.img
                            [ Attr.src ([ imgBase, imageInfo.src ] |> Path.join |> Path.toAbsolute)
                            , Attr.alt imageInfo.alt
                            , Attr.title title
                            ]
                            []

                    Nothing ->
                        Html.img
                            [ Attr.src ([ imgBase, imageInfo.src ] |> Path.join |> Path.toAbsolute)
                            , Attr.alt imageInfo.alt
                            ]
                            []
    }
