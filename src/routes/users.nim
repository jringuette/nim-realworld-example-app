import rosencrantz

let handler* =
  get[
    path("/api/users")[
      ok("Users")
    ]
  ]
