import rosencrantz

let
  getTags =
    get ->
      path("/api/tags") ->
        ok("Get Tags")

let handler* =
  getTags
