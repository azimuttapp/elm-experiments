module Page.Blog.Slug_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (a, div, h1, text)
import Html.Attributes exposing (href)
import Models.Article as Article exposing (Article)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Router
import Shared
import View exposing (View)


type alias Data =
    Article Msg


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { slug : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    Article.all |> DataSource.map (List.map (\article -> RouteParams article.slug))


data : RouteParams -> DataSource Data
data routeParams =
    Article.get routeParams.slug


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
        , title = static.data.title ++ " - Azimutt blog"
        , description = static.data.excerpt
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.data.title ++ " - Azimutt blog"
    , body =
        [ a [ href Router.home ] [ text "Home" ]
        , text " "
        , a [ href Router.blog ] [ text "Blog" ]
        , h1 [] [ text static.data.title ]
        , div [] static.data.body
        ]
    }
