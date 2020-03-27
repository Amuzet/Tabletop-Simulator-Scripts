--By Amuzet
mod_name = 'Portable Booster Generator'
version = 1.5
author = '76561198045776458'
WorkshopID='https://steamcommunity.com/sharedfiles/filedetails/?id=1880174681'
self.sticky = false
self.setName(mod_name..' '..version)
self.setRotation({0,0,0})
--[[Known issues
  Morningtide Boosters lost a rare.
]]
--Variables
Basic, Cards, Count, Tic, TAG, Back = false, {}, 0, 0.14, '', 'https://orig00.deviantart.net/f7ea/f/2016/040/2/f/playing_cards_template___wooden_back_by_toomanypenguins-d9r55w3.png'

--[[Class Card]]
local Card=setmetatable({n=0,json='',position=self.getPosition(),snap_to_grid=true
  },{__call=function(t,c)assert(c,'No Card Passed to Card()')if c.name then t.n=t.n+1
    t.json=string.format('{"Name":"Card","Transform":{"posX":0,"posY":0,"posZ":0,"rotX":0,"rotY":0,"rotZ":180,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},"Nickname":"%s","Description":"%s","CardID":%i00,"CustomDeck":{"%i":{"FaceURL":"%s","BackURL":"%s","NumWidth":1,"NumHeight":1,"BackIsHidden":true}}}',c.name,c.oracle,t.n,t.n,c.face,Back)
    spawnObjectJSON(t)end end})
--[[Other Stuff]]
function setBack()
  local img=self.getDescription()
  if img:find('http')then Back=img end
  self.setDescription(Back)end
--[[Class Button]]
local Button=setmetatable({function_owner=self,click_function='loadSet',label='Load xyz',width=2100,height=2100,font_size=199,position={0,0.5,0},scale={0.2,1,0.2}},{__call=function(t)
  toggleMenu(false)
  Count=getUI('tooltip'):match('%d+')
  if not Cards[TAG]then broadcastToAll('[dc143c]Warning: [4682b4]Server will stutter loading [-]'..Count..' Cards')end
  t.click_function='loadSet'
  t.tooltip='Click to load '..getUI('text')..' set.\n\nRight Click to reset module and choose another set'
  t.label='Keep this area is clear\n\n\nLoad '..TAG..' Set\n\n'..getUI('text')..'\n\n\nRight click to reset'
  self.createButton(t)end})
--[[UI Menu Toggle]]
function toggleMenu(bool) for _,v in ipairs({'expansion','core','masters','draft_innovation'})do self.UI.setAttribute(v,'active',bool)end end
function resetModule()if TAG~=''then
    broadcastToAll('Unlocking & Reseting Module')
    TAG=''
    local p=self.getPosition()
    self.setPosition({p[1],p[2]+0.5,p[3]})
    self.clearButtons()
    self.setLock(false)
    toggleMenu(true)
end end
--[[Set Loading Logic]]
function setLoad(tag,count)
  self.editButton({index=0,font_size=400})
  printToAll('Loading '..getUI('text')..' '..count)
  for i=1,count do Wait.time(function()
    local url='https://api.scryfall.com/cards/'..tag..'/'..i..'/en'
    self.editButton({index=0,label=tag..'\n'..i,})
    WebRequest.get(url,function(wr)initCard(wr)end)
  end,i*Tic)end end
