args = { ... }
if #args != 1
  print("Expected column size")
  return

size = tonumber(args[1])
if size < 1
  print("Column size must be positive")
  return

depth = 0
unloaded = 0
collected = 0
xPos, zPos = 0, 0
xDir, zDir = 0, 1

local goTo
local refuel
local tryDig
 

unload = (keepOneFuelStack) ->
  print("Unloading items...")
  for n = 1, 16
    count = turtle.getItemCount(n)
    if count > 0
      turtle.select(n)
      drop = true
      if keepOneFuelStack and turtle.refuel(0)
        drop = false
        keepOneFuelStack = false
      if drop
        turtle.drop!
        unloaded += count
  collected = 0
  turtle.select(1)


returnSupplies = ->
  x, y, z, xd, zd = xPos, depth, zPos, xDir, zDir
  print("Returning to surface...")
  goTo(0, 0, 0, 0, -1)
  
  fuelNeeded = 2 * (x + y + z) + 1
  if not refuel(fuelNeeded)
    unload(true)
    print("Waiting for fuel")
    while not refuel(fuelNeeded)
      os.pullEvent("turtle_inventory")
  else
    unload(true)
  
  print("Resuming mining...")
  goTo(x, y, z, xd, zd)


collect = ->
  full = true
  totalItems = 0
  for n = 1, 16
    count = turtle.getItemCount(n)
    if count == 0
      full = false
    totalItems += count
  
  if totalItems > collected
    collected = totalItems
    if math.fmod(collected + unloaded, 50) == 0
      print("Mined " .. (collected + unloaded) .. " items.")
  
  if full
    print("No empty slots left.")
    return false
  true


refuel = (amount) ->
  fuelLevel = turtle.getFuelLevel!
  if fuelLevel == "unlimited"
    return true
  
  needed = amount or (xPos + zPos + depth + 2)
  if turtle.getFuelLevel! < needed
    fueled = false
    for n = 1, 16
      if turtle.getItemCount(n) > 0
        turtle.select(n)
        if turtle.refuel(1)
          while turtle.getItemCount(n) > 0 and turtle.getFuelLevel! < needed
            turtle.refuel(1)
          if turtle.getFuelLevel! >= needed
            turtle.select(1)
            return true
    turtle.select(1)
    return false
  
  true


tryForwards = ->
  if not refuel!
    print("Not enough fuel")
    returnSupplies!
  
  while not turtle.forward!
    if turtle.detect!
      if turtle.dig!
        if not collect!
          returnSupplies!
      else
        return false
    elseif turtle.attack!
      if not collect!
        returnSupplies!
    else
      sleep(0.5)
  
  xPos += xDir
  zPos += zDir
  true


tryDown = ->
  if not refuel!
    print("Not enough fuel")
    returnSupplies!
  
  while not turtle.down!
    if turtle.detectDown!
      if turtle.digDown!
        if not collect!
          returnSupplies!
      else
        return false
    elseif turtle.attackDown!
      if not collect!
        returnSupplies!
    else
      sleep(0.5)

  depth += 1
  if math.fmod(depth, 10) == 0
    print("Descended " .. depth .. " metres.")

  true


tryDigUp = ->
  tryDig(turtle.detectUp, turtle.digUp, turtle.attackUp)


tryDigDown = ->
  tryDig(turtle.detectDown, turtle.digDown, turtle.attackDown)


tryDig = (detectFunc, digFunc, attackFunc) ->
  if detectFunc!
    if digFunc!
      if not collect!
        returnSupplies!
    else
      return false
  elseif attackFunc!
    if not collect!
      returnSupplies!
  true


turnLeft = ->
  turtle.turnLeft!
  xDir, zDir = -zDir, xDir


turnRight = ->
  turtle.turnRight!
  xDir, zDir = zDir, -xDir


goTo = (x, y, z, xd, zd) ->
  while depth > y
    if turtle.up!
      depth -= 1
    elseif turtle.digUp! or turtle.attackUp!
      collect!
    else
      sleep(0.5)

  if xPos > x
    while xDir != -1
      turnLeft!
    while xPos > x
      if turtle.forward!
        xPos -= 1
      elseif turtle.dig! or turtle.attack!
        collect!
      else
        sleep(0.5)
  elseif xPos < x
    while xDir != 1
      turnLeft!
    while xPos < x
      if turtle.forward!
        xPos = xPos + 1
      elseif turtle.dig! or turtle.attack!
        collect!
      else
        sleep(0.5)
  
  if zPos > z
    while zDir != -1
      turnLeft!
    while zPos > z
      if turtle.forward!
        zPos -= 1
      elseif turtle.dig! or turtle.attack!
        collect!
      else
        sleep(0.5)
  elseif zPos < z
    while zDir != 1
      turnLeft!
    while zPos < z
      if turtle.forward!
        zPos += 1
      elseif turtle.dig! or turtle.attack!
        collect!
      else
        sleep(0.5)
  
  while depth < y
    if turtle.down!
      depth += 1
    elseif turtle.digDown! or turtle.attackDown!
      collect!
    else
      sleep(0.5)
  
  while zDir != zd or xDir != xd
    turnLeft!


if not refuel!
  print("Out of fuel")
  return

print("Excavating #{size}x#{size} column...")
turtle.select(1)
alternate = 0
done = false
while not done
  for n = 1, size
    if not (tryDigUp! and tryDigDown!)
      done = true
      break
    for m = 1, size - 1
      if not (tryForwards! and tryDigUp! and tryDigDown!)
        done = true
        break
    if done then break
    if n < size
      if math.fmod(n + alternate, 2) == 0
        turnLeft!
        if not tryForwards!
          done = true
          break
        turnLeft!
      else
        turnRight!
        if not tryForwards!
          done = true
          break
        turnRight!
  if done then break
  
  if size > 1
    if math.fmod(size, 2) == 0
      turnRight!
    else
      if alternate == 0
        turnLeft!
      else
        turnRight!
      alternate = 1 - alternate
  
  if not (tryDown! and tryDown! and tryDown!)
    done = true
    break

print("Excavation complete. Returning to surface...")
goTo(0, 0, 0, 0, -1)
unload(false)
goTo(0, 0, 0, 0, 1)
print("Mined " .. (collected + unloaded) .. " items total.")

