type
  User* = ref object
    id*: uint64
    email*: string
    username*: string
    bio*: string
    image*: string

proc findById*(id: uint64): (bool, User) =
  return (false, nil)
