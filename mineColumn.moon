os.loadAPI "base"

local digLine, digSquare, digColumn, moveToNextLine, moveToNextSquare, dumpIntoChest
columnSize = 5
moveToNextLineTurnRight = true
startDir = base.getDirection!


digColumn = (n) ->
  result = true
  while result
    result = digSquare(n)
    if result
      moveToNextSquare!
    else
      print "error: digColumn(): Failed to dig square."
  if not result
    base.moveBack!
  result


moveToNextSquare = ->
  base.turnRight(2)
  result = base.downWithDig! and base.downWithDig!
  if not result
    print "error: moveToNextSquare(): Failed to move down."
  result


digSquare = (n) ->
  result = true
  for _ = 1, n - 1
    result = digLine(n)
    if not result
      print "error: digSquare(): Failed to digLine()."
      break
    result = moveToNextLine!
    if not result
      print "error: digSquare(): Failed to moveToNextLine()."
      break
  if result
    result = digLine(n)
  result


moveToNextLine = ->
  result = true
  if moveToNextLineTurnRight then base.turnRight!
  else base.turnLeft!
  result = base.forwardWithDig!
  if result
    if moveToNextLineTurnRight then base.turnRight!
    else base.turnLeft!
    moveToNextLineTurnRight = not moveToNextLineTurnRight
  else
    print "error: moveToNextLine(): Failed to move forward."
  result


digLine = (n) ->
  result = true

  for _ = 1, n - 1
    inspected, item = turtle.inspectDown!
    if inspected and not base.canPickUp(item)
      dumpIntoChest!
    result = base.digDown!
    if not result
      print "error: digLine(): Failed to digDown()."
      break

    inspected, item = turtle.inspect!
    if inspected and not base.canPickUp(item)
      dumpIntoChest!
    result = base.forwardWithDig!
    if not result
      print "error: digLine(): Failed to forwardWithDig()."
      break

  if result
    inspected, item = turtle.inspectDown!
    if inspected and not base.canPickUp(item)
      dumpIntoChest!
    result = base.digDown!

  result


dumpIntoChest = ->
  x, y, z = base.getX!, base.getY!, base.getZ!
  direction = base.getDirection!
  base.moveBack!
  base.turnToFace(base.oppositeDir(startDir))
  base.dropInventoryExceptFuelSources!
  base.moveTo(x, y, z)
  base.turnToFace(direction)


digColumn(columnSize)

