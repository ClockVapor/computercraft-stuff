os.loadAPI("base")
local digLine, digSquare, digColumn, moveToNextLine, moveToNextSquare, dumpIntoChest
local columnSize = 5
local moveToNextLineTurnRight = true
local startDir = base.getDirection()
digColumn = function(n)
  local result = true
  while result do
    result = digSquare(n)
    if result then
      moveToNextSquare()
    else
      print("error: digColumn(): Failed to dig square.")
    end
  end
  if not result then
    base.moveBack()
  end
  return result
end
moveToNextSquare = function()
  base.turnRight(2)
  local result = base.downWithDig() and base.downWithDig()
  if not result then
    print("error: moveToNextSquare(): Failed to move down.")
  end
  return result
end
digSquare = function(n)
  local result = true
  for _ = 1, n - 1 do
    result = digLine(n)
    if not result then
      print("error: digSquare(): Failed to digLine().")
      break
    end
    result = moveToNextLine()
    if not result then
      print("error: digSquare(): Failed to moveToNextLine().")
      break
    end
  end
  if result then
    result = digLine(n)
  end
  return result
end
moveToNextLine = function()
  local result = true
  if moveToNextLineTurnRight then
    base.turnRight()
  else
    base.turnLeft()
  end
  result = base.forwardWithDig()
  if result then
    if moveToNextLineTurnRight then
      base.turnRight()
    else
      base.turnLeft()
    end
    moveToNextLineTurnRight = not moveToNextLineTurnRight
  else
    print("error: moveToNextLine(): Failed to move forward.")
  end
  return result
end
digLine = function(n)
  local result = true
  for _ = 1, n - 1 do
    local inspected, item = turtle.inspectDown()
    if inspected and not base.canPickUp(item) then
      dumpIntoChest()
    end
    result = base.digDown()
    if not result then
      print("error: digLine(): Failed to digDown().")
      break
    end
    inspected, item = turtle.inspect()
    if inspected and not base.canPickUp(item) then
      dumpIntoChest()
    end
    result = base.forwardWithDig()
    if not result then
      print("error: digLine(): Failed to forwardWithDig().")
      break
    end
  end
  if result then
    local inspected, item = turtle.inspectDown()
    if inspected and not base.canPickUp(item) then
      dumpIntoChest()
    end
    result = base.digDown()
  end
  return result
end
dumpIntoChest = function()
  local x, y, z = base.getX(), base.getY(), base.getZ()
  local direction = base.getDirection()
  base.moveBack()
  base.turnToFace(base.oppositeDir(startDir))
  base.dropInventoryExceptFuelSources()
  base.moveTo(x, y, z)
  return base.turnToFace(direction)
end
return digColumn(columnSize)
