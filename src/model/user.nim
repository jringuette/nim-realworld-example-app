type
  User* = ref object
    id*: int64
    email*: string
    token*: string
    username*: string
    bio*: string
    image*: string

proc findById*(id: int64): (bool, User) =
  return (false, nil)
