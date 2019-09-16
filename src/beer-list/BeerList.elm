module BeerList exposing (main)

import Browser exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as Decode
    exposing
        ( Decoder
        , at
        , decodeString
        , field
        , float
        , int
        , list
        , map3
        , string
        )


type alias Beer =
    { id : Int
    , name : String
    , tagline : String
    , description : String
    , image_url : String
    , abv : Float
    , ibu : Float
    }


type alias Model =
    { beers : List Beer
    , errorMessage : Maybe String
    }



-- HTTP


type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error (List Beer))


url : String
url =
    "https://api.punkapi.com/v2/beers?page=1&per_page=80"


beerDecoder : Decoder Beer
beerDecoder =
    Decode.map7 Beer
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "tagline" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "image_url" Decode.string)
        (Decode.field "abv" Decode.float)
        (Decode.field "ibu" Decode.float)


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message


beerListDecoder : Decoder (List Beer)
beerListDecoder =
    Decode.list beerDecoder


getBeers : Cmd Msg
getBeers =
    Http.get
        { url = url
        , expect = Http.expectJson DataReceived beerListDecoder
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( model, getBeers )

        DataReceived (Ok beers) ->
            ( { model
                | beers = beers
                , errorMessage = Nothing
              }
            , Cmd.none
            )

        DataReceived (Err httpError) ->
            ( { model
                | errorMessage = Just (buildErrorMessage httpError)
              }
            , Cmd.none
            )


viewBeersOrError : Model -> Html Msg
viewBeersOrError model =
    case model.errorMessage of
        Just message ->
            viewError message

        Nothing ->
            viewBeers model.beers


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick SendHttpRequest ]
            [ text "Get data from server" ]
        , viewBeersOrError model
        ]


viewTableHeader =
    tr []
        [ th []
            [ text "ID" ]
        , th []
            [ text "Title" ]
        , th []
            [ text "Author" ]
        ]


viewPost : Beer -> Html Msg
viewPost beer =
    tr []
        [ td []
            [ text (String.fromInt beer.id) ]
        , td []
            [ text beer.name ]
        , td []
            [ text beer.description ]
        ]


viewBeers : List Beer -> Html Msg
viewBeers beers =
    div []
        [ h3 [] [ text "Beers" ]
        , table []
            ([ viewTableHeader ] ++ List.map viewPost beers)
        ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( { beers = []
      , errorMessage = Nothing
      }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
