--Gravity Distortion Bag
function encodeObj(o)
--o.registerCollisions()
o.setDescription('SECTOR')
o.addContextMenuItem('Lock It',LockThis,true)
o.addContextMenuItem('-->> Rotate -->>',Clockwise,true)
o.addContextMenuItem('<<-- Rotate <<--',Counter,true)
end
function RE()self.reload()end
function onLoad()
  Y=self.getPosition().y
  self.addContextMenuItem('reload',RE)end
function onObjectLeaveContainer(c,o)
  if c==self then encodeObj(o)end end
function onObjectDrop(c,o)
  if o.getDescription()=='SECTOR'then
    LockThis(c,o.getPosition(),o)
end end

function ROT(o,y)
  local p=o.getPosition();p.y=Y
  o.rotate({0,y,0})
  o.setPosition(p)
end
function Clockwise(c,p,o)ROT(o,36)end
function Counter(c,p,o)ROT(o,-36)end
function LockThis(c,p,o)
  o.setLock(true)
  o.unregisterCollisions()
  ROT(o,0)
  o.setRotation({0,0,0})
end

--[[function onObjectCollisionEnter(ro,ci)
  log(ci)
  if ci.collision_object.getDescription()==ro.getDescription()then
    LockThis(nil,nil,ro)
    alignSector(ro,ci.collision_object.getPosition())
end end

local SNAP={
--OVERLAP
{0,1,4.50},
{2.64,1,3.64},
{4.28,1,1.39},
--EDGE
{1.64,1,5.06},
{4.30,1,3.13},
{5.32,1,0}}

function alignSector(o,p)
  local P=o.getPosition()
  local relativeP={math.abs(P[1]-p[1]),1,math.abs(P[3]-p[3])}
  local destination={0,1,0}
  
  --use relativeP to determine it's propper snap
  for i,t in pairs(SNAP)do
    if  relativeP[1]>0.5+t[1]
    and relativeP[1]<t[1]-0.5
    and relativeP[3]<t[3]-0.5
    and relativeP[3]>0.5+t[3]then
      destination=t
      break end end
  
  if destination[1]==destination[3]then return end
  
  relativeP={P[1]-p[1],1,P[3]-p[3]}
  if relativeP[1]<0 then destination[1]=-destination[1]end
  if relativeP[3]<0 then destination[3]=-destination[3]end
  destination[2]=Y
  o.setPosition(destination)
end]]
