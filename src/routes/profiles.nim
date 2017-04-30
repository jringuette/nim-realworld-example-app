# Although system is implicitly imported, we now want to
# explicitly exclude the delete procedure
import system except delete

import rosencrantz

import ../model/user
from filter/auth import mandatoryAuth, optionalAuth


let
  getProfile =
    get ->
      pathChunk("/api/profiles") ->
        segment do (username: string) -> auto:
          optionalAuth do (user: User) -> auto:
            ok("Get Profile: " & username)

  followUser =
    post ->
      pathChunk("/api/profiles") ->
        segment do (username: string) -> auto:
          pathChunk("/follow") ->
            mandatoryAuth do (user: User) -> auto:
              ok("Follow User: " & username)

  unfollowUser =
    delete ->
      pathChunk("/api/profiles") ->
        segment do (username: string) -> auto:
          pathChunk("/follow") ->
            mandatoryAuth do (user: User) -> auto:
              ok("Unfollow User: " & username)

let handler* =
  getProfile ~
  followUser ~
  unfollowUser
