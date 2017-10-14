module Components.Attributes exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (on, keyCode)
import Json.Decode

onFinish : msg -> msg -> Attribute msg
onFinish enterMessage escapeMessage =
    let
        select key =
            case key of
                13 ->
                    enterMessage

                _ ->
                    -- Not a 'finish' key, such as ENTER or ESCAPE
                    escapeMessage
    in
        on "keydown" (Json.Decode.map select keyCode)
