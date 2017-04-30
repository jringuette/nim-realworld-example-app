import asyncdispatch, json, httpcore, tables

import rosencrantz

import ../model/user, ../service/userservice, customhandler
from ../auth import mandatoryAuth

let
  authentication =
    post ->
      path("/api/users/login") ->
        jsonBody do (body: JsonNode) -> auto:
          scopeAsync do:
            let
              email = body["user"]["email"].str
              password = body["user"]["password"].str

            let (success, user) = await login(email, password)

            if not success:
              let errors = {"email or password" : "is invalid"}.toTable()

              return unprocessableEntity(errors)
            else:
              return ok(user.email)

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
