local Refill={AugB=1.5,AugM=0,AugT=-1.5,Teirs={'bba7da','863e24','d0521a'},
  {'114d0a','4f9bd5','938f92'},{'e8582f','895e2c','ae06d9'},{'dbd430','50ab0d','bc979c'},
  {'ce4e45','5e99ca','7b06bc'},{'4b1a9a','5ec6aa','e9d76b'},{'d4fe1e','98721c','23f169'}}
local Vales={Level={'41dae4','e923bf'},
  {'326930','0bf0c2','8fe662','1b2875'},{'9f88ca','ec00c9','f6ce20','57afaa'},
  {'af872a','fe1c3e','b2a95b','c87c5f'},{'847433','6efbe3','b9010c','68aad2'}}
local Crafter={Base='b50526',
  {AugB='10a481',AugM='75e960',AugT='eabb8e'},{AugB='6406f8',AugM='61906e',AugT='56430b'}}
local ref={
  ['Mystic Vale']={'aeb4b5','7a1605','b81997'},
  ['Vale Of The Wild']={'9e9e57','c29627','676afd'}}
Zone={
  White ={vp=0,discard='2cdb4a',hidden='b0b2ed',deck='db353b',top='9c0323',row='14e0b3',obj='a2eba5'},
  Red   ={vp=0,discard='9e8586',hidden='4b2e3e',deck='139104',top='8b7e13',row='6d9ee2',obj='aed3d0'},
  Yellow={vp=0,discard='35b2a0',hidden='e32430',deck='be4d11',top='71f974',row='d0dd9c',obj='ede46c'},
  Blue  ={vp=0,discard='ff307d',hidden='44eb65',deck='78043d',top='400c0a',row='0c6171',obj='efa574'},
  Teal  ={vp=0,discard='3a7ff2',hidden='b2b9cf',deck='6b8ff2',top='2fb6ba',row='9c8a98',obj='3f2fa7'},
  Green ={vp=0,discard='d4d24e',hidden='c9ea92',deck='36fc6e',top='36b6de',row='6f129d',obj='7ce701'}}

local B=setmetatable({d=3,color={0,0,0},font_color=Color.Pink,position={-13,1,0},width=2200,height=700,font_size=500,scale={0.6,0.6,0.6},tooltip='',label='',click_function='N',function_owner=self
    },{__call=function(b,o,l,t,p,cf)
    if p then b.position=p else b.position[1]=b.position[1]+b.d end
    b.label,b.tooltip,b.font_color,b.click_function=l,t or '',o.getColorTint(),cf or l:gsub('%A+','')
    o.createButton(b)end})

function delay(N,t)local p={function_name=N,identifier=N..t.color..'PA',parameters=t,delay=2}Timer.destroy(p.identifier)Timer.create(p)end
function Aug(t)for _,a in pairs(t)do if Refill[a]then return a end end end
function pos(t)return Refill[Aug(t)or'AugM']end
function N()self.reload()end
function CENTER(o,c,a)Player[c].lookAt({position=o.getPosition(),pitch=85,yaw=180,distance=15})end
--BUTTONTABLES
--Import the Fertile Soils
--[[For Applying Banner Decals
local Decal={AugB=-3.3,AugM=0,AugT=3.3,name='',url='',
  position={0.53,0,0},rotation={90,180,0},scale={0.35,10,70}}
function DecalApplication(o,u,n)
  if not o.hasAnyTag()then return end
  if o.getDecals()then return end
  Decal.name=n or 'Banner'
  Decal.url=u
  for _,a in pairs(o.getTags())do
    if Decal[a]then
      Decal.position[3]=Decal[a]
      break
    end
  end
  o.addDecal(Decal)
end]]


function DECK(O,c,a)
  if c~=O.getDescription()then return end
  local z=getObjectFromGUID(Zone[c].deck)
  local empty=true
  for _,o in pairs(z.getObjects())do
    if('CardDeck'):find(o.type)then empty=false end end
  if not empty then return end
  for _,o in pairs(getObjectFromGUID(Zone[c].discard).getObjects())do
    if('CardDeck'):find(o.type)then
      o.setRotation({0,0,180})
      o.setPosition(z.getPosition())
    end
  end
  delay('shuffleDiscard',{color=c})
