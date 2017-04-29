import asyncdispatch, asynchttpserver

from rosencrantz import serve

from conduit/routes/handler import handlers


let server = newAsyncHttpServer();

waitFor server.serve(Port(8080), handlers)
