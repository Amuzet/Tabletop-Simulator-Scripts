--By Amuzet
mod_name,version='Card Importer',1.81
self.setName('[854FD9]'..mod_name..' [49D54F]'..version)
author,WorkshopID,GITURL='76561198045776458','https://steamcommunity.com/sharedfiles/filedetails/?id=1838051922','https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Magic/Importer.lua'

--[[Classes]]
local TBL={__call=function(t,k)if k then return t[k] end return t.___ end,__index=function(t,k)if type(t.___)=='table'then rawset(t,k,t.___())else rawset(t,k,t.___)end return t[k] end}
function TBL.new(d,t)if t then t.___=d return setmetatable(t,TBL)else return setmetatable(d,TBL)end end
newText=setmetatable({type='3DText',position={0,2,0},rotation={90,0,0}},{__call=function(t,p,text,f)t.position=p local o=spawnObject(t);o.TextTool.setValue(text)o.TextTool.setFontSize(f or 50)return function(t)if t then o.TextTool.setValue(t)else o.destruct()end end end})
--[[Variables]]
local Tick,Test,Quality,Back=0.2,false,TBL.new('normal',{}),TBL.new('https://i.stack.imgur.com/787gj.png',{})
--[[Card Spawning Class]]
local Deck=setmetatable({White={n=0,did='',cd='',co='',json='',position={0,0,0}},Brown={n=0,did='',cd='',co='',json='',position={0,0,0}},Red={n=0,did='',cd='',co='',json='',position={0,0,0}},Orange={n=0,did='',cd='',co='',json='',position={0,0,0}},Yellow={n=0,did='',cd='',co='',json='',position={0,0,0}},Green={n=0,did='',cd='',co='',json='',position={0,0,0}},Teal={n=0,did='',cd='',co='',json='',position={0,0,0}},Blue={n=0,did='',cd='',co='',json='',position={0,0,0}},Purple={n=0,did='',cd='',co='',json='',position={0,0,0}},Pink={n=0,did='',cd='',co='',json='',position={0,0,0}},j=[[{
  "Name":"Deck","Transform":{"posX":0,"posY":0,"posZ":0,"rotX":0,"rotY":180,"rotZ":180,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},
  "Nickname":"%s","Description":"%s",
  "DeckIDs":[%s],
  "CustomDeck":{%s},
  "ContainedObjects":[%s]}]]},{__call=function(t,qTbl)
    t[qTbl.color].json=t.j:format(Player[qTbl.color].steam_name,qTbl.url or'Notebook',t[qTbl.color].did:sub(1,-2),t[qTbl.color].cd:sub(1,-2),t[qTbl.color].co:sub(1,-2))
    t[qTbl.color].position=qTbl.position or{0,2,0}
    t[qTbl.color].position[2]=t[qTbl.color].position[2]+1
    t[qTbl.color].did,t[qTbl.color].cd,t[qTbl.color].co,t[qTbl.color].n='','','',0
    spawnObjectJSON(t[qTbl.color])endLoop()end})
