import asyncdispatch, asynchttpserver, httpcore, logging

from rosencrantz import serve, complete

from routes/index import handler
from auth import headerPrefix, jwtSecret, failureHandler
from model/db import connect

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

# DB setup

let connected = waitFor connect("127.0.0.1", 27017)

if connected:
  info("Succesfully connected to the database")
else:
  fatal("Could not connect to the database")

  quit(-1)

# Start server

let server = newAsyncHttpServer();

waitFor server.serve(Port(8080), handler)