import asyncdispatch, oids

import database, nimongo.bson

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

proc findById*(id: Oid): Future[(bool, User)] {.async.} =
  # find().one() fails if there are no results
  let users: seq[Bson] = await db[USERS].find(%*{ "_id": id }).all()

  if users.len == 0:
    return (false, nil)
  else:
    # the converter does not work when used in a tuple
    return (true, toUser(users[0]))

proc findByEmail*(email: string): Future[(bool, User)] {.async.} =
  let users: seq[Bson] = await db[USERS].find(%*{ "email": email }).all()

  if users.len == 0:
    return (false, nil)
  else:
    return (true, toUser(users[0]))

proc insert*(user: User): Future[User] {.async.} =
  if user.id == EMPTY_OID:
    user.id = genOid()

  yield db[USERS].insert(%*user)

  return user

proc update*(user: User): Future[User] {.async.} =
  yield db[USERS].update(%*{ "_id": user.id }, %*user, multi = false, upsert = false)

  return user
