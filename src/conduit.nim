import asyncdispatch, asynchttpserver, httpcore

from rosencrantz import serve, complete

from routes/handler import handlers
from auth import headerPrefix, jwtSecret, failureHandler


# Auth config

headerPrefix("Token")

jwtSecret("secret")

failureHandler(complete(Http401, "Failed to authenticate!"))

# Start server

let server = newAsyncHttpServer();

waitFor server.serve(Port(8080), handlers)
