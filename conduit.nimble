# Package

version       = "0.1.0"
author        = "Attila Bagossy"
description   = "Nim implementation of the RealWorld Conduit app"
license       = "MIT"

# Additional settings

bin     = @["conduit"]
binDir  = "build"
srcDir  = "src"
skipExt = @["nim"]


# Dependencies

requires "nim >= 1.0.0",
         "rosencrantz >= 0.4.3",
         "jwt >= 0.2.0",
         "nimongo#head",
         "bcrypt >= 0.2.1",
         "sam >= 0.1.11"

task server, "Run the server":
    exec("build/conduit")