end
function shuffleDiscard(t)
  local z=getObjectFromGUID(Zone[t.color].deck)
  for _,o in pairs(z.getObjects())do
    if o.type=='Deck'then o.shuffle()end end
end
function DISCARD(O,c,a)
  if c~=O.getDescription() then return end
  local z=getObjectFromGUID(Zone[c].discard)
  for _,o in pairs(getObjectFromGUID(Zone[c].row).getObjects())do
    if('CardDeck'):find(o.type)then o.setPosition(z.getPosition())end
  end
end
function nextPosition(c)
  --{42.49, 1.06, -23.50}
  --{41.50, 1.11, -23.50}
  --{29.50, 1.20, -23.54}
  local z=getObjectFromGUID(Zone[c].row)
  local p=z.getPosition()
  local off,min=p.x,100
  if off~=0 then off=0.5 end
  for _,o in pairs(z.getObjects())do
    if o.type=='Card'then
      local n=o.getPosition()
      n.x=math.floor(n.x+0.1)+off
      min=math.min(min,n.x)
      p.y=math.max(p.y,n.y)
      o.setPosition(n)
    end
  end
  if min==100 then min=p.x+14 end
  p.x=min-1
  p.y=p.y+0.05
  return p
end
function TOP(O,c,a)
  if c~=O.getDescription()then return end
  --move previous top deck to row
  local z=getObjectFromGUID(Zone[c].deck)
  local t=getObjectFromGUID(Zone[c].top)
  local p={position=t.getPosition(),rotation={0,0,0}}
  local check=false
  for _,o in pairs(t.getObjects())do
    if o.type=='Card'then
      o.setLock(true)
      o.setPosition(nextPosition(c))end end
  for _,o in pairs(z.getObjects())do
    if o.type=='Deck'then check=o.takeObject(p)
    elseif o.type=='Card'then
      o.setRotation(p.rotation)
      check=o.setPosition(p.position)
    end
    if check then
      broadcastToAll(Player[c].steam_name..' reveals the next card on top!')
      return
    end
  end
  DECK(O,c,a)
end
function MANA(O,c,a)
  if c~=O.getDescription()then return end
