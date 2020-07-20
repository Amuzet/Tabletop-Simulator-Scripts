--DominionDefinitiveEditionModifiedByAmuzet2020_07_19_H
VERSION,GITURL=2.1,'https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Dominion/Definitive.lua'
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
    bmd=bmDeck,
    sl=sL.n})
    return saved_data
end
--Runs when the map is first loaded
function onLoad(saved_data)
  WebRequest.get(GITURL,function(wr)
        local v=wr.text:match('VERSION,GITURL=(%d+%p%d+)')
        if v then v=tonumber(v)
          if v<VERSION then     broadcastToAll('Oh look at you with a Testing Version\nPlease Report any bugs to Amuzet.',{0,1,1})
          elseif v>VERSION then broadcastToAll('There is an UPDATE!\nCan be found in TTSClub.',{1,1,0})
          else                  broadcastToAll('Up to Date!\nHave a nice time playing.',{0,1,0})end
        else broadcastToAll('Problems have occured! Attempt to contact Amuzet on TTSClub',{1,0,0.2})end end)
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
      sL.n=loaded_data.sl or 3
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
    for k,r in pairs(ref_basicSlots)do local p=getObjectFromGUID(r.guid).getPosition();ref_basicSlots[k].pos={p[1],1.3,p[3]}end
    for k,r in pairs(ref_kingdomSlots)do local p=getObjectFromGUID(r.guid).getPosition();ref_kingdomSlots[k].pos={p[1],1.3,p[3]}end
    setUninteractible(ref)
    for _,o in pairs(getAllObjects())do if o.getLock()and (o.getName()==''or o.getName()=='Board')then o.interactable=false end end
    math.randomseed(os.time())
    
    for k,p in pairs(ref_players)do
      for _,o in pairs(getObjectFromGUID(p.zone).getObjects())do
        if o.getName()=='Victory Points'then
          ref_players[k].vp=o.getGUID()
        elseif o.getName()=='Debt Tokens'then
          ref_players[k].debt=o.getGUID()
        elseif o.getName()=='Coffers'then
          ref_players[k].coin=o.getGUID()
    end end end
    
    if gameState==1 then
      for _,o in pairs(getObjectFromGUID(ref_storageZone.script).getObjects())do
        if o.tag=='Deck'then local n=o.getName()
          for i,c in pairs(ref_sidePiles)do if n==c.name then ref_sidePiles[i].guid=o.getGUID()break elseif i==#ref_sidePiles then o.highlightOn({1,0,0.5})end end end end
      for _,o in pairs(getObjectFromGUID(ref_storageZone.script).getObjects())do
        if o.tag=='Deck'then local n=o.getName()
          for i,c in pairs(ref_cardSets)do if n==c.name then ref_cardSets[i].guid=o.getGUID();o.highlightOff()break end end end end
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
      local B={label='',click_function='click_selectDeck',function_owner=Global,position={0,0.4,0.6},rotation={0,0,0},scale={0.5,1,0.5},height=600,width=2000,font_size=250,color={0,0,0},font_color={1,1,1}}
      for i in ipairs(ref_cardSets)do
        local obj=getObjectFromGUID(ref_cardSets[i].guid)
        if obj then
          B.label='Select\n'..obj.getName()
          obj.createButton(B)
          for j, guid in ipairs(useSets)do
            local obj2=getObjectFromGUID(guid)
            if obj==obj2 then
              obj.highlightOn({0,1,0})
              break end end end end
      B.click_function='click_forcePile'
      for k,v in pairs({1,5})do
        local obj=getObjectFromGUID(ref_supplyPiles[v].guid)
        if obj then
          B.label='Force\n'..obj.getName()
          obj.createButton(B)
          local bool=0
          if B.label:find('Platinum')then bool=usePlatinum
          elseif B.label:find('Shelter')then bool=useShelters
          elseif B.label:find('Boulder Trap')then bool=useBoulderTrap end
          if bool==1 then obj.higlightOn({0,1,0})
          elseif bool==2 then obj.higlightOn({1,0,0})end
          end end
      local startB=getObjectFromGUID(ref.startButton)
      if startB then
        local btn=setmetatable({d=-3,function_owner=Global,position={-24,0,-8},rotation={0,180,0},scale={0.7,0.7,0.7},height=2000,width=5750,font_size=5000},{__call=function(b,l,t,p,f)
          b.position,b.label,b.tooltip=p or {b.position[1],b.position[2],b.position[3]-b.d},l,t or'';if f then b.click_function=f else b.click_function='click_' .. l:gsub('[^\n]+\n',''):gsub('%s','')end startB.createButton(b)end})
        btn('Selected Sets\nStart Game','Random Kingdom from selected sets and cards',{8.5,0,8.5})
        btn('Quick Setup\nTwo Sets','Random Kingdom from any two sets',{0,0,-48})
        btn('Quick Setup\nThree Sets','Random Kingdom from any three sets')
        btn('Quick Setup\nAll Sets','Random Kingdom from every set')
        btn('Balanced Setup\nDual Sets','Random Kingdom made with 5 cards of one set and 5 from another')
        btn('Black Market\nLimit: '..blackMarketMax,'The Number of cards in the Black Market',{-22.5,0,2},'click_blackMarketLimit')
        btn('Max Events: '..eventMax,'The Maximum number of noncards in Kingdom',nil,'click_eventLimit')
        btn('Included Sets:\n'..sL[sL.n-1],'Toggles sets which sets are allowed in Quick Setup.\nCurrently only official sets are allowed.\nThis excludes first printings and promos.',nil,'click_setLimit')
        btn('Tutorial\nBasic Game','Set Kingdom with only actions and up to two attacks')
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
    obj.createButton({label='End Game',click_function='click_endGame',function_owner=Global,position={0,0,3},rotation={0,180,0},height=1500,width=4000,font_size=9000})
