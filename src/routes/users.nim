import rosencrantz

import ../auth, ../model/user

let handler* =
  get[
    path("/api/users")[
      mandatoryAuth do (user: User) -> auto:
        ok("Success")
    ]
  ]
