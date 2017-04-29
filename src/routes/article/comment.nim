# Although system is implicitly imported, we now want to
# explicitly exclude the delete procedure.
import system except delete
# Same for JSON, delete needs to be excluded.
import json except delete

import rosencrantz

import ../../model/user
from ../../auth import mandatoryAuth, optionalAuth


let
  addComment =
    post ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          pathChunk("/comments") ->
            mandatoryAuth do (user: User) -> auto:
              jsonBody do (body: JsonNode) -> auto:
                ok("Add Comment: " & slug & " " & $body)

  deleteComment =
    delete ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          pathChunk("/comments") ->
            intSegment do (id: int) -> auto:
              mandatoryAuth do (user: User) -> auto:
                ok("Delete Comment: " & slug & " " & $id)

  getComments =
    get ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          pathChunk("/comments") ->
            optionalAuth do (user: User) -> auto:
              ok("Get Comments: " & slug)

let handler* =
  addComment ~
  deleteComment ~
  getComments
