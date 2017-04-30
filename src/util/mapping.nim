import macros


macro mapNonNil*(source, dest: typed; fields: openArray[string]): untyped =
  result = newNimNode(nnkStmtList, fields)

  for field in fields:
    let
      srcCondIdent    = newIdentNode($source)
      srcAssignIdent  = newIdentNode($source)
      destAssignIdent = newIdentNode($dest)
      fieldCondIdent  = newIdentNode($field)
      fieldSrcIdent   = newIdentNode($field)
      fieldDestIdent  = newIdentNode($field)

    let
      cond = infix(newDotExpr(srcCondIdent, fieldCondIdent), "!=", newNilLit())

    let
      assign = newAssignment(newDotExpr(destAssignIdent, fieldDestIdent),
                             newDotExpr(srcAssignIdent, fieldSrcIdent))

    let ifStmt = newIfStmt((cond, newStmtList(assign)))

    result.add(ifStmt)

macro mapEvery*(source, dest: typed; fields: openArray[string]): untyped =
  result = newNimNode(nnkStmtList, fields)

  for field in fields:
    let
      srcAssignIdent  = newIdentNode($source)
      destAssignIdent = newIdentNode($dest)
      fieldSrcIdent   = newIdentNode($field)
      fieldDestIdent  = newIdentNode($field)

    let
      assign = newAssignment(newDotExpr(destAssignIdent, fieldDestIdent),
                             newDotExpr(srcAssignIdent, fieldSrcIdent))

    result.add(assign)
