import asyncdispatch

import bcrypt

import ../model/user

proc checkPassword(receivedPassword, storedHash, salt: string): bool =
  let hashedPw = hash(receivedPassword, salt)

  compare(hashedPw, storedHash)

proc login*(email, password: string): Future[(bool, User)] {.async.} =
  let (found, user) = await findByEmail(email)

  if (not found) or (not checkPassword(password, user.hash, user.salt)):
    return (false, nil)
  else:
    return (true, user)