end end
function click_endGame(obj, color)
  if not Player[color].admin then
    bcast('Only the host and promoted players can end the game.', {0.75,0.75,0.75}, color)
  return end
  setNotes('[40e0d0][b][u]Final Scores:[/b][/u][FFFFFF]\n')
  dT={Red={},White={},Orange={},Green={},Yellow={},Blue={}}
  vP={Red={},White={},Orange={},Green={},Yellow={},Blue={}}
  function scoreCoroutine()
    wait(2,'cegscClean')
    for i=1,#getSeatedPlayers()do
      local currentPlayer=getSeatedPlayers()[i]
      local move=function(zone)
        for _,obj in ipairs(zone)do
          if obj.tag=='Card'and obj.getName()=='Miserable / Twice Miserable'then
            vP[currentPlayer]=vP[currentPlayer]-2
            local rot=obj.getRotation()
            if 90<rot.z and rot.z<270 then
              vP[currentPlayer]=vP[currentPlayer]-2
              bcast(currentPlayer..' is Twice Miserable',{1,0,1})
            else bcast(currentPlayer..' is Miserable',{1,0,1})end end
          if obj.tag=='Card'or obj.tag=='Deck'then
            local t=getType(obj.getName())
            if t and t~='Boon'and t~='Hex'and t~='Artifact'and t~='State'then
              obj.setRotation({0,180,180})
              obj.setPosition(ref_players[currentPlayer].deck)
              coroutine.yield(0)end end end end
      local gObjs=function(s)return getObjectFromGUID(ref_players[currentPlayer][s]).getObjects()end
      if Player[currentPlayer].getHandCount()>0 then
        vP[currentPlayer],dT[currentPlayer]=0,{}
        
        for i, obj in ipairs(gObjs('tavern'))do
          if obj.tag=='Deck'then
            for j, card in ipairs(obj.getObjects())do
              if card.nickname=='Distant Lands'then
                vP[currentPlayer]=vP[currentPlayer]+4
          end end end
          if obj.tag=='Card'then
            if obj.getName()=='Distant Lands'then
              vP[currentPlayer]=vP[currentPlayer]+4
          end end
          if obj.tag=='Card'or obj.tag=='Deck'then
            local t=getType(obj.getName())
            if t and t=='Boon'or t=='Hex'or t=='Artifact'or t=='State'then else
              obj.setRotation({0,180,180})
              obj.setPosition(ref_players[currentPlayer].deck)
              coroutine.yield(0)
        end end end
        move(gObjs('deckZone'))
        move(Player[currentPlayer].getHandObjects())
        move(gObjs('discardZone'))
        move(gObjs('zone'))
    end end
    wait(2,'cegscScore')
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
          deck={}}
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
        for i,v in pairs(tracker.deck)do
          tracker.amount=tracker.amount + v
          if getType(i):find('Action')then
            tracker.actions=tracker.actions + v
            if v>2 then
              tracker.orchard=tracker.orchard + 1
          end end
          if getType(i):find('Victory')then
            tracker.victory=tracker.victory + v end
          if getType(i):find('Castle')then
            tracker.castles=tracker.castles + 1 end
          if getType(i):find('Knight')then
            tracker.knights=tracker.knights + v end
          if v==1 then
            tracker.uniques=tracker.uniques + 1 end
        end
        -- Score Based on thier VP
        for k,v in pairs(tracker.deck)do
          local vp=getVP(k)
          if type(vp)~='number'then vp=vp(tracker)end
          if vp>0 then
            if tracker.deck.Pyramid and getType(k):find('Victory')then
              vp=vp-tracker.deck.Pyramid
              if vp<0 then vp=0 end
            end
            vP[cp]=vP[cp] + vp*v
        end end
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
function rcs(a)return math.random(1,#ref_cardSets-(a or sL.n))end
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
  for _,t in pairs({'Looter','Reserve','Doom','Fate','Project','Gathering','Fame','Season'})do if getType(c):find(t)then s=s..t..' 'end end
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
  b.editButton({index=0,label=l..'[009911]Start Game[-]',height=790*(#useSets+2)+100})
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
    wait(2,'cdsdsc')
    for i,v in pairs(ref_kingdomSlots)do getObjectFromGUID(useSets[(i%2)+1]).takeObject({position=v.pos,index=6-math.ceil(i/2),smooth=false})end
    for i,v in pairs(eventPiles)do getObjectFromGUID(v).takeObject({position=ref_eventSlots[i].pos,index=2,smooth=false})end
    click_StartGame(obj, color)
  end
  startLuaCoroutine(Global,'DualSetsCoroutine')
end
function click_BasicGame(obj, color)
  bcast('Beginner Tutorial')
  newText({20,1,50},'THE GAME ENDS WHEN:\nAny 3 piles are empty or\nThe Province pile is empty.')
  newText({0,1,11},'On your turn you may play One ACTION.\nOnce you have finished playing actions you may play TREASURES.\nThen you may Buy One Card. ([i]Cards you play can change all these[/i])',100)
  local knd={
'Cellar,Festival,Mine,Moat,Patrol,Poacher,Smithy,Village,Witch,Workshop',
'Cellar,Market,Merchant,Militia,Mine,Moat,Remodel,Smithy,Village,Workshop',}
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
end

function click_forcePile(obj, color)
  local guid,c=obj.getGUID(),{1,1,1}
  if guid==ref_supplyPiles[1].guid then
    if usePlatinum<2 then
      usePlatinum=1+usePlatinum
      if usePlatinum==1 then c={0,1,0}else c={1,0,0}end
      obj.highlightOn(c)
    else
      usePlatinum=0
      obj.highlightOff()
    end
  elseif guid==ref_supplyPiles[5].guid then
    if useShelters<2 then
      useShelters=1+useShelters
      if useShelters==1 then c={0,1,0}else c={1,0,0}end
      obj.highlightOn(c)
    else
      useShelters=0
      obj.highlightOff()
    end
  elseif guid==ref_supplyPiles[6].guid then
    if useBoulderTrap<2 then
      useBoulderTrap=1+useBoulderTrap
      if useBoulderTrap==1 then c={0,1,0}else c={1,0,0}end
      obj.highlightOn(c)
    else
      useBoulderTrap=0
      obj.highlightOff()
    end
  end
  obj.editButton({font_color=c})
end
sL={n=3,
'Official Sets','Currently only official sets are allowed.\nThis excludes first printings, promos and fan expansions.',12,
'Printed Cards','Currently only printed cards are allowed.\nThis excludes fan expansions.',13,
'Expansions','Currently only expansions are allowed.\nThis excludes first printings, promos, Adamabrams and Xtras.',18,
'Everyting','Currently cards from any set are allowed.\nThis excludes nothing.',0}
function click_setLimit(obj)
  if sL.n<#sL then sL.n=sL.n+3 else sL.n=3 end
  obj.editButton{index=getButton(obj,'Included Sets:'),label='Included Sets:\n'..sL[sL.n-2],tooltip='Toggles which sets are allowed in Quick Setup.\n'..sL[sL.n-1]}
  if sL.n==3 then
    
  elseif sL.n==6 then
    table.insert(ref_cardSets,15,ref_cardSets[22])
    table.remove(ref_cardSets,23)
  elseif sL.n==9 then
  elseif sL.n==12 then
  end
end
function click_eventLimit(obj)
  if eventMax<4 then eventMax=eventMax+1 else eventMax=0 end
  obj.editButton{index=getButton(obj,'Max Events: '),label='Max Events: '..eventMax}end
function click_blackMarketLimit(obj,_,a)
  if a and blackMarketMax>19 then blackMarketMax=blackMarketMax-5
  elseif a then blackMarketMax=60
  elseif blackMarketMax<60 then blackMarketMax=blackMarketMax+5
  else blackMarketMax=10 end
  obj.editButton{index=getButton(obj,'Black Market'),label='Black Market\nLimit: '..blackMarketMax}end
--function called when you click to start the game
function click_StartGame(obj, color)
  if not Player[color].admin then
    bcast('Only the host and promoted players can start the game.',{0.75,0.75,0.75},color)return end
  Turns.enable=false
  if getPlayerCount()>6 then
    bcast('This game needs 2 to 6 players to start.',{0.75,0.75,0.75},color)return end
  local summonException=false
  for _,es in pairs(ref_eventSlots)do
    for _,v in pairs(getObjectFromGUID(es.zone).getObjects())do
      if v.getName()=='Summon'then
        summonException=true
        break end end end
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
                bcast('Bane card needs to cost 2 or 3 with no debt or potions.',{0.75,0.75,0.75},color)
                return
              else
                requireBane=false
                break end end end end
        if zoneObj.getName()=='Black Market'then requireBlackMarket=true end
        cardCount=cardCount+1
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
  obj=getObjectFromGUID(ref_supplyPiles[1].guid)
  if obj then obj.clearButtons()end
  obj=getObjectFromGUID(ref_supplyPiles[5].guid)
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
    wait(1,'skskcStart')
    group(getObjectFromGUID(ref.randomizer.zone).getObjects())
    wait(1,'skskcGroup')
    local deck=false
    for i, v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do if v.tag=='Deck'then deck=v end end
    if deck then
      deck.setScale({1.88,1,1.88})
      deck.setRotation({0,180,180})
      deck.shuffle()
      deck.highlightOff()
    end
    wait(1,'skskcDeck')
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
                local tp=getType(v.name) if tp=='Event'or tp=='Landmark'or tp=='Project'or tp=='Way'or tp=='Edict'or tp=='Spell'then
                  if eventCount < eventMax then
                    --local tp=getType(v.name) if tp=='Way'then if w==1 then break end w=w+1 end
                    eventCount=eventCount + 1
                    deck.takeObject({position=ref_eventSlots[eventCount].pos, index=v.index, callback='setCallback', callback_owner=Global})
                    break end
                else
                  card=true
                  deck.takeObject({position=ks.pos, index=v.index, flip=true})
                  break end end end end
        wait(0.5,'skskcKingdom')
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
                    local tp=getType(v.name) if tp=='Event'or tp=='Landmark'or tp=='Project'or tp=='Way'or tp=='Edict'or tp=='Spell'then
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
            wait(2,'skskcMarket')
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
                    local tp=getType(card.name) if tp=='Event'or tp=='Landmark'or tp=='Project'or tp=='Way'or tp=='Edict'or tp=='Spell'then
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
                    local tp=getType(v.name) if tp=='Event'or tp=='Landmark'or tp=='Project'or tp=='Way'or tp=='Edict'or tp=='Spell'then
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
                    elseif v.nickname=='Stallions'then
                        coroutine.yield(0)
                        getPile('Stallions pile').shuffle()
                        getPile('Stallions pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break
                    elseif v.nickname=='Panda / Gardener'then
                        coroutine.yield(0)
                        getPile('Panda / Gardener pile').shuffle()
                        getPile('Panda / Gardener pile').takeObject({index=1, position=deckAddPos, flip=true})
                        deck.takeObject({index=v.index}).destruct()
                        cleanDeck=false
                        break end end end
        wait(2,'skskcMarket')
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
    wait(1,'skskcReorder')
    reorderKingdom()
    wait(0.5,'skskcPiles')
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
    usePlatinum=0
    getPile('Platinums').destruct()
    getPile('Colonies').destruct()
    getPile('Boulder Trap pile').setPosition(ref_basicSlots[5].pos)
    getPile('Ruins pile').setPosition(ref_basicSlots[11].pos)
    getObjectFromGUID(ref_basicSlots[6].guid).destruct()
    getObjectFromGUID(ref_basicSlots[12].guid).destruct()
  else getPile('Platinums').highlightOff()end
  
  local n=5+usePlatinum
  if not Use('Looter')then getPile('Ruins pile').destruct()
    getObjectFromGUID(ref_basicSlots[n].guid).destruct()n=n+6
    getPile('Boulder Trap pile').setPosition(ref_basicSlots[n].pos)end
  if not Use('BoulderTrap')then getPile('Boulder Trap pile').destruct()
    getObjectFromGUID(ref_basicSlots[n].guid).destruct()end
  if not Use('Potion')then getPile('Potions').destruct()
    getObjectFromGUID(ref_basicSlots[1].guid).destruct()
    getPile('Curses').setPosition(ref_basicSlots[7].pos)end
  
  if Use('Baker')then for i,obj in ipairs(getAllObjects())do if obj.getName()=='Coffers'then obj.call('baker')end end end
  if not Use('TradeRoute')then getObjectFromGUID(ref.tradeRoute.guid).destruct()end
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
  f(Use('Lessor'),'Bogus Lands')
  f(Use('Town'),'Road')
  f(Use('NecromancerLegacy'),'Zombie Legacy')
  f(Use('Delegate'),'Loyal Subjects')
  
  local dC=1
  if Use('Druid')then dC=4 end
  
  for i,v in ipairs(sideSlots)do getPile(v..' pile').setPosition(ref_sideSlots[i].pos)end
  for i=#sideSlots+dC,#ref_sideSlots do getObjectFromGUID(ref_sideSlots[i].guid).destruct()end
  for _,o in ipairs(getObjectFromGUID(ref_storageZone.script).getObjects())do if o.shuffle()then o.setLock(false)end end
  
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
'Journey',      'Coffers',      'VP',                'Debt',          'Villager',    'Fame','Spellcaster','Season'},{
'Tavern Mat',   'Exile Mat',    'Native Village Mat','Island Mat',    'Owns Project','Pirate Ship Coins',
'Set Aside',    '+1 Card Token','+1 Action Token',   '-2 Cost Token', '+1 Buy Token','Trade Route Mat',
'+1 Coin Token','-1 Coin Token','-1 Card Token',     'Trashing Token','Estate Token','Black Market Mat',
'Journey Token','Coffers',      'Victory Points',    'Debt Tokens',   'Villagers',   'Feat Mat','Spell Tokens','Season Mat'}
  for i,v in ipairs(temp)do if not Use(v)then for _,obj in pairs(getAllObjects())do if obj.getName()==names[i]or obj.getName()=='Rules '..names[i]then obj.destruct()end end end end
  getObjectFromGUID(ref.board).destruct()
  local toRemove={}
  if getPlayerCount()~=6 then
    for i in pairs(ref_players)do
      local found=false
      for j=1,#getSeatedPlayers()do
        local currentPlayer=getSeatedPlayers()[j]
        if currentPlayer==i and Player[currentPlayer].getHandCount()>0 then
          found=true
      end end
      if not found then
        table.insert(toRemove,i)
  end end end
  for i,v in pairs(toRemove)do for j,o in ipairs(getObjectFromGUID(ref_players[v].zone).getObjects())do if o.getName()~='Board'then o.destruct()end end end
  function tokenCoroutine()
    wait(4,'cutcSetup')
    log(Use[1])
    if Use('Landmark')or Use('Gathering')or Use('TradeRoute')or Use('Tax')or Use('Panda / Gardener')then
      obeliskPiles={}
      local function slot(z)
        for __,obj in ipairs(getObjectFromGUID(z).getObjects())do
          if obj.tag=='Deck'then
            getSetup('Tax')(obj)
            getSetup('Obelisk')(obj)
            getSetup('Aqueduct')(obj)
            getSetup('Trade Route')(obj)
            getSetup('Defiled Shrine')(obj)
            getSetup('Panda / Gardener')(obj)
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
    wait(1,'cutcDelete')
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
  for n,h in pairs({['Secret Cave']='Magic Lamp',['Cemetery']='Haunted Mirror',['Shepherd']='Pasture',['Tracker']='Pouch',['Pooka']='Cursed Gold',['Pixie']='Goat',['Fool']='Lucky Coin',['Magician']='Rabbit',['Jinxed Jewel']='Jinxed Jewel',['Burned Village']='Rescuers'})do
    if c==n then getPile('Heirlooms').takeObject({position=getObjectFromGUID(ref_storageZone.heirloom).getPosition(),guid=ref_heirlooms[h],flip=true})break end end end
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
        elseif v.getName()=='Dig'then
          local n=12
          if getPlayerCount()==2 then n=8 end
          while k<n do v.clone({position=ks.pos})k=k+1 end
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
        elseif v.getName()=='Stallions'then
          v.destruct()getPile('Stallions pile').setPosition(ks.pos)
        elseif v.getName()=='Panda / Gardener'then
          v.destruct()getPile('Panda / Gardener pile').setPosition(ks.pos)
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
      elseif v.getName()=='Stallions'then
        v.destruct()getPile('Stallions pile').setPosition(ref.baneSlot.pos)
      elseif v.getName()=='Panda / Gardener'then
        v.destruct()getPile('Panda / Gardener pile').setPosition(ks.pos)
      --All other cards get 10 copies
      else while k<10 do v.clone({position=ref.baneSlot.pos})k=k+1
  end end end end
  --Coroutine names the piles after they form
  function createPileCoroutine()wait(2,'cpcNames')
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
  for _,p in pairs(ref_supplyPiles)do if pileName==p.name then return getObjectFromGUID(p.guid)end end
  for _,p in pairs(ref_sidePiles)do if pileName==p.name then return getObjectFromGUID(p.guid)end end
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
  --if Use('Delegate')then getPile('Loyal Subjects pile').takeObject()
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
    wait(2,'dshcShuffle')
    for i, v in pairs(ref_players)do
      for j, b in pairs(getObjectFromGUID(v.deckZone).getObjects())do
        if b.tag=='Deck'then
          b.shuffle()
        end
      end
    end
    wait(0.5,'dshcDeal')
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
function wait(time,key)local start=os.time()print(key or'Unknown')repeat coroutine.yield(0)until os.time()>start+time end
--Shortcut broadcast function to shorten them when I call them in the code
function bcast(m,c,p)if c==nil then c={1,1,1}end if p then Player[p].broadcast(m,c)else broadcastToAll(m,c)end end
function tokenCallback(obj,m)obj.call('setOwner',m)end
function tokenMake(obj,key,n,pos,name)
  local p=obj.getPosition()
  if pos then p={p[1]+pos[1],p[2]+pos[2],p[3]+pos[3]}
  elseif key=='vp'then
    p={p[1]+0.9,p[2]+1,p[3]+1.25}
  elseif key=='debt'then
    p={p[1]-0.9,p[2]+1,p[3]-1.25}
  else
    p={p[1]-0.9,p[2]+1,p[3]-1.25}
  end
  local t={position=p,rotation={0,180,0},callback='tokenCallback',callback_owner=Global,params={name or obj.getName(),n or 0}}
  log(t.params)
  if not n then t.callback=nil end
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
{guid='497478'},{guid='e700bc'},{guid='7cbaf0'},{guid='5acda1'},{guid='28c05c'},{guid='00d4cc'},
{guid='377aaf'},{guid='563a61'},{guid='56dcad'},{guid='d516bd'},{guid='4b9597'},{guid='4ca7f5'}}
ref_sideSlots={
{guid='7ba0bf'},{guid='de9a73'},{guid='61ae8d'},{guid='f7a574'},
{guid='bb0b4f'},{guid='25756f'},{guid='1e113a'},{guid='2ea60a'},
{guid='8cf7ae'},{guid='d8a850'},{guid='3ba1c2'},{guid='d5f986'},
{guid='f0bd83'},{guid='811c7b'},{guid='fa020b'},{guid='a96aef'},

{guid='755720'},{guid='4733fe'},{guid='a6f52e'},{guid='7fb923'},
{guid='bf7652'},{guid='5750e9'},{guid='5a0bb6'},{guid='08dc7f'},
{guid='b6ce05'},{guid='bf9dda'},{guid='adb237'},{guid='788b21'},
{guid='dc9cf0'},{guid='eaf95e'},{guid='7535f5'},{guid='fa776f'},
{guid='8a299d'},{guid='6c4cb9'},{guid='5c1bf4'},{guid='18a0ba'},
{guid='fb0663'},{guid='5e6695'},{guid='e6fed4'},{guid='5bd468'},
{guid='360c35'},{guid='72bf1b'},{guid='561fa6'},{guid='98bcc2'}}
ref_eventSlots={
{guid='e091ca',zone='f5e84d',pos={-10.5,1.25,8.5}},
{guid='bb3643',zone='2ffd78',pos={ -3.5,1.25,8.5}},
{guid='1ff6fe',zone='65aaf5',pos={  3.5,1.25,8.5}},
{guid='6ca433',zone='0c28db',pos={ 10.5,1.25,8.5}}}
ref_supplyPiles={
{guid='85fcca',name='Platinums'},
{guid='475de7',name='Potions'},
{guid='6ce695',name='Colonies'},
{guid='2adf43',name='Ruins pile'},
{guid='9c6cd8',name='Shelters'},
{guid='1e2942',name='Boulder Trap pile'},
{guid='4033ec',name='Heirlooms'},
{guid='aa2438',name='Zombies'},
{guid='3a738e',name='Coppers'},
{guid='a655a3',name='Silvers'},
{guid='b11add',name='Golds'},
{guid='d9a2c0',name='Curses'},
{guid='4d0b0e',name='Estates'},
{guid='d253c8',name='Duchies'},
{guid='4a8334',name='Provinces'}}
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
{name='Stallions pile'},
{name='Panda / Gardener pile'}}
ref_kingdomSlots={
{guid='ea57b1',zone='987e4a'},
{guid='08e74d',zone='816553'},
{guid='3efdc8',zone='7b20e5'},
{guid='4e4e40',zone='740c12'},
{guid='4084c6',zone='fefd47'},
{guid='6be6f9',zone='47d4f1'},
{guid='4ab1b9',zone='4a3f91'},
{guid='48b491',zone='9d12c3'},
{guid='03a180',zone='9e931d'},
{guid='25f0bd',zone='00770c'}}
ref_players={
Blue  ={deckZone='307d12',discardZone='41de74',zone='062acc',coins='b2dc22',vp='b59b65',debt='186c83',tavern='015528',deck={-39.5,4,14.5},discard={-44.5,4,14.5}},
Green ={deckZone='9359a4',discardZone='72ba37',zone='c11794',coins='22bdb3',vp='6ae2a8',debt='a34771',tavern='af5c58',deck={-39.5,4,-27.5},discard={-44.5,4,-27.5}},
White ={deckZone='e6b388',discardZone='eb044b',zone='c95925',coins='b6bf41',vp='1b4618',debt='3d4844',tavern='d7d996',deck={-11.5,4,-27.5},discard={-16.5,4,-27.5}},
Red   ={deckZone='5a6e68',discardZone='e09013',zone='d1c5af',coins='4b832d',vp='84f540',debt='9cfa4a',tavern='48295f',deck={16.5,4,-27.5},discard={11.5,4,-27.5}},
Orange={deckZone='420340',discardZone='bf9b32',zone='10c425',coins='ce8828',vp='0d128b',debt='f2a253',tavern='fd4953',deck={44.5,4,-27.5},discard={-39.5,4,-27.5}},
Yellow={deckZone='7ee56d',discardZone='046cfd',zone='827520',coins='17dd2a',vp='c979ca',debt='10cb81',tavern='dea1f7',deck={44.5,4,14.5},discard={39.5,4,14.5}}}
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
{name='Antiquities'},
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
{cost='M3D0P0',name='Farmers\' Market',type='Action - Gathering',depend='VP'},
{cost='M5D0P0',name='Forum',type='Action'},
{cost='M3D0P0',name='Gladiator / Fortune',type='Action'},
{cost='M5D0P0',name='Groundskeeper',type='Action',depend='VP'},
{cost='M5D0P0',name='Legionary',type='Action - Attack'},
{cost='M2D0P0',name='Patrician / Emporium',type='Action',depend='VP'},
{cost='D8M0P0',name='Royal Blacksmith',type='Action'},
{cost='D8M0P0',name='Overlord',type='Action - Command'},
{cost='M4D0P0',name='Sacrifice',type='Action',depend='VP'},
{cost='M2D0P0',name='Settlers / Bustling Village',type='Action'},
{cost='M4D0P0',name='Temple',type='Action - Gathering',depend='VP'},
{cost='M4D0P0',name='Villa',type='Action'},
{cost='M5D0P0',name='Wild Hunt',type='Action - Gathering',depend='VP'},
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
{cost='MXDXP0',type='Landmark',name='Wolf Den',VP=function(t)log(t)return -t.wolf*3 end},
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
{cost='M2D0P0',name='Pixie',type='Action - Fate',depend='Heirloom'},
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
{cost='MXDXP0',type='Landmark',name='Xv1 El Dorado',depend='Artifact'},
{cost='M2D0P0',name='X Handler v1',type='Action'},
{cost='M2D0P0',name='X Hops v1',type='Treasure - Duration'},
{cost='M2D0P0',name='X Smithing Tools',type='Action - Duration'},
{cost='M2D0P0',name='X Stallions',type='Action - Stallion',depend='Horse'},
{cost='M2D0P1',name='X Wat',type='Treasure - Victory',VP=1},
{cost='M3D0P0',name='X Informer',type='Action - Command'},
{cost='M3D0P0',name='X Notary',type='Action',depend='Heir'},
{cost='M4D0P0',name='X Lease',type='Action'},
{cost='M4D0P0',name='X Lessor',type='Action - Attack'},
{cost='M4D0P0',name='X Statue v1',type='Action - Victory',depend='Aside'},
{cost='M4D0P0',name='X Vigil v1',type='Action - Attack'},
{cost='M4D0P0',name='X Watchmaker',type='Action - Reserve'},
{cost='M5D0P0',name='X Plague Doctor v1',type='Action - Attack - Duration'},
{cost='M5D0P0',name='X Savings',type='Treasure'},
{cost='M5D0P0',name='X Tithe v1',type='Action - Attack - Reserve - Duration',depend='Debt'},
{cost='M6D0P0',name='X Grand Laboratory',type='Action'},
{cost='M2D0P0',name='X Shetland Pony',type='Action - Stallion'},
{cost='M3D0P0',name='X Clydesdale',type='Action - Stallion'},
{cost='M4D0P0',name='X Appaloosa',type='Action - Stallion'},
{cost='M5D0P0',name='X Paint Horse',type='Action - Stallion'},
{cost='M6D0P0',name='X Gypsy Vanner',type='Action - Stallion'},
{cost='M7D0P0',name='X Mustang',type='Action - Victory - Stallion',VP=2},
{cost='M8D0P0',name='X Friesian',type='Action - Victory - Stallion',VP=3},
{cost='M9D0P0',name='X Arabian Horse',type='Victory - Stallion',VP=function(t)if t.deck['Arabian Horse']==1 then return t.deck.Horse or 0 else return 0 end end},
--X'v2 http://forum.dominionstrategy.com/index.php?topic=20407.0
{cost='MXDXP0',type='Landmark',name='X Clock Tower',depend='VP'},
{cost='MXDXP0',type='Landmark',name='X El Dorado',depend='Artifact'},
{cost='M0D0P2',type='Project',name='X Science Grant'},
{cost='M0D0P0',type='Event',name='X Debate',depend='Debt VP'},
{cost='M3D0P0',type='Event',name='X Truce',depend='Artifact'},
{cost='M0D0P0',type='State',name='X Collecting Artifacts'},
{cost='M0D0P0',type='Artifact',name='X Pact'},
{cost='M0D5P0',name='X Dice Games',type='Action'},
{cost='M0D0P0',name='X Draft',type='Action'},
{cost='M2D0P0',name='X Handler',type='Action'},
{cost='M2D0P0',name='X Hops',type='Treasure - Duration'},
{cost='M3D0P0',name='X Secret Path',type='Action - Duration - Victory',VP=1},
{cost='M4D0P0',name='X Duality',type='Action'},
{cost='M4D0P0',name='X Statue',type='Action - Victory'},
{cost='M4D0P0',name='X Stray Cat',type='Action - Reserve'},
{cost='M4D0P0',name='X Vigil',type='Action'},
{cost='M4D0P0',name='X Watchmaker',type='Action - Reserve'},
{cost='M4D3P0',name='X Mobsters',type='Night - Treasure'},
{cost='M5D0P0',name='X Custodian',type='Night - Attack - Duration'},
{cost='M5D0P0',name='X Market Town',type='Action'},
{cost='M5D0P0',name='X Plague Doctor',type='Action - Attack - Duration'},
{cost='M5D0P0',name='X Tithe',type='Action - Attack - Reserve - Duration',depend='Debt'},
{cost='M7D0P0',name='X Ballroom',type='Action'},
--Antiquities
{cost='M5D0P0',name='Q Agora',type='Action - Reaction'},
{cost='M4D0P0',name='Q Aquifer',type='Action'},
{cost='M7D0P0',name='Q Archaeologist',type='Action'},
{cost='M4D0P0',name='Q Boulder Trap',type='Trap',VP=-1},
{cost='M4D0P0',name='Q Collector',type='Action'},
{cost='M4D0P0',name='Q Curio',type='Treasure'},
{cost='M8D0P0',name='Q Dig',type='Action',depend='VP'},
{cost='M2D0P0',name='Q Discovery',type='Treasure'},
{cost='M6D0P0',name='Q Encroach',type='Action'},
{cost='M3D0P0',name='Q Gamepiece',type='Treasure - Reaction'},
{cost='M3D0P0',name='Q Grave Watcher',type='Action - Attack'},
{cost='M1D0P0',name='Q Graveyard',type='Action'},
{cost='M3D0P0',name='Q Inscription',type='Action - Reaction'},
{cost='M3D0P0',name='Q Inspector',type='Action - Attack'},
{cost='M5D0P0',name='Q Mastermind Antiquities',type='Action'},
{cost='M6D0P0',name='Q Mausoleum',type='Action',depend='Aside Memory'},
{cost='M4D0P0',name='Q Mendicant',type='Action',depend='VP'},
{cost='M3D0P0',name='Q Miner',type='Action'},
{cost='M5D0P0',name='Q Mission House',type='Action',depend='VP'},
{cost='M4D0P0',name='Q Moundbuilder Village',type='Action'},
{cost='M8D0P0',name='Q Pharaoh',type='Action - Attack'},
{cost='M3D0P0',name='Q Profiteer',type='Action'},
{cost='M5D0P0',name='Q Pyramid',type='Action'},
{cost='M3D0P0',name='Q Shipwreck',type='Action'},
{cost='M4D0P0',name='Q Snake Charmer',type='Action - Attack'},
{cost='M4D0P0',name='Q Stoneworks',type='Action',depend='VP'},
{cost='M5D0P0',name='Q Stronghold',type='Action - Reaction'},
{cost='M3D0P0',name='Q Tomb Raider',type='Action - Attack'},
--Legacy
{cost='M0D0P0',type='Edict',name='L Trade Agreement'},
{cost='M0D0P0',type='Edict',name='L Supervision'},
{cost='M0D0P0',type='Edict',name='L Simplicity',depend='Villagers'},
{cost='M0D0P0',type='Edict',name='L Monarchy'},
{cost='M0D0P0',type='Edict',name='L Inflation'},
{cost='M0D0P0',type='Edict',name='L Imperialism',depend='Platinum'},
{cost='M0D0P0',type='Edict',name='L Gigantism'},--3 More supply piles
{cost='M0D0P0',type='Edict',name='L Expansion',depend='MinusCoin'},
{cost='M0D0P0',type='Edict',name='L Exile',depend='Aside'},
{cost='M0D0P0',type='Edict',name='L Diplomacy'},
{cost='M0D0P0',type='Edict',name='L Banishment'},
{cost='M0D0P0',type='Edict',name='L Appeasement'},
{cost='M0D0P0',type='Edict',name='L Tyranny',depend='MinusCoin'},
{cost='M0D0P0',type='Edict',name='L Urbanisation'},--Replace estate/shelter with copper
{cost='M3D0P0',type='Event',name='L Exodus'},
{cost='M6D0P0',type='Event',name='L Contest'},--Makes a Contest pile of 10 5Costs
{cost='M0D0P0',type='Event',name='L Blessing'},
{cost='M5D0P0',type='Event',name='L Bureaucracy'},--token on Province pile
{cost='M6D0P0',type='Event',name='L Bargain',depend='Coffers'},
{cost='M0D0P1',type='Event',name='L Research'},
{cost='M0D0P0',type='Event',name='L Tithe'},
{cost='M3D0P0',type='Event',name='L Plundering',depend='Spoils'},
{cost='M3D0P0',type='Event',name='L Parting',depend='Journey'},
{cost='M5D0P0',type='Event',name='L Improve'},
{cost='M1D0P0',name='L Alley',type='Action'},
{cost='M2D0P0',name='L Decree',type='Treasure'},
{cost='M2D0P0',name='L Sunken City',type='Action - Duration'},
{cost='M3D0P0',name='L Nun',type='Action'},
{cost='M3D0P0',name='L Sawmill',type='Action'},
{cost='M3D0P0',name='L Shrine',type='Action'},
{cost='M3D0P0',name='L Well',type='Action'},
{cost='M4D0P0',name='L Docks',type='Action - Duration'},
{cost='M4D0P0',name='L Farmer',type='Action'},
{cost='M4D0P0',name='L Gallows',type='Action'},
{cost='M4D0P0',name='L Heir Legacy',type='Action'},
{cost='M4D0P0',name='L Landlord',type='Action'},
{cost='M5D0P0',name='L Assemble',type='Action'},
{cost='M5D0P0',name='L Cliffside Village',type='Action'},
{cost='M5D0P0',name='L Craftsmen',type='Action'},
{cost='M5D0P0',name='L Lycantrope',type='Action - Attack'},
{cost='M5D0P0',name='L Maze',type='Action - Victory - Attack'},
{cost='M5D0P0',name='L Sultan',type='Action'},
{cost='M5D0P0',name='L Tribunal',type='Action - Attack'},
{cost='M6D0P0',name='L Meadow',type='Victory',VP=2},
--LegacyFeats
{cost='M2D0P0',name='L Headhunter',type='Action - Fame'},
{cost='M4D0P0',name='L Curiosity Shop',type='Action - Fame'},
{cost='M4D0P0',name='L Imposter',type='Action - Fame'},
{cost='M5D0P0',name='L Adventure-Seeker',type='Action - Fame'},
{cost='M5D0P0',name='L Inquisitor',type='Action - Attack - Fame'},
{cost='M6D0P0',name='L Hall of Fame',type='Victory - Fame'},
--LegacyExpert
{cost='M0D0P1',name='L Homunculus',type='Action'},
{cost='M0D8P0',name='L Promenade',type='Action'},
{cost='M0D8P0',name='L Institute',type='Action'},
{cost='M2D0P0',name='L Sheriff',type='Action - Attack'},
{cost='M2D0P0',name='L Swamp',type='Action',depend='Imp Ghost'},
{cost='M3D0P0',name='L Iron Maiden',type='Action - Attack - Looter'},
{cost='M3D0P1',name='L Incantation',type='Action'},
{cost='M3D0P0',name='L Pilgrim',type='Action',depend='Coffers'},
{cost='M3D0P0',name='L Scientist',type='Action'},
{cost='M4D0P0',name='L Hunter',type='Action - Reserve'},
{cost='M4D0P0',name='L Lady-in-waiting',type='Action - Reserve'},
{cost='M4D0P0',name='L Scribe',type='Action - Attack - Duration',depend='Debt'},
{cost='M4D0P0',name='L Town',type='Action'},
{cost='M4D0P0',name='L Waggon Village',type='Action',depend='Debt'},
{cost='M5D0P0',name='L Delegate',type='Action'},
{cost='M5D0P0',name='L Lich',type='Action',depend='Zombie'},
{cost='M5D0P0',name='L Necromancer Legacy',type='Action'},
{cost='M5D0P0',name='L Sanctuary',type='Action'},
{cost='M6D0P0',name='L Minister',type='Action',depend='VP'},
{cost='M0D0P0',name='L Road',type='Action'},
{cost='M3D0P0',name='L Skeleton',type='Action - Attack'},
{cost='M3D0P0',name='L Zombie Legacy',type='Action - Attack'},
{cost='M3D0P0',name='L Loyal Subjects',type='Action - Attack'},
--LegacyTeams
{cost='M2D0P0',name='L Steeple',type='Action - Team'},
{cost='M3D0P0',name='L Conman',type='Action - Team'},
{cost='M3D0P0',name='L Fisher',type='Action - Reaction - Team'},
{cost='M4D0P0',name='L Merchant Quarter',type='Action - Team'},
{cost='M4D0P0',name='L Study',type='Action - Team'},
{cost='M4D0P0',name='L Still Village',type='Action - Duration - Team'},
{cost='M5D0P0',name='L Salesman',type='Action - Team'},
{cost='M5D0P0',name='L Sponsor',type='Action - Team'},
--Spellcasters
{cost='M2D0P0',type='Spell',name='S Wisdom'},
{cost='M4D0P0',type='Spell',name='S Wealth'},
{cost='M2D0P0',type='Spell',name='S Purity'},
{cost='M3D0P0',type='Spell',name='S Harm'},
{cost='M8D0P0',type='Spell',name='S Glory'},
{cost='M1D0P0',type='Spell',name='S Esprit'},
{cost='M4D0P0',type='Spell',name='S Dexterity'},
{cost='M2D0P0',name='S Trickster',type='Action - Spellcaster'},
{cost='M3D0P0',name='S Stone Circle',type='Victory - Spellcaster',VP=2},
{cost='M3D0P0',name='S Magician',type='Action - Spellcaster'},
{cost='M3D0P0',name='S Shaman',type='Action - Spellcaster'},
{cost='M4D0P0',name='S Summoner',type='Action - Spellcaster'},
{cost='M4D0P0',name='S Grimoire',type='Treasure - Spellcaster'},
{cost='M5D0P0',name='S Sorcerer',type='Action - Spellcaster'},
{cost='M5D0P0',name='S Wizard',type='Action - Spellcaster'},
--Seasons
{cost='M2D0P0',name='S Sojourner',type='Action - Season'},
{cost='M3D0P0',name='S Bailiff',type='Action - Season'},
{cost='M3D0P0',name='S Snow Witch',type='Action - Attack - Season'},
{cost='M3D0P0',name='S Student',type='Action - Season',depend='Following'},
{cost='M4D0P0',name='S Barbarian',type='Action - Season'},
{cost='M4D0P0',name='S Lumbermen',type='Action - Season'},
{cost='M4D0P0',name='S Peltmonger',type='Action - Season'},
{cost='M4D0P0',name='S Sanitarium',type='Action - Season'},
{cost='M4D0P0',name='S Timberland',type='Victory - Season',depend='VP',VP=2},
{cost='M5D0P0',name='S Ballroom',type='Action - Season'},
{cost='M5D0P0',name='S Cottage',type='Action - Season'},
{cost='M5D0P0',name='S Fjord Village',type='Action - Season'},
{cost='M5D0P0',name='S Plantation',type='Action - Season'},
{cost='M5D0P0',name='S Restore',type='Action - Season'},
--Tools http://forum.dominionstrategy.com/index.php?topic=20273.0
{cost='M4D0P0',name='T Armor',type='Tool'},
{cost='M4D0P0',name='T Axe',type='Tool'},
{cost='M5D0P0',name='T Bag of Holding',type='Tool'},
{cost='M4D0P0',name='T Bow and Arrow',type='Tool - Attack'},
{cost='M2D0P0',name='T Compass',type='Tool'},
{cost='M5D0P0',name='T Moccasins',type='Tool'},
{cost='M5D0P0',name='T Rations',type='Tool'},
{cost='M6D0P0',name='T Spellbook',type='Tool - Command'},
{cost='M5D0P0',name='T Sword',type='Tool'},
{cost='M3D0P0',name='T Telescope',type='Tool'},
{cost='M3D0P0',name='T Wagon',type='Tool'},
{cost='M5D0P0',name='T Battalion',type='Action'},
{cost='M0D0P0',name='T Broken Sword',type='Tool'},
{cost='M5D0P0',name='T Charlatan',type='Action'},
{cost='M0D0P0',name='T Cursed Antique',type='Tool'},
--Roots&Renewal http://forum.dominionstrategy.com/index.php?topic=11563.0
{cost='MXDXP0',type='Landmark',name='R Chancellery'},
{cost='M0D0P0',name='R Realm Tax',type='Treasure'},
{cost='M2D0P0',name='R Refugees',type='Action'},
{cost='M2D0P0',name='R Salesman',type='Action - Reserve'},
{cost='M2D0P0',name='R Trapper',type='Action'},
{cost='M3D0P0',name='R Deposit',type='Action'},
{cost='M3D0P0',name='R Petty Lord',type='Action - Traveller - Looter',depend='Prime'},
{cost='M3D0P0',name='R Provisioner',type='Action'},
{cost='M4D0P0',name='R Builder',type='Action - Reaction'},
{cost='M4D0P0',name='R Mining Camp',type='Action - Looter'},
{cost='M4D0P0',name='R Orphanage',type='Action',depend='VP'},
{cost='M4D0P0',name='R Reconvert',type='Action'},
{cost='M4D0P0',name='R Reeve',type='Action',depend='Estate'},
{cost='M4D0P0',name='R Shire',type='Victory - Reaction',VP=function(t)local vp,ne,zs,f=0,{},{},false;table.insert(zs,getObjectFromGUID(ref.baneSlot.zone))
    for _,g in ipairs(ref_basicSlotzs)do table.insert(zs,getObjectFromGUID(g))end
    for _,s in ipairs(ref_kingdomSlots)do table.insert(zs,getObjectFromGUID(s.zone))end
    for _,z in ipairs(zs)do for __,o in ipairs(z.getObjects())do
      if o.tag=='Card'then if getType(o.getName()):find('Knight')then table.insert(ne,'Knights')else table.insert(ne,o.getName())end
      elseif o.tag=='Deck'then table.insert(ne,o.getName():sub(1,-6))end end end
    for c,n in pairs(t.deck)do
      for _,p in ipairs(ne)do if p==c then f=true end end
      if getType(c):find('Knight')then for _,p in ipairs(ne)do if p=='Knights'then f=true end end end
      for _,bmCard in ipairs(bmDeck)do if c==bmCard then f=true end end--[[Blackmarket]]
      if not f then vp=vp+n end end return vp end},
{cost='M5D0P0',name='R Beachcomb',type='Action'},
{cost='M5D0P0',name='R Benefit',type='Action - Reaction'},
{cost='M5D0P0',name='R Building Crane',type='Action'},
{cost='M5D0P0',name='R Juggler',type='Action'},
{cost='M5D0P0',name='R Reparations',type='Treasure'},
{cost='M5D0P0',name='R Revaluate',type='Action',depend='Prime'},
{cost='M6D0P0',name='R Riverside',type='Victory'},
{cost='M4D0P0',name='R Lock / Caretaker',type='Treasure'},
{cost='M4D0P0',name='R Lock',type='Treasure'},
{cost='M5D0P0',name='R Caretaker',type='Action'},
{cost='M4D0P0',name='R Key',type='Treasure'},
{cost='M1D0P0',name='R Forest Hut',type='Action - Shelter'},
{cost='M5D0P0',name='R Robber Knight',type='Action - Attack - Looter - Traveller'},
{cost='M5D0P0',name='R Protector',type='Action - Traveller'},
{cost='M7D0P0',name='R Warlord',type='Action - Attack'},
{cost='M7D0P0',name='R Savior',type='Action'},
{cost='M3D0P0',name='R Battlement',type='Action - Reaction'},
{cost='M0D0P0',name='R Manor',type='Action'},
--Adamabrams
{cost='M6D0P0',name='C Mortgage',type='Project',depend='Debt'},
{cost='M0D0P0',name='C Lost Battle',type='Landmark',depend='VP'},
{cost='M4D0P0',name='C Cave',type='Night - Victory',VP=2},
{cost='M4D0P0',name='C Chisel',type='Action - Reserve'},
{cost='M7D0P0',name='C Knockout',type='Event',depend='Artifact'},
{cost='M1D0P1',name='C Migrant Village',type='Action',depend='Villager'},
{cost='M4D0P0',name='C Discretion',type='Action - Reserve',depend='VP Coffers Villager'},
{cost='M4D0P0',name='C Plot',type='Night',depend='VP'},
{cost='M4D0P0',name='C Investor',type='Action',depend='Debt'},
{cost='M6D0P0',name='C Contest',type='Action - Looter',depend='Prize'},
{cost='M6D0P0',name='C Uneven Road',type='Action - Victory',depend='Estate',VP=3},
{cost='M3D0P1',name='C Jekyll',type='Action',depend='Hyde'},
{cost='M4D0P1',name='C Hyde',type='Night - Attack'},
{cost='M5D0P0',name='C Stormy Seas',type='Night',depend='Debt'},
{cost='M0D4P0',name='C Liquid Luck',type='Action - Fate',depend='VP Potion'},
{cost='M6D0P0',name='C Cheque',type='Treasure - Command'},
{cost='M2D0P0',name='C Balance',type='Action - Reserve - Fate - Doom'},
--Co0kieL0rd http://forum.dominionstrategy.com/index.php?topic=13625.0
--icon https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Emojione_BW_1F36A.svg/768px-Emojione_BW_1F36A.svg.png
{cost='MXDXP0',type='Landmark',name='C Volcano'},
{cost='M4D0P0',name='C Bog Village',type='Action'},
{cost='M5D0P0',name='C Cabal',type='Action - Attack'},
{cost='M0D0P0',name='C Turncoat',type='Action'},
{cost='M4D0P0',name='C Guest of Honor',type='Action - Reserve',depend='VP'},
{cost='M4D0P0',name='C Demagogue',type='Action - Attack'},
{cost='M3D0P0',name='C Draft Horses',type='Action'},
{cost='M4D0P0',name='C Dry Dock',type='Action - Duration'},
{cost='M5D0P0',name='C Mediator',type='Action',depend='VP'},
{cost='M2D0P0',name='C Money Launderer',type='Action'},
{cost='M5D0P0',name='C Prefect',type='Action - Reserve',depend='Aside'},
{cost='M4D0P0',name='C Regal Decree',type='Action'},
{cost='M5D0P0',name='C Routing',type='Action'},
{cost='M3D0P0',name='C Secret Society',type='Action'},
{cost='M0D0P0',name='C ',type='Action'},
{cost='M3D0P0',name='C Suburb',type='Action - Reaction'},
{cost='M3D0P0',name='C Tollkeeper',type='Action - Duration'},
--Witches https://www.reddit.com/r/dominion/comments/hjwi11/witch_variants_for_every_expansion_day_7/
{cost='M5D0P0',name='W Equestrian Witch',type='Action - Attack',depend='Horse'},
{cost='M0D0P1',name='W Resourceful Witch',type='Action - Attack'},
{cost='M5D0P0',name='W Eclectic Witch',type='Action - Attack'},
{cost='M4D0P0',name='W Slum Witch',type='Action - Attack'},
{cost='M4D0P0',name='W Hedge Witch',type='Action - Attack - Gathering',depend='VP'},
{cost='M3D0P0',name='W Invoking Witch',type='Action - Attack'},
{cost='M5D0P0',name='W Summoned Fiend',type='Action - Attack - Doom'},
{cost='M4D0P0',name='W Miserly Witch',type='Action - Attack'},
{cost='M0D0P0',name='W Cursed Copper',type='Treasure - Curse',VP=-1},
--https://imgur.com/gallery/iaIN7iP
{cost='M4D0P0',name='W Faustian Witch',type='Action - Attack',depend='CursedBargain'},
{cost='M0D0P0',name='W Cursed Bargain',type='Treasure - Reserve - Curse',VP=-3},
{cost='M6D2P0',name='W Devious Witch',type='Action - Attack'},
--https://imgur.com/gallery/lx1BnPg
{cost='M3D0P0',name='W Rummaging Witch',type='Action - Attack'},
{cost='M2D0P0',name='W Retired Witch',type='Action - Attack',depend='Coffers'},
--https://imgur.com/gallery/18UZBgV
{cost='M4D0P0',name='W Nosy Witch',type='Action - Attack'},
{cost='M6D0P0',name='W Wandering Witch',type='Action - Attack - Reaction'},
--https://imgur.com/gallery/KV0V01h
{cost='M3D0P1',name='W Poisonous Witch',type='Action - Attack'},
{cost='M0D0P0',name='W Cursed Beverage',type='Treasure - Curse',VP=-2},
{cost='M5D0P0',name='W Prideful Witch',type='Action - Attack',depend='VP'},
--https://imgur.com/gallery/aLFCmWI
{cost='M4D0P0',name='W Versatile Witch',type='Action - Attack'},
{cost='M6D0P0',name='W Vengeful Witch',type='Action - Attack - Duration'},
--https://imgur.com/a/mw9c4N0
{cost='M5D0P0',name='W Ghostly Witch',type='Night - Attack'},
{cost='M0D0P0',name='W Ethereal Curse',type='Night - Curse',VP=-1},
{cost='M4D0P0',name='W Neighborhood Witch',type='Action',depend='Artifact'},
{cost='MXDXPX',name='W Cauldron',type='Artifact'},
--Custom https://www.reddit.com/r/dominion/comments/hrx0rb/original_new_cards_i_made_hope_you_enjoy1_lol/
{cost='M5D0P0',name='C Burned Village',type='Action - Night'},
{cost='M4D0P0',name='C Rescuers',type='Treasure - Heirloom'},
{cost='M5D0P0',name='C Ancient Coin',type='Treasure - Duration'},
{cost='M5D0P0',name='C Witching Hour',type='Night - Duration - Attack'},
{cost='M4D0P0',name='C Panda / Gardener',type='Action',depend='Coffers Villager',setup=function(o)if getType(o.getObjects()[1].name):find('Action')then tokenMake(o,'coin')tokenMake(o,'coin')end end},
{cost='M4D0P0',name='C Panda',type='Action'},
{cost='M6D0P0',name='C Gardener',type='Action'},
{cost='M0D0P8',name='C Bacchanal',type='Night',depend='Villager'},
{cost='M4D0P0',name='C Homestead',type='Action'},
{cost='M4D0P0',name='C Tulip Field',type='Victory',depend='Coffers Villager'},
{cost='M5D0P0',name='C Backstreet',type='Night',depend='Coffers Villager'},
{cost='M0D0P0',name='C Rabbit',type='Action - Treasure'},
{cost='M5D0P0',name='C Magician',type='Action',depend='Rabbit'},
{cost='M4D0P0',name='C Fishing Boat',type='Action - Duration'},
{cost='M3D0P0',name='C Drawbridge',type='Action - Reserve'},
{cost='M4D0P0',name='C Jinxed Jewel v1',type='Treasure - Night - Heirloom'},
{cost='M4D0P0',name='C Jinxed Jewel',type='Treasure - Night - Heirloom',depend='Heirloom'},
{cost='M0D0P0',name='',type=''},
{cost='M0D0P0',name='-1 Card Token',type=''}
}