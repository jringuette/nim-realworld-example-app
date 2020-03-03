import asyncdispatch, json, httpcore, tables, sets
import nre except get

import rosencrantz

from ../model/user import User, initUser
from ../service/userservice
  import login, register, UpdateUser, readFromJson, updateWith
from ../service/authservice import issueToken
from filter/auth import mandatoryAuth
from filter/terminal import unprocessableEntity
from filter/validation import validateBody


let
  emailPattern = re"""^\S+?\@\S+?\.\S+$"""
  usernamePattern = re"""^[a-zA-Z0-9]+$"""

proc respondWithUser(user: User): Handler =
  let resultJson = %*{
    "email": user.email,
    "token": issueToken(user.id),
    "username": user.username,
    "image": user.image,
    "bio": user.bio
  }

  ok(%{"user": resultJson})

proc authValidator(body: JsonNode): Table[string, string] {.procvar.} =
  result = initTable[string, string]()

  if not body.hasKey("user"):
    result.add("user", "missing field")
    return

  if not body["user"].hasKey("email"):
    result.add("email", "can't be blank")
  if not body["user"].hasKey("password"):
    result.add("password", "can't be blank")

# A nice JSON validator framework should be written instead of
# this horrible code.
proc registerValidator(body: JsonNode): Table[string, string] {.procvar.} =
  result = initTable[string, string]()

  if not body.hasKey("user"):
    result.add("user", "missing field")
    return

  if not body["user"].hasKey("email"):
    result.add("email", "can't be blank")
  elif not contains(body["user"]["email"].str, emailPattern):
    result.add("email", "is invalid")

  if not body["user"].hasKey("username"):
    result.add("username", "can't be blank")
  elif not contains(body["user"]["username"].str, usernamePattern):
    result.add("username", "is invalid")

  if not body["user"].hasKey("password"):
    result.add("password", "can't be blank")

proc updateValidator(body: JsonNode): Table[string, string] {.procvar.} =
  result = initTable[string, string]()

  if not body.hasKey("user"):
    result.add("user", "missing field")
    return

  if (body["user"].hasKey("email")) and
      (not contains(body["user"]["email"].str, emailPattern)):
    result.add("email", "is invalid")

  if (body["user"].hasKey("username")) and
      (not contains(body["user"]["username"].str, usernamePattern)):
    result.add("username", "is invalid")

let
  authentication =
    post ->
      path("/api/users/login") ->
        jsonBody(proc(body: JsonNode): auto =
      validateBody(authValidator, body) do -> auto:
        scopeAsync do:
          let
            email = body{"user", "email"}.str
            password = body{"user", "password"}.str

          let userFut = login(email, password)

          yield userFut

          if userFut.failed():
            let errors = {"email or password": "is invalid"}.toTable()

            return unprocessableEntity(errors)
          else:
            return respondWithUser(userFut.read())
    )

  registration =
    post ->
      path("/api/users") ->
        jsonBody(proc(body: JsonNode): auto =
      validateBody(registerValidator, body) do -> auto:
        scopeAsync do:
          let
            email = body{"user", "email"}.str
            username = body{"user", "username"}.str
            password = body{"user", "password"}.str

          let user = await register(email, username, password)

          return respondWithUser(user)
    )

  getCurrentUser =
    get ->
      path("/api/user") ->
        mandatoryAuth(proc(user: User): auto =
      return respondWithUser(user)
    )

  updateUser =
    put ->
      path("/api/user") ->
        mandatoryAuth(proc(user: User): auto =
      jsonBody(proc(body: JsonNode): auto =
        validateBody(updateValidator, body) do -> auto:
          scopeAsync do:
            let barebones = readFromJson($body["user"], UpdateUser)

            let updated = await updateWith(barebones, user)

            return respondWithUser(updated)
      )
    )

let handler* =
  authentication ~
  registration ~
  getCurrentUser ~
  updateUser
