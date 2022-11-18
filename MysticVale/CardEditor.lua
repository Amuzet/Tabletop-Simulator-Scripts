--MysticValeCardEditor
local zAdv =getObjectFromGUID('559bba')
local zAtch=getObjectFromGUID('a1e1d0')
local pCard=zAtch.getPosition()
local VaultPos={
Red   =getObjectFromGUID('abffe4').getPosition(),
Green =getObjectFromGUID('e810ae').getPosition(),
Blue  =getObjectFromGUID('c81ac0').getPosition(),
Yellow=getObjectFromGUID('c4380f').getPosition(),
Purple=getObjectFromGUID('95eac6').getPosition(),
White =getObjectFromGUID('c95ec1').getPosition()}
local URL=Global.getVar('URL')
local imageURLs  =Global.getTable('imageURLs')
local AbilityURLs=Global.getTable('AbilityURLs')

function Vault(o,c)o.setPositionSmooth(VaultPos[c],false,false)end
function Z()self.reload()end
function onLoad()
  self.addContextMenuItem('Reload',Z)
  for k,p in pairs(VaultPos)do
    VaultPos[k][2]=p[2]+1 end
  pCard[2]=self.getPosition()[2]+1
self.createButton({tooltip='Attach attachment decal to base card',width=300,height=3,position={0,0,0.83},click_function='Attach',function_owner=self})
self.createButton({tooltip='Remove attachment decals from base card',width=300,height=3,position={-1.24,0,0.83},click_function='RemoveAttachment',function_owner=self})
self.createButton({tooltip='Attach only cards ability',height=400,width=3,position={0.57,0,0},click_function='JustAbility',function_owner = self})end

function RemoveAttachment()
 for _,c in ipairs(zAtch.getObjects())do
  if c.type=='Card'then c.setDecals({})
end end end
--Ability,Card
function AddAbility(a,c)local n=a.getName()
 c.addDecal({name=n,url=URL..AbilityURLs[n],
  position={0.535,0.3,0},rotation={90,180,0},scale={0.32,2.91,1}})end

--Attachment,Card,posZ
function AddAdvancement(a,c,z)local n=a.getName()
  c.addDecal({name=n,url=URL..imageURLs[n],
    position={0,0.3,z},rotation={90,180,0},scale={2.145,0.906,1}})
  if a.hasTag('Ability')then AddAbility(a,c)end
end

function JustAbility(o,c)
  for _,Card in ipairs(zAtch.getObjects())do
    if Card.hasTag('Base')and Card.type=='Card'then
      Card.setRotation(self.getRotation())
      Card.setPosition(pCard)

  for j,oAbl in ipairs(zAdv.getObjects())do
    if oAbl.hasTag('Ability')and oAbl.type=='Card'then
    AddAbility(oAbl,Card)
    Vault(oAbl,c)break end
end end end end

function Attach(o,c)
  for _,Card in ipairs(zAtch.getObjects())do print(Card.getName())
    if Card.hasTag('Base')and Card.type=='Card'then
      Card.setRotation(self.getRotation())
      Card.setPosition(pCard)

 for j,oAdv in ipairs(zAdv.getObjects())do print(oAdv.getName())
  if oAdv.type=='Card'then

    if oAdv.hasTag('AdvancementT')then AddAdvancement(oAdv,Card,-1)end
    if oAdv.hasTag('AdvancementM')then AddAdvancement(oAdv,Card,0) end
    if oAdv.hasTag('AdvancementB')then AddAdvancement(oAdv,Card,1) end
    if oAdv.hasTag('LegT')then AddAdvancement(oAdv,Card,-0.5)end
    if oAdv.hasTag('LegB')then AddAdvancement(oAdv,Card,0.5) end
    
    Vault(oAdv,c)break end
end end end end
