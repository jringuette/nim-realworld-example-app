import rosencrantz

let handler* =
  get[
    path("/api/articles")[
      ok("Articles")
    ]
  ]
