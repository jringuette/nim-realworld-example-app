import rosencrantz

let handler* =
  get[
    path("/api/tags")[
      ok("Tags")
    ]
  ]
