import asyncdispatch, oids

from bcrypt import hash, compare

from ../model/user import User, findByEmail, findById

proc checkPassword(receivedPassword, storedHash, salt: string): bool =
  let hashedPw = hash(receivedPassword, salt)

  compare(hashedPw, storedHash)

proc login*(email, password: string): Future[(bool, User)] {.async.} =
  let (found, user) = await findByEmail(email)

  if (not found) or (not checkPassword(password, user.hash, user.salt)):
    return (false, nil)
  else:
    return (true, user)

proc getUserById*(id: Oid): Future[(bool, User)] =
  return findById(id)
