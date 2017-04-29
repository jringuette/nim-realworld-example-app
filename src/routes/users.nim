import rosencrantz

import ../auth, ../model/user

let
  authentication =
    post ->
      path("/api/users/login") ->
        ok("Authentication")

  registration =
    post ->
      path("/api/users") ->
        ok("Registration")

  getCurrentUser =
    get ->
      path("/api/user") ->
        mandatoryAuth do (user: User) -> auto:
          ok("Current user")

  updateUser =
    put ->
      path("/api/user") ->
        mandatoryAuth do (user: User) -> auto:
          ok("Update user")

let handler* =
  authentication ~
  registration ~
  getCurrentUser ~
  updateUser
