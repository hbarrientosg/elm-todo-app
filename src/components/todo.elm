module Components.Todo exposing (..)

import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

type alias Model = {
  id: Int,
  isDone: Bool,
  isEdit: Bool,
  value: String
}

init: String -> Model
init label = {
    id = 0,
    isDone = False,
    isEdit = False,
    value = label
  }

-- UPDATE
type Message = NoOperation
  | MarkAsDone
  | Focus String
  | Edit String
  | Save String

update: Message -> Model -> Model
update message model =
  case Debug.log "MESSAGE: " message of
    MarkAsDone -> { model | isDone = (not model.isDone) }
    NoOperation -> model
    Focus elementId -> { model | isEdit = True }
    Edit newValue -> { model | value = newValue }
    Save newValue -> { model | isEdit = False, value = newValue }




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
        input [ type_ "checkbox", class "toggle", onClick MarkAsDone ] [],
        label [] [ text model.value ],
        button [ class "destroy" ] []
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
