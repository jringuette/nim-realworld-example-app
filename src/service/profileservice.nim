import asyncdispatch, oids

from ../model/user import User
from ../util/future import completed, failed
from userservice import getByUsername

type
  Profile* = ref object
    id*: Oid
    username*: string
    bio*: string
    image*: string
    following*: bool

  ProfileNotFoundError* = object of Exception

converter userToProfile(user: User): Profile =
  result.new
  result.id = user.id
  result.username = user.username
  result.bio = user.bio
  result.image = user.image
  result.following = false

proc getByUsername*(username: string): Future[Profile] {.async.} =
  let
    userFut = userservice.getByUsername(username)

  yield userFut

  if (userFut.failed()):
    return await failed[Profile](newException(ProfileNotFoundError, "Profile Not Found!"))
  else:
    return await completed(userFut.read())
