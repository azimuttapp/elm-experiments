module Models.Article exposing (Article, all, get)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import Html exposing (Html)
import Libs.Markdown as Markdown exposing (Markdown)
import Markdown.Parser
import Markdown.Renderer
import OptimizedDecoder as Decode exposing (Decoder)
import Regex exposing (Regex)
import Router


type alias Folder =
    String


type alias FilePath =
    String


type alias Slug =
    String


type alias Article msg =
    { slug : Slug
    , title : String
    , excerpt : String
    , category : String
    , tags : List String
    , author : String
    , body : List (Html msg)
    , published : String
    }


folders : DataSource (List Folder)
folders =
    Glob.succeed (\slug -> slug)
        |> Glob.match (Glob.literal "content/blog/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal "/article.md")
        |> Glob.toDataSource


folderToFile : Folder -> FilePath
folderToFile folder =
    "content/blog/" ++ folder ++ "/article.md"


folderToSlug : FilePath -> Slug
folderToSlug path =
    "\\d+-\\d+-\\d+-(.+)"
        |> Regex.fromString
        |> Maybe.map (\r -> path |> Regex.find r |> List.concatMap .submatches |> List.filterMap identity |> List.head |> Maybe.withDefault "invalid-file-path")
        |> Maybe.withDefault "bad-file-path-regex"


all : DataSource (List (Article msg))
all =
    folders |> DataSource.andThen (List.map datasource >> DataSource.combine)


get : Slug -> DataSource (Article msg)
get slug =
    folders
        |> DataSource.andThen
            (List.filter (\f -> f |> String.endsWith slug)
                >> List.head
                >> Maybe.map datasource
                >> Maybe.withDefault (DataSource.fail ("No article for slug '" ++ slug ++ "'"))
            )


datasource : Folder -> DataSource (Article msg)
datasource folder =
    folder |> folderToFile |> File.bodyWithFrontmatter (articleDecoder (folder |> folderToSlug))


articleDecoder : Slug -> String -> Decoder (Article msg)
articleDecoder slug body =
    Decode.map7 (Article slug)
        (Decode.field "title" Decode.string)
        (Decode.field "excerpt" Decode.string)
        (Decode.field "category" Decode.string)
        (Decode.field "tags" tagsDecoder)
        (Decode.field "author" Decode.string)
        (body |> parseMarkdown ("/" ++ Router.blog_slug slug) |> Decode.fromResult)
        (Decode.field "published" Decode.string)


tagsDecoder : Decoder (List String)
tagsDecoder =
    Decode.string |> Decode.map (String.split "," >> List.map String.trim >> List.filter (String.isEmpty >> not))


parseMarkdown : String -> Markdown -> Result String (List (Html msg))
parseMarkdown imgBase markdownString =
    markdownString
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "Markdown error.")
        |> Result.andThen (\blocks -> Markdown.Renderer.render (Markdown.render imgBase) blocks)
