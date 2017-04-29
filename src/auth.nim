import asynchttpserver, asyncdispatch, httpcore, strutils, tables, json, logging

import rosencrantz, jwt

import model/user


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
  ID_CLAIM = "id"
  TOKEN_PART_COUNT = 3

# Module state
var
  # The prefix before the token in the Authorization header.
  prefix: string
  # The secret key to sign and verify JWTs.
  secret: string
  # A handler that will be executed upon unauthorized access.
  failHandler: Handler


proc headerPrefix*(): string =
  ## Gets the current header prefix.
  prefix

proc headerPrefix*(newPrefix: string) =
  ## Sets the current header prefix.
  prefix = newPrefix

proc jwtSecret*(): string =
  ## Gets the current JWT secret key.
  secret

proc jwtSecret*(newSecret: string) =
  ## Sets the current JWT secret key.
  secret = newSecret

proc failureHandler*(handler: Handler) =
  ## Gets the failure handler that will be executed upon
  ## unauthorized access.
  failHandler = handler

proc issueToken*(userId: int64): string =
  ## Issues a new JWT with the specified user id as a claim.
  ## Returns the string representation of the token.
  var token = toJWT(%*{
    "header": {
      "alg": "HS256",
      "typ": "JWT"
    },
    "claims": {
      "id": userId
    }
  })

  sign(token, secret)

  return $token

proc extractTokenFromRequest(req: RequestRef): (bool, JWT) =
  ## Extracts the JWT from the Authorization header.
  ## Returns (true, JWT) upon success, (false, empty JWT) othwerwise.
  result = (false, JWT())

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

  try:
    return (true, toJWT(authHeader[1]))
  except InvalidToken:
    return

proc extractUserIdFromToken(token: JWT): (bool, int64) =
  ## Extracts the user id from the id field of the JWT claims.
  ## Returns (true, id) upon success, (false, 0) otherwise.
  result = (false, 0'i64)

  if not token.claims.hasKey(ID_CLAIM):
    return

  let idClaim = token.claims[ID_CLAIM]

  case idClaim.node.kind:
  of JInt:
    return (true, int64(idClaim.node.num))
  else:
    return

proc getRequestingUser(req: RequestRef): (bool, User) =
  ## Gets the user associated with the request.
  ## Returns (true, User) upon success, (false, nil) otherwise
  result = (false, nil)

  let (success, token) = extractTokenFromRequest(req)

  if (not success) or (not token.verify(secret)):
    return

  let (succ, id) = extractUserIdFromToken(token)

  if not succ:
    return

  return findById(id)

proc mandatoryAuth*(p: UserAcceptingHandler): Handler =
  ## Expresses mandatory authentication.
  ## If an unauthorized request occurs, the failure handler will be called.
  ## Otherwise a correct User instance is passed to p.
  proc inner(req: RequestRef, ctx: Context): Future[Context] {.async.} =
    let (success, user) = getRequestingUser(req)

    if not success:
      return await failHandler(req, ctx)

    let handler = p(user)

    return await handler(req, ctx)

  inner

proc optionalAuth*(p: UserAcceptingHandler): Handler =
  ## Expresses optional authentication.
  ## p receives a nil User if the authentication failed.
  proc inner(req: RequestRef, ctx: Context): Future[Context] {.async.} =
    let (_, user) = getRequestingUser(req)

    let handler = p(user)

    return await handler(req, ctx)

  inner
