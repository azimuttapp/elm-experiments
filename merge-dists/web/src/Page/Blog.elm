module Page.Blog exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (a, h1, li, text, ul)
import Html.Attributes exposing (href)
import Models.Article as Article exposing (Article)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Router
import Shared
import View exposing (View)


type alias Data =
    List (Article Msg)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    Article.all


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , locale = Nothing
        , title = "Azimutt's blog"
        , description = "TODO"
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Azimutt's blog"
    , body =
        [ a [ href Router.home ] [ text "Home" ]
        , h1 [] [ text "Blog" ]
        , ul [] (static.data |> List.map (\article -> li [] [ a [ href (Router.blog_slug article.slug) ] [ text article.title ] ]))
        ]
    }
