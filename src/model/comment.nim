import oids

type
  Commment* = ref object
    id: Oid
    createdAt: int64
    updatedAt: int64
    body: string
    author: Oid
