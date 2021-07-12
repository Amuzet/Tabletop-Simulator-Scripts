--By Amuzet
mod_name,version='Wayfarer Boosters',0.1
local api='https://edhrec-json.s3.amazonaws.com/en/commanders/%s.json'
local wayfarer='http://wayfarerbooster.duckdns.org:8080/api/booster/generateBoosterPlain?themeUrl=commanders/%s'
local commander='atraxa-praetors-voice'
local decklist=''
local cardback=''

local lastKnownImporter=false
function findImporter()
  if lastKnownImporter then return lastKnownImporter end
  for _,o in pairs(getAllObjects())do
    if o.getName():find('Card Importer')then
      lastKnownImporter=o return o end end return false end
function passToImporter(o,c,a,data)
  local Importer=findImporter()
  local Modes=Importer.getVar('MODES')
  if not Importer then
    Player[c].broadcast('Card Importer not found!')
  elseif not Modes then
    Player[c].broadcast('Card Importer does not support Quick Import!\nUpdate to 1.82 or Later!')
  elseif Importer then
    local t={position=self.getPosition(),
      player=Player[c].steam_id,
      color=Player[c].color,
      full=data,
      mode=data:gsub('(http%S+)',''):match('(%S+)'),
      name=data:gsub('(http%S+)',''):gsub(' ',''),
      url=data:match('(http%S+)')}
    t.position[2]=t.position[2]+1
    
    if t.mode then
      local m,n=Modes:lower():find(t.mode:lower())
      if m then
        t.mode=Modes:sub(m,n)
        t.name=t.name:lower():gsub(t.mode:lower(),'',1)
      else t.mode=nil end end
    
    if t.name:len()<1 or not t.name:find('[%w_]')then t.name='island'else t.name=t.name:gsub('%s','')end
    Importer.call('Importer',t)end end

function onCollisionEnter(info)
  local o=info.collision_object
  --[[if o.type=='Deck'then
    local tblDeck={}
    for _,v in pairs(o.getObjects())do
      tblDeck[v.name]=(tblDeck[v.name] or 0)+1
    end
    decklist=''
    for m,n in pairs(tblDeck)do
      decklist=decklist..'\n'..n..' '..m
    end
  else]]
  if o.type=='Card'then
    local n=o.getName()
    if n:find('Creature')and not n:find('Legendary')then
      return broadcastToAll(n..' is not a Commander')
    elseif n==''then printToAll('Card not named!')end
    n=n:gsub('\n.*',''):lower():gsub('%W+','-')
    if commander==n then
      printToAll(n..' Already listed!')
    elseif n:len()>1 then
      commander=n
      printToAll('Loading EDHREC Tribes for: '..n)
      cardback=o.getCustomObject().back
      WebRequest.get(api:format(commander),wrCommander)
    else
      error('Commander name Malformated!')
    end
  end
end
--BUTTONTABLES
local B=setmetatable({d=0.1,position={-1,0.1,-1.5},width=4000,height=500,font_size=500,scale={0.1,0.1,0.1},tooltip='',label='',click_function='',function_owner=self
    },{__call=function(b,t)local fn='click_'..t.value:gsub('%W','')
    self.setVar(fn,function(o,c,a)
        passToImporter(o,c,a,'back '..cardback)
        WebRequest.get(wayfarer:format(commander..t['href-suffix']),function(rw)
            Notes.addNotebookTab({body=t.value..'\n'..rw.text,title=rw.url:match('commanders/(.+)')})
            passToImporter(o,c,a,'deck')end)end)
    b.label,b.click_function,b.tooltip,b.position[3]=t.value,fn,t['href-suffix'],b.position[3]+b.d
    self.createButton(b)end})
local NamePlate={}
for k,v in pairs(B)do NamePlate[k]=v end
NamePlate.position={0,0,-1.6}
NamePlate.scale={0.2,0.2,0.2}
NamePlate.width=8000
NamePlate.click_function='N'
function N()end
function onLoad()NamePlate.label='Wayfarer Booster Generator'self.createButton(NamePlate)end
function wrCommander(wr)
  self.clearButtons()
  B.position[3]=-1.5
  NamePlate.label=commander
  self.createButton(NamePlate)
  if not wr.text then return error('URL did not return information:\n'..wr.url)end
  local _,x=wr.text:find('"tribelinks":{')
  local tribes=wr.text:sub(x)
  _,y=tribes:find('}]}')
  local themes=tribes:sub(1,y)
  local json=JSON.decode(themes)
  local types='themes'
  if not json.themes then types='budget'end
  printToAll('EDHREC Tribes Loaded for: '..commander)
  for _,theme in pairs(json[types])do B(theme)end end
--EOF