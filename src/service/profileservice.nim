import asyncdispatch, oids, strutils

from ../model/user import User
from ../util/future import completed, failed
from userservice import getByUsername, update

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

  ProfileCannotBeFollowedError* = object of Exception
    username: string

proc username*(err: ProfileNotFoundError): string =
  err.username

template profileNotFound(name: string): untyped =
  var e: ref ProfileNotFoundError

  new(e)

  e.username = name
  # Only using strutils.`%`` because the template is not exported, therefore
  # this dependency is not unexpected.
  e.msg = "Profile with username \"$1\" not found." % [name]
  e

proc username*(err: ProfileCannotBeFollowedError): string =
  err.username

template profileCannotBeFollowed(name: string): untyped =
  var e: ref ProfileCannotBeFollowedError

  new(e)

  e.username = name
  e.msg = "Profile with username \"$1\" cannot be followed." % [name]
  e

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

  if userFut.failed():
    return await failed[Profile](profileNotFound(username))
  else:
    return await completed(userFut.read())

proc follow*(follower: User, followed: string): Future[Profile] {.async.} =
  let profileFut = getByUsername(followed)

  yield profileFut

  if profileFut.failed():
    # By using failed and readError, the exception is reraised in an async way.
    return await failed[Profile](profileFut.readError())

  let profile = profileFut.read()

  # You cannot follow yourself and the same person twice.
  if (follower.username == followed) or (profile.id in follower.following):
    return await failed[Profile](profileCannotBeFollowed(followed))

  follower.following.add(profile.id)

  let updateFut = userservice.update(follower)

  yield updateFut

  if updateFut.failed:
    return await failed[Profile](profileCannotBeFollowed(followed))
  else:
    # Future did not fail, so we can be sure that the modification was saved.
    # Therefore the representation can be safely modified and will be in sync.
    profile.following = true

    return await completed(profile)
