module BeerList exposing (BeerList)


type alias Beer =
    { name : String
    , tagline : String
    , description : String
    , image_url : String
    , abv : Float
    , ibu : Float
    }


type alias BeerList =
    { name : String
    , bio : String
    }


type alias Model =
    Int


initialModel : Model
initialModel =
    0
