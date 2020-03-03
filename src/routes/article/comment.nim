# Although system is implicitly imported, we now want to
# explicitly exclude the delete procedure.
import system except delete
# Same for JSON, delete needs to be excluded.
import json except delete

import rosencrantz

import ../../model/user
from ../filter/auth import mandatoryAuth, optionalAuth


let
  addComment =
    post ->
      pathChunk("/api/articles") ->
        segment(proc(slug: string): auto =
      pathChunk("/comments") ->
        mandatoryAuth(proc(user: User): auto =
        jsonBody(proc(body: JsonNode): auto =
          ok("Add Comment: " & slug & " " & $body)
        )
      )
    )

  deleteComment =
    delete ->
      pathChunk("/api/articles") ->
        segment(proc(slug: string): auto =
      pathChunk("/comments") ->
        intSegment(proc(id: int): auto =
        mandatoryAuth(proc(user: User): auto =
          ok("Delete Comment: " & slug & " " & $id)
        )
      )
    )

  getComments =
    get ->
      pathChunk("/api/articles") ->
        segment(proc(slug: string): auto =
      pathChunk("/comments") ->
        optionalAuth(proc(user: User): auto =
        ok("Get Comments: " & slug)
      )
    )

let handler* =
  addComment ~
  deleteComment ~
  getComments