local Card=setmetatable({n=1,hwfd=true,image=false,json='',position={0,0,0},snap_to_grid=true,callback='INC',callback_owner=self,j='{"Name":"Card","Transform":{"posX":0,"posY":0,"posZ":0,"rotX":0,"rotY":180,"rotZ":180,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},"Nickname":"%s","Description":"%s","CardID":%i00,"CustomDeck":{"%i":{"FaceURL":"%s","BackURL":"%s","NumWidth":1,"NumHeight":1,"BackIsHidden":true}}}'},
  {__call=function(t,c,qTbl)
      --NeededFeilds in c:name,type_line,cmc,card_faces,oracle_text,power,toughness,loyalty,mana_cost,highres_image
      t.json,c.face,c.oracle,c.back='','','',Back[qTbl.player]or Back.___
      c.name=c.name:gsub('"','')..'\n'..c.type_line:gsub(' // .*','')..' '..c.cmc..'CMC'
      --Oracle text Handling for Split/DFCs
      if c.card_faces then
        for _,f in ipairs(c.card_faces)do c.oracle=c.oracle..c.name:gsub('"','\'')..'\n'..setOracle(f)end
      else c.oracle=setOracle(c)end
      --if Quality[qTbl.player]=='art_crop'then c.oracle..'\nArtist: '..c.artist end
      --Image Handling
      if t.image and qTbl.mode~='Deck'then --Custom Image
        c.face=t.image
        t.image=false
      elseif c.image_uris then
        c.face=c.image_uris.normal:gsub('%?.*',''):gsub('normal',Quality[qTbl.player])
      else --DFC Cards
        c.name=c.name:gsub(' // [^\n]*','')
        c.face=c.card_faces[1].image_uris.normal:gsub('%?.*',''):gsub('normal',Quality[qTbl.player])
        if qTbl.mode~='Deck'then
          c.back=c.face:gsub('normal',Quality[qTbl.player])
          c.face=c.card_faces[2].image_uris.normal:gsub('%?.*',''):gsub('normal',Quality[qTbl.player])
          t.hwfd=false
      end end
      local n=t.n
      if qTbl.deck then n=Deck[qTbl.color].n+1;Deck[qTbl.color].n=n end
      --Set JSON to Spawn Card
      t.json=string.format(t.j,c.name,c.oracle,n,n,c.face,c.back)
      --What to do with this card
      if qTbl.deck then --Add it to player deck
        Deck[qTbl.color].did=Deck[qTbl.color].did..n..'00,'
        Deck[qTbl.color].co=Deck[qTbl.color].co..t.json:gsub(',"CardID":',',"HideWhenFaceDown":true,"CardID":')..','
        local fistpos=t.json:find('"'..n..'"')
        Deck[qTbl.color].cd=Deck[qTbl.color].cd..t.json:sub(fistpos,-3)..','
        if n==qTbl.deck then Wait.time(function()Deck(qTbl)end,1)
          Player[qTbl.color].broadcast('All '..n..' Cards loaded!',{0.5,0.5,0.5})
        elseif n<qTbl.deck then
          qTbl.text('Spawning here\n'..n..' Cards loaded')
        end
      else--Spawn solo card
        uLog(qTbl.color..' Spawned '..c.name:gsub('\n.*',''))
        t.position=qTbl.position or{0,2,0}
        t.position[2]=t.position[2]+Tick
        spawnObjectJSON(t)endLoop()end end})

function INC(obj)obj.hide_when_face_down,Card.n=Card.hwfd,Card.n+1;Card.hwfd=true end
function setOracle(c)local n='\n[b]'if c.power then n=n..c.power..'/'..c.toughness elseif c.loyalty then n=n..tostring(c.loyalty)else n='[b]'end return c.oracle_text:gsub('\"',"'")..n..'[/b]'end
function setCard(wr,qTbl)
  if qTbl.deck then uLog(wr.url,'setCard')end
  if wr.text then
    local json=JSON.decode(wr.text)
    if json.object=='card'then
      if json.lang=='en'then
        Card(json,qTbl)
      else
        WebRequest.get('https://api.scryfall.com/cards/'..json.set..'/'..json.collector_number..'/en',function(a)setCard(a,qTbl)end)
      end return
    elseif json.object=='error'then Player[qTbl.color].broadcast(json.details,{1,0,0})end
  else error('No Data Returned Contact Amuzet. setCard')end endLoop()end

function spawnList(wr,qTbl)
  uLog(wr.url)
  if wr.text then
    local n,json=1,JSON.decode(wr.text)
    if json.object=='list'then qTbl.deck=#json.data
      for i,v in ipairs(json.data) do Wait.time(function()Card(v,qTbl)end,i*Tick)end return
    elseif json.object=='card'then
      Card(json,qTbl)return
    elseif json.object=='error'then
      Player[qTbl.color].broadcast(json.details,{1,0,0})
  end end endLoop()end
--[[DeckFormatHandle]]
local sOver={DAR='DOM',MPS_AKH='MP2',MPS_KLD='MPS',FRF_UGIN='UGIN'}
local dFile={
  dckCheck='%[[%w_]+:%w+%]',dck=function(line)
    local set,num,name=line:match('%[([%w_]+):(%w+)%] (%w.*)')
    if set:find('DD3_')then set=set:gsub('DD3_','')
    elseif sOver[set]then set=sOver[set] end
    set=set:gsub('_.*',''):lower()
    return 'https://api.scryfall.com/cards/'..set..'/'..num end,
  
  decCheck='%[[%w_]+%]',dec=function(line)
    local set,name=line:match('%[([%w_]+)%] (%w.*)')
    if set:find('DD3_')then set=set:gsub('DD3_','')
    elseif sOver[set]then set=sOver[set] end
    set=set:gsub('_.*',''):lower()
    return 'https://api.scryfall.com/cards/named?fuzzy='..name..'&set='..set end,
  
  defCheck='%w+',def=function(line)
    local name=line:gsub('%[%S%]',''):match('(%w.*)')
    return 'https://api.scryfall.com/cards/named?fuzzy='..name end}
