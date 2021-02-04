module Basic exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (name, type_, value)
import Html.Events
import Json.Decode exposing (Decoder)
import Style
import Toast


type alias Model =
    Toast.Tray String


type Msg
    = ToastMsg Toast.Msg
    | AddToast String


main : Program () Model Msg
main =
    Browser.document
        { init = always ( Toast.tray, Cmd.none )
        , view = \model -> { title = "Simple Toasts", body = view model }
        , update = \msg model -> Tuple.mapSecond (Cmd.map ToastMsg) (update msg model)
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Toast.Msg )
update msg model =
    case msg of
        AddToast "" ->
            ( model, Cmd.none )

        AddToast message ->
            Toast.add model (Toast.expireIn 5000 message)

        ToastMsg tmsg ->
            Toast.update tmsg model


elementValueDecoder : String -> Decoder String
elementValueDecoder fieldName =
    Json.Decode.at [ "target", "elements", fieldName, "value" ] Json.Decode.string


decodeOnSubmit : String -> (String -> msg) -> Html.Attribute msg
decodeOnSubmit fieldName toMsg =
    elementValueDecoder fieldName
        |> Json.Decode.map (\val -> { message = toMsg val, stopPropagation = False, preventDefault = True })
        |> Html.Events.custom "submit"


viewToast : List (Html.Attribute Msg) -> Toast.Info String -> Html Msg
viewToast attributes toast =
    Html.div (Style.toast.base :: Style.toast.spaced :: attributes) [ Html.text toast.content ]


view : Model -> List (Html Msg)
view model =
    [ Style.global
    , Html.div [ Style.tray ] [ Toast.render viewToast model (Toast.config ToastMsg) ]
    , Html.form [ decodeOnSubmit "toast-message" (String.trim >> AddToast), Style.contentEditor.base ]
        [ Html.input [ type_ "text", name "toast-message" ] []
        , Html.input [ type_ "submit", value "Make Toast", Style.contentEditor.button ] []
        ]
    ]
