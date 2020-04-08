--By Amuzet
mod_name='Card Importer'
version=1.77
self.setName(mod_name..' '..version)
author='76561198045776458'
WorkshopID='https://steamcommunity.com/sharedfiles/filedetails/?id=1838051922'

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
  "ContainedObjects":[%s]
}]]},{__call=function(t,qTbl)
    t[qTbl.color].json=t.j:format(Player[qTbl.color].steam_name,qTbl.url or'Notebook',t[qTbl.color].did:sub(1,-2),t[qTbl.color].cd:sub(1,-2),t[qTbl.color].co:sub(1,-2))
    t[qTbl.color].position=qTbl.position or{0,2,0}
    t[qTbl.color].position[2]=t[qTbl.color].position[2]+1
    t[qTbl.color].did,t[qTbl.color].cd,t[qTbl.color].co,t[qTbl.color].n='','','',0
    spawnObjectJSON(t[qTbl.color])end})
local Card=setmetatable({n=1,hwfd=true,image=false,json='',position={0,0,0},snap_to_grid=true,callback='INC',callback_owner=self,j='{"Name":"Card","Transform":{"posX":0,"posY":0,"posZ":0,"rotX":0,"rotY":180,"rotZ":180,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},"Nickname":"%s","Description":"%s","CardID":%i00,"CustomDeck":{"%i":{"FaceURL":"%s","BackURL":"%s","NumWidth":1,"NumHeight":1,"BackIsHidden":true}}}'},
  {__call=function(t,c,qTbl)
      --NeededFeilds in c:name,type_line,cmc,card_faces,oracle_text,power,toughness,loyalty,mana_cost,highres_image
      t.json,c.face,c.oracle,c.back='','','',Back[qTbl.player]or Back.___
      c.name=c.name:gsub('"','\'')..'\n'..c.type_line:gsub(' // .*','')..' '..c.cmc..'CMC'
      --Oracle text Handling for Split/DFCs
      if c.card_faces then
        for _,f in ipairs(c.card_faces)do c.oracle=c.oracle..c.name:gsub('"','\'')..'\n'..setOracle(f)end
      else c.oracle=setOracle(c)end
      --if Quality[qTbl.player]=='art_crop'then c.oracle..'\nArtist: '..c.artist end
      --Image Handling
      if t.image and not qTbl.deck then --Custom Image
        c.face=t.image
        t.image=false
      elseif c.image_uris then
        c.face=c.image_uris.normal:gsub('%?.*',''):gsub('normal',Quality[qTbl.player])
      else --DFC Cards
        c.name=c.name:gsub(' // [^\n]*','')
        c.face=c.card_faces[1].image_uris.normal:gsub('%?.*',''):gsub('normal',Quality[qTbl.player])
        if qTbl.deck==nil then
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
        Deck[qTbl.color].co=Deck[qTbl.color].co..t.json..','
        local fistpos=t.json:find('"'..n..'"')
        Deck[qTbl.color].cd=Deck[qTbl.color].cd..t.json:sub(fistpos,-3)..','
        if n==qTbl.deck then Wait.time(function()Deck(qTbl)end,1)
          Player[qTbl.color].broadcast('All '..n..' Cards loaded!',{0.5,0.5,0.5})
        elseif 5==qTbl.deck-n then
          qTbl.text('Spawning here\nAlmost loaded')
        elseif 5<qTbl.deck-n then
          qTbl.text('Spawning here\n'..n..' Cards loaded')
        end
      else--Spawn solo card
        uLog(qTbl.color..' Spawned '..c.name:gsub('\n.*',''))
        t.position=qTbl.position or{0,2,0}
        t.position[2]=t.position[2]+Tick
        spawnObjectJSON(t)end end})

function INC(obj)obj.hide_when_face_down,Card.hwfd,Card.n=Card.hwfd,true,Card.n+1 end
function setOracle(c)local n='\n[b]'if c.power then n=n..c.power..'/'..c.toughness elseif c.loyalty then n=n..tostring(c.loyalty)else n='[b]'end return c.oracle_text:gsub('\"',"'")..n..'[/b]'end
function setCard(wr,qTbl)
  if not qTbl.deck then uLog(wr,wr.url)end
  if wr.text then
    local json=JSON.decode(wr.text)
    if json.object=='card'then
      if json.lang=='en'then
        Card(json,qTbl)
      else
        WebRequest.get('https://api.scryfall.com/cards/'..json.set..'/'..json.collector_number..'/en',function(a)
          setCard(a,qTbl)
        end)
      end
    elseif json.object=='error'then Player[qTbl.color].broadcast(json.details,{1,0,0})end
  else error('No Data Returned Contact Amuzet. setCard')end end

