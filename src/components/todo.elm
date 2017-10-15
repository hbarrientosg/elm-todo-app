module Components.Todo exposing (..)

import Dom
import Task
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
  | Save String

{- ! [] Executes a command on a background -}
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
