{-| Main App -}
import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing (..)
import Navigation exposing (Location)
import Components.Input as TodoEntry exposing (..)
import Components.Todo as Todo exposing (..)
import Components.Routing as Routing exposing (..)

init: Location -> (TodoApp, Cmd Message)
init location =
  let
    route = Routing.parseLocation location
  in
    (initModel route, Cmd.none)


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
  guidNext: Int,
  entry: TodoEntry,
  route: Routing.Route
}
emptyModel : TodoApp
emptyModel = {
    items = [],
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
    LocationChange location ->
        let
          newRoute = Routing.parseLocation location
          newModel = { model | route = newRoute }
        in case Debug.log "Route" newRoute of
          _ -> (newModel, Cmd.none)


routeFilter : Routing.Route -> (Todo.Model -> Bool)
routeFilter route =
  \todo ->
    case route of
      Active -> todo.isDone == False
      Completed -> todo.isDone == True
      _ -> (todo.id /= -1)

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
    filteredItems = List.filter (routeFilter model.route) model.items
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
                  ) filteredItems)
      ],
      footer [ class "footer", style (isVisible model.items) ] [
        span [ class "todo-count" ] [
          strong [] [ text (toString activeCount)],
          text " items left"
        ],
        ul [ class "filters" ] [
          li [] [
            a [ class (isSelected All), href "/#/" ] [ text "All" ]
          ],
          li [] [
            a [ class (isSelected Active), href "#/active"] [ text "Active" ]
          ],
          li [] [
            a [ class (isSelected Completed), href "#/completed"] [ text "Completed" ]
          ]
        ]
      ]
    ]
