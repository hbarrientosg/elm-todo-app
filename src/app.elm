{-| Main App -}
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing (..)
import Components.Input as TodoEntry exposing (..)
import Components.Todo as Todo exposing (..)

main =
    Html.program
        { view = view,
          update = update,
          subscriptions = \_ -> Sub.none, -- No Subscritpions
          init = ( model, Cmd.none )
        }

-- MODEL
type alias TodoApp = {
  items: List Todo.Model,
  guidNext: Int,
  entry: TodoEntry
}
model : TodoApp
model = {
    items = [],
    guidNext = 0,
    entry = TodoEntry.emptyEntry
  }

-- UPDATE
type Message = NoOperation
  | NewTodo (TodoEntry.Message)
  | UpdateTodo (Int, Todo.Message)

{- ! [] Executes a command on a background -}
update: Message -> TodoApp -> ( TodoApp, Cmd Message)
update message model =
  case Debug.log "MESSAGE: " message of
    NoOperation -> (model, Cmd.none)
    NewTodo entryMsg ->
      let
        updateEntry entry =
          TodoEntry.update entryMsg model.entry
        newModel = { model | entry = updateEntry model.entry }
        newId = model.guidNext + 1
      in
        case entryMsg of
          TodoEntry.CreateNew ->
            let
              newValue = model.entry.value
              newModel = { model |
                entry = TodoEntry.emptyEntry,
                items = (Todo.create newId newValue) :: model.items,
                guidNext = newId
              }
            in
            (newModel, Cmd.none)
          _ -> (newModel, Cmd.none)
    UpdateTodo todoMsg ->
        let
          todoId = Tuple.first todoMsg
          todoMessage = Tuple.second todoMsg
          {- Find a todo and only update the selected ones -}
          updateTodo = \todo ->
            if todo.id == todoId then
              Just (Todo.update todoMessage todo)
            else
              Just todo
          newModel = { model | items = List.filterMap updateTodo model.items }
        in
          case todoMessage of
            _ -> (newModel, Cmd.none)


-- VIEW
view: TodoApp -> Html Message
view model =
  let
    isVisible = \items ->
      if List.isEmpty items then
        [("display", "none")]
      else
        []
  in
    section [ class "todoapp" ] [
      header [ class "header" ] [
        h1 [] [ text "todos" ],
        Html.map (\msg -> NewTodo msg) (TodoEntry.view model.entry)
      ],
      section [ class "main" ] [
        ul [ class "todo-list" ]
        (List.map (\todo ->
                    let
                      todoView = Todo.view todo
                    in
                      Html.map (\msg -> UpdateTodo (todo.id, msg)) todoView
                  ) model.items)
      ],
      footer [ class "footer", style (isVisible model.items) ] [
        span [ class "todo-count" ] [
          strong [] [ text (toString (List.length model.items))],
          text " items left"
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
