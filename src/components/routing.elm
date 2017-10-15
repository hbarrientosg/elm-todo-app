module Components.Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)

type Route
    = All
    | Active
    | Completed
    | NotFound

matchers : Parser (Route -> a) a
matchers =
  oneOf [
    map All top,
    map Active (s "active"),
    map Completed (s "completed")
  ]

parseLocation: Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route -> route
    Nothing -> NotFound
