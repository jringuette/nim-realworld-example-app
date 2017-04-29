# Although system is implicitly imported, we now want to
# explicitly exclude the delete procedure.
import system except delete
# Same for JSON, delete needs to be excluded.
import json except delete
# Needed by queryString
import tables, strtabs

import rosencrantz

import ../../model/user
from ../../auth import mandatoryAuth, optionalAuth


let
  listArticles =
    get ->
      path("/api/articles") ->
        optionalAuth do (user: User) -> auto:
          queryString do (params: StringTableRef) -> auto:
            ok("List Articles with query: " & $params)

  feedArticles =
    get ->
      path("/api/articles/feed") ->
        mandatoryAuth do (user: User) -> auto:
          queryString do (params: StringTableRef) -> auto:
            ok("Feed Articles with query: " & $params)

  getArticle =
    get ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          ok("Get Article: " & slug)

  createArticle =
    post ->
      path("/api/articles") ->
        mandatoryAuth do (user: User) -> auto:
          jsonBody do (body: JsonNode) -> auto:
            ok("Create Article: " & $body)

  updateArticle =
    put ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          mandatoryAuth do (user: User) -> auto:
            jsonBody do (body: JsonNode) -> auto:
              ok("Update Article: " & $body)

  deleteArticle =
    delete ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          mandatoryAuth do (user: User) -> auto:
            ok("Delete Article: " & slug)

let handler* =
  listArticles ~
  feedArticles ~
  getArticle ~
  createArticle ~
  updateArticle ~
  deleteArticle
