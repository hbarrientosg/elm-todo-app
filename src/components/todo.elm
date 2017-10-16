module Components.Todo exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model = {
  id: Int,
  isDone: Bool,
  isEdit: Bool,
  value: String
}

create: Int -> String -> Model
create id task = {
    id = id,
    isDone = False,
    isEdit = False,
    value = task
  }

-- UPDATE
type Message = NoOperation
  | MarkAsDone
  | Focus String
  | Edit String
  | Delete
  | Save String

{- ! [] Executes a command on a background -}
update: Message -> Model -> Maybe Model
update message model =
  case Debug.log "MESSAGE: " message of
    MarkAsDone -> Just { model | isDone = (not model.isDone) }
    NoOperation -> Just model
    Focus elementId -> Just { model | isEdit = True }
    Edit newValue -> Just { model | value = newValue }
    Delete -> Nothing
    Save newValue -> Just { model | isEdit = False, value = newValue }

-- VIEW
view: Model -> Html Message
view model =
  let
    editingClass =
      (if model.isEdit then "editing "
      else "") ++
      (if model.isDone then "completed "
       else "")
    elementId = toString model.id
    newValue = model.value
  in
    li [ class editingClass, onDoubleClick (Focus elementId) ] [
      div [ class "view" ] [
        input [ type_ "checkbox", class "toggle", onClick MarkAsDone, checked model.isDone ] [],
        label [] [ text model.value ],
        button [ class "destroy", onClick Delete] []
      ],
      input [
        type_ "text",
        id elementId,
        class "edit",
        value newValue,
        onInput Edit,
        onBlur (Save newValue)
      ] []
    ]
