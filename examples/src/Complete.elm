module Complete exposing (main)

import Browser
import Html exposing (Html)
import Html.Events exposing (onClick)
import Style
import Toast


type Role
    = Success
    | Info
    | Warning
    | Error


type alias Toast =
    { message : String
    , role : Role
    }


type alias Model =
    { title : String
    , tray : Toast.Tray Toast
    }


type Msg
    = ToastMsg Toast.Msg
    | AddToast String Role


main : Program () Model Msg
main =
    Browser.document
        { init = always ( initialModel, Cmd.none )
        , view = \model -> { title = model.title, body = view model }
        , update = update
        , subscriptions = \_ -> Sub.none
        }


initialModel : Model
initialModel =
    { title = "Full Toast Playground"
    , tray = Toast.tray
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddToast message role ->
            Toast.expireOnBlur 5000 { message = message, role = role }
                |> Toast.withExitTransition 900
                |> Toast.add model.tray
                |> Toast.tuple ToastMsg model

        ToastMsg tmsg ->
            Toast.tuple ToastMsg model (Toast.update tmsg model.tray)


roleClass : Role -> Html.Attribute msg
roleClass role =
    case role of
        Success ->
            Style.background.green

        Info ->
            Style.background.blue

        Warning ->
            Style.background.yellow

        Error ->
            Style.background.red


button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button attrs =
    Html.button (Style.button :: attrs)


greenButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
greenButton attrs =
    button (Style.background.green :: attrs)


blueButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
blueButton attrs =
    button (Style.background.blue :: attrs)


yellowButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
yellowButton attrs =
    button (Style.background.yellow :: attrs)


redButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
redButton attrs =
    button (Style.background.red :: attrs)


triggerButtons : Html Msg
triggerButtons =
    Html.div [ Style.triggers ]
        [ greenButton [ onClick (AddToast "Yay!" Success) ] [ Html.text "Success ✓" ]
        , blueButton [ onClick (AddToast "Some info" Info) ] [ Html.text "Info 🔍" ]
        , yellowButton [ onClick (AddToast "Warning :s" Warning) ] [ Html.text "Warn ⚠️" ]
        , redButton [ onClick (AddToast "Oh no!" Error) ] [ Html.text "Error ☠️" ]
        ]


viewToast : List (Html.Attribute Msg) -> Toast.Info Toast -> Html Msg
viewToast attrs toast =
    Html.div
        (roleClass toast.content.role :: attrs)
        [ Html.text toast.content.message
        , Html.div [ Style.toast.closeButton, onClick <| ToastMsg <| Toast.exit toast.id ] [ Html.text "✘" ]
        ]


framePhaseAttr : Toast.Phase -> List (Html.Attribute msg)
framePhaseAttr phase =
    if phase == Toast.In then
        []

    else
        [ Style.toastFrame.fadeOut ]


viewToastFrame : List (Html.Attribute Msg) -> Toast.Info Toast -> Html Msg
viewToastFrame toastAttrs toast =
    Html.div
        (Style.toastFrame.base :: framePhaseAttr toast.phase)
        [ viewToast toastAttrs toast ]


toastConfig : Toast.Config Msg
toastConfig =
    Toast.config ToastMsg
        |> Toast.withTrayAttributes [ Style.tray ]
        |> Toast.withAttributes [ Style.toast.base ]
        |> Toast.withTransitionAttributes [ Style.toast.fadeOut ]
        |> Toast.withFocusAttributes [ Style.toast.active ]


view : Model -> List (Html Msg)
view model =
    [ Style.global
    , triggerButtons
    , Toast.render viewToastFrame model.tray toastConfig
    ]
