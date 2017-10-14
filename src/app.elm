{-| Main App -}
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Components.Todo as Todo exposing (..)

main =
  Html.beginnerProgram {
    model = model,
    view = view,
    update = Todo.update
  }

-- MODEL
model : Todo.Model
model = Todo.init "Hola que hace"

-- UPDATE

-- VIEW
view: Todo.Model -> Html Todo.Message
view model =
  section [ class "todoapp" ] [
    header [ class "header" ] [
      h1 [] [ text "todos" ],
      input [ type_ "text", class "new-todo", placeholder "What needs to be done?", autofocus True ] []
    ],
    section [ class "main" ] [
      ul [ class "todo-list" ] [
        Todo.view model
      ]
    ]
  ]

{-
  main =
    Html.beginnerProgram { model = model, view = newTodo, update = addNew }
  type alias Todo = {
    isDone: Bool,
    label: String
  }

  type alias TodoApp = {
    items: List Todo,
    newItem: String
  }

  model : TodoApp
  model = {
      items = [],
      newItem = ""
    }

   MODEL

  UPDATE
  type UpdateApp =
    UpdateField String |
    Add

  addNew: UpdateApp -> TodoApp
  addNew msg model =
    case Debug.log "MESSAGE: " msg of
      UpdateField str -> model

   VIEW
  newTodo : TodoApp -> Html UpdateApp
  newTodo appModel =
    input [
      type_ "text",
      class "new-todo",
      placeholder "What needs to be done?",
      value appModel.field,
      autofocus True,
      onInput UpdateField ] []

  main =
   section [ class "todoapp" ]
     [ header [ class "header" ] [
       h1 [] [ text "todos" ],
       input [ type_ "text", class "new-todo", placeholder "What needs to be done?", autofocus True, onInput Change ] []
     ]
   ]

-}
