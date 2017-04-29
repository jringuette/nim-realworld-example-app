import asyncdispatch, asynchttpserver, httpcore, logging

from rosencrantz import serve, complete

from routes/handler import handlers
from auth import headerPrefix, jwtSecret, failureHandler

# Log config

# Passing named arguments so it's much more readable
let consoleLogger = newConsoleLogger(
                      levelThreshold = lvlAll,
                      fmtStr = "$levelname [$datetime] ($appname) -- "
                    )

addHandler(consoleLogger)

# Auth config

headerPrefix("Token")

jwtSecret("secret")

failureHandler(complete(Http401, "Failed to authenticate!"))

# Start server

let server = newAsyncHttpServer();

waitFor server.serve(Port(8080), handlers)
