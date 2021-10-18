--DominionDefinitiveEditionModifiedByAmuzet2021_06_04_n
VERSION,GITURL=2.9,'https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Dominion/Definitive.lua'
--[[
Turn Tracker display the amount of turns
Rules in the Empty area
Expansion Description
Description of what the buttons do
Display what expansions are being used Above the Table
Output Kingdom Set
Custom Card Importer
Change Balance StartGame to fill the kingdom before making randomizer]]
function onSave()
  saved_data=JSON.encode({
    gs=gameState,
    emax=eventMax,
    bmax=blackMarketMax,
    smax=setsMax,
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
  objButton=getObjectFromGUID(ref.startButton)
  if objButton==self then return end
  WebRequest.get(GITURL,function(wr)
    local v=wr.text:match('VERSION,GITURL=(%d+%p?%d+)')
    if v then v=tonumber(v)
      if v<VERSION then     bcast('Oh look at you with a Testing Version\nPlease Report any bugs to Amuzet.',{0,1,1})
      elseif v>VERSION then bcast('There is an UPDATE!\nAttempting Update.\nThe Code will be pasted onto the Invisible block above the Ducy pile.\nCopy and paste its script over Global.\nIf this does not work, find the discord.',{1,1,0})objButton.setLuaScript(wr.text)objButton.reload()
      else                  bcast('Up to Date!\nHave a nice time playing.',{0,1,0})end
    else bcast('Problems have occured! Attempt to contact Amuzet on TTSClub',{1,0,0.2})end end)
  sL={n=1,
  {'Official Sets','Currently only official sets are allowed.\nThis excludes first printings, promos and fan expansions.',14},
  {'Printed Cards','Currently only printed cards are allowed.\nThis excludes fan expansions.',14},
  {'Expansions','Currently only expansions are allowed.\nThis excludes promo and cut cards, Adamabrams, Xtras and Witches.',22},
  {'Everyting','Currently cards from any set are allowed.\nThis excludes Duplicate/Outdated cards.',#ref.cardSets-2}}
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
    setsMax=loaded_data.smax or 3
    sL.n=loaded_data.sl or 1
  else
    gameState=1
    eventMax=4
    setsMax=3
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
      if o.getName()=='Victory Points'then  ref.players[k].vp=o.getGUID()
      elseif o.getName()=='Debt Tokens'then ref.players[k].debt=o.getGUID()
      elseif o.getName()=='Coffers'then     ref.players[k].coin=o.getGUID()
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
    if objButton then
      local put=setmetatable({d=-1.5,function_owner=self,position={0,0,-28},rotation={0,180,0},scale={0.6,1,0.6},font_size=1000,height=1030,width=8000,font_color={1,1,1},color={0,0,0}},
        {__call=function(u,v,l,f,p)u.value,u.position,u.tooltip,u.input_function=v,p or {u.position[1],u.position[2],u.position[3]+u.d},l,f or'put_'..v:gsub(':.*',''):gsub('%s','')
            objButton.createInput(u)end})
      put('Sets In Randomizer: '..setsMax,'The amount of sets that will be included in the randomizer')
      put('Event Cards To Use: '..eventMax,'The amount of Event type cards that will be used')
      put('Black Market Cards: '..blackMarketMax,'The amount of cards that will be used for Black Market card on top of Promos\n10 Card Minimum; Card Maximum based on 20 cards per set, minus 10.')
      put.d=-3
      put.scale={0.7,1,0.7}
      put.height=2000
      local btn=setmetatable(put,
        {__call=function(b,l,t,p,f)b.position,b.label,b.tooltip=p or {b.position[1],b.position[2],b.position[3]+b.d},l,t or''
            if f then b.click_function=f else b.click_function='click_'..l:gsub('\n.*',''):gsub('%s','')end objButton.createButton(b)end})
      btn('Include In Randomizer\nOfficial Expansions','These sets are all official expansions made by Donald X V of Rio Grande Games')
      put.width=5750
      btn('Balanced Setup','Random Kingdom made with a card from each selected sets')
      btn('Tutorial Game','Kingdoms Known to be easy to introduce to new players.')
      btn('All Sets\nQuick Setup','Just Play')
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
function click_ContactAmuzet()bcast('[b]Discord[/b]\nAmuzet#3078',{1,1,1})end
function createEndButton()
  local obj=getObjectFromGUID(ref.startButton)
  if obj then
    obj.createInput({value=Use[2],alignment=3,tooltip='Cards used in this Kingdom',input_function='input_kingdomOutput',function_owner=self,position={0,2,1},rotation={0,180,0},scale={0.6,1,0.6},font_size=1000,height=1030,width=80000,font_color={1,1,1},color={0,0,0}})
    obj.createButton({label='End Game',click_function='click_endGame',function_owner=self,position={-60,0,-4},rotation={0,180,0},height=1500,width=4000,font_size=9000})
end end
function input_kingdomOutput(o,c,i,s)
  if not s then o.editInput({index=0,value=Use[2]})
end end
function click_endGame(o,c)
  if not Player[c].admin then
    bcast('Only the host and promoted players can end the game.', {0.75,0.75,0.75}, c)
  return end
  setNotes('[40e0d0][b][u]Final Scores:[/b][/u][FFFFFF]\n')
  local obj=getObjectFromGUID(ref.startButton)
  if obj then obj.clearButtons()end
  gameState=4
  startLuaCoroutine(self,'scoreCoroutine')
end
local dT={Red={},White={},Orange={},Green={},Yellow={},Blue={}}
local vP={Red=0,White=0,Orange=0,Green=0,Yellow=0,Blue=0}
function scoreCoroutine()
  wait(2,'cegscClean')
  for ___,currentPlayer in pairs(getSeatedPlayers())do
    --ERROR UNKOWN past this point!
    if Player[currentPlayer].getHandCount()>0 then
      vP[currentPlayer],dT[currentPlayer]=0,{}
      
      for i, obj in ipairs(gObjs('tavern'))do
        if obj.type=='Deck'then
          for j, card in ipairs(obj.getObjects())do
            if card.nickname=='Distant Lands'then
              vP[currentPlayer]=vP[currentPlayer]+4
        end end end
        if obj.type=='Card'then
          if obj.getName()=='Distant Lands'then
            vP[currentPlayer]=vP[currentPlayer]+4
      end end end
      
      for __,zone in pairs({Player[currentPlayer].getHandObjects(),
          getObjectFromGUID(ref.players[currentPlayer].zone).getObjects()})do
        for _,obj in pairs(zone)do
          if obj.type=='Card'and obj.getName()=='Miserable / Twice Miserable'then
            vP[currentPlayer]=vP[currentPlayer]-2
            obj.setPosition({0,2,0})
            local rot=obj.getRotation()
            if 90<rot.z and rot.z<270 then
              vP[currentPlayer]=vP[currentPlayer]-2
              bcast(currentPlayer..' is Twice Miserable',{1,0,1})
            else bcast(currentPlayer..' is Miserable',{1,0,1})end
          elseif obj.type=='Card'or obj.type=='Deck'then
            local t=getType(obj.getName())
            if t and('LandmarkBoonHexStateArtifactProject'):find(t)then else
              obj.setRotation({0,180,180})
              obj.setPosition(ref.players[currentPlayer].deck)
              --coroutine.yield(0)
              end end end end
      --coroutine.yield(0)
  end end
  wait(2,'cegscScore')
  local totalCards={}
  for ___,cp in pairs(getSeatedPlayers())do
    if Player[cp].getHandCount() > 0 then
      local tracker={
        amount =0,
        actions=0,
        estates=0,
        orchard=0,
        knights=0,
        uniques=0, --WolfDen
        deck={}}
      for __,obj in pairs(getObjectFromGUID(ref.players[cp].deckZone).getObjects())do
        if obj.type=='Deck'then
          for _,v in pairs(obj.getObjects())do
            if dT[cp][v.nickname]then
              dT[cp][v.nickname]=1+dT[cp][v.nickname]
            else
              dT[cp][v.nickname]=1
        end end end
        if obj.type=='Card'then
          if dT[cp][obj.getName()]then
            dT[cp][obj.getName()]=1+dT[cp][obj.getName()]
          else
            dT[cp][obj.getName()]=1
      end end end
      tracker.deck=dT[cp]
      for i,v in pairs(tracker.deck)do
        tracker.amount=tracker.amount+v
        if getType(i):find('Knight')then tracker.knights=tracker.knights+v end
        if v==1 then                     tracker.uniques=tracker.uniques+1 end
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
          if obj2.type=='Card'then
            local vp=getVP(obj2.getName())
            if type(vp)=='function'then vP[cp]=vP[cp]+vp(tracker,dT,cp)end end end end
      --VictoryDisplay
      local clr=Color[cp]:lerp(Color.Grey,0.5)
      local pos={getObjectFromGUID(ref.players[currentPlayer].zone).getPosition()[1],1,-8}
      getObjectFromGUID(newText(pos,vP[cp])).setColorTint(clr)
      for i,v in pairs(pos)do pos[i]=v-0.05 end
      getObjectFromGUID(newText(pos,vP[cp])).setColorTint(Color.Black)
      setNotes(getNotes()..'\n'..cp..' VP: '..vP[cp])
      for card,count in pairs(dT[cp])do
        local s=count
        if count>9 then s='0'..count end
        --printToAll(s..count..' '..card,{1,1,1})
        if not totalCards[card]then totalCards[card]={[cp]=s}
        else totalCards[card][cp]=s end
      end
  end end
  printToAll('## ## :Card Name')
  for name,amount in pairs(totalCards)do
    local n=':'..name
    for _,c in pairs(getSeatedPlayers())do
      n=Color[c]:toHex(false)..amount..'[-] '..n end
    printToAll(n)
  end
  return 1
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
function rcs(a)return math.random(1,a or sL[sL.n][3])end
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
  if Use(n:gsub(' ',''))then return end
  local x,s,c=0,' ',n
  Use[2]=Use[2]..n..','
  log(n)
  if getCost(c):sub(-1)=='1'then s=s..'Potion 'end
  if getCost(c):match('M(%d+)') and tonumber(getCost(c):match('M(%d+)'))>6 then usePlatinum=1 end
  if not getCost(c):find('DX')then
    local d=tonumber(getCost(c):match('D(%d+)'))
    if d>0 then s=s..'Debt 'end end
  for _,t in pairs({'Looter','Reserve','Doom','Fate','Project','Gathering','Fame','Season','Spellcaster'})do if getType(c):find(t)then s=s..t..' 'end end
  for i,v in pairs(MasterData)do if c==v.name then x=i;if v.depend then s=s..v.depend..' 'end break end end
  if 100<x and x<126 then s=s..'Platinum 'elseif 175<x and x<225 then s=s..'Shelters 'end
  createHeirlooms(c)
  log(s)
  Use[1]=Use[1]..c:gsub(' ','')..s
end
--Input Callbacks
function put_SetsInRandomizer(o,c,i,s)if not s then
  setsMax=tonumber(i:match('%d+'))
  if setsMax>15 then setsMax=15 end
  Wait.time(function()objButton.editInput({index=0,value='Sets In Randomizer: '..setsMax})end,0.1)
end end
function put_EventCardsToUse(o,c,i,s)if not s then
  eventMax=tonumber(i:match('%d+'))
  if eventMax>4 then eventMax=4 end
  Wait.time(function()objButton.editInput({index=1,value='Event Cards To Use: '..eventMax})end,0.1)
end end
function put_BlackMarketCards(o,c,i,s)if not s then
  blackMarketMax=tonumber(i:match('%d+'))
  local d=(setsMax*20)-10
  if blackMarketMax>d then blackMarketMax=d
  elseif blackMarketMax<10 then blackMarketMax=10 end
  Wait.time(function()objButton.editInput({index=2,value='Black Market Cards: '..blackMarketMax})end,0.1)
end end
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
  obj.editButton({font_color=a})
end
function click_AllSets(obj, color)useSets={}
  for i,set in ipairs(ref.cardSets)do
    
    if i<sL[sL.n][3] then table.insert(useSets,set.guid)
    else break end end
  click_StartGame(obj, color)
end
function click_BalancedSetup(o,c)balanceSets(setsMax,o,c)end
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
    for i,j in pairs(t)do useSets[i]=ref.cardSets[j].guid end
  end
  
  for _,v in pairs(useSets)do getObjectFromGUID(v).shuffle()end
  
  local events={}
  for _,g in pairs(useSets)do for _,s in pairs(ref.cardSets)do if s.guid==g then
      if s.events then for _,v in pairs(s.events)do
      table.insert(events,ref.eventSets[v].guid)
    end end break end end end
  while #events>eventMax do table.remove(events,math.random(1,#events))end
  for i=#events,eventMax do
    local r=math.random(1,#events)
    while getObjectFromGUID(events[r]).getName():find(' Ways')do
      r=math.random(1,#events)end
    table.insert(events,events[r])end
  
  for _,v in pairs(events)do getObjectFromGUID(v).shuffle()end
  for i,v in pairs(ref.kingdomSlots)do
    if #getObjectFromGUID(v.zone).getObjects()==1 then
    getObjectFromGUID(useSets[(i%n)+1]).takeObject({
        position=v.pos,index=6-math.ceil(i/n),smooth=false,callback_function=cScale})end end
  for i,v in pairs(events)do
    local g=ref.eventSlots[i]
    if #getObjectFromGUID(g.zone).getObjects()==1 then
    getObjectFromGUID(v).takeObject({
        position=g.pos,index=2,smooth=false,callback_function=cScale})end end
  click_StartGame(o,c)
end
function click_TutorialGame(obj, color)
  bcast('Beginner Tutorial')
  newText({20,1,50},'THE GAME ENDS WHEN:\nAny 3 piles are empty or\nThe Province pile is empty.')
  newText({0,2,11},'On your turn you may play One ACTION.\nOnce you have finished playing actions you may play TREASURES.\nThen you may Buy One Card. ([i]Cards you play can change all these[/i])',100)
  local knd={
'Cellar,Festival,Mine,Moat,Patrol,Poacher,Smithy,Village,Witch,Workshop',
'Cellar,Market,Merchant,Militia,Mine,Moat,Remodel,Smithy,Village,Workshop',
'Cellar,Festival,Library,Sentry,Vassal,Courtier,Diplomat,Minion,Nobles,Pawn',
'Artisan,Council Room,Market,Militia,Workshop,Bridge,Mill,Mining Village,Patrol,Shanty Town',
'Lurker,Village,Swindler,Throne Room,Remodel,Diplomat,Mine,Replace,Bandit,Harem',
'Cellar,Village,Bureaucrat,Monument,Gardens,Contraband,Counting House,Mountebank,Artisan,Hoard',
'Baron,Courtier,Duke,Harem,Ironworks,Masquerade,Mill,Nobles,Patrol,Replace',
'Conspirator,Ironworks,Lurker,Pawn,Mining Village,Secret Passage,Steward,Swindler,Torturer,Trading Post',
'Hamlet,Merchant,Fortune Teller,Poacher,Throne Room,Bureaucrat,Remake,Laboratory,Jester,Horn of Plenty',
'Workshop,Remodel,Farming Village,Young Witch,Horse Traders,Jester,Market,Laboratory,Artisan,Fairgrounds,Merchant',
'Fool\'s Gold,Crossroads,Vassal,Oracle,Spice Merchant,Remodel,Laboratory,Festival,Sentry,Farmland',
'Squire,Rats,Remodel,Scavenger,Gardens,Knights,Laboratory,Festival,Library,Altar,Shelters',
'Black Cat,Displace,Sanctuary,Scrap,Snowy Village,Bandit,Gardens,Harbinger,Merchant,Moat,Way of the Mole,Toil'}
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
function click_IncludeInRandomizer(obj)
  if sL.n<#sL then sL.n=sL.n+1 else sL.n=1 end
  obj.editButton{
    index=getButton(obj,'Include In Randomizer'),
    label='Include In Randomizer\n'..sL[sL.n][1],
    tooltip='Toggles sets allowed In Randomizer.\n'..sL[sL.n][2]}
end
--function called when you click to start the game
function click_StartGame(obj, color)
  if not Player[color].admin then
    bcast('Only the host and promoted players can start the game.',{0.75,0.75,0.75},color)return end
  Turns.enable=false
  if getPlayerCount()>6 then
    bcast('This table only hosts 6 players.',{0.75,0.75,0.75},color)return end
  
  local events={}
  for _,es in ipairs(ref.eventSlots)do
    for i,v in ipairs(getObjectFromGUID(es.zone).getObjects())do
      if v.type=='Card'then
        Use.Add(v.name)
        table.insert(events,v)
  end end end
  for i in ipairs(events)do events[i].setPosition(ref.eventSlots[i].pos)end
  eventCount=#events
  
  local cardCount=0
  for _,ks in ipairs(ref.kingdomSlots)do
    for i,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
      if v.type=='Card'then
        Use.Add(v.name)
        cardCount=cardCount+1
  end end end
  
  if not Use('YoungWitch')or not Use('BlackMarket')then
    for j,guid in ipairs(useSets)do
      local obj2=getObjectFromGUID(guid)
      if obj2 then
        for _,ref in ipairs(obj2.getObjects())do
          if ref.nickname=='Young Witch'then
            cardCount=cardCount-1
          elseif ref.nickname=='Black Market'then
            cardCount=cardCount-blackMarketMax
  end end end end end
  
  for _,baneObj in ipairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
    if baneObj.type=='Card'then
      if not Use('YoungWitch')then baneObj.destruct()end
      local m,d,p=getCost(baneObj.getName()):match('M(%d+)D(%d+)P(%d+)')
      if m and d==p and(m==2 or m==3)then
        bcast('Bane card needs to cost 2 or 3 with no debt or potions.',{0.75,0.75,0.75},color)
        baneObj.destruct()
  end end end
  
  if cardCount==10 and not Use('YoungWitch')and not Use('BlackMarket')then
    removeButtons()
    gameState=2
    setupKingdom()
  elseif cardCount>10 then
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
    elseif Use('YoungWitch')then
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
        elseif cardCount2<12-cardCount then
            bcast('You don\'t have enough cards selected to form a random kingdom.', {0.75,0.75,0.75}, color)
            return end
    elseif Use('BlackMarket')and cardCount2<20-cardCount then
        bcast('You don\'t have enough cards selected to form a Black Market.', {0.75,0.75,0.75}, color)
        return end
    -- random kingdom start
    removeButtons()
    gameState=2
    setupKingdom()
  end
end
function getButton(o,s)for _,b in pairs(o.getButtons())do if b.label:find(s)then return b.index end end end
-- Function to remove all buttons
function removeButtons()
  for i in ipairs(ref.cardSets)do
    local obj=getObjectFromGUID(ref.cardSets[i].guid)
    if obj then obj.clearButtons()end
  end
  local obj=getObjectFromGUID(ref.startButton)
  if obj then obj.clearButtons()obj.clearInputs()end
  obj=getObjectFromGUID(ref.supplyPiles[1].guid)
  if obj then obj.clearButtons()end
  obj=getObjectFromGUID(ref.supplyPiles[5].guid)
  if obj then obj.clearButtons() obj.flip()end
  obj=getObjectFromGUID(ref.supplyPiles[6].guid)
  if obj then obj.clearButtons()end
end
eventTypes='EventLandmarkProjectWayEdict'
function GrabCard(ks,deck)
  local card=false
  for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
    if v.type=='Card'then card=true end end
  while not card do
    for j,v in pairs(deck.getObjects())do
      local tp=getType(v.name)
      if(eventTypes):find(tp)then
        if eventCount<eventMax then
          if tp:find('Way')then eventTypes:gsub('Way','')end
          Use.Add(v.name)
          eventCount=eventCount+1
          break end
      else
        card=true
        deck.takeObject({position=ks.pos,index=v.index,flip=true})
  break end end end end
-- Function to setup the Kingdom
function setupKingdom()
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
      if cs.name~='Promos'or not Use('Summon')then
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
  --Then Reorder The Cards
  function setupKingdomCoroutine()
    wait(1,'skskcStart')
    group(getObjectFromGUID(ref.randomizer.zone).getObjects())
    wait(1,'skskcGroup')
    local deck=false
    for i, v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do
      if v.type=='Deck'then deck=v end end
    if deck then
      deck.setScale({1.88,1,1.88})
      deck.setRotation({0,180,180})
      deck.shuffle()
      deck.highlightOff()
    end
    wait(1,'skskcDeck')
    if deck then
      for _,ks in ipairs(ref.kingdomSlots)do GrabCard(ks,deck)end
      if Use('LGigantism')then
        table.insert(ref.kingdomSlots,6,{guid='15cc8f',zone='323d85'})
        table.insert(ref.kingdomSlots,7,{guid='082508',zone='728565'})
        table.insert(ref.kingdomSlots,{guid='958410',zone='a725b3'})
        for _,ks in ipairs({ref.kingdomSlots[6],ref.kingdomSlots[7],ref.kingdomSlots[#ref.kingdomSlots]})do
          GrabCard(ks,deck)end end
      wait(0.5,'skskcKingdom')
      for _,ks in ipairs(ref.kingdomSlots)do
        for j, v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
          if v.type=='Card'then
            Use.Add(v.getName())
      end end end
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
              deck.takeObject({index=v.index}).destruct()
              p.takeObject({index=1}).destruct()
              coroutine.yield(0)
              p.shuffle()
              p.takeObject({index=1,position=deckAddPos,flip=true})
              cleanDeck=false
              break end end end
        wait(2,'skskcMarket')
        deck.shuffle()
        while #deck.getObjects()>blackMarketMax+1 do
          coroutine.yield(0)
          deck.takeObject({index=1}).destruct()
        end
        -- check for young witch
        for i, v in ipairs(deck.getObjects())do Use.Add(v.name)end
        if not Use('YoungWitch')then deck.takeObject({index=1}).destruct()end
      end
      local baneSet, blackMarket2Check=false, false
      if Use('YoungWitch')then
        for i,v in ipairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
          if v.type=='Card'then
            baneSet=true
            Use.Add(v.getName())
            if card.nickname=='Black Market'then
              blackMarket2Check=true end break
        end end
        if not baneSet then
          for j, card in ipairs(deck.getObjects())do
            local tp=getType(card.name)
            if('EventLandmarkProjectWayEdictSpell'):find(tp)then
            elseif getCost(card.nickname)=='M2D0P0'or getCost(card.nickname)=='M3D0P0'then
              Use.Add(card.nickname)
              if card.nickname=='Black Market'then
                blackMarket2Check=true end
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
      end end
      if deck.getName()=='Black Market deck'then
        for i, card in ipairs(deck.getObjects())do
          Use.Add(card.nickname)
          table.insert(bmDeck, card.nickname)
      end end
    end
    wait(1,'skskcReorder')
    reorderKingdom()
    wait(0.5,'skskcPiles')
    createPile()
    return 1
  end
  startLuaCoroutine(self,'setupKingdomCoroutine')
end
-- Function to reorder the Kingdom
function reorderKingdom()
  --First create an array with all the card names plus the costs in it
  local sortedKingdom={}
  for _,ks in ipairs(ref.kingdomSlots)do
    for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
      if v.type=='Card'then
        table.insert(sortedKingdom,getCost(v.getName())..v.getName())
  end end end
  --Then sort the list
  table.sort(sortedKingdom)
  --Finally, set the positions based on the new order
  for i,v in ipairs(sortedKingdom)do
    sortedKingdom[i]=v:sub(7)
    for _,ks in pairs(ref.kingdomSlots)do
      for k,b in ipairs(getObjectFromGUID(ks.zone).getObjects())do
        if b.getName()==sortedKingdom[i]then
          b.setPosition(ref.kingdomSlots[i].pos)
  end end end end
  --Do the same for events
  if eventCount>0 then
    local sortedEvents={}
    for _,es in ipairs(ref.eventSlots)do
      for j, v in ipairs(getObjectFromGUID(es.zone).getObjects())do
        if v.type=='Card'then v.setRotation({0,90,0})
          table.insert(sortedEvents,getCost(v.getName())..v.getName())
    end end end
    table.sort(sortedEvents)
    for i,v in ipairs(sortedEvents)do
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
  if not Use('YoungWitch')then for i,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do v.destruct()end end
  if not Use('BlackMarket')then for i,v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do v.destruct()end end
  if not Use('Zombie')then getPile('Zombies').destruct()end
  if not Use('Embargo')then getObjectFromGUID('7c2165').destruct()end
  if not Use('LGigantism')then
    for _,g in pairs({'15cc8f','323d85','082508','728565','958410','a725b3'})do
      getObjectFromGUID(g).destruct()end end
  for i in ipairs(ref.replacementPiles)do
    local obj=getObjectFromGUID(ref.replacementPiles[i].guid)
    local pos=obj.getPosition()
    if pos[1]>16 or pos[1]<-16 then obj.destruct()
    elseif pos[3]>23 or pos[3]<13 then obj.destruct()
  end end
  local sideSlots={}
  local f=function(a,p)if a then table.insert(sideSlots,p)else
    if getPile(p..' pile') then
    getPile(p..' pile').destruct()
    else print('Does Not Exist! ',p)
    end end end
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
  --CustomCards
  f(Use('XHeir'),'Heir')
  f(Use('XLessor'),'Bogus Lands')
  f(Use('LTown'),'Road')
  f(Use('LNecromancerLegacy'),'Zombie Legacy')
  f(Use('LDelegate'),'Loyal Subjects')
  --Why was there two Loyal Subjects piles
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
  
  function tokenCoroutine()
    wait(4,'cutcSetup')
    log(Use[1])
    log(Use[2])
    if Use('Obelisk')then obeliskPiles={}end
    local function slot(z,f)
      for __,obj in ipairs(getObjectFromGUID(z).getObjects())do
        if obj.type=='Deck'then f(obj)break end end end
    for name,setup in pairs(Setup)do
      local n=name:gsub(' ','')
      if Use(n)then
        for _,v in ipairs(ref.basicSlots)do slot(v.zone,setup)end
        for _,v in ipairs(ref.kingdomSlots)do slot(v.zone,setup)end
        slot(ref.baneSlot.zone,setup)end end
    if Use('Landmark')then
      for __,v in ipairs(ref.eventSlots)do
        for _,obj in ipairs(getObjectFromGUID(v.zone).getObjects())do
          if obj.type=='Card'then
            if('AqueductDefiled Shrine'):find(obj.getName())then tokenMake(obj,'vp',0)end
            if('ArenaBasilicaBathsBattlefieldColonnadeLabyrinth'):find(obj.getName())then
              tokenMake(obj,'vp',getPlayerCount()*6)end
            if obj.getName()=='Obelisk'then
              local k=math.random(1,#obeliskPiles)
              obj.highlightOn({1,0,1})
              obeliskPiles[k].highlightOn({1,0,1})
              obeliskTarget=obeliskPiles[k].getName():sub(1,-6)
              obj.setDescription('[b]TARGET:[/b] '..obeliskTarget)
              obeliskPiles=nil
            end break
    end end end end
    if Use('BlackMarket')then
      local deckBM=false
      for i, v in ipairs(getObjectFromGUID(ref.randomizer.zone).getObjects())do if v.type=='Deck'then deckBM=v end end
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
    getPile('Estates').takeObject({position=getObjectFromGUID(ref.storageZone.heirloom).getPosition(),flip=true})
  else
    getPile('Shelters').flip()
  end
  setupBaseCardCount()
end

function createHeirlooms(c)
  for n,h in pairs({['Secret Cave']='Magic Lamp',['Cemetery']='Haunted Mirror',['Shepherd']='Pasture',['Tracker']='Pouch',['Pooka']='Cursed Gold',['Pixie']='Goat',['Fool']='Lucky Coin',['C Magician']='Rabbit',['C Jinxed Jewel']='Jinxed Jewel',['C Burned Village']='Rescuers'})do
    if c==n then getPile('Heirlooms').takeObject({position=getObjectFromGUID(ref.storageZone.heirloom).getPosition(),guid=ref.heirlooms[h],flip=true})break end end end
function placePile(v,p)local l=getPile(v.getName()..' pile');l.setPosition(p)v.destruct()return l end
function makePile(v,p)local k,n=1,10--Card Kount
  --If we have a victory card and 2 players, we make 8 copies
  if getPlayerCount()==2 and(getType(v.getName()):find('Victory')or v.getName()=='Q Dig')then n=8
  --If we have a victory card or the card is Port, we make 12 copies
  elseif('PortQ Dig'):find(v.getName())or getType(v.getName()):find('Victory')then n=12
  elseif('Rats'):find(v.getName())then n=20 end

  if v.getName()=='Castles'then local l=placePile(v,p)
    if getPlayerCount()==2 then
      for _,n in pairs({'Humble Castle','Small Castle','Opulent Castle','King\'s Castle'})do
        for l,c in ipairs(l.getObjects())do
          if obj.nickname==n then l.takeObject({index=c.index}).destruct()
            break end end end end
  --If we have Knights, we swap in the Knights pile
  elseif v.getName()=='Knights'then placePile(v,p).shuffle()
  elseif v.getName()=='X Stallions'then placePile(v,p)
  elseif v.getName():find(' / ')then placePile(v,p)
  --All other cards get n copies
  else while k<n do v.clone({position=p})k=k+1 end
end end
function createPile()
  for _,ks in pairs(ref.kingdomSlots)do
    for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
      if v.type=='Card'then makePile(v,ks.pos)
  end end end
  local removeBane=true
  for i,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
    if v.type=='Card'then makePile(v,ref.baneSlot.pos)removeBane=false
  end end
  --Coroutine names the piles after they form
  function createPileCoroutine()wait(2,'cpcNames')
    if getPile('Heirlooms')then getPile('Heirlooms').destruct()end
    for _,ks in pairs(ref.kingdomSlots)do
      for j,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
        if v.type=='Deck'and v.getName():sub(-5)~=' pile'then
            v.setName(v.takeObject({position=v.getPosition()}).getName()..' pile')
    end end end
    if not removeBane then
      for _,v in pairs(getObjectFromGUID(ref.baneSlot.zone).getObjects())do
        if v.type=='Deck'and v.getName():sub(-5)~=' pile'then
            v.setName(v.takeObject({position=v.getPosition()}).getName()..' pile')
    end end end cleanUp()return 1
  end startLuaCoroutine(self, 'createPileCoroutine')end
function NO()end
function getVP(n)if Victory[n]then return Victory[n]end for _,v in pairs(MasterData)do if n==v.name then return v.VP or 0 end end end
function getCost(n)for _,v in pairs(MasterData)do if n==v.name then return v.c end end return'M0D0P0'end
function getType(n)for _,v in pairs(MasterData)do if n==v.name then return v.t end end return'Event'end
function getPile(pileName)for i,k in pairs({'replacementPiles','supplyPiles','sidePiles'})do for _,p in pairs(ref[k])do if pileName==p.name then return getObjectFromGUID(p.guid)end end end end
--Function to set the correct count of base cards
function setupBaseCardCount()
  local pCount=getPlayerCount()
  --Starting Curses
  setPileAmount(getPile('Curses'),(pCount-1)*10)
  if getPile('Ruins pile')then
    getPile('Ruins pile').shuffle()
    setPileAmount(getPile('Ruins pile'),(pCount-1)*10)
  end
  --Starting Treasures
  if pCount<5 then
    setPileAmount(getPile('Coppers'),60)
    setPileAmount(getPile('Silvers'),40)
    setPileAmount(getPile('Golds'),30)
  end
  --Starting Provinces
  if pCount==5 then
    setPileAmount(getPile('Provinces'),15)
  elseif pCount<5 then
    setPileAmount(getPile('Provinces'),12)
  end
  --2 Player Victory Card Setup
  if pCount==2 then
    setPileAmount(getPile('Estates'),8)
    setPileAmount(getPile('Duchies'),8)
    setPileAmount(getPile('Provinces'),8)
    if usePlatinum==1 then
      setPileAmount(getPile('Colonies'),8)
    end
  else
    setPileAmount(getPile('Estates'),12)
  end
  setupStartingDecks()
end
-- Function to setup starting Decks
function setupStartingDecks()
  --make a pile with used Heirlooms to copy
  local c,z,h=1,getObjectFromGUID(ref.storageZone.heirloom).getObjects(),false
  for _,obj in pairs(z)do if obj.type=='Deck'then c,h=1+obj.getQuantity(),obj elseif obj.type=='Card'then c,h=2,obj end end
  --Creating the starting decks
  --if Use('Delegate')then getPile('Loyal Subjects pile').takeObject()
  for p,v in pairs(ref.players)do
    local d=v.deck
    if h then h.clone({position=d})end
    for j=c,7 do getPile('Coppers').takeObject({position=d,flip=true})end
    if useShelters and getPile('Shelters')then
      getPile('Shelters').clone({position=d,rotation={0,180,180}})
    else for j=1,3 do getPile('Estates').takeObject({position=v.deck,flip=true})
  end end end
  if useShelters and getPile('Shelters')then getPile('Shelters').destruct()end
  
  Timer.create({identifier='dSH',function_name='dealStartingHands',delay=2})
end
-- Function to deal starting hands
function dealStartingHands()
  function dealStartingHandsCoroutine()
    wait(2,'dshcShuffle')
    for i, v in pairs(ref.players)do
      for j, b in pairs(getObjectFromGUID(v.deckZone).getObjects())do
        if b.type=='Deck'then
          b.shuffle()
        end
      end
    end
    wait(0.5,'dshcDeal')
    for i, v in pairs(ref.players)do
      for j, b in pairs(getObjectFromGUID(v.deckZone).getObjects())do
        if b.type=='Deck'then
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
function setPileAmount(pile,total)
  while pile.getQuantity()>total do pile.takeObject({}).destruct()
end end
--XML UI Buttons
function playHand(player)
  local objects = player.getHandObjects()
  local start = -2-#objects*2
  for i,o in ipairs(objects) do
  o.setPosition({start+i*4,1.2,-1})
end end
function drawCard(player)
  local t = ref.players[player.color]
  local deck = {zone = getObjectFromGUID(t.deckZone)}
  local discard = {zone = getObjectFromGUID(t.discardZone)}
  deck['pos'] = deck.zone.getPosition()
  discard['pos'] = discard.zone.getPosition()
  deck['objects'] = {}
  discard['objects'] = {}
  for _,o in pairs(deck.zone.getObjects()) do
    if o.tag == 'Deck' or o.tag == 'Card' then
      table.insert(deck.objects, o)end end
  for _,o in pairs(discard.zone.getObjects()) do
    if o.tag == 'Deck' or o.tag == 'Card' then
      table.insert(discard.objects, o)end end
  local dN,flip=0,false

  if #deck.objects > 1 or #discard.objects > 1 then
    player.broadcast('Fix your Deck/Discard area!',{1,0,1})
    return end
  if #deck.objects > 0 and #discard.objects > 0 and deck.objects[1].is_face_down == discard.objects[1].is_face_down then
    player.broadcast('2Fix your Deck/Discard area!',{1,0,1})
    return end
  if #discard.objects > 0 and discard.objects[1].is_face_down then
    local t = discard
    discard = deck
    deck = t
  elseif #deck.objects > 0 and deck.objects[1].is_face_down == false then
    local t = discard
    discard = deck
    deck = t
  end
  if #deck.objects == 0 then
    if #discard.objects == 0 then return end
    discard.objects[1].flip()
    discard.objects[1].setPosition(deck.pos)
    discard.objects[1].shuffle()
    Wait.time(function()discard.objects[1].deal(1,player.color)end,0.1)
  else
    deck.objects[1].deal(1,player.color)
end end

-- Function to get a count of players sitting at the table with hands to be dealt to.
function getPlayerCount()local c=#getSeatedPlayers()if c==1 then return 6 end return c end
-- Function to wait during coroutines
function wait(time,key)local start=os.time()print(key or'Unknown')repeat coroutine.yield(0)until os.time()>start+time end
--Shortcut broadcast function to shorten them when I call them in the code
function bcast(m,c,p)if c==nil then c={1,1,1}end if p then Player[p].broadcast(m,c)else broadcastToAll(m,c)end end
function tokenCallback(obj,m)obj.setPosition(m[3])obj.call('setOwner',m)end
function tokenMake(obj,key,n,post,name)
  local p=obj.getPosition()
  local pos=post or{-0.9,1,-1.25}
  if not post and key=='vp'then pos={0.9,1,1.25}end
  p={p[1]+pos[1],p[2]+pos[2],p[3]+pos[3]}
  local t={position=p,rotation={0,180,0},callback='tokenCallback',callback_owner=self,params={name or obj.getName(),n or 0,p}}
  log(t.params)
  if not n then t.callback=nil end
  getObjectFromGUID(ref.tokenBag[key]).takeObject(t)
end
--Function to set uninteractible objects
function setUninteractible(t)
  for _,o in pairs(getAllObjects())do
    local n=o.getName()
    if('CardDeck'):find(o.type)then
      local f=false
      for j,k in pairs({'replacementPiles','supplyPiles','eventSets','sidePiles','cardSets'})do
        if not f then for i,c in ipairs(ref[k])do if n==c.name then f,ref[k][i].guid=true,o.getGUID()break end end end end
      if gameState==1 and not f then o.highlightOn({1,0,0.5})print(n)end
    elseif n==''then o.interactable=false end
  
  for j,c in pairs({'baneSlot','randomizer'})do
    local o=getObjectFromGUID(ref[c].guid)
    if o then
      o.setLock(true)
      p=o.getPosition()
      ref[c].pos={p[1],1.3,p[3]}
  end end
  for j,c in pairs({'basicSlots','eventSlots','kingdomSlots','sideSlots'})do
    for k,r in pairs(ref[c])do
      local o=getObjectFromGUID(r.guid)
      if o then
        if o.getName()==''then
          o.interactable=false end
        o.setLock(true)
        p=o.getPosition()
        ref[c][k].pos={p[1],1.3,p[3]}
  end end end end
end
--VP Functions
function dv(t,s,d)local a=0;for c,n in pairs(t.deck)do if getType(c):find(s)then a=d and a+d or a+n end end return a end
Victory={
Gardens      =function(t)return math.floor(t.amount/10)end,
Duke         =function(t)return t.deck['Duchy']or 0 end,
Vineyard     =function(t)return math.floor(dv(t,'Action')/3)end,
Fairgrounds  =function(t)return 2*math.floor(#t.deck/5)end,
['Silk Road']=function(t)return 2*math.floor(dv(t,'Victory')/4)end,
Feodum       =function(t)return 3*math.floor((t.deck.Silver or 0)/4)end,
['Humble Castle']=function(t)return dv(t,'Castle')end,
['King\'s Castle']=function(t)return 2*dv(t,'Castle')end,
--Landmarks
['Bandit Fort']=function(t)return -((t.deck.Silver or 0)+(t.deck.Gold or 0))*2 end,
Fountain=function(t)if t.deck.Copper>9 then return 15 end return 0 end,
Keep=function(t,dT,cp)local v=0;for c,n in pairs(t.deck)do if getType(c):find('Treasure')then local w=true;for o,d in pairs(dT)do if o~=cp and d and d[c] and d[c]>n then w=false;end end end if w then v=v+5 end end end,
Museum=function(t)return #t.deck*2 end,
Obelisk=function(t)if obeliskTarget=='Knights'then return t.knights*2 elseif obeliskTarget then return(t.deck[obeliskTarget]or 0)*2 end return 0 end,
Orchard=function(t)local v=0;for c,n in pairs(t)do if getType(c):find('Action')then if n>2 then v=v+4 end end end return v end,
Palace=function(t)return 3*math.min(t.deck.Copper or 0, t.deck.Silver or 0, t.deck.Gold or 0)end,
Tower=function(t)local vp,ne,zs,f=0,{},{},false;for _,g in ipairs(ref.basicSlotzs)do table.insert(zs,getObjectFromGUID(g))end table.insert(zs,getObjectFromGUID(ref.baneSlot.zone))for _,s in ipairs(ref.kingdomSlots)do table.insert(zs,getObjectFromGUID(s.zone))end for _,z in ipairs(zs)do for __,o in ipairs(z.getObjects())do if o.type=='Card'and o.getName()~='Bane Card'then if getType(o.getName()):find('Knight')==nil then table.insert(ne,o.getName())else table.insert(ne,'Knights')end elseif o.type=='Deck'then table.insert(ne,o.getName():sub(1,-6))end end end for c,n in pairs(t.deck)do for _,p in ipairs(ne)do if p==c then f=true;end end if getType(c):find('Knight')then for _,p in ipairs(ne)do if p=='Knights'then f=true end end end for _,bmCard in ipairs(bmDeck)do if c==bmCard then f=true end end--[[self Blackmarket Var]]if getType(c):find('Victory')==nil and not f then vp=vp+n end end return vp end,
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
      if o.type=='Card'then if getType(o.getName()):find('Knight')then table.insert(ne,'Knights')else table.insert(ne,o.getName())end
      elseif o.type=='Deck'then table.insert(ne,o.getName():sub(1,-6))end end end
    for c,n in pairs(t.deck)do
      for _,p in ipairs(ne)do if p==c then f=true end end
      if getType(c):find('Knight')then for _,p in ipairs(ne)do if p=='Knights'then f=true end end end
      for _,bmCard in ipairs(bmDeck)do if c==bmCard then f=true end end--[[Blackmarket]]
      if not f then vp=vp+n end end return vp end,
['V Sacred Hall']=function(t)
  --Differntly Named in Trash
  return 0 end,
['V Acreage']=function(t)
  local uniqueActions=dv(t,'Action',1)
  return 3*(uniqueActions-uniqueActions%2) end,
['V Barony']=function(t)return 2*(dv(t,'Treasure',1)+dv(t,'Victory',1))end,
['V Bishopric']=function(t)printToAll('Bishopric Needs Manual Count.')return 0 end,
['V County']=function(t)
  local types,n='',0
  for c,_ in pairs(t.deck)do
    for p in getType(c):gmatch('%w+')do
      if not types:find(p)then
        types=types..p..' '
        n=n+1
  end end end
  return n end,
['V Domain']=function(t)return 3*math.min(t.deck.Province or 0,t.deck.Duchy or 0,t.deck.Estate or 0)end,
['V Gold Mine']=function(t)return(t.deck.Gold or 0)end,
['V Grange']=function(t)--[[1Per action card you have from an empty supply pile]]return 0 end,
['V Yards']=function(t)return math.floor(t.amount/3)end,
['C Tulip Field']=function(t,dT,cp)end
}
Setup={--(o):Deck
['Trade Route']=function(o)if getType(o.getObjects()[1].name):find('Victory')and not getType(o.getObjects()[1].name):find('Knight')then tokenMake(o,'coin',0,{0,1,0},'Trade Route')end end,
Tax=function(o)tokenMake(o,'debt',1,{0.9,1,-1.25})end,
Gathering=function(o)if getType(o.getObjects()[1].name):find('Gathering')then tokenMake(obj,'vp')end end,
Obelisk=function(o)if getType(o.getObjects()[o.getQuantity()].name):find('Action')then table.insert(obeliskPiles,o)end end,
Aqueduct=function(o)local n=o.getName()if n=='Golds'or n=='Silvers'then tokenMake(o,'vp',8)end end,
['Defiled Shrine']=function(o)local t=getType(o.getObjects()[1].name);if t:find('Action')and not t:find('Gathering')then tokenMake(o,'vp',2)end end,
['Way of the Mouse']=function(o)end,
['C Panda / Gardener']=function(o)tokenMake(o,'coin',2,{0,1,0})end,
}--Reference Tables
ref={
Board='7636a9',startButton='176e6a',tradeRoute='b853e8',
baneSlot  ={guid='df4a68',zone='5b9b18'},
randomizer={guid='3d5008',zone='fd0b1d'},
storageZone={fog='2c0471',heirloom='eb483b'},
tokenBag={coin='491d9b',debt='7624c9',vp='b935ba'},
heirlooms={},
basicSlots={
{guid='497478',zone='198948'},{guid='e700bc',zone='a5940e'},{guid='7cbaf0',zone='86fa0b'},{guid='5acda1',zone='810603'},{guid='28c05c',zone='0bd7f8'},{guid='00d4cc',zone='2a639d'},
{guid='377aaf',zone='67f21e'},{guid='563a61',zone='b33712'},{guid='56dcad',zone='d484d7'},{guid='d516bd',zone='7f9e58'},{guid='4b9597',zone='378afe'},{guid='4ca7f5',zone='7985d4'}},
sideSlots={
{guid='fa020b'},{guid='3ba1c2'},{guid='1e113a'},{guid='61ae8d'},
{guid='a96aef'},{guid='d5f986'},{guid='2ea60a'},{guid='f7a574'},
{guid='bf7652'},{guid='5750e9'},{guid='5a0bb6'},{guid='08dc7f'},
{guid='bf9dda'},{guid='adb237'},{guid='788b21'},{guid='dc9cf0'},
{guid='7535f5'},{guid='fa776f'},{guid='8a299d'},{guid='6c4cb9'},
{guid='18a0ba'},{guid='fb0663'},{guid='5e6695'},{guid='e6fed4'},
{guid='360c35'},{guid='561fa6'},{guid='72bf1b'},{guid='98bcc2'},
{guid='f0bd83'},{guid='8cf7ae'},{guid='bb0b4f'},{guid='7ba0bf'},
{guid='811c7b'},{guid='d8a850'},{guid='25756f'},{guid='de9a73'},
},
eventSlots={
{guid='e091ca',zone='abdb77'},{guid='bb3643',zone='2e81b8'},{guid='1ff6fe',zone='6320a3'},{guid='6ca433',zone='9a943d'},{guid='f456dc',zone='87cf23'},{guid='91e896',zone='06a75e'}},
supplyPiles={
{name='Platinums'},
{name='Potions'},
{name='Colonies'},
{name='Ruins pile'},
{name='Shelters'},
{name='Boulder Trap pile'},
{name='Zombies'},
{name='Coppers'},
{name='Silvers'},
{name='Golds'},
{name='Curses'},
{name='Estates'},
{name='Duchies'},
{name='Provinces'},
{name='Trash'}},
sidePiles={
{name='Heirlooms'},
{name='Spellcasters Spells pile'},
{name='W Cursed Bargain pile'},
{name='W Cursed Beverage pile'},
{name='W Cursed Copper pile'},
{name='W Ethereal Curse pile'},
{name='T Cursed Antique pile'},
{name='T Broken Sword pile'},
{name='Turncoat pile'},
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
{name='Teacher pile'}},
replacementPiles={
{name='Knights pile'},
{name='Sauna / Avanto pile'},
{name='Castles pile'},
{name='Catapult / Rocks pile'},
{name='Encampment / Plunder pile'},
{name='Gladiator / Fortune pile'},
{name='Patrician / Emporium pile'},
{name='Settlers / Bustling Village pile'},
{name='X Stallions pile'},
{name='C Panda / Gardener pile'},
{name='W Invoking Witch / W Summoned Fiend pile'}},
kingdomSlots={
{guid='ea57b1',zone='987e4a'},
{guid='08e74d',zone='816553'},
{guid='3efdc8',zone='7b20e5'},
{guid='4e4e40',zone='740c12'},
{guid='4084c6',zone='fefd47'},
{guid='6be6f9',zone='47d4f1'},
{guid='4ab1b9',zone='4a3f91'},
{guid='48b491',zone='9d12c3'},
{guid='03a180',zone='9e931d'},
{guid='25f0bd',zone='00770c'}},
players={
Blue  ={deckZone='307d12',discardZone='41de74',zone='062acc',coins='b2dc22',vp='b59b65',debt='186c83',tavern='015528',deck={-67.5,4,-28},discard={-72.5,4,-28}},
Green ={deckZone='9359a4',discardZone='72ba37',zone='c11794',coins='22bdb3',vp='6ae2a8',debt='a34771',tavern='af5c58',deck={-39.5,4,-28},discard={-44.5,4,-28}},
White ={deckZone='e6b388',discardZone='eb044b',zone='c95925',coins='b6bf41',vp='1b4618',debt='3d4844',tavern='d7d996',deck={-11.5,4,-28},discard={-16.5,4,-28}},
Red   ={deckZone='5a6e68',discardZone='e09013',zone='d1c5af',coins='4b832d',vp='84f540',debt='9cfa4a',tavern='48295f',deck={16.5,4,-28},discard={11.5,4,-28}},
Orange={deckZone='420340',discardZone='bf9b32',zone='10c425',coins='ce8828',vp='0d128b',debt='f2a253',tavern='fd4953',deck={44.5,4,-28},discard={39.5,4,-28}},
Yellow={deckZone='7ee56d',discardZone='046cfd',zone='827520',coins='17dd2a',vp='c979ca',debt='10cb81',tavern='dea1f7',deck={72.5,4,-28},discard={67.5,4,-28}}},
--All card sets/expansions
cardSets={
{name='Dominion'},
{name='Intrigue'},
{name='Seaside'},
{name='Alchemy'},
{name='Prosperity'},
{name='Cornucopia'},
{name='Hinterlands'},
{name='Dark Ages'},
{name='Guilds'},
{name='Adventures',events={1}},--10
{name='Empires',events={2,3}},
{name='Nocturne'},
{name='Renaissance',events={4}},
{name='Menagerie',events={5,6}},
{name='Antiquities'},
{name='Xtras'},
{name='Tools'},
{name='Spellcasters'},
{name='Seasons'},
{name='Legacy',events={9}},--20
{name='Legacy Expert',events={9,10}},
{name='Legacy Feats'},
{name='Legacy Teams'},
{name='Promos',events={7}},
{name='Co0kieL0rd'},
{name='Adamabrams',events={8}},
{name='Witches'},
{name='Duplicate/Outdated'}},
eventSets={
{name='Adventures Events'},
{name='Empires Events'},
{name='Empires Landmarks'},
{name='Renaissance Projects'},
{name='Menagerie Events'},
{name='Menagerie Ways'},
{name='Summon'},
{name='Adamabrams Extras'},
{name='Legacy Events'},
{name='Legacy Edicts'}}}
--Name of all cards along with costs, used for sorting
MasterData={
{c='M0D0P0',name='Copper',t='Treasure'},
{c='M3D0P0',name='Silver',t='Treasure'},
{c='M6D0P0',name='Gold',t='Treasure'},
{c='M9D0P0',name='Platinum',t='Treasure'},
{c='M4D0P0',name='Potion',t='Treasure'},
{c='M0D0P0',name='Curse',t='Curse',VP=-1},
{c='M2D0P0',name='Estate',t='Victory',VP=1},
{c='M5D0P0',name='Duchy',t='Victory',VP=3},
{c='M8D0P0',name='Province',t='Victory',VP=6},
{c='MBD0P0',name='Colony',t='Victory',VP=10},
{c='M6D0P0',name='Artisan',t='Action'},
{c='M5D0P0',name='Bandit',t='Action - Attack'},
{c='M4D0P0',name='Bureaucrat',t='Action - Attack'},
{c='M2D0P0',name='Cellar',t='Action'},
{c='M2D0P0',name='Chapel',t='Action'},
{c='M5D0P0',name='Council Room',t='Action'},
{c='M5D0P0',name='Festival',t='Action'},
{c='M4D0P0',name='Gardens',t='Victory'},
{c='M3D0P0',name='Harbinger',t='Action'},
{c='M5D0P0',name='Laboratory',t='Action'},
{c='M5D0P0',name='Library',t='Action'},
{c='M5D0P0',name='Market',t='Action'},
{c='M3D0P0',name='Merchant',t='Action'},
{c='M4D0P0',name='Militia',t='Action - Attack'},
{c='M5D0P0',name='Mine',t='Action'},
{c='M2D0P0',name='Moat',t='Action - Reaction'},
{c='M4D0P0',name='Moneylender',t='Action'},
{c='M4D0P0',name='Poacher',t='Action'},
{c='M4D0P0',name='Remodel',t='Action'},
{c='M5D0P0',name='Sentry',t='Action'},
{c='M4D0P0',name='Smithy',t='Action'},
{c='M4D0P0',name='Throne Room',t='Action'},
{c='M3D0P0',name='Vassal',t='Action'},
{c='M3D0P0',name='Village',t='Action'},
{c='M5D0P0',name='Witch',t='Action - Attack'},
{c='M3D0P0',name='Workshop',t='Action'},
{c='M4D0P0',name='Baron',t='Action'},
{c='M4D0P0',name='Bridge',t='Action'},
{c='M4D0P0',name='Conspirator',t='Action'},
{c='M5D0P0',name='Courtier',t='Action'},
{c='M2D0P0',name='Courtyard',t='Action'},
{c='M4D0P0',name='Diplomat',t='Action - Reaction'},
{c='M5D0P0',name='Duke',t='Victory'},
{c='M6D0P0',name='Harem',t='Treasure - Victory',VP=2},
{c='M4D0P0',name='Ironworks',t='Action'},
{c='M2D0P0',name='Lurker',t='Action'},
{c='M3D0P0',name='Masquerade',t='Action'},
{c='M4D0P0',name='Mill',t='Action - Victory',VP=1},
{c='M4D0P0',name='Mining Village',t='Action'},
{c='M5D0P0',name='Minion',t='Action - Attack'},
{c='M6D0P0',name='Nobles',t='Action - Victory',VP=2},
{c='M5D0P0',name='Patrol',t='Action'},
{c='M2D0P0',name='Pawn',t='Action'},
{c='M5D0P0',name='Replace',t='Action - Attack'},
{c='M3D0P0',name='Steward',t='Action'},
{c='M3D0P0',name='Swindler',t='Action - Attack'},
{c='M3D0P0',name='Shanty Town',t='Action'},
{c='M4D0P0',name='Secret Passage',t='Action'},
{c='M5D0P0',name='Trading Post',t='Action'},
{c='M5D0P0',name='Torturer',t='Action - Attack'},
{c='M5D0P0',name='Upgrade',t='Action'},
{c='M3D0P0',name='Wishing Well',t='Action'},
{c='M3D0P0',name='Ambassador',t='Action - Attack'},
{c='M5D0P0',name='Bazaar',t='Action'},
{c='M4D0P0',name='Caravan',t='Action - Duration'},
{c='M4D0P0',name='Cutpurse',t='Action - Attack'},
{c='M2D0P0',name='Embargo',t='Action'},
{c='M5D0P0',name='Explorer',t='Action'},
{c='M3D0P0',name='Fishing Village',t='Action - Duration'},
{c='M5D0P0',name='Ghost Ship',t='Action - Attack'},
{c='M2D0P0',name='Haven',t='Action - Duration'},
{c='M4D0P0',name='Island',t='Action - Victory',depend='Island',VP=2},
{c='M2D0P0',name='Lighthouse',t='Action - Duration'},
{c='M3D0P0',name='Lookout',t='Action'},
{c='M5D0P0',name='Merchant Ship',t='Action - Duration'},
{c='M2D0P0',name='Native Village',t='Action',depend='NativeVillage'},
{c='M4D0P0',name='Navigator',t='Action'},
{c='M5D0P0',name='Outpost',t='Action - Duration'},
{c='M2D0P0',name='Pearl Diver',t='Action'},
{c='M4D0P0',name='Pirate Ship',t='Action - Attack',depend='PirateShip'},
{c='M4D0P0',name='Salvager',t='Action'},
{c='M4D0P0',name='Sea Hag',t='Action - Attack'},
{c='M3D0P0',name='Smugglers',t='Action'},
{c='M5D0P0',name='Tactician',t='Action - Duration'},
{c='M4D0P0',name='Treasure Map',t='Action'},
{c='M5D0P0',name='Treasury',t='Action'},
{c='M3D0P0',name='Warehouse',t='Action'},
{c='M5D0P0',name='Wharf',t='Action - Duration'},
{c='M3D0P1',name='Alchemist',t='Action'},
{c='M2D0P1',name='Apothecary',t='Action'},
{c='M5D0P0',name='Apprentice',t='Action'},
{c='M3D0P1',name='Familiar',t='Action - Attack'},
{c='M4D0P1',name='Golem',t='Action'},
{c='M2D0P0',name='Herbalist',t='Action'},
{c='M3D0P1',name='Philosopher\'s Stone',t='Treasure'},
{c='M6D0P1',name='Possession',t='Action'},
{c='M2D0P1',name='Scrying Pool',t='Action - Attack'},
{c='M0D0P1',name='Transmute',t='Action'},
{c='M2D0P1',name='University',t='Action'},
{c='M0D0P1',name='Vineyard',t='Victory'},
{c='M7D0P0',name='Bank',t='Treasure'},--Prosperity
{c='M4D0P0',name='Bishop',t='Action',depend='VP'},
{c='M5D0P0',name='City',t='Action'},
{c='M5D0P0',name='Contraband',t='Treasure'},
{c='M5D0P0',name='Counting House',t='Action'},
{c='M7D0P0',name='Expand',t='Action'},
{c='M7D0P0',name='Forge',t='Action'},
{c='M6D0P0',name='Goons',t='Action - Attack',depend='VP'},
{c='M6D0P0',name='Grand Market',t='Action'},
{c='M6D0P0',name='Hoard',t='Treasure'},
{c='M7D0P0',name='King\'s Court',t='Action'},
{c='M3D0P0',name='Loan',t='Treasure'},
{c='M5D0P0',name='Mint',t='Action'},
{c='M4D0P0',name='Monument',t='Action',depend='VP'},
{c='M5D0P0',name='Mountebank',t='Action - Attack'},
{c='M8D0P0',name='Peddler',t='Action'},
{c='M4D0P0',name='Quarry',t='Treasure'},
{c='M5D0P0',name='Rabble',t='Action - Attack'},
{c='M5D0P0',name='Royal Seal',t='Treasure'},
{c='M4D0P0',name='Talisman',t='Treasure'},
{c='M3D0P0',name='Trade Route',t='Action'},
{c='M5D0P0',name='Vault',t='Action'},
{c='M5D0P0',name='Venture',t='Treasure'},
{c='M3D0P0',name='Watchtower',t='Action - Reactopm'},
{c='M4D0P0',name='Worker\'s Village',t='Action'},
{c='M6D0P0',name='Fairgrounds',t='Victory'},--Cornucopia
{c='M4D0P0',name='Farming Village',t='Action'},
{c='M3D0P0',name='Fortune Teller',t='Action - Attack'},
{c='M2D0P0',name='Hamlet',t='Action'},
{c='M5D0P0',name='Harvest',t='Action'},
{c='M5D0P0',name='Horn of Plenty',t='Treasure'},
{c='M4D0P0',name='Horse Traders',t='Action - Reaction'},
{c='M5D0P0',name='Hunting Party',t='Action'},
{c='M5D0P0',name='Jester',t='Action - Attack'},
{c='M3D0P0',name='Menagerie',t='Action'},
{c='M4D0P0',name='Remake',t='Action'},
{c='M4D0P0',name='Tournament',t='Action',depend='Prize'},
{c='M4D0P0',name='Young Witch',t='Action - Attack'},
{c='M0D0P0',name='Bag of Gold',t='Action - Prize'},
{c='M0D0P0',name='Diadem',t='Treasure - Prize'},
{c='M0D0P0',name='Followers',t='Action - Attack - Prize'},
{c='M0D0P0',name='Princess',t='Action - Prize'},
{c='M0D0P0',name='Trusty Steed',t='Action - Prize'},
{c='M6D0P0',name='Border Village',t='Action'},
{c='M5D0P0',name='Cache',t='Treasure'},
{c='M5D0P0',name='Cartographer',t='Action'},
{c='M2D0P0',name='Crossroads',t='Action'},
{c='M3D0P0',name='Develop',t='Action'},
{c='M2D0P0',name='Duchess',t='Action'},
{c='M5D0P0',name='Embassy',t='Action'},
{c='M6D0P0',name='Farmland',t='Victory',VP=2},
{c='M2D0P0',name='Fool\'s Gold',t='Treasure - Reaction'},
{c='M5D0P0',name='Haggler',t='Action'},
{c='M5D0P0',name='Highway',t='Action'},
{c='M5D0P0',name='Ill-Gotten Gains',t='Treasure'},
{c='M5D0P0',name='Inn',t='Action'},
{c='M4D0P0',name='Jack of All Trades',t='Action'},
{c='M5D0P0',name='Mandarin',t='Action'},
{c='M5D0P0',name='Margrave',t='Action - Attack'},
{c='M4D0P0',name='Noble Brigand',t='Action - Attack'},
{c='M4D0P0',name='Nomad Camp',t='Action'},
{c='M3D0P0',name='Oasis',t='Action'},
{c='M3D0P0',name='Oracle',t='Action - Attack'},
{c='M3D0P0',name='Scheme',t='Action'},
{c='M4D0P0',name='Silk Road',t='Victory'},
{c='M4D0P0',name='Spice Merchant',t='Action'},
{c='M5D0P0',name='Stables',t='Action'},
{c='M4D0P0',name='Trader',t='Action - Reaction'},
{c='M3D0P0',name='Tunnel',t='Victory - Reaction',VP=2},
{c='M0D0P0',name='Abandoned Mine',t='Action - Ruins'},
{c='M0D0P0',name='Ruined Library',t='Action - Ruins'},
{c='M0D0P0',name='Ruined Market',t='Action - Ruins'},
{c='M0D0P0',name='Ruined Village',t='Action - Ruins'},
{c='M0D0P0',name='Survivors',t='Action - Ruins'},
{c='M6D0P0',name='Altar',t='Action'},--DarkAges
{c='M4D0P0',name='Armory',t='Action'},
{c='M5D0P0',name='Band of Misfits',t='Action - Command'},
{c='M5D0P0',name='Bandit Camp',t='Action',depend='Spoils'},
{c='M2D0P0',name='Beggar',t='Action - Reaction'},
{c='M5D0P0',name='Catacombs',t='Action'},
{c='M5D0P0',name='Count',t='Action'},
{c='M5D0P0',name='Counterfeit',t='Treasure'},
{c='M5D0P0',name='Cultist',t='Action - Attack - Looter'},
{c='M4D0P0',name='Death Cart',t='Action - Looter'},
{c='M4D0P0',name='Feodum',t='Victory'},
{c='M3D0P0',name='Forager',t='Action'},
{c='M4D0P0',name='Fortress',t='Action'},
{c='M5D0P0',name='Graverobber',t='Action'},
{c='M3D0P0',name='Hermit',t='Action',depend='Madman'},
{c='M6D0P0',name='Hunting Grounds',t='Action'},
{c='M4D0P0',name='Ironmonger',t='Action'},
{c='M5D0P0',name='Junk Dealer',t='Action'},
{c='M5D0P0',name='Knights',t='Action - Attack - Knight'},
{c='M4D0P0',name='Marauder',t='Action - Attack - Looter',depend='Spoils'},
{c='M3D0P0',name='Market Square',t='Action - Reaction'},
{c='M5D0P0',name='Mystic',t='Action'},
{c='M5D0P0',name='Pillage',t='Action - Attack',depend='Spoils'},
{c='M1D0P0',name='Poor House',t='Action'},
{c='M4D0P0',name='Procession',t='Action'},
{c='M4D0P0',name='Rats',t='Action'},
{c='M5D0P0',name='Rebuild',t='Action'},
{c='M5D0P0',name='Rogue',t='Action - Attack'},
{c='M3D0P0',name='Sage',t='Action'},
{c='M4D0P0',name='Scavenger',t='Action'},
{c='M2D0P0',name='Squire',t='Action'},
{c='M3D0P0',name='Storeroom',t='Action'},
{c='M3D0P0',name='Urchin',t='Action - Attack',depend='Mercenary'},
{c='M2D0P0',name='Vagrant',t='Action'},
{c='M4D0P0',name='Wandering Minstrel',t='Action'},
{c='M0D0P0',name='Madman',t='Action'},
{c='M0D0P0',name='Mercenary',t='Action - Attack'},
{c='M0D0P0',name='Spoils',t='Treasure'},
{c='M5D0P0',name='Dame Anna',t='Action - Attack - Knight'},
{c='M5D0P0',name='Dame Josephine',t='Action - Attack - Knight - Victory',VP=2},
{c='M5D0P0',name='Dame Molly',t='Action - Attack - Knight'},
{c='M5D0P0',name='Dame Natalie',t='Action - Attack - Knight'},
{c='M5D0P0',name='Dame Sylvia',t='Action - Attack - Knight'},
{c='M5D0P0',name='Sir Bailey',t='Action - Attack - Knight'},
{c='M5D0P0',name='Sir Destry',t='Action - Attack - Knight'},
{c='M4D0P0',name='Sir Martin',t='Action - Attack - Knight'},
{c='M5D0P0',name='Sir Michael',t='Action - Attack - Knight'},
{c='M5D0P0',name='Sir Vander',t='Action - Attack - Knight'},
{c='M1D0P0',name='Hovel',t='Reaction - Shelter'},
{c='M1D0P0',name='Necropolis',t='Action - Shelter'},
{c='M1D0P0',name='Overgrown Estate',t='Victory - Shelter'},
{c='M4D0P0',name='Advisor',t='Action'},--Guilds
{c='M5D0P0',name='Baker',t='Action',depend='Baker Coffers'},
{c='M5D0P0',name='Butcher',t='Action',depend='Coffers'},
{c='M2D0P0',name='Candlestick Maker',t='Action',depend='Coffers'},
{c='M3D0P0',name='Doctor',t='Action'},
{c='M4D0P0',name='Herald',t='Action'},
{c='M5D0P0',name='Journeyman',t='Action'},
{c='M3D0P0',name='Masterpiece',t='Treasure'},
{c='M5D0P0',name='Merchant Guild',t='Action',depend='Coffers'},
{c='M4D0P0',name='Plaza',t='Action',depend='Coffers'},
{c='M5D0P0',name='Soothsayer',t='Action - Attack'},
{c='M2D0P0',name='Stonemason',t='Action'},
{c='M4D0P0',name='Taxman',t='Action - Attack'},
{c='M3D0P0',name='Amulet',t='Action - Duration'},
{c='M5D0P0',name='Artificer',t='Action'},
{c='M5D0P0',name='Bridge Troll',t='Action - Attack - Duration',depend='MinusCoin'},
{c='M3D0P0',name='Caravan Guard',t='Action - Duration - Reaction'},
{c='M2D0P0',name='Coin of the Realm',t='Treasure - Reserve'},
{c='M5D0P0',name='Distant Lands',t='Action - Reserve - Victory'},
{c='M3D0P0',name='Dungeon',t='Action - Duration'},
{c='M4D0P0',name='Duplicate',t='Action - Reserve'},
{c='M3D0P0',name='Gear',t='Action - Duration'},
{c='M5D0P0',name='Giant',t='Action - Attack',depend='Journey'},
{c='M3D0P0',name='Guide',t='Action - Reserve'},
{c='M5D0P0',name='Haunted Woods',t='Action - Attack - Duration'},
{c='M6D0P0',name='Hireling',t='Action - Duration'},
{c='M5D0P0',name='Lost City',t='Action'},
{c='M4D0P0',name='Magpie',t='Action'},
{c='M4D0P0',name='Messenger',t='Action'},
{c='M4D0P0',name='Miser',t='Action',depend='Reserve'},
{c='M2D0P0',name='Page',t='Action - Traveller'},
{c='M2D0P0',name='Peasant',t='Action - Traveller',depend='Reserve PlusCard PlusAction PlusBuy PlusCoin'},
{c='M4D0P0',name='Port',t='Action'},
{c='M4D0P0',name='Ranger',t='Action',depend='Journey'},
{c='M2D0P0',name='Ratcatcher',t='Action - Reserve'},
{c='M2D0P0',name='Raze',t='Action'},
{c='M5D0P0',name='Relic',t='Treasure - Attack',depend='MinusCard'},
{c='M5D0P0',name='Royal Carriage',t='Action - Reserve'},
{c='M5D0P0',name='Storyteller',t='Action'},
{c='M5D0P0',name='Swamp Hag',t='Action - Attack - Duration'},
{c='M4D0P0',name='Transmogrify',t='Action - Reserve'},
{c='M5D0P0',name='Treasure Trove',t='Treasure'},
{c='M5D0P0',name='Wine Merchant',t='Action - Reserve'},
{c='M3D0P0',name='Treasure Hunter',t='Action - Traveller'},
{c='M4D0P0',name='Warrior',t='Action - Warrior - Traveller'},
{c='M5D0P0',name='Hero',t='Action - Traveller'},
{c='M6D0P0',name='Champion',t='Action - Duration'},
{c='M3D0P0',name='Soldier',t='Action - Attack - Traveller'},
{c='M4D0P0',name='Fugitive',t='Action - Traveller'},
{c='M5D0P0',name='Disciple',t='Action - Traveller'},
{c='M6D0P0',name='Teacher',t='Action - Reserve'},
{c='M0D0P0',t='Event',name='Alms'},
{c='M5D0P0',t='Event',name='Ball',depend='MinusCoin'},
{c='M3D0P0',t='Event',name='Bonfire'},
{c='M0D0P0',t='Event',name='Borrow',depend='MinusCard'},
{c='M3D0P0',t='Event',name='Expedition'},
{c='M3D0P0',t='Event',name='Ferry',depend='TwoCost'},
{c='M7D0P0',t='Event',name='Inheritance',depend='Estate'},
{c='M6D0P0',t='Event',name='Lost Arts',depend='PlusAction'},
{c='M4D0P0',t='Event',name='Mission'},
{c='M8D0P0',t='Event',name='Pathfinding',depend='PlusCard'},
{c='M4D0P0',t='Event',name='Pilgrimage',depend='Journey'},
{c='M3D0P0',t='Event',name='Plan',depend='Trashing'},
{c='M0D0P0',t='Event',name='Quest'},
{c='M5D0P0',t='Event',name='Raid',depend='MinusCard'},
{c='M1D0P0',t='Event',name='Save'},
{c='M2D0P0',t='Event',name='Scouting Party'},
{c='M5D0P0',t='Event',name='Seaway',depend='PlusBuy'},
{c='M5D0P0',t='Event',name='Trade'},
{c='M6D0P0',t='Event',name='Training',depend='PlusCoin'},
{c='M2D0P0',t='Event',name='Travelling Fair'},
{c='M5D0P0',name='Archive',t='Action - Duration'},
{c='M5D0P0',name='Capital',t='Treasure',depend='Debt'},
{c='M3D0P0',name='Castles',t='Victory - Castle',depend='VP'},
{c='M3D0P0',name='Catapult / Rocks',t='Action - Attack'},
{c='M3D0P0',name='Chariot Race',t='Action',depend='VP'},
{c='M5D0P0',name='Charm',t='Treasure'},
{c='D8M0P0',name='City Quarter',t='Action'},
{c='M5D0P0',name='Crown',t='Action - Treasure'},
{c='M2D0P0',name='Encampment / Plunder',t='Action',depend='VP'},
{c='M3D0P0',name='Enchantress',t='Action - Attack - Duration'},
{c='D4M0P0',name='Engineer',t='Action'},
{c='M3D0P0',name='Farmers\' Market',t='Action - Gathering',depend='VP'},
{c='M5D0P0',name='Forum',t='Action'},
{c='M3D0P0',name='Gladiator / Fortune',t='Action'},
{c='M5D0P0',name='Groundskeeper',t='Action',depend='VP'},
{c='M5D0P0',name='Legionary',t='Action - Attack'},
{c='M2D0P0',name='Patrician / Emporium',t='Action',depend='VP'},
{c='D8M0P0',name='Royal Blacksmith',t='Action'},
{c='D8M0P0',name='Overlord',t='Action - Command'},
{c='M4D0P0',name='Sacrifice',t='Action',depend='VP'},
{c='M2D0P0',name='Settlers / Bustling Village',t='Action'},
{c='M4D0P0',name='Temple',t='Action - Gathering',depend='VP'},
{c='M4D0P0',name='Villa',t='Action'},
{c='M5D0P0',name='Wild Hunt',t='Action - Gathering',depend='VP'},
{c='M3D0P0',name='Humble Castle',t='Treasure - Victory - Castle'},
{c='M4D0P0',name='Crumbling Castle',t='Victory - Castle',VP=1,depend='VP'},
{c='M5D0P0',name='Small Castle',t='Action - Victory - Castle',VP=2},
{c='M6D0P0',name='Haunted Castle',t='Victory - Castle',VP=2},
{c='M7D0P0',name='Opulent Castle',t='Action - Victory - Castle',VP=3},
{c='M8D0P0',name='Sprawling Castle',t='Victory - Castle',VP=4},
{c='M9D0P0',name='Grand Castle',t='Victory - Castle',VP=5,depend='VP'},
{c='MAD0P0',name='King\'s Castle',t='Victory - Castle'},
{c='D03MP0',name='Catapult',t='Action - Attack'},
{c='D04MP0',name='Rocks',t='Treasure'},
{c='M2D0P0',name='Encampment',t='Action'},
{c='M5D0P0',name='Plunder',t='Treasure',depend='VP'},
{c='M3D0P0',name='Gladiator',t='Action'},
{c='D8M8P0',name='Fortune',t='Treasure'},
{c='M2D0P0',name='Patrician',t='Action'},
{c='M5D0P0',name='Emporium',t='Action',depend='VP'},
{c='M2D0P0',name='Settlers',t='Action'},
{c='M5D0P0',name='Bustling Village',t='Action'},
{c='M0D0P0',t='Event',name='Advance'},
{c='M0D8P0',t='Event',name='Annex'},
{c='M3D0P0',t='Event',name='Banquet'},
{c='M6D0P0',t='Event',name='Conquest',depend='VP'},
{c='M2D0P0',t='Event',name='Delve'},
{c='MED0P0',t='Event',name='Dominate',depend='VP'},
{c='M0D8P0',t='Event',name='Donate'},
{c='M4D0P0',t='Event',name='Ritual',depend='VP'},
{c='M4D0P0',t='Event',name='Salt the Earth',depend='VP'},
{c='M2D0P0',t='Event',name='Tax',depend='Debt'},
{c='M0D5P0',t='Event',name='Triumph',depend='VP'},
{c='M4D3P0',t='Event',name='Wedding',depend='VP'},
{c='M5D0P0',t='Event',name='Windfall'},
{c='MXDXP0',t='Landmark',name='Aqueduct',depend='VP'},
{c='MXDXP0',t='Landmark',name='Arena',depend='VP'},
{c='MXDXP0',t='Landmark',name='Bandit Fort'},
{c='MXDXP0',t='Landmark',name='Basilica',depend='VP'},
{c='MXDXP0',t='Landmark',name='Baths',depend='VP'},
{c='MXDXP0',t='Landmark',name='Battlefield',depend='VP'},
{c='MXDXP0',t='Landmark',name='Colonnade',depend='VP'},
{c='MXDXP0',t='Landmark',name='Defiled Shrine',depend='VP'},
{c='MXDXP0',t='Landmark',name='Fountain'},
{c='MXDXP0',t='Landmark',name='Keep'},
{c='MXDXP0',t='Landmark',name='Labyrinth',depend='VP'},
{c='MXDXP0',t='Landmark',name='Mountain Pass',depend='VP Debt'},
{c='MXDXP0',t='Landmark',name='Museum'},
{c='MXDXP0',t='Landmark',name='Obelisk'},
{c='MXDXP0',t='Landmark',name='Orchard'},
{c='MXDXP0',t='Landmark',name='Palace'},
{c='MXDXP0',t='Landmark',name='Tomb',depend='VP'},
{c='MXDXP0',t='Landmark',name='Tower'},
{c='MXDXP0',t='Landmark',name='Triumphal Arch'},
{c='MXDXP0',t='Landmark',name='Wall'},
{c='MXDXP0',t='Landmark',name='Wolf Den'},
{c='M4D0P0',name='Lucky Coin',t='Treasure - Heirloom'},
{c='M4D0P0',name='Cursed Gold',t='Treasure - Heirloom'},
{c='M2D0P0',name='Pasture',t='Treasure - Victory - Heirloom'},
{c='M2D0P0',name='Pouch',t='Treasure - Heirloom'},
{c='M2D0P0',name='Goat',t='Treasure - Heirloom'},
{c='M0D0P0',name='Magic Lamp',t='Treasure - Heirloom'},
{c='M0D0P0',name='Haunted Mirror',t='Treasure - Heirloom'},
{c='M0D0P0',name='Wish',t='Action'},
{c='M2D0P0',name='Bat',t='Night'},
{c='M0D0P0',name='Will-o\'-Wisp',t='Action'},
{c='M2D0P0',name='Imp',t='Action'},
{c='M4D0P0',name='Ghost',t='Night - Duration - Spirit'},
{c='M6D0P0',name='Raider',t='Night - Duration - Attack'},
{c='M5D0P0',name='Werewolf',t='Action - Night - Attack - Doom'},
{c='M5D0P0',name='Cobbler',t='Night - Duration'},
{c='M5D0P0',name='Den of Sin',t='Night - Duration'},
{c='M5D0P0',name='Crypt',t='Night - Duration'},
{c='M5D0P0',name='Vampire',t='Night - Attack - Doom'},
{c='M4D0P0',name='Exorcist',t='Night',depend='Imp Ghost'},
{c='M4D0P0',name='Devil\'s Workshop',t='Night',depend='Imp'},
{c='M3D0P0',name='Ghost Town',t='Night - Duration'},
{c='M3D0P0',name='Night Watchman',t='Night'},
{c='M3D0P0',name='Changeling',t='Night'},
{c='M2D0P0',name='Guardian',t='Night - Duration'},
{c='M2D0P0',name='Monastery',t='Night'},
{c='M5D0P0',name='Idol',t='Treasure - Attack - Fate'},
{c='M5D0P0',name='Tormentor',t='Action - Attack - Doom',depend='Imp'},
{c='M5D0P0',name='Cursed Village',t='Action - Doom'},
{c='M5D0P0',name='Sacred Grove',t='Action - Fate'},
{c='M5D0P0',name='Tragic Hero',t='Action'},
{c='M5D0P0',name='Pooka',t='Action',depend='Heirloom'},
{c='M4D0P0',name='Cemetery',t='Victory',depend='Ghost Heirloom',VP=2},
{c='M4D0P0',name='Skulk',t='Action - Attack - Doom'},
{c='M4D0P0',name='Blessed Village',t='Action - Fate'},
{c='M4D0P0',name='Bard',t='Action - Fate'},
{c='M4D0P0',name='Necromancer',t='Action',depend='Zombie'},
{c='M4D0P0',name='Conclave',t='Action'},
{c='M4D0P0',name='Shepherd',t='Action',depend='Heirloom'},
{c='M3D0P0',name='Secret Cave',t='Action - Duration',depend='Wish Heirloom'},
{c='M3D0P0',name='Fool',t='Action - Fate',depend='Heirloom'},
{c='M3D0P0',name='Leprechaun',t='Action - Doom',depend='Wish'},
{c='M2D0P0',name='Faithful Hound',t='Action - Reaction'},
{c='M2D0P0',name='Druid',t='Action - Fate'},
{c='M2D0P0',name='Tracker',t='Action - Fate',depend='Heirloom'},
{c='M2D0P0',name='Pixie',t='Action - Fate',depend='Heirloom'},
{c='M8D0P0',t='Project',name='Citadel'},
{c='M7D0P0',t='Project',name='Canal'},
{c='M6D0P0',t='Project',name='Innovation'},
{c='M6D0P0',t='Project',name='Crop Rotation'},
{c='M6D0P0',t='Project',name='Barracks'},
{c='M5D0P0',t='Project',name='Road Network'},
{c='M5D0P0',t='Project',name='Piazza'},
{c='M5D0P0',t='Project',name='Guildhall',depend='Coffers'},
{c='M5D0P0',t='Project',name='Fleet'},
{c='M5D0P0',t='Project',name='Capitalism'},
{c='M5D0P0',t='Project',name='Academy',depend='Villager'},
{c='M4D0P0',t='Project',name='Sinister Plot'},
{c='M4D0P0',t='Project',name='Silos'},
{c='M4D0P0',t='Project',name='Fair'},
{c='M4D0P0',t='Project',name='Exploration',depend='Coffers Villager'},
{c='M3D0P0',t='Project',name='Star Chart'},
{c='M3D0P0',t='Project',name='Sewers'},
{c='M3D0P0',t='Project',name='Pageant',depend='Coffers'},
{c='M3D0P0',t='Project',name='City Gate'},
{c='M3D0P0',t='Project',name='Cathedral'},
{c='MXDXPX',t='Artifact',name='Flag'},
{c='MXDXPX',t='Artifact',name='Horn'},
{c='MXDXPX',t='Artifact',name='Key'},
{c='MXDXPX',t='Artifact',name='Lantern'},
{c='MXDXPX',t='Artifact',name='Treasure Chest'},
{c='M5D0P0',name='Spices',t='Treasure',depend='Coffers'},
{c='M5D0P0',name='Scepter',t='Treasure'},
{c='M5D0P0',name='Villain',t='Action - Attack',depend='Coffers'},
{c='M5D0P0',name='Old Witch',t='Action - Attack'},
{c='M5D0P0',name='Treasurer',t='Action',depend='Artifact'},
{c='M5D0P0',name='Swashbuckler',t='Action',depend='Coffers Artifact'},
{c='M5D0P0',name='Seer',t='Action'},
{c='M5D0P0',name='Sculptor',t='Action',depend='Villager'},
{c='M5D0P0',name='Scholar',t='Action'},
{c='M5D0P0',name='Recruiter',t='Action',depend='Villager'},
{c='M4D0P0',name='Research',t='Action - Duration'},
{c='M4D0P0',name='Patron',t='Action - Reaction',depend='Coffers Villager'},
{c='M4D0P0',name='Silk Merchant',t='Action',depend='Coffers Villager'},
{c='M4D0P0',name='Priest',t='Action'},
{c='M4D0P0',name='Mountain Village',t='Action'},
{c='M4D0P0',name='Inventor',t='Action'},
{c='M4D0P0',name='Hideout',t='Action'},
{c='M4D0P0',name='Flag Bearer',t='Action',depend='Artifact'},
{c='M3D0P0',name='Cargo Ship',t='Action - Duration'},
{c='M3D0P0',name='Improve',t='Action'},
{c='M3D0P0',name='Experiment',t='Action'},
{c='M3D0P0',name='Acting Troupe',t='Action',depend='Villager'},
{c='M2D0P0',name='Ducat',t='Treasure',depend='Coffers'},
{c='M2D0P0',name='Lackeys',t='Action',depend='Villager'},
{c='M2D0P0',name='Border Guard',t='Action',depend='Artifact'},--MenagerieExpansion
{c='M2D0P0',name='Black Cat',t='Action - Attack - Reaction'},
{c='M2D0P0',name='Sleigh',t='Treasure',depend='Horse'},
{c='M2D0P0',name='Supplies',t='Treasure',depend='Horse'},
{c='M3D0P0',name='Camel Train',t='Action',depend='Exile'},
{c='M3D0P0',name='Goatherd',t='Action'},
{c='M3D0P0',name='Scrap',t='Action',depend='Horse'},
{c='M3D0P0',name='Sheepdog',t='Action - Reaction'},
{c='M3D0P0',name='Snowy Village',t='Action'},
{c='M3D0P0',name='Stockpile',t='Treasure',depend='Exile'},
{c='M4D0P0',name='Bounty Hunter',t='Action',depend='Exile'},
{c='M4D0P0',name='Cardinal',t='Action - Attack',depend='Exile'},
{c='M4D0P0',name='Cavalry',t='Action',depend='Horse'},
{c='M4D0P0',name='Groom',t='Action',depend='Horse'},
{c='M4D0P0',name='Hostelry',t='Action',depend='Horse'},
{c='M4D0P0',name='Village Green',t='Action - Duration - Reaction'},
{c='M5D0P0',name='Barge',t='Action - Duration'},
{c='M5D0P0',name='Coven',t='Action - Attack',depend='Exile'},
{c='M5D0P0',name='Displace',t='Action',depend='Exile'},
{c='M5D0P0',name='Falconer',t='Action - Reaction'},
{c='M5D0P0',name='Fisherman',t='Action'},
{c='M5D0P0',name='Gatekeeper',t='Action - Duration - Attack',depend='Exile'},
{c='M5D0P0',name='Hunting Lodge',t='Action'},
{c='M5D0P0',name='Kiln',t='Action'},
{c='M5D0P0',name='Livery',t='Action',depend='Horse'},
{c='M5D0P0',name='Mastermind',t='Action - Duration'},
{c='M5D0P0',name='Paddock',t='Action',depend='Horse'},
{c='M5D0P0',name='Sanctuary',t='Action',depend='Exile'},
{c='M6D0P0',name='Destrier',t='Action'},
{c='M6D0P0',name='Wayfarer',t='Action'},
{c='M7D0P0',name='Animal Fair',t='Action'},
{c='M3D0P0',name='Horse',t='Action'},
{c='M0D0P0',t='Way',name='Way of the Butterfly'},
{c='M0D0P0',t='Way',name='Way of the Camel',depend='Exile'},
{c='M0D0P0',t='Way',name='Way of the Chameleon'},
{c='M0D0P0',t='Way',name='Way of the Frog'},
{c='M0D0P0',t='Way',name='Way of the Goat'},
{c='M0D0P0',t='Way',name='Way of the Horse'},
{c='M0D0P0',t='Way',name='Way of the Mole'},
{c='M0D0P0',t='Way',name='Way of the Monkey'},
{c='M0D0P0',t='Way',name='Way of the Mouse'},
{c='M0D0P0',t='Way',name='Way of the Mule'},
{c='M0D0P0',t='Way',name='Way of the Otter'},
{c='M0D0P0',t='Way',name='Way of the Owl'},
{c='M0D0P0',t='Way',name='Way of the Ox'},
{c='M0D0P0',t='Way',name='Way of the Pig'},
{c='M0D0P0',t='Way',name='Way of the Rat'},
{c='M0D0P0',t='Way',name='Way of the Seal'},
{c='M0D0P0',t='Way',name='Way of the Sheep'},
{c='M0D0P0',t='Way',name='Way of the Squirrel'},
{c='M0D0P0',t='Way',name='Way of the Turtle',depend='Aside'},
{c='M0D0P0',t='Way',name='Way of the Worm',depend='Exile'},
{c='M0D0P0',t='Event',name='Delay',depend='Aside'},
{c='M0D0P0',t='Event',name='Desperation'},
{c='M2D0P0',t='Event',name='Gamble'},
{c='M2D0P0',t='Event',name='Pursue'},
{c='M2D0P0',t='Event',name='Ride',depend='Horse'},
{c='M2D0P0',t='Event',name='Toil'},
{c='M3D0P0',t='Event',name='Enhance'},
{c='M3D0P0',t='Event',name='March'},
{c='M3D0P0',t='Event',name='Transport',depend='Exile'},
{c='M4D0P0',t='Event',name='Banish',depend='Exile'},
{c='M4D0P0',t='Event',name='Bargain',depend='Horse'},
{c='M4D0P0',t='Event',name='Invest',depend='Exile'},
{c='M4D0P0',t='Event',name='Seize the Day',depend='Project'},
{c='M5D0P0',t='Event',name='Commerce'},
{c='M5D0P0',t='Event',name='Demand',depend='Horse'},
{c='M5D0P0',t='Event',name='Stampede',depend='Horse'},
{c='M7D0P0',t='Event',name='Reap'},
{c='M8D0P0',t='Event',name='Enclave',depend='Exile'},
{c='M10D0P0',t='Event',name='Alliance'},
{c='M10D0P0',t='Event',name='Populate'},--PromoSummonFirstPrintings
{c='M3D0P0',name='Black Market',t='Action'},
{c='M3D0P0',name='Church',t='Action - Duration'},
{c='M4D0P0',name='Envoy',t='Action'},
{c='M4D0P0',name='Dismantle',t='Action'},
{c='M4D0P0',name='Walled Village',t='Action'},
{c='M4D0P0',name='Sauna / Avanto',t='Action'},
{c='M4D0P0',name='Sauna',t='Action'},
{c='M5D0P0',name='Avanto',t='Action'},
{c='M5D0P0',name='Governor',t='Action'},
{c='M5D0P0',name='Stash',t='Treasure'},
{c='M6D0P0',name='Captain',t='Action - Duration - Command'},
{c='M8D0P0',name='Prince',t='Action',depend='Aside'},
{c='M5D0P0',name='Summon',t='Event',depend='Aside'},
{c='M6D0P0',name='Adventurer',t='Action'},
{c='M3D0P0',name='Chancellor',t='Action'},
{c='M4D0P0',name='Feast',t='Action'},
{c='M4D0P0',name='Spy',t='Action - Attack'},
{c='M4D0P0',name='Thief',t='Action - Attack'},
{c='M3D0P0',name='Woodcutter',t='Action'},
{c='M4D0P0',name='Coppersmith',t='Action'},
{c='M3D0P0',name='Great Hall',t='Action - Victory',VP=1},
{c='M5D0P0',name='Saboteur',t='Action - Attack'},
{c='M4D0P0',name='Scout',t='Action'},
{c='M2D0P0',name='Secret Chamber',t='Action - Reaction'},
{c='M5D0P0',name='Tribute',t='Action'},
{c='M5D0P0',name='Original Band of Misfits',t='Action'},
{c='D8M0P0',name='Original Overlord',t='Action'},
{c='M6D0P0',name='Original Captain',t='Action - Duration'},
--X'tra's
{c='MXDXP0',t='Landmark',name='Xv1 El Dorado',depend='Artifact'},
{c='M2D0P0',name='X Handler v1',t='Action'},
{c='M2D0P0',name='X Hops v1',t='Treasure - Duration'},
{c='M2D0P0',name='X Smithing Tools',t='Action - Duration'},
{c='M2D0P0',name='X Stallions',t='Action - Stallion',depend='Horse'},
{c='M2D0P1',name='X Wat',t='Treasure - Victory',VP=1},
{c='M3D0P0',name='X Informer',t='Action - Command'},
{c='M3D0P0',name='X Notary',t='Action',depend='Heir'},
{c='M4D0P0',name='X Lease',t='Action'},
{c='M4D0P0',name='X Lessor',t='Action - Attack'},
{c='M4D0P0',name='X Statue v1',t='Action - Victory',depend='Aside'},
{c='M4D0P0',name='X Vigil v1',t='Action - Attack'},
{c='M4D0P0',name='X Watchmaker',t='Action - Reserve'},
{c='M5D0P0',name='X Plague Doctor v1',t='Action - Attack - Duration'},
{c='M5D0P0',name='X Savings',t='Treasure'},
{c='M5D0P0',name='X Tithe v1',t='Action - Attack - Reserve - Duration',depend='Debt'},
{c='M6D0P0',name='X Grand Laboratory',t='Action'},
{c='M2D0P0',name='X Shetland Pony',t='Action - Stallion'},
{c='M3D0P0',name='X Clydesdale',t='Action - Stallion'},
{c='M4D0P0',name='X Appaloosa',t='Action - Stallion'},
{c='M5D0P0',name='X Paint Horse',t='Action - Stallion'},
{c='M6D0P0',name='X Gypsy Vanner',t='Action - Stallion'},
{c='M7D0P0',name='X Mustang',t='Action - Victory - Stallion',VP=2},
{c='M8D0P0',name='X Friesian',t='Action - Victory - Stallion',VP=3},
{c='M9D0P0',name='X Arabian Horse',t='Victory - Stallion'},
--Wonders http://forum.dominionstrategy.com/index.php?topic=20401.msg844160#msg844160
--X'v2 http://forum.dominionstrategy.com/index.php?topic=20407.0
{c='MXDXP0',t='Landmark',name='X Clock Tower',depend='VP'},
{c='MXDXP0',t='Landmark',name='X El Dorado',depend='Artifact'},
{c='M0D0P2',t='Project',name='X Science Grant'},
{c='M0D0P0',t='Event',name='X Debate',depend='Debt VP'},
{c='M3D0P0',t='Event',name='X Truce',depend='Artifact'},
{c='M0D0P0',t='State',name='X Collecting Artifacts'},
{c='M0D0P0',t='Artifact',name='X Pact'},
{c='M0D5P0',name='X Dice Games',t='Action'},
{c='M0D0P0',name='X Draft',t='Action'},
{c='M2D0P0',name='X Handler',t='Action'},
{c='M2D0P0',name='X Hops',t='Treasure - Duration'},
{c='M3D0P0',name='X Secret Path',t='Action - Duration - Victory',VP=1},
{c='M4D0P0',name='X Duality',t='Action'},
{c='M4D0P0',name='X Statue',t='Action - Victory'},
{c='M4D0P0',name='X Stray Cat',t='Action - Reserve'},
{c='M4D0P0',name='X Vigil',t='Action'},
{c='M4D0P0',name='X Watchmaker',t='Action - Reserve'},
{c='M4D3P0',name='X Mobsters',t='Night - Treasure'},
{c='M5D0P0',name='X Custodian',t='Night - Attack - Duration'},
{c='M5D0P0',name='X Market Town',t='Action'},
{c='M5D0P0',name='X Plague Doctor',t='Action - Attack - Duration'},
{c='M5D0P0',name='X Tithe',t='Action - Attack - Reserve - Duration',depend='Debt'},
{c='M7D0P0',name='X Ballroom',t='Action'},
--Antiquities
{c='M5D0P0',name='Q Agora',t='Action - Reaction',depend='BT'},
{c='M4D0P0',name='Q Aquifer',t='Action',depend='BT'},
{c='M7D0P0',name='Q Archaeologist',t='Action',depend='BT'},
{c='M4D0P0',name='Q Boulder Trap',t='Trap',depend='BT',VP=-1},
{c='M4D0P0',name='Q Collector',t='Action',depend='BT'},
{c='M4D0P0',name='Q Curio',t='Treasure',depend='BT'},
{c='M8D0P0',name='Q Dig',t='Action',depend='VP BT'},
{c='M2D0P0',name='Q Discovery',t='Treasure',depend='BT'},
{c='M6D0P0',name='Q Encroach',t='Action',depend='BT'},
{c='M3D0P0',name='Q Gamepiece',t='Treasure - Reaction',depend='BT'},
{c='M3D0P0',name='Q Grave Watcher',t='Action - Attack',depend='BT'},
{c='M1D0P0',name='Q Graveyard',t='Action',depend='BT'},
{c='M3D0P0',name='Q Inscription',t='Action - Reaction',depend='BT'},
{c='M3D0P0',name='Q Inspector',t='Action - Attack',depend='BT'},
{c='M5D0P0',name='Q Mastermind Antiquities',t='Action',depend='BT'},
{c='M6D0P0',name='Q Mausoleum',t='Action',depend='Aside Memory BT'},
{c='M4D0P0',name='Q Mendicant',t='Action',depend='VP BT'},
{c='M3D0P0',name='Q Miner',t='Action',depend='BT'},
{c='M5D0P0',name='Q Mission House',t='Action',depend='VP BT'},
{c='M4D0P0',name='Q Moundbuilder Village',t='Action',depend='BT'},
{c='M8D0P0',name='Q Pharaoh',t='Action - Attack',depend='BT'},
{c='M3D0P0',name='Q Profiteer',t='Action',depend='BT'},
{c='M5D0P0',name='Q Pyramid',t='Action',depend='BT'},
{c='M3D0P0',name='Q Shipwreck',t='Action',depend='BT'},
{c='M4D0P0',name='Q Snake Charmer',t='Action - Attack',depend='BT'},
{c='M4D0P0',name='Q Stoneworks',t='Action',depend='VP BT'},
{c='M5D0P0',name='Q Stronghold',t='Action - Reaction',depend='BT'},
{c='M3D0P0',name='Q Tomb Raider',t='Action - Attack',depend='BT'},
--Legacy
{c='M0D0P0',t='Edict',name='L Trade Agreement'},
{c='M0D0P0',t='Edict',name='L Supervision'},
{c='M0D0P0',t='Edict',name='L Simplicity',depend='Villager'},
{c='M0D0P0',t='Edict',name='L Monarchy'},
{c='M0D0P0',t='Edict',name='L Inflation'},
{c='M0D0P0',t='Edict',name='L Imperialism',depend='Platinum'},
{c='M0D0P0',t='Edict',name='L Gigantism'},--3 More supply piles
{c='M0D0P0',t='Edict',name='L Expansion',depend='MinusCoin'},
{c='M0D0P0',t='Edict',name='L Exile',depend='Aside'},
{c='M0D0P0',t='Edict',name='L Diplomacy'},
{c='M0D0P0',t='Edict',name='L Banishment'},
{c='M0D0P0',t='Edict',name='L Appeasement'},
{c='M0D0P0',t='Edict',name='L Tyranny',depend='MinusCoin'},
{c='M0D0P0',t='Edict',name='L Urbanisation'},--Replace estate/shelter with copper
{c='M3D0P0',t='Event',name='L Exodus'},
{c='M6D0P0',t='Event',name='L Contest'},--Makes a Contest pile of 10 5Costs
{c='M0D0P0',t='Event',name='L Blessing'},
{c='M5D0P0',t='Event',name='L Bureaucracy'},--token on Province pile
{c='M6D0P0',t='Event',name='L Bargain',depend='Coffers'},
{c='M0D0P1',t='Event',name='L Research'},
{c='M0D0P0',t='Event',name='L Tithe'},
{c='M3D0P0',t='Event',name='L Plundering',depend='Spoils'},
{c='M3D0P0',t='Event',name='L Parting',depend='Journey'},
{c='M5D0P0',t='Event',name='L Improve'},
{c='M1D0P0',name='L Alley',t='Action'},
{c='M2D0P0',name='L Decree',t='Treasure'},
{c='M2D0P0',name='L Sunken City',t='Action - Duration'},
{c='M3D0P0',name='L Nun',t='Action'},
{c='M3D0P0',name='L Sawmill',t='Action'},
{c='M3D0P0',name='L Shrine',t='Action'},
{c='M3D0P0',name='L Well',t='Action'},
{c='M4D0P0',name='L Docks',t='Action - Duration'},
{c='M4D0P0',name='L Farmer',t='Action'},
{c='M4D0P0',name='L Gallows',t='Action'},
{c='M4D0P0',name='L Heir Legacy',t='Action'},
{c='M4D0P0',name='L Landlord',t='Action'},
{c='M5D0P0',name='L Assemble',t='Action'},
{c='M5D0P0',name='L Cliffside Village',t='Action'},
{c='M5D0P0',name='L Craftsmen',t='Action'},
{c='M5D0P0',name='L Lycantrope',t='Action - Attack'},
{c='M5D0P0',name='L Maze',t='Action - Victory - Attack'},
{c='M5D0P0',name='L Sultan',t='Action'},
{c='M5D0P0',name='L Tribunal',t='Action - Attack'},
{c='M6D0P0',name='L Meadow',t='Victory',VP=2},
--LegacyFeats
{c='M2D0P0',name='L Headhunter',t='Action - Fame'},
{c='M4D0P0',name='L Curiosity Shop',t='Action - Fame'},
{c='M4D0P0',name='L Imposter',t='Action - Fame'},
{c='M5D0P0',name='L Adventure-Seeker',t='Action - Fame'},
{c='M5D0P0',name='L Inquisitor',t='Action - Attack - Fame'},
{c='M6D0P0',name='L Hall of Fame',t='Victory - Fame'},
--LegacyExpert
{c='M0D0P1',name='L Homunculus',t='Action'},
{c='M0D8P0',name='L Promenade',t='Action'},
{c='M0D8P0',name='L Institute',t='Action'},
{c='M2D0P0',name='L Sheriff',t='Action - Attack'},
{c='M2D0P0',name='L Swamp',t='Action',depend='Imp Ghost'},
{c='M3D0P0',name='L Iron Maiden',t='Action - Attack - Looter'},
{c='M3D0P1',name='L Incantation',t='Action'},
{c='M3D0P0',name='L Pilgrim',t='Action',depend='Coffers'},
{c='M3D0P0',name='L Scientist',t='Action',depend='Debt'},
{c='M4D0P0',name='L Hunter',t='Action - Reserve'},
{c='M4D0P0',name='L Lady-in-waiting',t='Action - Reserve'},
{c='M4D0P0',name='L Scribe',t='Action - Attack - Duration',depend='Debt'},
{c='M4D0P0',name='L Town',t='Action'},
{c='M4D0P0',name='L Waggon Village',t='Action',depend='Debt'},
{c='M5D0P0',name='L Delegate',t='Action'},
{c='M5D0P0',name='L Lich',t='Action',depend='Zombie'},
{c='M5D0P0',name='L Necromancer Legacy',t='Action'},
{c='M5D0P0',name='L Sanctuary',t='Action'},
{c='M6D0P0',name='L Minister',t='Action',depend='VP'},
{c='M0D0P0',name='L Road',t='Action'},
{c='M3D0P0',name='L Skeleton',t='Action - Attack'},
{c='M3D0P0',name='L Zombie Legacy',t='Action - Attack'},
{c='M3D0P0',name='L Loyal Subjects',t='Action - Attack'},
--LegacyTeams
{c='M2D0P0',name='L Steeple',t='Action - Team'},
{c='M3D0P0',name='L Conman',t='Action - Team'},
{c='M3D0P0',name='L Fisher',t='Action - Reaction - Team'},
{c='M4D0P0',name='L Merchant Quarter',t='Action - Team'},
{c='M4D0P0',name='L Study',t='Action - Team'},
{c='M4D0P0',name='L Still Village',t='Action - Duration - Team'},
{c='M5D0P0',name='L Salesman',t='Action - Team'},
{c='M5D0P0',name='L Sponsor',t='Action - Team'},
--Spellcasters
{c='M2D0P0',t='Spell',name='S Wisdom'},
{c='M4D0P0',t='Spell',name='S Wealth'},
{c='M2D0P0',t='Spell',name='S Purity'},
{c='M3D0P0',t='Spell',name='S Harm'},
{c='M8D0P0',t='Spell',name='S Glory'},
{c='M1D0P0',t='Spell',name='S Esprit'},
{c='M4D0P0',t='Spell',name='S Dexterity'},
{c='M2D0P0',name='S Trickster',t='Action - Spellcaster'},
{c='M3D0P0',name='S Stone Circle',t='Victory - Spellcaster',VP=2},
{c='M3D0P0',name='S Magician',t='Action - Spellcaster'},
{c='M3D0P0',name='S Shaman',t='Action - Spellcaster'},
{c='M4D0P0',name='S Summoner',t='Action - Spellcaster'},
{c='M4D0P0',name='S Grimoire',t='Treasure - Spellcaster'},
{c='M5D0P0',name='S Sorcerer',t='Action - Spellcaster'},
{c='M5D0P0',name='S Wizard',t='Action - Spellcaster'},
--Seasons
{c='M2D0P0',name='S Sojourner',t='Action - Season'},
{c='M3D0P0',name='S Bailiff',t='Action - Season'},
{c='M3D0P0',name='S Snow Witch',t='Action - Attack - Season'},
{c='M3D0P0',name='S Student',t='Action - Season',depend='Following PlusCard PlusAction PlusBuy PlusCoin'},
{c='M4D0P0',name='S Barbarian',t='Action - Season'},
{c='M4D0P0',name='S Lumbermen',t='Action - Season'},
{c='M4D0P0',name='S Peltmonger',t='Action - Season'},
{c='M4D0P0',name='S Sanitarium',t='Action - Season'},
{c='M4D0P0',name='S Timberland',t='Victory - Season',depend='VP',VP=2},
{c='M5D0P0',name='S Ballroom',t='Action - Season'},
{c='M5D0P0',name='S Cottage',t='Action - Season'},
{c='M5D0P0',name='S Fjord Village',t='Action - Season'},
{c='M5D0P0',name='S Plantation',t='Action - Season'},
{c='M5D0P0',name='S Restore',t='Action - Season'},
--Tools http://forum.dominionstrategy.com/index.php?topic=20273.0
{c='M4D0P0',name='T Armor',t='Tool'},
{c='M4D0P0',name='T Axe',t='Tool'},
{c='M5D0P0',name='T Bag of Holding',t='Tool'},
{c='M4D0P0',name='T Bow and Arrow',t='Tool - Attack'},
{c='M2D0P0',name='T Compass',t='Tool'},
{c='M5D0P0',name='T Moccasins',t='Tool'},
{c='M5D0P0',name='T Rations',t='Tool'},
{c='M6D0P0',name='T Spellbook',t='Tool - Command'},
{c='M5D0P0',name='T Sword',t='Tool'},
{c='M3D0P0',name='T Telescope',t='Tool'},
{c='M3D0P0',name='T Wagon',t='Tool'},
{c='M5D0P0',name='T Battalion',t='Action'},
{c='M0D0P0',name='T Broken Sword',t='Tool'},
{c='M5D0P0',name='T Charlatan',t='Action'},
{c='M0D0P0',name='T Cursed Antique',t='Tool'},
--Roots&Renewal http://forum.dominionstrategy.com/index.php?topic=11563.0
{c='MXDXP0',t='Landmark',name='R Chancellery'},
{c='M0D0P0',name='R Realm Tax',t='Treasure'},
{c='M2D0P0',name='R Refugees',t='Action'},
{c='M2D0P0',name='R Salesman',t='Action - Reserve'},
{c='M2D0P0',name='R Trapper',t='Action'},
{c='M3D0P0',name='R Deposit',t='Action'},
{c='M3D0P0',name='R Petty Lord',t='Action - Traveller - Looter',depend='Prime'},
{c='M3D0P0',name='R Provisioner',t='Action'},
{c='M4D0P0',name='R Builder',t='Action - Reaction'},
{c='M4D0P0',name='R Mining Camp',t='Action - Looter'},
{c='M4D0P0',name='R Orphanage',t='Action',depend='VP'},
{c='M4D0P0',name='R Reconvert',t='Action'},
{c='M4D0P0',name='R Reeve',t='Action',depend='Estate'},
{c='M4D0P0',name='R Shire',t='Victory - Reaction'},
{c='M5D0P0',name='R Beachcomb',t='Action'},
{c='M5D0P0',name='R Benefit',t='Action - Reaction'},
{c='M5D0P0',name='R Building Crane',t='Action'},
{c='M5D0P0',name='R Juggler',t='Action'},
{c='M5D0P0',name='R Reparations',t='Treasure'},
{c='M5D0P0',name='R Revaluate',t='Action',depend='Prime'},
{c='M6D0P0',name='R Riverside',t='Victory'},
{c='M4D0P0',name='R Lock / Caretaker',t='Treasure'},
{c='M4D0P0',name='R Lock',t='Treasure'},
{c='M5D0P0',name='R Caretaker',t='Action'},
{c='M4D0P0',name='R Key',t='Treasure'},
{c='M1D0P0',name='R Forest Hut',t='Action - Shelter'},
{c='M5D0P0',name='R Robber Knight',t='Action - Attack - Looter - Traveller'},
{c='M5D0P0',name='R Protector',t='Action - Traveller'},
{c='M7D0P0',name='R Warlord',t='Action - Attack'},
{c='M7D0P0',name='R Savior',t='Action'},
{c='M3D0P0',name='R Battlement',t='Action - Reaction'},
{c='M0D0P0',name='R Manor',t='Action'},
--Adamabrams
{c='M6D0P0',name='C Mortgage',t='Project',depend='Debt'},
{c='M0D0P0',name='C Lost Battle',t='Landmark',depend='VP'},
{c='M4D0P0',name='C Cave',t='Night - Victory',VP=2,depend='Artifact'},
{c='M4D0P0',name='C Chisel',t='Action - Reserve',depend='Artifact'},
{c='M7D0P0',name='C Knockout',t='Event',depend='Artifact'},
{c='M1D0P1',name='C Migrant Village',t='Action',depend='Villager'},
{c='M4D0P0',name='C Discretion',t='Action - Reserve',depend='VP Coffers Villager'},
{c='M4D0P0',name='C Plot',t='Night',depend='VP'},
{c='M4D0P0',name='C Investor',t='Action',depend='Debt'},
{c='M6D0P0',name='C Contest',t='Action - Looter',depend='Prize'},
{c='M6D0P0',name='C Uneven Road',t='Action - Victory',depend='Estate',VP=3},
{c='M3D0P1',name='C Jekyll',t='Action'},
{c='M4D0P1',name='C Hyde',t='Night - Attack'},
{c='M5D0P0',name='C Stormy Seas',t='Night',depend='Debt'},
{c='M0D4P0',name='C Liquid Luck',t='Action - Fate',depend='VP Potion'},
{c='M6D0P0',name='C Cheque',t='Treasure - Command'},
{c='M2D0P0',name='C Balance',t='Action - Reserve - Fate - Doom'},
--Co0kieL0rd http://forum.dominionstrategy.com/index.php?topic=13625.0
--icon https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Emojione_BW_1F36A.svg/768px-Emojione_BW_1F36A.svg.png
{c='MXDXP0',t='Landmark',name='C Volcano'},
{c='MXDXP0',t='Landmark',name='C Masque'},
{c='M4D0P0',name='C Bog Village',t='Action'},
{c='M5D0P0',name='C Cabal',t='Action - Attack'},
{c='M0D0P0',name='C Turncoat',t='Action'},
{c='M4D0P0',name='C Guest of Honor',t='Action - Reserve',depend='VP'},
{c='M4D0P0',name='C Demagogue',t='Action - Attack'},
{c='M3D0P0',name='C Draft Horses',t='Action'},
{c='M4D0P0',name='C Dry Dock',t='Action - Duration'},
{c='M4D0P0',name='C Dock',t='Action - Duration'},
{c='M5D0P0',name='C Mediator',t='Action',depend='VP'},
{c='M2D0P0',name='C Money Launderer',t='Action'},
{c='M5D0P0',name='C Prefect',t='Action - Reserve',depend='Aside'},
{c='M4D0P0',name='C Regal Decree',t='Action'},
{c='M5D0P0',name='C Routing',t='Action'},
{c='M4D0P0',name='C Secret Society',t='Action',depend='BlackMarket'},
{c='M4D0P0',name='C Reconvert',t='Action'},
{c='M4D0P0',name='C Mount',t='Action'},
{c='M4D0P0',name='C Blackmail',t='Action'},
{c='M5D0P0',name='C Search Party',t='Action'},
{c='M3D0P0',name='C Suburb',t='Action - Reaction'},
{c='M3D0P0',name='C Tollkeeper',t='Action - Duration'},
--Witches https://www.reddit.com/r/dominion/comments/hjwi11/witch_variants_for_every_expansion_day_7/
{c='M5D0P0',name='W Equestrian Witch',t='Action - Attack',depend='Horse'},
{c='M0D0P1',name='W Resourceful Witch',t='Action - Attack'},
{c='M5D0P0',name='W Eclectic Witch',t='Action - Attack'},
{c='M4D0P0',name='W Slum Witch',t='Action - Attack'},
{c='M4D0P0',name='W Hedge Witch',t='Action - Attack - Gathering',depend='VP'},
{c='M3D0P0',name='W Invoking Witch / W Summoned Fiend',t='Action - Attack'},
{c='M5D0P0',name='W Summoned Fiend',t='Action - Attack - Doom'},
{c='M4D0P0',name='W Miserly Witch',t='Action - Attack'},
{c='M0D0P0',name='W Cursed Copper',t='Treasure - Curse',VP=-1},
--https://imgur.com/gallery/iaIN7iP
{c='M4D0P0',name='W Faustian Witch',t='Action - Attack',depend='Reserve'},
{c='M0D0P0',name='W Cursed Bargain',t='Treasure - Reserve - Curse',VP=-3},
{c='M6D2P0',name='W Devious Witch',t='Action - Attack'},
--https://imgur.com/gallery/lx1BnPg
{c='M3D0P0',name='W Rummaging Witch',t='Action - Attack'},
{c='M2D0P0',name='W Retired Witch',t='Action - Attack',depend='Coffers'},
--https://imgur.com/gallery/18UZBgV
{c='M4D0P0',name='W Nosy Witch',t='Action - Attack'},
{c='M6D0P0',name='W Wandering Witch',t='Action - Attack - Reaction'},
--https://imgur.com/gallery/KV0V01h
{c='M3D0P1',name='W Poisonous Witch',t='Action - Attack'},
{c='M0D0P0',name='W Cursed Beverage',t='Treasure - Curse',VP=-2},
{c='M5D0P0',name='W Prideful Witch',t='Action - Attack',depend='VP'},
--https://imgur.com/gallery/aLFCmWI
{c='M4D0P0',name='W Versatile Witch',t='Action - Attack'},
{c='M6D0P0',name='W Vengeful Witch',t='Action - Attack - Duration'},
--https://imgur.com/a/mw9c4N0
{c='M5D0P0',name='W Ghostly Witch',t='Night - Attack'},
{c='M0D0P0',name='W Ethereal Curse',t='Night - Curse',VP=-1},
{c='M4D0P0',name='W Neighborhood Witch',t='Action',depend='Artifact Villager'},
{c='MXDXPX',t='Artifact',name='W Cauldron'},
--Venus http://forum.dominionstrategy.com/index.php?topic=20585.0
{c='MXDXPX',t='Way',name='V Way of the Centaur',depend='Horse'},
{c='MXDXPX',t='Way',name='V Way of the Mermaid'},
{c='MXDXPX',t='Way',name='V Way of the Sphinx'},
{c='MXDXPX',t='Way',name='V Way of the Harpy'},
{c='MXDXPX',t='Way',name='V Way of the Medusa'},
{c='MXDXPX',t='Way',name='V Way of the She-Wolf',depend='Doom'},
{c='M0DXPX',t='Event',name='V Joy'},
{c='M0DXPX',t='Event',name='V Lending',depend='Debt'},
{c='M1DXPX',t='Event',name='V Burnish'},
{c='M2DXPX',t='Event',name='V Footbridge'},
{c='MXD4PX',t='Event',name='V Bride Wait',depend='Aside'},
{c='M4DXPX',t='Event',name='V Calmness',depend='MinusCard'},
{c='M5DXPX',t='Event',name='V Burning'},
{c='M5DXPX',t='Event',name='V Restrain'},
{c='M6DXPX',t='Event',name='V Cursed Land'},
{c='M6DXPX',t='Event',name='V Pandora\'s Box'},
{c='MXD7PX',t='Event',name='V Birth of Venus'},
{c='M3DXPX',t='Project',name='V Veil of Protection'},
{c='M3DXPX',t='Project',name='V Phoenix'},
{c='M4DXPX',t='Project',name='V Divination'},
{c='M6DXPX',t='Project',name='V Seasons Grace',depend='Jorney'},
{c='MXD8PX',t='Project',name='V Greate Cathedral',depend='Exile'},
{c='MXD12PX',t='Project',name='V Land Grant'},
{c='MXDXPX',t='Landmark',name='V Acreage'},
{c='MXDXPX',t='Landmark',name='V Barony'},
{c='MXDXPX',t='Landmark',name='V Bishopric'},
{c='MXDXPX',t='Landmark',name='V County'},
{c='MXDXPX',t='Landmark',name='V Domain'},
{c='MXDXPX',t='Landmark',name='V Gold Mine'},
{c='MXDXPX',t='Landmark',name='V Grange'},
{c='MXDXPX',t='Landmark',name='V Virgin Lands'},
{c='MXDXPX',t='Landmark',name='V Yards'},
{c='M0D0P0',name='V Jane Doe',t='Action',depend='VP Coffers Villager Horse'},
{c='M2D0P0',name='V Healer',t='Action - Reaction'},
{c='M2D0P0',name='V Mirror',t='Action'},
{c='M2D0P0',name='V Monk',t='Action',depend='VP Exile'},
{c='M2D0P0',name='V Small Village',t='Action'},
{c='M2D0P0',name='V Taverner',t='Action - Reserve'},
{c='M2D0P0',name='V Wanderer',t='Action'},
{c='M3D0P0',name='V Big Hall',t='Action',depend='VP'},
{c='M3D0P0',name='V Flame Keeper',t='Action'},
{c='M3D0P0',name='V Gambler',t='Action'},
{c='M3D0P0',name='V Horse Lady',t='Action',depend='Horse Exile'},
{c='M3D0P0',name='V Hoyden',t='Action'},
{c='M3D0P0',name='V Maid',t='Action'},
{c='M3D0P0',name='V Minstrel',t='Action'},
{c='M3D0P0',name='V Morning',t='Action'},
{c='M3D0P0',name='V Native',t='Action'},
{c='M3D0P0',name='V Nurse',t='Night'},
{c='M3D0P0',name='V Nymphs',t='Action'},
{c='M3D0P0',name='V Resistance',t='Action'},
{c='M3D0P0',name='V Sisterhood',t='Action'},
{c='M3D0P0',name='V Valkyries',t='Action - Reaction',depend='Horse'},
{c='M3D0P0',name='V Workers',t='Action',depend='Villager'},
{c='M4D0P0',name='V Amazon',t='Action',depend='Horse'},
{c='M4D0P0',name='V Blind Bet',t='Action'},
{c='M4D0P0',name='V Bootleg',t='Action',depend='BlackMarket'},
{c='M4D0P0',name='V Clown',t='Action - Attack'},
{c='M4D0P0',name='V Dame',t='Action',depend='Horse'},
{c='M4D0P0',name='V Duplication',t='Action',depend='VP'},
{c='M4D0P0',name='V Emissary',t='Action - Attack'},
{c='M4D0P0',name='V Expectancy',t='Action',depend='Aside Exile'},
{c='M4D0P0',name='V Expulsion',t='Action - Attack'},
{c='M4D0P0',name='V Faithful Knight',t='Action',depend='VP Coffers Villager'},
{c='M4D0P0',name='V Fairy',t='Action'},
{c='M4D0P0',name='V Four Seasons',t='Action'},
{c='M4D0P0',name='V Ghost Pirate',t='Action - Attack'},
{c='M4D0P0',name='V Gladiatrix',t='Action'},
{c='M4D0P0',name='V Gravedigger',t='Night - Duration'},
{c='M4D0P0',name='V Guildmaster',t='Action - Command',depend='Coffers'},--NoviceCards
{c='M4D0P0',name='V Heiress',t='Action'},
{c='M4D0P0',name='V Hidden Pond',t='Victory'},
{c='M4D0P0',name='V Immolator',t='Action'},
{c='M4D0P0',name='V Jewelry',t='Action - Treasure'},
{c='M4D0P0',name='V Money Trick',t='Treasure - Reaction',depend='Coffers'},
{c='M4D0P0',name='V Night Ranger',t='Night',depend='Journey'},
{c='M4D0P0',name='V Privilege',t='Action'},
{c='M4D0P0',name='V Sacred Hall',t='Action - Victory',depend='VP'},
{c='M4D0P0',name='V Secret Place',t='Action',depend='Aside'},
{c='M4D0P0',name='V Succubus',t='Night - Reserve'},
{c='M4D0P0',name='V Tavern Show',t='Action - Command',depend='Reserve'},
{c='M4D0P0',name='V Tiara',t='Treasure'},
{c='M4D0P0',name='V Voyage',t='Action'},
{c='M4D0P0',name='V Warrioresses',t='Action - Attack - Duration',depend='Exile'},
{c='M4D0P0',name='V Wishing Fountain',t='Action'},
{c='M4D0P0',name='V Tale-Teller',t='Night'},
{c='M5D0P0',name='V Archeologist',t='Action - Duration',depend='Looter'},
{c='M5D0P0',name='V Banker',t='Action'},
{c='M5D0P0',name='V Blessing',t='Action',depend='Wish'},
{c='M5D0P0',name='V Buffoon',t='Action - Attack - Command'},
{c='M5D0P0',name='V Circus Camp',t='Action'},
{c='M5D0P0',name='V Crusader',t='Action'},
{c='M5D0P0',name='V Dangerous Ground',t='Action'},
{c='M5D0P0',name='V Dusk Warrior',t='Action - Duration'},
{c='M5D0P0',name='V Fertility',t='Action'},
{c='M5D0P0',name='V Golden Spoils',t='Treasure'},
{c='M5D0P0',name='V Hands of Gold',t='Night',depend='Villager'},
{c='M5D0P0',name='V Lanterns',t='Action'},
{c='M5D0P0',name='V Librarian',t='Action - Duration'},
{c='M5D0P0',name='V Magic Archive',t='Action - Duration'},
{c='M5D0P0',name='V Magic Library',t='Action - Reaction'},
{c='M5D0P0',name='V Maneuver',t='Action'},
{c='M5D0P0',name='V Marketplace',t='Action'},
{c='M5D0P0',name='V Nightmare',t='Action - Attack'},
{c='M5D0P0',name='V Nomad',t='Action'},
{c='M5D0P0',name='V Path',t='Action'},
{c='M5D0P0',name='V Rebel',t='Action - Duration - Attack'},
{c='M5D0P0',name='V Samurai',t='Action',depend='Coffers Villager'},
{c='M5D0P0',name='V Shenanigans',t='Action - Attack'},
{c='M5D0P0',name='V Shipmaster',t='Action - Duration'},
{c='M5D0P0',name='V Swinehero',t='Action - Duration'},
{c='M5D0P0',name='V Tavern Nights',t='Night - Reserve'},
{c='M5D0P0',name='V Janus',t='Action',depend='Journey'},
{c='M5D0P0',name='V Councillor',t='Action'},
{c='M6D0P0',name='V Distant Island',t='Victory',depend='Exile',VP=2},
{c='M6D0P0',name='V Paladin',t='Action'},
{c='M7D0P0',name='V Swamp',t='Action - Victory',VP=-1},
{c='M4D0P0',name='V Fruits / Fruit Mix',t='Treasure',depend='Coffers'},
{c='M4D0P0',name='V Fruits',t='Treasure',depend='Coffers'},
{c='M6D0P0',name='V Fruit Mix',t='Treasure',depend='Coffers'},
{c='M5D0P0',name='V Bewitch',t='Action',depend='SpellV'},
{c='M4D0P0',name='V Witchcraft',t='Action - Duration - Attack',depend='SpellV'},
{c='M4D0P0',name='V Spellbound',t='Night',depend='VP SpellV'},
--NonSupplyVenus
{c='M0D0P0',name='V Spell',t='Action - Victory',VP=-1},
{c='M0D0P0',name='V Young Saboteur',t='Action - Novice'},
{c='M0D0P0',name='V Young Sorceress',t='Action - Novice'},
{c='M0D0P0',name='V Young Smith',t='Action - Novice'},
{c='M0D0P0',name='V Young Trickster',t='Action - Novice',depend='Coffers'},
{c='M2D0P0',name='V Coin of Honor',t='Treasure - Heirloom'},
{c='M2D0P0',name='V Blessed Gems',t='Treasure - Heirloom'},
{c='M6D0P0',name='V Spring',t='Action - Traveller - Season'},
{c='M6D0P0',name='V Summer',t='Action - Traveller - Season'},
{c='M6D0P0',name='V Fall',t='Action - Traveller - Season'},
{c='M6D0P0',name='V Winter',t='Action - Traveller - Season'},
{c='M2D0P0',name='V Harpy',t='Action - Attack'},
{c='M2D0P0',name='V Medusa',t='Action - Attack'},
{c='M2D0P0',name='V She-Wolf',t='Action - Attack - Doom'},
--Custom https://www.reddit.com/r/dominion/comments/hrx0rb/original_new_cards_i_made_hope_you_enjoy1_lol/
{c='MXDXPX',t='Artifact',name='Letter'},
{c='MXDXPX',t='Artifact',name='Statue'},
{c='MXDXPX',t='Artifact',name='Torch'},
{c='MXDXPX',t='Artifact',name='Champion\'s Belt'},
{c='M5D0P0',name='C Burned Village',t='Action - Night'},
{c='M4D0P0',name='C Rescuers',t='Treasure - Heirloom'},
{c='M5D0P0',name='C Ancient Coin',t='Treasure - Duration'},
{c='M5D0P0',name='C Witching Hour',t='Night - Duration - Attack'},
{c='M4D0P0',name='C Panda / Gardener',t='Action',depend='Coffers Villager'},
{c='M4D0P0',name='C Panda',t='Action'},
{c='M6D0P0',name='C Gardener',t='Action'},
{c='M0D0P8',name='C Bacchanal',t='Night',depend='Villager'},
{c='M4D0P0',name='C Homestead',t='Action'},
{c='M4D0P0',name='C Tulip Field',t='Victory',depend='Coffers Villager'},
{c='M5D0P0',name='C Backstreet',t='Night',depend='Coffers Villager'},
{c='M0D0P0',name='C Rabbit',t='Action - Treasure'},
{c='M5D0P0',name='C Magician',t='Action',depend='Rabbit Coffers'},
{c='M4D0P0',name='C Fishing Boat',t='Action - Duration'},
{c='M3D0P0',name='C Drawbridge',t='Action - Reserve'},
{c='M4D0P0',name='C Jinxed Jewel v1',t='Treasure - Night - Heirloom'},
{c='M4D0P0',name='C Jinxed Jewel',t='Treasure - Night - Heirloom',depend='Heirloom'},
{c='M0D0P0',name='',t='Shelter'},
{c='M0D0P0',name='-1 Card Token',t=''}
}