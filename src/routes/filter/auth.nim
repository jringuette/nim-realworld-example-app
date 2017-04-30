import asynchttpserver, asyncdispatch, httpcore, strutils, logging, options

import rosencrantz

from ../../model/user import User
from ../../service/authservice import authenticateByToken


# Imported types
# It's a good practice to use named types where it makes sense.
type
  UserAcceptingHandler* = proc(user: User): Handler

  NoTokenFoundError* = object of Exception

# Just a type alias to decrease the noise.
type
  RequestRef = ref Request

# Compile-time consts that prevent typos and ensure that the
# values are the same across the module.
const
  AUTH_HEADER = "Authorization"
  TOKEN_PART_COUNT = 3

# Module state
var
  # The prefix before the token in the Authorization header.
  prefix: string
  # A handler that will be executed upon unauthorized access.
  failHandler: Handler


proc headerPrefix*(): string =
  ## Gets the current header prefix.
  prefix

proc headerPrefix*(newPrefix: string) =
  ## Sets the current header prefix.
  prefix = newPrefix

proc failureHandler*(handler: Handler) =
  ## Sets the failure handler that will be executed upon
  ## unauthorized access.
  failHandler = handler

proc extractTokenFromRequest(req: RequestRef): Option[string] =
  ## Extracts the JWT from the Authorization header.
  ## Returns none() upon success, some(JWT) othwerwise.
  result = none(string)

  if not req.headers.hasKey(AUTH_HEADER):
    return

  let authHeader = split(req.headers[AUTH_HEADER], maxsplit = 2)

  if (authHeader.len < 2) or (authHeader[0] != prefix):
    return

  let tokenString = authHeader[1]

  debug("Obtained token from request: ", tokenString)

  # Check if all parts of the JWT are present.
  # Unfortunately the jwt lib will attempt an illegal storage access
  # when calling the verify method if the JWT is not complete.
  if split(tokenString, { '.' }).len != TOKEN_PART_COUNT:
    return

  return some(authHeader[1])

proc getRequestingUser(req: RequestRef): Future[User] =
  ## Gets the user associated with the request.
  ## Returns a completed Future upon success, fails otherwise with
  ## NoTokenFoundError.
  let tokenOpt = extractTokenFromRequest(req)

  if tokenOpt.isNone:
    result = newFuture[User]()

    result.fail(newException(NoTokenFoundError, "No token found in request!"))

    return

  return authenticateByToken(tokenOpt.unsafeGet())

proc mandatoryAuth*(p: UserAcceptingHandler): Handler =
  ## Expresses mandatory authentication.
  ## If an unauthorized request occurs, the failure handler will be called.
  ## Otherwise a correct User instance is passed to p.
  proc inner(req: RequestRef, ctx: Context): Future[Context] {.async.} =
    let userFut = getRequestingUser(req)

    yield userFut

    if userFut.failed():
      return await failHandler(req, ctx)

    let handler = p(userFut.read())

    return await handler(req, ctx)

  inner

proc optionalAuth*(p: UserAcceptingHandler): Handler =
  ## Expresses optional authentication.
  ## p receives a nil User if the authentication failed.
  proc inner(req: RequestRef, ctx: Context): Future[Context] {.async.} =
    let userFut = getRequestingUser(req)

    yield userFut

    let user =
      if userFut.failed():
        nil
      else:
        userFut.read()

    let handler = p(user)

    return await handler(req, ctx)

  inner