end
victoryPool=33
function VICTORY(O,c,a)
  if c~=O.getDescription()then return end
  --Grab and return points to centeral pool
  local n=1
  if a then n=-1 end
  Zone[c].vp=Zone[c].vp+n
  victoryPool=victoryPool-n
  O.editButton({index=#O.getButtons()-1,label=Zone[c].vp})
end
function onLoad()
 getObjectFromGUID(Refill.Teirs[2]).createButton({
  label='Start\nGame',click_function='startGame',function_owner=self,
  width=3000,height=2000,font_size=900,scale={0.5,0.5,0.5}})
 for k,t in pairs(Zone)do
  local o=getObjectFromGUID(t.obj)
  o.setDescription(k)
  o.setColorTint(Color[k])
  o.interactable=false
  B(o,'DISCARD','Discard card in field',{-13,1,0})
  B(o,'DECK','Reshuffle discard')
  B(o,'TOP','Place top deck into field')
 end
 B.scale={0.9,0.9,0.9}
 B.d=5
 for k,t in pairs(Zone)do
  local o=getObjectFromGUID(t.obj)
  B(o,'CENTER','Recenter Camera',{0,1,0})
  B(o,'MANA','Track current mana\nClick to increase\nRight Click to decrease')
  addContextMenuItem('View '..k,function(c)CENTER(o,c)end)
  for _,d in pairs(getObjectFromGUID(t.deck).getObjects())do
    if d.type=='Deck'then d.shuffle()end end
 end
 B.scale={1,1,1}
 B.width=1000
 B.height=1000
 B.font_size=1000
 for k,t in pairs(Zone)do
  B(getObjectFromGUID(t.obj),'VICTORY','Track Victory point Tokens\nClick to increase\nRight Click to decrease',{0,1,-3})
 end
 for _,o in pairs(getObjectsWithTag('Uninteractable'))do
  o.interactable=false
end end

function startGame()
 getObjectFromGUID(Refill.Teirs[2]).clearButtons()
 for i=1,3 do
  local p=getObjectFromGUID(Refill.Teirs[i]).getPosition()
  for k,v in pairs(ref)do
   local o=getObjectFromGUID(v[i])
   o.setPosition(p)
   o.interactable=false
   o.setRotation({0,0,180})
  end
 end
 for i,g in ipairs(Vales.Level)do
  getObjectFromGUID(g).shuffle()end
 Timer.create({delay=1,function_name='shuffleAdvancements',identifier='shuffle'})
end
function shuffleAdvancements()
 for i=1,3 do
  local z=getObjectFromGUID(Refill.Teirs[i])
  for _,o in pairs(z.getObjects())do
   if o.shuffle()and i==1 then
    while o.getQuantity()>9+(#getSeatedPlayers()*3)do
     o.takeObject().destroy()
 end end end end
 Turns.enable=true
 getObjectFromGUID(Refill.Teirs[2]).createButton({
  label='Refill\nMarket',click_function='refillMarket',function_owner=self,
  width=3000,height=2000,font_size=900,scale={0.5,0.5,0.5},position={0,2,0}})
end
function returnToMarket(o,c,a)
  local teir=Aug(o.getTags())
  for i,v in ipairs(Refill)do
    if #getSeatedPlayers()<5 and i>3 then break end
    for _,g in pairs(v)do
      local z=getObjectFromGUID(g)
      if not z then return end
      local empty=true
      for _,o in pairs(z.getObjects())do
        if o.type=='Card'then empty=false end
      end
      if empty then
        p.position=z.getPosition()
        local aug=false
        --MAP i->j:123456->123123
        for j=((i-1)%3)+1,3 do
          for _,t in pairs(getObjectFromGUID(Refill.Teirs[j]).getObjects())do
            if t.type=='Deck'then
              aug=t.takeObject(p)
              Timer.create({delay=1,parameters={aug},function_name='shiftAdvancementTier',identifier='m'..aug.getGUID()})
            elseif t.type=='Card'then
              p.position[3]=p.position[3]+pos(t.getTags())
              aug=t
              aug.setPosition(p.position)
            end
            if aug then break end
          end
          if aug then break end
        end
        aug.setLock(true)
        aug.createButton({
            width=2000,height=1000,font_size=400,label='Buy\nAdvancement',tooltip=aug.getName(),
            scale={0.2,0.1,0.3},position={0.6,1,-0.5},click_function='addAdvancement',function_owner=self})
  end end end
end
function refillMarket()
  local p={position={},rotation={0,0,0}}
  for i,v in ipairs(Refill)do
    if #getSeatedPlayers()<5 and i>3 then break end
    for _,g in pairs(v)do
      local z=getObjectFromGUID(g)
      if not z then return end
      local empty=true
      for _,o in pairs(z.getObjects())do
        if o.type=='Card'then empty=false end
      end
      if empty then
        p.position=z.getPosition()
        local aug=false
        --MAP i->j:123456->123123
        for j=((i-1)%3)+1,3 do
          for _,t in pairs(getObjectFromGUID(Refill.Teirs[j]).getObjects())do
            if t.type=='Deck'then
              aug=t.takeObject(p)
              Timer.create({delay=1,parameters={aug},function_name='shiftAdvancementTier',identifier='m'..aug.getGUID()})
            elseif t.type=='Card'then
              p.position[3]=p.position[3]+pos(t.getTags())
              aug=t
              aug.setPosition(p.position)
            end
            if aug then break end
          end
          if aug then break end
        end
        aug.setLock(true)
        aug.createButton({
            width=2000,height=1000,font_size=400,label='Buy\nAdvancement',tooltip=aug.getName(),
            scale={0.2,0.1,0.3},position={0.6,1,-0.5},click_function='addAdvancement',function_owner=self})
  end end end
  p.rotation[2]=90
  for i,v in ipairs(Vales)do
    if #getSeatedPlayers()<5 and i>2 then break end
    for _,g in pairs(v)do
      local z=getObjectFromGUID(g)
      if not z then return end
      local empty=true
      for _,o in pairs(z.getObjects())do
        if o.type=='Card'then empty=false end
      end
      if empty then
        p.position=z.getPosition()
        getObjectFromGUID(Vales.Level[((i-1)%2)+1]).takeObject(p)
  end end end
end
function addAdvancement(o,c,a)
  local t=Aug(o.getTags())
  local z=getObjectFromGUID(Crafter[1][t])
  local empty=true
  for _,b in pairs(z.getObjects())do
    if b.type=='Card'then empty=false end end
  for _,card in pairs(getObjectFromGUID(Crafter.Base).getObjects())do
    if card.type=='Card'and t==Aug(card.getTags())then empty=false end end
  if not empty then
    return printToAll('Advancement slot currently filled! '..t,Color[c])end
  o.editButton({index=0,label='Return to\nMarket',click_function='returnToMarket'})
  o.setPosition(z.getPosition())
end
--CardCrafting
function completeCard(o,c,a)
  o.clearButtons()
  local augments={}
  for _,card in pairs(getObjectFromGUID(Crafter.Base).getObjects())do
    if card.type=='Card'then augments.card=card end end
  if not augments.card then return printToAll('No Base Card Found!',Color[c])end
  for k,v in pairs(Crafter[1])do
    for i=1,2 do
      local z=getObjectFromGUID(Crafter[i][k])
      for _,aug in pairs(z.getObjects())do
        if aug.type=='Card'then
          local p=aug.getPosition()
          p[1]=augments.card.getPosition()[1]
          aug.setPosition(p)
          table.insert(augments,aug)
  end end end end
  Timer.create({parameters=augments,delay=1,function_name='attachAdvancements',identifier='shuffle'})
end
cardBeingEdited=''
cardEditButton={label='Begin Editing Card',click_function='unattachAdvancements',function_owner=self,
        position={0,1,2},scale={0.5,0.5,0.5},width=5000,height=500,font_size=500}
function onObjectEnterZone(z,o)
  if z.getGUID()~='b50526'then
  elseif o.getGUID()==cardBeingEdited then
  elseif o.type=='Card'and cardBeingEdited==''then
    cardBeingEdited=o.getGUID()
    cardEditButton.label='Begin Editing Card'
    cardEditButton.click_function='unattachAdvancements'
    o.createButton(cardEditButton)
    o.setLock(true)
    o.interactable=false
    o.setPosition(z.getPosition())
  end
end
function unattachAdvancements(o,c,a)
  o.clearButtons()
  if a then return moveAside(o)end
  local empty=true
  for _,card in pairs(getObjectFromGUID(Crafter.Base).getObjects())do
    if card.type=='Card'and card~=o then empty=false end end
  if not empty then return printToAll('There is already a Base Card being edited!',Color[c])end
    local z=getObjectFromGUID(Crafter.Base)
    o.setLock(true)
    o.setRotation(z.getRotation())
    o.setPosition(z.getPosition())
    o.highlightOn(Color[c],10)
  --removeAttachments
  for _,g in pairs(o.removeAttachments())do
    local z=getObjectFromGUID(Crafter[1][Aug(g.getTags())])
    g.setRotation(z.getRotation())
    g.setPosition(z.getPosition())
    g.setScale({0.45,1,0.45})
  end
  cardEditButton.label='Finish Editing Card'
  cardEditButton.click_function='completeCard'
  o.createButton(cardEditButton)
end
function moveAside(o)o.setPosition({6.5,1,11})o.setLock(false)o.interactable,cardBeingEdited=true,''end
function moveBackToField(o,c)
  o.setPosition(getObjectFromGUID(Zone[c].row))
  o.setLock(false)
  o.interactable,cardBeingEdited=true,''
end
function attachAdvancements(t)for _,o in ipairs(t)do t.card.addAttachment(o)end moveAside(t.card)end
function shiftAdvancementTier(t)t[1].translate({0,0,pos(t[1].getTags())})end
turnCount=0
turnPoints=0
function onPlayerTurn()
  --check for difference in point totals at end of turn!
  turnCount=turnCount+1
  if turnCount==1 then return end
  refillMarket()
end
--[[function onCollisionEnter(t)
  local o=t.collision_object
  if o.type=='Card'then
    DecalApplication(o,'https://www.yucata.de/Games/MysticVale/images/ca_SporelingReclaimer.jpg')
  end
  if o.type~='Card'or o.hasAnyTag()then return end
  o.addTag('L1')
  local c={position={30,2,0},snap_to_grid=true}
  o.clone(c).addTag('AugT')
  o.clone(c).addTag('AugB')
  o.addTag('AugM')
end]]