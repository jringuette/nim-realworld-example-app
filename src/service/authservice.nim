import asynchttpserver, asyncdispatch, httpcore, strutils, tables, json, oids, options

import jwt

from ../model/user import User
from ../util/future import failed
from userservice import getById


type
  AuthenticationFailedError* = object of Exception

  InvalidUserIdError* = object of Exception

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

proc extractUserIdFromToken(token: JWT): Option[string] =
  ## Extracts the user id from the id field of the JWT claims.
  ## Returns some(id) upon success, none() otherwise.
  result = none(string)

  if not token.claims.hasKey(ID_CLAIM):
    return

  let idClaim = token.claims[ID_CLAIM]

  case idClaim.node.kind:
  of JString:
    return some(idClaim.node.str)
  else:
    return

proc verifyToken(tokenString: string): Option[JWT] =
  result = none(JWT)

  try:
    let token = toJWT(tokenString)

    if not token.verify(secret):
      return
    else:
      return some(token)
  except:
    return

proc authenticateByToken*(tokenString: string): Future[User] =
  let tokenOpt = verifyToken(tokenString)

  if tokenOpt.isNone():
    return failed[User](newException(AuthenticationFailedError,
                        "Token could not be verified!"))

  let idOpt = extractUserIdFromToken(tokenOpt.unsafeGet())

  if idOpt.isNone:
    return failed[User](newException(InvalidUserIdError, "Malformed token claim!"))

  return getById(parseOid(idOpt.unsafeGet()))
