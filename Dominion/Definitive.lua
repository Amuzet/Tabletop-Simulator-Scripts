--DominionDefinitiveEditionModifiedByAmuzet2020_05_11_D
function onSave()
  saved_data=JSON.encode({
    gs=gameState,
    emax=eventMax,
    bmax=blackMarketMax,
    ect=eventCount,
    ust=useSets,
    upt=usePlatinum,
    ush=useShelters,
    uhl=useHeirlooms,
    obl=obeliskTarget,
    bmd=bmDeck})
    return saved_data
end
--Runs when the map is first loaded
function onLoad(saved_data)
  local Color={Blue={31/255,136/255,255/255},Green={49/255,179/255,43/255},Red={219/255,26/255,24/255},White={0.3,0.3,0.3},Orange={244/255,100/255,29/255},Yellow={231/255,229/255,44/255}}
    if saved_data~=''then
      local loaded_data=JSON.decode(saved_data)
      gameState=loaded_data.gs
      eventMax=loaded_data.emax
      blackMarketMax=loaded_data.bmax
      eventCount=loaded_data.ect
      useSets=loaded_data.ust
      usePlatinum=loaded_data.upt
      useShelters=loaded_data.ush
      useHeirlooms=loaded_data.uhl
      obeliskTarget=loaded_data.obl
      bmDeck=loaded_data.bmd
    else
      gameState=1
      eventMax=4
      blackMarketMax=25
      eventCount=0
      usePlatinum=0
      useShelters=0
      useHeirlooms=false
      useSets={}
      bmDeck={}
      obeliskTarget=nil
    end
    setUninteractible(ref_kingdomSlots)
    setUninteractible(ref_basicSlots)
    setUninteractible(ref_eventSlots)
    setUninteractible(ref_sideSlots)
    for k,r in pairs(ref_sideSlots)do local p=getObjectFromGUID(r.guid).getPosition();ref_sideSlots[k].pos={p[1],1.3,p[3]}end
    setUninteractible(ref)
    for _,o in pairs(getAllObjects())do if o.getLock()and o.getName()==''then o.interactable=false end end
    for k,p in pairs(ref_players)do for _,o in pairs(getObjectFromGUID(p.zone).getObjects())do o.setDescription(k)end end
    math.randomseed(os.time())
    if gameState==1 then
      for _,o in pairs(getObjectFromGUID(ref_storageZone.script).getObjects())do
        if o.tag=='Deck'then local n=o.getName()
          for i,c in pairs(ref_sidePiles)do if n==c.name then ref_sidePiles[i].guid=o.getGUID()break elseif i==#ref_sidePiles then o.highlightOn({1,0,0.5})end end end end
      for _,o in pairs(getObjectFromGUID(ref_storageZone.setup).getObjects())do
        local f,n=false,o.getName()
        if(o.tag=='Deck'or o.tag=='Card')and n~='Heirlooms'and n~='Shelters'then
          if not f then for i,c in pairs(ref_replacementPiles)do if n==c.name then f,ref_replacementPiles[i].guid=true,o.getGUID()break end end end
          if not f then for i,c in pairs(ref_eventSets)do if n==c.name then f,ref_eventSets[i].guid=true,o.getGUID()break end end end
          if not f then for i,c in pairs(ref_cardSets)do if n==c.name then f,ref_cardSets[i].guid=true,o.getGUID()break end end end
          if not f then o.highlightOn({1,0,0.5})print(n)end end end
        --Added Heirlooms
        for _,v in ipairs(getPile('Heirlooms').getObjects())do ref_heirlooms[v.name]=v.guid end
        setNotes('[40e0d0][b][u]Dominion: Definitive Edition[/b][/u][ffffff]\n\nBefore pressing Start Game, you may place any card from the expansion piles into the empty supply slots. Select any number of expansions to be randomly selected to fill all the remaining slots. You may also remove any undesireable card from its expansion deck to prevent it from being selected. You may save the game now to save your selected kingdom and expansions before pressing start.\n\n[FFFF00][b]Do not delete any decks or place any deck of cards into a supply slot.[/b]')
        for i in ipairs(ref_cardSets)do
            local obj=getObjectFromGUID(ref_cardSets[i].guid)
            if obj then
                obj.createButton({
                    label='Select\n'..obj.getName(),click_function='click_selectDeck',
                    function_owner=Global,position={0,0.4,0.6},rotation={0,0,0},scale={0.5,1,0.5},
                    height=600,width=2000,font_size=250,color={0,0,0},font_color={1,1,1}})
                for j, guid in ipairs(useSets)do
                    local obj2=getObjectFromGUID(guid)
                    if obj==obj2 then
                        obj.highlightOn({0,1,0})
                        break
        end end end end
        local obj=getObjectFromGUID(ref.startButton)
        if obj then
            local btn=setmetatable({d=3,function_owner=Global,position={-24,0,-8},rotation={0,180,0},scale={0.7,0.7,0.7},height=2000,width=5750,font_size=5000},{__call=function(b,l,t,p,f)
              b.position,b.label,b.tooltip=p or {b.position[1],b.position[2],b.position[3]-b.d},l,t or'';if f then b.click_function=f else b.click_function='click_' .. l:gsub('[^\n]+\n',''):gsub('%s','')end obj.createButton(b)end})
            btn('Max Events: '..eventMax,               'The Maximum number of noncards in Kingdom',nil,'click_eventLimit')
            btn('Black Market\nLimit: '..blackMarketMax,'The Number of cards in the Black Market',nil,'click_blackMarketLimit')
            btn('Tutorial\nBasic Game','Set Kingdom with only actions and up to two attacks',{23,0,-11})
            btn('Tutorial\nCard Types','Random Kingdom with half being Non Action Cards')
            btn('Tutorial\nAdvanced',  'Random Kingdom with non vanilla sets')
            btn('Balanced Setup\nDual Sets',    'Random Kingdom made with 5 cards of one set and 5 from another')--[[
            btn('Currated Setup\nDesigners',      {14,0,-32}, 'Picks a Kingdom from a list of currated sets made by the Designers')
            btn('Currated Setup\nDominion League',{0,0,-32},  'Picks a Kingdom from a list of currated sets played in tournaments')
            btn('Currated Setup\nReddit Weekly','Set Kingdom for this week from Reddit')
            btn('Balanced Setup\nTripple Sets', 'Random Kingdom made with atleast 3 card from 3 different sets')]]
            btn('Quick Setup\nTwo Sets',  'Random Kingdom from any two sets',{0,0,-62})
            btn('Quick Setup\nThree Sets','Random Kingdom from any three sets')
            btn('Quick Setup\nAll Sets',  'Random Kingdom from every set')
            btn('Selected Sets\nStart Game','Random Kingdom from selected sets and cards',{13,0,-16})
        end
        obj=getObjectFromGUID(ref_extraSupplyPiles[1].guid)
        if obj then
            obj.createButton({
                label='Force\n'..obj.getName(),click_function='click_forcePile',
                function_owner=Global,position={0,0.4,0.6},rotation={0,0,0},scale={0.5,1,0.5},
                height=600,width=2000,font_size=250,color={0,0,0},font_color={1,1,1}})
            if usePlatinum==1 then obj.highlightOn({0,1,0})
            elseif usePlatinum==2 then obj.highlightOn({1,0,0}) end
        end
        obj=getObjectFromGUID(ref_extraSupplyPiles[5].guid)
        if obj then
            obj.createButton({
                label='Force\n'..obj.getName(), click_function='click_forcePile',
                function_owner=Global,position={0,0.4,0.6},rotation={0,0,0},scale={0.5,1,0.5},
                height=600,width=2000,font_size=250,color={0,0,0},font_color={1,1,1}})
            if useShelters==1 then obj.highlightOn({0,1,0})
            elseif useShelters==2 then obj.highlightOn({1,0,0}) end
        end
    end
    if gameState==2 then
        bcast('Setup was interrupted, please reset the game.')
    end
    if gameState==3 then
        if obeliskTarget then
            for i, obj in ipairs(getAllObjects())do
                if obj.getName()=='Obelisk'or obj.getName()==obeliskTarget .. ' pile'then
                    obj.highlightOn({1,0,1})
                end
            end
        end
        createEndButton()
    end
end
function createEndButton()
    local obj=getObjectFromGUID(ref.startButton)
    if obj then
        obj.createButton({
            label='End Game', click_function='click_endGame',
            function_owner=Global, position={0,0.5,0}, rotation={0,180,0},
            height=1500, width=4000, font_size=9000
        })
    end
end
function click_endGame(obj, color)
    if not Player[color].admin then
        bcast('Only the host and promoted players can end the game.', {0.75,0.75,0.75}, color)
        return end
    setNotes('[40e0d0][b][u]Final Scores:[/b][/u][FFFFFF]\n')
    dT={Red={},White={},Orange={},Green={},Yellow={},Blue={}}
    vP={Red={},White={},Orange={},Green={},Yellow={},Blue={}}
    function scoreCoroutine()
      wait(2)
      for i=1, #getSeatedPlayers()do
        local currentPlayer=getSeatedPlayers()[i]
        local move=function(zone)
          for _, obj in ipairs(zone)do
            if obj.tag=='Card'or obj.tag=='Deck'then
              local t=getType(obj.getName())
              if t~='Boon'and t~='Hex'and t~='Artifact'and t~='State'then
                obj.setRotation({0,180,180})
                obj.setPosition(ref_players[currentPlayer].deck)
                coroutine.yield(0) end end end end
        local gObjs=function(s)return getObjectFromGUID(ref_players[currentPlayer][s]).getObjects() end
        if Player[currentPlayer].getHandCount() > 0 then
            vP[currentPlayer],dT[currentPlayer]=0,{}
            
            move(gObjs('deckZone'))
            move(Player[currentPlayer].getHandObjects())
            move(gObjs('discardZone'))
            for i, obj in ipairs(gObjs('tavern'))do
                if obj.tag=='Deck'then
                    for j, card in ipairs(obj.getObjects())do
                        if card.nickname=='Distant Lands'then
                            vP[currentPlayer]=vP[currentPlayer] + 4
                end end end
                if obj.tag=='Card'then
                    if obj.getName()=='Distant Lands'then
                        vP[currentPlayer]=vP[currentPlayer] + 4
                end end
                if obj.tag=='Card'or obj.tag=='Deck'then
                    local t=obj.getDescription()
                    if t=='Boon'or t=='Hex'or t=='Artifact'or t=='State'then else
                        obj.setRotation({0,180,180})
                        obj.setPosition(ref_players[currentPlayer].deck)
                        coroutine.yield(0)
            end end end
            for i, obj in ipairs(gObjs('zone'))do
                if obj.tag=='Card'and obj.getName()=='Miserable / Twice Miserable'then
                    vP[currentPlayer]=vP[currentPlayer] - 2
                    local rot=obj.getRotation()
                    if 90 < rot.z and rot.z < 270 then
                      vP[currentPlayer]=vP[currentPlayer] - 2
                      bcast(currentPlayer..' is Twice Miserable',{1,0,1})
                    else
                      bcast(currentPlayer..' is Miserable',{1,0,1})
        end end end end end
        wait(2)
        for i=1, #getSeatedPlayers()do
            local cp=getSeatedPlayers()[i]
            if Player[cp].getHandCount() > 0 then
                local tracker={
                  amount =0,
                  actions=0,
                  castles=0,
                  estates=0,
                  orchard=0,
                  knights=0,
                  uniques=0, --WolfDen
                  victory=0,
                  deck={}
                }
                for _, obj in ipairs(getObjectFromGUID(ref_players[cp].deckZone).getObjects())do
                    if obj.tag=='Deck'then
                        for v,card in ipairs(obj.getObjects())do
                            if dT[cp][card.nickname]==nil then
                                dT[cp][card.nickname]=1
                            else
                                dT[cp][card.nickname]=1+dT[cp][card.nickname]
                    end end end
                    if obj.tag=='Card'then
                        if dT[cp][card.getName()]==nil then
                            dT[cp][card.getName()]=1
                        else
                            dT[cp][card.getName()]=1+dT[cp][card.getName()]
                end end end
                tracker.deck=dT[cp]
                for i, v in pairs(tracker.deck)do
                    tracker.amount=tracker.amount + v
                    if getType(i):find('Action')then
                        tracker.actions=tracker.actions + v
                        if v > 2 then
                            tracker.orchard=tracker.orchard + 1
                        end
                    end
                    if getType(i):find('Victory')then
                        tracker.victory=tracker.victory + v
                    end
                    if getType(i):find('Castle')then
                        tracker.castles=tracker.castles + 1
                    end
                    if getType(i):find('Knight')then
                        tracker.knights=tracker.knights + v
                    end
                    if v==1 then
                        tracker.uniques=tracker.uniques + 1
                    end
                end
                -- Score Gardens
                for k,v in pairs(tracker.deck)do
                    local vp=getVP(k)
                    if type(vp)~='number'then vp=vp(tracker)end
                    vP[cp]=vP[cp] + vp*v
                end
                -- Score VP tokens
                if getObjectFromGUID(ref_players[cp].vp)then
                    vP[cp]=vP[cp] + getObjectFromGUID(ref_players[cp].vp).call('getCount')
                end
                -- Landmarks
                for _,es in ipairs(ref_eventSlots)do
                    for _,obj2 in ipairs(getObjectFromGUID(es.zone).getObjects())do
                        if obj2.tag=='Card'then
                            local vp=getVP(obj2.getName())
                            if type(vp)=='function'then vP[cp]=vP[cp]+vp(tracker,dT,cp)end end end end
                setNotes(getNotes()..'\n'..cp..' VP: '..vP[cp])
                
                printToAll(cp .. '\'s Deck:', Color[cp])
                
                for card, count in pairs(dT[cp])do
                    local s='0'
                    if count > 9 then s='' end
                    printToAll(s..count .. ' ' .. card, {1,1,1})
        end end end
        local obj=getObjectFromGUID(ref.startButton)
        return 1
    end
    if obj then obj.clearButtons()end
    gameState=4
    startLuaCoroutine(Global,'scoreCoroutine')
end
--Used in Button Callbacks
newText=setmetatable({type='3DText',position={},rotation={90,0,0}
    },{__call=function(t,p,text,f)
      t.position=p
      local o=spawnObject(t)
      o.TextTool.setValue(text)
      o.TextTool.setFontSize(f or 200)
      return o.getGUID()end})
