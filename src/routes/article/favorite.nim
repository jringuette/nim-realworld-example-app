# Although system is implicitly imported, we now want to
# explicitly exclude the delete procedure.
import system except delete

import rosencrantz

import ../../model/user
from ../../auth import mandatoryAuth


let
  favoriteArticle =
    post ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          pathChunk("/favorite") ->
            mandatoryAuth do (user: User) -> auto:
              ok("Favorite Article: " & slug)

  unfavoriteArticle =
    delete ->
      pathChunk("/api/articles") ->
        segment do (slug: string) -> auto:
          pathChunk("/favorite") ->
            mandatoryAuth do (user: User) -> auto:
              ok("Unfavorite Article: " & slug)

let handler* =
  favoriteArticle ~
  unfavoriteArticle
