from ../model/user import User


type
  Profile* = ref object
    username*: string
    bio*: string
    image*: string
    following*: bool

proc profileFromUser(user: User): Profile =
  result.new
  result.username = user.username
  result.bio = user.bio
  result.image = user.image
  result.following = false

proc getByUsername(username: String): Profile =
  discard