function rcs(a)return math.random(1,#ref_cardSets-(a or 5))end
function timerStart(t)click_StartGame(t[1],t[2])end
function findCard(trg,r,p)
  log(trg)
  for _,set in ipairs(r)do
    local deck=getObjectFromGUID(set.guid)
    if deck then
      for __,card in ipairs(deck.getObjects())do
        if card.name==trg then
          deck.takeObject({position=p,index=card.index,smooth=false})
          break end end end end end
function kingdomList(str,par)
  local s=str
  if s:find('Shelters')then useShelters,s=1,s:gsub(',Shelters','')else useShelters=2 end
  if s:find('Platinum')then usePlatinum,s=1,s:gsub(',Platinum','')else usePlatinum=2 end
  local i=0
  for t in s:gmatch('[^,]+')do i=i+1
    if i==11 and s:find('Young Witch')then findCard(t,ref_cardSets,ref.baneSlot.pos)
    elseif i<11 then findCard(t,ref_cardSets,ref_kingdomSlots[i].pos)
    elseif t=='Summon'then getObjectFromGUID(ref_eventSets[#ref_eventSets-1].guid).setPosition(ref_eventSlots[i-10].pos)
    else local j=i-10
      if s:find('Young Witch')then j=j+1 end
      findCard(t,ref_eventSets,ref_eventSlots[j].pos)end end
  Timer.create({identifier='RW',function_name='timerStart',parameters=par,delay=2})
end
local Use=setmetatable({' ',' '},{__call=function(t,s)local _,n=t[1]:gsub(' '..s..' ',' '..s..' ');if n>0 then return n end return false end})
function Use.Add(n)
  local x,s,c=0,' ',n
  log(n)
  if getCost(c):sub(-1)=='1'then s=s..'Potion 'end
  if not getCost(c):find('D0')and not getCost(c):find('DX')then s=s..'Debt 'end
  for _,t in pairs({'Looter','Reserve','Doom','Fate','Project','Gathering'})do if getType(c):find(t)then s=s..t..' 'end end
  for i,v in pairs(ref_master)do if c==v.name then x=i;if v.depend then s=s..v.depend..' 'end break end end
  if 100<x and x<126 then s=s..'Platinum 'elseif 175<x and x<225 then s=s..'Shelters 'end
  createHeirlooms(c)
  log(s)
  Use[1]=Use[1]..c:gsub(' ','')..s
end
--Button Callbacks
function click_selectDeck(obj, color)
  local guid,inUse,a=obj.getGUID(),true,{1,1,1}
  for i,guid2 in ipairs(useSets)do
    local obj2=getObjectFromGUID(guid2)
    if obj==obj2 then
      obj.highlightOff()
      inUse=false
      table.remove(useSets,i)
      break end end
  if inUse then a={0,1,0}
    obj.highlightOn({0,1,0})
    table.insert(useSets,guid)
  end
  local b,l=getObjectFromGUID(ref.startButton),'Selected Sets\n'
  for _,g in pairs(useSets)do
    for _,s in pairs(ref_cardSets)do
      if g==s.guid then l=l..s.name..'\n'
  break end end end
  b.editButton({index=#b.getButtons()-1,label=l..'[009911]Start Game[-]',height=790*(#useSets+2)+100})
  obj.editButton({font_color=a})
end
function click_AllSets(obj, color)useSets={}
    for i,set in ipairs(ref_cardSets)do if set.name~='Promos'then table.insert(useSets,set.guid)else break end end
    click_StartGame(obj, color)
end
function click_TwoSets(obj, color)useSets={}
    local n,m=rcs(),rcs()
    while m==n do m=rcs()end
    table.insert(useSets, ref_cardSets[n].guid)
    table.insert(useSets, ref_cardSets[m].guid)
    click_StartGame(obj, color)
end
function click_ThreeSets(obj, color)useSets={}
    local n,m,o=rcs(),rcs(),rcs()
    while m==n do m=rcs()end
    while o==m or o==n do o=rcs()end
    table.insert(useSets,ref_cardSets[n].guid)
    table.insert(useSets,ref_cardSets[m].guid)
    table.insert(useSets,ref_cardSets[o].guid)
    click_StartGame(obj, color)
end
function click_DualSets(obj, color)
  if #useSets>2 then
    while #useSets>2 do table.remove(useSets,math.random(1,#useSets))end
  elseif #useSets==1 then
    local m=rcs()
    for i,v in pairs(ref_cardSets)do
      if useSets[1]==v.guid then
        while m==i do m=rcs()end
        table.insert(useSets,ref_cardSets[m].guid)
      end
    end
  elseif #useSets==0 then
    local n,m=rcs(),rcs()
    while m==n do m=rcs()end
    table.insert(useSets,ref_cardSets[n].guid)
    table.insert(useSets,ref_cardSets[m].guid)
  end
  local eventPiles={}
  for _,g in pairs(useSets)do for _,s in pairs(ref_cardSets)do if s.guid==g then
      if s.events then for _,v in pairs(s.events)do
      table.insert(eventPiles,ref_eventSets[v].guid)
      end end break
  end end end
  
  for _,v in pairs(useSets)do getObjectFromGUID(v).shuffle()end
  for _,v in pairs(eventPiles)do getObjectFromGUID(v).shuffle()end
  
  function DualSetsCoroutine()
    wait(2)
    for i,v in pairs(ref_kingdomSlots)do getObjectFromGUID(useSets[(i%2)+1]).takeObject({position=v.pos,index=6-math.ceil(i/2),smooth=false})end
    for i,v in pairs(eventPiles)do getObjectFromGUID(v).takeObject({position=ref_eventSlots[i].pos,index=2,smooth=false})end
    
    click_StartGame(obj, color)
  end
  startLuaCoroutine(Global,'DualSetsCoroutine')
end
function click_TrippleSets(obj, color)
  printToAll('This does nothing!',{1,1,1})
end
function click_RedditWeekly(obj, color)
  --https://www.reddit.com/r/dominion/search?q=title%3Akotw+author%3Aavocadro&sort=newl&utm_name=dominion&t=week
  local KotW='KotW 12/1: Bishop, Crown, Forager, Goons, Inventor, King\'s Court, Lighthouse, Lurker, Remake, Watchtower. Events: Dominate, Donate. Colony/Platinum; no Shelters. [Intrigue, Seaside, Prosperity, Cornucopia, Dark Ages, Empires, Renaissance]'
  
  bcast('Kingdom of the Week '..KotW:match('%d+/%d+')..'/2019')
  local tbl={bane=KotW:match('%(Bane: (.+)%)'),P=KotW:match('[NOno ]*Colony/Platinum'),S=KotW:match('[NOno ]*Shelters')}
  if tbl.P and tbl.P:find('[Nn][Oo]')then tbl.P=false end
  if tbl.S and tbl.S:find('[Nn][Oo]')then tbl.S=false end
  local x=KotW:gsub('%p ([%s%w\']+)',function(a)table.insert(tbl,a)return''end,10)
  local g=function(b)x:match('[s]?(: [%s%w,])[%.;]'):gsub('%p ([%s%w\']+)',function(a)table.insert(tbl,a)end)end
  g('Landmark')
  g('Project')
  g('Event')
  log(tbl)
  --KotW.gsub()
  kingdomList(tbl,{obj,color})
end
function click_DominionLeague(obj, color)
  bcast('Beginner Tutorial')
  local knd={
'Vineyard,Pearl Diver,Stonemason,Oasis,Storeroom,Philosopher\'s Stone,Talisman,Herald,Cultist,Fairgrounds,Shelters',
'Stonemason,Hermit,Wishing Well,Fortress,Nomad,Camp,Sea Hag,Golem,Bandit Camp,Merchant Guild,Mystic,Shelters',
'Herbalist,Sage,Mining Village,Rats,Salvager,Highway,Horn of Plenty,Rogue,Soothsayer,Peddler',
'Embargo,Secret Chamber,Watchtower,Swindler,Bridge,Procession,Talisman,Gardens,Jester,Mint',
'Oracle,Village,Fortress,Moneylender,Plaza,Silk Road,City,Contraband,Library,Pillage',
'University,Menagerie,Horse Traders,Bazaar,Embassy,Margrave,Pillage,Altar,Grand Market,Expand,Platinum',
'Moat,Vagrant,Scheme,Island,Throne Room,Salvager,Jester,Rabble,Fairgrounds,Peddler',
'Oasis,Shanty Town,Marauder,Young Witch,Mining Village,Silk Road,Market,Stables,Merchant Ship,Graverobber,Vagrant',
'Storeroom,Wishing Well,Coppersmith,Mining Village,Salvager,Throne Room,Mint,Tactician,Bank,Forge,Platinum',
'Horse Traders,Fool\'s Gold,Menagerie,Develop,Warehouse,Conspirator,Minion,Duke,Horn of Plenty,Candlestick Maker',
'Counting,House,Mountebank,Inn,Festival,Throne Room,Plaza,Gardens,Trade Route,Storeroom,Scheme,Platinum',
'Poor House,Hamlet,Tunnel,Oracle,Doctor,Remake,Sea Hag,Inn,Merchant Guild,King\'s Court',
'Squire,Bridge,Apprentice,Haggler,Marauder,Urchin,Shanty Town,Library,Hoard,Harem,Shelter',
'Stonemason,Tunnel,Storeroom,Watchtower,Rats,Bishop,Fortress,Catacombs,Minion,Hunting Grounds,Shelters',
'Fool\'s Gold,Native Village,Stonemason,Market,Square,Wishing Well,Ironmonger,Procession,Catacombs,Witch,Adventurer',
'Scavenger,Philosopher\'s Stone,Gardens,Squire,Worker\'s Village,Vault,Steward,Caravan,Mountebank,Adventurer,Platinum',
'Vineyard,Apothecary,Fishing Village,Menagerie,Envoy,Young Witch,Market,Goons,Hoard,Expand,Wishing Well,Platinum',
'Fool\'s Gold,Lookout,Shanty Town,Warehouse,Woodcutter,Remodel,Sea Hag,Apprentice,Bazaar,Hoard',
'Hamlet,Menagerie,Tunnel,Watchtower,Monument,Remake,Inn,Tactician,Adventurer,Bank',
'Courtyard,Oracle,Trade Route,Tournament,Golem,Bazaar,Mint,Rabble,Fairgrounds,King\'s Court',
'Vineyard,Herbalist,Fishing Village,Philosopher\'s Stone,Caravan,Young Witch,Horn of Plenty,Mandarin,Royal Seal,Trading Post,Watchtower',
'Ambassador,Lookout,Wishing Well,Bishop,Ironworks,Monument,Trader,Venture,Expand,Peddler,Platinum',
'Crossroads,Embargo,Trade Route,Tunnel,Village,Warehouse,Workshop,Silk Road,Spice Merchant,Apprentice',
'Moat,Fortune,Teller,Bridge,Moneylender,Smithy,Throne Room,Festival,Jester,Vault,Fairgrounds',
'Chapel,Embargo,Fool\'s Gold,Oasis,Workshop,Thief,Throne Room,Worker\'s Village,Margrave,Wharf',
'Haven,Fishing Village,Scheme,Steward,Horse Traders,Mountebank,Upgrade,Festival,Library,Goons',
'Native Village,Talisman,Treasure Map,Worker\'s Village,City,Vault,Venture,Grand Market,Expand,Peddler,Platinum',
'Moat,Tunnel,Bishop,Gardens,Ironworks,Young Witch,Tournament,Council Room,Torturer,Border Village,Hamlet',
'Crossroads,Loan,Silk Road,Baron,Bureaucrat,Apprentice,Duke,Farmland,Harem,Nobles,Platinum',
'Haven,Great,Hall,Workshop,Masquerade,Ironworks,Island,Throne Room,Tactician,Goons,King\'s Court',
'Lookout,Masquerade,Oracle,Smithy,Worker\'s Village,Festival,Ghost Ship,Margrave,Mountebank,Treasury',
'Embargo,University,Scrying Pool,Worker\'s Village,Remodel,Wharf,Rabble,Grand Market,Forge,Peddler,Platinum',
'Menagerie,Tunnel,Ghost Ship,Governor,Inn,Monument,Worker\'s Village,Grand Market,Goons,Adventurer',
'Embargo,Scheme,Menagerie,Watchtower,Fishing Village,Remake,Haggler,Vault,Grand Market,Expand,Platinum',
'Crossroads,Secret Chamber,Warehouse,Loan,Ambassador,Caravan,Worker\'s Village,Bureaucrat,Merchant Ship,Grand Market,Platinum',
'Chapel,Fishing Village,Watchtower,Ironworks,Gardens,Bridge,Highway,Mountebank,Ill-Gotten,Gains,Goons,Platinum',
'Torturer,Merchant Ship,Moneylender,Caravan,Familiar,Watchtower,Steward,University,Embargo,Hamlet',
'Counting,House,Vault,Laboratory,Golem,Coppersmith,Worker\'s Village,Tunnel,Chancellor,Apothecary,Hamlet',
'Harem,Venture,Golem,Tournament,Bishop,Thief,Remake,Tunnel,Fishing Village,Fool\'s Gold',
'Forge,Torturer,Governor,Mountebank,Wharf,Sea Hag,Worker\'s Village,Familiar,Fishing Village,Chapel',
'Fairgrounds,Nobles,Golem,Spy,Quarry,Ironworks,Throne Room,Menagerie,Black Market,Native Village'}
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
end
function click_Designers(obj, color)
  bcast('Loading a Set created by the Designers')
  local knd={
'Courtyard,Minion,Steward,Mining Village,Conspirator,Bureaucrat,Chancellor,Council Room,Mine,Militia',
'Herbalist,Transmute,Apothecary,Alchemist,Golem,Cellar,Chancellor,Festival,Militia,Smithy',
'Bishop,Goons,Monument,Peddler,Grand Market,Council Room,Cellar,Library,Throne Room,Chancellor',
'Bank,Expand,Forge,King\'s Court,Vault,Bridge,Coppersmith,Swindler,Tribute,Wishing Well',
'Fairgrounds,Farming Village,Horse Traders,Jester,Young Witch,Feast,Laboratory,Market,Remodel,Workshop,Cellar',
'Crossroads,Farmland,Fool\'s Gold,Oracle,Spice Merchant,Adventurer,Chancellor,Festival,Laboratory,Remodel',
'Bureaucrat,Council Room,Feast,Laboratory,Market,Moneylender,Remodel,Smithy,Village,Workshop',
'Adventurer,Laboratory,Library,Militia,Throne Room,Bridge,Masquerade,Shanty Town,Steward,Trading Post',
'Cellar,Feast,Gardens,Witch,Workshop,Ambassador,Fishing Village,Lighthouse,Merchant Ship,Treasury',
'Adventurer,Council Room,Mine,Moneylender,Village,Expand,Loan,Quarry,Vault,Venture',
'Cellar,Gardens,Market,Militia,Mine,Remodel,Throne Room,Alchemist,Apothecary,Herbalist',
'Bureaucrat,Chancellor,Chapel,Festival,Library,Moat,Hamlet,Horse Traders,Jester,Remake',
'Conspirator,Coppersmith,Courtyard,Duke,Harem,Nobles,Scout,Trading Post,Upgrade,Wishing Well',
'Conspirator,Coppersmith,Harem,Masquerade,Mining Village,Ambassador,Caravan,Merchant Ship,Native Village,Tactician',
'Great Hall,Ironworks,Masquerade,Mining Village,Upgrade,City,Grand Market,Royal Seal,Talisman,Trade Route',
'Courtyard,Duke,Great Hall,Minion,Nobles,Scout,Wishing Well,Herbalist,Transmute,Vineyard',
'Bridge,Ironworks,Minion,Shanty Town,Steward,Upgrade,Fairgrounds,Harvest,Horse Traders,Young Witch,Courtyard',
'Caravan,Embargo,Explorer,Fishing Village,Ghost Ship,Island,Lighthouse,Salvager,Treasury,Warehouse',
'Ghost Ship,Haven,Island,Lookout,Tactician,Bishop,Trade Route,Venture,Watchtower,Worker\'s Village',
'Bazaar,Cutpurse,Lookout,Pearl Diver,Salvager,Warehouse,Wharf,Apprentice,University,Vineyard',
'Bazaar,Embargo,Haven,Navigator,Warehouse,Wharf,Fortune Teller,Hamlet,Horn of Plenty,Hunting Party',
'Bank,Expand,Goons,Hoard,Mint,Monument,Peddler,Royal Seal,Talisman,Worker\'s Village',
'Bank,Goons,Hoard,Mint,Quarry,Vault,Watchtower,Apothecary,Apprentice,Transmute',
'Bishop,Grand Market,Loan,Monument,Peddler,Rabble,Farming Village,Horn of Plenty,Menagerie,Tournament',
'Cellar,Festival,Library,Market,Militia,Moneylender,Smithy,Thief,Throne Room,Woodcutter',
'Conspirator,Coppersmith,Duke,Great Hall,Harem,Pawn,Scout,Steward,Torturer,Upgrade',
'Adventurer,Bureaucrat,Council Room,Remodel,Workshop,Caravan,Ghost Ship,Merchant Ship,Native Village,Outpost',
'Chancellor,Festival,Moat,Witch,Woodcutter,Apprentice,Golem,Philosopher\'s Stone,University,Vineyard',
'Cellar,Council Room,Gardens,Thief,Village,Forge,Hoard,Loan,Rabble,Venture',
'Cellar,Feast,Laboratory,Mine,Workshop,Fairgrounds,Farming Village,Fortune Teller,Horn of Plenty,Menagerie'}
  kingdomList(knd[math.random(1,#knd)],{obj,color})
end
function click_VanillaSets(obj, color)
  bcast('Setting up Base Game and Intrigue')
  useSets={ref_cardSets[1].guid,ref_cardSets[2].guid}
  click_StartGame(obj,color)
end
function click_BasicGame(obj, color)
  bcast('Beginner Tutorial')
  newText({26.00,1,25},'THE GAME ENDS WHEN:\nAny 3 piles are empty or\nThe Province pile is empty.')
  newText({0.00,1,11},'On your turn you may play One ACTION.\nOnce you have finished playing actions you may play TREASURES.\nThen you may Buy One Card. ([i]Cards you play can change all these[/i])',100)
  local knd={
'Cellar,Festival,Mine,Moat,Patrol,Poacher,Smithy,Village,Witch,Workshop',
'Cellar,Market,Merchant,Militia,Mine,Moat,Remodel,Smithy,Village,Workshop',}
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
end
function click_CardTypes(obj, color)
  bcast('Not Implemented Yet')
  --click_StartGame(obj,color)
end
function click_Advanced(obj, color)
  bcast('Not Implemented Yet')
 
  --click_StartGame(obj,color)
end

function click_forcePile(obj, color)
    local guid,c=obj.getGUID(),{1,1,1}
    if guid==ref_extraSupplyPiles[1].guid then
        if usePlatinum < 2 then
            usePlatinum=1 + usePlatinum
            if usePlatinum==1 then c={0,1,0}else c={1,0,0}end
            obj.highlightOn(c)
        else
            usePlatinum=0
            obj.highlightOff()
        end
    elseif guid==ref_extraSupplyPiles[5].guid then
        if useShelters < 2 then
            useShelters=1 + useShelters
            if useShelters==1 then c={0,1,0}else c={1,0,0}end
            obj.highlightOn(c)
        else
            useShelters=0
            obj.highlightOff()
        end
    end
    obj.editButton({font_color=c})
end
function click_eventLimit(obj,color)
  if eventMax<4 then eventMax=eventMax+1 else eventMax=0 end
  obj.editButton{index=getButton(obj,'Max Events: '),label='Max Events: '..eventMax}end
function click_blackMarketLimit(obj,color,a)
  if a and blackMarketMax>19 then blackMarketMax=blackMarketMax-5
  elseif a then blackMarketMax=60
  elseif blackMarketMax<60 then blackMarketMax=blackMarketMax+5
  else blackMarketMax=10 end
  obj.editButton{index=getButton(obj,'Black Market'),label='Black Market\nLimit: '..blackMarketMax}end
--function called when you click to start the game
function click_StartGame(obj, color)
  if not Player[color].admin then
    bcast('Only the host and promoted players can start the game.', {0.75,0.75,0.75}, color)
    return
  end
  if getPlayerCount() < 2 or getPlayerCount() > 6 then
    bcast('This game needs 2 to 6 players to start.', {0.75,0.75,0.75}, color)
    return
  end
  local summonException=false
  for _,es in ipairs(ref_eventSlots)do
    for j, v in ipairs(getObjectFromGUID(es.zone).getObjects())do
        if v.getName()=='Summon'then
            summonException=true
            break
        end
    end
  end
  local requireBane=false
  local requireBlackMarket=false
  local cardCount=0
  for i in ipairs(ref_kingdomSlots)do
    local supplyZone=getObjectFromGUID(ref_kingdomSlots[i].zone)
    local supplyCheck=supplyZone.getObjects()
    for j in ipairs(supplyCheck)do
      local zoneObj=supplyCheck[j]
      if zoneObj.tag=='Card'then
        if zoneObj.getName()=='Young Witch'then
          requireBane=true
          local baneZone=getObjectFromGUID(ref.baneSlot.zone).getObjects()
          for k in ipairs(baneZone)do
            local baneObj=baneZone[k]
            if baneObj.tag=='Card'and baneObj.getName()~='Bane pile'then
              if getCost(baneObj.getName())~='M2D0P0'and getCost(baneObj.getName())~='M3D0P0'then
                bcast('Bane card needs to cost 2 or 3 with no debt or potions.', {0.75,0.75,0.75}, color)
                return
              else
                requireBane=false
                break end end end end 
        if zoneObj.getName()=='Black Market'then requireBlackMarket=true end
        cardCount=cardCount + 1
  end end end
  if not requireBane then
    for j,guid in ipairs(useSets)do
      local obj2=getObjectFromGUID(guid)
      if obj2 then
        for _,ref in ipairs(obj2.getObjects())do
          if ref.nickname=='Young Witch'then
            requireBane=true
          elseif ref.nickname=='Black Market'then
            requireBlackMarket=true
  end end end end end
  if cardCount==10 and not requireBane and not requireBlackMarket then
    removeButtons()
    setupKingdom(summonException)
    gameState=2
  elseif cardCount > 10 then
    bcast('You have too many already chosen kingdom cards.', {0.75,0.75,0.75}, color)
    return
  else
    local cardCount2=0
    for j, guid in ipairs(useSets)do
        local obj2=getObjectFromGUID(guid)
        if obj2 then
            obj2.setLock(false)
            cardCount2=#obj2.getObjects() + cardCount2
        end
    end
    if cardCount2 < 11 - cardCount then
        bcast('You don\'t have enough cards selected to form a random kingdom.', {0.75,0.75,0.75}, color)
        return
    elseif requireBane then
        local deckCheck=false
        for j, guid in ipairs(useSets)do
            local obj2=getObjectFromGUID(guid)
            for k, ref in ipairs(obj2.getObjects())do
                if getCost(ref.nickname)=='M2D0P0'or getCost(ref.nickname)=='M3D0P0'then
                    if ref.nickname~='Young Witch'then
                        deckCheck=true
        end end end end
        if not deckCheck then
            bcast('Selected cards need a valid possible Bane card.', {0.75,0.75,0.75}, color)
            return
        elseif cardCount2 < 12 - cardCount then
            bcast('You don\'t have enough cards selected to form a random kingdom.', {0.75,0.75,0.75}, color)
            return end
    elseif cardCount2 < 20 - cardCount and requireBlackMarket then
        bcast('You don\'t have enough cards selected to form a random kingdom.', {0.75,0.75,0.75}, color)
        return end
    -- random kingdom start
    removeButtons()
    setupKingdom(summonException)
    gameState=2
  end
end
function getButton(o,s)for _,b in pairs(o.getButtons())do if b.label:find(s)then return b.index end end end
-- Function to remove all buttons
function removeButtons()
  local obj=getPile('Shelters')
  if obj then obj.flip() end
  for i in ipairs(ref_cardSets)do
    local obj=getObjectFromGUID(ref_cardSets[i].guid)
    if obj then obj.clearButtons()end
  end
  local obj=getObjectFromGUID(ref.startButton)
  if obj then obj.clearButtons()end
  obj=getObjectFromGUID(ref_extraSupplyPiles[1].guid)
  if obj then obj.clearButtons()end
  obj=getObjectFromGUID(ref_extraSupplyPiles[5].guid)
  if obj then obj.clearButtons()end
end
-- Function to setup the Kingdom
function setupKingdom(summonException)
  -- first we delete all the not in use sets and group the remaining
  for i,cs in ipairs(ref_cardSets)do
    local found=false
    local guid=cs.guid
    local obj=getObjectFromGUID(guid)
    for _,g in ipairs(useSets)do
      local o=getObjectFromGUID(g)
      if obj==o and obj then
        o.setPosition(ref.randomizer.pos)
        o.flip()
        found=true
      end
    end
    if cs.events then
      if cs.name~='Promos'or not summonException then
        for _,n in pairs(cs.events) do
          local o=getObjectFromGUID(ref_eventSets[n].guid)
          if o and found then
          o.setRotation({0,0,0})
          o.setPosition(ref.randomizer.pos)
          o.flip()
          elseif o and not found then o.destruct()end
    end end end
    if not found and obj then obj.destruct()end
  end
  function setupKingdomCoroutine()
    wait(2)
    local deck=false
    for i, v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do if v.tag=='Deck'then deck=v end end
    if deck then
        deck.setRotation({0,180,180})
        deck.shuffle()
        deck.highlightOff()
    end
    wait(1)
    local events={}
    for _,es in ipairs(ref_eventSlots)do
        for j, v in ipairs(getObjectFromGUID(es.zone).getObjects())do
            if v.tag=='Card'then table.insert(events, v) end
        end
    end
    for i in ipairs(events)do events[i].setPosition(ref_eventSlots[i].pos) end
    eventCount=#events
    if deck then
      local w=0
        for _,ks in ipairs(ref_kingdomSlots)do
            card=false
            for j, v in ipairs(getObjectFromGUID(ks.zone).getObjects())do if v.tag=='Card'then card=true end end
            while not card do
              for j, v in pairs(deck.getObjects())do
                local tp=getType(v.name) if tp=='Event'or tp=='Landmark'or tp=='Project'or tp=='Way'then
                  if eventCount < eventMax then
                    --local tp=getType(v.name) if tp=='Way'then if w==1 then break end w=w+1 end
                    eventCount=eventCount + 1
                    deck.takeObject({position=ref_eventSlots[eventCount].pos, index=v.index, callback='setCallback', callback_owner=Global})
                    break end
                else
                  card=true
                  deck.takeObject({position=ks.pos, index=v.index, flip=true})
                  break end end end end
        wait(0.5)
        local blackMarket, requireBane=false, false
        for _,ks in ipairs(ref_kingdomSlots)do
            for j, v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
                if v.tag=='Card'then
                    Use.Add(v.getName())
                    if v.getName()=='Young Witch'then
                        requireBane=true
                        break
                    elseif v.getName()=='Black Market'then
                        blackMarket=true
        end end end end
        if Use('BlackMarket')then
            deck.setName('Black Market deck')
            local cleanDeck=false
            local deckAddPos={deck.getPosition()[1],deck.getPosition()[2] + 2,deck.getPosition()[3]}
            while not cleanDeck do
                cleanDeck=true
                for i, v in ipairs(deck.getObjects())do
                    local tp=getType(v.name) if tp=='Event'or tp=='Landmark'or tp=='Project'or tp=='Way'then
                        coroutine.yield(0)
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Knights'then
                        coroutine.yield(0)
                        getPile('Knights pile').shuffle()
                        getPile('Knights pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Castles'then
                        coroutine.yield(0)
                        getPile('Castles pile').shuffle()
                        getPile('Castles pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Catapult / Rocks'then
                        coroutine.yield(0)
                        getPile('Catapult / Rocks pile').shuffle()
                        getPile('Catapult / Rocks pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Encampment / Plunder'then
                        coroutine.yield(0)
                        getPile('Encampment / Plunder pile').shuffle()
                        getPile('Encampment / Plunder pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Gladiator / Fortune'then
                        coroutine.yield(0)
                        getPile('Gladiator / Fortune pile').shuffle()
                        getPile('Gladiator / Fortune pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Patrician / Emporium'then
                        coroutine.yield(0)
                        getPile('Patrician / Emporium pile').shuffle()
                        getPile('Patrician / Emporium pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Settlers / Bustling Village'then
                        coroutine.yield(0)
                        getPile('Settlers / Bustling Village pile').shuffle()
                        getPile('Settlers / Bustling Village pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Sauna / Avanto'then
                        coroutine.yield(0)
                        getPile('Sauna / Avanto pile').shuffle()
                        getPile('Sauna / Avanto pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    end
                end
            end
            wait(2)
            deck.shuffle()
            while #deck.getObjects() > blackMarketMax + 1 do
                coroutine.yield(0)
                deck.takeObject({index=1}).destruct()
            end
            -- check for young witch
            for i, v in ipairs(deck.getObjects())do
                if v.nickname=='Young Witch'then
                    requireBane=true
                end
            end
            if not requireBane then
                deck.takeObject({index=1}).destruct()
            end
        end
        local baneSet, blackMarket2Check=false, false
        if requireBane then
            for i, v in ipairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
                if v.tag=='Card'and v.getName()~='Bane pile'then
                    Use.Add(v.getName())
                    baneSet=true
                    if v.getName()=='Black Market'then
                        blackMarket2Check=true
            end end end
            if not baneSet then
                for j, card in ipairs(deck.getObjects())do
                    if getType(card.name)=='Event'or getType(card.name)=='Landmark'or getType(card.name)=='Project'or getType(card.name)=='Way'then
                    elseif getCost(card.nickname)=='M2D0P0'or getCost(card.nickname)=='M3D0P0'then
                        Use.Add(card.nickname)
                        if card.nickname=='Black Market'then
                            blackMarket2Check=true
                        end
                        deck.takeObject({position=ref.baneSlot.pos, index=card.index, flip=true})
                        break end end end end
        if blackMarket2Check then
            deck.setName('Black Market deck')
            local cleanDeck=false
            local deckAddPos={deck.getPosition()[1],deck.getPosition()[2] + 2,deck.getPosition()[3]}
            while not cleanDeck do
                cleanDeck=true
                for i, v in ipairs(deck.getObjects())do
                    local tp=getType(v.name) if tp=='Event'or tp=='Landmark'or tp=='Project'or tp=='Way'then
                        coroutine.yield(0)
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Knights'then
                        coroutine.yield(0)
                        getPile('Knights pile').shuffle()
                        getPile('Knights pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Castles'then
                        coroutine.yield(0)
                        getPile('Castles pile').shuffle()
                        getPile('Castles pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Catapult / Rocks'then
                        coroutine.yield(0)
                        getPile('Catapult / Rocks pile').shuffle()
                        getPile('Catapult / Rocks pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Encampment / Plunder'then
                        coroutine.yield(0)
                        getPile('Encampment / Plunder pile').shuffle()
                        getPile('Encampment / Plunder pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Gladiator / Fortune'then
                        coroutine.yield(0)
                        getPile('Gladiator / Fortune pile').shuffle()
                        getPile('Gladiator / Fortune pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Patrician / Emporium'then
                        coroutine.yield(0)
                        getPile('Patrician / Emporium pile').shuffle()
                        getPile('Patrician / Emporium pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Settlers / Bustling Village'then
                        coroutine.yield(0)
                        getPile('Settlers / Bustling Village pile').shuffle()
                        getPile('Settlers / Bustling Village pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Sauna / Avanto'then
                        coroutine.yield(0)
                        getPile('Sauna / Avanto pile').shuffle()
                        getPile('Sauna / Avanto pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break end end end
        wait(2)
        deck.shuffle()
        while #deck.getObjects()>blackMarketMax do
          coroutine.yield(0)
          deck.takeObject({index=1}).destruct()
        end
      end
      if deck.getName()=='Black Market deck'then
        for i, card in ipairs(deck.getObjects())do
          Use.Add(card.nickname)
          table.insert(bmDeck, card.nickname)
        end
      end
    end
    wait(1)
    reorderKingdom()
    wait(0.5)
    createPile()
    return 1
  end
  startLuaCoroutine(Global, 'setupKingdomCoroutine')
end
-- Callback to fix the event position
function setCallback(obj)obj.setRotation({0,90,0})end
-- Function to reorder the Kingdom
function reorderKingdom()
    --First create an array with all the card names plus the costs in it
    local sortedKingdom={}
    for _,ks in ipairs(ref_kingdomSlots)do
        for j, v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
            if v.tag=='Card'then
                table.insert(sortedKingdom, getCost(v.getName()) .. v.getName())
    end end end
    --Then sort the list
    table.sort(sortedKingdom)
    --Finally, set the positions based on the new order
    for i, v in ipairs(sortedKingdom)do
        sortedKingdom[i]=v:sub(7)
        for _,ks in pairs(ref_kingdomSlots)do
            for k, b in ipairs(getObjectFromGUID(ks.zone).getObjects())do
                if b.getName()==sortedKingdom[i] then
                    b.setPosition(ref_kingdomSlots[i].pos)
    end end end end
    --Do the same for events
    if eventCount > 0 then
        local sortedEvents={}
        for _,es in ipairs(ref_eventSlots)do
            for j, v in ipairs(getObjectFromGUID(es.zone).getObjects())do
                if v.tag=='Card'then
                    Use.Add(v.getName())
                    table.insert(sortedEvents, getCost(v.getName()) .. v.getName())
        end end end
        table.sort(sortedEvents)
        for i, v in ipairs(sortedEvents)do
            sortedEvents[i]=v:sub(7)
            for _,es in ipairs(ref_eventSlots)do
                for k,b in ipairs(getObjectFromGUID(es.zone).getObjects())do
                    if b.getName()==sortedEvents[i] then
                        b.setPosition(es.pos)
                        b.setLock(true)
end end end end end end

function cleanUp()
  local sp=function(a,b)local _,c=Use[1]:gsub(b,b);if a==0 then if c>9 or math.random(a,1+c-a*5)>0 then a=1;end end end
  sp(useShelters,'Shelters')
  sp(usePlatinum,'Platinum')
  if usePlatinum~=1 then
    getPile('Platinums').destruct()
    getPile('Colonies').destruct()
    getPile('Golds').setPosition(ref_basicSlots[5].pos)
    getPile('Silvers').setPosition(ref_basicSlots[4].pos)
    getPile('Coppers').setPosition(ref_basicSlots[3].pos)
    getPile('Potions').setPosition(ref_basicSlots[2].pos)
    getPile('Ruins pile').setPosition(ref_basicSlots[6].pos)
    getObjectFromGUID(ref_basicSlots[1].guid).destruct()
    getObjectFromGUID(ref_basicSlots[7].guid).destruct()
  else getPile('Platinums').highlightOff()end
  
  if not Use('Potion')then
    getPile('Potions').destruct()
    if usePlatinum~=1 then
      getObjectFromGUID(ref_basicSlots[2].guid).destruct()
    else
      getObjectFromGUID(ref_basicSlots[1].guid).destruct()
    end
  end
  
  if Use('Baker')then for i,obj in ipairs(getAllObjects())do if obj.getName()=='Coffers'then obj.call('baker')end end end
  if not Use('TradeRoute')then getObjectFromGUID(ref.tradeRoute.guid).destruct()end
  if not Use('Looter')then getPile('Ruins pile').destruct()if usePlatinum~=1 then getObjectFromGUID(ref_basicSlots[6].guid).destruct() else getObjectFromGUID(ref_basicSlots[7].guid).destruct()end end
  if not Use('Bane')then for i,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do v.destruct()end end
  if not Use('BlackMarket')then for i,v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do v.destruct()end end
  if not Use('Zombie')then getPile('Zombies').destruct()end
  if not Use('Embargo')then getObjectFromGUID('7c2165').destruct()end
  
  for i in ipairs(ref_replacementPiles)do
    local obj=getObjectFromGUID(ref_replacementPiles[i].guid)
    local pos=obj.getPosition()
    if pos[1]>16 or pos[1]<-16 then obj.destruct()
    elseif pos[3]>23 or pos[3]<13 then obj.destruct()
  end end
  local sideSlots={}
  local f=function(a,p)if a then table.insert(sideSlots,p)else getPile(p..' pile').destruct()end end
  f(Use('Page'),'Champion')
  f(Use('Page'),'Hero')
  f(Use('Page'),'Warrior')
  f(Use('Page'),'Treasure Hunter')
  f(Use('Peasant'),'Teacher')
  f(Use('Peasant'),'Disciple')
  f(Use('Peasant'),'Fugitive')
  f(Use('Peasant'),'Soldier')
  f(Use('Spoils'),'Spoils')
  f(Use('Mercenary'),'Mercenary')
  f(Use('Madman'),'Madman')
  f(Use('Prize'),'Prize')
  f(Use('Ghost'),'Ghost')
  f(Use('Imp'),'Imp')
  f(Use('Fate')or(Use('Imp')and Use('Ghost')),'Will-o\'-Wisp')
  f(Use('Wish'),'Wish')
  f(Use('Vampire'),'Bat')
  f(Use('Horse'),'Horses')
  f(Use('Fate'),'Boons')
  f(Use('Doom'),'Hexes')
  f(Use('Doom')or Use('Fool'),'States')
  f(Use('Artifact'),'Artifacts')
  f(Use('Hyde'),'Hyde')
  f(Use('Heir'),'Heir')
  f(Use('BogusLands'),'Bogus Lands')
  f(Use('Road'),'Road')
  f(Use('ZombieLegacy'),'Zombie Legacy')
  f(Use('LoyalSubjects'),'Loyal Subjects')
  
  local dC=1
  if Use('Druid')then dC=4 end
  
  for i,v in ipairs(sideSlots)do getPile(v..' pile').setPosition(ref_sideSlots[i].pos)end
  for i=#sideSlots+dC,#ref_sideSlots do getObjectFromGUID(ref_sideSlots[i].guid).destruct()end
  for _,o in ipairs(getObjectFromGUID(ref_storageZone.script).getObjects())do o.shuffle()o.setLock(false)end
  
  for _,g in pairs(ref_storageZone)do getObjectFromGUID(g).destruct()end
  
  for i,es in ipairs(ref_eventSlots)do
    local obj,zone=getObjectFromGUID(es.guid),getObjectFromGUID(es.zone)
    for _,o2 in ipairs(zone.getObjects())do
      if o2.tag=='Card'then
        if eventCount==3 then
          o2.setPosition({o2.getPosition()[1]+3.5, o2.getPosition()[2], o2.getPosition()[3]})
        elseif eventCount==2 then
          o2.setPosition({o2.getPosition()[1]+7, o2.getPosition()[2], o2.getPosition()[3]})
        elseif eventCount==1 then
          o2.setPosition({o2.getPosition()[1]+10.5, o2.getPosition()[2], o2.getPosition()[3]})
        end
      end
    end
    if i > eventCount then
      obj.destruct()
    elseif eventCount==3 then
      obj.setPosition({obj.getPosition()[1]+3.5, obj.getPosition()[2], obj.getPosition()[3]})
    elseif eventCount==2 then
      obj.setPosition({obj.getPosition()[1]+7, obj.getPosition()[2], obj.getPosition()[3]})
    elseif eventCount==1 then
      obj.setPosition({obj.getPosition()[1]+10.5, obj.getPosition()[2], obj.getPosition()[3]})
    end
  end
  
  local temp,names={
'Reserve',      'Exile',        'NativeVillage',     'Island',        'Project',     'PirateShip',
'Aside',        'PlusCard',     'PlusAction',        'TwoCost',       'PlusBuy',     'TradeRoute',
'PlusCoin',     'MinusCoin',    'MinusCard',         'Trashing',      'Estate',      'BlackMarket',
'Journey',      'Coffers',      'VP',                'Debt',          'Villager'},{
'Tavern Mat',   'Exile Mat',    'Native Village Mat','Island Mat',    'Owns Project','Pirate Ship Coins',
'Set Aside',    '+1 Card Token','+1 Action Token',   '-2 Cost Token', '+1 Buy Token','Trade Route Mat',
'+1 Coin Token','-1 Coin Token','-1 Card Token',     'Trashing Token','Estate Token','Black Market Mat',
'Journey Token','Coffers',      'Victory Points',    'Debt Tokens',   'Villagers'}
  for i,v in ipairs(temp)do if not Use(v)then for _,obj in pairs(getAllObjects())do if obj.getName()==names[i]or obj.getName()=='Rules '..names[i]then obj.destruct()end end end end
  getObjectFromGUID(ref.board).destruct()
  local toRemove={}
  if getPlayerCount()~=6 then
    for i in pairs(ref_players)do
      local found=false
      for j=1, #getSeatedPlayers()do
        local currentPlayer=getSeatedPlayers()[j]
        if currentPlayer==i and Player[currentPlayer].getHandCount() > 0 then
          found=true
      end end
      if not found then
        table.insert(toRemove,i)
  end end end
  for i,v in pairs(toRemove)do for j,o in ipairs(getObjectFromGUID(ref_players[v].zone).getObjects())do o.destruct()end end
  function tokenCoroutine()
    wait(4)
    log(Use[1])
    if Use('TradeRoute')or Use('Tax')or Use('Landmark')or Use('Gathering')then
      obeliskPiles={}
      local function slot(z)
        for __,obj in ipairs(getObjectFromGUID(z).getObjects())do
          if obj.tag=='Deck'then
            getSetup('Tax')(obj)
            getSetup('Obelisk')(obj)
            getSetup('Aqueduct')(obj)
            getSetup('Trade Route')(obj)
            getSetup('Defiled Shrine')(obj)
            if getType(obj.getObjects()[obj.getQuantity()].name):find('Gathering')then tokenMake(obj,'vp')end
            break end end end
      for _,v in ipairs(ref_basicSlotZones)do slot(v)end
      for _,v in ipairs(ref_kingdomSlots)do slot(v.zone)end
      slot(ref.baneSlot.zone)
      
      for __,v in ipairs(ref_eventSlots)do
        for _,obj in ipairs(getObjectFromGUID(v.zone).getObjects())do
          if obj.tag=='Card'then
            if obj.getName()=='Aqueduct'or obj.getName()=='Defiled Shrine'then tokenMake(obj,'vp',0)end
            if obj.getName()=='Arena'or obj.getName()=='Basilica'or obj.getName()=='Baths'or obj.getName()=='Battlefield'or obj.getName()=='Colonnade'or obj.getName()=='Labyrinth'then
              tokenMake(obj,'vp',getPlayerCount()*6)end
            if obj.getName()=='Obelisk'then
                local k=math.random(1,#obeliskPiles)
                obj.highlightOn({1,0,1})
                obeliskPiles[k].highlightOn({1,0,1})
                obeliskTarget=obeliskPiles[k].getName():sub(1,-6)
                obeliskPiles =nil
            end break
    end end end end
    if Use('BlackMarket')then pos=blackMarketDeck.getPosition()local g=0
      for i,card in ipairs(blackMarketDeck.getObjects())do
        if getType(card.name):find('Gathering')then g=g+1
          if     g==1 then tokenMake(blackMarketDeck,'vp',0,nil,card.nickname)
          elseif g==2 then tokenMake(blackMarketDeck,'vp',0,{0.9,1,-1.25},card.nickname)
          else   tokenMake(blackMarketDeck,'vp',0,{-0.9,1,-1.25},card.nickname)
    end end end end
    wait(1)
    for _,v in pairs(ref_tokenBag)do getObjectFromGUID(v).destruct()end
    if getPile('Heirlooms')then getPile('Heirlooms').destruct()end
    return 1
  end
  startLuaCoroutine(Global, 'tokenCoroutine')
  if useShelters~=1 and getPile('Shelters')then
    getPile('Shelters').destruct()
    setupBaseCardCount(false, false)
  else
    setupBaseCardCount(true, false)
  end
end
function createHeirlooms(c)
  for n,card in pairs({['Secret Cave']='Magic Lamp',['Cemetery']='Haunted Mirror',['Shepherd']='Pasture',['Tracker']='Pouch',['Pooka']='Cursed Gold',['Pixie']='Goat',['Fool']='Lucky Coin',['Magician']='Rabbit'})do
    if c==n then getPile('Heirlooms').takeObject({position=getObjectFromGUID(ref_storageZone.heirloom).getPosition(),guid=ref_heirlooms[card],flip=true})break end end end
function createPile()
  for _,ks in pairs(ref_kingdomSlots)do
    for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
      if v.tag=='Card'then local k=1--First we check for 2 player Castles
        if v.getName()=='Castles'then v.destruct()getPile('Castles pile').setPosition(ks.pos)
          if getPlayerCount()==2 then
            for _,name in pairs({'Humble Castle','Small Castle','Opulent Castle','King\'s Castle'})do
              for l, card in ipairs(getPile('Castles pile').getObjects())do
                if card.nickname==name then
                  getPile('Castles pile').takeObject({index=card.index}).destruct()
                  break end end end end
        --If we have a victory card and 2 players, we make 8 copies
        elseif getPlayerCount()==2 and getType(v.getName()):find('Victory')then
          while k<8 do v.clone({position=ks.pos})k=k+1 end
          --If we have a victory card or the card is Port, we make 12 copies
        elseif getType(v.getName()):find('Victory')or v.getName()=='Port'then
          while k<12 do v.clone({position=ks.pos})k=k+1 end
        --If we have Rats, we get 20 copies
        elseif v.getName()=='Rats'then
          while k<20 do v.clone({position=ks.pos})k=k+1 end
        --If we have Knights, we swap in the Knights pile
        elseif v.getName()=='Knights'then
          v.destruct()getPile('Knights pile').setPosition(ks.pos)getPile('Knights pile').shuffle()
        elseif v.getName()=='Catapult / Rocks'then
          v.destruct()getPile('Catapult / Rocks pile').setPosition(ks.pos)
        elseif v.getName()=='Encampment / Plunder'then
          v.destruct()getPile('Encampment / Plunder pile').setPosition(ks.pos)
        elseif v.getName()=='Gladiator / Fortune'then
          v.destruct()getPile('Gladiator / Fortune pile').setPosition(ks.pos)
        elseif v.getName()=='Patrician / Emporium'then
          v.destruct()getPile('Patrician / Emporium pile').setPosition(ks.pos)
        elseif v.getName()=='Settlers / Bustling Village'then
          v.destruct()getPile('Settlers / Bustling Village pile').setPosition(ks.pos)
        elseif v.getName()=='Sauna / Avanto'then
          v.destruct()getPile('Sauna / Avanto pile').setPosition(ks.pos)
        --All other cards get 10 copies
        else while k<10 do v.clone({position=ks.pos})k=k+1
  end end end end end
  local removeBane=true
  for i,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
    if v.tag=='Card'then removeBane=false local k=1
      if getPlayerCount()==2 and v.getName()=='Castles'then v.destruct()getPile('Castles pile').setPosition(ref.baneSlot.pos)
        for k=1,4 do
          for l,card in ipairs(castlesPile.getObjects())do
            if k==1 and card.nickname=='Humble Castle'then
              getPile('Castles pile').takeObject({index=card.index}).destruct()break
            elseif k==2 and card.nickname=='Small Castle'then
              getPile('Castles pile').takeObject({index=card.index}).destruct()break
            elseif k==3 and card.nickname=='Opulent Castle'then
              getPile('Castles pile').takeObject({index=card.index}).destruct()break
            elseif k==4 and card.nickname=='King\'s Castle'then
              getPile('Castles pile').takeObject({index=card.index}).destruct()break
        end end end
      --Then we do 3+ player Castles
      elseif v.getName()=='Castles'then v.destruct()getPile('Castles pile').setPosition(ref.baneSlot.pos)
      --If we have a victory card and 2 players, we make 8 copies
      elseif getPlayerCount()==2 and getType(v.getName()):find('Victory')then
        while k<8 do v.clone({position=ref.baneSlot.pos})k=k+1 end
      --If we have a victory card, we make 12 copies
      elseif v.getDescription():find('Victory')then
        while k<12 do v.clone({position=ref.baneSlot.pos})k=k+1 end
      --If we have Knights, we swap in the Knights pile
      elseif v.getName()=='Catapult / Rocks'then
        v.destruct()getPile('Catapult / Rocks pile').setPosition(ref.baneSlot.pos)
      elseif v.getName()=='Encampment / Plunder'then
        v.destruct()getPile('Encampment / Plunder pile').setPosition(ref.baneSlot.pos)
      elseif v.getName()=='Gladiator / Fortune'then
        v.destruct()getPile('Gladiator / Fortune pile').setPosition(ref.baneSlot.pos)
      elseif v.getName()=='Patrician / Emporium'then
        v.destruct()getPile('Patrician / Emporium pile').setPosition(ref.baneSlot.pos)
      elseif v.getName()=='Settlers / Bustling Village'then
        v.destruct()getPile('Settlers / Bustling Village pile').setPosition(ref.baneSlot.pos)
      --All other cards get 10 copies
      else while k<10 do v.clone({position=ref.baneSlot.pos})k=k+1
  end end end end
  --Coroutine names the piles after they form
  function createPileCoroutine()wait(2)
    if getPile('Heirlooms')then getPile('Heirlooms').destruct()end
    for _,ks in pairs(ref_kingdomSlots)do
      for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
        if v.tag=='Deck'and v.getName():sub(-5)~=' pile'then
            v.setName(v.takeObject({position=v.getPosition()}).getName()..' pile')
    end end end
    if not removeBane then
      for _,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
        if v.tag=='Deck'and v.getName():sub(-5)~=' pile'then
            v.setName(v.takeObject({position=v.getPosition()}).getName()..' pile')
    end end end cleanUp()return 1
  end startLuaCoroutine(Global, 'createPileCoroutine')end
function getVP(n)for _,v in pairs(ref_master)do if n==v.name then if v.VP then return v.VP end return 0 end end end
function getCost(n)for _,v in pairs(ref_master)do if n==v.name then return v.cost end end return'M0D0P0'end
function getType(n)for _,v in pairs(ref_master)do if n==v.name then return v.type end end return'Event'end
function getSetup(n)if Use(n:gsub(' ',''))then for _,v in pairs(ref_master)do if n==v.name then if v.setup then return v.setup end end end end return function()end end
function getPile(pileName)
  for _,p in pairs(ref_replacementPiles)do if pileName==p.name then return getObjectFromGUID(p.guid)end end
  for _,p in pairs(ref_basicSupplyPiles)do if pileName==p.name then return getObjectFromGUID(p.guid)end end
  for _,p in pairs(ref_extraSupplyPiles)do if pileName==p.name then return getObjectFromGUID(p.guid)end end
  for _,p in pairs(ref_sidePiles       )do if pileName==p.name then return getObjectFromGUID(p.guid)end end
end
-- Function to set the correct count of base cards
function setupBaseCardCount(useShelters, useHeirlooms)
  local pCount=getPlayerCount()
  --Starting Estates
  if useShelters and getPile('Shelters')then
    removeFromPile(getPile('Estates'), 18)
  else
    removeFromPile(getPile('Estates'), 18 - (pCount * 3))
  end
  --Starting Curses
  removeFromPile(getPile('Curses'), 50 - ((pCount - 1) * 10))
  if getPile('Ruins pile')then
    getPile('Ruins pile').shuffle()
    removeFromPile(getPile('Ruins pile'), 50 - ((pCount - 1) * 10))
  end
  --Starting Treasures
  if pCount > 4 then
    removeFromPile(getPile('Coppers'), 40)
    removeFromPile(getPile('Silvers'), 10)
    removeFromPile(getPile('Golds'), 12)
  elseif pCount < 5 then
    removeFromPile(getPile('Coppers'), 60)
    removeFromPile(getPile('Silvers'), 40)
    removeFromPile(getPile('Golds'), 30)
  end
  -- Remove Coppers when using Heirlooms
  if useHeirlooms then
    removeFromPile(getPile('Coppers'), (pCount * 7))
  end
  --Starting Provinces
  if pCount==5 then
    removeFromPile(getPile('Provinces'), 3)
  elseif pCount < 5 then
    removeFromPile(getPile('Provinces'), 6)
  end
  --2 Player Victory Card Setup
  if pCount==2 then
    removeFromPile(getPile('Estates'), 4)
    removeFromPile(getPile('Duchies'), 4)
    removeFromPile(getPile('Provinces'), 4)
    if usePlatinum==1 then
        removeFromPile(getPile('Colonies'), 4)
    end
  end
  setupStartingDecks(useShelters, useHeirlooms)
end
-- Function to setup starting Decks
function setupStartingDecks(useShelters, useHeirlooms)
  --make a pile with used Heirlooms to copy
  local c,z,h=1,getObjectFromGUID(ref_storageZone.heirloom).getObjects(),false
  for _,obj in pairs(z)do if obj.tag=='Deck'then c,h=1+obj.getQuantity(),obj elseif obj.tag=='Card'then c,h=2,obj end end
  --Creating the starting decks
  for i=1,#getSeatedPlayers()do
    local p=getSeatedPlayers()[i]
    if 0<Player[p].getHandCount()then
      if h then h.clone({position=ref_players[p].deck})end
      for j=c,7 do getPile('Coppers').takeObject({position=ref_players[p].deck,flip=true})end
      if useShelters and getPile('Shelters')then
        getPile('Shelters').clone({position=ref_players[p].deck,rotation={0,180,180}})
      else for j=1,3 do getPile('Estates').takeObject({position=ref_players[p].deck,flip=true})
  end end end end
  if useShelters and getPile('Shelters')then getPile('Shelters').destruct()end
  dealStartingHands()
end
-- Function to deal starting hands
function dealStartingHands()
  function dealStartingHandsCoroutine()
    wait(2)
    for i, v in pairs(ref_players)do
      for j, b in pairs(getObjectFromGUID(v.deckZone).getObjects())do
        if b.tag=='Deck'then
          b.shuffle()
        end
      end
    end
    wait(0.5)
    for i, v in pairs(ref_players)do
      for j, b in pairs(getObjectFromGUID(v.deckZone).getObjects())do
        if b.tag=='Deck'then
            b.deal(5, i)
        end
      end
    end
    createEndButton()
    gameState=3
    setNotes('[40e0d0][b][u]Dominion: Definitive Edition[/b][/u][ffffff]\n\nMake sure all cards are in each player\'s hand, deck, discard, Tavern mat, Island mat, or Native Village mat before pressing End Game. Any card outside of these areas will not be counted.')
    
    local t=getSeatedPlayers()
    Turns.turn_color=t[math.random(1,#t)]
    Turns.enable=true
    return 1
  end
  startLuaCoroutine(Global, 'dealStartingHandsCoroutine')
end
function removeFromPile(pile, count)
  log(count,pile.getName())
  local total=pile.getQuantity()-count
  while pile.getQuantity()>total do pile.takeObject({}).destruct()
end end
-- Function to get a count of players sitting at the table with hands to be dealt to.
function getPlayerCount()local c=#getSeatedPlayers()for i=1,#getSeatedPlayers()do if Player[getSeatedPlayers()[i]].getHandCount()<1 then p=p-1 end end if c==1 then return 6 end return c end
-- Function to wait during coroutines
function wait(time)local start=os.time()repeat coroutine.yield(0)until os.time()>start+time end
--Shortcut broadcast function to shorten them when I call them in the code
function bcast(m,c,p)if c==nil then c={1,1,1}end if p then Player[p].broadcast(m,c)else broadcastToAll(m,c)end end
function tokenCallback(obj,s)obj.call('setOwner',s)end
function tokenMake(obj,key,n,pos,name)
  local p=obj.getPosition()
  if pos then
    p={p[1]+pos[1],p[2]+pos[2],p[3]+pos[3]}
  elseif key=='vp'then
    p={p[1]+0.9,p[2]+1,p[3]+1.25}
  elseif key=='debt'then
    p={p[1]-0.9,p[2]+1,p[3]-1.25}
  else
    p={p[1]-0.9,p[2]+1,p[3]-1.25}
  end 
  local t={position=p,rotation={0,180,0},callback='tokenCallback',callback_owner=Global,params={name or obj.getName(),n or 0}}
  log(t.params)
  getObjectFromGUID(ref_tokenBag[key]).takeObject(t)
end
--Function to set uninteractible objects
function setUninteractible(t)for k,g in pairs(t)do local obj=getObjectFromGUID(g.guid or g)
  if obj and obj.interactable==false then print((g.guid or g)..' '..k..' is Duplicate guid!')
  elseif obj then obj.interactable=false else log(g,k)end end end
--Reference Tables
ref={
baneSlot   ={guid='df4a68',pos={15,1.3,22},zone='5b9b18'},
randomizer ={guid='3d5008',pos={20,1.3,22},zone='fd0b1d'},
tradeRoute ={guid='b853e8',pos={17.5,1.6,8.5}},
startButton='176e6a',board='7636a9'}
ref_heirlooms={}
ref_storageZone={script='06110c',setup='b19032',fog='2c0471',fog2='ab5594',heirloom='eb483b'}
ref_tokenBag={coin='491d9b',debt='7624c9',vp='b935ba'}
ref_basicSlotZones={'198948','a5940e','86fa0b','810603','0bd7f8','2a639d','67f21e','b33712','d484d7','7f9e58','378afe'}
ref_basicSlots={
{guid='377aaf',pos={-25,1.3,31.5}},
{guid='563a61',pos={-20,1.3,31.5}},
{guid='56dcad',pos={-15,1.3,31.5}},
{guid='d516bd',pos={-10,1.3,31.5}},
{guid='4b9597',pos={ -5,1.3,31.5}},
{guid='28c05c',pos={ 20,1.3,31.5}},
{guid='00d4cc',pos={ 25,1.3,31.5}},
{guid='497478'},{guid='e700bc'},{guid='81d094'},{guid='b60e21'}}
ref_sideSlots={
{guid='7ba0bf'},{guid='de9a73'},{guid='61ae8d'},{guid='f7a574'},
{guid='bb0b4f'},{guid='25756f'},{guid='1e113a'},{guid='2ea60a'},
{guid='8cf7ae'},{guid='d8a850'},{guid='3ba1c2'},{guid='d5f986'},
{guid='f0bd83'},{guid='811c7b'},{guid='fa020b'},{guid='a96aef'},
{guid='5bd468'},{guid='e6fed4'},{guid='5e6695'},{guid='fb0663'},

{guid='7535f5'},{guid='eaf95e'},{guid='adb237'},{guid='bf9dda'},
{guid='18a0ba'},{guid='98bcc2'},{guid='561fa6'},{guid='72bf1b'},
{guid='bf7652'},{guid='5750e9'},{guid='5a0bb6'},{guid='08dc7f'},
{guid='dc9cf0'},{guid='fa776f'},{guid='7fb923'},{guid='788b21'},
{guid='a6f52e'},{guid='91e763'},{guid='4733fe'},{guid='e47c8a'},
{guid='b6ce05'},{guid='8a299d'},{guid='bf7652'},{guid='6c4cb9'},
{guid='755720'},{guid='5c1bf4'},}
ref_eventSlots={
{guid='e091ca',zone='f5e84d',pos={-10.5,1.25,8.5}},
{guid='bb3643',zone='2ffd78',pos={ -3.5,1.25,8.5}},
{guid='1ff6fe',zone='65aaf5',pos={  3.5,1.25,8.5}},
{guid='6ca433',zone='0c28db',pos={ 10.5,1.25,8.5}}}
ref_basicSupplyPiles={
{guid='3a738e',name='Coppers'},
{guid='a655a3',name='Silvers'},
{guid='b11add',name='Golds'},
{guid='d9a2c0',name='Curses'},
{guid='4d0b0e',name='Estates'},
{guid='d253c8',name='Duchies'},
{guid='4a8334',name='Provinces'}}
ref_extraSupplyPiles={
{guid='85fcca',name='Platinums'},
{guid='475de7',name='Potions'},
{guid='6ce695',name='Colonies'},
{guid='2adf43',name='Ruins pile'},
{guid='9c6cd8',name='Shelters'},
{guid='4033ec',name='Heirlooms'},
{guid='aa2438',name='Zombies'}}
ref_sidePiles={
{name='Loyal Subjects pile'},
{name='Zombie Legacy pile'},
{name='Road pile'},
{name='Bogus Lands pile'},
{name='Heir pile'},
{name='Hyde pile'},
{name='Artifacts pile'},
{name='States pile'},
{name='Horses pile'},
{name='Boons pile'},
{name='Hexes pile'},
{name='Wish pile'},
{name='Bat pile'},
{name='Will-o\'-Wisp pile'},
{name='Imp pile'},
{name='Ghost pile'},
{name='Prize pile'},
{name='Madman pile'},
{name='Mercenary pile'},
{name='Spoils pile'},
{name='Treasure Hunter pile'},
{name='Warrior pile'},
{name='Hero pile'},
{name='Champion pile'},
{name='Soldier pile'},
{name='Fugitive pile'},
{name='Disciple pile'},
{name='Teacher pile'}}
ref_replacementPiles={
{name='Knights pile'},
{name='Sauna / Avanto pile'},
{name='Castles pile'},
{name='Catapult / Rocks pile'},
{name='Encampment / Plunder pile'},
{name='Gladiator / Fortune pile'},
{name='Patrician / Emporium pile'},
{name='Settlers / Bustling Village pile'},
{name='Stallions pile'}}
ref_kingdomSlots={
{guid='ea57b1',zone='987e4a',pos={-10,1.3,22}},
{guid='08e74d',zone='816553',pos={ -5,1.3,22}},
{guid='3efdc8',zone='7b20e5',pos={  0,1.3,22}},
{guid='4e4e40',zone='740c12',pos={  5,1.3,22}},
{guid='4084c6',zone='fefd47',pos={ 10,1.3,22}},
{guid='6be6f9',zone='47d4f1',pos={-10,1.3,14.5}},
{guid='4ab1b9',zone='4a3f91',pos={ -5,1.3,14.5}},
{guid='48b491',zone='9d12c3',pos={  0,1.3,14.5}},
{guid='03a180',zone='9e931d',pos={  5,1.3,14.5}},
{guid='25f0bd',zone='00770c',pos={ 10,1.3,14.5}}}
ref_players={
Blue  ={deckZone='307d12',discardZone='41de74',zone='062acc',coins='b2dc22',vp='b59b65',debt='186c83',tavern='015528',deck={-46.5,3,21},discard={-51.5,3,21}},
Green ={deckZone='9359a4',discardZone='72ba37',zone='c11794',coins='22bdb3',vp='6ae2a8',debt='a34771',tavern='af5c58',deck={-46.5,3,-21},discard={-51.5,3,-21}},
White ={deckZone='e6b388',discardZone='eb044b',zone='c95925',coins='b6bf41',vp='1b4618',debt='3d4844',tavern='d7d996',deck={-18.5,3,-21},discard={-23.5,3,-21}},
Red   ={deckZone='5a6e68',discardZone='e09013',zone='d1c5af',coins='4b832d',vp='84f540',debt='9cfa4a',tavern='48295f',deck={23.5,3,-21},discard={18.5,3,-21}},
Orange={deckZone='420340',discardZone='bf9b32',zone='10c425',coins='ce8828',vp='0d128b',debt='f2a253',tavern='fd4953',deck={51.5,3,-21},discard={46.5,3,-21}},
Yellow={deckZone='7ee56d',discardZone='046cfd',zone='827520',coins='17dd2a',vp='c979ca',debt='10cb81',tavern='dea1f7',deck={51.5,3,21},discard={46.5,3,21}}}
--All card sets/expansions
ref_cardSets={
{name='Dominion'},
{name='Intrigue'},
{name='Seaside'},
{name='Alchemy'},
{name='Prosperity'},
{name='Cornucopia'},
{name='Hinterlands'},
{name='Dark Ages'},
{name='Guilds'},
{name='Adventures',events={1}},
{name='Empires',events={2,3}},
{name='Nocturne'},
{name='Renaissance',events={4}},
{name='Menagerie',events={5,6}},
{name='Xtras'},
{name='Legacy',events={9}},
{name='Legacy Expert',events={9,10}},
{name='Spellcasters',events={11}},
{name='Seasons'},
{name='Legacy Teams'},
{name='Promos',events={7}},
{name='Adamabrams',events={8}},
{name='Cut Dominion cards'},
{name='Cut Intrigue cards'},
{name='Duplicate Legacy Cards'}}
ref_eventSets={
{name='Adventures Events'},
{name='Empires Events'},
{name='Empires Landmarks'},
{name='Renaissance Projects'},
{name='Menagerie Events'},
{name='Menagerie Ways'},
{name='Summon'},
{name='Adamabrams Extras'},
{name='Legacy Events'},
{name='Legacy Edicts'},
{name='Spellcasters Spells'}}
--Name of all cards along with costs, used for sorting
ref_master={
{cost='M0D0P0',name='Copper',type='Treasure'},
{cost='M3D0P0',name='Silver',type='Treasure'},
{cost='M6D0P0',name='Gold',type='Treasure'},
{cost='M9D0P0',name='Platinum',type='Treasure'},
{cost='M4D0P0',name='Potion',type='Treasure'},
{cost='M0D0P0',name='Curse',type='Curse',VP=-1},
{cost='M2D0P0',name='Estate',type='Victory',VP=1},
{cost='M5D0P0',name='Duchy',type='Victory',VP=3},
{cost='M8D0P0',name='Province',type='Victory',VP=6},
{cost='MBD0P0',name='Colony',type='Victory',VP=10},
{cost='M6D0P0',name='Artisan',type='Action'},
{cost='M5D0P0',name='Bandit',type='Action - Attack'},
{cost='M4D0P0',name='Bureaucrat',type='Action - Attack'},
{cost='M2D0P0',name='Cellar',type='Action'},
{cost='M2D0P0',name='Chapel',type='Action'},
{cost='M5D0P0',name='Council Room',type='Action'},
{cost='M5D0P0',name='Festival',type='Action'},
{cost='M4D0P0',name='Gardens',type='Victory',VP=function(t)return math.floor(t.amount/10)end},
{cost='M3D0P0',name='Harbinger',type='Action'},
{cost='M5D0P0',name='Laboratory',type='Action'},
{cost='M5D0P0',name='Library',type='Action'},
{cost='M5D0P0',name='Market',type='Action'},
{cost='M3D0P0',name='Merchant',type='Action'},
{cost='M4D0P0',name='Militia',type='Action - Attack'},
{cost='M5D0P0',name='Mine',type='Action'},
{cost='M2D0P0',name='Moat',type='Action - Reaction'},
{cost='M4D0P0',name='Moneylender',type='Action'},
{cost='M4D0P0',name='Poacher',type='Action'},
{cost='M4D0P0',name='Remodel',type='Action'},
{cost='M5D0P0',name='Sentry',type='Action'},
{cost='M4D0P0',name='Smithy',type='Action'},
{cost='M4D0P0',name='Throne Room',type='Action'},
{cost='M3D0P0',name='Vassal',type='Action'},
{cost='M3D0P0',name='Village',type='Action'},
{cost='M5D0P0',name='Witch',type='Action - Attack'},
{cost='M3D0P0',name='Workshop',type='Action'},
{cost='M4D0P0',name='Baron',type='Action'},
{cost='M4D0P0',name='Bridge',type='Action'},
{cost='M4D0P0',name='Conspirator',type='Action'},
{cost='M5D0P0',name='Courtier',type='Action'},
{cost='M2D0P0',name='Courtyard',type='Action'},
{cost='M4D0P0',name='Diplomat',type='Action - Reaction'},
{cost='M5D0P0',name='Duke',type='Victory',VP=function(t)return t.deck['Duchy']or 0 end},
{cost='M6D0P0',name='Harem',type='Treasure - Victory',VP=2},
{cost='M4D0P0',name='Ironworks',type='Action'},
{cost='M2D0P0',name='Lurker',type='Action'},
{cost='M3D0P0',name='Masquerade',type='Action'},
{cost='M4D0P0',name='Mill',type='Action - Victory',VP=1},
{cost='M4D0P0',name='Mining Village',type='Action'},
{cost='M5D0P0',name='Minion',type='Action - Attack'},
{cost='M6D0P0',name='Nobles',type='Action - Victory',VP=2},
{cost='M5D0P0',name='Patrol',type='Action'},
{cost='M2D0P0',name='Pawn',type='Action'},
{cost='M5D0P0',name='Replace',type='Action - Attack'},
{cost='M3D0P0',name='Steward',type='Action'},
{cost='M3D0P0',name='Swindler',type='Action - Attack'},
{cost='M3D0P0',name='Shanty Town',type='Action'},
{cost='M4D0P0',name='Secret Passage',type='Action'},
{cost='M5D0P0',name='Trading Post',type='Action'},
{cost='M5D0P0',name='Torturer',type='Action - Attack'},
{cost='M5D0P0',name='Upgrade',type='Action'},
{cost='M3D0P0',name='Wishing Well',type='Action'},
{cost='M3D0P0',name='Ambassador',type='Action - Attack'},
{cost='M5D0P0',name='Bazaar',type='Action'},
{cost='M4D0P0',name='Caravan',type='Action - Duration'},
{cost='M4D0P0',name='Cutpurse',type='Action - Attack'},
{cost='M2D0P0',name='Embargo',type='Action'},
{cost='M5D0P0',name='Explorer',type='Action'},
{cost='M3D0P0',name='Fishing Village',type='Action - Duration'},
{cost='M5D0P0',name='Ghost Ship',type='Action - Attack'},
{cost='M2D0P0',name='Haven',type='Action - Duration'},
{cost='M4D0P0',name='Island',type='Action - Victory',depend='Island',VP=2},
{cost='M2D0P0',name='Lighthouse',type='Action - Duration'},
{cost='M3D0P0',name='Lookout',type='Action'},
{cost='M5D0P0',name='Merchant Ship',type='Action - Duration'},
{cost='M2D0P0',name='Native Village',type='Action',depend='NativeVillage'},
{cost='M4D0P0',name='Navigator',type='Action'},
{cost='M5D0P0',name='Outpost',type='Action - Duration'},
{cost='M2D0P0',name='Pearl Diver',type='Action'},
{cost='M4D0P0',name='Pirate Ship',type='Action - Attack',depend='PirateShip'},
{cost='M4D0P0',name='Salvager',type='Action'},
{cost='M4D0P0',name='Sea Hag',type='Action - Attack'},
{cost='M3D0P0',name='Smugglers',type='Action'},
{cost='M5D0P0',name='Tactician',type='Action - Duration'},
{cost='M4D0P0',name='Treasure Map',type='Action'},
{cost='M5D0P0',name='Treasury',type='Action'},
{cost='M3D0P0',name='Warehouse',type='Action'},
{cost='M5D0P0',name='Wharf',type='Action - Duration'},
{cost='M3D0P1',name='Alchemist',type='Action'},
{cost='M2D0P1',name='Apothecary',type='Action'},
{cost='M5D0P0',name='Apprentice',type='Action'},
{cost='M3D0P1',name='Familiar',type='Action - Attack'},
{cost='M4D0P1',name='Golem',type='Action'},
{cost='M2D0P0',name='Herbalist',type='Action'},
{cost='M3D0P1',name='Philosopher\'s Stone',type='Treasure'},
{cost='M6D0P1',name='Possession',type='Action'},
{cost='M2D0P1',name='Scrying Pool',type='Action - Attack'},
{cost='M0D0P1',name='Transmute',type='Action'},
{cost='M2D0P1',name='University',type='Action'},
{cost='M0D0P1',name='Vineyard',type='Victory',VP=function(t)return math.floor(t.actions/3) end},
{cost='M7D0P0',name='Bank',type='Treasure'},--Prosperity
{cost='M4D0P0',name='Bishop',type='Action',depend='VP'},
{cost='M5D0P0',name='City',type='Action'},
{cost='M5D0P0',name='Contraband',type='Treasure'},
{cost='M5D0P0',name='Counting House',type='Action'},
{cost='M7D0P0',name='Expand',type='Action'},
{cost='M7D0P0',name='Forge',type='Action'},
{cost='M6D0P0',name='Goons',type='Action - Attack',depend='VP'},
{cost='M6D0P0',name='Grand Market',type='Action'},
{cost='M6D0P0',name='Hoard',type='Treasure'},
{cost='M7D0P0',name='King\'s Court',type='Action'},
{cost='M3D0P0',name='Loan',type='Treasure'},
{cost='M5D0P0',name='Mint',type='Action'},
{cost='M4D0P0',name='Monument',type='Action',depend='VP'},
{cost='M5D0P0',name='Mountebank',type='Action - Attack'},
{cost='M8D0P0',name='Peddler',type='Action'},
{cost='M4D0P0',name='Quarry',type='Treasure'},
{cost='M5D0P0',name='Rabble',type='Action - Attack'},
{cost='M5D0P0',name='Royal Seal',type='Treasure'},
{cost='M4D0P0',name='Talisman',type='Treasure'},
{cost='M3D0P0',name='Trade Route',type='Action',setup=function(o)if getType(o.getObjects()[1].name):find('Victory')and not getType(o.getObjects()[1].name):find('Knight')then tokenMake(o,'coin')end end},
{cost='M5D0P0',name='Vault',type='Action'},
{cost='M5D0P0',name='Venture',type='Treasure'},
{cost='M3D0P0',name='Watchtower',type='Action - Reactopm'},
{cost='M4D0P0',name='Worker\'s Village',type='Action'},
{cost='M6D0P0',name='Fairgrounds',type='Victory',VP=function(t)return 2*math.floor(#t.deck/5)end},--Cornucopia
{cost='M4D0P0',name='Farming Village',type='Action'},
{cost='M3D0P0',name='Fortune Teller',type='Action - Attack'},
{cost='M2D0P0',name='Hamlet',type='Action'},
{cost='M5D0P0',name='Harvest',type='Action'},
{cost='M5D0P0',name='Horn of Plenty',type='Treasure'},
{cost='M4D0P0',name='Horse Traders',type='Action - Reaction'},
{cost='M5D0P0',name='Hunting Party',type='Action'},
{cost='M5D0P0',name='Jester',type='Action - Attack'},
{cost='M3D0P0',name='Menagerie',type='Action'},
{cost='M4D0P0',name='Remake',type='Action'},
{cost='M4D0P0',name='Tournament',type='Action',depend='Prize'},
{cost='M4D0P0',name='Young Witch',type='Action - Attack',depend='Bane'},
{cost='M0D0P0',name='Bag of Gold',type='Action - Prize'},
{cost='M0D0P0',name='Diadem',type='Treasure - Prize'},
{cost='M0D0P0',name='Followers',type='Action - Attack - Prize'},
{cost='M0D0P0',name='Princess',type='Action - Prize'},
{cost='M0D0P0',name='Trusty Steed',type='Action - Prize'},
{cost='M6D0P0',name='Border Village',type='Action'},
{cost='M5D0P0',name='Cache',type='Treasure'},
{cost='M5D0P0',name='Cartographer',type='Action'},
{cost='M2D0P0',name='Crossroads',type='Action'},
{cost='M3D0P0',name='Develop',type='Action'},
{cost='M2D0P0',name='Duchess',type='Action'},
{cost='M5D0P0',name='Embassy',type='Action'},
{cost='M6D0P0',name='Farmland',type='Victory',VP=2},
{cost='M2D0P0',name='Fool\'s Gold',type='Treasure - Reaction'},
{cost='M5D0P0',name='Haggler',type='Action'},
{cost='M5D0P0',name='Highway',type='Action'},
{cost='M5D0P0',name='Ill-Gotten Gains',type='Treasure'},
{cost='M5D0P0',name='Inn',type='Action'},
{cost='M4D0P0',name='Jack of All Trades',type='Action'},
{cost='M5D0P0',name='Mandarin',type='Action'},
{cost='M5D0P0',name='Margrave',type='Action - Attack'},
{cost='M4D0P0',name='Noble Brigand',type='Action - Attack'},
{cost='M4D0P0',name='Nomad Camp',type='Action'},
{cost='M3D0P0',name='Oasis',type='Action'},
{cost='M3D0P0',name='Oracle',type='Action - Attack'},
{cost='M3D0P0',name='Scheme',type='Action'},
{cost='M4D0P0',name='Silk Road',type='Victory',VP=function(t)return 2*math.floor(t.victory/4)end},
{cost='M4D0P0',name='Spice Merchant',type='Action'},
{cost='M5D0P0',name='Stables',type='Action'},
{cost='M4D0P0',name='Trader',type='Action - Reaction'},
{cost='M3D0P0',name='Tunnel',type='Victory - Reaction',VP=2},
{cost='M0D0P0',name='Abandoned Mine',type='Action - Ruins'},
{cost='M0D0P0',name='Ruined Library',type='Action - Ruins'},
{cost='M0D0P0',name='Ruined Market',type='Action - Ruins'},
{cost='M0D0P0',name='Ruined Village',type='Action - Ruins'},
{cost='M0D0P0',name='Survivors',type='Action - Ruins'},
{cost='M6D0P0',name='Altar',type='Action'},--DarkAges
{cost='M4D0P0',name='Armory',type='Action'},
{cost='M5D0P0',name='Band of Misfits',type='Action - Command'},
{cost='M5D0P0',name='Bandit Camp',type='Action',depend='Spoils'},
{cost='M2D0P0',name='Beggar',type='Action - Reaction'},
{cost='M5D0P0',name='Catacombs',type='Action'},
{cost='M5D0P0',name='Count',type='Action'},
{cost='M5D0P0',name='Counterfeit',type='Treasure'},
{cost='M5D0P0',name='Cultist',type='Action - Attack - Looter'},
{cost='M4D0P0',name='Death Cart',type='Action - Looter'},
{cost='M4D0P0',name='Feodum',type='Victory',VP=function(t)return 3*math.floor((t.deck.Silver or 0)/4) end},
{cost='M3D0P0',name='Forager',type='Action'},
{cost='M4D0P0',name='Fortress',type='Action'},
{cost='M5D0P0',name='Graverobber',type='Action'},
{cost='M3D0P0',name='Hermit',type='Action',depend='Madman'},
{cost='M6D0P0',name='Hunting Grounds',type='Action'},
{cost='M4D0P0',name='Ironmonger',type='Action'},
{cost='M5D0P0',name='Junk Dealer',type='Action'},
{cost='M5D0P0',name='Knights',type='Action - Attack - Knight'},
{cost='M4D0P0',name='Marauder',type='Action - Attack - Looter',depend='Spoils'},
{cost='M3D0P0',name='Market Square',type='Action - Reaction'},
{cost='M5D0P0',name='Mystic',type='Action'},
{cost='M5D0P0',name='Pillage',type='Action - Attack',depend='Spoils'},
{cost='M1D0P0',name='Poor House',type='Action'},
{cost='M4D0P0',name='Procession',type='Action'},
{cost='M4D0P0',name='Rats',type='Action'},
{cost='M5D0P0',name='Rebuild',type='Action'},
{cost='M5D0P0',name='Rogue',type='Action - Attack'},
{cost='M3D0P0',name='Sage',type='Action'},
{cost='M4D0P0',name='Scavenger',type='Action'},
{cost='M2D0P0',name='Squire',type='Action'},
{cost='M3D0P0',name='Storeroom',type='Action'},
{cost='M3D0P0',name='Urchin',type='Action - Attack',depend='Mercenary'},
{cost='M2D0P0',name='Vagrant',type='Action'},
{cost='M4D0P0',name='Wandering Minstrel',type='Action'},
{cost='M0D0P0',name='Madman',type='Action'},
{cost='M0D0P0',name='Mercenary',type='Action - Attack'},
{cost='M0D0P0',name='Spoils',type='Treasure'},
{cost='M5D0P0',name='Dame Anna',type='Action - Attack - Knight'},
{cost='M5D0P0',name='Dame Josephine',type='Action - Attack - Knight - Victory',VP=2},
{cost='M5D0P0',name='Dame Molly',type='Action - Attack - Knight'},
{cost='M5D0P0',name='Dame Natalie',type='Action - Attack - Knight'},
{cost='M5D0P0',name='Dame Sylvia',type='Action - Attack - Knight'},
{cost='M5D0P0',name='Sir Bailey',type='Action - Attack - Knight'},
{cost='M5D0P0',name='Sir Destry',type='Action - Attack - Knight'},
{cost='M4D0P0',name='Sir Martin',type='Action - Attack - Knight'},
{cost='M5D0P0',name='Sir Michael',type='Action - Attack - Knight'},
{cost='M5D0P0',name='Sir Vander',type='Action - Attack - Knight'},
{cost='M1D0P0',name='Hovel',type='Reaction - Shelter'},
{cost='M1D0P0',name='Necropolis',type='Action - Shelter'},
{cost='M1D0P0',name='Overgrown Estate',type='Victory - Shelter'},
{cost='M4D0P0',name='Advisor',type='Action'},--Guilds
{cost='M5D0P0',name='Baker',type='Action',depend='Baker Coffers'},
{cost='M5D0P0',name='Butcher',type='Action',depend='Coffers'},
{cost='M2D0P0',name='Candlestick Maker',type='Action',depend='Coffers'},
{cost='M3D0P0',name='Doctor',type='Action'},
{cost='M4D0P0',name='Herald',type='Action'},
{cost='M5D0P0',name='Journeyman',type='Action'},
{cost='M3D0P0',name='Masterpiece',type='Treasure'},
{cost='M5D0P0',name='Merchant Guild',type='Action',depend='Coffers'},
{cost='M4D0P0',name='Plaza',type='Action',depend='Coffers'},
{cost='M5D0P0',name='Soothsayer',type='Action - Attack'},
{cost='M2D0P0',name='Stonemason',type='Action'},
{cost='M4D0P0',name='Taxman',type='Action - Attack'},
{cost='M3D0P0',name='Amulet',type='Action - Duration'},
{cost='M5D0P0',name='Artificer',type='Action'},
{cost='M5D0P0',name='Bridge Troll',type='Action - Attack - Duration',depend='MinusCoin'},
{cost='M3D0P0',name='Caravan Guard',type='Action - Duration - Reaction'},
{cost='M2D0P0',name='Coin of the Realm',type='Treasure - Reserve'},
{cost='M5D0P0',name='Distant Lands',type='Action - Reserve - Victory'},
{cost='M3D0P0',name='Dungeon',type='Action - Duration'},
{cost='M4D0P0',name='Duplicate',type='Action - Reserve'},
{cost='M3D0P0',name='Gear',type='Action - Duration'},
{cost='M5D0P0',name='Giant',type='Action - Attack',depend='Journey'},
{cost='M3D0P0',name='Guide',type='Action - Reserve'},
{cost='M5D0P0',name='Haunted Woods',type='Action - Attack - Duration'},
{cost='M6D0P0',name='Hireling',type='Action - Duration'},
{cost='M5D0P0',name='Lost City',type='Action'},
{cost='M4D0P0',name='Magpie',type='Action'},
{cost='M4D0P0',name='Messenger',type='Action'},
{cost='M4D0P0',name='Miser',type='Action',depend='Reserve'},
{cost='M2D0P0',name='Page',type='Action - Traveller'},
{cost='M2D0P0',name='Peasant',type='Action - Traveller',depend='Reserve PlusCard PlusAction PlusBuy PlusCoin'},
{cost='M4D0P0',name='Port',type='Action'},
{cost='M4D0P0',name='Ranger',type='Action',depend='Journey'},
{cost='M2D0P0',name='Ratcatcher',type='Action - Reserve'},
{cost='M2D0P0',name='Raze',type='Action'},
{cost='M5D0P0',name='Relic',type='Treasure - Attack',depend='MinusCard'},
{cost='M5D0P0',name='Royal Carriage',type='Action - Reserve'},
{cost='M5D0P0',name='Storyteller',type='Action'},
{cost='M5D0P0',name='Swamp Hag',type='Action - Attack - Duration'},
{cost='M4D0P0',name='Transmogrify',type='Action - Reserve'},
{cost='M5D0P0',name='Treasure Trove',type='Treasure'},
{cost='M5D0P0',name='Wine Merchant',type='Action - Reserve'},
{cost='M3D0P0',name='Treasure Hunter',type='Action - Traveller'},
{cost='M4D0P0',name='Warrior',type='Action - Warrior - Traveller'},
{cost='M5D0P0',name='Hero',type='Action - Traveller'},
{cost='M6D0P0',name='Champion',type='Action - Duration'},
{cost='M3D0P0',name='Soldier',type='Action - Attack - Traveller'},
{cost='M4D0P0',name='Fugitive',type='Action - Traveller'},
{cost='M5D0P0',name='Disciple',type='Action - Traveller'},
{cost='M6D0P0',name='Teacher',type='Action - Reserve'},
{cost='M0D0P0',type='Event',name='Alms'},
{cost='M5D0P0',type='Event',name='Ball',depend='MinusCoin'},
{cost='M3D0P0',type='Event',name='Bonfire'},
{cost='M0D0P0',type='Event',name='Borrow',depend='MinusCard'},
{cost='M3D0P0',type='Event',name='Expedition'},
{cost='M3D0P0',type='Event',name='Ferry',depend='TwoCost'},
{cost='M7D0P0',type='Event',name='Inheritance',depend='Estate'},
{cost='M6D0P0',type='Event',name='Lost Arts',depend='PlusAction'},
{cost='M4D0P0',type='Event',name='Mission'},
{cost='M8D0P0',type='Event',name='Pathfinding',depend='PlusCard'},
{cost='M4D0P0',type='Event',name='Pilgrimage',depend='Journey'},
{cost='M3D0P0',type='Event',name='Plan',depend='Trashing'},
{cost='M0D0P0',type='Event',name='Quest'},
{cost='M5D0P0',type='Event',name='Raid',depend='MinusCard'},
{cost='M1D0P0',type='Event',name='Save'},
{cost='M2D0P0',type='Event',name='Scouting Party'},
{cost='M5D0P0',type='Event',name='Seaway',depend='PlusBuy'},
{cost='M5D0P0',type='Event',name='Trade'},
{cost='M6D0P0',type='Event',name='Training',depend='PlusCoin'},
{cost='M2D0P0',type='Event',name='Travelling Fair'},
{cost='M5D0P0',name='Archive',type='Action - Duration'},
{cost='M5D0P0',name='Capital',type='Treasure',depend='Debt'},
{cost='M3D0P0',name='Castles',type='Victory - Castle',depend='VP'},
{cost='M3D0P0',name='Catapult / Rocks',type='Action - Attack'},
{cost='M3D0P0',name='Chariot Race',type='Action',depend='VP'},
{cost='M5D0P0',name='Charm',type='Treasure'},
{cost='D8M0P0',name='City Quarter',type='Action'},
{cost='M5D0P0',name='Crown',type='Action - Treasure'},
{cost='M2D0P0',name='Encampment / Plunder',type='Action',depend='VP'},
{cost='M3D0P0',name='Enchantress',type='Action - Attack - Duration'},
{cost='D4M0P0',name='Engineer',type='Action'},
{cost='M3D0P0',name='Farmers\' Market',type='Action - Gathering'},
{cost='M5D0P0',name='Forum',type='Action'},
{cost='M3D0P0',name='Gladiator / Fortune',type='Action'},
{cost='M5D0P0',name='Groundskeeper',type='Action',depend='VP'},
{cost='M5D0P0',name='Legionary',type='Action - Attack'},
{cost='M2D0P0',name='Patrician / Emporium',type='Action',depend='VP'},
{cost='D8M0P0',name='Royal Blacksmith',type='Action'},
{cost='D8M0P0',name='Overlord',type='Action - Command'},
{cost='M4D0P0',name='Sacrifice',type='Action',depend='VP'},
{cost='M2D0P0',name='Settlers / Bustling Village',type='Action'},
{cost='M4D0P0',name='Temple',type='Action - Gathering'},
{cost='M4D0P0',name='Villa',type='Action'},
{cost='M5D0P0',name='Wild Hunt',type='Action - Gathering'},
{cost='M3D0P0',name='Humble Castle',type='Treasure - Victory - Castle',VP=function(t)return t.castles*1 end},
{cost='M4D0P0',name='Crumbling Castle',type='Victory - Castle',VP=1,depend='VP'},
{cost='M5D0P0',name='Small Castle',type='Action - Victory - Castle',VP=2},
{cost='M6D0P0',name='Haunted Castle',type='Victory - Castle',VP=2},
{cost='M7D0P0',name='Opulent Castle',type='Action - Victory - Castle',VP=3},
{cost='M8D0P0',name='Sprawling Castle',type='Victory - Castle',VP=4},
{cost='M9D0P0',name='Grand Castle',type='Victory - Castle',VP=5,depend='VP'},
{cost='MAD0P0',name='King\'s Castle',type='Victory - Castle',VP=function(t)return t.castles*2 end},
{cost='D03MP0',name='Catapult',type='Action - Attack'},
{cost='D04MP0',name='Rocks',type='Treasure'},
{cost='M2D0P0',name='Encampment',type='Action'},
{cost='M5D0P0',name='Plunder',type='Treasure',depend='VP'},
{cost='M3D0P0',name='Gladiator',type='Action'},
{cost='D8M8P0',name='Fortune',type='Treasure'},
{cost='M2D0P0',name='Patrician',type='Action'},
{cost='M5D0P0',name='Emporium',type='Action',depend='VP'},
{cost='M2D0P0',name='Settlers',type='Action'},
{cost='M5D0P0',name='Bustling Village',type='Action'},
{cost='M0D0P0',type='Event',name='Advance'},
{cost='M0D8P0',type='Event',name='Annex'},
{cost='M3D0P0',type='Event',name='Banquet'},
{cost='M6D0P0',type='Event',name='Conquest',depend='VP'},
{cost='M2D0P0',type='Event',name='Delve'},
{cost='MED0P0',type='Event',name='Dominate',depend='VP'},
{cost='M0D8P0',type='Event',name='Donate'},
{cost='M4D0P0',type='Event',name='Ritual',depend='VP'},
{cost='M4D0P0',type='Event',name='Salt the Earth',depend='VP'},
{cost='M2D0P0',type='Event',name='Tax',depend='Debt',setup=function(o)tokenMake(o,'debt',1)end},
{cost='M0D5P0',type='Event',name='Triumph',depend='VP'},
{cost='M4D3P0',type='Event',name='Wedding',depend='VP'},
{cost='M5D0P0',type='Event',name='Windfall'},
{cost='MXDXP0',type='Landmark',name='Aqueduct',depend='VP',setup=function(o)local n=o.getName()if n=='Golds'or n=='Silvers'then tokenMake(o,'vp',8)end end},
{cost='MXDXP0',type='Landmark',name='Arena',depend='VP'},
{cost='MXDXP0',type='Landmark',name='Bandit Fort',VP=function(t)return -((t.deck.Silver or 0)+(t.deck.Gold or 0))*2 end},
{cost='MXDXP0',type='Landmark',name='Basilica',depend='VP'},
{cost='MXDXP0',type='Landmark',name='Baths',depend='VP'},
{cost='MXDXP0',type='Landmark',name='Battlefield',depend='VP'},
{cost='MXDXP0',type='Landmark',name='Colonnade',depend='VP'},
{cost='MXDXP0',type='Landmark',name='Defiled Shrine',depend='VP',setup=function(o)local t=getType(o.getObjects()[1].name);if t:find('Action')and not t:find('Gathering')then tokenMake(o,'vp',2)end end},
{cost='MXDXP0',type='Landmark',name='Fountain',VP=function(t)if t.deck.Copper>9 then return 15 end end},
{cost='MXDXP0',type='Landmark',name='Keep',VP=function(t,dT,cp)local v=0;for c,n in pairs(t.deck)do if getType(c):find('Treasure')then local w=true;for o,d in pairs(dT)do if o~=cp and d and d[c] and d[c]>n then w=false;end end end if w then v=v+5 end end end},
{cost='MXDXP0',type='Landmark',name='Labyrinth',depend='VP'},
{cost='MXDXP0',type='Landmark',name='Mountain Pass',depend='VP Debt'},
{cost='MXDXP0',type='Landmark',name='Museum',VP=function(t)return #t.deck*2 end},
{cost='MXDXP0',type='Landmark',name='Obelisk',VP=function(t)if obeliskTarget=='Knights'then return t.knights*2 elseif obeliskTarget then return(t.deck[obeliskTarget]or 0)*2 end return 0 end,setup=function(o)if getType(o.getObjects()[o.getQuantity()].name):find('Action')then table.insert(obeliskPiles,o)end end},
{cost='MXDXP0',type='Landmark',name='Orchard',VP=function(t)return t.orchard*4 end},
{cost='MXDXP0',type='Landmark',name='Palace',VP=function(t)return math.min(t.deck.Copper or 0, t.deck.Silver or 0, t.deck.Gold or 0)*3 end},
{cost='MXDXP0',type='Landmark',name='Tomb',depend='VP'},
{cost='MXDXP0',type='Landmark',name='Tower',VP=function(t)local vp,ne,zs,f=0,{},{},false;for _,g in ipairs(ref_basicSlotzs)do table.insert(zs,getObjectFromGUID(g))end table.insert(zs,getObjectFromGUID(ref.baneSlot.zone))for _,s in ipairs(ref_kingdomSlots)do table.insert(zs,getObjectFromGUID(s.zone))end for _,z in ipairs(zs)do for __,o in ipairs(z.getObjects())do if o.tag=='Card'and o.getName()~='Bane Card'then if getType(o.getName()):find('Knight')==nil then table.insert(ne,o.getName())else table.insert(ne,'Knights')end elseif o.tag=='Deck'then table.insert(ne,o.getName():sub(1,-6))end end end for c,n in pairs(t.deck)do for _,p in ipairs(ne)do if p==c then f=true;end end if getType(c):find('Knight')then for _,p in ipairs(ne)do if p=='Knights'then f=true end end end for _,bmCard in ipairs(bmDeck)do if c==bmCard then f=true end end--[[Global Blackmarket Var]]if getType(c):find('Victory')==nil and not f then vp=vp+n end end return vp end},
{cost='MXDXP0',type='Landmark',name='Triumphal Arch',VP=function(t)local h,s=0,0;for c,n in pairs(t.deck)do if getType(c):find('Action')then if n>h then s=h;h=n elseif n>s then s=n end end end return s*3 end},
{cost='MXDXP0',type='Landmark',name='Wall',VP=function(t)return -(t.amount-15)end},
{cost='MXDXP0',type='Landmark',name='Wolf Den',VP=function(t)log(t)return -t.wolf*3 end},--Nocturne
{cost='M4D0P0',name='Lucky Coin',type='Treasure - Heirloom'},
{cost='M4D0P0',name='Cursed Gold',type='Treasure - Heirloom'},
{cost='M2D0P0',name='Pasture',type='Treasure - Victory - Heirloom',VP=function(t)return t.estates*1 end},
{cost='M2D0P0',name='Pouch',type='Treasure - Heirloom'},
{cost='M2D0P0',name='Goat',type='Treasure - Heirloom'},
{cost='M0D0P0',name='Magic Lamp',type='Treasure - Heirloom'},
{cost='M0D0P0',name='Haunted Mirror',type='Treasure - Heirloom'},
{cost='M0D0P0',name='Wish',type='Action'},
{cost='M2D0P0',name='Bat',type='Night'},
{cost='M0D0P0',name='Will-o\'-Wisp',type='Action'},
{cost='M2D0P0',name='Imp',type='Action'},
{cost='M4D0P0',name='Ghost',type='Night - Duration - Spirit'},
{cost='M6D0P0',name='Raider',type='Night - Duration - Attack'},
{cost='M5D0P0',name='Werewolf',type='Action - Night - Attack - Doom'},
{cost='M5D0P0',name='Cobbler',type='Night - Duration'},
{cost='M5D0P0',name='Den of Sin',type='Night - Duration'},
{cost='M5D0P0',name='Crypt',type='Night - Duration'},
{cost='M5D0P0',name='Vampire',type='Night - Attack - Doom'},
{cost='M4D0P0',name='Exorcist',type='Night',depend='Imp Ghost'},
{cost='M4D0P0',name='Devil\'s Workshop',type='Night',depend='Imp'},
{cost='M3D0P0',name='Ghost Town',type='Night - Duration'},
{cost='M3D0P0',name='Night Watchman',type='Night'},
{cost='M3D0P0',name='Changeling',type='Night'},
{cost='M2D0P0',name='Guardian',type='Night - Duration'},
{cost='M2D0P0',name='Monastery',type='Night'},
{cost='M5D0P0',name='Idol',type='Treasure - Attack - Fate'},
{cost='M5D0P0',name='Tormentor',type='Action - Attack - Doom',depend='Imp'},
{cost='M5D0P0',name='Cursed Village',type='Action - Doom'},
{cost='M5D0P0',name='Sacred Grove',type='Action - Fate'},
{cost='M5D0P0',name='Tragic Hero',type='Action'},
{cost='M5D0P0',name='Pooka',type='Action',depend='Heirloom'},
{cost='M4D0P0',name='Cemetery',type='Victory',depend='Ghost Heirloom',VP=2},
{cost='M4D0P0',name='Skulk',type='Action - Attack - Doom'},
{cost='M4D0P0',name='Blessed Village',type='Action - Fate'},
{cost='M4D0P0',name='Bard',type='Action - Fate'},
{cost='M4D0P0',name='Necromancer',type='Action',depend='Zombie'},
{cost='M4D0P0',name='Conclave',type='Action'},
{cost='M4D0P0',name='Shepherd',type='Action',depend='Heirloom'},
{cost='M3D0P0',name='Secret Cave',type='Action - Duration',depend='Wish Heirloom'},
{cost='M3D0P0',name='Fool',type='Action - Fate',depend='Heirloom'},
{cost='M3D0P0',name='Leprechaun',type='Action - Doom',depend='Wish'},
{cost='M2D0P0',name='Faithful Hound',type='Action - Reaction'},
{cost='M2D0P0',name='Druid',type='Action - Fate'},
{cost='M2D0P0',name='Tracker',type='Action - Fate',depend='Heirloom'},
{cost='M2D0P0',name='Pixie',type='Action - Fate',depend='Heirloom'},--Renaissance
{cost='M8D0P0',name='Citadel',type='Project'},
{cost='M7D0P0',name='Canal',type='Project'},
{cost='M6D0P0',name='Innovation',type='Project'},
{cost='M6D0P0',name='Crop Rotation',type='Project'},
{cost='M6D0P0',name='Barracks',type='Project'},
{cost='M5D0P0',name='Road Network',type='Project'},
{cost='M5D0P0',name='Piazza',type='Project'},
{cost='M5D0P0',name='Guildhall',type='Project',depend='Coffers'},
{cost='M5D0P0',name='Fleet',type='Project'},
{cost='M5D0P0',name='Capitalism',type='Project'},
{cost='M5D0P0',name='Academy',type='Project',depend='Villager'},
{cost='M4D0P0',name='Sinister Plot',type='Project'},
{cost='M4D0P0',name='Silos',type='Project'},
{cost='M4D0P0',name='Fair',type='Project'},
{cost='M4D0P0',name='Exploration',type='Project',depend='Coffers Villager'},
{cost='M3D0P0',name='Star Chart',type='Project'},
{cost='M3D0P0',name='Sewers',type='Project'},
{cost='M3D0P0',name='Pageant',type='Project',depend='Coffers'},
{cost='M3D0P0',name='City Gate',type='Project'},
{cost='M3D0P0',name='Cathedral',type='Project'},
{cost='M5D0P0',name='Spices',type='Treasure',depend='Coffers'},
{cost='M5D0P0',name='Scepter',type='Treasure'},
{cost='M5D0P0',name='Villain',type='Action - Attack',depend='Coffers'},
{cost='M5D0P0',name='Old Witch',type='Action - Attack'},
{cost='M5D0P0',name='Treasurer',type='Action',depend='Artifact Key'},
{cost='M5D0P0',name='Swashbuckler',type='Action',depend='Coffers Artifact TreasureChest'},
{cost='M5D0P0',name='Seer',type='Action'},
{cost='M5D0P0',name='Sculptor',type='Action',depend='Villager'},
{cost='M5D0P0',name='Scholar',type='Action'},
{cost='M5D0P0',name='Recruiter',type='Action',depend='Villager'},
{cost='M4D0P0',name='Research',type='Action - Duration'},
{cost='M4D0P0',name='Patron',type='Action - Reaction',depend='Coffers Villager'},
{cost='M4D0P0',name='Silk Merchant',type='Action',depend='Coffers Villager'},
{cost='M4D0P0',name='Priest',type='Action'},
{cost='M4D0P0',name='Mountain Village',type='Action'},
{cost='M4D0P0',name='Inventor',type='Action'},
{cost='M4D0P0',name='Hideout',type='Action'},
{cost='M4D0P0',name='Flag Bearer',type='Action',depend='Artifact Flag'},
{cost='M3D0P0',name='Cargo Ship',type='Action - Duration'},
{cost='M3D0P0',name='Improve',type='Action'},
{cost='M3D0P0',name='Experiment',type='Action'},
{cost='M3D0P0',name='Acting Troupe',type='Action',depend='Villager'},
{cost='M2D0P0',name='Ducat',type='Treasure',depend='Coffers'},
{cost='M2D0P0',name='Lackeys',type='Action',depend='Villager'},
{cost='M2D0P0',name='Border Guard',type='Action',depend='Artifact Lantern Horn'},--MenagerieExpansion
{cost='M2D0P0',name='Black Cat',type='Action - Attack - Reaction'},
{cost='M2D0P0',name='Sleigh',type='Treasure',depend='Horse'},
{cost='M2D0P0',name='Supplies',type='Treasure',depend='Horse'},
{cost='M3D0P0',name='Camel Train',type='Action',depend='Exile'},
{cost='M3D0P0',name='Goatherd',type='Action'},
{cost='M3D0P0',name='Scrap',type='Action',depend='Horse'},
{cost='M3D0P0',name='Sheepdog',type='Action - Reaction'},
{cost='M3D0P0',name='Snowy Village',type='Action'},
{cost='M3D0P0',name='Stockpile',type='Treasure',depend='Exile'},
{cost='M4D0P0',name='Bounty Hunter',type='Action',depend='Exile'},
{cost='M4D0P0',name='Cardinal',type='Action - Attack',depend='Exile'},
{cost='M4D0P0',name='Cavalry',type='Action',depend='Horse'},
{cost='M4D0P0',name='Groom',type='Action',depend='Horse'},
{cost='M4D0P0',name='Hostelry',type='Action',depend='Horse'},
{cost='M4D0P0',name='Village Green',type='Action - Duration - Reaction'},
{cost='M5D0P0',name='Barge',type='Action - Duration'},
{cost='M5D0P0',name='Coven',type='Action - Attack',depend='Exile'},
{cost='M5D0P0',name='Displace',type='Action',depend='Exile'},
{cost='M5D0P0',name='Falconer',type='Action - Reaction'},
{cost='M5D0P0',name='Fisherman',type='Action'},
{cost='M5D0P0',name='Gatekeeper',type='Action - Duration - Attack',depend='Exile'},
{cost='M5D0P0',name='Hunting Lodge',type='Action'},
{cost='M5D0P0',name='Kiln',type='Action'},
{cost='M5D0P0',name='Livery',type='Action',depend='Horse'},
{cost='M5D0P0',name='Mastermind',type='Action - Duration'},
{cost='M5D0P0',name='Paddock',type='Action',depend='Horse'},
{cost='M5D0P0',name='Sanctuary',type='Action',depend='Exile'},
{cost='M6D0P0',name='Destrier',type='Action'},
{cost='M6D0P0',name='Wayfarer',type='Action'},
{cost='M7D0P0',name='Animal Fair',type='Action'},
{cost='M3D0P0',name='Horse',type='Action'},
{cost='M0D0P0',type='Way',name='Way of the Butterfly'},
{cost='M0D0P0',type='Way',name='Way of the Camel',depend='Exile'},
{cost='M0D0P0',type='Way',name='Way of the Chameleon'},
{cost='M0D0P0',type='Way',name='Way of the Frog'},
{cost='M0D0P0',type='Way',name='Way of the Goat'},
{cost='M0D0P0',type='Way',name='Way of the Horse'},
{cost='M0D0P0',type='Way',name='Way of the Mole'},
{cost='M0D0P0',type='Way',name='Way of the Monkey'},
{cost='M0D0P0',type='Way',name='Way of the Mouse',setup=function()end},
{cost='M0D0P0',type='Way',name='Way of the Mule'},
{cost='M0D0P0',type='Way',name='Way of the Otter'},
{cost='M0D0P0',type='Way',name='Way of the Owl'},
{cost='M0D0P0',type='Way',name='Way of the Ox'},
{cost='M0D0P0',type='Way',name='Way of the Pig'},
{cost='M0D0P0',type='Way',name='Way of the Rat'},
{cost='M0D0P0',type='Way',name='Way of the Seal'},
{cost='M0D0P0',type='Way',name='Way of the Sheep'},
{cost='M0D0P0',type='Way',name='Way of the Squirrel'},
{cost='M0D0P0',type='Way',name='Way of the Turtle',depend='Aside'},
{cost='M0D0P0',type='Way',name='Way of the Worm',depend='Exile'},
{cost='M0D0P0',type='Event',name='Delay',depend='Aside'},
{cost='M0D0P0',type='Event',name='Desperation'},
{cost='M2D0P0',type='Event',name='Gamble'},
{cost='M2D0P0',type='Event',name='Pursue'},
{cost='M2D0P0',type='Event',name='Ride',depend='Horse'},
{cost='M2D0P0',type='Event',name='Toil'},
{cost='M3D0P0',type='Event',name='Enhance'},
{cost='M3D0P0',type='Event',name='March'},
{cost='M3D0P0',type='Event',name='Transport',depend='Exile'},
{cost='M4D0P0',type='Event',name='Banish',depend='Exile'},
{cost='M4D0P0',type='Event',name='Bargain',depend='Horse'},
{cost='M4D0P0',type='Event',name='Invest',depend='Exile'},
{cost='M4D0P0',type='Event',name='Seize the Day',depend='Project'},
{cost='M5D0P0',type='Event',name='Commerce'},
{cost='M5D0P0',type='Event',name='Demand',depend='Horse'},
{cost='M5D0P0',type='Event',name='Stampede',depend='Horse'},
{cost='M7D0P0',type='Event',name='Reap'},
{cost='M8D0P0',type='Event',name='Enclave',depend='Exile'},
{cost='M10D0P0',type='Event',name='Alliance'},
{cost='M10D0P0',type='Event',name='Populate'},--PromoSummonFirstPrintings
{cost='M3D0P0',name='Black Market',type='Action'},
{cost='M3D0P0',name='Church',type='Action - Duration'},
{cost='M4D0P0',name='Envoy',type='Action'},
{cost='M4D0P0',name='Dismantle',type='Action'},
{cost='M4D0P0',name='Walled Village',type='Action'},
{cost='M4D0P0',name='Sauna / Avanto',type='Action'},
{cost='M4D0P0',name='Sauna',type='Action'},
{cost='M5D0P0',name='Avanto',type='Action'},
{cost='M5D0P0',name='Governor',type='Action'},
{cost='M5D0P0',name='Stash',type='Treasure'},
{cost='M6D0P0',name='Captain',type='Action - Duration - Command'},
{cost='M8D0P0',name='Prince',type='Action',depend='Aside'},
{cost='M5D0P0',name='Summon',type='Event',depend='Aside'},
{cost='M6D0P0',name='Adventurer',type='Action'},
{cost='M3D0P0',name='Chancellor',type='Action'},
{cost='M4D0P0',name='Feast',type='Action'},
{cost='M4D0P0',name='Spy',type='Action - Attack'},
{cost='M4D0P0',name='Thief',type='Action - Attack'},
{cost='M3D0P0',name='Woodcutter',type='Action'},
{cost='M4D0P0',name='Coppersmith',type='Action'},
{cost='M3D0P0',name='Great Hall',type='Action - Victory',VP=1},
{cost='M5D0P0',name='Saboteur',type='Action - Attack'},
{cost='M4D0P0',name='Scout',type='Action'},
{cost='M2D0P0',name='Secret Chamber',type='Action - Reaction'},
{cost='M5D0P0',name='Tribute',type='Action'},
{cost='M5D0P0',name='Original Band of Misfits',type='Action'},
{cost='D8M0P0',name='Original Overlord',type='Action'},
{cost='M6D0P0',name='Original Captain',type='Action - Duration'},
--X'tra's
{cost='MXDXP0',type='Landmark',name='El Dorado',depend='Artifact'},
{cost='M2D0P0',name='Handler',type='Action'},
{cost='M2D0P0',name='Hops',type='Treasure - Duration'},
{cost='M2D0P0',name='Smithing Tools',type='Action - Duration'},
{cost='M2D0P0',name='Stallions',type='Action - Stallion',depend='Horse'},
{cost='M2D0P1',name='Wat',type='Treasure - Victory',VP=1},
{cost='M3D0P0',name='Informer',type='Action - Command'},
{cost='M3D0P0',name='Notary',type='Action',depend='Heir'},
{cost='M4D0P0',name='Lease',type='Action'},
{cost='M4D0P0',name='Lessor',type='Action - Attack',depend='BogusLands'},
{cost='M4D0P0',name='Statue',type='Action - Victory',depend='Aside'},
{cost='M4D0P0',name='Vigil',type='Action - Attack'},
{cost='M4D0P0',name='Watchmaker',type='Action - Reserve'},
{cost='M5D0P0',name='Plague Doctor',type='Action - Attack - Duration'},
{cost='M5D0P0',name='Savings',type='Treasure'},
{cost='M5D0P0',name='Tithe',type='Action - Attack - Reserve - Duration',depend='Debt'},
{cost='M6D0P0',name='Grand Laboratory',type='Action'},
{cost='M2D0P0',name='Shetland Pony',type='Action - Stallion'},
{cost='M3D0P0',name='Clydesdale',type='Action - Stallion'},
{cost='M4D0P0',name='Appaloosa',type='Action - Stallion'},
{cost='M5D0P0',name='Paint Horse',type='Action - Stallion'},
{cost='M6D0P0',name='Gypsy Vanner',type='Action - Stallion'},
{cost='M7D0P0',name='Mustang',type='Action - Victory - Stallion',VP=2},
{cost='M8D0P0',name='Friesian',type='Action - Victory - Stallion',VP=3},
{cost='M9D0P0',name='Arabian Horse',type='Victory - Stallion',VP=function(t)if t.deck['Arabian Horse']==1 then return t.deck.Horse or 0 else return 0 end end},
--Legacy
{cost='M1D0P0',name='Alley',type='Action'},
{cost='M2D0P0',name='Decree',type='Treasure'},
{cost='M2D0P0',name='Headhunter',type='Action - Fame'},
{cost='M2D0P0',name='Sunken City',type='Action - Duration'},
{cost='M3D0P0',name='Nun',type='Action'},
{cost='M3D0P0',name='Sawmill',type='Action'},
{cost='M3D0P0',name='Shrine',type='Action'},
{cost='M3D0P0',name='Well',type='Action'},
{cost='M4D0P0',name='Curiosity Shop',type='Action - Fame'},
{cost='M4D0P0',name='Docks',type='Action - Duration'},
{cost='M4D0P0',name='Farmer',type='Action'},
{cost='M4D0P0',name='Gallows',type='Action'},
{cost='M4D0P0',name='Heir Legacy',type='Action'},
{cost='M4D0P0',name='Imposter',type='Action - Fame'},
{cost='M4D0P0',name='Landlord',type='Action'},
{cost='M5D0P0',name='Adventure-Seeker',type='Action - Fame'},
{cost='M5D0P0',name='Assemble',type='Action'},
{cost='M5D0P0',name='Cliffside Village',type='Action'},
{cost='M5D0P0',name='Craftsmen',type='Action'},
{cost='M5D0P0',name='Inquisitor',type='Action - Attack - Fame'},
{cost='M5D0P0',name='Lycantrope',type='Action - Attack'},
{cost='M5D0P0',name='Maze',type='Action - Victory - Attack'},
{cost='M5D0P0',name='Sultan',type='Action'},
{cost='M5D0P0',name='Tribunal',type='Action - Attack'},
{cost='M6D0P0',name='Hall of Fame',type='Victory - Fame'},
{cost='M6D0P0',name='Meadow',type='Victory',VP=2},
--LegacyExpert
{cost='MD0P0',name='',type=''},
{cost='MD0P0',name='',type=''},
{cost='MD0P0',name='',type=''},
{cost='M0D0P1',name='Homunculus',type='Action'},
{cost='M0D8P0',name='Promenade',type='Action'},
{cost='M0D8P0',name='Institute',type='Action'},
{cost='M2D0P0',name='Sheriff',type='Action - Attack'},
{cost='M2D0P0',name='Swamp',type='Action',depend='Imp Ghost'},
{cost='M3D0P0',name='Iron Maiden',type='Action - Attack - Looter'},
{cost='M3D0P1',name='Incantation',type='Action'},
{cost='M3D0P0',name='Pilgrim',type='Action',depend='Coffers'},
{cost='M3D0P0',name='Scientist',type='Action'},
{cost='M4D0P0',name='Hunter',type='Action - Reserve'},
{cost='M4D0P0',name='Lady-in-waiting',type='Action - Reserve'},
{cost='M4D0P0',name='Scribe',type='Action - Attack - Duration',depend='Debt'},
{cost='M4D0P0',name='Town',type='Action',depend='Road'},
{cost='M4D0P0',name='Waggon Village',type='Action',depend='Debt'},
{cost='M5D0P0',name='Delegate',type='Action',depend='LoyalSubjects'},
{cost='M5D0P0',name='Lich',type='Action',depend='Zombie'},
{cost='M5D0P0',name='Necromancer Legacy',type='Action',depend='ZombieLegacy'},
{cost='M5D0P0',name='Sanctuary',type='Action'},
{cost='M6D0P0',name='Minister',type='Action',depend='VP'},
{cost='M0D0P0',name='Road',type='Action'},
{cost='M3D0P0',name='Skeleton',type='Action - Attack'},
{cost='M3D0P0',name='Zombie Legacy',type='Action - Attack'},
{cost='M3D0P0',name='Loyal Subjects',type='Action - Attack'},
--Spellcasters
{cost='M2D0P0',name='Trickster',type='Action - Spellcaster'},
{cost='M3D0P0',name='Stone Circle',type='Victory - Spellcaster',VP=2},
{cost='M3D0P0',name='Magician',type='Action - Spellcaster'},
{cost='M3D0P0',name='Shaman',type='Action - Spellcaster'},
{cost='M4D0P0',name='Summoner',type='Action - Spellcaster'},
{cost='M4D0P0',name='Grimoire',type='Treasure - Spellcaster'},
{cost='M5D0P0',name='Sorcerer',type='Action - Spellcaster'},
{cost='M5D0P0',name='Wizard',type='Action - Spellcaster'},
--Seasons
{cost='M2D0P0',name='Sojourner',type='Action - Season'},
{cost='M3D0P0',name='Bailiff',type='Action - Season'},
{cost='M3D0P0',name='Snow Witch',type='Action - Attack - Season'},
{cost='M3D0P0',name='Student',type='Action - Season',depend='Following'},
{cost='M4D0P0',name='Barbarian',type='Action - Season'},
{cost='M4D0P0',name='Lumbermen',type='Action - Season'},
{cost='M4D0P0',name='Peltmonger',type='Action - Season'},
{cost='M4D0P0',name='Sanitarium',type='Action - Season'},
{cost='M4D0P0',name='Timberland',type='Victory - Season',depend='VP',VP=2},
{cost='M5D0P0',name='Ballroom',type='Action - Season'},
{cost='M5D0P0',name='Cottage',type='Action - Season'},
{cost='M5D0P0',name='Fjord Village',type='Action - Season'},
{cost='M5D0P0',name='Plantation',type='Action - Season'},
{cost='M5D0P0',name='Restore',type='Action - Season'},
--LegacyTeams
{cost='M2D0P0',name='Steeple',type='Action - Team'},
{cost='M3D0P0',name='Conman',type='Action - Team'},
{cost='M3D0P0',name='Fisher',type='Action - Reaction - Team'},
{cost='M4D0P0',name='Merchant Quarter',type='Action - Team'},
{cost='M4D0P0',name='Study',type='Action - Team'},
{cost='M4D0P0',name='Still Village',type='Action - Duration - Team'},
{cost='M5D0P0',name='Salesman',type='Action - Team'},
{cost='M5D0P0',name='Sponsor',type='Action - Team'},
--Adamabrams
{cost='M6D0P0',name='Mortgage',type='Project',depend='Debt'},
{cost='M0D0P0',name='Lost Battle',type='Landmark',depend='VP'},
{cost='M4D0P0',name='Cave',type='Night - Victory',VP=2},
{cost='M4D0P0',name='Chisel',type='Action - Reserve'},
{cost='M7D0P0',name='Knockout',type='Event',depend='Artifact'},
{cost='M1D0P1',name='Migrant Village',type='Action',depend='Villager'},
{cost='M4D0P0',name='Discretion',type='Action - Reserve',depend='VP Coffers Villager'},
{cost='M4D0P0',name='Plot',type='Night',depend='VP'},
{cost='M4D0P0',name='Investor',type='Action',depend='Debt'},
{cost='M6D0P0',name='Contest',type='Action - Looter'},
{cost='M6D0P0',name='Uneven Road',type='Action - Victory',depend='Estate',VP=3},
{cost='M3D0P1',name='Jekyll',type='Action',depend='Hyde'},
{cost='M4D0P1',name='Hyde',type='Night - Attack'},
{cost='M5D0P0',name='Stormy Seas',type='Night',depend='Debt'},
{cost='M0D4P0',name='Liquid Luck',type='Action - Fate'},
{cost='M6D0P0',name='Cheque',type='Treasure - Command'},
{cost='M2D0P0',name='Balance',type='Action - Reserve - Fate - Doom'},
{cost='M0D0P0',name='Rabbit',type='Action - Treasure'},
{cost='M5D0P0',name='Magician',type='Action',depend='Rabbit'},
{cost='M4D0P0',name='Fishing Boat',type='Action - Duration'},
{cost='M3D0P0',name='Drawbridge',type='Action - Reserve'},
{cost='M4D0P0',name='Jinxed Jewel',type='Treasure - Night - Heirloom'},
{cost='M0D0P0',name='-1 Card Token',type=''}
}