import rosencrantz

import ../model/user

var
  secret: string
  failHandler: Handler

type
  UserAcceptingHandler* = proc(user: User): Handler

proc jwtSecret*(): string =
  secret

proc jwtSecret*(newSecret: string) =
  secret = newSecret

proc failureHandler*(handler: Handler) =
  failHandler = handler

proc mandatoryAuth*(p: UserAcceptingHandler): Handler =
  nil

proc optionalAuth*(p: UserAcceptingHandler): Handler =
  nil
