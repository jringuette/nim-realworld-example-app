import asyncdispatch, oids, options

import database, nimongo.bson

import ../util/future


type
  User* = ref object
    id*: Oid
    email*: string
    hash*: string
    salt*: string
    username*: string
    bio*: string
    image*: string
    following*: seq[Oid]
    favorites*: seq[Oid]

  UserNotFoundError* = object of Exception

type
  BsonWritable = concept x
    %*(x) is Bson

const
  USERS = "users"
  EMPTY_OID = Oid()

converter toUser(bs: Bson): User =
  if bs == nil:
    result = nil
  else:
    result.new
    result.id = bs["_id"]
    result.email = bs["email"]
    result.hash = bs["hash"]
    result.salt = bs["salt"]
    result.username = bs["username"]
    result.bio = bs["bio"]
    result.image = bs["image"]
    result.following = @[]
    result.favorites = @[]

    for i in 0..<bs["following"].len:
      result.following.add(bs["following"][i])

    for i in 0..<bs["favorites"].len:
      result.favorites.add(bs["favorites"][i])

converter toBson(user: User): Bson =
  %*{
    "_id": user.id,
    "email": user.email,
    "hash": user.hash,
    "salt": user.salt,
    "username": user.username,
    "bio": user.bio,
    "image": user.image,
    "following": user.following,
    "favorites": user.favorites
  }

proc initUser*(): User =
  result.new
  result.following = @[]
  result.favorites = @[]

proc findByUniqueField[T: BsonWritable](name: string, value: T): Future[User] {.async.}  =
  # find().one() fails if there are no results
  var usersFut = db[USERS].find(%*{ name: value }).all()

  yield usersFut

  if (usersFut.failed()) or (usersFut.read().len == 0):
    return await failed[User](newException(UserNotFoundError, "User not found"))
  else:
    return await completed[User](usersFut.read()[0])

proc findById*(id: Oid): Future[User] {.async.} =
  return await findByUniqueField("_id", id)

proc findByEmail*(email: string): Future[User] {.async.} =
  return await findByUniqueField("email", email)

proc findByUsername*(username: string): Future[User] {.async.} =
  return await findByUniqueField("username", username)

proc insert*(user: User): Future[User] {.async.} =
  if user.id == EMPTY_OID:
    user.id = genOid()

  yield db[USERS].insert(%*user)

  return user

proc update*(user: User): Future[User] {.async.} =
  yield db[USERS].update(%*{ "_id": user.id }, %*user, multi = false, upsert = false)

  return user