--[[Card Rarity Slot]]
function initCard(wr)
  local card=JSON.decode(wr.text)
  if card.name then else return false end
  local tbl={face='',oracle='',rarity='',name=''}
  --Get entire Oracle text of Card
  if card.card_faces then
    local cf=card.card_faces
    tbl.name=cf[1].name..'\n'..cf[1].type_line:gsub('%S*',function(a)return'['..string_to_color(a)..']'..a..'[-]'end)..'\n'..card.cmc..'CMC'
    for _,f in ipairs(cf)do tbl.oracle=tbl.oracle..'\n'..setOracle(f)end
  else
    tbl.oracle=setOracle(card)
    tbl.name=card.name..'\n'..card.type_line:gsub('%S*',function(a)return'['..string_to_color(a)..']'..a..'[-]'end)..'\n'..card.cmc..'CMC'
  end
  --Find front face image of Card
  if card.image_uris then tbl.face=card.image_uris.normal:gsub('%?.*','')
  else tbl.face=card.card_faces[1].image_uris.normal:gsub('%?.*','')end
  --Change quality to small if no Highres Image is avaliable
  if not card.highres_image then tbl.face=tbl.face:gsub('normal','small')end
  --Plansewalker Decks/Boxtoppers and Custom Rarity Slots
  local slot=false
  if card.type_line:find('Basic')and not card.type_line:find('Snow')then
    tbl.rarity='BASICS'if not Basic then Basic=true end
  elseif sGen[TAG]and sGen[TAG][1]==card.set then
    tbl.rarity='SPECIAL'
  --Cards Past the last Forest or Ante Cards
  elseif Basic or(card.oracle_text and card.oracle_text:find('playing for ante'))then
    tbl.rarity='OVERCOUNT'
  elseif sRty[TAG]and sRty[TAG](card)then
    tbl.rarity,slot=sRty[TAG](card)
  else
    tbl.rarity=card.rarity:upper()
    if tbl.rarity=='COMMON'and #card.colors==1 then
      local clr=card.colors[1]
      if Cards[TAG][clr]then
        Cards[TAG][clr]=Cards[TAG][clr]+1
      else
        Cards[TAG][clr]=1
  end end end
  if slot then
    if Cards[TAG][slot]then table.insert(Cards[TAG][slot],tbl)
    else Cards[TAG][slot]={tbl}end end
  if Cards[TAG][tbl.rarity]then table.insert(Cards[TAG][tbl.rarity],tbl)
  else Cards[TAG][tbl.rarity]={tbl}end end
function loadSet(obj,clr,alt)
  if Player[clr].admin then
    self.editButton({index=0,click_function='doNothing'})
    if alt then resetModule()else
      --[[Spawn Set/Cards]]
      function setOracle(c)local n=''
        if c.power then n=c.power..'/'..c.toughness else n=c.loyalty or' 'end
        return string.format('%s %s\n%s\n[b]%s[/b]',c.type_line, c.mana_cost, c.oracle_text, n):gsub('\"',"'")
      end
      if Cards[TAG]then Count=0
      else Cards[TAG]={W=0,U=0,B=0,R=0,G=0};setLoad(TAG,Count)end
      Wait.time(function()if sGen[TAG]and Count~=0 then
          local s=sGen[TAG]
          setLoad(s[1],s[2])
          Wait.time(setButton,(1+s[2])*Tic)
        else setButton()end end,(1+Count)*Tic)
end end end
function setButton()
  self.editButton({index=0,
      label = 'Make 12 Boosters\n\n'..getUI('text'),
      tooltip = 'Click to make 12 '..getUI('text')..' Boosters.\n\nRight Click to reset module and choose another set',
      click_function = 'clickMB',
      font_size=199,})
end
function clickMB(o,c,a)
  setBack()
  if a then
    resetModule()
  else
    self.clearButtons()
    makeBoosters()
    Wait.time(resetModule,14)
  end
end
--[[Makeing the boosters]]
function makeBoosters(a)
  setBack()
  self.setLock(true)
  Basic=false
  --Amount, xIncrement, zIncrement
  local n,pos=a or 12,self.getPosition()
  pos={pos[1]-3.6,pos[2]+0.5,pos[3]-3.4}
  if Cards[TAG]['BASICS']then Card.position={pos[1]-3.6,pos[2],pos[3]-3.4}
    for k,c in pairs(Cards[TAG]['BASICS'])do Card(c)end end
  
  local pack={COMMON=11,UNCOMMON=3,RARE=1,MYTHIC=8}
  if sPak[TAG]then for k,v in pairs(sPak[TAG])do pack[k]==v end end
  
  for i=0,n-1 do Wait.time(function()local p={}for k,v in pairs(pack)do p[k]=v end
    createBooster({pos[1]+2.4*(i%4),pos[2],pos[3]+3.4*math.floor(i/4)},p)end,i)end
