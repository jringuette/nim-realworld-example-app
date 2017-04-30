import asynchttpserver, asyncdispatch, tables, json

import rosencrantz

import terminal


type
  JsonValidator* = proc(body: JsonNode): Table[string, string]
  ParamlessHandler* = proc: Handler

type
  RequestRef = ref Request

template isEmpty(t: Table): bool =
  t.len == 0

proc validateBody*(validator: JsonValidator, body: JsonNode, p: ParamlessHandler): Handler =
  proc inner(req: RequestRef, ctx: Context): Future[Context] {.async.} =
    let validationResult = validator(body)

    let handler =
      if validationResult.isEmpty():
        p()
      else:
        unprocessableEntity(validationResult)

    return await handler(req, ctx)

  inner
