--[[Author:Amuzet
List of GUIDs objects that will rotate
  {GUID,RotationOffset}
Some models may face in the wrong direction if
  they face opposite set their number to 180]]
RotateObjects={
  {'1da74a',180},
  {'c5139e',180},
  {'416410',0},
  {'669140',0},
  {'6da046',180},
  {'46460b',180}}

PointerObject= self
--Use below if PointerObject is different than self or Global
--PointerObject=getObjectFromGUID('ABCDEF')

--If you want PointerObject to face an Object in the list
--set the number for the index of it. Turn off with 0.
PointTo=4
--PointerObject's own RotationOffset
Offset=180

function onObjectPickUp(_, obj)check(obj)end
function onObjectDrop(  _, obj)check(obj)end
function onObjectHover( _, obj)check(obj)end

function check(obj)
  if not obj then return end
  local b=0
  for i,g in pairs(RotateObjects)do
    if not getObjectFromGUID(g[1])then--Object NoExist?
      table.remove(RotateObjects,i)--Delete from List
    elseif obj.getGUID()==g[1] then
      b=1
  end end
  if b>0 or obj==PointerObject then
    startLuaCoroutine(self,'whileDrop')
    doRotateTo()
  end
end

function whileDrop()
  while not PointerObject.resting do coroutine.yield(0)end
  doRotateTo()coroutine.yield(1)end

function doRotateTo()
  local rv={0,0,0}
  local p1=PointerObject.getPosition()
  for i,g in pairs(RotateObjects) do
    local o=getObjectFromGUID(g[1])
    local p2=o.getPosition()
    
    rv[2]=math.deg(math.atan2(
        p1[1]-p2[1],p1[3]-p2[3]))+g[2]
    o.setRotation(rv)
  end
  
  if PointTo<1 or PointTo>#RotateObjects then return end
  local g=RotateObjects[PointTo]
  local p2=getObjectFromGUID(g[1]).getPosition()
  rv[2]=math.deg(math.atan2(
      p2[1]-p1[1],p2[3]-p1[3]))+Offset
  PointerObject.setRotation(rv)
end