--[[Deck spawning]]
function spawnDeck(wr,qTbl)
  if wr.text:find('!DOCTYPE')then
    uLog(wr.url,'Mal Formated Deck '..qTbl.color)
    uNotebook('D'..qTbl.color,wr.url)
    Player[qTbl.color].broadcast('Your Deck list could not be found\nMake sure the Deck is set to PUBLIC',{1,0.5,0})
  else
    uLog(wr.url,'Deck Spawned by '..qTbl.color)
    local sideboard=''
    local deck,list={},wr.text:gsub('\n%S*Sideboard(.*)',function(a)sideboard=a return ''end)
    local maybeboard=sideboard:match('\n%S*Maybeboard(.*)')
--[[if qTbl.mode=='Sideboard'then list=wr.text:match('Sideboard(.*)')end
    list=list:gsub('Maybeboard.*','')]]
    
    list:gsub('(%d+)[ xX]([^\r\n]+)',function(a,b)
        for k,v in pairs(dFile)do
          if type(v)=='string'and b:find(v)then
            for i=1,a do table.insert(deck,dFile[k:sub(1,3)](b))end
            break end end end)
    
    qTbl.deck=#deck
    
    for i,url in ipairs(deck) do
      Wait.time(function()
          WebRequest.get(url,function(c)
              setCard(c,qTbl)end)end,i*Tick)end
    delay('endLoop',#deck*2)
end end

function spawnParse(wr,qTbl,g,url)
  uLog(wr.text,wr.url)
  qTbl.deck=0
  wr.text:gsub(g,function(uid)
      qTbl.deck=qTbl.deck+1
      Wait.time(function()
          WebRequest.get(url..uid,
            function(c) setCard(c,qTbl)end)end,i*Tick)end)
  delay('endLoop',i)
end
function spawnCube(wr,qTbl,check)local cube={};wr.text:gsub(check,function(b)table.insert(cube,b)uLog(b)end)qTbl.deck=#cube;for i,v in ipairs(cube)do Wait.time(function()WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..v,function(c)setCard(c,qTbl)end)end,i*Tick)end delay('endLoop',#cube)end
local DeckSites={
  --domain as key in table set to a function that takes a string and returns a url,and function
  --Key=function(URL) return modifiedURL,function(modifiedURL,qTbl)end,
  --https://deckstats.net/decks/99231/1519126-zombie-deck-beta?include_comments=1&export_dec=1
  deckstats=function(a)return a..'?export_txt=1',spawnDeck end,
  --https://tappedout.net/mtg-decks/the-minewalker/ https://tappedout.net/alter/3057/
  tappedout=function(a)printToAll('Tappedout Alters Unsupported',{0.1,0.5,0.8})return a:gsub('.cb=%d+','')..'?fmt=txt',spawnDeck end,
  pastbin=function(a)return a:gsub('com/','com/raw/'),spawnDeck end,
  deckbox=function(a)return a..'/export',spawnDeck end,
  scryfall=function(a)return a:gsub('com/.*/','com/decks/'):gsub('scryfall','api.scryfall')..'/export/text',spawnDeck end,
  --https://www.moxfield.com/decks/fiWavmsoZk6ttuu6ngfTZA
  --https://api.moxfield.com/v1/decks/all/fiWavmsoZk6ttuu6ngfTZA/download
  moxfield=function(a)return 'https://api.moxfield.com/v1/decks/all/'..a:match('/decks/(.*)')..'/download',spawnDeck end,
  --Default Function 'spawnDeck' requires a url that returns a plain text deck list.
  mtggoldfish=function(a)
    if a:find('/archetype/')then
    --https://www.mtggoldfish.com/archetype/standard-jeskai-fires#paper
    --https://www.mtggoldfish.com/deck/download/2560235
      return a,function(wr,qTbl)Player[qTbl.color].broadcast('This is an Archtype!\nPlease spawn a User made Deck.',{0.9,0.1,0.1})endLoop()end
    elseif a:find('/deck/')then
    --https://www.mtggoldfish.com/deck/2572815#paper
    --https://www.mtggoldfish.com/deck/download/2572815
      return a:gsub('/deck/','/deck/download/'):gsub('#%w+',''),spawnDeck
    else return a,function(wr,qTbl)Player[qTbl.color].broadcast('This MTGgoldfish url is malformated.\nOr unsupported contact Amuzet.')end end end,
  archidekt=function(a)return 'https://archidekt.com/api/decks/'..a:match('/(%d+)')..'/small/',function(wr,qTbl)
    qTbl.deck=0
    --TrimJSON
    local json=wr.text
    for k,s in pairs({'types','oracleCard','prices','edition'})do json=json:gsub('"'..s..'"[^}]+},','')end
    
    --for k,s in pairs({'"uid":"','"quantity":'})do json:gsub('"'..s..'(.+)["]?,',function(d)return''end)end
    uNotebook('archidekt',json)
    json=JSON.decode(json)
    --json:gsub('uid":"([^"]+)"[^}]+,"quantity":(%d+)',function(b,d)
    for _,v in pairs(json.cards)do
      uLog(v)
      qTbl.deck=qTbl.deck+v.quantity
      for i=1,v.quantity do
        Wait.time(function()
          WebRequest.get('https://api.scryfall.com/cards/'..v.card.uid,
            function(c)setCard(c,qTbl)end)end,i*Tick*2)end end end end,
  cubetutor=function(a)return a,function(wr,qTbl)spawnCube(wr,qTbl,'class="cardPreview "[^>]*>([^<]*)<')end end,
  cubecobra=function(a)return a:gsub('list','download/plaintext'),function(wr,qTbl)spawnCube(wr,qTbl,'[^\n]+')end end,
}
local apiSet='http://api.scryfall.com/cards/random?q=is:booster+set:'
local Booster=setmetatable({
    dom=function(p)local n=math.random(13,#p);p[n]=p[n]..'+t:legendary'return p end,
    war=function(p)local n=math.random(13,#p);p[n]=p[n]..'+t:planeswalker'return p end,
    tsp='tsb',mb1='fmb1',bfz='exp',ogw='exp',kld='mps',aer='mps',akh='mp2',hou='mp2'
  },{__call=function(t,set,n)
    local pack,u={},apiSet..set..'+'
    if not n and t[set]and type(t[set])=='function'then
      return t[set](t(set,true))
    else
      if('rav gpt dis rtr gtc dgm grn rna'):find(set)then u=u..'-t:land+'
      elseif('cns cn2'):find(set)then u=u..'+-wm:conspiracy+'end
      for _,c in pairs({'w','u','b','r','g'})do
        table.insert(pack,u..'r:common+c:'..c)end
      for i=1,6 do table.insert(pack,u..'r:common+-t:basic')end
      if(t[set]and math.random(1,144)==1)or('tsp mb1'):find(set)then
        pack[#pack]=apiSet..t[set]end
      for i=1,3 do table.insert(pack,u..'r:uncommon')end
      table.insert(pack,u..'(r:rare+or+r:mythic)')
      return pack end end})
for _,s in pairs({'isd','dka','soi','emn'})do
    Booster[s]=function(p)local n=math.random(6,11);for i,v in pairs(p)do if i~=n then p[i]=p[i]..'+-is:transform'else p[i]=apiSet..s..'+is:transform'end end return p end end
for _,s in pairs({'rav+t:land+-t:basic','gpt+t:land+-t:basic','dis+t:land+-t:basic','rtr+t:land+-t:basic','gtc+t:land+-t:basic','dgm+t:land+-t:basic','grn+t:land+-t:basic','rna+t:land+-t:basic',
    'ice+t:basic+t:snow','mh1+t:basic+t:snow','cns+wm:conspiracy','cn2+wm:conspiracy'})do
  local k=s:match('%w+');Booster[k]=function(p)p[math.random(6,11)]=apiSet..s;return p end end
--[[Importer Data Structure]]
local Importer=setmetatable({
  --Variables
  request={},
  --Functions
  Search=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/search?q='..qTbl.name,function(wr)
        spawnList(wr,qTbl)end)end,
  
  Back=function(qTbl)
    if qTbl.target then qTbl.url=qTbl.target.getJSON():match('BackURL": "([^"]*)"')end
    Back[qTbl.player]=qTbl.url
    Player[qTbl.color].broadcast('Card Backs set to\n'..qTbl.url,{0.9,0.9,0.9})
    endLoop()end,
  
  Spawn=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        local obj=JSON.decode(wr.text)
        if obj.object=='card'and obj.type_line:match('Token')then
          WebRequest.get('https://api.scryfall.com/cards/search?unique=card&q=t%3Atoken+'..qTbl.name:gsub(' ','%%20'),function(wr)
              spawnList(wr,qTbl)end)
          return false
        else setCard(wr,qTbl)end end)end,
  
  Token=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        local json=JSON.decode(wr.text)
        if json.all_parts then
          qTbl.deck=#json.all_parts
          for _,v in ipairs(json.all_parts) do
              WebRequest.get(v.uri,function(wr)setCard(wr,qTbl)end)end
        --What is this elseif json.oracle
        else Player[qTbl.color].broadcast('No Tokens Found',{0.9,0.9,0.9})endLoop()end end)end,
  
  Print=function(qTbl)
    local url,n='https://api.scryfall.com/cards/search?unique=prints&q=',qTbl.name:lower():gsub('%s','')
    if n=='plains'or n=='island'or n=='swamp'or n=='mountain'or n=='forest'then
      --url=url:gsub('prints','art')end
      broadcastToAll('Please Do NOT print Basics\nIf you would like a specific Basic specify that in your decklist\nor Spawn it using "Scryfall search t:basic+set:xln" the corresponding setcode',{0.9,0.9,0.9})
      endLoop()
    else
    WebRequest.get(url..qTbl.name,function(wr)
        spawnList(wr,qTbl)end)end end,
  
  Legalities=function(qTbl)
    WebRequest.get('http://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        for f,l in pairs(JSON.decode(wr.text:match('"legalities":({[^}]+})')))do printToAll(l..' in '..f) end endLoop()end)end,
  
  Legal=function(qTbl)
    WebRequest.get('http://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        local n,s,t='','',JSON.decode(wr.text:match('"legalities":({[^}]+})'))
        for f,l in pairs(t)do if l=='legal'and s==''then s='[11ff11]'..f:sub(1,1):upper()..f:sub(2)..' Legal'
          elseif l=='not_legal'and s~=''then if n==''then n='Not Legal in:' end n=n..' '..f end end
        
        if s==''then s='[ff1111]Banned' else local b=''
          for f,l in pairs(t)do if l=='banned'then b=b..' '..f end end
          if b~=''then s=s..'[-]\n[ff1111]Banned in:'..b end end
        
        local r=''
        for f,l in pairs(t)do if l=='restricted'then r=r..' '..f end end
        if r~=''then s=s..'[-]\n[ffff11]Restricted in:'..r end
        printToAll('Legalities:'..qTbl.full:match('%s.*')..'\n'..s,{1,1,1})
        endLoop()end)end,
  
  Text=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/named?format=text&fuzzy='..qTbl.name,function(wr)
        if qTbl.target then qTbl.target.setDescription(wr.text)
        else Player[qTbl.color].broadcast(wr.text)end
        endLoop()end)end,
  
  Rules=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        WebRequest.get(JSON.decode(wr.text).rulings_uri,function(wr)
          local data,text=JSON.decode(wr.text),'[00cc88]'
          if data[1]then for _,v in pairs(data)do
              text=text..v.published_at..'[-]\n[ff7700]'..v.comment..'[-][00cc88]\n'end
          else text='No Rulings'end
          
          if text:len()>1000 then
            uNotebook('R'..SF.request,text)
            broadcastToAll('Rulings are too long!\nFull rulings can be found in the Notebook',{0.9,0.9,0.9})
          elseif qTbl.target then qTbl.target.setDescription(text)
          else broadcastToAll(text,{0.9,0.9,0.9})
          end endLoop()end)end)end,
  
  Mystery=function(qTbl)
    local t,url={},'http://api.scryfall.com/cards/random?q=set:mb1+'
    for _,r in pairs({'common','uncommon'})do
      for _,c in pairs({'w','u','b','r','g'})do
        table.insert(t,url..('r:%s+c:%s+id:%s'):format(r,c,c))
      end
    end
    table.insert(t,url..'c:c+-r:rare+-r:mythic')
    table.insert(t,url..'c:m+-r:rare+-r:mythic')
    table.insert(t,url..'(r:rare+or+r:mythic)+frame:2015')
    table.insert(t,url..'(r:rare+or+r:mythic)+-frame:2015')
    local fSlot={'http://api.scryfall.com/cards/random?q=set:cmb1','http://api.scryfall.com/cards/random?q=set:fmb1'}
    
    qTbl.url='Mystery Booster'
    if qTbl.name:find('playtest')then
      qTbl.url='Playtest Booster'
      table.insert(t,fSlot[1])
    elseif qTbl.name:find('both')then
      table.insert(t,fSlot[math.random(1,2)])
    else table.insert(t,fSlot[2])end
    
    qTbl.deck=#t
    qTbl.mode='Deck'
    for i,u in pairs(t)do
      Wait.time(function()WebRequest.get(u,function(wr)
            setCard(wr,qTbl)end)end,i*Tick)end
    end,
  
  Booster=function(qTbl)
    if qTbl.name==''then qTbl.name='ori'end
    WebRequest.get('https://api.scryfall.com/sets/'..qTbl.name,function(w)
        local j=JSON.decode(w.text)
        if j.object=='set'then
          local pack=Booster(qTbl.name)
          qTbl.url='Booster '..j.name
          qTbl.deck=#pack
          qTbl.mode='Deck'
          for i,u in pairs(pack)do
            Wait.time(function()WebRequest.get(u,function(wr)
                  setCard(wr,qTbl)end)end,i*Tick)end
    end end)end,
  
  Random=function(qTbl)
    local url,q1='https://api.scryfall.com/cards/random','?q=is:hires'
    if qTbl.name:find('q=')then url=url..qTbl.full:match('%s(%S+)')else
      for _,tbl in ipairs({{w='c%3Aw',u='c%3Au',b='c%3Ab',r='c%3Ar',g='c%3Ag'},
          {i='t%3Ainstant',s='t%3Asorcery',e='t%3Aenchantment',c='t%3Acreature',a='t%3Aartifact',l='t%3Aland',p='t%Aplaneswalker'}})do
        local t,q2=0,''
        for k,m in pairs(tbl) do
          if string.match(qTbl.name:lower(),k)then
            if t==1 then q2='('..q2 end
            if t>0 then q2=q2..'or+'end
            t,q2=t+1,q2..m..'+'end end
        if t>1 then q2=q2..')+'end
        q1=q1..q2 end
      local tst,cmc=qTbl.full:match('([=<>]+)(%d+)')
      if tst then q1=q1..'cmc'..tst..cmc end
      if q1~='?q='then url=url..(q1..' '):gsub('%+ ',''):gsub(' ','')end
    end
    uLog(url,qTbl.color..' Importer '..qTbl.full)
    local n=tonumber(qTbl.full:match('%s(%d+)'))
    if n then
      qTbl.deck=n
      for i=1,n do
        Wait.time(function()
        WebRequest.get(url,function(wr)setCard(wr,qTbl)end)end,i*Tick)end
    else WebRequest.get(url,function(wr)setCard(wr,qTbl)end)end end,
  
  Quality=function(qTbl)
    for k,v in pairs({s='small',n='normal',l='large',a='art_crop',b='border_crop'}) do
      if qTbl.name:find(v)then Quality[qTbl.player]=v end end
    endLoop()end,
  
  Deck=function(qTbl)
    if qTbl.url then
      for k,v in pairs(DeckSites) do
        if qTbl.url:find(k)then
          qTbl.mode='Deck'
          local url,deckFunction=v(qTbl.url)
          WebRequest.get(url,function(wr) deckFunction(wr,qTbl)end)
          return true end end
    elseif qTbl.mode=='Deck'then
      local d=getNotebookTabs()
      d=d[#d]
      spawnDeck({
          text=d.body,
          url='Notebook '..d.title..d.color},qTbl)
    end return false end,
  
    },{
  __call=function(t,qTbl)
    if qTbl then
      log(qTbl,'Importer Request '..qTbl.color)
      qTbl.text=newText(qTbl.position,Player[qTbl.color].steam_name..'\n'..qTbl.full)
      table.insert(t.request,qTbl)
    end
    --Main Logic
    if t.request[4] and qTbl then
      Player[qTbl.color].broadcast('Clearing Previous requests yours added and being processed.')
      endLoop()
    elseif qTbl and t.request[2]then
      Player[qTbl.color].broadcast('Queueing request.')
    elseif t.request[1]then
      local tbl=t.request[1]
      --Logic Branch
      if tbl.url and tbl.mode~='Back'then
        if not t.Deck(tbl)then
        --If URL is not Deck list then
        --Custom Image Replace
        Card.image=tbl.url
        t.Spawn(tbl)
        end
      elseif t[tbl.mode]then
        --Execute that Mode
        t[tbl.mode](tbl)
      else
        --Attempt to Spawn
        t.Spawn(tbl)
      end
    elseif qTbl then broadcastToAll('Something went Wrong please contact Amuzet\nImporter did not get a mode. MAIN LOGIC')
  end end})

