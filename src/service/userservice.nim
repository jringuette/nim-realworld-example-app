import asyncdispatch, oids

from bcrypt import hash, compare, genSalt

from ../model/user import User, findByEmail, findById, insert, initUser

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

proc register*(email, username, password: string): Future[User] =
  let user = initUser()

  user.email = email
  user.username = username
  user.salt = genSalt(10)
  user.hash = hash(password, user.salt)

  return insert(user)
