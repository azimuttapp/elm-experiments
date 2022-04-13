module Router exposing (blog, blog_slug, home)


home : String
home =
    "/"


blog : String
blog =
    "/blog"


blog_slug : String -> String
blog_slug slug =
    "/blog/" ++ slug
