module Components.Todo exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Components.Attributes exposing (..)

type alias Model = {
  id: Int,
  isDone: Bool,
  isEdit: Bool,
  editing: String,
  value: String
}

create: Int -> String -> Model
create id task = {
    id = id,
    isDone = False,
    isEdit = False,
    editing = task,
    value = task
  }

-- UPDATE
type Message = NoOperation
  | MarkAsDone Bool
  | Focus String
  | Edit String
  | Delete
  | Save
  | Cancel

{- ! [] Executes a command on a background -}
update: Message -> Model -> Maybe Model
update message model =
  case Debug.log "MESSAGE: " message of
    MarkAsDone value -> Just { model | isDone = value }
    NoOperation -> Just model
    Focus elementId -> Just { model | isEdit = True }
    Edit newValue -> Just { model | isEdit = True, editing = newValue }
    Delete -> Nothing
    Save -> Just { model | isEdit = False, value = model.editing }
    Cancel -> Just { model | isEdit = False, editing = model.value }

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
        input [ type_ "checkbox", class "toggle", onClick (MarkAsDone (not model.isDone)), checked model.isDone ] [],
        label [] [ text model.value ],
        button [ class "destroy", onClick Delete] []
      ],
      input [
        type_ "text",
        id elementId,
        class "edit",
        value model.editing,
        onInput Edit,
        onBlur Save,
        onFinish Save Cancel
      ] []
    ]
