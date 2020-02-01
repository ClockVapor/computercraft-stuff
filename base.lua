x, y, z = 0, 0, 0
direction = "+x"
waitForFuel = false
fuelSources = {
  "minecraft:coal",
  "minecraft:charcoal",
  "minecraft:log",
  "minecraft:log2"
}
okayNotToDig = {
  "minecraft:water",
  "minecraft:flowing_water",
  "minecraft:lava",
  "minecraft:flowing_lava"
}
getX = function()
  return x
end
getY = function()
  return y
end
getZ = function()
  return z
end
isWaitForFuel = function()
  return waitForFuel
end
setWaitForFuel = function(wait)
  waitForFuel = wait
end
getDirection = function()
  return direction
end
forward = function(n)
  n = n or 1
  return move(n, turtle.forward)
end
dig = function()
  return _dig(turtle.inspect, turtle.dig)
end
forwardWithDig = function(n)
  n = n or 1
  for _ = 1, n do
    if not dig() or not forward() then
      print("error: forwardWithDig(): Failed.")
      return false
    end
  end
  return true
end
back = function(n)
  n = n or 1
  return move(-n, turtle.back)
end
move = function(n, turtleFunc)
  n = n or 1
  for i = 1, math.abs(n) do
    if not refuel() or not turtleFunc() then
      print("error: move(): Failed.")
      return false
    end
    if n >= 0 then
      x = x + getForwardX()
      z = z + getForwardZ()
    else
      x = x - getForwardX()
      z = z - getForwardZ()
    end
  end
  return true
end
up = function(n)
  n = n or 1
  return moveVertical(n, turtle.up)
end
digUp = function()
  return _dig(turtle.inspectUp, turtle.digUp)
end
upWithDig = function(n)
  n = n or 1
  for _ = 1, n do
    if not digUp() or not up() then
      print("error: upWithDig(): Failed.")
      return false
    end
  end
  return true
end
down = function(n)
  n = n or 1
  return moveVertical(-n, turtle.down)
end
digDown = function()
  return _dig(turtle.inspectDown, turtle.digDown)
end
downWithDig = function(n)
  n = n or 1
  for _ = 1, n do
    if not digDown() or not down() then
      print("error: downWithDig(): Failed.")
      return false
    end
  end
  return true
end
_dig = function(inspectFunc, digFunc)
  local inspected, item = inspectFunc()
  local result = inspected and (digFunc() or isOkayNotToDig(item.name)) or not inspected
  if not result then
    print("error: _dig(): Failed to dig " .. tostring(item.name) .. ".")
  end
  return result
end
moveVertical = function(n, turtleFunc)
  n = n or 1
  for i = 1, math.abs(n) do
    if not refuel() or not turtleFunc() then
      print("error: moveVertical(): Failed.")
      return false
    end
    if n >= 0 then
      y = y + 1
    else
      y = y - 1
    end
  end
  return true
end
getForwardX = function(n)
  n = n or 1
  if direction == "+x" then
    return n
  elseif direction == "-x" then
    return -n
  elseif direction == "+z" then
    return 0
  elseif direction == "-z" then
    return 0
  end
end
getForwardZ = function(n)
  n = n or 1
  if direction == "+x" then
    return 0
  elseif direction == "-x" then
    return 0
  elseif direction == "+z" then
    return n
  elseif direction == "-z" then
    return -n
  end
end
turnRight = function(n)
  n = n or 1
  for _ = 1, n do
    if turtle.turnRight() then
      if direction == "+x" then
        direction = "+z"
      elseif direction == "-x" then
        direction = "-z"
      elseif direction == "+z" then
        direction = "-x"
      elseif direction == "-z" then
        direction = "+x"
      end
    else
      print("error: turnRight(): Failed.")
    end
  end
