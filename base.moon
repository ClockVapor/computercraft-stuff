export *

-- Position of the turtle, relative to where it started.
x, y, z = 0, 0, 0

-- Direction the turtle is currently facing.
direction = "+x"

-- When the turtle is out of fuel and it can't find any fuel in its inventory, should it sit still and wait for more?
-- If false, it will return to its starting point instead.
waitForFuel = false

-- Items that can be used as fuel for the turtle.
fuelSources = { "minecraft:coal", "minecraft:charcoal", "minecraft:log", "minecraft:log2" }

-- Blocks that are okay for the turtle to simply move through without digging.
okayNotToDig = { "minecraft:water", "minecraft:flowing_water", "minecraft:lava", "minecraft:flowing_lava" }

getX = -> x
getY = -> y
getZ = -> z
isWaitForFuel = -> waitForFuel
setWaitForFuel = (wait) -> waitForFuel = wait
getDirection = -> direction


forward = (n) ->
  n = n or 1
  move(n, turtle.forward)


dig = ->
  _dig(turtle.inspect, turtle.dig)


forwardWithDig = (n) ->
  n = n or 1
  for _ = 1, n
    if not dig! or not forward!
      print "error: forwardWithDig(): Failed."
      return false
  true


back = (n) ->
  n = n or 1
  move(-n, turtle.back)


-- Has the turtle move n steps using the given turtle movement function.
move = (n, turtleFunc) ->
  n = n or 1
  for i = 1, math.abs(n)
    if not refuel! or not turtleFunc!
      print "error: move(): Failed."
      return false
    if n >= 0
      x += getForwardX!
      z += getForwardZ!
    else
      x -= getForwardX!
      z -= getForwardZ!
  true


up = (n) ->
  n = n or 1
  moveVertical(n, turtle.up)


digUp = ->
  _dig(turtle.inspectUp, turtle.digUp)


upWithDig = (n) ->
  n = n or 1
  for _ = 1, n
    if not digUp! or not up!
      print "error: upWithDig(): Failed."
      return false
  true


down = (n) ->
  n = n or 1
  moveVertical(-n, turtle.down)


digDown = ->
  _dig(turtle.inspectDown, turtle.digDown)


downWithDig = (n) ->
  n = n or 1
  for _ = 1, n
    if not digDown! or not down!
      print "error: downWithDig(): Failed."
      return false
  true


_dig = (inspectFunc, digFunc) ->
  inspected, item = inspectFunc!
  result = inspected and (digFunc! or isOkayNotToDig(item.name)) or not inspected
  if not result
    print "error: _dig(): Failed to dig #{item.name}."
  result


moveVertical = (n, turtleFunc) ->
  n = n or 1
  for i = 1, math.abs n
    if not refuel! or not turtleFunc!
      print "error: moveVertical(): Failed."
      return false
    if n >= 0
      y += 1
    else
      y -= 1
  true


getForwardX = (n) ->
  n = n or 1
  if direction == "+x"
    n
  elseif direction == "-x"
    -n
  elseif direction == "+z"
    0
  elseif direction == "-z"
    0


getForwardZ = (n) ->
  n = n or 1
  if direction == "+x"
    0
  elseif direction == "-x"
    0
  elseif direction == "+z"
    n
  elseif direction == "-z"
    -n
  

turnRight = (n) ->
  n = n or 1
  for _ = 1, n
    if turtle.turnRight!
      if direction == "+x"
        direction = "+z"
      elseif direction == "-x"
        direction = "-z"
      elseif direction == "+z"
        direction = "-x"
      elseif direction == "-z"
        direction = "+x"
    else
      print "error: turnRight(): Failed."


turnLeft = (n) ->
  n = n or 1
  for _ = 1, n
    if turtle.turnLeft!
      if direction == "+x"
        direction = "-z"
      elseif direction == "-x"
        direction = "+z"
      elseif direction == "+z"
        direction = "+x"
      elseif direction == "-z"
        direction = "-x"
    else
      print "error: turnLeft(): Failed."


moveBack = ->
  moveTo(0, 0, 0)


moveTo = (dx, dy, dz) ->
  if x > dx then turnToFace("-x")
  elseif x < dx then turnToFace("+x")
  forwardWithDig(math.abs(dx - x))

  if z > dz then turnToFace("-z")
  elseif z < dz then turnToFace("+z")
  forwardWithDig(math.abs(dz - z))

  if y > dy then downWithDig(y - dy)
  elseif y < dy then upWithDig(dy - y)
  

getFuelToMoveBack = ->
  math.abs(x) + math.abs(y) + math.abs(z)


-- If the turtle's fuel level is less than or equal to what it needs to return to its starting point, attempts to
-- refuel from its inventory. If no fuel is found, the turtle will either wait for more to show up, or it will
-- return to its starting point.
refuel = ->
  result = true
  if turtle.getFuelLevel! <= getFuelToMoveBack!
    oldSlot = turtle.getSelectedSlot!
    if waitForFuel
      while not selectWhere((item) -> isFuelSource(item.name))
        print "warn: refuel(): No fuel sources. Will loop and wait..."
        sleep(10)
    else
      if not selectWhere((item) -> isFuelSource(item.name))
        print "error: refuel(): No fuel sources. Returning to starting point."
        moveBack!
        return false
    result = turtle.refuel(1) and turtle.select(oldSlot)
    if not result then print "error: refuel(): While refueling and selecting old slot."
  result


-- Has the turtle select the first item in its inventory that matches the given predicate.
selectWhere = (pred) ->
  for i = 1, 16
    item = turtle.getItemDetail(i)
    if item
      if pred(item)
        turtle.select(i)
        return true
  print "error: selectWhere(): No item matching predicate was found."
  false


-- Has the turtle turn to face the given direction.
turnToFace = (dir) ->
  if dir == "+x"
    if direction == "-x"
      turnRight 2
    elseif direction == "+z"
      turnLeft!
    elseif direction == "-z"
      turnRight!
  elseif dir == "-x"
    if direction == "+x"
      turnRight 2
    elseif direction == "+z"
      turnRight!
    elseif direction == "-z"
      turnLeft!
  elseif dir == "+z"
    if direction == "+x"
      turnRight!
    elseif direction == "-x"
      turnLeft!
    elseif direction == "-z"
      turnRight 2
  elseif dir == "-z"
    if direction == "+x"
      turnLeft!
    elseif direction == "-x"
      turnRight!
    elseif direction == "=z"
      turnRight 2


-- Gets the opposite direction of the given direction.
oppositeDir = (dir) ->
  if dir == "+x"
    "-x"
  elseif dir == "-x"
    "+x"
  elseif dir == "+z"
    "-z"
  elseif dir == "-z"
    "+z"


isFuelSource = (name) ->
  isInTable(fuelSources, name)


isOkayNotToDig = (name) ->
  isInTable(okayNotToDig, name)


isInTable = (table, item) ->
  for _, v in pairs(table)
    if item == v then return true
  false


dropInventoryExceptFuelSources = ->
  for i = 1, 16
    turtle.select(i)
    item = turtle.getItemDetail!
    if not isFuelSource(item.name)
      turtle.drop!


isFull = ->
  for i = 1, 16
    if turtle.getItemSpace(i) > 0
      return false
  true


canPickUp = (item) ->
  for i = 1, 16
    inventoryItem = turtle.getItemDetail(i)
    if inventoryItem == nil or item.name == inventoryItem.name and turtle.getItemSpace(i) > 0
      return true
  false

