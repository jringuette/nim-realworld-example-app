import asyncdispatch, oids

from bcrypt import hash, compare, genSalt
import sam

from ../model/user import User, findByEmail, findById, insert, initUser, update
from ../util/mapping import mapNonNil

type
  UpdateUser* = ref object
    email*: string
    username*: string
    password*: string
    bio*: string
    image*: string

proc readFromJson*(s: string, t: typedesc[UpdateUser]): UpdateUser =
  result.new

  loads(result, s)

proc checkPassword(receivedPassword, storedHash, salt: string): bool =
  let hashedPw = hash(receivedPassword, salt)

  compare(hashedPw, storedHash)

proc login*(email, password: string): Future[(bool, User)] {.async.} =
  let (found, user) = await findByEmail(email)

  if (not found) or (not checkPassword(password, user.hash, user.salt)):
    return (false, nil)
  else:
    return (true, user)

proc getById*(id: Oid): Future[(bool, User)] =
  return findById(id)

proc generatePassword(password: string): (string, string) =
  let salt = genSalt(10)

  (hash(password, salt), salt)

proc register*(email, username, password: string): Future[User] =
  let user = initUser()

  user.email = email
  user.username = username
  (user.hash, user.salt) = generatePassword(password)

  return insert(user)

proc update*(barebones: UpdateUser, original: User): Future[User] =
  mapNonNil(
    source = barebones,
    dest   = original,
    fields = ["username", "email", "bio", "image"]
  )

  if barebones.password != nil:
    (original.hash, original.salt) = generatePassword(barebones.password)

  return user.update(original)
