# Package

version       = "0.1.0"
author        = "Attila Bagossy"
description   = "Nim implementation of the RealWorld Conduit app"
license       = "MIT"

# Additional settings

bin     = @["conduit"]
binDir  = "build"
skipExt = @["nim"]

# Dependencies

requires "nim >= 0.16.0"

requires "rosencrantz >= 0.3.0"

# Tasks

task server, "Run the Nim Conduit backend":
  --forceBuild
  --run
  --path: "."

  --hints: off
  --stacktrace: on
  --linetrace: on
  
  setCommand "compile", "conduit.nim"
