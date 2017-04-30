import asynchttpserver, asyncdispatch, httpcore, strutils, logging

import rosencrantz

from ../../model/user import User
from ../../service/authservice import authenticateByToken


# Imported types
# It's a good practice to use named types where it makes sense.
type
  UserAcceptingHandler* = proc(user: User): Handler

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

proc extractTokenFromRequest(req: RequestRef): (bool, string) =
  ## Extracts the JWT from the Authorization header.
  ## Returns (true, JWT) upon success, (false, empty JWT) othwerwise.
  result = (false, nil)

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

  return (true, authHeader[1])

proc getRequestingUser(req: RequestRef): Future[(bool, User)] =
  ## Gets the user associated with the request.
  ## Returns (true, User) upon success, (false, nil) otherwise
  let (success, token) = extractTokenFromRequest(req)

  if not success:
    result = newFuture[(bool, User)]()

    result.complete((false, nil))

    return

  return authenticateByToken(token)

proc mandatoryAuth*(p: UserAcceptingHandler): Handler =
  ## Expresses mandatory authentication.
  ## If an unauthorized request occurs, the failure handler will be called.
  ## Otherwise a correct User instance is passed to p.
  proc inner(req: RequestRef, ctx: Context): Future[Context] {.async.} =
    let (success, user) = await getRequestingUser(req)

    if not success:
      return await failHandler(req, ctx)

    let handler = p(user)

    return await handler(req, ctx)

  inner

proc optionalAuth*(p: UserAcceptingHandler): Handler =
  ## Expresses optional authentication.
  ## p receives a nil User if the authentication failed.
  proc inner(req: RequestRef, ctx: Context): Future[Context] {.async.} =
    let (_, user) = await getRequestingUser(req)

    let handler = p(user)

    return await handler(req, ctx)

  inner
