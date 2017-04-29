from rosencrantz import `~`

from article/article  import handler
from article/comment  import handler
from article/favorite import handler

let handler* =
  comment.handler ~
  favorite.handler ~
  article.handler
