from rosencrantz import `~`, notFound

import articles
import profiles
import users
import tags


let notFoundHandler =
  notFound("Page not found")

let handler* =
  articles.handler ~
  profiles.handler ~
  users.handler ~
  tags.handler ~
  notFoundHandler
