import rosencrantz

let handler* =
  get[
    path("/api/profiles")[
      ok("profiles")
    ]
  ]
