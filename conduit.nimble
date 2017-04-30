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

requires "nim >= 0.16.0",
         "rosencrantz >= 0.3.0",
         "jwt >= 0.0.1",
         "nimongo >= 0.1",
         "bcrypt >= 0.2.1",
         # Only a transitive dependency, but most be referenced here with #head
         # because the latest release is broken.
         "jsmn#head",
         "sam >= 0.1.3"
