import asynchttpserver, asyncdispatch, tables, json

import rosencrantz

proc unprocessableEntity*(errors: Table[string, string]): Handler =
  var resultJson = %{ "errors": newJObject() }

  for key, value in errors.pairs():
    resultJson["errors"][key] = %value

  complete(HttpCode(422), $resultJson)
