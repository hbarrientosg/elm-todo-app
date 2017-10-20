{-| Main App -}
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (..)
import Task
import Dom exposing (focus)
import Navigation exposing (Location)
import Routing exposing (..)
import Components.TodoEntry as TodoEntry exposing (..)
import Components.Todo as Todo exposing (..)

init: Location -> (TodoApp, Cmd Message)
init location =
  let
    route = Routing.parseLocation location
  in
    (initModel route, Cmd.none)


main : Program Never TodoApp Message
main =
    Navigation.program LocationChange
        { view = view,
          update = update,
          subscriptions = \_ -> Sub.none, -- No Subscritpions
          init = init
        }

-- MODEL
type alias TodoApp = {
  items: List Todo.Model,
  markAll: Bool,
  guidNext: Int,
  entry: TodoEntry,
  route: Routing.Route
}

emptyModel : TodoApp
emptyModel = {
    items = [],
    markAll = False,
    guidNext = 0,
    entry = TodoEntry.emptyEntry,
    route = All
  }

initModel : Routing.Route -> TodoApp
initModel newRoute =
  { emptyModel | route = newRoute }

-- UPDATE
type Message = NoOperation
  | LocationChange (Location)
  | NewTodo (TodoEntry.Message)
  | UpdateTodo (Int, Todo.Message)
  | FocusAttempt (Result Dom.Error ())
  | MarkAll (Bool)
  | Clear

{- ! [] Executes a command on a background -}
update: Message -> TodoApp -> ( TodoApp, Cmd Message)
update message model =
  case Debug.log "MESSAGE: " message of
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
              newModel = addNew model newId
            in
            newModel ! []
          _ -> newModel ! []
    UpdateTodo todoMsg ->
        let
          todoId = Tuple.first todoMsg
          todoMessage = Tuple.second todoMsg
          {- Find a todo and only update the selected ones -}
          updateTodo = updateMap todoId todoMessage
          updateModel = { model | items = List.filterMap updateTodo model.items }
        in case todoMessage of
          Focus todoId ->
            (updateModel, Task.attempt FocusAttempt (focus todoId) )
          _ -> updateModel ! []
    LocationChange location ->
        let
          newRoute = Routing.parseLocation location
          newModel = { model | route = newRoute }
        in case Debug.log "Route" newRoute of
          _ -> newModel ! []
    FocusAttempt result ->
      model ! []
    MarkAll value ->
        let
          update = updateAll (Todo.MarkAsDone value)
          newModel = { model |
              items = List.filterMap update model.items,
              markAll = value
            }
        in
          newModel ! []
    Clear ->
      let
        deleteComplete = routeFilter Routing.Active
      in
      { model |
          items = List.filter deleteComplete model.items
      } ! []
    _ -> model ! []

routeFilter : Routing.Route -> (Todo.Model -> Bool)
routeFilter route =
  \todo ->
    case route of
      Active -> todo.isDone == False
      Completed -> todo.isDone == True
      _ -> (todo.id /= -1)

addNew: TodoApp -> Int -> TodoApp
addNew model newId =
  if String.isEmpty model.entry.value then
    model
  else
    { model |
      entry = TodoEntry.emptyEntry,
      items = (Todo.create newId model.entry.value) :: model.items,
      guidNext = newId
    }

updateAll : Todo.Message -> (Todo.Model -> Maybe Todo.Model)
updateAll todoMessage =
  \todo ->
    (Todo.update todoMessage todo)

updateMap : Int -> Todo.Message -> (Todo.Model -> Maybe Todo.Model)
updateMap todoId todoMessage =
  \todo ->
    if todo.id == todoId then
      (Todo.update todoMessage todo)
    else
      Just todo


-- VIEW
view: TodoApp -> Html Message
view model =
  let
    isVisible = \items ->
      if List.isEmpty items then
        [("display", "none")]
      else
        []
    isSelected = \route ->
      if model.route == route then
        "selected"
      else
        ""
    activeCount = List.length (List.filter (routeFilter Active) model.items)
    activeDone = List.length (List.filter (routeFilter Completed) model.items)
    filteredItems = List.filter (routeFilter model.route) model.items
  in
    section [ class "todoapp" ] [
      header [ class "header" ] [
        h1 [] [ text "todos" ],
        Html.map (\msg -> NewTodo msg) (TodoEntry.view model.entry)
      ],
      section [ class "main" ] [
        input [
          class "toggle-all",
          type_ "checkbox",
          name "toggle",
          onClick (MarkAll (not model.markAll)) ] [],
        label [ for "toggle-all" ] [ text "Mark all as complete" ],
        ul [ class "todo-list" ]
        (List.map (\todo ->
                    let
                      todoView = Todo.view todo
                    in
                      Html.map (\msg -> UpdateTodo (todo.id, msg)) todoView
                  ) filteredItems)
      ],
      footer [ class "footer", style (isVisible model.items) ] [
        span [ class "todo-count" ] [
          strong [] [ text (toString activeCount)],
          text " items left"
        ],
        ul [ class "filters" ] [
          li [] [
            a [ class (isSelected All), href "#/" ] [ text "All" ]
          ],
          li [] [
            a [ class (isSelected Active), href "#/active"] [ text "Active" ]
          ],
          li [] [
            a [ class (isSelected Completed), href "#/completed"] [ text "Completed" ]
          ]
        ],
        button [ class "clear-completed", hidden (activeDone == 0), onClick Clear]
               [ text  (String.concat ["Clear completed (", (toString activeDone), ")"])  ]
      ]
    ]
