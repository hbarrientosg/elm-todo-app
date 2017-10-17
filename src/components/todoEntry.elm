module Components.TodoEntry exposing (..)

import Html exposing (Html, input)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Components.Attributes exposing (onFinish)
-- Model
type alias TodoEntry = {
  value: String
}

emptyEntry: TodoEntry
emptyEntry = {
    value = ""
  }

-- Update
type Message = NoOperation
  | Typing String
  | CreateNew

update: Message -> TodoEntry -> TodoEntry
update message model =
  case Debug.log "ENTRY: " message of
    NoOperation -> model
    Typing newValue -> { model | value = newValue }
    CreateNew -> model

-- View
view: TodoEntry -> Html Message
view model =
  input [
    type_ "text",
    class "new-todo",
    placeholder "What needs to be done?",
    autofocus True,
    value model.value,
    onInput Typing,
    onFinish CreateNew NoOperation
  ] []
