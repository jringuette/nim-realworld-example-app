# Although system is implicitly imported, we now want to
# explicitly exclude the delete procedure
import system except delete
import json except delete
import asyncdispatch, oids

import rosencrantz

import ../model/user
import ../service/profileservice
from ../util/exception import readMsg
from filter/auth import mandatoryAuth, optionalAuth


proc respondWithProfile(profile: Profile): Handler =
  let profileJson = %*{
    "username": profile.username,
    "bio": profile.bio,
    "image": profile.image,
    "following": profile.following
  }

  ok(%{"profile": profileJson})

let
  getProfile =
    get ->
      pathChunk("/api/profiles") ->
        segment(proc(username: string): auto =
      optionalAuth(proc(user: User): auto =
        scopeAsync do:
          let profileFut = getByUsername(username)

          yield profileFut

          if profileFut.failed():
            return notFound(profileFut.readError().readMsg())
          else:
            let profile = profileFut.read()

            if user != nil:
              profile.following = profile.id in user.following

            return respondWithProfile(profile)
      )
    )

  followUser =
    post ->
      pathChunk("/api/profiles") ->
        segment(proc(username: string): auto =
      pathChunk("/follow") ->
        mandatoryAuth(proc(user: User): auto =
        scopeAsync do:
          let profileFut = follow(user, username)

          yield profileFut

          if profileFut.failed:
            return notFound(profileFut.readError().readMsg())
          else:
            return respondWithProfile(profileFut.read())
      )
    )

  unfollowUser =
    delete ->
      pathChunk("/api/profiles") ->
        segment(proc(username: string): auto =
      pathChunk("/follow") ->
        mandatoryAuth(proc(user: User): auto =
        scopeAsync do:
          let profileFut = unfollow(user, username)

          yield profileFut

          if profileFut.failed:
            return notFound(profileFut.readError().readMsg())
          else:
            return respondWithProfile(profileFut.read())
      )
    )

let handler* =
  getProfile ~
  followUser ~
  unfollowUser