--[[Functions used everywhere else]]
local Usage=[[    [b]%s
[-][-][0077ff]Scryfall[/b] [i]cardname[/i]  [-][Spawns that card]
[b][0077ff]Scryfall[/b] [i]URL cardname[/i]  [-][Spawns [i]cardname[/i] with [i]URL[/i] as it face]
[b][0077ff]Scryfall[/b] [i]URL[/i]  [-][Spawn that deck list or Image]
[b]Supported: [/b][i]archidekt cubetutor cubecobra deckstats deckbox mtggoldfish scryfall tappedout pastebin[/i]
[b][0077ff]Scryfall help[/b] [-][Displays all possible commands]

[b][ff7700]deck[/b] [-][Spawn deck from newest Notebook tab]
[b][ff7700]back[/b] [i]URL[/i] [-][Makes card back URL]
[b][ff7700]text[/b] [i]name[/i] [-][Prints Oracle text of name]
[b][ff7700]print[/b] [i]name[/i] [-][Spawns various printings of name]
[b][ff7700]legal[/b] [i]name[/i] [-][Prints Legalities of name]
[b][ff7700]rules[/b] [i]name[/i] [-][Prints Rulings of name ]
[b][ff7700]random[/b] [i]isecalpwubrg<>=# quantity[/i] [-]['[i]ri=2[/i]' Spawns a Red Instant of CMC Two]
[b][ff7700]search[/b] [i]syntax[/i] [-][Spawns all cards matching that search (be careful)]
[b][ff7700]random[/b] ?q=[i]syntax quantity[/i] [-][Advanced Random using search syntax (go crazy!)]
[b][ff7700]quality[/b] [i]mode[/i] [-][Changes the quality of the image]
[i]small,normal,large,art_crop,border_crop[/i] ]]
function endLoop()if Importer.request[1]then Importer.request[1].text()table.remove(Importer.request,1)end Importer()end
function delay(fN,tbl)local timerParams={function_name=fN,identifier=fN..'Timer'}
  if type(tbl)=='table'then timerParams.parameters=tbl end
  if type(tbl)=='number'then timerParams.delay=tbl*Tick
  else timerParams.delay=1.5 end
  Timer.destroy(timerParams.identifier)
  Timer.create(timerParams)