function spawnList(wr,qTbl)
  uLog(wr.url)
  if wr.text and tonumber(wr.text:match('%d+'))<30 then
    local n,json=1,JSON.decode(wr.text)
    if json.object=='list'then
      for i,v in ipairs(json.data) do Wait.time(function()Card(v,qTbl)end,i*Tick)end
      n=#json.data
    elseif json.object=='card'then
      Card(json,qTbl)
    elseif json.object=='error'then
      Player[qTbl.color].broadcast(json.details,{1,0,0})
    end
    delay('endLoop',n)
  else
    local n=wr.text:match('%d+')
    if n then Player[qTbl.player].broadcast('PLEASE do not spawn that many cards! '..n)
    else error(JSON.decode(wr.text).details)end endLoop()end end
--[[DeckFormatHandle]]
local dFile={
  dckCheck='%[[%w_]+:%w+%]',dck=function(line)
    local set,num,name=line:match('%[([%w_]+):(%w+)%] (%w.*)')
    if set=='MPS_AKH'then set='MP2'
    elseif set=='MPS_KLD'then set='MPS'
    elseif set=='FRF_UGIN'then set='UGIN'
    elseif set:find('DD3_')then set=set:gsub('DD3_','')end
    set=set:gsub('_.*',''):lower()
    return 'https://api.scryfall.com/cards/'..set..'/'..num end,
  
  decCheck='%[[%w_]+%]',dec=function(line)
    local set,name=line:match('%[([%w_]+)%] (%w.*)')
    if set=='MPS_AKH'then set='MP2'
    elseif set=='MPS_KLD'then set='MPS'
    elseif set=='FRF_UGIN'then set='UGIN'
    elseif set:find('DD3_')then set=set:gsub('DD3_','')end
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
  --[[Key=function(URL) return modifiedURL,function(modifiedURL)end,]]
  --https://deckstats.net/decks/99231/1519126-zombie-deck-beta?include_comments=1&export_dec=1
  deckstats=function(a)return a..'?export_txt=1',spawnDeck end,
  --[[https://tappedout.net/mtg-decks/the-minewalker/ https://tappedout.net/alter/3057/]]
  tappedout=function(a)printToAll('Tappedout Alters Unsupported',{0.1,0.5,0.8})return a:gsub('.cb=%d+','')..'?fmt=txt',spawnDeck end,
  pastbin=function(a)return a:gsub('com/','com/raw/'),spawnDeck end,
  deckbox=function(a)return a..'/export',spawnDeck end,
  scryfall=function(a)return a:gsub('com/.*/','com/decks/'):gsub('scryfall','api.scryfall')..'/export/text',spawnDeck end,
  --Default Function 'spawnDeck' requires a url that returns a plain text deck list.
  mtggoldfish=function(a)
    if a:find('/archetype/')then
    --https://www.mtggoldfish.com/archetype/standard-jeskai-fires#paper
    --https://www.mtggoldfish.com/deck/download/2560235
      return a,function(b,qTbl)Player[qTbl.color].broadcast('This is an Archtype!\nPlease spawn a User made Deck.',{0.9,0.1,0.1})endLoop()end
    elseif a:find('/deck/')then
    --https://www.mtggoldfish.com/deck/2572815#paper
    --https://www.mtggoldfish.com/deck/download/2572815
      return a:gsub('/deck/','/deck/download/'):gsub('#%w+',''),spawnDeck
    else return a,function(b,qTbl)Player[qTbl.color].broadcast('This MTGgoldfish url is malformated.\nOr unsupported contact Amuzet.')end end end,
  archidekt=function(a)return 'https://archidekt.com/api/decks/'..a:match('/(%d+)')..'/small/',function(wr,qTbl)
    qTbl.deck=0
    --TrimJSON
    local json=wr.text
    for k,s in pairs({'types','oracleCard','prices','edition'})do json=json:gsub('"'..s..'"[^}]+},','')end
    uNotebook('archidekt',json)
    json=JSON.decode(json)
    --json:gsub('uid":"([^"]+)"[^}]+,"quantity":(%d+)',function(b,d)
    for _,v in pairs(json.cards)do
      uLog(v)
      qTbl.deck=qTbl.deck+v.quantity
      for i=1,v.quantity do
        Wait.time(function()
          WebRequest.get('https://api.scryfall.com/cards/'..v.card.uid,
            function(c)setCard(c,qTbl)end)
          end,i*Tick*2)
      end
    end
    delay('endLoop',qTbl.deck)end end,
  cubetutor=function(a)return a,function(wr,qTbl)spawnCube(wr,qTbl,'class="cardPreview "[^>]*>([^<]*)<')end end,
  cubecobra=function(a)return a:gsub('list','download/plaintext'),function(wr,qTbl)spawnCube(wr,qTbl,'[^\n]+')end end,
}
--[[Importer Data Structure]]
local Importer=setmetatable({
  --Variables
  request={},
  --Functions
  Search=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/search?q='..qTbl.name,function(wr)
        spawnList(wr,qTbl)end)end,
  
  Back=function(qTbl)
    if qTbl.target then
      qTbl.url=qTbl.target.getJSON():match('BackURL": "([^"]*)"')
    end
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
        else
          setCard(wr,qTbl)
          endLoop()
        end end)end,
    
  Token=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
        local json=JSON.decode(wr.text)
        if json.all_parts then
          for _,v in ipairs(json.all_parts) do
            if v.name~=json.name then
            WebRequest.get(v.uri,function(wr)
                setCard(wr,qTbl)
              end)end end
          delay('endLoop',#json.all_parts)
        --What is this elseif json.oracle
        else
          Player[qTbl.color].broadcast('No Tokens Found',{0.9,0.9,0.9})
          endLoop()end end)end,
  
  Print=function(qTbl)
    local url,n='https://api.scryfall.com/cards/search?unique=prints&q=',qTbl.name:lower():gsub('%s','')
    if n=='plains'or n=='island'or n=='swamp'or n=='mountain'or n=='forest'then
      --url=url:gsub('prints','art')end
      broadcastToAll('Please Do NOT print Basics\nIf you would like a specific Basic find its art online\nSpawn it using "Importer URL BASICLANDNAME"',{0.9,0.9,0.9})
      endLoop()
    else
    WebRequest.get(url..qTbl.name,function(wr)
        spawnList(wr,qTbl)end)end end,
  
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
  
  Random=function(qTbl)
    local url,q1='https://api.scryfall.com/cards/random','?q='
    for _,tbl in ipairs({{w='c%3Aw',u='c%3Au',b='c%3Ab',r='c%3Ar',g='c%3Ag'},{i='t%3Ainstant',s='t%3Asorcery',e='t%3Aenchantment',c='t%3Acreature',a='t%3Aartifact',l='t%3Aland',p='t%Aplaneswalker'}})do
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
    uLog(url,qTbl.color..' Importer '..qTbl.full)
    if qTbl.full:match('%s%d+')then
      for i=2,qTbl.full:match('%s(%d+)')do
        Wait.time(function()
        WebRequest.get(url,function(wr)setCard(wr,qTbl)end)end,i*Tick)end end
    WebRequest.get(url,function(wr)setCard(wr,qTbl)endLoop()end)end,
  
  Quality=function(qTbl)
    for k,v in pairs({s='small',n='normal',l='large',a='art_crop',b='border_crop'}) do
      if qTbl.name:find(v)then Quality[qTbl.player]=v end end
    endLoop()end,
  
  Deck=function(qTbl)
    if qTbl.url then
      for k,v in pairs(DeckSites) do
        if qTbl.url:find(k)then
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
local Usage=[[    [753FC9][b]%s[-]
[0077ff]Scryfall[/b] [i]cardname[/i]  [-][Spawns that card]
[b][0077ff]Scryfall[/b] [i]URL cardname[/i]  [-][Spawns [i]cardname[/i] with [i]URL[/i] as it face]
[b][0077ff]Scryfall[/b] [i]URL[/i]  [-][Spawn that deck list or Image]
[i]archidekt cubetutor cubecobra deckstats deckbox mtggoldfish scryfall tappedout pastebin[/i]

[b][ff7700]help[/b] [-][Prints this text]
[b][ff7700]deck[/b] [-][Spawn deck from newest Notebook tab]
[b][ff7700]back[/b] [i]URL[/i] [-][Makes card back URL]
[b][ff7700]text[/b] [i]name[/i] [-][Prints Oracle text of name]
[b][ff7700]print[/b] [i]name[/i] [-][Spawns various printings of name]
[b][ff7700]legal[/b] [i]name[/i] [-][Prints Legalities of name]
[b][ff7700]rules[/b] [i]name[/i] [-][Prints Rulings of name]
[b][ff7700]random[/b] [i]isecalpwubrg<>=# quantity[/i] [-][Fills field with ANY random card]
[b][ff7700]quality[/b] [i]mode[/i] [-][Changes the quality of the image]
[i]small,normal,large,art_crop,border_crop[/i] ]]
function endLoop()if Importer.request[1]then if Importer.request[1].text then Importer.request[1].text()end table.remove(Importer.request,1)end Importer()end
function delay(fN,tbl)local timerParams={function_name=fN,identifier=fN..'Timer'}
  if type(tbl)=='table'then timerParams.parameters=tbl end
  if type(tbl)=='number'then timerParams.delay=tbl*Tick
  else timerParams.delay=1.5 end
  Timer.destroy(timerParams.identifier)
  Timer.create(timerParams)
end
function uLog(a,b) if Test then log(a,b)end end
function uNotebook(t,b,c)local p={index=-1,title=t,body=b or'',color=c or'Grey'}
  for i,v in ipairs(getNotebookTabs())do if v.title==p.title then p.index=i end end
  if p.index<0 then addNotebookTab(p)else editNotebookTab(p)end return p.index end
function uVersion(wr)
  uLog(wr.is_done,'Checking Importer Version')
  local v=wr.text:match(mod_name..' Version %d+%p%d+')
  if v then v=v:match('%d+%p%d+') else v=version end
  local s='\nLatest Version '..self.getName()
  if version<tonumber(v)then s='\n[77ff00]Update Ready:'..tonumber(v)..' on Workshop[-]\n'..wr.url
  elseif version>tonumber(v)or Test then Test,s=true,'\n[fff600]Experimental Version of Importer Module'end
  Usage=Usage..s
  broadcastToAll(s,{1,0,1})
end

--[[Tabletop Callbacks]]
function onSave()self.script_state=JSON.encode(Back)end
function onLoad(data)
  Usage=Usage:format(self.getName())
  WebRequest.get(WorkshopID,self,'uVersion')
  if data~=''then Back=JSON.decode(data)else Back=JSON.decode('{"___":"https://i.stack.imgur.com/787gj.png","76561198000043097":"https://i.imgur.com/rfQsgTL.png","76561198025014348":"https://i.imgur.com/pPnIKhy.png","76561198045241564":"http://i.imgur.com/P7qYTcI.png","76561198045776458":"https://media.wizards.com/2019/images/daily/oCa6ZZvWzu.png","76561198069287630":"http://i.imgur.com/OCOGzLH.jpg","76561198079063165":"https://external-preview.redd.it/QPaqxNBqLVUmR6OZTPpsdGd4MNuCMv91wky1SZdxqUc.png?s=006bfa2facd944596ff35301819a9517e6451084"}')end
  Back=TBL.new(Back)
  self.createButton({label="+",click_function='registerModule',function_owner=self,position={0,0.2,-0.5},height=100,width=100,font_size=100,tooltip="Adds Oracle Look Up"})
  uNotebook('SHelp',Usage)
  uNotebook('SData',self.script_state)
  self.setDescription(Usage:gsub('[^\n]*\n','',1):gsub('%]  %[',']\n['):gsub('\n\n','\n'))
  printToAll(Usage,{0.9,0.9,0.9})
  if self.getLock()then registerModule()end  end

local chatToggle=false
function onChat(msg,player)
  if msg:find('[Ss]cryfall ')or msg:find('!S%S* ')then
    local a=msg:match('[Ss]cryfall (.*)')or msg:match('!S%S* (.*)')or false
    if a=='hide'and player.admin then
      chatToggle=not chatToggle
      if chatToggle then msg='supressing' else msg='showing'end
      broadcastToAll('Importer now '..msg..' Chat messages with Importer in them.\nToggle this with "Importer Hide"',{0.9,0.9,0.9})
    elseif a=='help'then
      player.print(Usage,{0.9,0.9,0.9})
    elseif a=='clear'then
      Back=TBL.new(Back.___,{})
      self.script_state=''
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
      if chatToggle then uLog(msg,player.steam_name) return false end
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