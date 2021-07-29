local Owner='Teal'
local Zone=Global.getTable('Zone')[Owner]
function delay(N,t)local p={function_name=N,identifier=N..t.color..'PA',parameters=t,delay=2}Timer.destroy(p.identifier)Timer.create(p)end
--BUTTONTABLES
function N()self.reload()end
local B=setmetatable({d=3,color={0,0,0},font_color=self.getColorTint(),position={-16,1,0},width=2200,height=600,font_size=500,scale={0.6,0.6,0.6},tooltip='',label='',click_function='N',function_owner=self
    },{__call=function(b,l,p,cf)
    if p then b.position=p else b.position[1]=b.position[1]+b.d end
    b.label,b.click_function=l,cf or l:gsub('%A+','')
    self.createButton(b)end})

--When the cards touch together they combine
--Context menu to uncombine them
--If all else fails have a tile to build cards At
function DISCARD(o,c,a)
  if c~=Owner then return end
  local z=getObjectFromGUID(Zone.discard)
  if not z then return end
  for _,o in pairs(z.getObjects())do
    if('CardDeck'):find(o.type)then
      o.setRotation({0,0,0})
      o.setPosition(getObjectFromGUID(Zone.hidden).getPosition())
    end
  end
  delay('shuffleDiscard',{color=Owner})
end
function shuffleDiscard(t)
  local z=getObjectFromGUID(Zone.deck)
  for _,o in pairs(z.getObjects())do
    if o.type=='Deck'then
      o.shuffle()
    end
  end
end
function DECK(o,c,a)
  if c~=Owner then return end
  local h=getObjectFromGUID(Zone.hidden)
  if not h then return end
  if Zone.revealed then
    h.translate({0,-1,0})
  else
    h.translate({0,1,0})
    broadcastToAll(Player[c].steam_name..' will be searching their deck!',Color[c])
  end
  Zone.revealed=not Zone.revealed
end
function nextPosition()
  --{42.49, 1.06, -23.50}
  --{41.50, 1.11, -23.50}
  --{29.50, 1.20, -23.54}
  local z=getObjectFromGUID(Zone.row)
  local p=z.getPosition()
  local off,min=p.x,100
  if off~=0 then off=0.5 end
  for _,o in pairs(z.getObjects())do
    if o.type=='Card'then
      local n=o.getPosition()
      n.x=math.floor(n.x+0.1)+off
      min=math.min(min,n.x)
      o.setPosition(n)
    end
  end
  if min==100 then min=p.x+13 end
  p.x=min
  return p
end
function TOP(O,c,a)
  if c~=Owner then return end
  --move previous top deck to row
  local z=getObjectFromGUID(Zone.deck)
  local p={position=getObjectFromGUID(Zone.top).getPosition(),rotation={0,0,180}}
  local check=false
  for _,o in pairs(getObjectFromGUID(Zone.top).getObjects())do
    if o.type=='Card'then
      o.setPosition(nextPosition())
    end
  end
  for _,o in pairs(z.getObjects())do
    if o.type=='Deck'then
      check=o.takeObject(p)
    elseif o.type=='Card'then
      o.setRotation(p.rotation)
      check=o.setPosition(p.position)
    end
    if O and check then
      broadcastToAll(Player[c].steam_name..' reveals the next card on top!')
      break
    end
  end
end
function MANA(o,c,a)end
function VICTORY(o,c,a)
  
end
function CENTER(o,c,a)Player[c].lookAt({position=self.getPosition(),pitch=85,yaw=180,distance=15})end
function onLoad()
  self.setColorTint(Owner)
  B('DISCARD')
  B('^DECK^')
  B('^ TOP ^')
  B.scale={0.9,0.9,0.9}
  B.d=5
  B('CENTER',{0,1,0})
  B('MANA')
  B('VICTORY')
  addContextMenuItem('View '..Owner,function(c)CENTER(nil,c)end)
  for _,o in pairs(getObjectFromGUID(Zone.deck).getObjects())do
    if o.type=='Deck'then
      o.shuffle()
    end
  end
  TOP(nil,Owner)
end