end
function uLog(a,b)if Test then log(a,b)end end
function uNotebook(t,b,c)local p={index=-1,title=t,body=b or'',color=c or'Grey'}
  for i,v in ipairs(getNotebookTabs())do if v.title==p.title then p.index=i end end
  if p.index<0 then addNotebookTab(p)else editNotebookTab(p)end return p.index end
function uVersion(wr)
  uLog(wr.is_done,'Checking Importer Version')
  local v=wr.text:match('mod_name,version=\'Card Importer\',(%d+%p%d+)')
  log('GITHUB Version '..v)
  if v then v=tonumber(v) else v=version end
  local s='\nLatest Version '..self.getName()
  if version>v or Test then Test,s=true,'\n[fff600]Experimental Version of Importer Module'
  elseif version<v then s='\n[77ff00]Update Ready:'..v..' on Workshop[-]\n'..wr.url end
  Usage=Usage..s
  broadcastToAll(s,{1,0,1})
end

--[[Tabletop Callbacks]]
function onSave()self.script_state=JSON.encode(Back)end
function onLoad(data)
  Usage=Usage:format(self.getName())
  WebRequest.get(GITURL,self,'uVersion')
  if data~=''then Back=JSON.decode(data)end
  Back=TBL.new(Back)
  self.createButton({label="+",click_function='registerModule',function_owner=self,position={0,0.2,-0.5},height=100,width=100,font_size=100,tooltip="Adds Oracle Look Up"})
  uNotebook('SHelp',Usage)
  uNotebook('SData',self.script_state)
  local u=Usage:gsub('\n\n.*','\nFull capabilities listed in Notebook: SHelp')
  self.setDescription(u:gsub('[^\n]*\n','',1):gsub('%]  %[',']\n['))
  printToAll(u,{0.9,0.9,0.9})
  if self.getLock()then registerModule()end end

