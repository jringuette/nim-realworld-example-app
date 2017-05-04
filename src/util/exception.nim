from strutils import splitLines

proc readMsg*(err: ref Exception): string =
  ## Returns the error message without the stack trace. Please see
  ## https://github.com/nim-lang/Nim/issues/4999
  ## Should only be used for async error handling.
  if err.msg == nil:
    nil
  else:
    err.msg.splitLines()[0]
