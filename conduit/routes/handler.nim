from rosencrantz import `~`, notFound

from articles import handler
from profiles import handler
from users    import handler
from tags     import handler

let notFoundHandler = 
  notFound("Page not found")

let handlers* = 
  articles.handler ~
  profiles.handler ~
  users.handler ~
  tags.handler ~
  notFoundHandler