local SMG,SMC='[b]Scryfall: [/b]',{0.5,1,0.8}
function onPlayerConnect(player)if player.steam_id==author then printToAll(SMG..'Welcome Amuzet, creator of me. The Card Importer!',SMC)end end
function onPlayerDisconnect(player)if player.steam_id==author then printToAll(SMG..'Goodbye Amuzet, take care of yur self buddy-o-pal!',SMC)end end
local chatToggle=false
function onChat(msg,player)
  if msg:find('[Ss]cryfall ')or msg:find('!S%S* ')then
    local a=msg:match('[Ss]cryfall (.*)')or msg:match('!S%S* (.*)')or false
    if a=='hide'and player.admin then
      chatToggle=not chatToggle
      if chatToggle then msg='supressing' else msg='showing'end
      broadcastToAll('Importer now '..msg..' Chat messages with Importer in them.\nToggle this with "Importer Hide"',{0.9,0.6,0.4})
    elseif a=='help'then
      player.print(Usage,{0.9,0.9,0.9})return false
    elseif a=='announce my pressence!'then
      local s=SMG
      if player.steam_id==author then
        s=s..'My creator has requested that I announce their pressence!\n'..SMG..'Behold the titan that is '..player.name..'!'
      elseif player.host then
        s=s..'You may be the host,'..player.steam_name..', but your not as special to me as my Amuzet.'
      else s=s..'Why would I? You are of no significance to me!'end
      broadcastToAll(s,SMC)
    elseif a=='clear'then
      self.script_state='{"76561197975480678":"http://cloud-3.steamusercontent.com/ugc/772861785996967901/6E85CE1D18660E60849EF5CEE08E818F7400A63D/","76561198000043097":"https://i.imgur.com/rfQsgTL.png","76561198025014348":"https://i.imgur.com/pPnIKhy.png","76561198045241564":"http://i.imgur.com/P7qYTcI.png","76561198045776458":"https://media.wizards.com/2019/images/daily/oCa6ZZvWzu.png","76561198069287630":"http://i.imgur.com/OCOGzLH.jpg","76561198079063165":"https://external-preview.redd.it/QPaqxNBqLVUmR6OZTPpsdGd4MNuCMv91wky1SZdxqUc.png?s=006bfa2facd944596ff35301819a9517e6451084","76561198005479600":"https://images-na.ssl-images-amazon.com/images/I/61AGZ37D7eL._SL1039_.jpg","a":"Dummy"}'
      Back=TBL.new('https://i.stack.imgur.com/787gj.png',JSON.decode(self.script_state))
    elseif a then
      local tbl={position=player.getPointerPosition(),player=player.steam_id,color=player.color,url=a:match('(http%S+)'),mode=a:gsub('(http%S+)',''):match('(%S+)'),name=a:gsub('(http%S+)',''):gsub(' ',''),full=a}
      if tbl.color=='Grey'then tbl.position={0,2,0}end
      if tbl.mode then
        for k,v in pairs(Importer)do
          if tbl.mode:lower()==k:lower()and type(v)=='function'then
            tbl.mode,tbl.name=k,tbl.name:lower():gsub(k:lower(),'',1)
            break end end end
      
      if tbl.name:len()<1 or tbl.name==' 'then tbl.name='island'else tbl.name=tbl.name:gsub('%s','')end
      
      Importer(tbl)
      if chatToggle then uLog(msg,player.steam_name)return false end
