--Mana Market
mod_name,version='ManaMarket',0.1
author,WorkshopID,GITURL='76561198045776458','',''
coauthor='76561197990874079'--Adamf9898

M,N=math.random(1,5),0
Format='f:standard'
incX,incY=2.34,3.23
rot=self.getRotation()
pos=self.getPosition()
--------------------------------------------------------------------------------
-- Editable Values
--------------------------------------------------------------------------------
Rows=5
--PerRarity
Max={ManaMarket=15,common=15,uncommon=15,rare=9,w=3,u=3,b=3,r=3,g=3}
--AmmountsPerPlayer
Min={ManaMarket=15,common= 5,uncommon= 4,rare=1,w=1,u=1,b=1,r=1,g=1}

--supports custom functions with a position{x,y,z} argument
Generate={
--Do Not Edit ManaMarket unless you understand
ManaMarket=function(p)
  local o=temp.takeObject({position=p,rotation=rot})
  Wait.condition(function()
    local p=o.getPosition()
    p[2]=p[2]+1
    for i=1,M-1 do
      o.clone({position=p})end
end,function()return(o.resting and not o.loading_custom)end,99)end,
--Otherwise ensure Strings
--ensure atleast 1 pile of each color
w='r:common+id>=w',
u='r:common+id>=u',
b='r:common+id>=b',
r='r:common+id>=r',
g='r:common+id>=g',
common  ='r:common',
uncommon='r:uncommon',
rare    ='r>=rare',
}

-------------------------------------------------------------------------------
--  Quick Importer Code Addapted to ManaMarket
-------------------------------------------------------------------------------
local lastKnownImporter=nil
function findImporter()
  if lastKnownImporter then return lastKnownImporter end
  for _,o in pairs(getObjects())do
    if o.getVar('mod_name')=='Card Importer'and o.getVar('MODES')then
      lastKnownImporter=o return o end end return false end

Host=Player.getPlayers()[1]

function passToImporter(data,pos)
  local Importer=findImporter()
  local Modes=Importer.getVar('MODES')

  if  not Importer then broadcastToAll('Card Importer not found!')
  elseif not Modes then broadcastToAll('Card Importer does not support Quick Import!\nUpdate to 1.82 or Later!')

  elseif Importer then
    local t={
      position=pos,
      player=Host.steam_id,
      color=Host.color,
      full=data,
      mode=data:gsub('(http%S+)',''):match('(%S+)'),
      name=data:gsub('(http%S+)',''):gsub(' ',''),
      url=data:match('(http%S+)')}
    
    if t.mode then
      local m,n=Modes:lower():find(t.mode:lower())
      if m then
        t.mode=Modes:sub(m,n)
        t.name=t.name:lower():gsub(t.mode:lower(),'',1)
      else t.mode=nil end end
    
    if t.name:len()<1 or not t.name:find('[%w_]')then t.name='blank card'else t.name=t.name:gsub('%s','')end
    Importer.call('Importer',t)end end

-------------------------------------------------------------------------------
--  ManaMarket Setup Code
-------------------------------------------------------------------------------
function Z()self.reload()end
function onLoad()
  self.addContextMenuItem('Reload',Z)
  self.setRotation({0,180,0})
  self.createInput({value=Format,input_function='setFormat',function_owner=self,
      width=6500,height=200,font_size=150,position={15,1,-1},scale={2,2,2},
      tooltip='This value will be used in limiting the cards in the market.\nExamples:\nf:standard\nis:frenchvanilla'})
  self.createButton({click_function='start',function_owner=self,position={15,1,4},
    tooltip='Click to place each card.',width=4000,height=999,font_size=99,scale={3,3,3},
    label='^ ^ ^ ^\nRows: '..Rows})end
function onDrop()self.setRotation({0,150,0})end

function setFormat(o,c,i,s)
  if not s then
    self.setInput({index=0,value=i:gsub('%s','+')})
  end
end

function spawn(s,p)
  Wait.time(function()
    passToImporter('random ?q='..Format..'+'..s,p)
  end,N*3)
end

function makePiles()
  for _,o in pairs(getObjects())do
    if o.type=='Card'and o.getName():find('CMC')then
      local c={position=o.getPosition()}
      c.position[2]=c.position[2]+2
      o.clone(c)
      o.clone(c)
    end
  end
end

function newPos(i)
  return{pos.x+math.ceil(i/Rows)*incX,2,pos.z-(i-1)%Rows*incY}
end
--Setup Code
function start()
  if not findImporter()then broadcastToAll('Importer Not Found\nPlease load one in')return end
  self.setLock(true)
  self.clearButtons()
  self.clearInputs()

  rot=self.getRotation()
  pos=self.getPosition()
  temp=self.takeObject({position={0,20,0}})
  temp.shuffle()
  temp.setLock(true)

  --GenerateAtPositions
  local t,x={},#getSeatedPlayers()
  for k,v in pairs(Generate)do
    local n=Min[k]*x
    if k=='ManaMarket'then n=Min[k]end
  
    for i=1,math.min(n,Max[k])do
      if type(v)=='string'then N=N+1
        spawn(v,newPos(N))else v(newPos(i))end
    end
    if k=='ManaMarket'then
      pos.x=pos.x+math.ceil(n/Rows)*incX
    end
  end

  Wait.time(makePiles,N*4)

  temp.destroy()
end
--EOF