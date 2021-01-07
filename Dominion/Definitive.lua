--DominionDefinitiveEditionModifiedByAmuzet2020_07_30_k
VERSION,GITURL=2.7,'https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Dominion/Definitive.lua'
--[[Bugs:
Some card backs are miscolored so you can tell which is which in hands. ex shelters
Heirlooms spawn an extra card next to yellow if there are 5+ players
TO DO:
Create Input that can take kingdom as CSV
Create Input that shows kingdom as CSV
Prevent Card Shaped objects from being scored
Make Included sets Work
Find the Artifact named: "X Pact"
Cleaner:If a player leaves the game during their turn, it will give their cards to the pervious player]]
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
    local v=wr.text:match('VERSION,GITURL=(%d+%p?%d+)')
    if v then v=tonumber(v)
      if v<VERSION then     broadcastToAll('Oh look at you with a Testing Version\nPlease Report any bugs to Amuzet.',{0,1,1})
      elseif v>VERSION then broadcastToAll('There is an UPDATE!\nAttempting Update.',{1,1,0})self.setLuaScript(wr.text)self.reload()
      else                  broadcastToAll('Up to Date!\nHave a nice time playing.',{0,1,0})end
    else broadcastToAll('Problems have occured! Attempt to contact Amuzet on TTSClub',{1,0,0.2})end end)
  local Color={Blue={31/255,136/255,255/255},Green={49/255,179/255,43/255},Red={219/255,26/255,24/255},White={0.3,0.3,0.3},Orange={244/255,100/255,29/255},Yellow={231/255,229/255,44/255}}
  sL={n=1,
  {'Official Sets','Currently only official sets are allowed.\nThis excludes first printings, promos and fan expansions.',14},
  {'Printed Cards','Currently only printed cards are allowed.\nThis excludes fan expansions.',14},
  {'Expansions','Currently only expansions are allowed.\nThis excludes promo and cut cards, Adamabrams and Xtras.',22},
  {'Everyting','Currently cards from any set are allowed.\nThis excludes nothing.',#ref.cardSets-1}}
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
    sL.n=loaded_data.sl or 1
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
  setUninteractible()
  math.randomseed(os.time())
  
  for k,p in pairs(ref.players)do
    for _,o in pairs(getObjectFromGUID(p.zone).getObjects())do
      if o.getName()=='Victory Points'then
        ref.players[k].vp=o.getGUID()
      elseif o.getName()=='Debt Tokens'then
        ref.players[k].debt=o.getGUID()
      elseif o.getName()=='Coffers'then
        ref.players[k].coin=o.getGUID()
  end end end
  
  if gameState==1 then
    --Added Heirlooms
    for _,v in ipairs(getPile('Heirlooms').getObjects())do ref.heirlooms[v.name]=v.guid end
    setNotes('[40e0d0][b][u]Dominion: Definitive Edition[/b][/u][-]\n\nBefore pressing Start Game, you may place any card from the expansion piles into the empty supply slots. Select any number of expansions to be randomly selected to fill all the remaining slots. You may also remove any undesireable card from its expansion deck to prevent it from being selected. You may save the game now to save your selected kingdom and expansions before pressing start.\n\n[FFFF00][b]Do not delete any decks or place any deck of cards into a supply slot.[/b]')
    local B={label='',click_function='click_selectDeck',function_owner=self,position={0,0.4,0.6},rotation={0,0,0},scale={0.5,1,0.5},height=600,width=2000,font_size=250,color={0,0,0},font_color={1,1,1}}
    for i in ipairs(ref.cardSets)do
      local obj=getObjectFromGUID(ref.cardSets[i].guid)
      if obj then
        B.label='Include\n'..obj.getName()
        obj.createButton(B)
        for j, guid in ipairs(useSets)do
          local obj2=getObjectFromGUID(guid)
          if obj==obj2 then
            obj.highlightOn({0,1,0})
            break end end end end
    B.click_function='click_forcePile'
    for k,v in pairs({1,5,6})do
      local obj=getObjectFromGUID(ref.supplyPiles[v].guid)
      if obj then
        B.label='Force\n'..obj.getName()
        obj.createButton(B)
        local bool=0
        if B.label:find('Platinum')then bool=usePlatinum
        elseif B.label:find('Shelters')then bool=useShelters
        elseif B.label:find('Boulder Trap pile')then bool=useBoulderTrap end  
        if bool==1 then obj.highlightOn({0,1,0})
        elseif bool==2 then obj.highlightOn({1,0,0})end
        end end
    local startB=getObjectFromGUID(ref.startButton)
    if startB then
      local btn=setmetatable({d=-3,function_owner=self,position={-24,0,-8},rotation={0,180,0},scale={0.7,0.7,0.7},height=2000,width=5750,font_size=5000},{__call=function(b,l,t,p,f)
        b.position,b.label,b.tooltip=p or {b.position[1],b.position[2],b.position[3]-b.d},l,t or'';if f then b.click_function=f else b.click_function='click_' .. l:gsub('[^\n]+\n',''):gsub('%s','')end startB.createButton(b)end})
      btn('Quick Setup\nTwo Sets','Random Kingdom from any two sets',{-8.5,0,-48})
      btn('Quick Setup\nThree Sets','Random Kingdom from any three sets')
      btn('Quick Setup\nAll Sets','Random Kingdom from every set')
      btn('Tutorial\nBasic Game','Set Kingdom with only actions and up to two attacks')
      btn('Balanced Setup\nDual Sets','Random Kingdom made with 5 cards of one set and 5 from another',{8.5,0,-48})
      btn('Balanced Setup\nTriple Sets','Random Kingdom made with 3 cards each from 3 sets with a forth card from a random one of those sets')
      btn('Balanced Setup\nFive Sets','Random Kingdom made with 2 cards each from 5 sets')
      btn('Balanced Setup\nTen Sets','Random Kingdom made with a card each from 10 different sets')
      btn.color={0,0,0}btn.font_color={1,1,1}
      btn('Selected Sets\nStart Game','Random Kingdom from selected sets and cards',{0,0,-39})
      btn('Black Market\nLimit: '..blackMarketMax,'The Number of cards in the Black Market',{-16,0,-31},'click_blackMarketLimit')
      btn('Max Events: '..eventMax,'The Maximum number of noncards in Kingdom',{16,0,-31},'click_eventLimit')
      btn.width=7000
      btn('Include in Randomizer\nOfficial Expansions','These sets are all official expansions made by Donald X V of Rio Grande Games',{42,0,-31},'click_setLimit')
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
    obj.createButton({label='End Game',click_function='click_endGame',function_owner=self,position={-60,0,-4},rotation={0,180,0},height=1500,width=4000,font_size=9000})
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
            if t and('LandmarkBoonHexStateArtifactProject'):find(t)then elseif t then
              obj.setRotation({0,180,180})
              obj.setPosition(ref.players[currentPlayer].deck)
              coroutine.yield(0)end end end end
      local gObjs=function(s)return getObjectFromGUID(ref.players[currentPlayer][s]).getObjects()end
      --ERROR UNKOWN past this point!
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
            if t and('LandmarkBoonHexStateArtifactProject'):find(t)then elseif t then
              obj.setRotation({0,180,180})
              obj.setPosition(ref.players[currentPlayer].deck)
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
          estates=0,
          orchard=0,
          knights=0,
          uniques=0, --WolfDen
          deck={}}
        for _, obj in ipairs(getObjectFromGUID(ref.players[cp].deckZone).getObjects())do
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
          tracker.amount=tracker.amount+v
          if Use('LandGrant')then
            if tracker['PlayerDefined']==nil then
              tracker['PlayerDefined']=0 end
            if getType(i):find('PlayerDefined')then
              tracker['PlayerDefined']=tracker['PlayerDefined']+v end
          end
          if getType(i):find('Knight')then  tracker.knights=tracker.knights+v end
          if v==1 then                      tracker.uniques=tracker.uniques+1 end
        end
        -- Score Based on thier VP
        for k,v in pairs(tracker.deck)do
          local vp=getVP(k)
          if type(vp)=='function'then vp=vp(tracker,dT,cp)
          elseif k=='Curse'then log(vp)end
          
          if tracker.deck.Pyramid and getType(k):find('Victory')then
            vp=vp-tracker.deck.Pyramid
            if vp<0 then vp=0 end
          end
          vP[cp]=vP[cp] + vp*v
        end
        -- Score VP tokens
        if getObjectFromGUID(ref.players[cp].vp)then
          vP[cp]=vP[cp] + getObjectFromGUID(ref.players[cp].vp).call('getCount')
        end
        -- Landmarks
        for _,es in ipairs(ref.eventSlots)do
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
  startLuaCoroutine(self,'scoreCoroutine')
end
--Used in Button Callbacks
newText=setmetatable({type='3DText',position={},rotation={90,0,0}
    },{__call=function(t,p,text,f)
      t.position=p
      local o=spawnObject(t)
      o.TextTool.setValue(text)
      o.TextTool.setFontSize(f or 200)
      return o.getGUID()end})
function cScale(o)o.setScale({1.88,1,1.88})end
function rcs(a)return math.random(1,#ref.cardSets-(a or sL[sL.n][3]))end
function timerStart(t)click_StartGame(t[1],t[2])end
function findCard(trg,r,p)
  log(trg)
  for _,set in ipairs(r)do
    local deck=getObjectFromGUID(set.guid)
    if deck then
      for __,card in ipairs(deck.getObjects())do
        if card.name==trg then
          deck.takeObject({position=p,index=card.index,smooth=false,callback_function=cScale})
          break end end end end end
function kingdomList(str,par)
  local s=str
  if s:find('Shelters')then useShelters,s=1,s:gsub(',Shelters','')else useShelters=2 end
  if s:find('Platinum')then usePlatinum,s=1,s:gsub(',Platinum','')else usePlatinum=2 end
  local i=0
  for t in s:gmatch('[^,]+')do i=i+1
    if i==11 and s:find('Young Witch')then findCard(t,ref.cardSets,ref.baneSlot.pos)
    elseif i<11 then findCard(t,ref.cardSets,ref.kingdomSlots[i].pos)
    elseif t=='Summon'then getObjectFromGUID(ref.eventSets[#ref.eventSets-1].guid).setPosition(ref.eventSlots[i-10].pos)
    else local j=i-10
      if s:find('Young Witch')then j=j+1 end
      findCard(t,ref.eventSets,ref.eventSlots[j].pos)end end
  Timer.create({identifier='RW',function_name='timerStart',parameters=par,delay=2})
end
local Use=setmetatable({' ',' '},{__call=function(t,s)local _,n=t[1]:gsub(' '..s..' ',' '..s..' ');if n>0 then return n end return false end})
function Use.Add(n)
  local x,s,c=0,' ',n
  Use[2]=Use[2]..n..','
  log(n)
  if getCost(c):sub(-1)=='1'then s=s..'Potion 'end
  if getCost(c):match('M(%d+)') and tonumber(getCost(c):match('M(%d+)'))>6 then usePlatinum=1 end
  if not getCost(c):find('D0')and not getCost(c):find('DX')then s=s..'Debt 'end
  for _,t in pairs({'Looter','Reserve','Doom','Fate','Project','Gathering','Fame','Season','Spellcaster'})do if getType(c):find(t)then s=s..t..' 'end end
  for i,v in pairs(MasterData)do if c==v.name then x=i;if v.depend then s=s..v.depend..' 'end break end end
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
    for _,s in pairs(ref.cardSets)do
      if g==s.guid then l=l..s.name..'\n'
  break end end end
  self.editButton({index=8,label=l..'Start Game',height=790*(#useSets+2)+100})
  obj.editButton({font_color=a})
end
function click_AllSets(obj, color)useSets={}
    for i,set in ipairs(ref.cardSets)do if set.name~='Promos'then table.insert(useSets,set.guid)else break end end
    click_StartGame(obj, color)
end
function click_TwoSets(obj, color)useSets={}
    local n,m=rcs(),rcs()
    while m==n do m=rcs()end
    table.insert(useSets, ref.cardSets[n].guid)
    table.insert(useSets, ref.cardSets[m].guid)
    click_StartGame(obj, color)
end
function click_ThreeSets(obj, color)useSets={}
    local n,m,o=rcs(),rcs(),rcs()
    while m==n do m=rcs()end
    while o==m or o==n do o=rcs()end
    table.insert(useSets,ref.cardSets[n].guid)
    table.insert(useSets,ref.cardSets[m].guid)
    table.insert(useSets,ref.cardSets[o].guid)
    click_StartGame(obj, color)
end
function click_DualSets(o,c)balanceSets(2,o,c)end
function click_TripleSets(o,c)balanceSets(3,o,c)end
function click_FiveSets(o,c)balanceSets(5,o,c)end
function click_TenSets(o,c)balanceSets(10,o,c)end
function balanceSets(n,o,c)
  if #useSets>n then
    while #useSets>n do table.remove(useSets,math.random(1,#useSets))end
  elseif #useSets<n then
    local t={}
    for _,s in pairs(useSets)do for i,v in pairs(ref.cardSets)do
      if s==v.guid then table.insert(t,i)break end end end
    for i=#t+1,n do table.insert(t,rcs())
      for j,s in pairs(t)do if j==i then break end
        while s==t[i]do t[i]=rcs()
    end end end
    log(t)
    for i,n in pairs(t)do useSets[i]=ref.cardSets[n].guid end
  end
  
  for _,v in pairs(useSets)do getObjectFromGUID(v).shuffle()end
  
  local events={}
  for _,g in pairs(useSets)do for _,s in pairs(ref.cardSets)do if s.guid==g then
      if s.events then for _,v in pairs(s.events)do
      table.insert(events,ref.eventSets[v].guid)
      end end break end end end
  if #events==1 then for i=1,math.random(1,3)do
      table.insert(events,events[1])end
  elseif #events==2 then for i=1,2 do
      local j=i
      if getObjectFromGUID(events[i]).getName():find(' Ways')then j=(i%2)+1 end
      if getObjectFromGUID(events[j]).getName():find(' Ways')then break end
      table.insert(events,events[j])end
  elseif #events==3 then
    table.insert(events,events[math.random(1,3)])
  elseif #events>4 then
    while #events>4 do table.remove(events,math.random(1,#events))end
  end
  
  for _,v in pairs(events)do getObjectFromGUID(v).shuffle()end
  for i,v in pairs(ref.kingdomSlots)do
    getObjectFromGUID(useSets[(i%n)+1]).takeObject({
        position=v.pos,index=6-math.ceil(i/n),smooth=false,callback_function=cScale})end
  for i,v in pairs(events)do getObjectFromGUID(v).takeObject({position=ref.eventSlots[i].pos,index=2,smooth=false,callback_function=cScale})end
  click_StartGame(o,c)
end
function click_BasicGame(obj, color)
  bcast('Beginner Tutorial')
  newText({20,1,50},'THE GAME ENDS WHEN:\nAny 3 piles are empty or\nThe Province pile is empty.')
  newText({0,2,11},'On your turn you may play One ACTION.\nOnce you have finished playing actions you may play TREASURES.\nThen you may Buy One Card. ([i]Cards you play can change all these[/i])',100)
  local knd={
'Cellar,Festival,Mine,Moat,Patrol,Poacher,Smithy,Village,Witch,Workshop',
'Cellar,Market,Merchant,Militia,Mine,Moat,Remodel,Smithy,Village,Workshop',}
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
end
function click_RedditWeekly(obj, color)
  bcast('Reddit Weekly')
  
end
function click_forcePile(obj, color)
  local guid,c=obj.getGUID(),{1,1,1}
  if guid==ref.supplyPiles[1].guid then
    if usePlatinum<2 then
      usePlatinum=1+usePlatinum
      if usePlatinum==1 then c={0,1,0}else c={1,0,0}end
      obj.highlightOn(c)
    else
      usePlatinum=0
      obj.highlightOff()
    end
  elseif guid==ref.supplyPiles[5].guid then
    if useShelters<2 then
      useShelters=1+useShelters
      if useShelters==1 then c={0,1,0}else c={1,0,0}end
      obj.highlightOn(c)
    else
      useShelters=0
      obj.highlightOff()
    end
  elseif guid==ref.supplyPiles[6].guid then
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
function click_setLimit(obj)
  if sL.n<#sL then sL.n=sL.n+1 else sL.n=1 end
  obj.editButton{
    index=getButton(obj,'Included Sets:'),
    label='Included Sets:\n'..sL[sL.n][1],
    tooltip='Toggles which sets are allowed in Quick Setup.\n'..sL[sL.n][2]}
  
  
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
  for _,es in pairs(ref.eventSlots)do
    for _,v in pairs(getObjectFromGUID(es.zone).getObjects())do
      if v.getName()=='Summon'then
        summonException=true
        break end end end
  local requireBane=false
  local requireBlackMarket=false
  local cardCount=0
  for i in ipairs(ref.kingdomSlots)do
    local supplyZone=getObjectFromGUID(ref.kingdomSlots[i].zone)
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
  for i in ipairs(ref.cardSets)do
    local obj=getObjectFromGUID(ref.cardSets[i].guid)
    if obj then obj.clearButtons()end
  end
  local obj=getObjectFromGUID(ref.startButton)
  if obj then obj.clearButtons()end
  obj=getObjectFromGUID(ref.supplyPiles[1].guid)
  if obj then obj.clearButtons()end
  obj=getObjectFromGUID(ref.supplyPiles[5].guid)
  if obj then obj.clearButtons()end
end
-- Function to setup the Kingdom
function setupKingdom(summonException)
  -- first we delete all the not in use sets and group the remaining
  for i,cs in ipairs(ref.cardSets)do
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
          local o=getObjectFromGUID(ref.eventSets[n].guid)
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
    for _,es in ipairs(ref.eventSlots)do
        for j, v in ipairs(getObjectFromGUID(es.zone).getObjects())do
            if v.tag=='Card'then table.insert(events, v) end
        end
    end
    for i in ipairs(events)do events[i].setPosition(ref.eventSlots[i].pos) end
    eventCount=#events
    if deck then
      local w=0
        for _,ks in ipairs(ref.kingdomSlots)do
            card=false
            for j, v in ipairs(getObjectFromGUID(ks.zone).getObjects())do if v.tag=='Card'then card=true end end
            while not card do
              for j, v in pairs(deck.getObjects())do
                local tp=getType(v.name)
                if('EventLandmarkProjectWayEdictSpell'):find(tp)then
                  if eventCount < eventMax then
                    --local tp=getType(v.name) if tp=='Way'then if w==1 then break end w=w+1 end
                    eventCount=eventCount + 1
                    deck.takeObject({position=ref.eventSlots[eventCount].pos, index=v.index, callback='setCallback', callback_owner=self})
                    break end
                else
                  card=true
                  deck.takeObject({position=ks.pos, index=v.index, flip=true})
                  break end end end end
        wait(0.5,'skskcKingdom')
        local blackMarket, requireBane=false, false
        for _,ks in ipairs(ref.kingdomSlots)do
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
                local tp=getType(v.name)
                if('EventLandmarkProjectWayEdictSpell'):find(tp)then
                  coroutine.yield(0)
                  deck.takeObject({index=v.index}).destruct()
                  cleanDeck=false
                  break
                elseif('KnightsCastlesX Stallions'):find(v.nickname)or v.nickname:find(' / ')then
                  coroutine.yield(0)
                  local p=getPile(v.nickname..' pile')
                  p.takeObject({index=1,position={-75,2,0}})
                  coroutine.yield(0)
                  p.shuffle()
                  p.takeObject({index=1,position=deckAddPos,flip=true})
                  deck.takeObject({index=v.index}).destruct()
                  cleanDeck=false
                  break end end end
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
                    local tp=getType(card.name)
                    if('EventLandmarkProjectWayEdictSpell'):find(tp)then
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
                  local tp=getType(v.name)
                  if('EventLandmarkProjectWayEdictSpell'):find(tp)then
                    coroutine.yield(0)
                    deck.takeObject({index=v.index}).destruct()
                    cleanDeck=false
                    break
                  elseif('KnightsCastlesX Stallions'):find(v.nickname)or v.nickname:find(' / ')then
                    coroutine.yield(0)
                    local p=getPile(v.nickname..' pile')
                    p.takeObject({index=1,position={-75,2,0}})
                    coroutine.yield(0)
                    p.shuffle()
                    p.takeObject({index=1,position=deckAddPos,flip=true})
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
  startLuaCoroutine(self, 'setupKingdomCoroutine')
end
-- Callback to fix the event position
function setCallback(obj)obj.setRotation({0,90,0})end
-- Function to reorder the Kingdom
function reorderKingdom()
    --First create an array with all the card names plus the costs in it
    local sortedKingdom={}
    for _,ks in ipairs(ref.kingdomSlots)do
        for j, v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
            if v.tag=='Card'then
                table.insert(sortedKingdom, getCost(v.getName()) .. v.getName())
    end end end
    --Then sort the list
    table.sort(sortedKingdom)
    --Finally, set the positions based on the new order
    for i, v in ipairs(sortedKingdom)do
        sortedKingdom[i]=v:sub(7)
        for _,ks in pairs(ref.kingdomSlots)do
            for k, b in ipairs(getObjectFromGUID(ks.zone).getObjects())do
                if b.getName()==sortedKingdom[i] then
                    b.setPosition(ref.kingdomSlots[i].pos)
    end end end end
    --Do the same for events
    if eventCount > 0 then
        local sortedEvents={}
        for _,es in ipairs(ref.eventSlots)do
            for j, v in ipairs(getObjectFromGUID(es.zone).getObjects())do
                if v.tag=='Card'then
                    Use.Add(v.getName())
                    table.insert(sortedEvents, getCost(v.getName()) .. v.getName())
        end end end
        table.sort(sortedEvents)
        for i, v in ipairs(sortedEvents)do
            sortedEvents[i]=v:sub(7)
            for _,es in ipairs(ref.eventSlots)do
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
    getPile('Boulder Trap pile').setPosition(ref.basicSlots[5].pos)
    getPile('Ruins pile').setPosition(ref.basicSlots[11].pos)
    getObjectFromGUID(ref.basicSlots[6].guid).destruct()
    getObjectFromGUID(ref.basicSlots[12].guid).destruct()
  else getPile('Platinums').highlightOff()end
  
  local n=5+usePlatinum
  if Use('Looter')then useShelters=1 else
    getPile('Ruins pile').destruct()
    getObjectFromGUID(ref.basicSlots[n].guid).destruct()n=n+6
    getPile('Boulder Trap pile').setPosition(ref.basicSlots[n].pos)end
  if not Use('BT')then getPile('Boulder Trap pile').destruct()
    getObjectFromGUID(ref.basicSlots[n].guid).destruct()end
  if not Use('Potion')then getPile('Potions').destruct()
    getObjectFromGUID(ref.basicSlots[1].guid).destruct()
    getPile('Curses').setPosition(ref.basicSlots[7].pos)end
  
  if Use('Baker')then for i,obj in ipairs(getAllObjects())do if obj.getName()=='Coffers'then obj.call('baker')end end end
  if not Use('TradeRoute')then getObjectFromGUID(ref.tradeRoute).destruct()end
  if not Use('Bane')then for i,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do v.destruct()end end
  if not Use('BlackMarket')then for i,v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do v.destruct()end end
  if not Use('Zombie')then getPile('Zombies').destruct()end
  if not Use('Embargo')then getObjectFromGUID('7c2165').destruct()end
  
  for i in ipairs(ref.replacementPiles)do
    local obj=getObjectFromGUID(ref.replacementPiles[i].guid)
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
  f(Use('XHeir'),'Heir')
  f(Use('XLessor'),'Bogus Lands')
  f(Use('LTown'),'Road')
  f(Use('LNecromancerLegacy'),'Zombie Legacy')
  f(Use('LDelegate'),'Loyal Subjects')
  f(Use('LDelegate'),'Loyal Subjects')
  f(Use('WGhostlyWitch'),'W Ethereal Curse')
  f(Use('WMiserlyWitch'),'W Cursed Copper')
  f(Use('WPoisonousWitch'),'W Cursed Beverage')
  f(Use('WFaustianWitch'),'W Cursed Bargain')
  f(Use('TBattalion'),'T Broken Sword')
  f(Use('TCharlatan'),'T Cursed Antique')
  f(Use('CCabal'),'Turncoat')
  f(Use('CJekyll'),'Hyde')
  f(Use('Spellcaster'),'Spellcasters Spells')
  
  local dC,eC=1,0
  if Use('Druid')then dC=dC+3 end
  if Use('XHandler')then dC=dC+3 end
  if Use('Spellcaster')then eC=eC+2 end
  for i,v in ipairs(sideSlots)do
    local obj=getPile(v..' pile')
    obj.setPosition(ref.sideSlots[i].pos)
    obj.setLock(false)end
  local x=0
  if #sideSlots~=0 then
    x=getObjectFromGUID(ref.sideSlots[#sideSlots].guid).getPosition()[1]-6.25 end
  for i=#sideSlots+1,#ref.sideSlots do
    local obj=getObjectFromGUID(ref.sideSlots[i].guid)
    if i<#sideSlots+dC then
      obj.setRotation({0,270,0})
      obj.setPosition({x,1.2,13.5+(i-#sideSlots)*4.5})
    else
      obj.destruct()
    end end
  
  getObjectFromGUID(ref.storageZone.fog).destruct()
  
  for i,es in ipairs(ref.eventSlots)do
    local obj=getObjectFromGUID(es.guid)
    if i>eventCount+eC then obj.destruct()end
  end
  
  local temp={
--Tracker
VP='Victory Points',
Debt='Debt Tokens',
Coffers='Coffers',
Villager='Villagers',
PirateShip='Pirate Ship Coins',
--Zones
Fame='Feat Mat',
Aside='Set Aside',
Exile='Exile Mat',
Island='Island Mat',
Season='Season Mat',
Reserve='Tavern Mat',
TradeRoute='Trade Route Mat',
BlackMarket='Black Market Mat',
NativeVillage='Native Village Mat',
--Tokens
TwoCost='-2 Cost Token',
PlusBuy='+1 Buy Token',
PlusCoin='+1 Coin Token',
PlusCard='+1 Card Token',
PlusAction='+1 Action Token',
MinusCoin='-1 Coin Token',
MinusCard='-1 Card Token',
Trashing='Trashing Token',
Estate='Estate Token',
Journey='Journey Token',
Project='Owns Project',
Spellcaster='Spell Tokens'}
  for k,v in pairs(temp)do if Use(k)then temp[k]=nil end end
  for _,obj in pairs(getAllObjects())do
    for k,v in pairs(temp)do
      if obj.getName()==v or obj.getName()=='Rules '..k then
        obj.destruct()
  end end end
  getObjectFromGUID(ref.Board).destruct()
  local toRemove={}
  if getPlayerCount()~=6 then
    for i in pairs(ref.players)do
      local found=false
      for j=1,#getSeatedPlayers()do
        local currentPlayer=getSeatedPlayers()[j]
        if currentPlayer==i and Player[currentPlayer].getHandCount()>0 then
          found=true
      end end
      if not found then
        table.insert(toRemove,i)
  end end end
  for i,v in pairs(toRemove)do for j,o in ipairs(getObjectFromGUID(ref.players[v].zone).getObjects())do if o.getName()~='Board'then o.destruct()end end end
  function tokenCoroutine()
    wait(4,'cutcSetup')
    log(Use[1])
    if Use('Landmark')or Use('Gathering')or Use('TradeRoute')or Use('Tax')or Use('C Panda / Gardener')then
      obeliskPiles={}
      local function slot(z)
        for __,obj in ipairs(getObjectFromGUID(z).getObjects())do
          if obj.tag=='Deck'then
            getSetup('Tax')(obj)
            getSetup('Obelisk')(obj)
            getSetup('Aqueduct')(obj)
            getSetup('Trade Route')(obj)
            getSetup('Defiled Shrine')(obj)
            getSetup('C Panda / Gardener')(obj)
            if getType(obj.getObjects()[obj.getQuantity()].name):find('Gathering')then tokenMake(obj,'vp')end
            break end end end
      for _,v in ipairs(ref.basicSlots)do slot(v.zone)end
      for _,v in ipairs(ref.kingdomSlots)do slot(v.zone)end
      slot(ref.baneSlot.zone)
      
      for __,v in ipairs(ref.eventSlots)do
        for _,obj in ipairs(getObjectFromGUID(v.zone).getObjects())do
          if obj.tag=='Card'then
            if('AqueductDefiled Shrine'):find(obj.getName())then tokenMake(obj,'vp',0)end
            if('ArenaBasilicaBathsBattlefieldColonnadeLabyrinth'):find(obj.getName())then
              tokenMake(obj,'vp',getPlayerCount()*6)end
            if obj.getName()=='Obelisk'then
                local k=math.random(1,#obeliskPiles)
                obj.highlightOn({1,0,1})
                obeliskPiles[k].highlightOn({1,0,1})
                obeliskTarget=obeliskPiles[k].getName():sub(1,-6)
                obj.setDescription('[b]TARGET:[/b] '..obeliskTarget)
                obeliskPiles =nil
            end break
    end end end end
    if Use('BlackMarket')then
      local deckBM=false
      for i, v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do if v.tag=='Deck'then deckBM=v end end
      pos=deckBM.getPosition()local g=0
      for i,card in ipairs(deckBM.getObjects())do
        if getType(card.name):find('Gathering')then g=g+1
          if     g==1 then tokenMake(deckBM,'vp',0,nil,card.nickname)
          elseif g==2 then tokenMake(deckBM,'vp',0,{0.9,1,-1.25},card.nickname)
          else   tokenMake(deckBM,'vp',0,{-0.9,1,-1.25},card.nickname)
    end end end end
    wait(1,'cutcDelete')
    for _,v in pairs(ref.tokenBag)do getObjectFromGUID(v).destruct()end
    if getPile('Heirlooms')then getPile('Heirlooms').destruct()end
    return 1
  end
  startLuaCoroutine(self, 'tokenCoroutine')
  if useShelters~=1 and getPile('Shelters')then
    getPile('Shelters').destruct()
    setupBaseCardCount(false, false)
  else
    setupBaseCardCount(true, false)
  end
end
function createHeirlooms(c)
  for n,h in pairs({['Secret Cave']='Magic Lamp',['Cemetery']='Haunted Mirror',['Shepherd']='Pasture',['Tracker']='Pouch',['Pooka']='Cursed Gold',['Pixie']='Goat',['Fool']='Lucky Coin',['C Magician']='Rabbit',['C Jinxed Jewel']='Jinxed Jewel',['C Burned Village']='Rescuers'})do
    if c==n then getPile('Heirlooms').takeObject({position=getObjectFromGUID(ref.storageZone.heirloom).getPosition(),guid=ref.heirlooms[h],flip=true})break end end end
function placePile(v,p)local l=getPile(v.getName()..' pile');l.setPosition(p)v.destruct()return l end
function makePile(v,p)local k,n=1,10--Card Kount
  --If we have a victory card and 2 players, we make 8 copies
  if getPlayerCount()==2 and(getType(v.getName()):find('Victory')or v.getName()=='Dig')then n=8
  --If we have a victory card or the card is Port, we make 12 copies
  elseif('PortDig'):find(v.getName())or getType(v.getName()):find('Victory')then n=12
  elseif('Rats'):find(v.getName())then n=20 end
  if v.getName()=='Castles'then local l=placePile(v,p)
    if getPlayerCount()==2 then
      for _,n in pairs({'Humble Castle','Small Castle','Opulent Castle','King\'s Castle'})do
        for l,c in ipairs(l.getObjects())do
          if card.nickname==n then l.takeObject({index=c.index}).destruct()
            break end end end end end
  --If we have Knights, we swap in the Knights pile
  elseif v.getName()=='Knights'then placePile(v,p).shuffle()
  elseif v.getName()=='X Stallions'then placePile(v,p)
  elseif v.getName():find(' / ')then placePile(v,p)
  --All other cards get 10 copies
  else while k<n do v.clone({position=ks.pos})k=k+1
end end
function createPile()
  for _,ks in pairs(ref.kingdomSlots)do
    for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
      if v.tag=='Card'then makePile(v,ks.pos)
  end end end
  local removeBane=true
  for i,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
    if v.tag=='Card'then makePile(v,ref.baneSlot.pos)removeBane=false
  end end
  --Coroutine names the piles after they form
  function createPileCoroutine()wait(2,'cpcNames')
    if getPile('Heirlooms')then getPile('Heirlooms').destruct()end
    for _,ks in pairs(ref.kingdomSlots)do
      for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
        if v.tag=='Deck'and v.getName():sub(-5)~=' pile'then
            v.setName(v.takeObject({position=v.getPosition()}).getName()..' pile')
    end end end
    if not removeBane then
      for _,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
        if v.tag=='Deck'and v.getName():sub(-5)~=' pile'then
            v.setName(v.takeObject({position=v.getPosition()}).getName()..' pile')
    end end end cleanUp()return 1
  end startLuaCoroutine(self, 'createPileCoroutine')end
function NO()end
function getVP(n)if Victory[n]then return Victory[n]end for _,v in pairs(MasterData)do if n==v.name then return v.VP or 0 end end end
function getCost(n)for _,v in pairs(MasterData)do if n==v.name then return v.cost end end return'M0D0P0'end
function getType(n)for _,v in pairs(MasterData)do if n==v.name then return v.type end end return'Event'end
function getSetup(n)if Use(n:gsub(' ',''))then for _,v in pairs(MasterData)do if n==v.name then if v.setup then return v.setup end end end end return NO end
function getPile(pileName)for i,k in pairs({'replacementPiles','supplyPiles','sidePiles'})do for _,p in pairs(ref[k])do if pileName==p.name then return getObjectFromGUID(p.guid)end end end end
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
  local c,z,h=1,getObjectFromGUID(ref.storageZone.heirloom).getObjects(),false
  for _,obj in pairs(z)do if obj.tag=='Deck'then c,h=1+obj.getQuantity(),obj elseif obj.tag=='Card'then c,h=2,obj end end
  --Creating the starting decks
  --if Use('Delegate')then getPile('Loyal Subjects pile').takeObject()
  for i=1,#getSeatedPlayers()do
    local p=getSeatedPlayers()[i]
    if 0<Player[p].getHandCount()then
      if h then h.clone({position=ref.players[p].deck})end
      for j=c,7 do getPile('Coppers').takeObject({position=ref.players[p].deck,flip=true})end
      if useShelters and getPile('Shelters')then
        getPile('Shelters').clone({position=ref.players[p].deck,rotation={0,180,180}})
      else for j=1,3 do getPile('Estates').takeObject({position=ref.players[p].deck,flip=true})
  end end end end
  if useShelters and getPile('Shelters')then getPile('Shelters').destruct()end
  dealStartingHands()
end
-- Function to deal starting hands
function dealStartingHands()
  function dealStartingHandsCoroutine()
    wait(2,'dshcShuffle')
    for i, v in pairs(ref.players)do
      for j, b in pairs(getObjectFromGUID(v.deckZone).getObjects())do
        if b.tag=='Deck'then
          b.shuffle()
        end
      end
    end
    wait(0.5,'dshcDeal')
    for i, v in pairs(ref.players)do
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
  startLuaCoroutine(self, 'dealStartingHandsCoroutine')
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
  local t={position=p,rotation={0,180,0},callback='tokenCallback',callback_owner=self,params={name or obj.getName(),n or 0}}
  log(t.params)
  if not n then t.callback=nil end
  getObjectFromGUID(ref.tokenBag[key]).takeObject(t)
end
--Function to set uninteractible objects
function setUninteractible(t)
  for _,o in pairs(getAllObjects())do
    local n=o.getName()
    if('CardDeck'):find(o.tag)then
      local f=false
      for j,k in pairs({'replacementPiles','supplyPiles','eventSets','sidePiles','cardSets'})do
        if not f then for i,c in ipairs(ref[k])do if n==c.name then f,ref[k][i].guid=true,o.getGUID()break end end end end
      if gameState==1 and not f then o.highlightOn({1,0,0.5})print(n)end
    else local p=o.getPosition();p={p[1],1.3,p[3]}
      --if o.getGMNotes():find('side')then ref.sideSlots[o.getGMNotes():match('%d+')]={guid=o.getGUID()}end
      for j,c in pairs({'basicSlots','eventSlots','kingdomSlots'})do
      for k,r in pairs(ref[c])do if o.getGUID()==ref[c][k].guid then ref[c][k].pos=p end end end
      
      o.setLock(true)
      if n==''then
        o.interactable=false
  end end end
  --[[addNotebookTab({title='Slots',body=JSON.encode(JSON.decode(JSON.encode(ref.sideSlots)))})
  for k,v in pairs(ref)do
    if v[1]and v[1].name then
      for i,t in ipairs(v)do
        if not t.guid then
          print('No GUID found for '..t.name)
        end
      end
    end
  end]]
end
function dv(t,s,d)local a=0;for c,n in pairs(t)do if getType(c):find(s)then a=d and a+1 or a+n end end return a end
--VP Functions
Victory={
Gardens      =function(t)return math.floor(t.amount/10)end,
Duke         =function(t)return t.deck['Duchy']or 0 end,
Vineyard     =function(t)return math.floor(dv(t,'Action')/3)end,
Fairgrounds  =function(t)return 2*math.floor(#t.deck/5)end,
['Silk Road']=function(t)return 2*math.floor(dv(t,'Victory')/4)end,
Feodum       =function(t)return 3*math.floor((t.deck.Silver or 0)/4)end,
['Humble Castle']=function(t)return dv(t,'Castles')end,
['King\'s Castle']=function(t)return 2*dv(t,'Castles')end,
--Landmarks
['Bandit Fort']=function(t)return -((t.deck.Silver or 0)+(t.deck.Gold or 0))*2 end,
Fountain=function(t)if t.deck.Copper>9 then return 15 end return 0 end,
Keep=function(t,dT,cp)local v=0;for c,n in pairs(t.deck)do if getType(c):find('Treasure')then local w=true;for o,d in pairs(dT)do if o~=cp and d and d[c] and d[c]>n then w=false;end end end if w then v=v+5 end end end,
Museum=function(t)return #t.deck*2 end,
Obelisk=function(t)if obeliskTarget=='Knights'then return t.knights*2 elseif obeliskTarget then return(t.deck[obeliskTarget]or 0)*2 end return 0 end,setup=function(o)if getType(o.getObjects()[o.getQuantity()].name):find('Action')then table.insert(obeliskPiles,o)end end,
Orchard=function(t)local v=0;for c,n in pairs(t)do if getType(c):find('Action')then if n>2 then v=v+4 end end return v end,
Palace=function(t)return 3*math.min(t.deck.Copper or 0, t.deck.Silver or 0, t.deck.Gold or 0)end,
Tower=function(t)local vp,ne,zs,f=0,{},{},false;for _,g in ipairs(ref.basicSlotzs)do table.insert(zs,getObjectFromGUID(g))end table.insert(zs,getObjectFromGUID(ref.baneSlot.zone))for _,s in ipairs(ref.kingdomSlots)do table.insert(zs,getObjectFromGUID(s.zone))end for _,z in ipairs(zs)do for __,o in ipairs(z.getObjects())do if o.tag=='Card'and o.getName()~='Bane Card'then if getType(o.getName()):find('Knight')==nil then table.insert(ne,o.getName())else table.insert(ne,'Knights')end elseif o.tag=='Deck'then table.insert(ne,o.getName():sub(1,-6))end end end for c,n in pairs(t.deck)do for _,p in ipairs(ne)do if p==c then f=true;end end if getType(c):find('Knight')then for _,p in ipairs(ne)do if p=='Knights'then f=true end end end for _,bmCard in ipairs(bmDeck)do if c==bmCard then f=true end end--[[self Blackmarket Var]]if getType(c):find('Victory')==nil and not f then vp=vp+n end end return vp end,
['Triumphal Arch']=function(t)local h,s=0,0;for c,n in pairs(t.deck)do if getType(c):find('Action')then if n>h then s=h;h=n elseif n>s then s=n end end end return s*3 end,
Wall=function(t)return -(t.amount-15)end,
['Wolf Den']=function(t)log(t)return -t.wolf*3 end,
--Nocturn
Pasture=function(t)return t.estates*1 end,
--Customs
['X Arabian Horse']=function(t)if t.deck['Arabian Horse']==1 then return t.deck.Horse or 0 else return 0 end end,
['R Shire']=function(t)local vp,ne,zs,f=0,{},{},false;table.insert(zs,getObjectFromGUID(ref.baneSlot.zone))
    for _,g in ipairs(ref.basicSlotzs)do table.insert(zs,getObjectFromGUID(g))end
    for _,s in ipairs(ref.kingdomSlots)do table.insert(zs,getObjectFromGUID(s.zone))end
    for _,z in ipairs(zs)do for __,o in ipairs(z.getObjects())do
      if o.tag=='Card'then if getType(o.getName()):find('Knight')then table.insert(ne,'Knights')else table.insert(ne,o.getName())end
      elseif o.tag=='Deck'then table.insert(ne,o.getName():sub(1,-6))end end end
    for c,n in pairs(t.deck)do
      for _,p in ipairs(ne)do if p==c then f=true end end
      if getType(c):find('Knight')then for _,p in ipairs(ne)do if p=='Knights'then f=true end end end
      for _,bmCard in ipairs(bmDeck)do if c==bmCard then f=true end end--[[Blackmarket]]
      if not f then vp=vp+n end end return vp end,
['V Acreage']=function(t)return 0 end,
['V Barony']=function(t)return 2*(dv(t,'Treasure')+dv(t,'Victory'))end,
['V Bishopric']=function(t)printToAll('Bishopric Needs Manual Count.')return 0 end,
['V County']=function(t)return 0 end,
['V Domain']=function(t)return 3*math.min(t.deck.Province or 0,t.deck.Duchy or 0,t.deck.Estate or 0)end,
['V Gold Mine']=function(t)return(t.deck.Gold or 0)end,
['V Grange']=function(t)--[[1Per action card you have from an empty supply pile]]return 0 end,
['V Yards']=function(t)return math.floor(t.amount/3)end,
['C Tulip Field']=function(t,dT,cp)end
}
Setup={
['Trade Route']=function(o)if getType(o.getObjects()[1].name):find('Victory')and not getType(o.getObjects()[1].name):find('Knight')then tokenMake(o,'coin')end end,
Tax=function(o)tokenMake(o,'debt',1)end,
Aqueduct=function(o)local n=o.getName()if n=='Golds'or n=='Silvers'then tokenMake(o,'vp',8)end end,
['Defiled Shrine']=function(o)local t=getType(o.getObjects()[1].name);if t:find('Action')and not t:find('Gathering')then tokenMake(o,'vp',2)end end,
['Way of the Mouse']=function(o)end,
['C Panda / Gardener']=function(o)if getType(o.getObjects()[1].name):find('Action')then tokenMake(o,'coin')tokenMake(o,'coin')end end,
}