end end end

--[[Card Encoder]]
pID=mod_name
function registerModule()
  enc=Global.getVar('Encoder')
  if enc then
    buttons={'Respawn','Oracle','Rulings','Emblem\nAnd Tokens','Printings','Set Sleeve','Reverse Card'}
    enc.call('APIregisterTool',{toolID=pID,name=pID,funcOwner=self,activateFunc='toggleMenu',display=true})
    function eEmblemAndTokens(o,p)ENC(o,p,'Token')end function eOracle(o,p)ENC(o,p,'Text')end function eRulings(o,p)ENC(o,p,'Rules')end function ePrintings(o,p)ENC(o,p,'Print')end function eRespawn(o,p)ENC(o,p,'Spawn')end function eSetSleeve(o,p)ENC(o,p,'Back')end
    function eReverseCard(o,p)ENC(o,p)spawnObjectJSON({json=o.getJSON():gsub('BackURL','FaceURL'):gsub('FaceURL','BackURL',1)})
end end end
function ENC(o,p,m)enc.call('APIrebuildButtons',{obj=o})if m then if o.getName()==''and m~='Back'then Player[p].broadcast('Card has no name!',{1,0,1}) else Importer({position={o.getPosition().x+1,o.getPosition().y+1,o.getPosition().z+1},target=o,player=Player[p].steam_id,color=p,name=o.getName():gsub('\n.*','')or'Energy Reserve',mode=m,full='Card Encoder'})end end end
function toggleMenu(o)enc=Global.getVar('Encoder')if enc then flip=enc.call("APIgetFlip",{obj=o})for i,v in ipairs(buttons)do Button(o,v,flip)end Button:reset()end end
Button=setmetatable({label='UNDEFINED',click_function='eOracle',function_owner=self,height=400,width=2100,font_size=360,scale={0.4,0.4,0.4},position={0,0.28,-1.35},rotation={0,0,90},reset=function(t)t.label='UNDEFINED';t.position={0,0.28,-1.35}end
  },{__call=function(t,o,l,f)
      local inc,i=0.325,0
      l:gsub('\n',function()t.height,inc,i=t.height+400,inc+0.1625,i+1 end)
      t.label,t.click_function,t.position,t.rotation[3]=l,'e'..l:gsub('%s',''),{0,0.28*f,t.position[3]+inc},90-90*f
      o.createButton(t)
      t.height=400
      if i % 2==1 then t.position[3]=t.position[3]+0.1625 end end})
--EOF