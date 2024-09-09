# elm-toast

A simple way to implement toast messages, [pop-up notifications](https://en.wikipedia.org/wiki/Pop-up_notification) or snackbars in the Elm architecture.

`elm-toast` is a highly customizable library that handles a toast stack for you.

See online examples of a [trivial app](https://ellie-app.com/fz2FLpBJX4Sa1) and a [full-fledged thing](https://ellie-app.com/fz2DPCTmyvXa1) or run [example apps](https://github.com/emilianobovetti/elm-toast/tree/master/examples) on your machine.

## Toast

We serve three kinds of toasts:

```elm
import Toast

first = Toast.persistent "Hello, I'm a persistent toast"

second = Toast.expireIn 5000 "I'm going to expire in five seconds"

third = Toast.expireOnBlur 5000 "I'll expire only if not focused"
```

Persistent toasts will stay there until you take explicit action, they won't fade out automatically.

The second kind of toast, instead, will be removed after a fixed amount of time: in our example five seconds.

Lastly we have toasts that will only expire if the user is not interacting with them, if they receive focus or have mouse over, they have to wait the end of user's interaction and then five more seconds to fade out.

## Tray

Toasts have to be served on a tray, and get an empty tray is as simple as:

```elm
import Toast

emptyTray : Toast.Tray String
emptyTray =
  Toast.tray
```

You may have noticed that `Toast.Tray` is parametric and we are using the `String` type there. This is just the type of our own toast, it can be anything from a plain string, or a record to a whole new type.

```elm
type Color
    = Red
    | Blue
    | Green

type alias Toast =
    { message : String
    , color : Color
    }

emptyTray : Toast.Tray Toast
emptyTray =
  Toast.tray
```

## The Elm Architecture

Now that we have both toast and tray we are almost done, we just need to plug some wires:

### Setup types

We'll declare our `Toast` type, then application's `Model` and `Msg`.

```elm
import Toast

type Color
    = Red
    | Green
    | Blue

type alias Toast =
    { message : String
    , color : Color
    }

{- Let's store our tray here -}
type alias Model =
    { tray : Toast.Tray Toast }

{- We need a variant that contains Toast.Msg -}
type Msg
    = ToastMsg Toast.Msg
    | AddToast Toast
```

### Init function

We'll create a model with an empty tray and schedule toast insertion using `Task.perform` and `Process.sleep`.

```elm
import Process
import Task

delay : Int -> msg -> Cmd msg
delay ms msg =
    Task.perform (always msg) (Process.sleep <| toFloat ms)

{- Create a model with an empty tray and schedule toast insertions -}
init : () -> ( Model, Cmd Msg )
init () =
    ( { tray = Toast.tray }
    , Cmd.batch
        [ delay 0 (AddToast { message = "hello, world", color = Green })
        , delay 500 (AddToast { message = "I'm red", color = Red })
        , delay 1000 (AddToast { message = "...and I'm blue", color = Blue })
        ]
    )
```

### Update function

We have two messages right now: for `AddToast` we'll create a persistent toast and add it to app tray, for `ToastMsg` we have to forward its content to `Toast.update` and update our app accordingly.

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddToast content ->
            let
                ( tray, tmesg ) =
                    Toast.add model.tray (Toast.persistent content)
            in
            ( { model | tray = tray }, Cmd.map ToastMsg tmesg )

        ToastMsg tmsg ->
            let
                ( tray, newTmesg ) =
                    Toast.update tmsg model.tray
            in
            ( { model | tray = tray }, Cmd.map ToastMsg newTmesg )
```

### View function

The main actor here is call to `Toast.render`, it receives a `viewToast` function, our toast tray and a `Toast.Config Msg`.

First thing you'll notice in following snippet is that toast view is completely delegated to the user, `elm-toast` makes almost no assumption on how it should be done.

```elm
import Html exposing (Html)
import Html.Attributes exposing (style)

view : Model -> { title : String, body : List (Html Msg) }
view model =
    { title = "Yay! elm-toast"
    , body = [ Toast.render viewToast model.tray (Toast.config ToastMsg) ]
    }

viewToast : List (Html.Attribute Msg) -> Toast.Info Toast -> Html Msg
viewToast attributes toast =
    Html.div
      (toastStyles toast ++ attributes)
      [ Html.text toast.content.message ]

toastStyles : Toast.Info Toast -> List (Html.Attribute msg)
toastStyles toast =
    let
        background : Html.Attribute msg
        background =
            case toast.content.color of
                Red ->
                    style "background" "#f77"

                Green ->
                    style "background" "#7f7"

                Blue ->
                    style "background" "#77f"
    in
    [ background
    , style "width" "110px"
    , style "font-size" "18px"
    , style "padding" "10px"
    , style "margin" "10px"
    ]
```

### Putting it all together

Export a `Browser.document` at this point is trivial.

```elm
module MyApp exposing (main)

import Browser

main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
```

It's worth noting that we could use `Toast.tuple` to refactor our `update` function:

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddToast content ->
            Toast.persistent content
                |> Toast.add model.tray
                |> Toast.tuple ToastMsg model

        ToastMsg tmsg ->
            Toast.update tmsg model.tray
                |> Toast.tuple ToastMsg model
```

## You Might Ask
#### (aka FAQ not really asked)

### Can I add a delay to show an exit transition on toast fade out?

Of course, you can use `withExitTransition` passing the number of milliseconds between the moment the toast is exiting and the moment the toast is removed.

```elm
Toast.persistent content
    |> Toast.withExitTransition 1000
    |> Toast.add model.tray
    |> Toast.tuple ToastMsg model
```

### Can I have toasts with unique content?

There are three functions to achieve that: [addUnique](https://package.elm-lang.org/packages/emilianobovetti/elm-toast/latest/Toast#addUnique), [addUniqueBy](https://package.elm-lang.org/packages/emilianobovetti/elm-toast/latest/Toast#addUniqueBy) and [addUniqueWith](https://package.elm-lang.org/packages/emilianobovetti/elm-toast/latest/Toast#addUniqueWith).

### How can I programmatically remove a toast?

One of these two functions: [remove](https://package.elm-lang.org/packages/emilianobovetti/elm-toast/latest/Toast#remove) or [exit](https://package.elm-lang.org/packages/emilianobovetti/elm-toast/latest/Toast#exit).

E.g.:

```elm
type alias Toast = { message : String }

viewToast : List (Html.Attribute Msg) -> Toast.Info Toast -> Html Msg
viewToast attributes toast =
    Html.div
        attributes
        [ Html.text toast.content.message
        , Html.div
            [ onClick (ToastMsg <| Toast.exit toast.id) ]
            [ Html.text "close" ]
        ]
```

The difference between those two is pretty simple: if you `remove` a toast it'll be deleted right away, if `exit` is used the toast will go through its fade-out cycle, so [exitTransition](https://package.elm-lang.org/packages/emilianobovetti/elm-toast/latest/Toast#withExitTransition) milliseconds are waited before the toast is removed.
