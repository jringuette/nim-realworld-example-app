import oids

type
  Article* = ref object
    slug*: string
    title: string
    description*: string
    body*: string
    tagList*: seq[string]
    createdAt*: int64
    updatedAt*: int64
    favoritesCount*: int
    author*: Oid
    comments*: seq[Oid]
