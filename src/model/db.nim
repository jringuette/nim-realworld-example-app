import asyncdispatch

import nimongo.bson, nimongo.mongo

export bson, mongo

var
  db*: AsyncMongo

proc connect*(host: string, port: uint16): Future[bool] =
  db = newAsyncMongo(host, port)

  return db.connect()
