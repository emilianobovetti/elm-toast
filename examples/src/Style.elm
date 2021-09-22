module Style exposing
    ( background
    , button
    , conditionals
    , contentEditor
    , global
    , toast
    , toastFrame
    , tray
    , triggers
    )

import Html exposing (Attribute, Html)
import Html.Attributes exposing (class)


conditionals : List ( a, Bool ) -> List a
conditionals list =
    list
        |> List.filter Tuple.second
        |> List.map Tuple.first


style : String -> Html msg
style css =
    Html.node "style" [] [ Html.text css ]


type alias Toast msg =
    { base : Attribute msg
    , fadeOut : Attribute msg
    , spaced : Attribute msg
    , active : Attribute msg
    , closeButton : Attribute msg
    }


toast : Toast msg
toast =
    { base = class "toast"
    , fadeOut = class "toast--fade-out"
    , spaced = class "toast--spaced"
    , active = class "toast--active"
    , closeButton = class "toast__close"
    }


tray : Attribute msg
tray =
    class "toast-tray"


type alias ToastFrame msg =
    { base : Attribute msg
    , fadeOut : Attribute msg
    }


toastFrame : ToastFrame msg
toastFrame =
    { base = class "toast-frame"
    , fadeOut = class "toast-frame--fade-out"
    }


type alias ContentEditor msg =
    { base : Attribute msg
    , button : Attribute msg
    }


contentEditor : ContentEditor msg
contentEditor =
    { base = class "content-editor"
    , button = class "content-editor__btn"
    }


type alias Background msg =
    { green : Attribute msg
    , blue : Attribute msg
    , yellow : Attribute msg
    , red : Attribute msg
    }


background : Background msg
background =
    { green = class "bg-green"
    , blue = class "bg-blue"
    , yellow = class "bg-yellow"
    , red = class "bg-red"
    }


triggers : Attribute msg
triggers =
    class "trigger-buttons"


button : Attribute msg
button =
    class "button"


global : Html msg
global =
    style """
.toast-tray {
  position: fixed;
  top: 1em;
  right: 1em;
}

.toast {
  font-family: sans-serif;
  box-sizing: content-box;
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: relative;
  width: 15em;
  padding: 0.8em 1em;
  background: #4a90e2;
  color: white;
  opacity: 1;
  transition:
    opacity 0.6s ease,
    transform 0.6s ease;
}

.toast::after {
  content: '';
  position: absolute;
  z-index: -1;
  left: 0;
  width: 100%;
  height: 100%;
  box-shadow: 2px 2px 5px 1px #999;
  opacity: 0.5;
  transition: opacity 0.3s ease;
}

.toast--active {
  transform: translateX(-0.3em);
}

.toast--active::after {
  box-shadow: 2px 2px 7px 1px #888;
  opacity: 1;
}

.toast--fade-out {
  opacity: 0;
  transform: translateX(20em);
}

.toast--spaced {
  margin-bottom: 1em;
}

.toast-frame {
  min-height: 4em;
  max-height: 4em;
  transition:
    min-height 0.6s linear,
    min-height 0.6s linear;
}

.toast-frame--fade-out {
  min-height: 0;
  max-height: 0;
}

.toast__close {
  cursor: pointer;
  font-family: monospace;
  color: #f8f8f8;
}

.trigger-buttons {
  display: flex;
  flex-flow: column wrap;
}

.button {
  cursor: pointer;
  margin: 0.5em 1em;
  color: white;
  height: 2em;
  width: 8em;
  border: 0.1em solid #ddd;
  font-size: 1.2em;
}

.content-editor {
    margin: 1em;
}

.content-editor__btn {
  margin: 0 1em;
}

.bg-green {
  background: #82dd55;
}

.bg-blue {
  background: #4a90e2;
}

.bg-yellow {
  background: #f8df67;
}

.bg-red {
  background: #e23636;
}
"""
