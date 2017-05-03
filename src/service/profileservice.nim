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
    # note that it's not exported
    username: string

template profileNotFound*(username: string): untyped =
  var e: ref ProfileNotFoundError

  new(e)

  e.username = username
  # Could use strutils.`%` but templates should not have
  # unexpected dependencies.
  e.msg = "Profile with username \"" & username & "\" not found."
  e

proc username*(err: ProfileNotFoundError): string =
  err.username

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
    return await failed[Profile](profileNotFound(username))
  else:
    return await completed(userFut.read())
