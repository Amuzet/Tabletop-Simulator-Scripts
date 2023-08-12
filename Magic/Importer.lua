--By Amuzet
mod_name,version='Card Importer',1.967
self.setName('[854FD9]'..mod_name..' [49D54F]'..version)
author,WorkshopID,GITURL='76561198045776458','https://steamcommunity.com/sharedfiles/filedetails/?id=1838051922','https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Magic/Importer.lua'
coauthor='76561197968157267'--PIE
lang='en'
--[[Classes]]
local TBL={__call=function(t,k)if k then return t[k] end return t.___ end,__index=function(t,k)if type(t.___)=='table'then rawset(t,k,t.___())else rawset(t,k,t.___)end return t[k] end}
function TBL.new(d,t)if t then t.___=d return setmetatable(t,TBL)else return setmetatable(d,TBL)end end

textItems={}
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
local Deck,Tick,Test,Quality,Back=1,0.2,false,TBL.new('normal',{}),TBL.new('https://i.stack.imgur.com/787gj.png',{})

--Image Handler
function trunkateURI(uri,q,s)
  if q=='png' then uri=uri:gsub('.jpg','.png')end
  return uri:gsub('%?.*',''):gsub('normal',q)..s
end
--[[Card Spawning Class]]
-- pieHere:
-- replaced spawnObjectJSON with spawnObjectData, cuz TTS's JSON stuff sucks anyways
-- spawning deck old-school style, not one card at a time
-- added a pcall "restart on error" just in case
local Card=setmetatable({n=1,image=false},
  {__call=function(t,c,qTbl)
    success,errorMSG=pcall(function()
      --NeededFeilds in c:name,type_line,cmc,card_faces,oracle_text,power,toughness,loyalty
      c.face,c.oracle,c.back='','',Back[qTbl.player] or Back.___
      local n,state,qual,imgSuffix=t.n,false,Quality[qTbl.player],''
      t.n=n+1
      --Check for card's spoiler image quality
      if c.image_status~='highres_scan' then
        imgSuffix='?'..tostring(os.date('%x')):gsub('/', '')
      end

			local orientation={false}--Tabletop Card Sideways
			--Oracle text Handling for Split then DFC then Normal
      if c.card_faces and c.image_uris then--Adventure/Split
				local instantSorcery=0
        for i,f in ipairs(c.card_faces)do
					f.name=f.name:gsub('"','')..'\n'..f.type_line..'\n'..c.cmc..'CMC'
          if i==1 then c.name=f.name end
          c.oracle=c.oracle..f.name..'\n'..setOracle(f)..(i==#c.card_faces and''or'\n')
					
					--Count nonPermanent text boxes, exclude Aftermath
					if not c.oracle:find('Aftermath')and
					('InstantSorcery'):find(f.type_line)then
						instantSorcery=1+instantSorcery end
				end
				if instantSorcery==2 then--Split/Fuse
					orientation[1]=true end

			elseif c.card_faces then--DFC
				local f=c.card_faces[1]
        c.name=f.name:gsub('"','')..'\n'..f.type_line..'\n'..c.cmc..'CMC DFC'
        c.oracle=setOracle(f)
				for i,face in ipairs(c.card_faces)do
					if face.type_line:find('Battle')then
						orientation[i]=true
					else
						orientation[i]=false
					end
					print(i..' '..tostring(orientation[i]))
				end
			else--NORMAL
        c.name=c.name:gsub('"','')..'\n'..c.type_line..'\n'..c.cmc..'CMC'
        c.oracle=setOracle(c)
				if('planar'):find(c.layout)then orientation[1]=true end
      end

      local backDat=nil
      --Image Handling
      if qTbl.deck and qTbl.image and qTbl.image[n] then
        c.face=qTbl.image[n]
      elseif c.card_faces and not c.image_uris then --DFC REWORKED for STATES!
        local faceAddress=trunkateURI( c.card_faces[1].image_uris.normal , qual , imgSuffix )
        local backAddress=trunkateURI( c.card_faces[2].image_uris.normal , qual , imgSuffix )
        if faceAddress:find('/back/') and backAddress:find('/front/') then
          local temp=faceAddress;faceAddress=backAddress;backAddress=temp end
        if t.image then faceAddress,backAddress=t.image,t.image end
        c.face=faceAddress
        local f=c.card_faces[2]
        local name=f.name:gsub('"','')..'\n'..f.type_line..'\n'..c.cmc..'CMC DFC'
        local oracle=setOracle(f)
        local b=n
				
        if qTbl.deck then b=qTbl.deck+n end
        backDat={
          Transform={posX=0,posY=0,posZ=0,rotX=0,rotY=0,rotZ=0,scaleX=1,scaleY=1,scaleZ=1},
          Name="Card",
          Nickname=name,
          Description=oracle,
          Memo=c.oracle_id,
          CardID=b*100,
          CustomDeck={[b]={
							FaceURL=backAddress,
							BackURL=c.back,
							NumWidth=1,NumHeight=1,Type=0,
							BackIsHidden=true,UniqueBack=false}},
        }
      elseif t.image then --Custom Image
        c.face=t.image
        t.image=false
      elseif c.image_uris then
        c.face=trunkateURI( c.image_uris.normal , qual , imgSuffix )
      end

      -- prepare cardDat
      local cardDat={
        Transform={posX=0,posY=0,posZ=0,rotX=0,rotY=0,rotZ=0,scaleX=1,scaleY=1,scaleZ=1},
        Name="Card",
        Nickname=c.name,
        Description=c.oracle,
        Memo=c.oracle_id,
        CardID=n*100,
        CustomDeck={[n]={
						FaceURL=c.face,
						BackURL=c.back,
						NumWidth=1,NumHeight=1,Type=0,
						BackIsHidden=true,UniqueBack=false}},
      }
			
      if backDat then --backface is state#2
        cardDat.States={[2]=backDat}end
			
			local landscapeView={0,180,270}
			--AltView
			if orientation[1]then cardDat.AltLookAngle=landscapeView end
			if orientation[2]then cardDat.States[2].AltLookAngle=landscapeView end

      -- Spawn
      if not(qTbl.deck) or qTbl.deck==1 then        --Spawn solo card
        local spawnDat={
          data=cardDat,
          position=qTbl.position or {0,2,0},
          rotation=Vector(0,Player[qTbl.color].getPointerRotation(),0)
        }
        spawnObjectData(spawnDat)
        uLog(qTbl.color..' spawned '..c.name:gsub('\n.*',''))
        endLoop()
      else                          --Spawn deck
        if Deck==1 then             --initialize deckDat
          deckDat={}
          deckDat={
            Transform={posX=0,posY=0,posZ=0,rotX=0,rotY=0,rotZ=0,scaleX=1,scaleY=1,scaleZ=1},
            Name="Deck",
            Nickname=Player[qTbl.color].steam_name or "Deck",
            Description=qTbl.full or "Deck",
            DeckIDs={},
            CustomDeck={},
            ContainedObjects={},
          }
        end
        deckDat.DeckIDs[Deck]=cardDat.CardID      -- add card info into deckDat
        deckDat.CustomDeck[n]=cardDat.CustomDeck[n]
        deckDat.ContainedObjects[Deck]=cardDat
        if Deck<qTbl.deck then
          qTbl.text('Spawning here\n'..Deck..' cards loaded')
          Deck=Deck+1
        elseif Deck==qTbl.deck then
          local spawnDat={
            data=deckDat,
            position=qTbl.position or {0,2,0},
            rotation=Vector(0,Player[qTbl.color].getPointerRotation(),180)
          }
          spawnObjectData(spawnDat)
          Player[qTbl.color].broadcast('All '..Deck..' cards loaded!',{0.5,0.5,0.5})
          Deck=1
          endLoop()
        end
      end
    end)
    if not success then
      printToAll('Something went wrong and the importer crashed, giving the error:',{1,0,0})
      printToAll(errorMSG,{0.8,0,0})
      printToAll("If you were doing everything you were supposed to, please let Amuzet know on discord or the workshop page (please remember what you typed to get the error, and the error message itself).",{0,1,1})
      printToAll('Restarting Importer...',{0,0.5,1})
      for i,o in ipairs(textItems) do
        if o~=nil then
          o.destruct()
        end
      end
      self.reload()
    end
  end})

function setOracle(c)local n='\n[b]'
  if c.power then n=n..c.power..'/'..c.toughness
  elseif c.loyalty then n=n..tostring(c.loyalty)
  else n=false end return c.oracle_text:gsub('\"',"'")..(n and n..'[/b]'or'') end

function setCard(wr,qTbl,originalData)
  if wr.text then
    local json=JSON.decode(wr.text)
		
    if json.object=='card' then
			
			--Fancy Art Series
			if originalData and originalData.layout=='art_series'then
				for k in ('mana_cost type_line oracle_text colors power toughness loyalty'):gmatch('%S+')do
					--if json.card_faces and json.card_faces then
						for i=1,2 do
							if json.card_faces and json.card_faces[i][k]then
								originalData.card_faces[i][k]=json.card_faces[i][k]
							elseif json[k]then
								originalData.card_faces[i][k]=json[k]
				end end end
				for k in ('cmc type_line color_identity layout'):gmatch('%S+')do
					if json[k]then
						originalData[k]=json[k]
				end end
				if json.image_uris then
					originalData.card_faces[2].image_uris = json.image_uris
				else
					originalData.card_faces[2].image_uris = json.card_faces[2].image_uris
				end

			elseif json.layout=='art_series'then
				WebRequrest.get('http://api.scryfall.com/cards/named?fuzzy='..json.card_faces[1].name,function(request)
          local locale_json = JSON.decode(request.text)
          if locale_json.object=='error' then
            Card(json,qTbl)
          else
            setCard(request, qTbl, json)
          end
        end)

      elseif json.lang==lang then
        Card(json, qTbl)
      elseif json.lang=='en' then
        WebRequest.get('https://api.scryfall.com/cards/'..json.set..'/'..json.collector_number..'/'..lang,function(request)
          local locale_json = JSON.decode(request.text)
          if locale_json.object=='error' then
            Card(json,qTbl)
          else
            setCard(request, qTbl, json)
          end
        end)
      else
        WebRequest.get('https://api.scryfall.com/cards/'..json.set..'/'..json.collector_number..'/en',function(a)setCard(a,qTbl,json)end)
      end
      return
    -- elseif originalData then
      -- Card(json,qTbl)
-- pieHere: ^^^
-- the above bit is probably supposed to be Card(originalData,qTbl) to spawn the original foreign card instead of the error json?
-- replaced with a fuzzy search on the card name instead --> seems to find/get the english version after all
    elseif originalData and originalData.name then
      WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..originalData.name:gsub('%W',''),function(a)setCard(a,qTbl)end)
      return
    elseif json.object=='error' then
      Player[qTbl.color].broadcast(json.details,{1,0,0})
      endLoop()
      return
    end
  else
    error('No Data Returned Contact Amuzet. setCard')
  end
  endLoop()
