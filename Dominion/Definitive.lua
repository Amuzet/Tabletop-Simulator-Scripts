--DominionDefinitiveEditionModifiedByAmuzet2023_07_15
VERSION,GITURL=2.9,'https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Dominion/Definitive.lua'
--[[TODO:
Program Rotate for Allies Split Piles
Change background to Regal
Find Crash after 'cutcSetup'
Rules in the Empty area
Expansion Description
Description of what the buttons do
Display what expansions are being used Above the Table
Custom Card Importer
Tools expansion cards named incorrectly
REDDIT WEEKLY KINGDOM: https://www.reddit.com/r/dominion/search?q=title%3Akotw+author%3Aavocadro&sort=newl&utm_name=dominion&t=week&raw_json=0
KINGDOM IMPORTER: https://dominionrandomizer.com/
  examples:
    Broker, Town, Emissary, Hunter, Underling, Moat, Bandit, Galleria, Mine, Smithy, Fellowship of Scribes
    Merchant Camp, Augurs, Barbarian, Importer, Smithy, Devil's Workshop, Vampire, Pooka, Changeling, Werewolf, Peaceful Cult
    Druid, Exorcist, Capital, Castles, Chapel, Capital City, Hunter, Town, Sycophant, Emissary, Baths, The Mountain's Gift, The Sky's Gift, The Moon's Gift, Architects' Guild
]]
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
  {'Printed Cards','Currently any officially printed cards are allowed.\nThis excludes fan expansions.',14},
  {'Expansions','Currently only expansions are allowed.\nThis excludes promo/cut cards, Adamabrams, Xtras and Witches.',22},
  {'Everyting','Currently cards from any set are allowed.\nThis excludes Duplicate/cut cards.',#ref.cardSets-2}}
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
    eventMax=2
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
  useBoulderTrap=0
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
      btn('Tutorial Game','Kingdoms Known to be easy to introduce to new players.\nRight Click for slightly more advanced games.')
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
    obj.createInput({value=Use[2],alignment=3,tooltip='Cards used in this Kingdom',input_function='input_kingdomOutput',function_owner=self,position={0,2,1},rotation={0,180,0},scale={0.6,1,0.6},font_size=1000,height=1030,width=80000})
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
      
      for i, obj in ipairs(getObjectFromGUID(ref.players[currentPlayer].tavern).getObjects())do
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
        elseif k=='Curse'then log(vp)end--Why are we loging Curse?
        
        if tracker.deck.Pyramid and getType(k):find('Victory')then
          vp=vp-tracker.deck.Pyramid
          if vp<0 then vp=0 end
        end
        vP[cp]=vP[cp] + vp*v  --TODO:ERROR nil value
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
      local pos=Player[cp].getHandTransform().position
      local v=vP[cp]
      pos[3]=-21.5
      newText(pos,tostring(v),400).setColorTint(clr)
      for i,v in pairs(pos)do pos[i]=v-0.05 end
      newText(pos,tostring(v),400).setColorTint(Color.Black)
      setNotes(getNotes()..'\n'..cp..' VP: '..v)
      for card,count in pairs(dT[cp])do
        local s=count
        if count<10 then s='0'..count end
        --printToAll(s..count..' '..card,{1,1,1})
        if not totalCards[card]then totalCards[card]={[cp]=s}
        else totalCards[card][cp]=s end
      end
  end end
  
  local n=''
  for name,amount in pairs(totalCards)do
    for _,c in pairs(getSeatedPlayers())do
      local a=amount[c]or'00'
      n=n..'['..Color[c]:toHex(false)..']'..a..'[-] ' end
    n=n..':'..name..'\n'
  end
  printToAll('## ## :Card Name\n'..n,Color.Grey)
  return 1
end
--Used in Button Callbacks
newText=setmetatable({type='3DText',position={},rotation={90,0,0}
    },{__call=function(t,p,text,f)
      t.position=p
      local o=spawnObject(t)
      o.TextTool.setValue(text)
      o.TextTool.setFontSize(f or 200)
      return o end})
function cScale(o)o.setScale({1.88,1,1.88})end
function rcs(a)return math.random(1,a or sL[sL.n][3])end
function timerStart(t)click_StartGame(t[1],t[2],t[3])end
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
  
  if #getObjectFromGUID(ref.kingdomSlots[1].zone).getObjects()~=1 then
    return end
  
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
end
Use=setmetatable({' ',' '},{__call=function(t,s)local _,n=t[1]:gsub(' '..s..' ',' '..s..' ');if n>0 then return n end return false end})
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
  for _,t in pairs({'Looter','Reserve','Doom','Fate','Project','Liaison','Gathering','Fame','Season','Spellcaster'})do if getType(c):find(t)then s=s..t..' 'end end
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
function click_BalancedSetup(o,c,a)balanceSets(setsMax,o,c,a)end
function balanceSets(n,o,c,a)
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
    for i,j in pairs(t)do useSets[i]=ref.cardSets[j].guid end
  end
  
  for _,v in pairs(useSets)do getObjectFromGUID(v).shuffle()end
  
  local events={}
  for _,g in pairs(useSets)do for _,s in pairs(ref.cardSets)do if s.guid==g then
      if s.events then for _,v in pairs(s.events)do
      table.insert(events,ref.eventSets[v].guid)
    end end break end end end
  if #events>0 then
    while #events>eventMax do table.remove(events,math.random(1,#events))end
    local eT=eventTypes..''
    while #events<eventMax do
      local r=math.random(1,#events)
      local b=true
      while b do
        local name=getObjectFromGUID(events[r]).getName()
        eT:gsub(getType(name),
          function(t)b,r=false,math.random(1,#events)return''end)
        end
      table.insert(events,events[r])end
  end
  for _,v in pairs(events)do getObjectFromGUID(v).shuffle()end
  for i,v in pairs(ref.kingdomSlots)do
    if #getObjectFromGUID(v.zone).getObjects()==1 then
    getObjectFromGUID(useSets[(i%n)+1]).takeObject({
        position=v.pos,index=2,smooth=false,callback_function=cScale})end end
  for i,v in pairs(events)do
    local g=ref.eventSlots[i]
    if #getObjectFromGUID(g.zone).getObjects()==1 then
    getObjectFromGUID(v).takeObject({
        position=g.pos,rotation={0,90,0},index=2,smooth=false,callback_function=cScale})end end
  getObjectFromGUID(ref.startButton).editButton({index=1,font_color=Color.Purple,label='Right Click to\nStart Balanced',tooltip='Now you can edit the kingdom before actually setting up all the piles.\nIf you prefer not to play with some of these cards delet them now.\nClicking again will refil any newly empty slots again.\nRight-Click will actually start the game!'})
  if a then Timer.create({identifier='cSG',function_name='timerStart',parameters={o,c,a},delay=1})end
end
function click_TutorialGame(obj, color,a)
  bcast('Beginner Tutorial')
  newText({20,1,50},'THE GAME ENDS WHEN:\nAny 3 piles are empty or\nThe Province pile is empty.')
  newText({0,2,11},'On your turn you may play One ACTION.\nOnce you have finished playing actions you may play TREASURES.\nThen you may Buy One Card. ([i]Cards you play can change all these[/i])',100)
  local knd={
'Cellar,Festival,Mine,Moat,Patrol,Poacher,Smithy,Village,Witch,Workshop',
'Cellar,Market,Merchant,Militia,Mine,Moat,Remodel,Smithy,Village,Workshop',
'Cellar,Festival,Library,Sentry,Vassal,Courtier,Diplomat,Minion,Nobles,Pawn'}
  if a then knd={
'Artisan,Council Room,Market,Militia,Workshop,Bridge,Mill,Mining Village,Patrol,Shanty Town',
'Lurker,Village,Swindler,Throne Room,Remodel,Diplomat,Mine,Replace,Bandit,Harem',
'Cellar,Village,Bureaucrat,Monument,Gardens,Contraband,Counting House,Mountebank,Artisan,Hoard',
'Baron,Courtier,Duke,Harem,Ironworks,Masquerade,Mill,Nobles,Patrol,Replace',
'Conspirator,Ironworks,Lurker,Pawn,Mining Village,Secret Passage,Steward,Swindler,Torturer,Trading Post',
'Hamlet,Merchant,Fortune Teller,Poacher,Throne Room,Bureaucrat,Remake,Laboratory,Jester,Horn of Plenty',
'Workshop,Remodel,Farming Village,Young Witch,Horse Traders,Jester,Market,Laboratory,Artisan,Fairgrounds,Merchant',
'Fool\'s Gold,Crossroads,Vassal,Oracle,Spice Merchant,Remodel,Laboratory,Festival,Sentry,Farmland',
'Cellar,Library,Moneylender,Throne Room,Workshop,Highway,Inn,Margrave,Noble Brigand,Oasis',
'Cellar,Moneylender,Throne Room,Witch,Workshop,Hermit,Hunting Grounds,Mystic,Poor House,Wandering Minstrel,Shelters',
'Squire,Rats,Remodel,Scavenger,Gardens,Knights,Laboratory,Festival,Library,Altar,Shelters',
'Laboratory,Cellar,Workshop,Festival,Moneylender,Stonemason,Advisor,Baker,Journeyman,Merchant Guild',
'Bandit,Militia,Moneylender,Gardens,Village,Butcher,Baker,Candlestick Maker,Doctor,Sootslayer',
'Library,Merchant,Remodel,Market,Sentry,Plaza,Masterpiece,Candlestick Maker,Taxman,Herald',
'Market,Merchant,Militia,Throne Room,Workshop,Dungeon,Gear,Guide,Lost City,Miser,Traning',
'Bandit,Bureaucrat,Gardens,Moneylender,Witch,Amulet,Duplicate,Giant,Messenger,Treasure Trove,Bonefire,Raid',
'Cellar,Library,Remodel,Village,Workshop,Enchantress,Forum,Legionary,Overlord,Temple,Windfall,Orchard',
'Bureaucrat,Gardens,Laboratory,Market,Moneylender,Catapult,Charm,Farmers\' Market,Groundskeeper,Patrician,Conquest,Aqueduct',
'Druid,Exorcist,Ghost Town,Idol,Night Watchmen,Bandit,Gardens,Mine,Poacher,Smithy',
'Bard,Conclave,Cursed Village,Devil\'s Workshop,Tragic Hero,Cellar,Harbinger,Market,Merchant,Moneylender',
'Acting Troupe,Cargo Ship,Recruiter,Seer,Treasurer,Market,Merchant,Mine,Smithy,Vassal',
'Flag Bearer,Lackeys,Scholar,Swashbuckler,Villain,Cellar,Festival,Harbinger,Remodel,Workshop,Barracks,Pageant',
'Barge,Destrier,Paddock,Stockpile,Supplies,Artisan,Cellar,Market,Mine,Village,Stampede,Way of the Seal',
--'Black Cat,Displace,Sanctuary,Scrap,Snowy Village,Bandit,Gardens,Harbinger,Merchant,Moat,Way of the Mole,Toil'
}end
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
end
function click_RedditWeekly(obj, color)
  bcast('Reddit Weekly')
  local knd={}
  if a then knd={
'Fool\'s Gold,Gear,Fortune Teller,Baron,Trone Room,Falconer,Displace,Scepter,Barge,Vampire,Way of the Butterfly,Save,Academy,Training',

}end
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
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
  --CheckForEvents
  local events={}
  for _,es in ipairs(ref.eventSlots)do
    for i,v in ipairs(getObjectFromGUID(es.zone).getObjects())do
      if v.type=='Card'then
        eventTypes:gsub(getType(v.getName()),
          function(t)Use.Add(v.getName())table.insert(events,v)return''end)
  end end end
  --for i,o in ipairs(events)do o.setLock(true)o.setPosition(ref.eventSlots[i].pos)end
  eventCount=#events
  
  local cardCount=0
  for _,ks in ipairs(ref.kingdomSlots)do
    for i,v in ipairs(getObjectFromGUID(ks.zone).getObjects())do
      if v.type=='Card'then
        Use.Add(v.getName())
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
eventTypes='EventEventEventEventLandmarkLandmarkProjectProjectWayEdictAlly'
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
  f(Use('V Four Seasons'),'V Spring')
  f(Use('V Four Seasons'),'V Summer')
  f(Use('V Four Seasons'),'V Fall')
  f(Use('V Four Seasons'),'V Winter')
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
  --f(Use('Liaison'),'Allies')
  --CustomCards
  f(Use('SpellV'),'V Spell')
  f(Use('Disaster'),'C Wastes')
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
  f(Use('VLandGrant'),'V Land Grant')
  f(Use('Spellcaster'),'Spellcasters Spells')
  
  local dC,eC=1,0
  if Use('Druid')then dC=dC+3 end
  if Use('XHandler')then dC=dC+3 end
  if Use('Spellcaster')then eC=eC+2 end
  --Move remaining non supply piles
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
  
  for k,v in pairs(Suppliment)do
    if Use(k)then Suppliment[k]=nil end end
  for _,obj in pairs(getAllObjects())do
    for k,v in pairs(Suppliment)do
      if obj.getName()==v or obj.getName()=='Rules '..k then
        obj.destruct()
      elseif obj.getName():find(' Token')then
        obj.setLock(false)
  end end end
  getObjectFromGUID(ref.Board).destruct()
  
  function tokenCoroutine()
    wait(4,'cutcSetup')
    log(Use[1])
    log(Use[2])
    if Use('Obelisk')then obeliskPiles={}end
    --Setup f() on z pile
    local function slot(z,f)
      for __,obj in ipairs(getObjectFromGUID(z).getObjects())do
        if obj.type=='Deck'then f(obj)break end end end
    for name,setup in pairs(Setup)do
      local n=name:gsub(' ','')
      if Use(n)then--Set
        print('Setup: '..name)
        for _,v in ipairs(ref.basicSlots)do slot(v.zone,setup)end
        for _,v in ipairs(ref.kingdomSlots)do slot(v.zone,setup)end
        slot(ref.baneSlot.zone,setup)end end
    print('PostSetupLoop')
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
    wait(2,'cutcDelete')--No longer Crashes before this call Why was it happening
    for _,v in pairs(ref.tokenBag)do getObjectFromGUID(v).destruct()end
    if getPile('Heirlooms')then getPile('Heirlooms').destruct()end
    --SETUPSTARTING DECK
    local tbl={position=ref.players.White.deck,flip=true}
    local c,z=1,getObjectFromGUID(ref.players.White.deckZone).getObjects()
    for _,o in pairs(z)do
      if o.type=='Card'then
        c=c+1
      elseif o.type=='Deck'then
        c=1+#o.getObjects()end end
    local shelters=getPile('Shelters')
    local estate=getPile('Estates')
    if useShelters~=1 then
      shelters.destruct()
      estate.takeObject(tbl)
      estate.takeObject(tbl)
      estate.takeObject(tbl)
    else
      shelters.setPosition(tbl.position)
      estate.takeObject().destruct()
      estate.takeObject().destruct()
      estate.takeObject().destruct()
      --shelters.flip()
    end
    for i=c,7 do getPile('Coppers').takeObject(tbl)end
    wait(1,'DecksSetup')
    Timer.create({identifier='cSD',function_name='copyStartingDecks',delay=1})
    return 1
  end
  startLuaCoroutine(self, 'tokenCoroutine')
end

function createHeirlooms(c)
  for n,h in pairs({['Secret Cave']='Magic Lamp',['Cemetery']='Haunted Mirror',['Shepherd']='Pasture',['Tracker']='Pouch',['Pooka']='Cursed Gold',['Pixie']='Goat',['Fool']='Lucky Coin',['C Magician']='Rabbit',['C Jinxed Jewel']='Jinxed Jewel',['C Burned Village']='Rescuers',['V Emissary']='V Coin of Honor',['V Blessing']='V Blessed Gems'})do
    if c==n then getPile('Heirlooms').takeObject({position=ref.players.White.deck,guid=ref.heirlooms[h],flip=true})break end end end
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
function getVP(n)if Victory[n]then return Victory[n]end if MasterData[n]then return MasterData[n].VP end return 0 end
function getCost(n)if MasterData[n]then return MasterData[n].c end return'M0D0P0'end
function getType(n)if MasterData[n]then return MasterData[n].t end return'Event'end
--[[ Old Code
function getVP(n)if Victory[n]then return Victory[n]end for _,v in pairs(MasterData)do if n==v.name then return v.VP or 0 end end end
function getCost(n)for _,v in pairs(MasterData)do if n==v.name then return v.c end end return'M0D0P0'end
function getType(n)for _,v in pairs(MasterData)do if n==v.name then return v.t end end return'Event'end
]]
function getPile(pileName)for i,k in pairs({'replacementPiles','supplyPiles','sidePiles'})do for _,p in pairs(ref[k])do if pileName==p.name then return getObjectFromGUID(p.guid)end end end end
--Function to set the correct count of base cards
function setupBaseCardCount()
  local pCount=getPlayerCount()
  --Starting Curses
  setPileAmount('Curses',(pCount-1)*10)
  if getPile('Ruins pile')then
    getPile('Ruins pile').shuffle()
    setPileAmount('Ruins pile',(pCount-1)*10)
  end
  --Starting Treasures
  if pCount<5 then
    setPileAmount('Provinces',12)
    setPileAmount('Coppers',60)
    setPileAmount('Silvers',40)
    setPileAmount('Golds',30)
  else
    setPileAmount('Coppers',120)
  end
  --Starting Provinces
  if pCount==5 then
    setPileAmount('Provinces',15)
  end
  --2 Player Victory Card Setup
  if pCount==2 then
    setPileAmount('Estates',8)
    setPileAmount('Duchies',8)
    setPileAmount('Provinces',8)
    if usePlatinum==1 then
      setPileAmount('Colonies',8)
    end
  else
    setPileAmount('Estates',12)
  end
end
-- Function to setup starting Decks
function copyStartingDecks()
  local deck=false
  for _,o in pairs(getObjectFromGUID(ref.players.White.deckZone).getObjects())do
    if o.type=='Deck'then deck=o end end
  --Copy the deck for each player
  for p,v in pairs(ref.players)do if p~='White'then
    deck.clone({position=v.deck})end end
  
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
  startLuaCoroutine(self,'dealStartingHandsCoroutine')
  Timer.create({identifier='sBCC',function_name='setupBaseCardCount',delay=1})
end
function setPileAmount(pileName,total)
  local pile=getPile(pileName)
  while pile.getQuantity()>total do pile.takeObject({}).destruct()
end end
--XML UI Buttons
function playHand(player,alt)
  if player.color==Turns.turn_color then
    local objects = player.getHandObjects()
    local start = -2-#objects*2
    for i,o in ipairs(objects) do
      o.setPosition({start+i*4,1.3,-1})
    end
  else player.broadcast('Wait Your Turn.')
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
function tokenCallback(obj,m)obj.call('setOwner',m)end
function tokenMake(obj,key,n,post,name)
  local p=obj.getPosition()
  local pos=post or{-0.9,1,-1.25}
  if not post and key=='vp'then pos={0.9,1,1.25}end
  p={p[1]+pos[1],p[2]+pos[2],p[3]+pos[3]}
  local t={position=p,rotation={0,180,0},callback='tokenCallback',callback_owner=self,params={name or obj.getName(),n or 0}}
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
Pasture=function(t)return t.estates*1 end,
['Plateau Shepherd']=function(t,dT,cp)
  local twoCosts=0
  local favorTokens=getObjectFromGUID(ref.players[cp].favor).call('getCount')
  for c,n in pairs(t.deck)do if getCost(c):find('M2D0P0')then twoCosts=twoCosts+n end end
  return math.min(favorTokens,twoCosts)*2 end,
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
['C Tulip Field']=function(t,dT,cp)end,
['C Panorama']=function(t)return dv(t,'Victory',1)end
}
Setup={--(o):Deck
['Trade Route']=function(o)if getType(o.getObjects()[1].name):find('Victory')and not getType(o.getObjects()[1].name):find('Knight')then tokenMake(o,'coin',1,{-1,1,0},'Trade Route')end end,
Tax=function(o)tokenMake(o,'debt',1,{0.9,1,-1.25})end,
Gathering=function(o)if getType(o.getObjects()[1].name):find('Gathering')then tokenMake(o,'vp',nil,nil,o.getName())end end,
Obelisk=function(o)if getType(o.getObjects()[o.getQuantity()].name):find('Action')then table.insert(obeliskPiles,o)end end,
Aqueduct=function(o)local n=o.getName()if n=='Golds'or n=='Silvers'then tokenMake(o,'vp',8)end end,
['Defiled Shrine']=function(o)local t=getType(o.getObjects()[1].name);if t:find('Action')and not t:find('Gathering')then tokenMake(o,'vp',2)end end,
['Way of the Mouse']=function(o)end,
['C Panda / Gardener']=function(o)tokenMake(o,'coin',2,{1,1,0})end,
}
Suppliment={
--Tracker
VP='Victory Points',
Debt='Debt Tokens',
Coffers='Coffers',
Villager='Villagers',
PirateShip='Pirate Ship Coins',
Liaison='Favors',
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
TwoCost='%-2 Cost Token',
PlusBuy='%+1 Buy Token',
PlusCoin='%+1 Coin Token',
PlusCard='%+1 Card Token',
PlusAction='%+1 Action Token',
MinusCoin='%-1 Coin Token',
MinusCard='%-1 Card Token',
Trashing='Trashing Token',
Estate='Estate Token',
Journey='Journey Token',
Project='Project Token',
Spellcaster='Spell Tokens',
--VDFC
VWayoftheBeast='V Beast pile',
VGuildmaster='V Novice pile',
--RuleCubes
Team='TEAM',
Edict='EDICT'}
--Reference Tables
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
{name='V Land Grant pile'},
{name='V Spring pile'},
{name='V Summer pile'},
{name='V Fall pile'},
{name='V Winter pile'},
{name='V Spell pile'},
{name='V Novice pile'},
{name='V Beast pile'},
{name='Heirlooms'},
{name='C Wastes pile'},
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
{name='V Spring'},
{name='V Summer'},
{name='V Fall'},
{name='V Winter'},
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
{name='V Fruits / Fruit Mix pile'},
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
Blue  ={deckZone='307d12',discardZone='41de74',zone='062acc',coins='b2dc22',vp='b59b65',debt='186c83',tavern='015528',favor='',deck={-67.5,4,-28},discard={-72.5,4,-28}},
Green ={deckZone='9359a4',discardZone='72ba37',zone='c11794',coins='22bdb3',vp='6ae2a8',debt='a34771',tavern='af5c58',favor='',deck={-39.5,4,-28},discard={-44.5,4,-28}},
White ={deckZone='e6b388',discardZone='eb044b',zone='c95925',coins='b6bf41',vp='1b4618',debt='3d4844',tavern='d7d996',favor='',deck={-11.5,4,-28},discard={-16.5,4,-28}},
Red   ={deckZone='5a6e68',discardZone='e09013',zone='d1c5af',coins='4b832d',vp='84f540',debt='9cfa4a',tavern='48295f',favor='',deck={16.5,4,-28},discard={11.5,4,-28}},
Orange={deckZone='420340',discardZone='bf9b32',zone='10c425',coins='ce8828',vp='0d128b',debt='f2a253',tavern='fd4953',favor='',deck={44.5,4,-28},discard={39.5,4,-28}},
Yellow={deckZone='7ee56d',discardZone='046cfd',zone='827520',coins='17dd2a',vp='c979ca',debt='10cb81',tavern='dea1f7',favor='',deck={72.5,4,-28},discard={67.5,4,-28}}},
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
{name='Venus',events={11,12}},
--{name='Xtras'},
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
{name='Venus Mundane',events={11,12}},
{name='Disasters'},
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
{name='Legacy Edicts'},
{name='Venus Events'},
{name='Venus Ways Projects'},
}}
--Name of all cards along with costs, used for sorting
MasterData={
['Copper']={c='M0D0P0',t='Treasure'},
['Silver']={c='M3D0P0',t='Treasure'},
['Gold']={c='M6D0P0',t='Treasure'},
['Platinum']={c='M9D0P0',t='Treasure'},
['Potion']={c='M4D0P0',t='Treasure'},
['Curse']={c='M0D0P0',t='Curse',VP=-1},
['Estate']={c='M2D0P0',t='Victory',VP=1},
['Duchy']={c='M5D0P0',t='Victory',VP=3},
['Province']={c='M8D0P0',t='Victory',VP=6},
['Colony']={c='MBD0P0',t='Victory',VP=10},
['Artisan']={c='M6D0P0',t='Action'},
['Bandit']={c='M5D0P0',t='Action - Attack'},
['Bureaucrat']={c='M4D0P0',t='Action - Attack'},
['Cellar']={c='M2D0P0',t='Action'},
['Chapel']={c='M2D0P0',t='Action'},
['Council Room']={c='M5D0P0',t='Action'},
['Festival']={c='M5D0P0',t='Action'},
['Gardens']={c='M4D0P0',t='Victory'},
['Harbinger']={c='M3D0P0',t='Action'},
['Laboratory']={c='M5D0P0',t='Action'},
['Library']={c='M5D0P0',t='Action'},
['Market']={c='M5D0P0',t='Action'},
['Merchant']={c='M3D0P0',t='Action'},
['Militia']={c='M4D0P0',t='Action - Attack'},
['Mine']={c='M5D0P0',t='Action'},
['Moat']={c='M2D0P0',t='Action - Reaction'},
['Moneylender']={c='M4D0P0',t='Action'},
['Poacher']={c='M4D0P0',t='Action'},
['Remodel']={c='M4D0P0',t='Action'},
['Sentry']={c='M5D0P0',t='Action'},
['Smithy']={c='M4D0P0',t='Action'},
['Throne Room']={c='M4D0P0',t='Action'},
['Vassal']={c='M3D0P0',t='Action'},
['Village']={c='M3D0P0',t='Action'},
['Witch']={c='M5D0P0',t='Action - Attack'},
['Workshop']={c='M3D0P0',t='Action'},
['Baron']={c='M4D0P0',t='Action'},
['Bridge']={c='M4D0P0',t='Action'},
['Conspirator']={c='M4D0P0',t='Action'},
['Courtier']={c='M5D0P0',t='Action'},
['Courtyard']={c='M2D0P0',t='Action'},
['Diplomat']={c='M4D0P0',t='Action - Reaction'},
['Duke']={c='M5D0P0',t='Victory'},
['Harem']={c='M6D0P0',t='Treasure - Victory',VP=2},
['Ironworks']={c='M4D0P0',t='Action'},
['Lurker']={c='M2D0P0',t='Action'},
['Masquerade']={c='M3D0P0',t='Action'},
['Mill']={c='M4D0P0',t='Action - Victory',VP=1},
['Mining Village']={c='M4D0P0',t='Action'},
['Minion']={c='M5D0P0',t='Action - Attack'},
['Nobles']={c='M6D0P0',t='Action - Victory',VP=2},
['Patrol']={c='M5D0P0',t='Action'},
['Pawn']={c='M2D0P0',t='Action'},
['Replace']={c='M5D0P0',t='Action - Attack'},
['Steward']={c='M3D0P0',t='Action'},
['Swindler']={c='M3D0P0',t='Action - Attack'},
['Shanty Town']={c='M3D0P0',t='Action'},
['Secret Passage']={c='M4D0P0',t='Action'},
['Trading Post']={c='M5D0P0',t='Action'},
['Torturer']={c='M5D0P0',t='Action - Attack'},
['Upgrade']={c='M5D0P0',t='Action'},
['Wishing Well']={c='M3D0P0',t='Action'},
['Ambassador']={c='M3D0P0',t='Action - Attack'},
['Bazaar']={c='M5D0P0',t='Action'},
['Caravan']={c='M4D0P0',t='Action - Duration'},
['Cutpurse']={c='M4D0P0',t='Action - Attack'},
['Embargo']={c='M2D0P0',t='Action'},
['Explorer']={c='M5D0P0',t='Action'},
['Fishing Village']={c='M3D0P0',t='Action - Duration'},
['Ghost Ship']={c='M5D0P0',t='Action - Attack'},
['Haven']={c='M2D0P0',t='Action - Duration'},
['Island']={c='M4D0P0',t='Action - Victory',depend='Island',VP=2},
['Lighthouse']={c='M2D0P0',t='Action - Duration'},
['Lookout']={c='M3D0P0',t='Action'},
['Merchant Ship']={c='M5D0P0',t='Action - Duration'},
['Native Village']={c='M2D0P0',t='Action',depend='NativeVillage'},
['Navigator']={c='M4D0P0',t='Action'},
['Outpost']={c='M5D0P0',t='Action - Duration'},
['Pearl Diver']={c='M2D0P0',t='Action'},
['Pirate Ship']={c='M4D0P0',t='Action - Attack',depend='PirateShip'},
['Salvager']={c='M4D0P0',t='Action'},
['Sea Hag']={c='M4D0P0',t='Action - Attack'},
['Smugglers']={c='M3D0P0',t='Action'},
['Tactician']={c='M5D0P0',t='Action - Duration'},
['Treasure Map']={c='M4D0P0',t='Action'},
['Treasury']={c='M5D0P0',t='Action'},
['Warehouse']={c='M3D0P0',t='Action'},
['Wharf']={c='M5D0P0',t='Action - Duration'},
['Alchemist']={c='M3D0P1',t='Action'},
['Apothecary']={c='M2D0P1',t='Action'},
['Apprentice']={c='M5D0P0',t='Action'},
['Familiar']={c='M3D0P1',t='Action - Attack'},
['Golem']={c='M4D0P1',t='Action'},
['Herbalist']={c='M2D0P0',t='Action'},
['Philosopher\'s Stone']={c='M3D0P1',t='Treasure'},
['Possession']={c='M6D0P1',t='Action'},
['Scrying Pool']={c='M2D0P1',t='Action - Attack'},
['Transmute']={c='M0D0P1',t='Action'},
['University']={c='M2D0P1',t='Action'},
['Vineyard']={c='M0D0P1',t='Victory'},
['Bank']={c='M7D0P0',t='Treasure'},--Prosperity
['Bishop']={c='M4D0P0',t='Action',depend='VP'},
['City']={c='M5D0P0',t='Action'},
['Contraband']={c='M5D0P0',t='Treasure'},
['Counting House']={c='M5D0P0',t='Action'},
['Expand']={c='M7D0P0',t='Action'},
['Forge']={c='M7D0P0',t='Action'},
['Goons']={c='M6D0P0',t='Action - Attack',depend='VP'},
['Grand Market']={c='M6D0P0',t='Action'},
['Hoard']={c='M6D0P0',t='Treasure'},
['King\'s Court']={c='M7D0P0',t='Action'},
['Loan']={c='M3D0P0',t='Treasure'},
['Mint']={c='M5D0P0',t='Action'},
['Monument']={c='M4D0P0',t='Action',depend='VP'},
['Mountebank']={c='M5D0P0',t='Action - Attack'},
['Peddler']={c='M8D0P0',t='Action'},
['Quarry']={c='M4D0P0',t='Treasure'},
['Rabble']={c='M5D0P0',t='Action - Attack'},
['Royal Seal']={c='M5D0P0',t='Treasure'},
['Talisman']={c='M4D0P0',t='Treasure'},
['Trade Route']={c='M3D0P0',t='Action'},
['Vault']={c='M5D0P0',t='Action'},
['Venture']={c='M5D0P0',t='Treasure'},
['Watchtower']={c='M3D0P0',t='Action - Reactopm'},
['Worker\'s Village']={c='M4D0P0',t='Action'},
['Fairgrounds']={c='M6D0P0',t='Victory'},--Cornucopia
['Farming Village']={c='M4D0P0',t='Action'},
['Fortune Teller']={c='M3D0P0',t='Action - Attack'},
['Hamlet']={c='M2D0P0',t='Action'},
['Harvest']={c='M5D0P0',t='Action'},
['Horn of Plenty']={c='M5D0P0',t='Treasure'},
['Horse Traders']={c='M4D0P0',t='Action - Reaction'},
['Hunting Party']={c='M5D0P0',t='Action'},
['Jester']={c='M5D0P0',t='Action - Attack'},
['Menagerie']={c='M3D0P0',t='Action'},
['Remake']={c='M4D0P0',t='Action'},
['Tournament']={c='M4D0P0',t='Action',depend='Prize'},
['Young Witch']={c='M4D0P0',t='Action - Attack'},
['Bag of Gold']={c='M0D0P0',t='Action - Prize'},
['Diadem']={c='M0D0P0',t='Treasure - Prize'},
['Followers']={c='M0D0P0',t='Action - Attack - Prize'},
['Princess']={c='M0D0P0',t='Action - Prize'},
['Trusty Steed']={c='M0D0P0',t='Action - Prize'},
['Border Village']={c='M6D0P0',t='Action'},
['Cache']={c='M5D0P0',t='Treasure'},
['Cartographer']={c='M5D0P0',t='Action'},
['Crossroads']={c='M2D0P0',t='Action'},
['Develop']={c='M3D0P0',t='Action'},
['Duchess']={c='M2D0P0',t='Action'},
['Embassy']={c='M5D0P0',t='Action'},
['Farmland']={c='M6D0P0',t='Victory',VP=2},
['Fool\'s Gold']={c='M2D0P0',t='Treasure - Reaction'},
['Haggler']={c='M5D0P0',t='Action'},
['Highway']={c='M5D0P0',t='Action'},
['Ill-Gotten Gains']={c='M5D0P0',t='Treasure'},
['Inn']={c='M5D0P0',t='Action'},
['Jack of All Trades']={c='M4D0P0',t='Action'},
['Mandarin']={c='M5D0P0',t='Action'},
['Margrave']={c='M5D0P0',t='Action - Attack'},
['Noble Brigand']={c='M4D0P0',t='Action - Attack'},
['Nomad Camp']={c='M4D0P0',t='Action'},
['Oasis']={c='M3D0P0',t='Action'},
['Oracle']={c='M3D0P0',t='Action - Attack'},
['Scheme']={c='M3D0P0',t='Action'},
['Silk Road']={c='M4D0P0',t='Victory'},
['Spice Merchant']={c='M4D0P0',t='Action'},
['Stables']={c='M5D0P0',t='Action'},
['Trader']={c='M4D0P0',t='Action - Reaction'},
['Tunnel']={c='M3D0P0',t='Victory - Reaction',VP=2},
['Abandoned Mine']={c='M0D0P0',t='Action - Ruins'},
['Ruined Library']={c='M0D0P0',t='Action - Ruins'},
['Ruined Market']={c='M0D0P0',t='Action - Ruins'},
['Ruined Village']={c='M0D0P0',t='Action - Ruins'},
['Survivors']={c='M0D0P0',t='Action - Ruins'},
['Altar']={c='M6D0P0',t='Action'},--DarkAges
['Armory']={c='M4D0P0',t='Action'},
['Band of Misfits']={c='M5D0P0',t='Action - Command'},
['Bandit Camp']={c='M5D0P0',t='Action',depend='Spoils'},
['Beggar']={c='M2D0P0',t='Action - Reaction'},
['Catacombs']={c='M5D0P0',t='Action'},
['Count']={c='M5D0P0',t='Action'},
['Counterfeit']={c='M5D0P0',t='Treasure'},
['Cultist']={c='M5D0P0',t='Action - Attack - Looter'},
['Death Cart']={c='M4D0P0',t='Action - Looter'},
['Feodum']={c='M4D0P0',t='Victory'},
['Forager']={c='M3D0P0',t='Action'},
['Fortress']={c='M4D0P0',t='Action'},
['Graverobber']={c='M5D0P0',t='Action'},
['Hermit']={c='M3D0P0',t='Action',depend='Madman'},
['Hunting Grounds']={c='M6D0P0',t='Action'},
['Ironmonger']={c='M4D0P0',t='Action'},
['Junk Dealer']={c='M5D0P0',t='Action'},
['Knights']={c='M5D0P0',t='Action - Attack - Knight'},
['Marauder']={c='M4D0P0',t='Action - Attack - Looter',depend='Spoils'},
['Market Square']={c='M3D0P0',t='Action - Reaction'},
['Mystic']={c='M5D0P0',t='Action'},
['Pillage']={c='M5D0P0',t='Action - Attack',depend='Spoils'},
['Poor House']={c='M1D0P0',t='Action'},
['Procession']={c='M4D0P0',t='Action'},
['Rats']={c='M4D0P0',t='Action'},
['Rebuild']={c='M5D0P0',t='Action'},
['Rogue']={c='M5D0P0',t='Action - Attack'},
['Sage']={c='M3D0P0',t='Action'},
['Scavenger']={c='M4D0P0',t='Action'},
['Squire']={c='M2D0P0',t='Action'},
['Storeroom']={c='M3D0P0',t='Action'},
['Urchin']={c='M3D0P0',t='Action - Attack',depend='Mercenary'},
['Vagrant']={c='M2D0P0',t='Action'},
['Wandering Minstrel']={c='M4D0P0',t='Action'},
['Madman']={c='M0D0P0',t='Action'},
['Mercenary']={c='M0D0P0',t='Action - Attack'},
['Spoils']={c='M0D0P0',t='Treasure'},
['Dame Anna']={c='M5D0P0',t='Action - Attack - Knight'},
['Dame Josephine']={c='M5D0P0',t='Action - Attack - Knight - Victory',VP=2},
['Dame Molly']={c='M5D0P0',t='Action - Attack - Knight'},
['Dame Natalie']={c='M5D0P0',t='Action - Attack - Knight'},
['Dame Sylvia']={c='M5D0P0',t='Action - Attack - Knight'},
['Sir Bailey']={c='M5D0P0',t='Action - Attack - Knight'},
['Sir Destry']={c='M5D0P0',t='Action - Attack - Knight'},
['Sir Martin']={c='M4D0P0',t='Action - Attack - Knight'},
['Sir Michael']={c='M5D0P0',t='Action - Attack - Knight'},
['Sir Vander']={c='M5D0P0',t='Action - Attack - Knight'},
['Hovel']={c='M1D0P0',t='Reaction - Shelter'},
['Necropolis']={c='M1D0P0',t='Action - Shelter'},
['Overgrown Estate']={c='M1D0P0',t='Victory - Shelter'},
['Advisor']={c='M4D0P0',t='Action'},--Guilds
['Baker']={c='M5D0P0',t='Action',depend='Coffers'},
['Butcher']={c='M5D0P0',t='Action',depend='Coffers'},
['Candlestick Maker']={c='M2D0P0',t='Action',depend='Coffers'},
['Doctor']={c='M3D0P0',t='Action'},
['Herald']={c='M4D0P0',t='Action'},
['Journeyman']={c='M5D0P0',t='Action'},
['Masterpiece']={c='M3D0P0',t='Treasure'},
['Merchant Guild']={c='M5D0P0',t='Action',depend='Coffers'},
['Plaza']={c='M4D0P0',t='Action',depend='Coffers'},
['Soothsayer']={c='M5D0P0',t='Action - Attack'},
['Stonemason']={c='M2D0P0',t='Action'},
['Taxman']={c='M4D0P0',t='Action - Attack'},
['Amulet']={c='M3D0P0',t='Action - Duration'},
['Artificer']={c='M5D0P0',t='Action'},
['Bridge Troll']={c='M5D0P0',t='Action - Attack - Duration',depend='MinusCoin'},
['Caravan Guard']={c='M3D0P0',t='Action - Duration - Reaction'},
['Coin of the Realm']={c='M2D0P0',t='Treasure - Reserve'},
['Distant Lands']={c='M5D0P0',t='Action - Reserve - Victory'},
['Dungeon']={c='M3D0P0',t='Action - Duration'},
['Duplicate']={c='M4D0P0',t='Action - Reserve'},
['Gear']={c='M3D0P0',t='Action - Duration'},
['Giant']={c='M5D0P0',t='Action - Attack',depend='Journey'},
['Guide']={c='M3D0P0',t='Action - Reserve'},
['Haunted Woods']={c='M5D0P0',t='Action - Attack - Duration'},
['Hireling']={c='M6D0P0',t='Action - Duration'},
['Lost City']={c='M5D0P0',t='Action'},
['Magpie']={c='M4D0P0',t='Action'},
['Messenger']={c='M4D0P0',t='Action'},
['Miser']={c='M4D0P0',t='Action',depend='Reserve'},
['Page']={c='M2D0P0',t='Action - Traveller'},
['Peasant']={c='M2D0P0',t='Action - Traveller',depend='Reserve PlusCard PlusAction PlusBuy PlusCoin'},
['Port']={c='M4D0P0',t='Action'},
['Ranger']={c='M4D0P0',t='Action',depend='Journey'},
['Ratcatcher']={c='M2D0P0',t='Action - Reserve'},
['Raze']={c='M2D0P0',t='Action'},
['Relic']={c='M5D0P0',t='Treasure - Attack',depend='MinusCard'},
['Royal Carriage']={c='M5D0P0',t='Action - Reserve'},
['Storyteller']={c='M5D0P0',t='Action'},
['Swamp Hag']={c='M5D0P0',t='Action - Attack - Duration'},
['Transmogrify']={c='M4D0P0',t='Action - Reserve'},
['Treasure Trove']={c='M5D0P0',t='Treasure'},
['Wine Merchant']={c='M5D0P0',t='Action - Reserve'},
['Treasure Hunter']={c='M3D0P0',t='Action - Traveller'},
['Warrior']={c='M4D0P0',t='Action - Warrior - Traveller'},
['Hero']={c='M5D0P0',t='Action - Traveller'},
['Champion']={c='M6D0P0',t='Action - Duration'},
['Soldier']={c='M3D0P0',t='Action - Attack - Traveller'},
['Fugitive']={c='M4D0P0',t='Action - Traveller'},
['Disciple']={c='M5D0P0',t='Action - Traveller'},
['Teacher']={c='M6D0P0',t='Action - Reserve'},
['Alms']={c='M0D0P0',t='Event'},
['Ball']={c='M5D0P0',t='Event',depend='MinusCoin'},
['Bonfire']={c='M3D0P0',t='Event'},
['Borrow']={c='M0D0P0',t='Event',depend='MinusCard'},
['Expedition']={c='M3D0P0',t='Event'},
['Ferry']={c='M3D0P0',t='Event',depend='TwoCost'},
['Inheritance']={c='M7D0P0',t='Event',depend='Estate'},
['Lost Arts']={c='M6D0P0',t='Event',depend='PlusAction'},
['Mission']={c='M4D0P0',t='Event'},
['Pathfinding']={c='M8D0P0',t='Event',depend='PlusCard'},
['Pilgrimage']={c='M4D0P0',t='Event',depend='Journey'},
['Plan']={c='M3D0P0',t='Event',depend='Trashing'},
['Quest']={c='M0D0P0',t='Event'},
['Raid']={c='M5D0P0',t='Event',depend='MinusCard'},
['Save']={c='M1D0P0',t='Event'},
['Scouting Party']={c='M2D0P0',t='Event'},
['Seaway']={c='M5D0P0',t='Event',depend='PlusBuy'},
['Trade']={c='M5D0P0',t='Event'},
['Training']={c='M6D0P0',t='Event',depend='PlusCoin'},
['Travelling Fair']={c='M2D0P0',t='Event'},
['Archive']={c='M5D0P0',t='Action - Duration'},
['Capital']={c='M5D0P0',t='Treasure',depend='Debt'},
['Castles']={c='M3D0P0',t='Victory - Castle',depend='VP'},
['Catapult / Rocks']={c='M3D0P0',t='Action - Attack'},
['Chariot Race']={c='M3D0P0',t='Action',depend='VP'},
['Charm']={c='M5D0P0',t='Treasure'},
['City Quarter']={c='D8M0P0',t='Action'},
['Crown']={c='M5D0P0',t='Action - Treasure'},
['Encampment / Plunder']={c='M2D0P0',t='Action',depend='VP'},
['Enchantress']={c='M3D0P0',t='Action - Attack - Duration'},
['Engineer']={c='D4M0P0',t='Action'},
['Farmers\' Market']={c='M3D0P0',t='Action - Gathering',depend='VP'},
['Forum']={c='M5D0P0',t='Action'},
['Gladiator / Fortune']={c='M3D0P0',t='Action'},
['Groundskeeper']={c='M5D0P0',t='Action',depend='VP'},
['Legionary']={c='M5D0P0',t='Action - Attack'},
['Patrician / Emporium']={c='M2D0P0',t='Action',depend='VP'},
['Royal Blacksmith']={c='D8M0P0',t='Action'},
['Overlord']={c='D8M0P0',t='Action - Command'},
['Sacrifice']={c='M4D0P0',t='Action',depend='VP'},
['Settlers / Bustling Village']={c='M2D0P0',t='Action'},
['Temple']={c='M4D0P0',t='Action - Gathering',depend='VP'},
['Villa']={c='M4D0P0',t='Action'},
['Wild Hunt']={c='M5D0P0',t='Action - Gathering',depend='VP'},
['Humble Castle']={c='M3D0P0',t='Treasure - Victory - Castle'},
['Crumbling Castle']={c='M4D0P0',t='Victory - Castle',VP=1,depend='VP'},
['Small Castle']={c='M5D0P0',t='Action - Victory - Castle',VP=2},
['Haunted Castle']={c='M6D0P0',t='Victory - Castle',VP=2},
['Opulent Castle']={c='M7D0P0',t='Action - Victory - Castle',VP=3},
['Sprawling Castle']={c='M8D0P0',t='Victory - Castle',VP=4},
['Grand Castle']={c='M9D0P0',t='Victory - Castle',VP=5,depend='VP'},
['King\'s Castle']={c='MAD0P0',t='Victory - Castle'},
['Catapult']={c='D03MP0',t='Action - Attack'},
['Rocks']={c='D04MP0',t='Treasure'},
['Encampment']={c='M2D0P0',t='Action'},
['Plunder']={c='M5D0P0',t='Treasure',depend='VP'},
['Gladiator']={c='M3D0P0',t='Action'},
['Fortune']={c='D8M8P0',t='Treasure'},
['Patrician']={c='M2D0P0',t='Action'},
['Emporium']={c='M5D0P0',t='Action',depend='VP'},
['Settlers']={c='M2D0P0',t='Action'},
['Bustling Village']={c='M5D0P0',t='Action'},
['Advance']={c='M0D0P0',t='Event'},
['Annex']={c='M0D8P0',t='Event'},
['Banquet']={c='M3D0P0',t='Event'},
['Conquest']={c='M6D0P0',t='Event',depend='VP'},
['Delve']={c='M2D0P0',t='Event'},
['Dominate']={c='MED0P0',t='Event',depend='VP'},
['Donate']={c='M0D8P0',t='Event'},
['Ritual']={c='M4D0P0',t='Event',depend='VP'},
['Salt the Earth']={c='M4D0P0',t='Event',depend='VP'},
['Tax']={c='M2D0P0',t='Event',depend='Debt'},
['Triumph']={c='M0D5P0',t='Event',depend='VP'},
['Wedding']={c='M4D3P0',t='Event',depend='VP'},
['Windfall']={c='M5D0P0',t='Event'},
['Aqueduct']={c='MXDXP0',t='Landmark',depend='VP'},
['Arena']={c='MXDXP0',t='Landmark',depend='VP'},
['Bandit Fort']={c='MXDXP0',t='Landmark'},
['Basilica']={c='MXDXP0',t='Landmark',depend='VP'},
['Baths']={c='MXDXP0',t='Landmark',depend='VP'},
['Battlefield']={c='MXDXP0',t='Landmark',depend='VP'},
['Colonnade']={c='MXDXP0',t='Landmark',depend='VP'},
['Defiled Shrine']={c='MXDXP0',t='Landmark',depend='VP'},
['Fountain']={c='MXDXP0',t='Landmark'},
['Keep']={c='MXDXP0',t='Landmark'},
['Labyrinth']={c='MXDXP0',t='Landmark',depend='VP'},
['Mountain Pass']={c='MXDXP0',t='Landmark',depend='VP Debt'},
['Museum']={c='MXDXP0',t='Landmark'},
['Obelisk']={c='MXDXP0',t='Landmark'},
['Orchard']={c='MXDXP0',t='Landmark'},
['Palace']={c='MXDXP0',t='Landmark'},
['Tomb']={c='MXDXP0',t='Landmark',depend='VP'},
['Tower']={c='MXDXP0',t='Landmark'},
['Triumphal Arch']={c='MXDXP0',t='Landmark'},
['Wall']={c='MXDXP0',t='Landmark'},
['Wolf Den']={c='MXDXP0',t='Landmark'},
['Lucky Coin']={c='M4D0P0',t='Treasure - Heirloom'},
['Cursed Gold']={c='M4D0P0',t='Treasure - Heirloom'},
['Pasture']={c='M2D0P0',t='Treasure - Victory - Heirloom'},
['Pouch']={c='M2D0P0',t='Treasure - Heirloom'},
['Goat']={c='M2D0P0',t='Treasure - Heirloom'},
['Magic Lamp']={c='M0D0P0',t='Treasure - Heirloom'},
['Haunted Mirror']={c='M0D0P0',t='Treasure - Heirloom'},
['Wish']={c='M0D0P0',t='Action'},
['Bat']={c='M2D0P0',t='Night'},
['Will-o\'-Wisp']={c='M0D0P0',t='Action'},
['Imp']={c='M2D0P0',t='Action'},
['Ghost']={c='M4D0P0',t='Night - Duration - Spirit'},
['Raider']={c='M6D0P0',t='Night - Duration - Attack'},
['Werewolf']={c='M5D0P0',t='Action - Night - Attack - Doom'},
['Cobbler']={c='M5D0P0',t='Night - Duration'},
['Den of Sin']={c='M5D0P0',t='Night - Duration'},
['Crypt']={c='M5D0P0',t='Night - Duration'},
['Vampire']={c='M5D0P0',t='Night - Attack - Doom'},
['Exorcist']={c='M4D0P0',t='Night',depend='Imp Ghost'},
['Devil\'s Workshop']={c='M4D0P0',t='Night',depend='Imp'},
['Ghost Town']={c='M3D0P0',t='Night - Duration'},
['Night Watchman']={c='M3D0P0',t='Night'},
['Changeling']={c='M3D0P0',t='Night'},
['Guardian']={c='M2D0P0',t='Night - Duration'},
['Monastery']={c='M2D0P0',t='Night'},
['Idol']={c='M5D0P0',t='Treasure - Attack - Fate'},
['Tormentor']={c='M5D0P0',t='Action - Attack - Doom',depend='Imp'},
['Cursed Village']={c='M5D0P0',t='Action - Doom'},
['Sacred Grove']={c='M5D0P0',t='Action - Fate'},
['Tragic Hero']={c='M5D0P0',t='Action'},
['Pooka']={c='M5D0P0',t='Action',depend='Heirloom'},
['Cemetery']={c='M4D0P0',t='Victory',depend='Ghost Heirloom',VP=2},
['Skulk']={c='M4D0P0',t='Action - Attack - Doom'},
['Blessed Village']={c='M4D0P0',t='Action - Fate'},
['Bard']={c='M4D0P0',t='Action - Fate'},
['Necromancer']={c='M4D0P0',t='Action',depend='Zombie'},
['Conclave']={c='M4D0P0',t='Action'},
['Shepherd']={c='M4D0P0',t='Action',depend='Heirloom'},
['Secret Cave']={c='M3D0P0',t='Action - Duration',depend='Wish Heirloom'},
['Fool']={c='M3D0P0',t='Action - Fate',depend='Heirloom'},
['Leprechaun']={c='M3D0P0',t='Action - Doom',depend='Wish'},
['Faithful Hound']={c='M2D0P0',t='Action - Reaction'},
['Druid']={c='M2D0P0',t='Action - Fate'},
['Tracker']={c='M2D0P0',t='Action - Fate',depend='Heirloom'},
['Pixie']={c='M2D0P0',t='Action - Fate',depend='Heirloom'},
['Citadel']={c='M8D0P0',t='Project'},
['Canal']={c='M7D0P0',t='Project'},
['Innovation']={c='M6D0P0',t='Project'},
['Crop Rotation']={c='M6D0P0',t='Project'},
['Barracks']={c='M6D0P0',t='Project'},
['Road Network']={c='M5D0P0',t='Project'},
['Piazza']={c='M5D0P0',t='Project'},
['Guildhall']={c='M5D0P0',t='Project',depend='Coffers'},
['Fleet']={c='M5D0P0',t='Project'},
['Capitalism']={c='M5D0P0',t='Project'},
['Academy']={c='M5D0P0',t='Project',depend='Villager'},
['Sinister Plot']={c='M4D0P0',t='Project'},
['Silos']={c='M4D0P0',t='Project'},
['Fair']={c='M4D0P0',t='Project'},
['Exploration']={c='M4D0P0',t='Project',depend='Coffers Villager'},
['Star Chart']={c='M3D0P0',t='Project'},
['Sewers']={c='M3D0P0',t='Project'},
['Pageant']={c='M3D0P0',t='Project',depend='Coffers'},
['City Gate']={c='M3D0P0',t='Project'},
['Cathedral']={c='M3D0P0',t='Project'},
['Flag']={c='MXDXPX',t='Artifact'},
['Horn']={c='MXDXPX',t='Artifact'},
['Key']={c='MXDXPX',t='Artifact'},
['Lantern']={c='MXDXPX',t='Artifact'},
['Treasure Chest']={c='MXDXPX',t='Artifact'},
['Spices']={c='M5D0P0',t='Treasure',depend='Coffers'},
['Scepter']={c='M5D0P0',t='Treasure'},
['Villain']={c='M5D0P0',t='Action - Attack',depend='Coffers'},
['Old Witch']={c='M5D0P0',t='Action - Attack'},
['Treasurer']={c='M5D0P0',t='Action',depend='Artifact'},
['Swashbuckler']={c='M5D0P0',t='Action',depend='Coffers Artifact'},
['Seer']={c='M5D0P0',t='Action'},
['Sculptor']={c='M5D0P0',t='Action',depend='Villager'},
['Scholar']={c='M5D0P0',t='Action'},
['Recruiter']={c='M5D0P0',t='Action',depend='Villager'},
['Research']={c='M4D0P0',t='Action - Duration'},
['Patron']={c='M4D0P0',t='Action - Reaction',depend='Coffers Villager'},
['Silk Merchant']={c='M4D0P0',t='Action',depend='Coffers Villager'},
['Priest']={c='M4D0P0',t='Action'},
['Mountain Village']={c='M4D0P0',t='Action'},
['Inventor']={c='M4D0P0',t='Action'},
['Hideout']={c='M4D0P0',t='Action'},
['Flag Bearer']={c='M4D0P0',t='Action',depend='Artifact'},
['Cargo Ship']={c='M3D0P0',t='Action - Duration'},
['Improve']={c='M3D0P0',t='Action'},
['Experiment']={c='M3D0P0',t='Action'},
['Acting Troupe']={c='M3D0P0',t='Action',depend='Villager'},
['Ducat']={c='M2D0P0',t='Treasure',depend='Coffers'},
['Lackeys']={c='M2D0P0',t='Action',depend='Villager'},
['Border Guard']={c='M2D0P0',t='Action',depend='Artifact'},--MenagerieExpansion
['Black Cat']={c='M2D0P0',t='Action - Attack - Reaction'},
['Sleigh']={c='M2D0P0',t='Treasure',depend='Horse'},
['Supplies']={c='M2D0P0',t='Treasure',depend='Horse'},
['Camel Train']={c='M3D0P0',t='Action',depend='Exile'},
['Goatherd']={c='M3D0P0',t='Action'},
['Scrap']={c='M3D0P0',t='Action',depend='Horse'},
['Sheepdog']={c='M3D0P0',t='Action - Reaction'},
['Snowy Village']={c='M3D0P0',t='Action'},
['Stockpile']={c='M3D0P0',t='Treasure',depend='Exile'},
['Bounty Hunter']={c='M4D0P0',t='Action',depend='Exile'},
['Cardinal']={c='M4D0P0',t='Action - Attack',depend='Exile'},
['Cavalry']={c='M4D0P0',t='Action',depend='Horse'},
['Groom']={c='M4D0P0',t='Action',depend='Horse'},
['Hostelry']={c='M4D0P0',t='Action',depend='Horse'},
['Village Green']={c='M4D0P0',t='Action - Duration - Reaction'},
['Barge']={c='M5D0P0',t='Action - Duration'},
['Coven']={c='M5D0P0',t='Action - Attack',depend='Exile'},
['Displace']={c='M5D0P0',t='Action',depend='Exile'},
['Falconer']={c='M5D0P0',t='Action - Reaction'},
['Fisherman']={c='M5D0P0',t='Action'},
['Gatekeeper']={c='M5D0P0',t='Action - Duration - Attack',depend='Exile'},
['Hunting Lodge']={c='M5D0P0',t='Action'},
['Kiln']={c='M5D0P0',t='Action'},
['Livery']={c='M5D0P0',t='Action',depend='Horse'},
['Mastermind']={c='M5D0P0',t='Action - Duration'},
['Paddock']={c='M5D0P0',t='Action',depend='Horse'},
['Sanctuary']={c='M5D0P0',t='Action',depend='Exile'},
['Destrier']={c='M6D0P0',t='Action'},
['Wayfarer']={c='M6D0P0',t='Action'},
['Animal Fair']={c='M7D0P0',t='Action'},
['Horse']={c='M3D0P0',t='Action'},
['Way of the Butterfly']={c='M0D0P0',t='Way'},
['Way of the Camel']={c='M0D0P0',t='Way',depend='Exile'},
['Way of the Chameleon']={c='M0D0P0',t='Way'},
['Way of the Frog']={c='M0D0P0',t='Way'},
['Way of the Goat']={c='M0D0P0',t='Way'},
['Way of the Horse']={c='M0D0P0',t='Way'},
['Way of the Mole']={c='M0D0P0',t='Way'},
['Way of the Monkey']={c='M0D0P0',t='Way'},
['Way of the Mouse']={c='M0D0P0',t='Way'},
['Way of the Mule']={c='M0D0P0',t='Way'},
['Way of the Otter']={c='M0D0P0',t='Way'},
['Way of the Owl']={c='M0D0P0',t='Way'},
['Way of the Ox']={c='M0D0P0',t='Way'},
['Way of the Pig']={c='M0D0P0',t='Way'},
['Way of the Rat']={c='M0D0P0',t='Way'},
['Way of the Seal']={c='M0D0P0',t='Way'},
['Way of the Sheep']={c='M0D0P0',t='Way'},
['Way of the Squirrel']={c='M0D0P0',t='Way'},
['Way of the Turtle']={c='M0D0P0',t='Way',depend='Aside'},
['Way of the Worm']={c='M0D0P0',t='Way',depend='Exile'},
['Delay']={c='M0D0P0',t='Event',depend='Aside'},
['Desperation']={c='M0D0P0',t='Event'},
['Gamble']={c='M2D0P0',t='Event'},
['Pursue']={c='M2D0P0',t='Event'},
['Ride']={c='M2D0P0',t='Event',depend='Horse'},
['Toil']={c='M2D0P0',t='Event'},
['Enhance']={c='M3D0P0',t='Event'},
['March']={c='M3D0P0',t='Event'},
['Transport']={c='M3D0P0',t='Event',depend='Exile'},
['Banish']={c='M4D0P0',t='Event',depend='Exile'},
['Bargain']={c='M4D0P0',t='Event',depend='Horse'},
['Invest']={c='M4D0P0',t='Event',depend='Exile'},
['Seize the Day']={c='M4D0P0',t='Event',depend='Project'},
['Commerce']={c='M5D0P0',t='Event'},
['Demand']={c='M5D0P0',t='Event',depend='Horse'},
['Stampede']={c='M5D0P0',t='Event',depend='Horse'},
['Reap']={c='M7D0P0',t='Event'},
['Enclave']={c='M8D0P0',t='Event',depend='Exile'},
['Alliance']={c='M10D0P0',t='Event'},
['Populate']={c='M10D0P0',t='Event'},
--Allies
['Cave Dwellers']={c='MXDXPX',t='Ally'},
['Coastal Haven']={c='MXDXPX',t='Ally'},
['Peaceful Cult']={c='MXDXPX',t='Ally'},
['Plateau Shepherd']={c='MXDXPX',t='Ally'},
['League of Bankers']={c='MXDXPX',t='Ally'},
['Crafters\' Guild']={c='MXDXPX',t='Ally'},
['City-State']={c='MXDXPX',t='Ally'},
['Band of Nomads']={c='MXDXPX',t='Ally'},
['Architects\' Guild']={c='MXDXPX',t='Ally'},
['Island Folk']={c='MXDXPX',t='Ally'},
['Order of Masons']={c='MXDXPX',t='Ally'},
['Family of Inventors']={c='MXDXPX',t='Ally'},
['Gang of Pickpockets']={c='MXDXPX',t='Ally'},
['Augurs']={c='M3D0P0',t='Action - Augur',depend='Rotation'},
['Herb Gatherer']={c='M3D0P0',t='Action - Augur'},
['Acolyte']={c='M4D0P0',t='Action - Augur'},
['Sorceress']={c='M5D0P0',t='Action - Attack - Augur'},
['Sibyl']={c='M6D0P0',t='Action - Augur'},
['Townsfolk']={c='M2D0P0',t='Action - Townsfolk',depend='Rotation'},
['Town Crier']={c='M2D0P0',t='Action - Townsfolk'},
['Blacksmith']={c='M3D0P0',t='Action - Townsfolk'},
['Miller']={c='M4D0P0',t='Action - Townsfolk'},
['Elder']={c='M5D0P0',t='Action - Townsfolk'},
['Wizard']={c='M2D0P0',t='Action - Wizard',depend='Rotation Liaison'},
['Student']={c='M2D0P0',t='Action - Wizard - Liaison'},
['Conjurer']={c='M3D0P0',t='Action - Duration - Wizard'},
['Sorcerer']={c='M4D0P0',t='Action - Attack - Wizard'},
['Lich']={c='M5D0P0',t='Action - Wizard'},
['Odyssies']={c='M3D0P0',t='Action - Odyssey',depend='Rotation'},
['Old Map']={c='M3D0P0',t='Action - Odyssey'},
['Voyage']={c='M4D0P0',t='Action - Duration - Odyssey'},
['Sunken Treasure']={c='M5D0P0',t='Treasure - Odyssey'},
['Distant Shore']={c='M6D0P0',t='Action - Victory - Odyssey'},
['Bauble']={c='M2D0P0',t='Treasure - Liaison'},
['Underling']={c='M3D0P0',t='Action - Liaison'},
['Broker']={c='M4D0P0',t='Action - Liaison'},
['Importer']={c='M3D0P0',t='Action - Duration - Liaison'},
['Merchant Camp']={c='M3D0P0',t='Action'},
['Courier']={c='M4D0P0',t='Action'},
['Town']={c='M4D0P0',t='Action'},
['Royal Galley']={c='M4D0P0',t='Action - Duration'},
['Highwayman']={c='M5D0P0',t='Action - Duration - Attack'},
['Modify']={c='M5D0P0',t='Action'},
['Swap']={c='M5D0P0',t='Action'},
--Plunder
['Cheap']={c='MXDXPX',t='Trait'},
['Cursed']={c='MXDXPX',t='Trait',depend='Loot'},
['Fated']={c='MXDXPX',t='Trait'},
['Fawning']={c='MXDXPX',t='Trait'},
['Friendly']={c='MXDXPX',t='Trait'},
['Hasty']={c='MXDXPX',t='Trait'},
['Inherited']={c='MXDXPX',t='Trait'},
['Inspiring']={c='MXDXPX',t='Trait'},
['Nearby']={c='MXDXPX',t='Trait'},
['Patient']={c='MXDXPX',t='Trait'},
['Pious']={c='MXDXPX',t='Trait'},
['Reckless']={c='MXDXPX',t='Trait'},
['Rich']={c='MXDXPX',t='Trait'},
['Shy']={c='MXDXPX',t='Trait'},
['Tireless']={c='MXDXPX',t='Trait'},
['Bury']={c='M1D0P0',t='Event'},
['Avoid']={c='M2D0P0',t='Event'},
['Deliver']={c='M2D0P0',t='Event'},
['Peril']={c='M2D0P0',t='Event',depend='Loot'},
['Rush']={c='M2D0P0',t='Event'},
['Foray']={c='M3D0P0',t='Event',depend='Loot'},
['Launch']={c='M3D0P0',t='Event'},
['Mirror']={c='M3D0P0',t='Event'},
['Prepare']={c='M3D0P0',t='Event'},
['Scrounge']={c='M3D0P0',t='Event'},
['Journey']={c='M4D0P0',t='Event'},
['Maelstrom']={c='M4D0P0',t='Event'},
['Looting']={c='M6D0P0',t='Event',depend='Loot'},
['Invasion']={c='M10D0P0',t='Event',depend='Loot'},
['Prosper']={c='M10D0P0',t='Event',depend='Loot'},
['Amphora']={c='M7D0P0',t='Treasure - Loot'},
['Doubloons']={c='M7D0P0',t='Treasure - Loot'},
['Endless Chalice']={c='M7D0P0',t='Treasure - Duration - Loot'},
['Figurehead']={c='M7D0P0',t='Treasure - Duration - Loot'},
['Hammer']={c='M7D0P0',t='Treasure - Loot'},
['Insignia']={c='M7D0P0',t='Treasure - Loot'},
['Jewels']={c='M7D0P0',t='Treasure - Duration - Loot'},
['Orb']={c='M7D0P0',t='Treasure - Loot'},
['Prize Goat']={c='M7D0P0',t='Treasure - Loot'},
['Puzzle Box']={c='M7D0P0',t='Treasure - Loot'},
['Sextant']={c='M7D0P0',t='Treasure - Loot'},
['Shield']={c='M7D0P0',t='Treasure - Reaction - Loot'},
['Spell Scroll']={c='M7D0P0',t='Treasure - Loot'},
['Staff']={c='M7D0P0',t='Treasure - Loot'},
['Sword']={c='M7D0P0',t='Treasure - Attack - Loot'},
--PlunderKingdomCards
['Cage']={c='M2D0P0',t='Treasure - Duration'},
['Grotto']={c='M2D0P0',t='Action - Duration'},
['Jewelled Egg']={c='M2D0P0',t='Treasure',depend='Loot'},
['Search']={c='M2D0P0',t='Action - Duration',depend='Loot'},
['Shaman']={c='M2D0P0',t='Action'},
['Secluded Shrine']={c='M3D0P0',t='Action - Duration'},
['Siren']={c='M3D0P0',t='Action - Duration - Attack'},
['Stowaway']={c='M3D0P0',t='Action - Duration - Reaction'},
['Taskmaster']={c='M3D0P0',t='Action - Duration'},
['Abundance']={c='M4D0P0',t='Treasure - Duration'},
['Cabin Boy']={c='M4D0P0',t='Action - Duration'},
['Crucible']={c='M4D0P0',t='Treasure'},
['Flagship']={c='M4D0P0',t='Action - Duration - Command'},
['Fortune Hunter']={c='M4D0P0',t='Action'},
['Gondola']={c='M4D0P0',t='Treasure - Duration'},
['Harbor Village']={c='M4D0P0',t='Action'},
['Landing Party']={c='M4D0P0',t='Action - Duration'},
['Mapmaker']={c='M4D0P0',t='Action - Reaction'},
['Maroon']={c='M4D0P0',t='Action'},
['Rope']={c='M4D0P0',t='Treasure - Duration'},
['Swamp Shacks']={c='M4D0P0',t='Action'},
['Tools']={c='M4D0P0',t='Treasure'},
['Buried Treasure']={c='M5D0P0',t='Treasure - Duration'},
['Crew']={c='M5D0P0',t='Action - Duration'},
['Cutthroat']={c='M5D0P0',t='Action - Duration - Attack',depend='Loot'},
['Enlarge']={c='M5D0P0',t='Action - Duration'},
['Figurine']={c='M5D0P0',t='Treasure'},
['First Mate']={c='M5D0P0',t='Action'},
['Frigate']={c='M5D0P0',t='Action - Duration - Attack'},
['Longship']={c='M5D0P0',t='Action - Duration'},
['Mining Road']={c='M5D0P0',t='Action'},
['Pendant']={c='M5D0P0',t='Treasure'},
['Pickaxe']={c='M5D0P0',t='Treasure',depend='Loot'},
['Pilgrim']={c='M5D0P0',t='Action'},
['Quartermaster']={c='M5D0P0',t='Action - Duration'},
['Silver Mine']={c='M5D0P0',t='Treasure'},
['Trickster']={c='M5D0P0',t='Action - Attack'},
['Wealthy Village']={c='M5D0P0',t='Action',depend='Loot'},
['Sack of Loot']={c='M6D0P0',t='Treasure',depend='Loot'},
['King\'s Cache']={c='M7D0P0',t='Treasure'},
--PromoSummonFirstPrintings
['Black Market']={c='M3D0P0',t='Action'},
['Church']={c='M3D0P0',t='Action - Duration'},
['Envoy']={c='M4D0P0',t='Action'},
['Dismantle']={c='M4D0P0',t='Action'},
['Walled Village']={c='M4D0P0',t='Action'},
['Sauna / Avanto']={c='M4D0P0',t='Action'},
['Sauna']={c='M4D0P0',t='Action'},
['Avanto']={c='M5D0P0',t='Action'},
['Governor']={c='M5D0P0',t='Action'},
['Stash']={c='M5D0P0',t='Treasure'},
['Captain']={c='M6D0P0',t='Action - Duration - Command'},
['Prince']={c='M8D0P0',t='Action',depend='Aside'},
['Summon']={c='M5D0P0',t='Event',depend='Aside'},
['Adventurer']={c='M6D0P0',t='Action'},
['Chancellor']={c='M3D0P0',t='Action'},
['Feast']={c='M4D0P0',t='Action'},
['Spy']={c='M4D0P0',t='Action - Attack'},
['Thief']={c='M4D0P0',t='Action - Attack'},
['Woodcutter']={c='M3D0P0',t='Action'},
['Coppersmith']={c='M4D0P0',t='Action'},
['Great Hall']={c='M3D0P0',t='Action - Victory',VP=1},
['Saboteur']={c='M5D0P0',t='Action - Attack'},
['Scout']={c='M4D0P0',t='Action'},
['Secret Chamber']={c='M2D0P0',t='Action - Reaction'},
['Tribute']={c='M5D0P0',t='Action'},
['Original Band of Misfits']={c='M5D0P0',t='Action'},
['Original Overlord']={c='D8M0P0',t='Action'},
['Original Captain']={c='M6D0P0',t='Action - Duration'},
--X'tra's
['Xv1 El Dorado']={c='MXDXP0',t='Landmark',depend='Artifact'},
['X Handler v1']={c='M2D0P0',t='Action'},
['X Hops v1']={c='M2D0P0',t='Treasure - Duration'},
['X Smithing Tools']={c='M2D0P0',t='Action - Duration'},
['X Stallions']={c='M2D0P0',t='Action - Stallion',depend='Horse'},
['X Wat']={c='M2D0P1',t='Treasure - Victory',VP=1},
['X Informer']={c='M3D0P0',t='Action - Command'},
['X Notary']={c='M3D0P0',t='Action',depend='Heir'},
['X Lease']={c='M4D0P0',t='Action'},
['X Lessor']={c='M4D0P0',t='Action - Attack'},
['X Statue v1']={c='M4D0P0',t='Action - Victory',depend='Aside'},
['X Vigil v1']={c='M4D0P0',t='Action - Attack'},
['X Watchmaker']={c='M4D0P0',t='Action - Reserve'},
['X Plague Doctor v1']={c='M5D0P0',t='Action - Attack - Duration'},
['X Savings']={c='M5D0P0',t='Treasure'},
['X Tithe v1']={c='M5D0P0',t='Action - Attack - Reserve - Duration',depend='Debt'},
['X Grand Laboratory']={c='M6D0P0',t='Action'},
['X Shetland Pony']={c='M2D0P0',t='Action - Stallion'},
['X Clydesdale']={c='M3D0P0',t='Action - Stallion'},
['X Appaloosa']={c='M4D0P0',t='Action - Stallion'},
['X Paint Horse']={c='M5D0P0',t='Action - Stallion'},
['X Gypsy Vanner']={c='M6D0P0',t='Action - Stallion'},
['X Mustang']={c='M7D0P0',t='Action - Victory - Stallion',VP=2},
['X Friesian']={c='M8D0P0',t='Action - Victory - Stallion',VP=3},
['X Arabian Horse']={c='M9D0P0',t='Victory - Stallion'},
--Wonders http://forum.dominionstrategy.com/index.php?topic=20401.msg844160#msg844160
--X'v2 http://forum.dominionstrategy.com/index.php?topic=20407.0
['X Clock Tower']={c='MXDXP0',t='Landmark',depend='VP'},
['X El Dorado']={c='MXDXP0',t='Landmark',depend='Artifact'},
['X Science Grant']={c='M0D0P2',t='Project'},
['X Debate']={c='M0D0P0',t='Event',depend='Debt VP'},
['X Truce']={c='M3D0P0',t='Event',depend='Artifact'},
['X Collecting Artifacts']={c='M0D0P0',t='State'},
['X Pact']={c='M0D0P0',t='Artifact'},
['X Dice Games']={c='M0D5P0',t='Action'},
['X Draft']={c='M0D0P0',t='Action'},
['X Handler']={c='M2D0P0',t='Action'},
['X Hops']={c='M2D0P0',t='Treasure - Duration'},
['X Secret Path']={c='M3D0P0',t='Action - Duration - Victory',VP=1},
['X Duality']={c='M4D0P0',t='Action'},
['X Statue']={c='M4D0P0',t='Action - Victory'},
['X Stray Cat']={c='M4D0P0',t='Action - Reserve'},
['X Vigil']={c='M4D0P0',t='Action'},
['X Watchmaker']={c='M4D0P0',t='Action - Reserve'},
['X Mobsters']={c='M4D3P0',t='Night - Treasure'},
['X Custodian']={c='M5D0P0',t='Night - Attack - Duration'},
['X Market Town']={c='M5D0P0',t='Action'},
['X Plague Doctor']={c='M5D0P0',t='Action - Attack - Duration'},
['X Tithe']={c='M5D0P0',t='Action - Attack - Reserve - Duration',depend='Debt'},
['X Ballroom']={c='M7D0P0',t='Action'},
--Antiquities
['Q Agora']={c='M5D0P0',t='Action - Reaction',depend='BT'},
['Q Aquifer']={c='M4D0P0',t='Action',depend='BT'},
['Q Archaeologist']={c='M7D0P0',t='Action',depend='BT'},
['Q Boulder Trap']={c='M4D0P0',t='Trap',depend='BT',VP=-1},
['Q Collector']={c='M4D0P0',t='Action',depend='BT'},
['Q Curio']={c='M4D0P0',t='Treasure',depend='BT'},
['Q Dig']={c='M8D0P0',t='Action',depend='VP BT'},
['Q Discovery']={c='M2D0P0',t='Treasure',depend='BT'},
['Q Encroach']={c='M6D0P0',t='Action',depend='BT'},
['Q Gamepiece']={c='M3D0P0',t='Treasure - Reaction',depend='BT'},
['Q Grave Watcher']={c='M3D0P0',t='Action - Attack',depend='BT'},
['Q Graveyard']={c='M1D0P0',t='Action',depend='BT'},
['Q Inscription']={c='M3D0P0',t='Action - Reaction',depend='BT'},
['Q Inspector']={c='M3D0P0',t='Action - Attack',depend='BT'},
['Q Mastermind Antiquities']={c='M5D0P0',t='Action',depend='BT'},
['Q Mausoleum']={c='M6D0P0',t='Action',depend='Aside Memory BT'},
['Q Mendicant']={c='M4D0P0',t='Action',depend='VP BT'},
['Q Miner']={c='M3D0P0',t='Action',depend='BT'},
['Q Mission House']={c='M5D0P0',t='Action',depend='VP BT'},
['Q Moundbuilder Village']={c='M4D0P0',t='Action',depend='BT'},
['Q Pharaoh']={c='M8D0P0',t='Action - Attack',depend='BT'},
['Q Profiteer']={c='M3D0P0',t='Action',depend='BT'},
['Q Pyramid']={c='M5D0P0',t='Action',depend='BT'},
['Q Shipwreck']={c='M3D0P0',t='Action',depend='BT'},
['Q Snake Charmer']={c='M4D0P0',t='Action - Attack',depend='BT'},
['Q Stoneworks']={c='M4D0P0',t='Action',depend='VP BT'},
['Q Stronghold']={c='M5D0P0',t='Action - Reaction',depend='BT'},
['Q Tomb Raider']={c='M3D0P0',t='Action - Attack',depend='BT'},
--Legacy
['L Trade Agreement']={c='M0D0P0',t='Edict'},
['L Supervision']={c='M0D0P0',t='Edict'},
['L Simplicity']={c='M0D0P0',t='Edict',depend='Villager'},
['L Monarchy']={c='M0D0P0',t='Edict'},
['L Inflation']={c='M0D0P0',t='Edict'},
['L Imperialism']={c='M0D0P0',t='Edict',depend='Platinum'},
['L Gigantism']={c='M0D0P0',t='Edict'},--3 More supply piles
['L Expansion']={c='M0D0P0',t='Edict',depend='MinusCoin'},
['L Exile']={c='M0D0P0',t='Edict',depend='Aside'},
['L Diplomacy']={c='M0D0P0',t='Edict'},
['L Banishment']={c='M0D0P0',t='Edict'},
['L Appeasement']={c='M0D0P0',t='Edict'},
['L Tyranny']={c='M0D0P0',t='Edict',depend='MinusCoin'},
['L Urbanisation']={c='M0D0P0',t='Edict'},--Replace estate/shelter with copper
['L Exodus']={c='M3D0P0',t='Event'},
['L Contest']={c='M6D0P0',t='Event',depend='BlackMarket'},--Makes a Contest pile of 10 5Costs
['L Blessing']={c='M0D0P0',t='Event'},
['L Bureaucracy']={c='M5D0P0',t='Event'},--token on Province pile
['L Bargain']={c='M6D0P0',t='Event',depend='Coffers'},
['L Research']={c='M0D0P1',t='Event'},
['L Tithe']={c='M0D0P0',t='Event'},
['L Plundering']={c='M3D0P0',t='Event',depend='Spoils'},
['L Parting']={c='M3D0P0',t='Event',depend='Journey'},
['L Improve']={c='M5D0P0',t='Event'},
['L Alley']={c='M1D0P0',t='Action'},
['L Decree']={c='M2D0P0',t='Treasure'},
['L Sunken City']={c='M2D0P0',t='Action - Duration'},
['L Nun']={c='M3D0P0',t='Action'},
['L Sawmill']={c='M3D0P0',t='Action'},
['L Shrine']={c='M3D0P0',t='Action'},
['L Well']={c='M3D0P0',t='Action'},
['L Docks']={c='M4D0P0',t='Action - Duration'},
['L Farmer']={c='M4D0P0',t='Action'},
['L Gallows']={c='M4D0P0',t='Action'},
['L Heir Legacy']={c='M4D0P0',t='Action'},
['L Landlord']={c='M4D0P0',t='Action'},
['L Assemble']={c='M5D0P0',t='Action'},
['L Cliffside Village']={c='M5D0P0',t='Action'},
['L Craftsmen']={c='M5D0P0',t='Action'},
['L Lycantrope']={c='M5D0P0',t='Action - Attack'},
['L Maze']={c='M5D0P0',t='Action - Victory - Attack'},
['L Sultan']={c='M5D0P0',t='Action'},
['L Tribunal']={c='M5D0P0',t='Action - Attack'},
['L Meadow']={c='M6D0P0',t='Victory',VP=2},
--LegacyFeats
['L Headhunter']={c='M2D0P0',t='Action - Fame'},
['L Curiosity Shop']={c='M4D0P0',t='Action - Fame'},
['L Imposter']={c='M4D0P0',t='Action - Fame'},
['L Adventure-Seeker']={c='M5D0P0',t='Action - Fame'},
['L Inquisitor']={c='M5D0P0',t='Action - Attack - Fame'},
['L Hall of Fame']={c='M6D0P0',t='Victory - Fame'},
--LegacyExpert
['L Homunculus']={c='M0D0P1',t='Action'},
['L Promenade']={c='M0D8P0',t='Action'},
['L Institute']={c='M0D8P0',t='Action'},
['L Sheriff']={c='M2D0P0',t='Action - Attack'},
['L Swamp']={c='M2D0P0',t='Action',depend='Imp Ghost'},
['L Iron Maiden']={c='M3D0P0',t='Action - Attack - Looter'},
['L Incantation']={c='M3D0P1',t='Action'},
['L Pilgrim']={c='M3D0P0',t='Action',depend='Coffers'},
['L Scientist']={c='M3D0P0',t='Action',depend='Debt'},
['L Hunter']={c='M4D0P0',t='Action - Reserve'},
['L Lady-in-waiting']={c='M4D0P0',t='Action - Reserve'},
['L Scribe']={c='M4D0P0',t='Action - Attack - Duration',depend='Debt'},
['L Town']={c='M4D0P0',t='Action'},
['L Waggon Village']={c='M4D0P0',t='Action',depend='Debt'},
['L Delegate']={c='M5D0P0',t='Action'},
['L Lich']={c='M5D0P0',t='Action',depend='Zombie'},
['L Necromancer Legacy']={c='M5D0P0',t='Action'},
['L Sanctuary']={c='M5D0P0',t='Action'},
['L Minister']={c='M6D0P0',t='Action',depend='VP'},
['L Road']={c='M0D0P0',t='Action'},
['L Skeleton']={c='M3D0P0',t='Action - Attack'},
['L Zombie Legacy']={c='M3D0P0',t='Action - Attack'},
['L Loyal Subjects']={c='M3D0P0',t='Action - Attack'},
--LegacyTeams
['L Steeple']={c='M2D0P0',t='Action - Team'},
['L Conman']={c='M3D0P0',t='Action - Team'},
['L Fisher']={c='M3D0P0',t='Action - Reaction - Team'},
['L Merchant Quarter']={c='M4D0P0',t='Action - Team'},
['L Study']={c='M4D0P0',t='Action - Team'},
['L Still Village']={c='M4D0P0',t='Action - Duration - Team'},
['L Salesman']={c='M5D0P0',t='Action - Team'},
['L Sponsor']={c='M5D0P0',t='Action - Team'},
--Spellcasters
['S Wisdom']={c='M2D0P0',t='Spell'},
['S Wealth']={c='M4D0P0',t='Spell'},
['S Purity']={c='M2D0P0',t='Spell'},
['S Harm']={c='M3D0P0',t='Spell'},
['S Glory']={c='M8D0P0',t='Spell'},
['S Esprit']={c='M1D0P0',t='Spell'},
['S Dexterity']={c='M4D0P0',t='Spell'},
['S Trickster']={c='M2D0P0',t='Action - Spellcaster'},
['S Stone Circle']={c='M3D0P0',t='Victory - Spellcaster',VP=2},
['S Magician']={c='M3D0P0',t='Action - Spellcaster'},
['S Shaman']={c='M3D0P0',t='Action - Spellcaster'},
['S Summoner']={c='M4D0P0',t='Action - Spellcaster'},
['S Grimoire']={c='M4D0P0',t='Treasure - Spellcaster'},
['S Sorcerer']={c='M5D0P0',t='Action - Spellcaster'},
['S Wizard']={c='M5D0P0',t='Action - Spellcaster'},
--Seasons
['S Sojourner']={c='M2D0P0',t='Action - Season'},
['S Bailiff']={c='M3D0P0',t='Action - Season'},
['S Snow Witch']={c='M3D0P0',t='Action - Attack - Season'},
['S Student']={c='M3D0P0',t='Action - Season',depend='Following PlusCard PlusAction PlusBuy PlusCoin'},
['S Barbarian']={c='M4D0P0',t='Action - Season'},
['S Lumbermen']={c='M4D0P0',t='Action - Season'},
['S Peltmonger']={c='M4D0P0',t='Action - Season'},
['S Sanitarium']={c='M4D0P0',t='Action - Season'},
['S Timberland']={c='M4D0P0',t='Victory - Season',depend='VP',VP=2},
['S Ballroom']={c='M5D0P0',t='Action - Season'},
['S Cottage']={c='M5D0P0',t='Action - Season'},
['S Fjord Village']={c='M5D0P0',t='Action - Season'},
['S Plantation']={c='M5D0P0',t='Action - Season'},
['S Restore']={c='M5D0P0',t='Action - Season'},
--12Seasons http://forum.dominionstrategy.com/index.php?topic=20842.msg873086#msg873086
--Tools http://forum.dominionstrategy.com/index.php?topic=20273.0
['T Armor']={c='M4D0P0',t='Tool'},
['T Axe']={c='M4D0P0',t='Tool'},
['T Bag of Holding']={c='M5D0P0',t='Tool'},
['T Bow and Arrow']={c='M4D0P0',t='Tool - Attack'},
['T Compass']={c='M2D0P0',t='Tool'},
['T Moccasins']={c='M5D0P0',t='Tool'},
['T Rations']={c='M5D0P0',t='Tool'},
['T Spellbook']={c='M6D0P0',t='Tool - Command'},
['T Sword']={c='M5D0P0',t='Tool'},
['T Telescope']={c='M3D0P0',t='Tool'},
['T Wagon']={c='M3D0P0',t='Tool'},
['T Battalion']={c='M5D0P0',t='Action'},
['T Broken Sword']={c='M0D0P0',t='Tool'},
['T Charlatan']={c='M5D0P0',t='Action'},
['T Cursed Antique']={c='M0D0P0',t='Tool'},
--Roots&Renewal http://forum.dominionstrategy.com/index.php?topic=11563.0
['R Chancellery']={c='MXDXP0',t='Landmark'},
['R Realm Tax']={c='M0D0P0',t='Treasure'},
['R Refugees']={c='M2D0P0',t='Action'},
['R Salesman']={c='M2D0P0',t='Action - Reserve'},
['R Trapper']={c='M2D0P0',t='Action'},
['R Deposit']={c='M3D0P0',t='Action'},
['R Petty Lord']={c='M3D0P0',t='Action - Traveller - Looter',depend='Prime'},
['R Provisioner']={c='M3D0P0',t='Action'},
['R Builder']={c='M4D0P0',t='Action - Reaction'},
['R Mining Camp']={c='M4D0P0',t='Action - Looter'},
['R Orphanage']={c='M4D0P0',t='Action',depend='VP'},
['R Reconvert']={c='M4D0P0',t='Action'},
['R Reeve']={c='M4D0P0',t='Action',depend='Estate'},
['R Shire']={c='M4D0P0',t='Victory - Reaction'},
['R Beachcomb']={c='M5D0P0',t='Action'},
['R Benefit']={c='M5D0P0',t='Action - Reaction'},
['R Building Crane']={c='M5D0P0',t='Action'},
['R Juggler']={c='M5D0P0',t='Action'},
['R Reparations']={c='M5D0P0',t='Treasure'},
['R Revaluate']={c='M5D0P0',t='Action',depend='Prime'},
['R Riverside']={c='M6D0P0',t='Victory'},
['R Lock / Caretaker']={c='M4D0P0',t='Treasure'},
['R Lock']={c='M4D0P0',t='Treasure'},
['R Caretaker']={c='M5D0P0',t='Action'},
['R Key']={c='M4D0P0',t='Treasure'},
['R Forest Hut']={c='M1D0P0',t='Action - Shelter'},
['R Robber Knight']={c='M5D0P0',t='Action - Attack - Looter - Traveller'},
['R Protector']={c='M5D0P0',t='Action - Traveller'},
['R Warlord']={c='M7D0P0',t='Action - Attack'},
['R Savior']={c='M7D0P0',t='Action'},
['R Battlement']={c='M3D0P0',t='Action - Reaction'},
['R Manor']={c='M0D0P0',t='Action'},
--Adamabrams
['C Mortgage']={c='M6D0P0',t='Project',depend='Debt'},
['C Lost Battle']={c='M0D0P0',t='Landmark',depend='VP'},
['C Cave']={c='M4D0P0',t='Night - Victory',VP=2,depend='Artifact'},
['C Chisel']={c='M4D0P0',t='Action - Reserve',depend='Artifact'},
['C Knockout']={c='M7D0P0',t='Event',depend='Artifact'},
['C Migrant Village']={c='M1D0P1',t='Action',depend='Villager'},
['C Discretion']={c='M4D0P0',t='Action - Reserve',depend='VP Coffers Villager'},
['C Plot']={c='M4D0P0',t='Night',depend='VP'},
['C Investor']={c='M4D0P0',t='Action',depend='Debt'},
['C Contest']={c='M6D0P0',t='Action - Looter',depend='Prize'},
['C Uneven Road']={c='M6D0P0',t='Action - Victory',depend='Estate',VP=3},
['C Jekyll']={c='M3D0P1',t='Action'},
['C Hyde']={c='M4D0P1',t='Night - Attack'},
['C Stormy Seas']={c='M5D0P0',t='Night',depend='Debt'},
['C Liquid Luck']={c='M0D4P0',t='Action - Fate',depend='VP Potion'},
['C Cheque']={c='M6D0P0',t='Treasure - Command'},
['C Balance']={c='M2D0P0',t='Action - Reserve - Fate - Doom'},
--Co0kieL0rd http://forum.dominionstrategy.com/index.php?topic=13625.0
--icon https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Emojione_BW_1F36A.svg/768px-Emojione_BW_1F36A.svg.png
['C Volcano']={c='MXDXP0',t='Landmark'},
['C Masque']={c='MXDXP0',t='Landmark'},
['C Bog Village']={c='M4D0P0',t='Action'},
['C Cabal']={c='M5D0P0',t='Action - Attack'},
['C Turncoat']={c='M0D0P0',t='Action'},
['C Guest of Honor']={c='M4D0P0',t='Action - Reserve',depend='VP'},
['C Demagogue']={c='M4D0P0',t='Action - Attack'},
['C Draft Horses']={c='M3D0P0',t='Action'},
['C Dry Dock']={c='M4D0P0',t='Action - Duration'},
['C Dock']={c='M4D0P0',t='Action - Duration'},
['C Mediator']={c='M5D0P0',t='Action',depend='VP'},
['C Money Launderer']={c='M2D0P0',t='Action'},
['C Prefect']={c='M5D0P0',t='Action - Reserve',depend='Aside'},
['C Regal Decree']={c='M4D0P0',t='Action'},
['C Routing']={c='M5D0P0',t='Action'},
['C Secret Society']={c='M4D0P0',t='Action',depend='BlackMarket'},
['C Reconvert']={c='M4D0P0',t='Action'},
['C Mount']={c='M4D0P0',t='Action'},
['C Blackmail']={c='M4D0P0',t='Action'},
['C Search Party']={c='M5D0P0',t='Action'},
['C Suburb']={c='M3D0P0',t='Action - Reaction'},
['C Tollkeeper']={c='M3D0P0',t='Action - Duration'},
--WeeklyDesign http://forum.dominionstrategy.com/index.php?topic=18987.msg860685#msg860685
['C Corsair']={c='M4D0P0',t='Night - Attack - Fame'},
--Witches https://www.reddit.com/r/dominion/comments/hjwi11/witch_variants_for_every_expansion_day_7/
['W Equestrian Witch']={c='M5D0P0',t='Action - Attack',depend='Horse'},
['W Resourceful Witch']={c='M0D0P1',t='Action - Attack'},
['W Eclectic Witch']={c='M5D0P0',t='Action - Attack'},
['W Slum Witch']={c='M4D0P0',t='Action - Attack'},
['W Hedge Witch']={c='M4D0P0',t='Action - Attack - Gathering',depend='VP'},
['W Invoking Witch / W Summoned Fiend']={c='M3D0P0',t='Action - Attack'},
['W Summoned Fiend']={c='M5D0P0',t='Action - Attack - Doom'},
['W Miserly Witch']={c='M4D0P0',t='Action - Attack'},
['W Cursed Copper']={c='M0D0P0',t='Treasure - Curse',VP=-1},
--https://imgur.com/gallery/iaIN7iP
['W Faustian Witch']={c='M4D0P0',t='Action - Attack',depend='Reserve'},
['W Cursed Bargain']={c='M0D0P0',t='Treasure - Reserve - Curse',VP=-3},
['W Devious Witch']={c='M6D2P0',t='Action - Attack'},
--https://imgur.com/gallery/lx1BnPg
['W Rummaging Witch']={c='M3D0P0',t='Action - Attack'},
['W Retired Witch']={c='M2D0P0',t='Action - Attack',depend='Coffers'},
--https://imgur.com/gallery/18UZBgV
['W Nosy Witch']={c='M4D0P0',t='Action - Attack'},
['W Wandering Witch']={c='M6D0P0',t='Action - Attack - Reaction'},
--https://imgur.com/gallery/KV0V01h
['W Poisonous Witch']={c='M3D0P1',t='Action - Attack'},
['W Cursed Beverage']={c='M0D0P0',t='Treasure - Curse',VP=-2},
['W Prideful Witch']={c='M5D0P0',t='Action - Attack',depend='VP'},
--https://imgur.com/gallery/aLFCmWI
['W Versatile Witch']={c='M4D0P0',t='Action - Attack'},
['W Vengeful Witch']={c='M6D0P0',t='Action - Attack - Duration'},
--https://imgur.com/a/mw9c4N0
['W Ghostly Witch']={c='M5D0P0',t='Night - Attack'},
['W Ethereal Curse']={c='M0D0P0',t='Night - Curse',VP=-1},
['W Neighborhood Witch']={c='M4D0P0',t='Action',depend='Artifact Villager'},
['W Cauldron']={c='MXDXPX',t='Artifact'},
--Venus http://forum.dominionstrategy.com/index.php?topic=20585.0
['V Way of the Centaur']={c='MXDXPX',t='Way',depend='Horse'},
['V Way of the Mermaid']={c='MXDXPX',t='Way'},
['V Way of the Sphinx']={c='MXDXPX',t='Way'},
['V Way of the Harpy']={c='MXDXPX',t='Way'},
['V Way of the Medusa']={c='MXDXPX',t='Way'},
['V Way of the She-Wolf']={c='MXDXPX',t='Way',depend='Doom'},
['V Joy']={c='M0DXPX',t='Event'},
['V Lending']={c='M0DXPX',t='Event',depend='Debt'},
['V Burnish']={c='M1DXPX',t='Event'},
['V Footbridge']={c='M2DXPX',t='Event'},
['V Bride Wait']={c='MXD4PX',t='Event',depend='Aside'},
['V Calmness']={c='M4DXPX',t='Event',depend='MinusCard'},
['V Burning']={c='M5DXPX',t='Event'},
['V Restrain']={c='M5DXPX',t='Event'},
['V Cursed Land']={c='M6DXPX',t='Event'},
['V Pandora\'s Box']={c='M6DXPX',t='Event'},
['V Birth of Venus']={c='MXD7PX',t='Event'},
['V Veil of Protection']={c='M3DXPX',t='Project'},
['V Phoenix']={c='M3DXPX',t='Project'},
['V Divination']={c='M4DXPX',t='Project'},
['V Seasons Grace']={c='M6DXPX',t='Project',depend='Jorney'},
['V Greate Cathedral']={c='MXD8PX',t='Project',depend='Exile'},
['V Land Grant']={c='MXD12PX',t='Project'},
['V Acreage']={c='MXDXPX',t='Landmark'},
['V Barony']={c='MXDXPX',t='Landmark'},
['V Bishopric']={c='MXDXPX',t='Landmark'},
['V County']={c='MXDXPX',t='Landmark'},
['V Domain']={c='MXDXPX',t='Landmark'},
['V Gold Mine']={c='MXDXPX',t='Landmark'},
['V Grange']={c='MXDXPX',t='Landmark'},
['V Virgin Lands']={c='MXDXPX',t='Landmark'},
['V Yards']={c='MXDXPX',t='Landmark'},
['V Jane Doe']={c='M0D0P0',t='Action',depend='VP Coffers Villager Horse'},
['V Healer']={c='M2D0P0',t='Action - Reaction'},
['V Mirror']={c='M2D0P0',t='Action'},
['V Monk']={c='M2D0P0',t='Action',depend='VP Exile'},
['V Small Village']={c='M2D0P0',t='Action'},
['V Taverner']={c='M2D0P0',t='Action - Reserve'},
['V Wanderer']={c='M2D0P0',t='Action'},
['V Big Hall']={c='M3D0P0',t='Action',depend='VP'},
['V Flame Keeper']={c='M3D0P0',t='Action'},
['V Gambler']={c='M3D0P0',t='Action'},
['V Horse Lady']={c='M3D0P0',t='Action',depend='Horse Exile'},
['V Hoyden']={c='M3D0P0',t='Action'},
['V Maid']={c='M3D0P0',t='Action'},
['V Minstrel']={c='M3D0P0',t='Action'},
['V Morning']={c='M3D0P0',t='Action'},
['V Native']={c='M3D0P0',t='Action'},
['V Nurse']={c='M3D0P0',t='Night'},
['V Nymphs']={c='M3D0P0',t='Action'},
['V Resistance']={c='M3D0P0',t='Action'},
['V Sisterhood']={c='M3D0P0',t='Action'},
['V Valkyries']={c='M3D0P0',t='Action - Reaction',depend='Horse'},
['V Workers']={c='M3D0P0',t='Action',depend='Villager'},
['V Amazon']={c='M4D0P0',t='Action',depend='Horse'},
['V Blind Bet']={c='M4D0P0',t='Action'},
['V Bootleg']={c='M4D0P0',t='Action',depend='BlackMarket'},
['V Clown']={c='M4D0P0',t='Action - Attack'},
['V Dame']={c='M4D0P0',t='Action',depend='Horse'},
['V Duplication']={c='M4D0P0',t='Action',depend='VP'},
['V Emissary']={c='M4D0P0',t='Action - Attack'},
['V Expectancy']={c='M4D0P0',t='Action',depend='Aside Exile'},
['V Expulsion']={c='M4D0P0',t='Action - Attack'},
['V Faithful Knight']={c='M4D0P0',t='Action',depend='VP Coffers Villager'},
['V Fairy']={c='M4D0P0',t='Action'},
['V Four Seasons']={c='M4D0P0',t='Action'},
['V Ghost Pirate']={c='M4D0P0',t='Action - Attack'},
['V Gladiatrix']={c='M4D0P0',t='Action'},
['V Gravedigger']={c='M4D0P0',t='Night - Duration'},
['V Guildmaster']={c='M4D0P0',t='Action - Command',depend='Coffers'},--NoviceCards
['V Heiress']={c='M4D0P0',t='Action'},
['V Hidden Pond']={c='M4D0P0',t='Victory'},
['V Immolator']={c='M4D0P0',t='Action'},
['V Jewelry']={c='M4D0P0',t='Action - Treasure'},
['V Money Trick']={c='M4D0P0',t='Treasure - Reaction',depend='Coffers'},
['V Night Ranger']={c='M4D0P0',t='Night',depend='Journey'},
['V Privilege']={c='M4D0P0',t='Action'},
['V Sacred Hall']={c='M4D0P0',t='Action - Victory',depend='VP'},
['V Secret Place']={c='M4D0P0',t='Action',depend='Aside'},
['V Succubus']={c='M4D0P0',t='Night - Reserve'},
['V Tavern Show']={c='M4D0P0',t='Action - Command',depend='Reserve'},
['V Tiara']={c='M4D0P0',t='Treasure'},
['V Voyage']={c='M4D0P0',t='Action'},
['V Warrioresses']={c='M4D0P0',t='Action - Attack - Duration',depend='Exile'},
['V Wishing Fountain']={c='M4D0P0',t='Action'},
['V Tale-Teller']={c='M4D0P0',t='Night'},
['V Archeologist']={c='M5D0P0',t='Action - Duration',depend='Looter'},
['V Banker']={c='M5D0P0',t='Action'},
['V Blessing']={c='M5D0P0',t='Action',depend='Wish'},
['V Buffoon']={c='M5D0P0',t='Action - Attack - Command'},
['V Circus Camp']={c='M5D0P0',t='Action'},
['V Crusader']={c='M5D0P0',t='Action'},
['V Dangerous Ground']={c='M5D0P0',t='Action'},
['V Dusk Warrior']={c='M5D0P0',t='Action - Duration'},
['V Fertility']={c='M5D0P0',t='Action'},
['V Golden Spoils']={c='M5D0P0',t='Treasure'},
['V Hands of Gold']={c='M5D0P0',t='Night',depend='Villager'},
['V Lanterns']={c='M5D0P0',t='Action'},
['V Librarian']={c='M5D0P0',t='Action - Duration'},
['V Magic Archive']={c='M5D0P0',t='Action - Duration'},
['V Magic Library']={c='M5D0P0',t='Action - Reaction'},
['V Maneuver']={c='M5D0P0',t='Action'},
['V Marketplace']={c='M5D0P0',t='Action'},
['V Nightmare']={c='M5D0P0',t='Action - Attack'},
['V Nomad']={c='M5D0P0',t='Action'},
['V Path']={c='M5D0P0',t='Action'},
['V Rebel']={c='M5D0P0',t='Action - Duration - Attack'},
['V Samurai']={c='M5D0P0',t='Action',depend='Coffers Villager'},
['V Shenanigans']={c='M5D0P0',t='Action - Attack'},
['V Shipmaster']={c='M5D0P0',t='Action - Duration'},
['V Swinehero']={c='M5D0P0',t='Action - Duration'},
['V Tavern Nights']={c='M5D0P0',t='Night - Reserve'},
['V Janus']={c='M5D0P0',t='Action',depend='Journey'},
['V Councillor']={c='M5D0P0',t='Action'},
['V Distant Island']={c='M6D0P0',t='Victory',depend='Exile',VP=2},
['V Paladin']={c='M6D0P0',t='Action'},
['V Swamp']={c='M7D0P0',t='Action - Victory',VP=-1},
['V Fruits / Fruit Mix']={c='M4D0P0',t='Treasure',depend='Coffers'},
['V Fruits']={c='M4D0P0',t='Treasure',depend='Coffers'},
['V Fruit Mix']={c='M6D0P0',t='Treasure',depend='Coffers'},
['V Bewitch']={c='M5D0P0',t='Action',depend='SpellV'},
['V Witchcraft']={c='M4D0P0',t='Action - Duration - Attack',depend='SpellV'},
['V Spellbound']={c='M4D0P0',t='Night',depend='VP SpellV'},
--NonSupplyVenus
['V Spell']={c='M0D0P0',t='Action - Victory',VP=-1},
['V Young Saboteur']={c='M0D0P0',t='Action - Novice'},
['V Young Sorceress']={c='M0D0P0',t='Action - Novice'},
['V Young Smith']={c='M0D0P0',t='Action - Novice'},
['V Young Trickster']={c='M0D0P0',t='Action - Novice',depend='Coffers'},
['V Coin of Honor']={c='M2D0P0',t='Treasure - Heirloom'},
['V Blessed Gems']={c='M2D0P0',t='Treasure - Heirloom'},
['V Spring']={c='M6D0P0',t='Action - Traveller - Season'},
['V Summer']={c='M6D0P0',t='Action - Traveller - Season'},
['V Fall']={c='M6D0P0',t='Action - Traveller - Season'},
['V Winter']={c='M6D0P0',t='Action - Traveller - Season'},
['V Harpy']={c='M2D0P0',t='Action - Attack'},
['V Medusa']={c='M2D0P0',t='Action - Attack'},
['V She-Wolf']={c='M2D0P0',t='Action - Attack - Doom'},
--Alchemy Reforged http://forum.dominionstrategy.com/index.php?topic=20753.0
['R Alkahest']={c='M0D0P1',t='Action'},
['R Elixir of Life']={c='M1D0P1',t='Action'},
['R Ingredients']={c='M1D0P1',t='Action',depend='Coffers'},
['R Aqua Vitae']={c='M2D0P1',t='Action'},
['R Panacea']={c='M3D0P1',t='Action'},
['R Transmute']={c='M4D0P1',t='Action'},
['R Homunculi']={c='M5D0P1',t='Action'},
['R Philosopher\'s Stone']={c='M0D0P2',t='Action'},
['R Holy Relics']={c='M3D0P0',t='Action',depend='Artifact'},
['R Four Elements']={c='M4D0P0',t='Action'},
['R Bibliothecary']={c='M4D0P0',t='Action',depend='Villager'},
['R Athenaeum']={c='M5D0P0',t='Action'},
['R Research Library']={c='M5D0P0',t='Action'},
['R Study']={c='M5D0P0',t='Action'},
['R Workroom']={c='M5D0P0',t='Action'},
['R Royal Archives']={c='M6D0P0',t='Action'},
['R Chain Reaction']={c='M2D0P0',t='Action - Reaction'},
['R Black Powder']={c='M3D0P0',t='Action - Attack'},
['R Orrery']={c='M3D0P0',t='Action - Duration'},
['R Distill']={c='M4D0P0',t='Action',depend='Villager Coffers VP'},
['R Aqua Regia']={c='M4D0P0',t='Action'},
['R Sanctum']={c='M4D0P0',t='Action - Victory',depend='VP'},
['R Quicksilver']={c='M5D0P0',t='Action - Treasure'},
['R Prima Materia']={c='M6D0P0',t='Action - Treasure'},
['R Potion Seller']={c='M0D0P1',t='Project'},
['R Fermentation']={c='M1D0P1',t='Project'},
['R Magnum Opus']={c='M3D0P1',t='Project'},
['R Bell']={c='MXDXPX',t='Artifact'},
['R Book']={c='MXDXPX',t='Artifact'},
['R Candle']={c='MXDXPX',t='Artifact'},
['R Air']={c='M4D0P0',t='Action'},
['R Water']={c='M4D0P0',t='Action'},
['R Earth']={c='M4D0P0',t='Action'},
['R Fire']={c='M4D0P0',t='Action'},
--Custom https://www.reddit.com/r/dominion/comments/hrx0rb/original_new_cards_i_made_hope_you_enjoy1_lol/
--Landscapes https://www.reddit.com/r/dominion/comments/pp62rq/custom_set_dominion_landscapes/
['C Cloakmaker']={c='M3D0P0',t='Action'},
['C Drought']={c='M3D0P0',t='Action - Attack - Duration - Disaster'},
['C Recovery']={c='M2D0P0',t='Event',depend='Disaster'},
['C Early Frost']={c='M3D0P0',t='Action - Attack Disaster'},
['C Earthquake']={c='M3D0P0',t='Action - Attack Disaster'},
['C Emergency Fund']={c='M2D0P0',t='Treasure - Reaction'},
['C Flood Plains']={c='M4D0P0',t='Action - Victory'},
['C Field Researcher']={c='M5D0P0',t='Action - Duration'},
['C Flood']={c='M5D0P0',t='Action - Attack Disaster'},
['C Forester']={c='M5D0P0',t='Action'},
['C Hysteric']={c='M5D0P0',t='Action - Attack Disaster'},
['C Meteorologist']={c='M2D0P0',t='Action'},
['C Panorama']={c='M9D0P0',t='Action - Victory - Command'},
['C Profiteer']={c='M4D0P0',t='Action'},
['C Prospector']={c='M3D0P0',t='Action',depend='Coffers'},
['C Twister']={c='M4D0P0',t='Action - Attack Disaster'},
['C Wayfarer']={c='M3D0P0',t='Action'},
['C Wildfire']={c='M1D0P0',t='Action - Disaster'},
['C Wreckage Broker']={c='M6D0P0',t='Action - Duration',depend='Coffers'},
['C Wastes']={c='M0D0P0',t='Victory'},
--RandomCustoms
['Letter']={c='MXDXPX',t='Artifact'},
['Statue']={c='MXDXPX',t='Artifact'},
['Torch']={c='MXDXPX',t='Artifact'},
['Champion\'s Belt']={c='MXDXPX',t='Artifact'},
['C Evil Lair']={c='M5D0P0',depend='Artifact'},
['Haunted Crown']={c='MXDXPX',t='Artifact'},
['C Burned Village']={c='M5D0P0',t='Action - Night'},
['C Rescuers']={c='M4D0P0',t='Treasure - Heirloom'},
['C Ancient Coin']={c='M5D0P0',t='Treasure - Duration'},
['C Witching Hour']={c='M5D0P0',t='Night - Duration - Attack'},
['C Panda / Gardener']={c='M4D0P0',t='Action',depend='Coffers Villager'},
['C Panda']={c='M4D0P0',t='Action'},
['C Gardener']={c='M6D0P0',t='Action'},
['C Bacchanal']={c='M0D0P8',t='Night',depend='Villager'},
['C Homestead']={c='M4D0P0',t='Action'},
['C Tulip Field']={c='M4D0P0',t='Victory',depend='Coffers Villager'},
['C Backstreet']={c='M5D0P0',t='Night',depend='Coffers Villager'},
['C Rabbit']={c='M0D0P0',t='Action - Treasure'},
['C Magician']={c='M5D0P0',t='Action',depend='Rabbit Coffers'},
['C Fishing Boat']={c='M4D0P0',t='Action - Duration'},
['C Drawbridge']={c='M3D0P0',t='Action - Reserve'},
['C Jinxed Jewel v1']={c='M4D0P0',t='Treasure - Night - Heirloom'},
['C Jinxed Jewel']={c='M4D0P0',t='Treasure - Night - Heirloom',depend='Heirloom'},
['']={c='M0D0P0'},
}--[[Find Replace Performed
({c=.+),name=('.+')(,t.+},)
[\2]=\1\3
Second
({c=.+),name=('.+')(,.+},)
[\2]=\1\3
Third
({c=.+),name=('.+')},
[\2]=\1},
]]