end
turnLeft = function(n)
  n = n or 1
  for _ = 1, n do
    if turtle.turnLeft() then
      if direction == "+x" then
        direction = "-z"
      elseif direction == "-x" then
        direction = "+z"
      elseif direction == "+z" then
        direction = "+x"
      elseif direction == "-z" then
        direction = "-x"
      end
    else
      print("error: turnLeft(): Failed.")
    end
  end
end
moveBack = function()
  return moveTo(0, 0, 0)
end
moveTo = function(dx, dy, dz)
  if x > dx then
    turnToFace("-x")
  elseif x < dx then
    turnToFace("+x")
  end
  forwardWithDig(math.abs(dx - x))
  if z > dz then
    turnToFace("-z")
  elseif z < dz then
    turnToFace("+z")
  end
  forwardWithDig(math.abs(dz - z))
  if y > dy then
    return downWithDig(y - dy)
  elseif y < dy then
    return upWithDig(dy - y)
  end
end
getFuelToMoveBack = function()
  return math.abs(x) + math.abs(y) + math.abs(z)
end
refuel = function()
  local result = true
  if turtle.getFuelLevel() <= getFuelToMoveBack() then
    local oldSlot = turtle.getSelectedSlot()
    if waitForFuel then
      while not selectWhere(function(item)
        return isFuelSource(item.name)
      end) do
        print("warn: refuel(): No fuel sources. Will loop and wait...")
        sleep(10)
      end
    else
      if not selectWhere(function(item)
        return isFuelSource(item.name)
      end) then
        print("error: refuel(): No fuel sources. Returning to starting point.")
        moveBack()
        return false
      end
    end
    result = turtle.refuel(1) and turtle.select(oldSlot)
    if not result then
      print("error: refuel(): While refueling and selecting old slot.")
    end
  end
  return result
end
selectWhere = function(pred)
  for i = 1, 16 do
    local item = turtle.getItemDetail(i)
    if item then
      if pred(item) then
        turtle.select(i)
        return true
      end
    end
  end
  print("error: selectWhere(): No item matching predicate was found.")
  return false
end
turnToFace = function(dir)
  if dir == "+x" then
    if direction == "-x" then
      return turnRight(2)
    elseif direction == "+z" then
      return turnLeft()
    elseif direction == "-z" then
      return turnRight()
    end
  elseif dir == "-x" then
    if direction == "+x" then
      return turnRight(2)
    elseif direction == "+z" then
      return turnRight()
    elseif direction == "-z" then
      return turnLeft()
    end
  elseif dir == "+z" then
    if direction == "+x" then
      return turnRight()
    elseif direction == "-x" then
      return turnLeft()
    elseif direction == "-z" then
      return turnRight(2)
    end
  elseif dir == "-z" then
    if direction == "+x" then
      return turnLeft()
    elseif direction == "-x" then
      return turnRight()
    elseif direction == "=z" then
      return turnRight(2)
    end
  end
end
oppositeDir = function(dir)
  if dir == "+x" then
    return "-x"
  elseif dir == "-x" then
    return "+x"
  elseif dir == "+z" then
    return "-z"
  elseif dir == "-z" then
    return "+z"
  end
end
isFuelSource = function(name)
  return isInTable(fuelSources, name)
end
isOkayNotToDig = function(name)
  return isInTable(okayNotToDig, name)
end
isInTable = function(table, item)
  for _, v in pairs(table) do
    if item == v then
      return true
    end
  end
  return false
end
dropInventoryExceptFuelSources = function()
  for i = 1, 16 do
    turtle.select(i)
    local item = turtle.getItemDetail()
    if not isFuelSource(item.name) then
      turtle.drop()
    end
  end
end
isFull = function()
  for i = 1, 16 do
    if turtle.getItemSpace(i) > 0 then
      return false
    end
  end
  return true
end
canPickUp = function(item)
  for i = 1, 16 do
    local inventoryItem = turtle.getItemDetail(i)
    if inventoryItem == nil or item.name == inventoryItem.name and turtle.getItemSpace(i) > 0 then
      return true
    end
  end
  return false
end
