from asyncdispatch import Future, newFuture, complete, fail


proc completed*[T](val: T): Future[T] =
  result = newFuture[T]()

  result.complete(val)

proc failed*[T](ex: ref Exception): Future[T] =
  result = newFuture[T]()

  result.fail(ex)