end
--[[Pack Generation Overrides]]
function createBooster(pos,pack)
  Card.position=pos
  
  local function perPackSlot(slot)
    local c=Cards[TAG][slot][math.random(1,#Cards[TAG][slot])]
    Card(c)
    pack[c.rarity:upper()]=pack[c.rarity:upper()]-1
  end
  --Check that a Set has Mythics
  if Cards[TAG]['MYTHIC']and pack.MYTHIC>0 then
    pack.RARE,pack.MYTHIC=mythicDist(pack.MYTHIC)
  elseif not Cards[TAG]['MYTHIC']then pack.MYTHIC=0 end
  --Double Faced / Conspiracy
  if pack.EXTRA then
    local eS=math.random(1,pack.EXTRA[4]+pack.EXTRA[3]+pack.EXTRA[2]+pack.EXTRA[1])
    if eS>pack.EXTRA[3]+pack.EXTRA[2]+pack.EXTRA[1]then pack.EXTRACOMMON=1
    elseif eS>pack.EXTRA[2]+pack.EXTRA[1]then pack.EXTRAUNCOMMON=1
    elseif eS>pack.EXTRA[1]then pack.EXTRARARE=1
    else pack.EXTRAMYTHIC=1 end
  --Guarentied Per Pack Slots
  elseif pack.PARTNER      then perPackSlot('PARTNER')
  elseif pack.LEGENDARY    then perPackSlot('LEGENDARY')
  elseif pack.PLANESWALKER then perPackSlot('PLANESWALKER')end
  --Attempt to stop duplicate Commons
  local genNums=setmetatable({},{__call=function(t,n)for i,v in ipairs(t)do if n==v then return i end end return false end})
  
  for r,n in pairs(pack)do
    if not Cards[TAG][r]then log(TAG..' Rarity Not Found:'..r)
    elseif r=='SPECIAL'then
      if math.random(1,n)==1 or n==1 then
        Card(Cards[TAG][r][math.random(1,#Cards[TAG][r])])
      else pack.COMMON=pack.COMMON+1 end
    elseif n>0 then
      if r=='COMMON'then
        local a,b=1,0
        --First a common or each color
        for _,k in ipairs({'W','U','B','R','G'})do
          --Evaluate where the last common of that color is
          --This Math continues to generate numbers above the amount that are in the set
          b=b+Cards[TAG][k]
          local d=math.random(a,b)
          table.insert(genNums,d)
          if Cards[TAG][r][d]then
            Card(Cards[TAG][r][d])
            pack.COMMON = pack.COMMON -1
          else printToAll('Common Not Found '..d..'/'..#Cards[TAG][r],{1,0,1}) end
          --Set where the Start of the Next color is
          a=a+Cards[TAG][k]end end
      --Then generate the rest of that rarity
      for i=1,pack[r]do
        local rng,L=math.random(1,#Cards[TAG][r]),0
        while genNums(rng)do rng,L=math.random(1,#Cards[TAG][r]),L+1 end
        if L>0 then table.insert(genNums,'[dd5555]L'..L..'[-]')end
        table.insert(genNums,rng)
        Card(Cards[TAG][r][rng])
      end
      --Log Pack Generation
      local bool=false
      for k,m in ipairs(genNums)do if genNums(m)and genNums(m)~=k and type(m)=='number'then bool=true end end
      if bool then local s='['..string_to_color(r)..']'..r for _,v in ipairs(genNums)do s=s..'_'..v end print(s..'[-]')end
    end
  end
end
function mythicDist(r,m)if math.random(1,m or 8)==1 then return 0,1 end return 1,0 end
--[[Tabletop Callbacks]]
function onDrop()self.setRotation({0,0,0})end
function onSave()
  for i,v in ipairs(Cards)do table.remove(Cards)end
  local name='\n'
  for k,_ in pairs(Cards)do name=name..k..' 'end
  if name~='\n'then self.setName(mod_name..' '..version..name)end
  return JSON.encode(Cards)end
function onLoad(data)
  if data~=''then Cards=JSON.decode(data)for k,_ in pairs(Cards)do print('Stored Set: '..k)end end
  setBack()WebRequest.get(WorkshopID,self,'versionCheck')end
function onChat(m,p)
  if m:find('clearPortableBoosterGenerator')and p.admin then
    Notes.addNotebookTab({title='Cards',body=onSave()})Cards={};onSave()
    broadcastToAll('[ff2222]Sets Nilled Out![-]\nSets must be Reloaded.',{1,0.4,1})
  elseif m:find('makeBoosters')and p.admin then local n=m:match('%d+');makeBoosters(n)end
end
function onChoice(p, _, id)
  local name=self.UI.getAttribute(id,'text')
  self.setRotation({0,0,0})
  if p.admin and TAG~=id then
    TAG=id
    Button()
  else
    printToAll(p.steam_name..' Wants to play '..name)
  end
end
function getUI(a)return self.UI.getAttribute(TAG,a)end
function doNothing(o,p,a)broadcastToColor('Please stop clicking the button.',stringColorToRGB(p.color))end
function versionCheck(wr)
  local _,b=wr.text:find(mod_name..' Version ')
  local v=wr.text:sub(b,b+10):match('%d+%p%d+')
  --This matches the first instance of Number Punctuation Number (1.1)
  local txt='[b]'..mod_name..' '..version..'[/b]\nSelect the set to load. Once loaded click the button to make 12 boosters!'
  --Version Checking
  if version<tonumber(v)then txt=txt..'\n[fff600]Consider Updating to '..mod_name..' '..v end
  printToAll(txt,{1,1,1})
end

sGen={tsp={'tsb',121},akh={'mp2',54},hou={'mp2',54},kld={'mps',54},aer={'mps',54},bfz={'exp',45}}
sPak={
  tsp={SPECIAL=1},
  mh1={SPECIAL=1},
  bfz={SPECIAL=432},
  kld={SPECIAL=144},
  bbd={PARTNER=1},
  dom={LEGENDARY=1},
  war={PLANESWALKER=1},
  isd={EXTRA={1,12,42,66}},
  dka={EXTRA={2,6,24,48}},}
sPak.cns=sPak.isd
sPak.cn2=sPak.isd
sPak.aer=sPak.kld
sPak.hou=sPak.kld
sPak.akh=sPak.kld
sRty={ogw=function(c)if c.name=='Wastes'then  return 'COMMON'end end,
  isd=function(c)if not c.image_uris then       return 'EXTRA'..c.rarity:upper()end end,
  grn=function(c)if c.type_line:find('Land')then  return 'EXTRA'..c.rarity:upper()end end,
  cns=function(c)if c.watermark == 'conspiracy'then return 'EXTRA'..c.rarity:upper()end end,
  dom=function(c)if c.type_line:find('Legendary')then return c.rarity:upper(),'LEGENDARY'end end,
  bbd=function(c)if c.oracle:find('Partner with ')then  return c.rarity:upper(),'PARTNER'end end,
  war=function(c)if c.type_line:find('Planeswalker')then  return c.rarity:upper(),'PLANESWALKER'end end,
  ice=function(c)if c.type_line:find('Basic Snow Land')then return'COMMON'end end,
  mh1=function(c)if c.type_line:find('Basic Snow Land')then return'SPECIAL'end end,}
sRty.dka=sRty.isd
sRty.soi=sRty.isd
sRty.emn=sRty.isd
sRty.rna=sRty.grn
sRty.dgm=sRty.grn
sRty.cn2=sRty.cns
sRty.csp=sRty.ice