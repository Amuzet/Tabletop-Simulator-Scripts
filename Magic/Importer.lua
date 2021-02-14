--By Amuzet
mod_name,version='Card Importer',1.93
self.setName('[854FD9]'..mod_name..' [49D54F]'..version)
author,WorkshopID,GITURL='76561198045776458','https://steamcommunity.com/sharedfiles/filedetails/?id=1838051922','https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Magic/Importer.lua'

--[[Classes]]
local TBL={__call=function(t,k)if k then return t[k] end return t.___ end,__index=function(t,k)if type(t.___)=='table'then rawset(t,k,t.___())else rawset(t,k,t.___)end return t[k] end}
function TBL.new(d,t)if t then t.___=d return setmetatable(t,TBL)else return setmetatable(d,TBL)end end

textItems={}            -- pieHere, keep a table of all active textObjects
newText=setmetatable({
  type='3DText',
  position={0,2,0},
  rotation={90,0,0}},
  {__call=function(t,p,text,f)
    t.position=p
    local o=spawnObject(t)
    table.insert(textItems,o)
    o.TextTool.setValue(text)
    o.TextTool.setFontSize(f or 50)
    return function(t)
      if t then
        o.TextTool.setValue(t)
      else
        for i,oo in ipairs(textItems) do
          if oo==o then
            table.remove(textItems,i)
          end
        end
        o.destruct()
      end
    end
  end})

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
local Card=setmetatable({n=1,hwfd=true,image=false,json='',position={0,0,0},snap_to_grid=true,callback='INC',callback_owner=self,j='{"Name":"Card","Transform":{"posX":0,"posY":0,"posZ":0,"rotX":0,"rotY":180,"rotZ":180,"scaleX":1.0,"scaleY":1.0,"scaleZ":1.0},"Memo":"%s","Nickname":"%s","Description":"%s","CardID":%i00,"CustomDeck":{"%i":{"FaceURL":"%s","BackURL":"%s","NumWidth":1,"NumHeight":1,"BackIsHidden":true}}}'},
  {__call=function(t,c,qTbl)
      --NeededFeilds in c:name,type_line,cmc,card_faces,oracle_text,power,toughness,loyalty,mana_cost,highres_image
      t.json,c.face,c.oracle,c.oracleT,c.back='','','','',Back[qTbl.player]or Back.___
      local n,state,qual=t.n,false,Quality[qTbl.player]

      if qTbl.deck then
        if qTbl.deck==1 then qTbl.deck=false else
        n=Deck[qTbl.color].n+1;Deck[qTbl.color].n=n end end
      local b=n+1
      --Oracle text Handling for Split then DFC then Normal
      if c.card_faces and c.image_uris then
        for i,f in ipairs(c.card_faces)do
          f.name=f.name:gsub('"','')..'\n'..f.type_line..' '..c.cmc..'CMC'
          if i==1 then c.name=f.name end
          c.oracle=c.oracle..f.name..'\n'..setOracle(f)..(i==#c.card_faces and''or'\n')end
        elseif c.card_faces then local f=c.card_faces[1]
        c.name=f.name:gsub('"','')..'\n'..f.type_line..' '..c.cmc..'CMC DFC'
        c.oracle=setOracle(f)else
        c.name=c.name:gsub('"','')..'\n'..c.type_line..' '..c.cmc..'CMC'
        c.oracle=setOracle(c)end

      --Image Handling
      if qTbl.deck and qTbl.image and qTbl.image[n] then
        c.face=qTbl.image[n]
      elseif c.card_faces and not c.image_uris then --DFC REWORKED for STATES!
        local faceAddress=c.card_faces[1].image_uris.normal:gsub('%?.*',''):gsub('normal',qual)
        local backAddress=c.card_faces[2].image_uris.normal:gsub('%?.*',''):gsub('normal',qual)
        if faceAddress:find('/back/') and backAddress:find('/front/') then
          local temp=faceAddress;faceAddress=backAddress;backAddress=temp end
        if t.image then faceAddress,backAddress=t.image,t.image end
        if qTbl.deck then Deck[qTbl.color].n=b else t.n=b end
        c.face=faceAddress
        --TTS Decks Skip additional states of cards beyond the first
        local f=c.card_faces[2]
        local name=f.name:gsub('"','')..'\n'..f.type_line..' '..c.cmc..'CMC DFC'
        local oracle=setOracle(f)
        state=string.format(t.j,c.oracle_id,name,oracle,b,b,backAddress,c.back)
      elseif t.image then --Custom Image
        c.face=t.image
        t.image=false
      elseif c.image_uris then
        c.face=c.image_uris.normal:gsub('%?.*',''):gsub('normal',qual)
      end
      --Set JSON to Spawn Card
      t.json=string.format(t.j,c.oracle_id,c.name,c.oracle,n,n,c.face,c.back)
      if state then t.json=t.json:sub(1,t.json:len()-1)..',"States":{"2":'..state..'}}'end
      uNotebook(c.name,t.json)
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

function INC(obj)Card.n=Card.n+1 end
function setOracle(c)local n='\n[b]'
  if c.power then n=n..c.power..'/'..c.toughness
  elseif c.loyalty then n=n..tostring(c.loyalty)
  else n=false end return c.oracle_text:gsub('\"',"'")..(n and n..'[/b]'or'') end
function setCard(wr,qTbl,originalData)
  if wr.text then
    local json=JSON.decode(wr.text)
    if json.object=='card'then
      if json.lang=='en'then
        Card(json,qTbl)
      else
        WebRequest.get('https://api.scryfall.com/cards/'..json.set..'/'..json.collector_number..'/en',function(a)setCard(a,qTbl,json)end)
      end return
    elseif originalData then
      Card(json,qTbl)
    elseif json.object=='error'then Player[qTbl.color].broadcast(json.details,{1,0,0})end
  else error('No Data Returned Contact Amuzet. setCard')end endLoop()end

function parseForToken(oracle,qTbl)endLoop()end
--[[  if oracle:find('token')and oracle:find('[Cc]reate')then
    --My first attempt to parse oracle text for token info
    local ptcolorType,abilities=oracle:match('[Cc]reate(.+)(token[^\n]*)')
    --Check for power and toughness
    local power,toughness='_','_'
    if ptColorType:find('%d/%d')then
      power,toughness=ptColorType:match('(%d+)/(%d+)')end
    --It wouldn't be able to find treasure or clues
    local colors=''
    for k,v in pairs({w='white',u='blue',b='black',r='red',g='green',c='colorless'})do
     if ptColorType:find(v)then colors=colors..k end end
    --How the heck am I going to do abilities
    if abilities:find('tokens? with ')then
      local abTbl={}
      abilities=abilities:gsub('"([^"]+)"',function(a)
        table.insert(abTbl,a)return''end)
      for _,v in pairs({'haste','first strike','double strike','reach','flying'})do
        if abilities:find(v)then table.insert(abTbl,v)end end
    end
  end
end]]

function spawnList(wr,qTbl)
  uLog(wr.url)
  local txt=wr.text
  if txt then --PIE's Rework
    local jsonType = txt:sub(1,20):match('{"object":"(%w+)"')
    if jsonType=='list' then
      local nCards=txt:match('"total_cards":(%d+)')
      if nCards~=nil then nCards=tonumber(nCards) else
        -- a jsonlist but couldn't find total_cards ? shouldn't happen, but just in case
        textItems[#textItems].destruct()
        table.remove(textItems,#textItems)
        return
      end
      if tonumber(nCards)>100 then
        Player[qTbl.color].broadcast('This search query gives too many results (>100)',{1,0,0})
        textItems[#textItems].destruct()
        table.remove(textItems,#textItems)
        return
      end
      qTbl.deck=nCards
      local last=0
      local cards={}
      for i=1,nCards do
        start=string.find(txt,'{"object":"card"',last+1)
        local nopen,txti=1,start
        while nopen~=0 do
          txti=txti+1
          if txt:sub(txti,txti)=='{' then nopen=nopen+1
          elseif txt:sub(txti,txti)=='}' then nopen=nopen-1 end
        end
        last=txti
        local card = JSON.decode(txt:sub(start,last))
        Wait.time(function() Card(card,qTbl) end, i*Tick)
      end
      return

    elseif jsonType=='card' then
      local n,json=1,JSON.decode(txt)
      Card(json,qTbl)
      return

    elseif jsonType=='error' then
      local n,json=1,JSON.decode(txt)
      Player[qTbl.color].broadcast(json.details,{1,0,0})
    end
  end
  endLoop()
end

--[[DeckFormatHandle]]
local sOver={['10ED']='10E',DAR='DOM',MPS_AKH='MP2',MPS_KLD='MPS',FRF_UGIN='UGIN'}
local dFile={
  uidCheck=',%w+-%w+-%w+-%w+-%w+',uid=function(line)
    local num,uid=string.match('__'..line..'__','__%a+,(%d+).+,([%w%-]+)__')
    return num,'https://api.scryfall.com/cards/'..uid end,

  dckCheck='%[[%w_]+:%w+%]',dck=function(line)
    local num,set,col,name=line:match('(%d+).%W+([%w_]+):(%w+)%W+(%w.*)')
    local alter=name:match(' #(http%S+)')or false
    name=name:gsub(' #.+','')
    if set:find('DD3_')then set=set:gsub('DD3_','')
    elseif sOver[set]then set=sOver[set]end
    set=set:gsub('_.*',''):lower()
    return num,'https://api.scryfall.com/cards/'..set..'/'..col,alter end,

  decCheck='%[[%w_]+%]',dec=function(line)
    local num,set,name=line:match('(%d+).%W+([%w_]+)%W+(%w.*)')
    local alter=name:match(' #(http%S+)')or false
    name=name:gsub(' #.+','')
    if set:find('DD3_')then set=set:gsub('DD3_','')
    elseif sOver[set]then set=sOver[set]end
    set=set:gsub('_.*',''):lower()
    return num,'https://api.scryfall.com/cards/named?fuzzy='..name..'&set='..set,alter end,

  defCheck='%d+.%w+',def=function(line)
    local num,name=line:match('(%d+).(.*)')
    local alter=name:match(' #(http%S+)')or false
    name=name:gsub(' #.+','')
    return num,'https://api.scryfall.com/cards/named?fuzzy='..name,alter end}
--[[Deck spawning]]
function spawnDeck(wr,qTbl)
  if wr.text:find('!DOCTYPE')then
    uLog(wr.url,'Mal Formated Deck '..qTbl.color)
    uNotebook('D'..qTbl.color,wr.url)
    Player[qTbl.color].broadcast('Your Deck list could not be found\nMake sure the Deck is set to PUBLIC',{1,0.5,0})
    textItems[#textItems].destruct()    --pieHere, missed removing this txtObject last time
	  table.remove(textItems,#textItems)
  else
    uLog(wr.url,'Deck Spawned by '..qTbl.color)
    local sideboard=''
    qTbl.image={}
    local deck,list={},wr.text:gsub('\n%S*Sideboard(.*)',function(a)sideboard=a return ''end)
    if sideboard~=''then
      Player[qTbl.color].broadcast('Extraboards Found and pasted into Notebook\n"Scryfall deck" to spawn most recent Notebook Tab')
      uNotebook(qTbl.url,sideboard)end

    for b in list:gmatch('([^\r\n]+)')do
      for k,v in pairs(dFile)do
        if type(v)=='string'and b:find(v)then
          local n,a,r=dFile[k:sub(1,3)](b)
          for i=1,n do table.insert(deck,a)
            --table.insert(qTbl.image,r)
          end break end end end
    qTbl.deck=#deck

    for i,url in ipairs(deck) do
      Wait.time(function()
          WebRequest.get(url,function(c)
              setCard(c,qTbl)end)end,i*Tick)end
end end
setCSV=4
function spawnCSV(wr,qTbl)
  local side,deck,list='',{},wr.text
  for line in list:gmatch('([^\r\n]+)')do
    local tbl,l={},','..line:gsub(',("[^"]+"),',function(g)return','..g:gsub(',','')..','end)
    l=l:gsub(',',', ')
    for csv in l:gmatch(',([^,]+)')do
      if csv:len()==1 then break
      else table.insert(tbl,csv:sub(2))end end
    if #tbl<setCSV-1 then uLog(tbl)printToAll('Tell Amuzet that an Error occored in spawnCSV:\n'..qTbl.full)return endLoop()
    elseif not tbl[2]:find('%d+')then--FirstCSVLine
    elseif(setCSV==3)or(
      setCSV==4 and tbl[1]:find('main'))or(
      setCSV==7 and not tbl[1]:find('board'))then
      local b='https://api.scryfall.com/cards/named?fuzzy='..tbl[3]
      if tbl[setCSV]and tbl[setCSV]~='000'then b=b..'&set='..tbl[setCSV]end
      for i=1,tbl[2]do table.insert(deck,b)end
    else--Side/Maybe
      side=side..tbl[2]..' '..tbl[3]..'\n'
      uLog(side)
  end end
  if side~=''then
    Player[qTbl.color].broadcast('Sideboard Found and pasted into Notebook\n"Scryfall deck" to spawn most recent Notebook Tab')
    uNotebook(qTbl.url,side)end
  qTbl.deck=#deck
  for i,u in ipairs(deck)do
    Wait.time(function()
        WebRequest.get(u,function(c)
            local t=JSON.decode(c.text)
            if t.object~='card'then if u:find('&')then
              WebRequest.get(u:gsub('&.+',''),function(c)setCard(c,qTbl)end)
              else WebRequest.get('https://api.scryfall.com/cards/named?fuzzy=blankcard',function(c)setCard(c,qTbl)end)end
            else setCard(c,qTbl)end end)end,i*Tick*2)end end

local DeckSites={
  deckstats=function(a)return a:gsub('%?cb=%d.+','')..'?include_comments=1&export_txt=1',spawnDeck end,
  pastebin=function(a)return a:gsub('com/','com/raw/'),spawnDeck end,
  mtgdecks=function(a)return a..'/dec',spawnDeck end,
  
  deckbox=function(a)return a..'/export',function(r,qTbl)
    local wr={url=r.url}
    wr.text=r.text:match('%Wbody%W(.+)%W%Wbody%W'):gsub('<br.?>','\n')
    spawnDeck(wr,qTbl)end end,
--scryfall=function(a)return'https://api.scryfall.com'..a:match('(/decks/.*)')..'/export/text',spawnDeck end,
  scryfall=function(a)setCSV=7 return'https://api.scryfall.com'..a:match('(/decks/.*)')..'/export/csv',spawnCSV end,
  --https://tappedout.net/users/i_am_moonman/lists/15-11-20-temp-cube/?cat=type&sort=&fmt=csv
  tappedout=function(a)if a:find('/lists/')then setCSV=3 else setCSV=4 end
    return a:gsub('.cb=%d+','')..'?fmt=csv',spawnCSV end,
--A function which returns a url and function which handels that url's output
  mtggoldfish=function(a)
    if a:find('/archetype/')then return a,function(wr,qTbl)Player[qTbl.color].broadcast('This is an Archtype!\nPlease spawn a User made Deck.',{0.9,0.1,0.1})endLoop()end
    elseif a:find('/deck/')then return a:gsub('/deck/','/deck/download/'):gsub('#.+',''),spawnDeck
    else return a,function(wr,qTbl)Player[qTbl.color].broadcast('This MTGgoldfish url is malformated.\nOr unsupported contact Amuzet.')end end end,
  archidekt=function(a)return 'https://archidekt.com/api/decks/'..a:match('/(%d+)')..'/small/?format=json',function(wr,qTbl)
    qTbl.deck=0
    local json=wr.text
    for _,s in pairs({'types','legalities','oracleCard','prices','edition'})do json=json:gsub('"'..s..'"[^}]+},','')end
    json=json:gsub(',"ckNormalId[^}]+},','},')
    json=json:gsub(',"viewCount":.+]}','}')
    uNotebook('archidekt',json)
    json=JSON.decode(json)
    local board=''
    for _,v in pairs(json.cards)do
      if('SideboardMaybeboard'):find(v.categories[1])then
        board=board..v.quantity..' '..v.card.uid
      else for i=1,v.quantity do
        qTbl.deck=qTbl.deck+1
        Wait.time(function()
          WebRequest.get('https://api.scryfall.com/cards/'..v.card.uid,
            function(c)setCard(c,qTbl)end)end,qTbl.deck*Tick*2)end end end
    if board~=''then Player[qTbl.color].broadcast(json.name..' Sideboard and Maybeboard in notebook.\nType "Scryfall deck" to spawn it now.')
    uNotebook(json.name,board)end end end,
  cubetutor=function(a)return a,function(wr,qTbl)
    local cube,html={},wr.text:sub(100000)
    html:gsub('class="cardPreview ([^>]*>[^<]*)<',function(b)
        local s,c=b:match('cloudfront.net/([^/]+)/[^>]+>(.+)')
        if s then s=s:gsub('_.+','')
          if s:len()>3 and s:find('DDA...')then s=s:sub(4)end
        else c=b:match('>(.+)');s='pgru' end
        table.insert(cube,'https://api.scryfall.com/cards/named?fuzzy='..c..'&set='..s)
        return''end)
    qTbl.deck=#cube
    for i,u in ipairs(cube)do
      Wait.time(function()
          WebRequest.get(u,function(c)
              local t=JSON.decode(c.text)
              if t.object~='card'then
                WebRequest.get(u:gsub('&.+',''),function(c)setCard(c,qTbl)end)
              else setCard(c,qTbl)end end)end,i*Tick*2)
    end end end,
  cubecobra=function(a)return a:gsub('/cube/(%w+)/','download/csv'),function(wr,qTbl)
    local cube,list={},wr.text:gsub('[^\r\n]+','',1)
    if not qTbl.image or type(qTbl.image)~='table'then qTbl.image={}end
    for line in list:gmatch('([^\r\n]+)')do
      local tbl,n,l={},0,line:gsub('.-"','',2)
      log(line)
      table.insert(tbl,line:match('"([^"]+)"'))
      for csv in l:gmatch('(,.-),')do log(csv)
        if csv:len()==1 then table.insert(tbl,false)
        else table.insert(tbl,csv:gsub('"',''))end end
      if n<10 then n=n+1 log(tbl)end
      --if tbl[12]:find('http')then qTbl.image[n]=tbl[12]:match('"([^"]+)')end
      local b='https://api.scryfall.com/cards/'..tbl[5]..'/'..tbl[6]
      table.insert(cube,b)
    end
    qTbl.deck=#cube
    for i,url in ipairs(cube)do
      Wait.time(function()
          WebRequest.get(url,function(c)
              setCard(c,qTbl)end)end,i*Tick*2)end
    end end}
local apiSet='http://api.scryfall.com/cards/random?q=is:booster+set:'
function rarity(m,r,u)
  if math.random(1,m or 36)==1 then return'+r:mythic'
  elseif math.random(1,r or 8)==1 then return'+r:rare'
  elseif math.random(1,u or 4)==1 then return'+r:uncommon'
  else return'+r:common'end end
function typeCo(p,t)local n=math.random(13,#p);for i=13,#p do if n==i then p[i]=p[i]..'+'..t else p[i]=p[i]..'+-('..t..')'end end return p end
local Booster=setmetatable({
    dom=function(p)return typeCo(p,'t:legendary')end,
    war=function(p)return typeCo(p,'t:planeswalker')end,
    znr=function(p)return typeCo(p,'t:land+(is:spell+or+pathway)')end,
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
      table.insert(pack,u..rarity(8,1))
      return pack end end})

Booster['2xm']=function(p)p[11]=p[#p];for i=9,10 do p[i]=apiSet..'2xm'..rarity()end return p end
for _,s in pairs({'isd','dka','soi','emn'})do
    Booster[s]=function(p)local n=math.random(6,11);for i,v in pairs(p)do if i~=n then p[i]=p[i]..'+-is:transform'else p[i]=apiSet..s..rarity()..'+is:transform'end end return p end end
for _,s in pairs({'cns','cn2'})do
    Booster[s]=function(p)local n=math.random(6,11);for i,v in pairs(p)do if i~=n then p[i]=p[i]..'+-wm:conspiracy'else p[i]=apiSet..s..rarity()..'+wm:conspiracy'end end return p end end
for _,s in pairs({'rav','gpt','dis','rtr','gtc','dgm','grn','rna'})do
    Booster[s]=function(p)local n=math.random(6,11);for i,v in pairs(p)do if i~=n then p[i]=p[i]..'+-t:land'else p[i]=apiSet..s..rarity()..'+t:land+-t:basic'end end return p end end
for _,s in pairs({'ice','mh1'})do
    Booster[s]=function(p)p[math.random(6,11)]=apiSet..s..'+t:basic+t:snow'return p end end

--[[Importer Data Structure]]
Importer=setmetatable({
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
          qTbl.deck=#json.all_parts-1
          for _,v in ipairs(json.all_parts)do if json.name~=v.name then
              WebRequest.get(v.uri,function(wr)setCard(wr,qTbl)end)end end
        --What is this elseif json.oracle
        elseif json.object=='card'then
          local oracle=json.oracle_text
          if json.card_faces then
            for _,f in ipairs(json.card_faces)do oracle=oracle..json.name:gsub('"','\'')..'\n'..setOracle(f)end end
          parseForToken(oracle,qTbl)
        elseif qTbl.target then
          local o=qTbl.target.getDescription()
          if o:find('[Cc]reate')or o:find('emblem')then parseForToken(o,qTbl)
          else Player[qTbl.color].broadcast('Card not found in Scryfall\nAnd did not have oracle text to parse.',{0.9,0.9,0.9})endLoop()end
        else
          Player[qTbl.color].broadcast('No Tokens Found',{0.9,0.9,0.9})endLoop()end end)end,

  Print=function(qTbl)
    local url,n='https://api.scryfall.com/cards/search?unique=prints&q=',qTbl.name:lower():gsub('%s','')
    if('plains island swamp mountain forest'):find(n)then
      --url=url:gsub('prints','art')end
      broadcastToAll('Please Do NOT print Basics\nIf you would like a specific Basic specify that in your decklist\nor Spawn it using "Scryfall island&set=kld" the corresponding setcode',{0.9,0.9,0.9})
      endLoop()
    else
      if qTbl.oracleid~=nil then      -- pieHere, if oracleID is given use that to find prints (allows to get prints for tokens)
        WebRequest.get(url..qTbl.oracleid,function(wr)spawnList(wr,qTbl)end)
      else
        WebRequest.get(url..qTbl.name,function(wr)spawnList(wr,qTbl)end)
      end
    end
  end,

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

--pieHere, either scryfall api changed, or this was broken to begin with
--the rulings_uri returns an "object":"list" that *contains* the sought after data table, as opposed to the data table itself
Rules=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
      local cardDat = JSON.decode(wr.text)
      if cardDat.object=="error" then
        broadcastToAll(cardDat.details,{0.9,0.9,0.9})   -- pieHere, also added the error bit
	endLoop()
      elseif cardDat.object=="card" then
        WebRequest.get(cardDat.rulings_uri,function(wr)
          local data,text=JSON.decode(wr.text),'[00cc88]'
          if data.object=='list' then   -- <-- that! pieHere
            data=data.data
          end
          if data~=nil and data[1] then
            for _,v in pairs(data) do
              text=text..v.published_at..'[-]\n[ff7700]'..v.comment..'[-][00cc88]\n'
            end
          else
            text='No Rulings'
          end
          if text:len()>1000 then
            uNotebook(cardDat.name,text)
            broadcastToAll('Rulings are too long!\nFull rulings can be found in the Notebook',{0.9,0.9,0.9})
          elseif qTbl.target then
            qTbl.target.setDescription(text)
          else
            broadcastToAll(text,{0.9,0.9,0.9})
          end
          endLoop()
        end)
      end
    end)
  end,

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
        else Player[qTbl.color].broadcast(j.details,{1,0,0})endLoop()
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
    if('small normal large art_crop border_crop'):find(qTbl.name)then
      Quality[qTbl.player]=qTbl.name end endLoop()end,

  Deck=function(qTbl)
    if qTbl.url then
      for k,v in pairs(DeckSites) do
        if qTbl.url:find(k)then
          qTbl.mode='Deck'
          local url,deckFunction=v(qTbl.url)
          WebRequest.get(url,function(wr) deckFunction(wr,qTbl)end)
          return true end end
    elseif qTbl.mode=='Deck'then
      local d=getNotebookTabs();d=d[#d]
      spawnDeck({text=d.body,url='Notebook '..d.title..d.color},qTbl)
    end return false end,

    },{
  __call=function(t,qTbl)
    if qTbl then
      log(qTbl,'Importer Request '..qTbl.color)
      qTbl.text=newText(qTbl.position,Player[qTbl.color].steam_name..'\n'..qTbl.full)
      table.insert(t.request,qTbl)
    end
    --Main Logic
    if t.request[13] and qTbl then
      Player[qTbl.color].broadcast('Clearing Previous requests yours added and being processed.')
      endLoop()
    elseif qTbl and t.request[2]then
      local msg='Queueing request '..#t.request
      if t.request[4]then msg=msg..'. Queue auto clears after the 13th request!'
      elseif t.request[3]then msg=msg..'. Type `Scryfall clear queue` to Force quit the queue!'end
      Player[qTbl.color].broadcast(msg)
    elseif t.request[1]then
      local tbl=t.request[1]
      --If URL is not Deck list then
      --Custom Image Replace
      if tbl.url and tbl.mode~='Back'then
        if not t.Deck(tbl)then
        Card.image=tbl.url
        t.Spawn(tbl)end
      elseif t[tbl.mode]then t[tbl.mode](tbl)
      else t.Spawn(tbl)end--Attempt to Spawn
    elseif qTbl then broadcastToAll('Something went Wrong please contact Amuzet\nImporter did not get a mode. MAIN LOGIC')
  end end})
MODES=''
for k,v in pairs(Importer)do if not('request'):find(k)then
MODES=MODES..' '..k end end
--[[Functions used everywhere else]]
local Usage=[[    [b]%s
[-][-][0077ff]Scryfall[/b] [i]cardname[/i]  [-][Spawns that card]
[b][0077ff]Scryfall[/b] [i]URL cardname[/i]  [-][Spawns [i]cardname[/i] with [i]URL[/i] as it face]
[b][0077ff]Scryfall[/b] [i]URL[/i]  [-][Spawn that deck list or Image]
[b]Supported:[/b] [i]archidekt cubetutor cubecobra deckstats deckbox mtggoldfish scryfall tappedout pastebin[/i]
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
[b][ff7700]clear[/b] [i]back[/i]/[i]queue[/i] [-][Clears the latest request in the queue, Resets cardbacks to Default]
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
  local v=wr.text:match('mod_name,version=\'Card Importer\',(%d+%p%d+)')
  log('GITHUB Version '..v)
  if v then v=tonumber(v) else v=version end
  local s='\nLatest Version '..self.getName()
  if version>v or Test then Test,s=true,'\n[fff600]Experimental Version of Importer Module'
  elseif version<v then s='\n[77ff00]Update Ready:'..v..' Attempting Update[-]\n'..wr.url end
  Usage=Usage..s
  broadcastToAll(s,{1,0,1})
  if s:find(' Attempting Update')then
    self.setLuaScript(wr.text)
    self.reload()
  else
    registerModule()
  end
end

--[[Tabletop Callbacks]]
function onSave()self.script_state=JSON.encode(Back)end
function onLoad(data)
  for _,o in pairs(getAllObjects())do
    if o.getName():find(mod_name)and o~=self then
      if version<o.getVar('version')then
        self.destruct()
      else o.destruct()end
      break end end

  WebRequest.get(GITURL,self,'uVersion')
  if data~=''then Back=JSON.decode(data)end
  Back=TBL.new(Back)
  self.createButton({label="+",click_function='registerModule',function_owner=self,position={0,0.2,-0.5},height=100,width=100,font_size=100,tooltip="Adds Oracle Look Up"})
  Usage=Usage:format(self.getName())
  uNotebook('SHelp',Usage)
  uNotebook('SData',self.script_state)
  local u=Usage:gsub('\n\n.*','\nFull capabilities listed in Notebook: SHelp')
  self.setDescription(u:gsub('[^\n]*\n','',1):gsub('%]  %[',']\n['))
  printToAll(u,{0.9,0.9,0.9})
  onChat('Scryfall clear back')end

local SMG,SMC='[b]Scryfall: [/b]',{0.5,1,0.8}
function onPlayerConnect(player)
  if player.steam_id==author then
    printToAll(SMG..'Welcome Amuzet, creator of me. The Card Importer!',SMC)
end end
function onPlayerDisconnect(player)
  if player.steam_id==author then
    printToAll(SMG..'Goodbye Amuzet, take care of yur self buddy-o-pal!',SMC)
end end
function onDestroy()
  for _,o in pairs(textItems) do
    if o~=nil then o.destruct() end
  end
end
local chatToggle=false
function onChat(msg,p)
  if msg:find('!?[Ss]cryfall ')then
    local a=msg:match('!?[Ss]cryfall (.*)')or false
    if a=='hide'and p.admin then
      chatToggle=not chatToggle
      if chatToggle then msg='supressing' else msg='showing'end
      broadcastToAll('Importer now '..msg..' Chat messages with Importer in them.\nToggle this with "Scryfall Hide"',SMC)
    elseif a=='help'then
      p.print(Usage,{0.9,0.9,0.9})return false
    elseif a=='promote me' and p.steam_id==author then
      p.promote()
    elseif a=='clear queue'then
      version=version-1
      printToAll(SMG..'Respawning Importer!',SMC)
      self.reload()
    elseif a=='clear back'then
      self.script_state='{"76561198237455552":"https://i.imgur.com/FhwK9CX.jpg","76561198041801580":"https://earthsky.org/upl/2015/01/pillars-of-creation-2151.jpg","76561198052971595":"http://cloud-3.steamusercontent.com/ugc/1653343413892121432/2F5D3759EEB5109D019E2C318819DEF399CD69F9/","76561198053151808":"http://cloud-3.steamusercontent.com/ugc/1289668517476690629/0D8EB10F5D7351435C31352F013538B4701668D5/","76561197984192849":"https://i.imgur.com/JygQFRA.png","76561197975480678":"http://cloud-3.steamusercontent.com/ugc/772861785996967901/6E85CE1D18660E60849EF5CEE08E818F7400A63D/","76561198000043097":"https://i.imgur.com/rfQsgTL.png","76561198025014348":"https://i.imgur.com/pPnIKhy.png","76561198045241564":"http://i.imgur.com/P7qYTcI.png","76561198045776458":"https://cdnb.artstation.com/p/assets/images/images/009/160/199/medium/gui-ramalho-air-compass.jpg","76561198069287630":"http://i.imgur.com/OCOGzLH.jpg","76561198079063165":"https://external-preview.redd.it/QPaqxNBqLVUmR6OZTPpsdGd4MNuCMv91wky1SZdxqUc.png?s=006bfa2facd944596ff35301819a9517e6451084","76561198005479600":"https://images-na.ssl-images-amazon.com/images/I/61AGZ37D7eL._SL1039_.jpg","a":"Dummy"}'
      Back=TBL.new('https://i.stack.imgur.com/787gj.png',JSON.decode(self.script_state))
    elseif a then
      local tbl={position=p.getPointerPosition(),player=p.steam_id,color=p.color,url=a:match('(http%S+)'),mode=a:gsub('(http%S+)',''):match('(%S+)'),name=a:gsub('(http%S+)',''):gsub(' ',''),full=a}
      if tbl.color=='Grey'then tbl.position={0,2,0}end
      if tbl.mode then
        for k,v in pairs(Importer)do
          if tbl.mode:lower()==k:lower()and type(v)=='function'then
            tbl.mode,tbl.name=k,tbl.name:lower():gsub(k:lower(),'',1)
            break end end end

      if tbl.name:len()<1 then tbl.name='blank card'
      else tbl.name=tbl.name:gsub('%s','')end

      Importer(tbl)
      if chatToggle then uLog(msg,p.steam_name)return false end
end end end

--[[Card Encoder]]
pID=mod_name
function registerModule()
  enc=Global.getVar('Encoder')
  if enc then--Fix THIS!
    local prop={name=pID,funcOwner=self,activateFunc='toggleMenu'}
    local v=enc.getVar('version')
    buttons={'Respawn','Oracle','Rulings','Emblem\nAnd Tokens','Printings','Set Sleeve','Reverse Card'}
    if v and tonumber(v:match('%d+%.%d+'))<4.4 then
      prop.toolID=pID
      prop.display=true
      enc.call('APIregisterTool',prop)
    else
      prop.values={}
      prop.visible=true
      prop.propID=pID
      prop.tags='tool,cardImporter,Amuzet'
      enc.call('APIregisterProperty',prop)end
    function eEmblemAndTokens(o,p)ENC(o,p,'Token')end function eOracle(o,p)ENC(o,p,'Text')end function eRulings(o,p)ENC(o,p,'Rules')end function ePrintings(o,p)ENC(o,p,'Print')end function eRespawn(o,p)ENC(o,p,'Spawn')end function eSetSleeve(o,p)ENC(o,p,'Back')end
    function eReverseCard(o,p)ENC(o,p)spawnObjectJSON({json=o.getJSON():gsub('BackURL','FaceURL'):gsub('FaceURL','BackURL',1)})
end end end

function ENC(o,p,m)   -- pieHere, look for card memo/oracleid and pass it on
  enc.call('APIrebuildButtons',{obj=o})
  if m then
    if o.getName()=='' and m~='Back' then
      Player[p].broadcast('Card has no name!',{1,0,1})
    else
      local oracleid=nil
      if o.memo~=nil and o.memo~='' then
        oracleid='oracleid:'..o.memo
      end
      Importer({
        position=o.getPosition()+Vector(0,1,0)+o.getTransformRight():scale(-2.4),
        target=o,
        player=Player[p].steam_id,
        color=p,
        oracleid=oracleid,
        name=o.getName():gsub('\n.*','')or'Energy Reserve',
        mode=m,
        full='Card Encoder'
      })
    end
  end
end

function toggleMenu(o)enc=Global.getVar('Encoder')if enc then flip=enc.call("APIgetFlip",{obj=o})for i,v in ipairs(buttons)do Button(o,v,flip)end Button:reset()end end
Button=setmetatable({label='UNDEFINED',click_function='eOracle',function_owner=self,height=400,width=2100,font_size=360,scale={0.4,0.4,0.4},position={0,0.28,-1.35},rotation={0,0,90},reset=function(t)t.label='UNDEFINED';t.position={0,0.28,-1.35}end
  },{__call=function(t,o,l,f)
      local inc,i=0.325,0
      l:gsub('\n',function()t.height,inc,i=t.height+400,inc+0.1625,i+1 end)
      t.label,t.click_function,t.position,t.rotation[3]=l,'e'..l:gsub('%s',''),{0,0.28*f,t.position[3]+inc},90-90*f
      o.createButton(t)
      t.height=400
      if i%2==1 then t.position[3]=t.position[3]+0.1625 end end})
--EOF
