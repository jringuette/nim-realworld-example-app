# Although system is implicitly imported, we now want to
# explicitly exclude the delete procedure.
import system except delete
# Same for JSON, delete needs to be excluded.
import json except delete
# Needed by queryString
import tables, strtabs

import rosencrantz

import ../../model/user
from ../filter/auth import mandatoryAuth, optionalAuth


let
  listArticles =
    get ->
      path("/api/articles") ->
        optionalAuth(proc(user: User): auto =
      queryString(proc(params: StringTableRef): auto =
        ok("List Articles with query: " & $params)
      )
    )

  feedArticles =
    get ->
      path("/api/articles/feed") ->
        mandatoryAuth(proc(user: User): auto =
      queryString(proc(params: StringTableRef): auto =
        ok("Feed Articles with query: " & $params)
      )
    )

  getArticle =
    get ->
      pathChunk("/api/articles") ->
        segment(proc(slug: string): auto =
      ok("Get Article: " & slug)
    )

  createArticle =
    post ->
      path("/api/articles") ->
        mandatoryAuth(proc(user: User): auto =
      jsonBody(proc(body: JsonNode): auto =
        ok("Create Article: " & $body)
      )
    )

  updateArticle =
    put ->
      pathChunk("/api/articles") ->
        segment(proc(slug: string): auto =
      mandatoryAuth(proc(user: User): auto =
        jsonBody(proc(body: JsonNode): auto =
          ok("Update Article: " & $body)
        )
      )
    )

  deleteArticle =
    delete ->
      pathChunk("/api/articles") ->
        segment(proc(slug: string): auto =
      mandatoryAuth(proc(user: User): auto =
        ok("Delete Article: " & slug)
      )
    )

let handler* =
  listArticles ~
  feedArticles ~
  getArticle ~
  createArticle ~
  updateArticle ~
  deleteArticle