end

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
        endLoop()   --pieHere, I missed this one too
        return
      end
      if tonumber(nCards)>100 then
        Player[qTbl.color].broadcast('This search query gives too many results (>100)',{1,0,0})
        textItems[#textItems].destruct()
        table.remove(textItems,#textItems)
        endLoop()   --pieHere, I missed this one too
        return
      end
      qTbl.deck=nCards
      local last=0
      local cards={}
      for i=1,nCards do
        start=string.find(txt,'{"object":"card"',last+1)
        last=findClosingBracket(txt,start)
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
    if num==nil or name==nil then    --pieHere, avoids that one edge-case error with deckstats decks
      return 0,'',''
    end
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
    textItems[#textItems].destruct()
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
          end
          break
        end
      end
    end
    qTbl.deck=#deck

    for i,url in ipairs(deck) do
      Wait.time(function()
                  WebRequest.get(url,function(c) setCard(c,qTbl) end)
                end,i*Tick)
    end
  end
end

setCSV=4
function spawnCSV(wr,qTbl)
  local side,deck,list='',{},wr.text
  for line in list:gmatch('([^\r\n]+)')do
    local tbl,l={},','..line:gsub(',("[^"]+"),',function(g)return','..g:gsub(',','')..','end)
    l=l:gsub(',',', ')
    for csv in l:gmatch(',([^,]+)')do
      if csv:len()==1 then break
      else
        table.insert(tbl,csv:sub(2))
      end
    end
    if #tbl<setCSV-1 then uLog(tbl)printToAll('Tell Amuzet that an Error occored in spawnCSV:\n'..qTbl.full)
      endLoop()
      return
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
    end
  end
  if side~=''then
    Player[qTbl.color].broadcast('Sideboard Found and pasted into Notebook\n"Scryfall deck" to spawn most recent Notebook Tab')
    uNotebook(qTbl.url,side)
  end
  qTbl.deck=#deck
  for i,u in ipairs(deck)do
    Wait.time(function()
                WebRequest.get(u,function(c)
                                   local t=JSON.decode(c.text)
                                   if t.object~='card'then
                                     if u:find('&') then
                                       WebRequest.get(u:gsub('&.+',''),function(c)setCard(c,qTbl)end)
                                     else
                                       WebRequest.get('https://api.scryfall.com/cards/named?fuzzy=blankcard',function(c)setCard(c,qTbl)end)
                                     end
                                   else
                                     setCard(c,qTbl)
                                   end
                end)
    end,i*Tick*2)
  end
end

local DeckSites={
  moxfield=function(a)      -- PieHere: added moxfield support
    local urlSuffix = a:match("moxfield%.com/decks/(.*)")
    local deckID = urlSuffix:match("([^%s%?/$]*)")
    local url = "https://api.moxfield.com/v2/decks/all/" .. deckID .. "/"
    return url,function(wr,qTbl)
      local deckName = wr.text:match('"name":"(.-)","description"'):gsub('(\\u....)',''):gsub('%W','')
      local startInd=1
      local endInd
      local keepGoing=true
      local cards={}
      n=0
      while keepGoing do
        n=n+1
        startInd=wr.text:find('{"quantity":',startInd)
        if startInd==nil then keepGoing=false break end
        endInd=findClosingBracket(wr.text,startInd)
        if endInd==nil then keepGoing=false break end
        local cardSnip = wr.text:sub(startInd,endInd)
        card={
          quantity=cardSnip:match('"quantity":(%d+)'),
          boardType=cardSnip:match('"boardType":"(%a+)"'),
          scryfall_id=cardSnip:match('"scryfall_id":"(.-)"'),
          name=cardSnip:match('"name":"(.-)"'):gsub('(\\u....)',''),
        }
        table.insert(cards,card)
        startInd=endInd+1
      end
      local sideboard=''
      qTbl.deck=0
      for i,card in ipairs(cards) do
        if card.boardType=='sideboard' or card.boardType=='maybeboard' then
          sideboard=sideboard..card.quantity..' '..card.name..'\n'
        elseif card.boardType=='mainboard' or card.boardType=='commanders' or card.boardType=='companions' then
          for i=1,card.quantity do
            qTbl.deck=qTbl.deck+1
            Wait.time(function()
              WebRequest.get('https://api.scryfall.com/cards/'..card.scryfall_id,
                function(c)setCard(c,qTbl)end)end,qTbl.deck*Tick*2)
          end
        end
      end
      if sideboard~='' then
        Player[qTbl.color].broadcast(deckName..' Sideboard and Maybeboard in notebook.\nType "Scryfall deck" to spawn it now.')
        uNotebook(deckName,sideboard)
      end
    end
  end,
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
    json=JSON.decode(json)
    local board=''
    for _,v in pairs(json.cards)do
      for i=1,v.quantity do
        qTbl.deck=qTbl.deck+1
        Wait.time(function()
          WebRequest.get('https://api.scryfall.com/cards/'..v.card.uid,
            function(c)setCard(c,qTbl)end)end,qTbl.deck*Tick*2)end end
    if board~=''then Player[qTbl.color].broadcast(json.name..' Sideboard and Maybeboard in notebook.\nType "Scryfall deck" to spawn it now.')
    uNotebook(json.name,board)end end end,

  cubecobra=function(a)return a:gsub('list','download/csv')..'?showother=false',function(wr,qTbl)
    local cube,list={},wr.text:gsub('[^\r\n]+','',1)
    if not qTbl.image or type(qTbl.image)~='table'then qTbl.image={}end
    local c = 0
    for line in list:gmatch('([^\r\n]+)')do
      local tbl,n,l={},0,line:gsub('.-"','',2)
      --Grab all non-empty strings surrounded by quotes, will include set and cn
      for obj in line:gmatch('([^"]+)') do
          table.insert(tbl,obj)
      end
      --Only include cards that aren't on the maybeboard
      if line:match(',false,') then
        local b='https://api.scryfall.com/cards/'..tbl[5]..'/'..tbl[7]
        c=c+1
        if tbl[9]:match('http') then
            qTbl.image[c]=tbl[9]
        end
        Wait.time(function() WebRequest.get(b,function(c)setCard(c,qTbl)end) end,c*Tick)
      end
    end
    qTbl.deck = c
  end end}
local apiRnd='http://api.scryfall.com/cards/random?q='
local apiSet=apiRnd..'is:booster+s:'
function rarity(m,r,u)
  if math.random(1,m or 36)==1 then return'r:mythic'
  elseif math.random(1,r or 8)==1 then return'r:rare'
  elseif math.random(1,u or 4)==1 then return'r:uncommon'
  else return'r:common'end end
function typeCo(p,t)local n=math.random(#p-1,#p)for i=13,#p do if n==i then p[i]=p[i]..'+'..t else p[i]=p[i]..'+-('..t..')'end end return p end
local Booster=setmetatable({
    dom=function(p)return typeCo(p,'t:legendary')end,
    war=function(p)return typeCo(p,'t:planeswalker')end,
    znr=function(p)return typeCo(p,'t:land+is:mdfc')end,
    tsp='tsb',mb1='fmb1',mh2='h1r',stx='sta',--Garenteed
    bfz='exp',ogw='exp',kld='mps',aer='mps',akh='mp2',hou='mp2',bro='brr'--Masterpiece
  },{__call=function(t,set,n)
    local pack,u={},apiSet..set..'+'
    u=u:gsub('%+s:%(','+(')
    if not n and t[set]and type(t[set])=='function'then
      return t[set](t(set,true))
    else
      for c in('wubrg'):gmatch('.')do table.insert(pack,u..'r:common+c>='..c)end
      for i=1,6 do table.insert(pack,u..'r:common+-t:basic')end
      --masterpiece math replaces 11th Common
      if not n and((t[set]and math.random(1,144)==1)or('tsp mb1 mh2 sta'):find(set))then
        pack[#pack]=apiSet..t[set]end
      for i=1,3 do table.insert(pack,u..'r:uncommon')end
      table.insert(pack,u..rarity(8,1))
      return pack end end})
--ReplacementSlot
function rSlot(p,s,a,b)for i,v in pairs(p)do if i~=6 then p[i]=v..a else p[i]=apiSet..s..'+'..rarity()..b end end return p end
--Weird Boosters
Booster['tsr']=function(p)p[11]=p[9]:gsub('is:booster+r:common','r:special')return p end
Booster['unf']=function(p)local j=rSlot(p,'unf','+-t:Attraction','+t:Attraction')
  table.insert(j,j[6])return j end
Booster['ust']=function(p)local j=rSlot(p,'ust','+-t:Contraption','+t:Contraption')
  table.insert(j,j[6])return j end
for s in('clb cmr'):gmatch('%S+')do
  Booster[s]=function(p)--wubrg CCCCC CCUUU URLLF
    local u=apiSet..s..'+t:legendary+'--L
    p[#p]=p[#p]..'+-t:legendary'
    table.insert(p,12,p[12])
    table.insert(p,6,p[6])
    table.insert(p,u..rarity(8,1))
    table.insert(p,u..rarity(8,1))
    table.insert(p,apiSet..s..'+is:etched')
    printToAll('20 Card Booster, draft two each pick')
    return p end end
for s in('2xm 2x2'):gmatch('%S+')do
  Booster[s]=function(p)p[11]=p[12];table.insert(p,apiSet..s..'+'..rarity(8,1))return p end end
--Booster['2xm']=function(p)p[11]=p[#p]for i=9,10 do p[i]=apiSet..'2xm'..'+'..rarity()end return p end
for s in('isd dka soi emn'):gmatch('%S+')do
  Booster[s]=function(p)return rSlot(p,s,'+-is:transform','+is:transform')end end
for s in('mid vow'):gmatch('%S+')do--Crimson Moon
  Booster[s]=function(p)local n=math.random(#p-1,#p)for i,v in pairs(p)do if i==6 or i==n then p[i]=p[i]..'+is:transform'else p[i]=p[i]..'+-is:transform'end end return p end end
for s in('cns cn2'):gmatch('%S+')do
  Booster[s]=function(p)return rSlot(p,s,'+-wm:conspiracy','+wm:conspiracy')end end
for s in('rav gpt dis rtr gtc dgm grn rna'):gmatch('%S+')do
  Booster[s]=function(p)return rSlot(p,s,'+-t:land','+t:land+-t:basic')end end
for s in('ice all csp mh1 khm'):gmatch('%S+')do
  Booster[s]=function(p)p[6]=apiSet..s..'+t:basic+t:snow'return p end end
--wubrg CCCCC CUUUR LLYUF
Booster['cmm']=function(p)
	for i=12,15 do p[i]=p[i]..'+-t:legendary'end
	local sL=apiSet..'cmm+t:legendary'
	--2 Legendaries
	table.insert(p,sL)
	table.insert(p,sL)
	--1 Rare+ Legendary
	table.insert(p,sL..'+'..rarity(8,1))
	--1 more Uncommon
	table.insert(p,apiSet..'cmm+r:uncommon+-t:legendary')
	--1 any Foil
	table.insert(p,apiSet..'cmm+'..rarity())
	--20 Total
	return p end

--Custom Booster Packs
Booster.CMMDRAFT=function(qTbl)return Booster('cmm',true)end
Booster.ADAMS=function(qTbl)
  local pack,u={},'http://api.scryfall.com/cards/random?q=f:standard+'
  for c in ('wubrg'):gmatch('.')do
    table.insert(pack,u..'r:common+c:'..c)end
  for i=1,5 do table.insert(pack,u..'r:common+-t:basic')end
  for i=1,3 do table.insert(pack,u..'r:uncommon')end
  table.insert(pack,u..rarity(8,1))
  table.insert(pack,u..'t:basic')
  table.insert(pack,u:sub(1,39)..'(border:borderless+or+frame:showcase+or+set:plist)')
  if math.random(1,2)==1 then pack[#pack-1]=pack[#pack]end
  return pack end
Booster.STANDARD=function(qTbl)
  local pack,u={},'http://api.scryfall.com/cards/random?q=f:standard+'
  for c in ('wubrg'):gmatch('.')do
    table.insert(pack,u..'r:common+c:'..c)end
  for i=1,5 do table.insert(pack,u..'r:common+-t:basic')end
  for i=1,3 do table.insert(pack,u..'r:uncommon')end
  table.insert(pack,u..rarity(8,1))
  table.insert(pack,u..'t:basic')
  table.insert(pack,u:sub(1,39)..'(border:borderless+or+frame:showcase+or+set:plist)')
  if math.random(1,2)==1 then pack[#pack-1]=pack[#pack]end
  return pack end
Booster.MANAMARKET=function(qTbl)
  local pack,u={},'http://api.scryfall.com/cards/random?q=f:standard+'
  for c in ('wubrg'):gmatch('.')do
    table.insert(pack,u..'r:common+c:'..c)end
  for i=1,5 do table.insert(pack,u..'r:common+-t:basic')end
  for i=1,3 do table.insert(pack,u..'r:uncommon')end
  table.insert(pack,u..rarity(8,1))
  table.insert(pack,u..'t:basic')
  table.insert(pack,u:sub(1,39)..'(set:tafr+or+set:tstx+or+set:tkhm+or+set:tznr+or+set:sznr+or+set:tm21+or+set:tiko+or+set:tthb+or+set:teld)')
  for i=#pack-1,#pack do
    if math.random(1,2)==1 then
      pack[i]=u..'(border:borderless+or+frame:showcase+or+frame:extendedart+or+set:plist+or+set:sta)'
    end end
  return pack end
Booster.PLANAR=function(qTbl)
	--((t:plane or t:phenomenon) o:planeswalk) or 
	local u='http://api.scryfall.com/cards/random?q='
	local additional="+or+o:'planar+di'+or+o:'will+of+the+planeswalker'"
	
	local pack={
	u..'frame:2015+c=w',
	u..'frame:2015+c=u',
	u..'frame:2015+c=b',
	u..'frame:2015+c=r',
	u..'frame:2015+c=g',
	u..'frame:2015+c=c',
	u..'frame:2015+c>1',
	u..'frame:2015+c<2+id>1',
	u..'frame:2015+-is:permanent',
	u..'frame:2015+-t:creature',
	u..'frame:2015+is:french_vanilla',
	u..'((t:plane+or+t:phenomenon)+o:planeswalk)',
	u..'((t:plane+or+t:phenomenon)+-o:planeswalk)',
	u..'(t:plane+or+t:phenomenon)'..additional,
	u..'t:planeswalker'}
	
	return pack end
--PLANES
Booster.CONSPIRACY=function(qTbl)--wubrgCCCCCTUUURT
  local p=Booster('(s:cns+or+s:cn2)')
  local z=p[#p]:gsub('r:%S+',rarity(9,6,3))
  table.insert(p,z)
  p[6]=p[math.random(10,12)]
  for i,s in pairs(p)do
    if i==6 or i==#p then
      p[i]=p[i]..'+wm:conspiracy'
    else p[i]=p[i]..'+-wm:conspiracy'end end
  return p end
Booster.INNISTRAD=function(qTbl)--wubrgDCCCCDUUURD
  local p=Booster('(s:isd+or+s:dka+or+s:avr+or+s:soi+or+s:emn+or+s:mid+s:vow)')
  local z=p[#p]:gsub('r:%S+',rarity(8,1))
  table.insert(p,z)
  p[11]=p[12]
  for i,s in pairs(p)do
    if i==6 or i==11 or i==#p then
      p[i]=p[i]..'+is:transform'
    else p[i]=p[i]..'+-is:transform'end end
  return p end
Booster.RAVNICA=function(qTbl)--wubrgmmm???UUURL
  local l,p='t:land+-t:basic',Booster('(s:rav+or+s:gpt+or+s:dis+or+s:rtr+or+s:gtc+or+s:dgm+or+s:grn+or+s:rna)')
  table.insert(p,p[#p])
  for i=6,8 do p[i]=p[8]..'+id>=2'end
  for i=9,math.random(9,11)do p[i]=p[11]..'+id<=1'end
  for i,s in pairs(p)do
    if i==#p then
      p[i]=p[i]:gsub('r:%S+',rarity(9,6,3))..'+'..l
    else p[i]=p[i]..'+-'..l end end
  return p end
Booster.KAMIGAWA=function(qTbl)--wubrgCCCCCCUUURN
  local p=Booster('(s:chk+or+s:bok+or+s:sok+or+s:neo)')
  local z=p[#p]:gsub('r:%S+',rarity(8,4,1)..'+t:legendary')
  table.insert(p,z)
  --{'t:creature','t:creature','-t:creature','t:equipment','t:artifact -t:equipment','(t:saga or t:shrine or t:aura)','t:enchantment -(t:saga or t:shrine or t:aura)'}
  return p end
Booster.MIRRODIN=function(qTbl)
  local p=Booster('(s:mrd+or+s:dst+or+s:5dn+or+s:som+or+s:mbs+or+s:nph)')
  return p end
Booster.PHYREXIA=function(qTbl)
  local p=Booster.MIRRODIN(qTbl)
  table.insert(p,p[#p])
  p[11]=p[12]
  local s='(wm:phyrexian+or+ft:phyrex+or+phyrex+or+yawgmoth+or+is:phyrexian+or+ft:yawgmoth+or+art:phyrexian)+(is:spell+or+t:land)'
  for _,i in pairs({6,11,#p})do
    p[i]=p[i]:gsub('%b()',s)end
  return p end
Booster.ZENDIKAR=function(qTbl)
  local p=Booster('(s:zen+or+s:wwk+or+s:roe+or+s:bfz+or+s:ogw+or+s:znr)')
  --Masterpiece
  local mSlot='(s:exp+or+s:zne)'
  if math.random(144)~=1 then
    p[6]=p[6]:gsub('%(.+',mSlot)end
  return p end
Booster.HELP=function(qTbl)
  local s=''
  for k,_ in pairs(Booster)do
    if k==k:upper()then
      s=s..'[i][ff7700]'..k..'[/i] , '
    end
  end
--NotWorking[b][0077ff]Scryfall booster[/b] [i](t:artifact)[/i]  [-][Spawn a Booster with all cards matching that search querry, in this case only Artifacts]
  Player[qTbl.color].broadcast([[
[b][0077ff]Scryfall booster[/b] [i]xln[/i]  [-][Spawns Ixalan Booster]
[b][0077ff]Scryfall booster[/b] [i]SET[/i]  [-][Spawns a Booster with that [i]SET[/i] code as defined by Scryfall.com]

[b]Custom Masters Packs[/b] [The following list are Double Master like packs made by Amuzet and friends]
 > ]]..s)
  return Booster('plist')end
  
function spawnPack(qTbl,pack)
  qTbl.deck=#pack
  qTbl.mode='Deck'
  log(pack)
	--TODO: prevent dups, divert to a seperate function before setCard()
  for i,u in pairs(pack)do
    Wait.time(function()WebRequest.get(u,function(wr)
					if wr.text:find('object:"error"')then log(u)end
					--Divert here
          setCard(wr,qTbl)end)end,i*Tick)end
	--Store the returned pack check for dups
	--Rerun pack if dups 3 of same or more than a pair
	--Exclude Multiverse ID
end
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
    local url,n='https://api.scryfall.com/cards/search?unique=prints&q=',qTbl.name:lower():gsub('%s',''):gsub('%%20','')    -- pieHere, making search with spaces possible
    if('plains island swamp mountain forest'):find(n)then
      --url=url:gsub('prints','art')end
      broadcastToAll('Please Do NOT print Basics\nIf you would like a specific Basic specify that in your decklist\nor Spawn it using "Scryfall island&set=kld" the corresponding setcode',{0.9,0.9,0.9})
      endLoop()
    else
      if qTbl.oracleid~=nil then
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

  Rules=function(qTbl)
    WebRequest.get('https://api.scryfall.com/cards/named?fuzzy='..qTbl.name,function(wr)
      local cardDat = JSON.decode(wr.text)
      if cardDat.object=="error" then
        broadcastToAll(cardDat.details,{0.9,0.9,0.9})
	      endLoop()
      elseif cardDat.object=="card" then
        WebRequest.get(cardDat.rulings_uri,function(wr)
          local data,text=JSON.decode(wr.text),'[00cc88]'
          if data.object=='list' then
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
    qTbl.url='Booster '..qTbl.name
    if Booster[qTbl.name:upper()]then
      spawnPack(qTbl,Booster[qTbl.name:upper()](qTbl))

		elseif #qTbl.name<5 then
      if qTbl.name==''then qTbl.name='ori'end
      WebRequest.get('https://api.scryfall.com/sets/'..qTbl.name,function(w)
        local j=JSON.decode(w.text)
        if j.object=='set'then
          qTbl.url='Booster '..j.name
          spawnPack(qTbl,Booster(qTbl.name))
      else Player[qTbl.color].broadcast(j.details,{1,0,0})endLoop()end end)

		elseif qTbl.name:find('%W')then
      Player[qTbl.color].broadcast('Attempting custom Booster:\n '..qTbl.name)
      if qTbl.name:find('^%(')then else
        qTbl.name='('..qTbl.name..')'end
      spawnPack(qTbl,Booster(qTbl.name))
    else Player[qTbl.color].broadcast('No Booster found to make')endLoop()end end,

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
    if('small normal large art_crop border_crop'):find(qTbl.name) then
      Quality[qTbl.player]=qTbl.name
    end
    endLoop()
  end,

  Lang=function(qTbl)
    lang=qTbl.name
    if lang and lang~=''then
      p.print('Change the language to '..lang,{0.9,0.9,0.9})return false
    else
      p.print('Please type specific language',{0.9,0.9,0.9})return false
    end endLoop()
  end,

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

  Rawdeck=function(qTbl)
    if qTbl.target then
      local dec=qTbl.target.getDescription()
      
      spawnDeck({text=dec,url='Description '..qTbl.target.getName()},qTbl)
    end end,

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
[b]Supported:[/b] [i]archidekt cubecobra deckstats deckbox moxfield mtggoldfish scryfall tappedout pastebin[/i]
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
  for _,o in pairs(getObjects())do
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
  -- uNotebook('SData',self.script_state)   -- pieHere, remove the debug text popping into the notebook
  local u=Usage:gsub('\n\n.*','\nFull capabilities listed in Notebook: SHelp')
  u=u..'\nWhats New: Now actually spawns Time Spiral Remastered Cards.'
  self.setDescription(u:gsub('[^\n]*\n','',1):gsub('%]  %[',']\n['))
  printToAll(u,{0.9,0.9,0.9})
  onChat('Scryfall clear back')end
function onDestroy()
  for _,o in pairs(textItems) do
    if o~=nil then o.destruct() end
end end

local SMG,SMC='[b]Scryfall: [/b]',{0.5,1,0.8}
function AP(p,s)printToAll(SMG..s:format(p.steam_name),SMC)end
function onPlayerConnect(p)
      if p.steam_id==author   then AP('Welcome %s, creator of me. The Card Importer!')
  elseif p.steam_id==coauthor then AP('Praise be to %s!')end end
function onPlayerDisconnect(p)
      if p.steam_id==author   then AP('Goodbye %s, take care of yur self buddy-o-pal!')
  elseif p.steam_id==coauthor then AP('𝜋 doesn\'t terminate, but %s does.')end end

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
      self.script_state=string.gsub([[{
"76561198015252567":"https://static.wikia.nocookie.net/mtgsalvation_gamepedia/images/5/5c/Cardback_reimagined.png",
"76561198237455552":"https://i.imgur.com/FhwK9CX.jpg",
"76561198041801580":"https://earthsky.org/upl/2015/01/pillars-of-creation-2151.jpg",
"76561198052971595":"http://cloud-3.steamusercontent.com/ugc/1653343413892121432/2F5D3759EEB5109D019E2C318819DEF399CD69F9/",
"76561198053151808":"http://cloud-3.steamusercontent.com/ugc/1289668517476690629/0D8EB10F5D7351435C31352F013538B4701668D5/",
"76561197984192849":"https://i.imgur.com/JygQFRA.png",
"76561197975480678":"http://cloud-3.steamusercontent.com/ugc/772861785996967901/6E85CE1D18660E60849EF5CEE08E818F7400A63D/",
"76561198000043097":"https://i.imgur.com/rfQsgTL.png",
"76561198025014348":"https://i.imgur.com/pPnIKhy.png",
"76561198045241564":"http://i.imgur.com/P7qYTcI.png",
"76561198045776458":"https://cdnb.artstation.com/p/assets/images/images/009/160/199/medium/gui-ramalho-air-compass.jpg",
"76561198069287630":"http://i.imgur.com/OCOGzLH.jpg",
"76561198005479600":"https://images-na.ssl-images-amazon.com/images/I/61AGZ37D7eL._SL1039_.jpg",
"76561198317076000":"https://i.imgur.com/vh8IeEn.jpeg"}]],'\n','')

			Back=TBL.new('https://gamepedia.cursecdn.com/mtgsalvation_gamepedia/f/f8/Magic_card_back.jpg',JSON.decode(self.script_state))
			--BelerenFontM https://i.stack.imgur.com/787gj.png

    elseif a then
      --pieHere, allow using spaces instead of + when doing search syntax, also allow ( ) grouping
      local tbl={position=p.getPointerPosition(),player=p.steam_id,color=p.color,url=a:match('(http%S+)'),mode=a:gsub('(http%S+)',''):match('(%S+)'),name=a:gsub('(http%S+)',''),full=a}
      if tbl.color=='Grey' then
        tbl.position={0,2,0}
      end
      if tbl.mode then
        for k,v in pairs(Importer) do
          if tbl.mode:lower()==k:lower() and type(v)=='function' then
            tbl.mode,tbl.name=k,tbl.name:lower():gsub(k:lower(),'',1)
            break end end end

      if tbl.name:len()<1 then
        tbl.name='blank card'
      else
        if tbl.name:sub(1,1)==' ' then
          tbl.name=tbl.name:sub(2,-1)   --pieHere, remove 1st space
        end
        --pieHere, add character encoding to be able to put in same search as on scryfall.com
        charEncoder={ [' '] ='%%20',
                      ['>'] ='%%3E',
                      ['<'] ='%%3C',
                      [':'] ='%%3A',
                      ['%(']='%%28',
                      ['%)']='%%29',
                      ['%{']='%%7B',
                      ['%}']='%%7D',
                      ['%[']='%%5B',
                      ['%]']='%%5D',
                      ['%|']='%%7C',
                      ['%/']='%%2F',
                      ['\\']='%%5C',
                      ['%^']='%%5E',
                      ['%$']='%%24',
                      ['%?']='%%3F',
                      ['%!']='%%3F'}
        for char,replacement in pairs(charEncoder) do
          tbl.name=tbl.name:gsub(char,replacement)
        end

        -- -- pieHere, this would be the smarter way to do it, but for some reason it doesn't quite work?
        -- -- it's just the ^ sybmol? can't get that one to encode..
        -- chars2encode={' ','>','<',':','%(','%)','%{','%}','%[','%]','%|','%/','\\','%^','%$','%?','%!'}
        -- for _,char in pairs(chars2encode) do
        --   tbl.name=tblname:gsub(char,'%%'..string.format("%X",string.unicode(char)))
        -- end

      end
      Importer(tbl)
      if chatToggle then uLog(msg,p.steam_name)return false end
    end
  end
end

-- find paired {} and []
function findClosingBracket(txt,st)   -- find paired {} or []
  local ob,cb='{','}'
  local pattern='[{}]'
  if txt:sub(st,st)=='[' then
    ob,cb='[',']'
    pattern='[%[%]]'
  end
  local txti=st
  local nopen=1
  while nopen>0 do
    txti=string.find(txt,pattern,txti+1)
    if txt:sub(txti,txti)==ob then
      nopen=nopen+1
    elseif txt:sub(txti,txti)==cb then
      nopen=nopen-1
    end
  end
  return txti
end

--[[Card Encoder]]
pID=mod_name
function registerModule()
  enc=Global.getVar('Encoder')
  if enc then
    local prop={name=pID,funcOwner=self,activateFunc='toggleMenu'}
    local v=enc.getVar('version')
    buttons={'Respawn','Oracle','Rulings','Emblem\nAnd Tokens','Printings','Set Sleeve','Reverse Card'}
    if v and(type(v)=='string'and tonumber(v:match('%d+%.%d+'))or v)<4.4 then
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

function ENC(o,p,m)
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
