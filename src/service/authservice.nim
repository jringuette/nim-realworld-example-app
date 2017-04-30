import asynchttpserver, asyncdispatch, httpcore, strutils, tables, json, oids

import jwt

from ../model/user import User
from userservice import getUserById

const
  ID_CLAIM = "id"

# Module state
var
  # The secret key to sign and verify JWTs.
  secret: string

proc jwtSecret*(): string =
  ## Gets the current JWT secret key.
  secret

proc jwtSecret*(newSecret: string) =
  ## Sets the current JWT secret key.
  secret = newSecret

proc issueToken*(userId: Oid): string =
  ## Issues a new JWT with the specified user id as a claim.
  ## Returns the string representation of the token.
  var token = toJWT(%*{
    "header": {
      "alg": "HS256",
      "typ": "JWT"
    },
    "claims": {
      "id": $userId
    }
  })

  sign(token, secret)

  return $token

proc extractUserIdFromToken(token: JWT): (bool, string) =
  ## Extracts the user id from the id field of the JWT claims.
  ## Returns (true, id) upon success, (false, 0) otherwise.
  result = (false, nil)

  if not token.claims.hasKey(ID_CLAIM):
    return

  let idClaim = token.claims[ID_CLAIM]

  case idClaim.node.kind:
  of JString:
    return (true, idClaim.node.str)
  else:
    return

proc verifyToken(tokenString: string): (bool, JWT) =
  result = (false, JWT())

  try:
    let token = toJWT(tokenString)

    if not token.verify(secret):
      return
    else:
      return (true, token)
  except:
    return

proc authenticateByToken*(tokenString: string): Future[(bool, User)] =
  result = newFuture[(bool, User)]()
  result.complete((false, nil))

  let (verified, token) = verifyToken(tokenString)

  if not verified:
    return

  let (valid, id) = extractUserIdFromToken(token)

  if not valid:
    return

  return getUserById(parseOid(id))
