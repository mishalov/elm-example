module HomePage exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)


view model =
    div [ class "jumbotron" ]
        [ h1 [] [ text "Welcome to Elm street bar!" ]
        , p []
            [ text "We offer you to checkout our top-quality beers" ]
        ]


main =
    view "dummy model"
