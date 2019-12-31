--DominionDefinitiveEditionModifiedByAmuzet2019_12_01_B
function onSave()
    --saved_data = ""

    saved_data = JSON.encode({
        gs = gameState,
        emax = eventMax,
        bmax = blackMarketMax,
        ect = eventCount,
        ust = useSets,
        upt = usePlatinum,
        ush = useShelters,
        uhl = useHeirlooms,
        obl = obeliskTarget,
        bmd = bmDeck
        --ref = globalVariable,
    })
    return saved_data
end
--Runs when the map is first loaded
function onLoad(saved_data)
  local Color = {
    Red = {219/255,26/255,24/255},
    White = {0.3,0.3,0.3},
    Orange = {244/255,100/255,29/255},
    Green = {49/255,179/255,43/255},
    Yellow = {231/255,229/255,44/255},
    Blue = {31/255,136/255,255/255}
  }
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        gameState = loaded_data.gs
        eventMax = loaded_data.emax
        blackMarketMax = loaded_data.bmax
        eventCount = loaded_data.ect
        useSets = loaded_data.ust
        usePlatinum = loaded_data.upt
        useShelters = loaded_data.ush
        useHeirlooms = loaded_data.uhl
        obeliskTarget = loaded_data.obl
        bmDeck = loaded_data.bmd
        -- globalVariable = loaded_data.ref
    else
        gameState = 1
        eventMax = 4
        blackMarketMax = 25
        eventCount = 0
        usePlatinum = 0
        useShelters = 0
        useHeirlooms = false
        useSets = {}
        bmDeck = {}
        obeliskTarget = nil
        -- global variables that need to be saved between loads
    end
    setUninteractible()
    math.randomseed(os.time())
    if gameState == 1 then
        --Added Heirlooms
        for _,v in ipairs( getPile("Heirlooms").getObjects() ) do
            ref_heirlooms[v.name] = v.guid
        end
        setNotes("[40e0d0][b][u]Dominion: Definitive Edition[/b][/u][ffffff]\n\nBefore pressing Start Game, you may place any card from the expansion piles into the empty supply slots. Select any number of expansions to be randomly selected to fill all the remaining slots. You may also remove any undesireable card from its expansion deck to prevent it from being selected. You may save the game now to save your selected kingdom and expansions before pressing start.\n\n[FFFF00][b]Do not delete any decks or place any deck of cards into a supply slot.[/b]")
        for i in ipairs(ref_cardSets) do
            local obj = getObjectFromGUID(ref_cardSets[i].guid)
            if obj ~= nil then
                obj.createButton({
                    label="Select\n"..obj.getName(), click_function="click_selectDeck",
                    function_owner=Global, position={0,0.4,0.6}, rotation={0,0,0}, scale={0.5,1,0.5},
                    height=600, width=1500, font_size=250
                })
                for j, guid in ipairs(useSets) do
                    local obj2 = getObjectFromGUID(guid)
                    if obj == obj2 then
                        obj.highlightOn({0,1,0})
                        break
                    end
                end
            end
        end
        local obj = getObjectFromGUID(ref_startButton)
        if obj ~= nil then
            local btn=setmetatable({function_owner=Global,position={0,0,-20},rotation={0,180,0},height=2000,width=5750,font_size=9000},{__call=function(b,l,p,t,f)
                    b.label,b.position,b.tooltip=l,p,t or'';if f then b.click_function=f else b.click_function='click_' .. l:gsub('[^\n]+\n',''):gsub('%s','')end obj.createButton(b)end})
            btn('Max Events: ' .. eventMax,               {14,0,-20}, 'The Maximum number of noncards in Kingdom','click_eventLimit')
            btn('Selected Sets\nStart Game',              {0,0,-20},  'Random Kingdom from selected sets and cards')
            btn('Black Market\nLimit: ' .. blackMarketMax,{-14,0,-20},'The Number of cards in the Black Market','click_blackMarketLimit')
            
            btn('Tutorial\nBasic Game',{0,0,-26},  'Set Kingdom with only actions and up to two attacks')
            btn('Tutorial\nCard Types',{14,0,-26}, 'Random Kingdom with half being Non Action Cards')
            btn('Tutorial\nAdvanced',  {-14,0,-26},'Random Kingdom with non vanilla sets')
            
            btn('Currated Setup\nDesigners',      {14,0,-32}, 'Picks a Kingdom from a list of currated sets made by the Designers')
            btn('Currated Setup\nDominion League',{0,0,-32},  'Picks a Kingdom from a list of currated sets played in tournaments')
            btn('Currated Setup\nReddit Weekly',  {-14,0,-32},'Set Kingdom for this week from Reddit')
            
            btn('Quick Setup\nAll Sets',  {14,0,-38}, 'Random Kingdom from every set')
            btn('Quick Setup\nTwo Sets',  {0,0,-38},  'Random Kingdom from any two sets')
            btn('Quick Setup\nThree Sets',{-14,0,-38},'Random Kingdom from any three sets')
            
        end
        obj = getObjectFromGUID(ref_extraSupplyPiles[1].guid)
        if obj ~= nil then
            obj.createButton({
                label="Select", click_function="click_selectRandom",
                function_owner=Global, position={0,0,2.5}, rotation={0,0,0},
                height=300, width=750, font_size=250
            })
            if usePlatinum == 1 then obj.highlightOn({0,1,0})
            elseif usePlatinum == 2 then obj.highlightOn({1,0,0}) end
        end
        obj = getObjectFromGUID(ref_extraSupplyPiles[5].guid)
        if obj ~= nil then
            obj.createButton({
                label="Select", click_function="click_selectRandom",
                function_owner=Global, position={0,0,2.5}, rotation={0,0,0},
                height=300, width=750, font_size=250
            })
            if useShelters == 1 then obj.highlightOn({0,1,0})
            elseif useShelters == 2 then obj.highlightOn({1,0,0}) end
        end
    end
    if gameState == 2 then
        bcast("Setup was interrupted, please reset the game.")
    end
    if gameState == 3 then
        if obeliskTarget ~= nil then
            for i, obj in ipairs(getAllObjects()) do
                if obj.getName() == "Obelisk" or obj.getName() == obeliskTarget .. " pile" then
                    obj.highlightOn({1,0,1})
                end
            end
        end
        createEndButton()
    end
end
function createEndButton()
    local obj = getObjectFromGUID(ref_startButton)
    if obj ~= nil then
        obj.createButton({
            label="End Game", click_function="click_endGame",
            function_owner=Global, position={0,0,24.5}, rotation={0,180,0},
            height=1500, width=4000, font_size=9000
        })
    end
end
function click_endGame(obj, color)
    if not Player[color].admin then
        bcast("Only the host and promoted players can end the game.", {0.75,0.75,0.75}, color)
        return
    end
    setNotes("[40e0d0][b][u]Final Scores:[/b][/u][FFFFFF]\n")
    victoryPoints = {Red = nil, White = nil, Orange = nil, Green = nil, Yellow = nil, Blue = nil}
    deckTracker = {Red = nil, White = nil, Orange = nil, Green = nil, Yellow = nil, Blue = nil}
    function scoreCoroutine()
        
        wait(2)
        for i = 1, #getSeatedPlayers() do
            local currentPlayer = getSeatedPlayers()[i]
            local move = function(zone)
                for _, obj in ipairs(zone) do
                    if obj.tag == "Card" or obj.tag == "Deck" then
                        local t = obj.getDescription()
                        if t ~= "Boon" and t ~= "Hex" and t ~= "Artifact" and t ~= "State" then
                            obj.setRotation({0,180,180})
                            obj.setPosition(ref_players[currentPlayer].deck)
                            coroutine.yield(0)
            end end end end
            local gObjs = function(s) getObjectFromGUID(ref_players[currentPlayer][s]).getObjects() end
            if Player[currentPlayer].getHandCount() > 0 then
                victoryPoints[currentPlayer] = 0
                deckTracker[currentPlayer] = {}
                
                move(gObjs("deckZone"))
                move(Player[currentPlayer].getHandObjects(1))
                move(gObjs("discardZone"))
                move(gObjs("island"))
                for i, obj in ipairs(gObjs("tavern")) do
                    if obj.tag == "Deck" then
                        for j, card in ipairs(obj.getObjects()) do
                            if card.nickname == "Distant Lands" then
                                victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + 4
                    end end end
                    if obj.tag == "Card" then
                        if obj.getName() == "Distant Lands" then
                            victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + 4
                    end end
                    if obj.tag == "Card" or obj.tag == "Deck" then
                        local t = obj.getDescription()
                        if t == "Boon" or t == "Hex" or t == "Artifact" or t == "State" then else
                            obj.setRotation({0,180,180})
                            obj.setPosition(ref_players[currentPlayer].deck)
                            coroutine.yield(0)
                end end end
                for i, obj in ipairs(gObjs("zone")) do
                    if obj.tag == 'Card' and obj.getName() == 'Miserable / Twice Miserable' then
                        victoryPoints[currentPlayer] = victoryPoints[currentPlayer] - 2
                        local rot = obj.getRotation()
                        if 90 < rot.z and rot.z < 270 then
                          victoryPoints[currentPlayer] = victoryPoints[currentPlayer] - 2
                          bcast(currentPlayer..' is Twice Miserable',{1,0,1})
                        else
                          bcast(currentPlayer..' is Miserable',{1,0,1})
        end end end end end
        wait(2)
        for i = 1, #getSeatedPlayers() do
            local currentPlayer = getSeatedPlayers()[i]
            if Player[currentPlayer].getHandCount() > 0 then
                local tracker = {
                  amount = 0,
                  actions = 0,
                  castles = 0,
                  estates = 0,
                  orchard = 0,
                  knights = 0,
                  uniques = 0, --WolfDen
                  victory = 0,
                  deck = {}
                }
                for i, obj in ipairs(getObjectFromGUID(ref_players[currentPlayer].deckZone).getObjects()) do
                    if obj.tag == "Deck" then
                        for v, card in ipairs(obj.getObjects()) do
                            if deckTracker[currentPlayer][card.nickname] == nil then
                                deckTracker[currentPlayer][card.nickname] = 1
                            else
                                deckTracker[currentPlayer][card.nickname] = 1 + deckTracker[currentPlayer][card.nickname]
                    end end end
                    if obj.tag == "Card" then
                        if deckTracker[currentPlayer][card.getName()] == nil then
                            deckTracker[currentPlayer][card.getName()] = 1
                        else
                            deckTracker[currentPlayer][card.getName()] = 1 + deckTracker[currentPlayer][card.getName()]
                end end end
                tracker.deck = deckTracker[currentPlayer]
                for i, v in pairs(tracker.deck) do
                    tracker.amount = tracker.amount + v
                    if string.find(getType(i), "Action") ~= nil then
                        tracker.actions = tracker.actions + v
                        if v > 2 then
                            tracker.orchard = tracker.orchard + 1
                        end
                    end
                    if string.find(getType(i), "Victory") ~= nil then
                        tracker.victory = tracker.victory + v
                    end
                    if string.find(getType(i), "Castle") ~= nil then
                        tracker.castles = tracker.castles + 1
                    end
                    if string.find(getType(i), "Knight") ~= nil then
                        tracker.knights = tracker.knights + v
                    end
                    if v == 1 then
                        tracker.uniques = tracker.uniques + 1
                    end
                end
                -- Score Gardens
                for k, v in pairs(tracker.deck) do
                    local vp = getVP(cName)
                    if type(vp) == 'function' then vp = vp(tracker) end
                    victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + vp
                end
                -- Score VP tokens
                if getObjectFromGUID(ref_players[currentPlayer].vp) ~= nil then
                    victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + getObjectFromGUID(ref_players[currentPlayer].vp).call("getCount")
                end
                -- Score Obelisk
                if obeliskTarget ~= nil then
                    if tracker.deck[obeliskTarget] ~= nil then
                        victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + tracker.deck[obeliskTarget] * 2
                    end
                end
                if obeliskTarget == "Knights" then
                    victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + tracker.knights * 2
                end
                -- Landmarks
                for _ in ipairs(ref_eventSlots) do
                    for i, obj2 in ipairs(getObjectFromGUID(ref_eventSlots[i].zone).getObjects()) do
                        if obj2.tag == "Card" then
                            local vp = getVP(obj2.getName())
                            if type(vp) == 'function' then
                                victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + vp(tracker)
                            else
                                victoryPoints[currentPlayer] = victoryPoints[curr]
                            end
                            if obj2.getName() == "Keep" then
                                for card, count in pairs(tracker.deck) do
                                    if string.find(getType(card), "Treasure") ~= nil then
                                        local winner = true
                                        for otherPlayer, deck in pairs(deckTracker) do
                                            if otherPlayer ~= currentPlayer and deck ~= nil then
                                                if deck[card] ~= nil then
                                                    if deck[card] > count then
                                                        winner = false
                                        end end end end
                                        if winner then
                                            victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + 5
                            end end end end
                            if obj2.getName() == "Tower" then
                                local towerCount,notEmpty,zones=0,{},{}
                                for j,guid in ipairs(ref_basicSlotZones)do table.insert(zones,getObjectFromGUID(guid))end
                                table.insert(zones,getObjectFromGUID(ref_baneSlot.zone))
                                for j,slot in ipairs(ref_kingdomSlots)do table.insert(zones,getObjectFromGUID(slot.zone))end
                                for j,zone in ipairs(zones)do for __,obj in ipairs(zone.getObjects())do
                                        if obj.tag=='Card'and obj.getName()~='Bane Card'then
                                            if string.find(getType(obj.getName()), "Knight") == nil then
                                                table.insert(notEmpty, obj.getName())
                                            else
                                                table.insert(notEmpty, "Knights")
                                            end
                                        elseif obj.tag == "Deck" then
                                            table.insert(notEmpty, string.sub(obj.getName(), 1, -6))
                                end end end
                                for card, count in pairs(tracker.deck) do
                                    local found = false
                                    for i, pile in ipairs(notEmpty) do
                                        if pile == card then
                                            found = true
                                    end end
                                    if string.find(getType(card), "Knight") ~= nil then
                                        for i, pile in ipairs(notEmpty) do
                                            if pile == "Knights" then
                                                found = true
                                    end end end
                                    for i, bmCard in ipairs(bmDeck) do
                                        if card == bmCard then
                                            found = true
                                    end end
                                    if string.find(getType(card), "Victory") == nil and not found then
                                        victoryPoints[currentPlayer] = victoryPoints[currentPlayer] + count
                end end end end end end
                
                setNotes(getNotes() .. "\n" .. currentPlayer .. " VP: " .. victoryPoints[currentPlayer])
                
                printToAll(currentPlayer .. "'s Deck:", Color[currentPlayer])
                
                for card, count in pairs(deckTracker[currentPlayer]) do
                    local s = "0"
                    if count > 9 then s = "" end
                    printToAll(s..count .. " " .. card, {1,1,1})
        end end end
        local obj = getObjectFromGUID(ref_startButton)
        return 1
    end
    if obj then obj.clearButtons()end
    gameState = 4
    startLuaCoroutine(Global, "scoreCoroutine")
end
--Used in Button Callbacks
newText = setmetatable({type='3DText',position={},rotation={90,0,0}
    },{__call = function(t,p,text,f)
      t.position=p
      local o=spawnObject(t)
      o.TextTool.setValue(text)
      o.TextTool.setFontSize(f or 25)
    end})
function rcs(a)return math.random(1,#ref_cardSets-(a or 4))end
function timerStart(t)click_StartGame(t[1],t[2])end
function findCard( target, Ref, pos )
    for j,set in ipairs(Ref)do
        local deck = getObjectFromGUID( set.guid )
        if deck and deck.tag=='deck'then
            for _,card in ipairs( deck.getObjects() )do
                if card.name == target then
                    log('Found: '..target)
                    deck.takeObject({position=pos,index=card.index,smooth = false})
                    break end end end end end
function kingdomList(tbl,par)
    if tbl.bane then findCard( tbl.bane, ref_cardSets, ref_baneSlot.pos )end
    if tbl.S then useShelters=1 else useShelters=2 end
    if tbl.P then usePlatinum=1 else usePlatinum=2 end
    local res = ref_eventSets
    local sum = res[4]
    table.remove(res,4)
    for i,target in ipairs(tbl)do
        if i < 11 then
            findCard( target, ref_cardSets, ref_kingdomSlots[i].pos )
        elseif target == 'Summon' then
            getObjectFromGUID( sum.guid ).setPosition( ref_eventSlots[i-10].pos )
        else
            findCard( target, res, ref_eventSlots[i-10].pos )
        end
    end
    table.insert(res,4,sum)
    Timer.create({
        identifier = 'RedditWeekly',
        function_name = 'timerStart',
        parameters = par,
        delay = 3
    })
end
--Button Callbacks
function click_selectDeck(obj, color)
    local guid = obj.getGUID()
    local inUse = true
    for i, guid2 in ipairs(useSets) do
        local obj2 = getObjectFromGUID(guid2)
        if obj == obj2 then
            obj.highlightOff()
            inUse = false
            table.remove(useSets, i)
            break
        end
    end
    if inUse then
        obj.highlightOn({0,1,0})
        table.insert(useSets, guid)
    end
end
function click_AllSets(obj, color)
    useSets={}
    for i,set in ipairs(ref_cardSets)do if i<15 table.insert(useSets,set.guid)end end
    click_StartGame(obj, color)
end
function click_TwoSets(obj, color)
    useSets={}
    local n,m=rcs(),rcs()
    while m==n do m=rcs()end
    table.insert(useSets, ref_cardSets[n].guid)
    table.insert(useSets, ref_cardSets[m].guid)
    
    click_StartGame(obj, color)
end
function click_ThreeSets(obj, color)
    useSets={}
    local n,m,o=rcs(),rcs(),rcs()
    while m==n do m=rcs()end
    while o==m or o==n do o=rcs()end
    table.insert(useSets,ref_cardSets[n].guid)
    table.insert(useSets,ref_cardSets[m].guid)
    table.insert(useSets,ref_cardSets[o].guid)
    
    click_StartGame(obj, color)
end
function click_RedditWeekly(obj, color)
  --https://www.reddit.com/r/dominion/search?q=title%3Akotw+author%3Aavocadro&sort=newl&utm_name=dominion&t=week
  local KotW = "KotW 12/1: Bishop, Crown, Forager, Goons, Inventor, King's Court, Lighthouse, Lurker, Remake, Watchtower. Events: Dominate, Donate. Colony/Platinum; no Shelters. [Intrigue, Seaside, Prosperity, Cornucopia, Dark Ages, Empires, Renaissance]"
  
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
  local knd = {
{'Vineyard','Pearl Diver','Stonemason','Oasis','Storeroom','Philosopher\'s Stone','Talisman','Herald','Cultist','Fairgrounds',Shelter=true},
{'Stonemason','Hermit','Wishing Well','Fortress','Nomad','Camp','Sea Hag','Golem','Bandit Camp','Merchant Guild','Mystic',Shelter=true},
{'Herbalist','Sage','Mining Village','Rats','Salvager','Highway','Horn of Plenty','Rogue','Soothsayer','Peddler'},
{'Embargo','Secret Chamber','Watchtower','Swindler','Bridge','Procession','Talisman','Gardens','Jester','Mint'},
{'Oracle','Village','Fortress','Moneylender','Plaza','Silk Road','City','Contraband','Library','Pillage'},
{'University','Menagerie','Horse Traders','Bazaar','Embassy','Margrave','Pillage','Altar','Grand Market','Expand',Platinum=true},
{'Moat','Vagrant','Scheme','Island','Throne Room','Salvager','Jester','Rabble','Fairgrounds','Peddler'},
{'Oasis','Shanty Town','Marauder','Young Witch','Mining Village','Silk Road','Market','Stables','Merchant Ship','Graverobber',bane='Vagrant'},
{'Storeroom','Wishing Well','Coppersmith','Mining Village','Salvager','Throne Room','Mint','Tactician','Bank','Forge',Platinum=true},
{'Horse Traders','Fool\'s Gold','Menagerie','Develop','Warehouse','Conspirator','Minion','Duke','Horn of Plenty','Candlestick Maker'},
{'Counting','House','Mountebank','Inn','Festival','Throne Room','Plaza','Gardens','Trade Route','Storeroom','Scheme',Platinum=true},
{'Poor House','Hamlet','Tunnel','Oracle','Doctor','Remake','Sea Hag','Inn','Merchant Guild','King\'s Court'},
{'Squire','Bridge','Apprentice','Haggler','Marauder','Urchin','Shanty Town','Library','Hoard','Harem',Shelter=true},
{'Stonemason','Tunnel','Storeroom','Watchtower','Rats','Bishop','Fortress','Catacombs','Minion','Hunting Grounds',Shelter=true},
{'Fool\'s Gold','Native Village','Stonemason','Market','Square','Wishing Well','Ironmonger','Procession','Catacombs','Witch','Adventurer'},
{'Scavenger','Philosopher\'s Stone','Gardens','Squire','Worker\'s Village','Vault','Steward','Caravan','Mountebank','Adventurer',Platinum=true},
{'Vineyard','Apothecary','Fishing Village','Menagerie','Envoy','Young Witch','Market','Goons','Hoard','Expand',bane='Wishing Well',Platinum=true},
{'Fool\'s Gold','Lookout','Shanty Town','Warehouse','Woodcutter','Remodel','Sea Hag','Apprentice','Bazaar','Hoard'},
{'Hamlet','Menagerie','Tunnel','Watchtower','Monument','Remake','Inn','Tactician','Adventurer','Bank'},
{'Courtyard','Oracle','Trade Route','Tournament','Golem','Bazaar','Mint','Rabble','Fairgrounds','King\'s Court'},
{'Vineyard','Herbalist','Fishing Village','Philosopher\'s Stone','Caravan','Young Witch','Horn of Plenty','Mandarin','Royal Seal','Trading Post',bane='Watchtower'},
{'Ambassador','Lookout','Wishing Well','Bishop','Ironworks','Monument','Trader','Venture','Expand','Peddler',Platinum=true},
{'Crossroads','Embargo','Trade Route','Tunnel','Village','Warehouse','Workshop','Silk Road','Spice Merchant','Apprentice'},
{'Moat','Fortune','Teller','Bridge','Moneylender','Smithy','Throne Room','Festival','Jester','Vault','Fairgrounds'},
{'Chapel','Embargo','Fool\'s Gold','Oasis','Workshop','Thief','Throne Room','Worker\'s Village','Margrave','Wharf'},
{'Haven','Fishing Village','Scheme','Steward','Horse Traders','Mountebank','Upgrade','Festival','Library','Goons'},
{'Native Village','Talisman','Treasure Map','Worker\'s Village','City','Vault','Venture','Grand Market','Expand','Peddler',Platinum=true},
{'Moat','Tunnel','Bishop','Gardens','Ironworks','Young Witch','Tournament','Council Room','Torturer','Border Village',bane='Hamlet'},
{'Crossroads','Loan','Silk Road','Baron','Bureaucrat','Apprentice','Duke','Farmland','Harem','Nobles',Platinum=true},
{'Haven','Great','Hall','Workshop','Masquerade','Ironworks','Island','Throne Room','Tactician','Goons','King\'s Court'},
{'Lookout','Masquerade','Oracle','Smithy','Worker\'s Village','Festival','Ghost Ship','Margrave','Mountebank','Treasury'},
{'Embargo','University','Scrying Pool','Worker\'s Village','Remodel','Wharf','Rabble','Grand Market','Forge','Peddler',Platinum=true},
{'Menagerie','Tunnel','Ghost Ship','Governor','Inn','Monument','Worker\'s Village','Grand Market','Goons','Adventurer'},
{'Embargo','Scheme','Menagerie','Watchtower','Fishing Village','Remake','Haggler','Vault','Grand Market','Expand',Platinum=true},
{'Crossroads','Secret Chamber','Warehouse','Loan','Ambassador','Caravan','Worker\'s Village','Bureaucrat','Merchant Ship','Grand Market',Platinum=true},
{'Chapel','Fishing Village','Watchtower','Ironworks','Gardens','Bridge','Highway','Mountebank','Ill-Gotten','Gains','Goons',Platinum=true},
{'Torturer','Merchant Ship','Moneylender','Caravan','Familiar','Watchtower','Steward','University','Embargo','Hamlet'},
{'Counting','House','Vault','Laboratory','Golem','Coppersmith','Worker\'s Village','Tunnel','Chancellor','Apothecary','Hamlet'},
{'Harem','Venture','Golem','Tournament','Bishop','Thief','Remake','Tunnel','Fishing Village','Fool\'s Gold'},
{'Forge','Torturer','Governor','Mountebank','Wharf','Sea Hag','Worker\'s Village','Familiar','Fishing Village','Chapel'},
{'Fairgrounds','Nobles','Golem','Spy','Quarry','Ironworks','Throne Room','Menagerie','Black Market','Native Village'}
    }
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
end
function click_Designers(obj, color)
  bcast('Loading a Set created by the Designers')
  local knd = {
{'Courtyard','Minion','Steward','Mining Village','Conspirator','Bureaucrat','Chancellor','Council Room','Mine','Militia'},
{'Herbalist','Transmute','Apothecary','Alchemist','Golem','Cellar','Chancellor','Festival','Militia','Smithy'},
{'Bishop','Goons','Monument','Peddler','Grand Market','Council Room','Cellar','Library','Throne Room','Chancellor'},
{'Bank','Expand','Forge','King\'s Court','Vault','Bridge','Coppersmith','Swindler','Tribute','Wishing Well'},
{'Fairgrounds','Farming Village','Horse Traders','Jester','Young Witch','Feast','Laboratory','Market','Remodel','Workshop',bane='Cellar'},
{'Crossroads','Farmland','Fool\'s Gold','Oracle','Spice Merchant','Adventurer','Chancellor','Festival','Laboratory','Remodel'},
{'Bureaucrat','Council Room','Feast','Laboratory','Market','Moneylender','Remodel','Smithy','Village','Workshop'},
{'Adventurer','Laboratory','Library','Militia','Throne Room','Bridge','Masquerade','Shanty Town','Steward','Trading Post'},
{'Cellar','Feast','Gardens','Witch','Workshop','Ambassador','Fishing Village','Lighthouse','Merchant Ship','Treasury'},
{'Adventurer','Council Room','Mine','Moneylender','Village','Expand','Loan','Quarry','Vault','Venture'},
{'Cellar','Gardens','Market','Militia','Mine','Remodel','Throne Room','Alchemist','Apothecary','Herbalist'},
{'Bureaucrat','Chancellor','Chapel','Festival','Library','Moat','Hamlet','Horse Traders','Jester','Remake'},
{'Conspirator','Coppersmith','Courtyard','Duke','Harem','Nobles','Scout','Trading Post','Upgrade','Wishing Well'},
{'Conspirator','Coppersmith','Harem','Masquerade','Mining Village','Ambassador','Caravan','Merchant Ship','Native Village','Tactician'},
{'Great Hall','Ironworks','Masquerade','Mining Village','Upgrade','City','Grand Market','Royal Seal','Talisman','Trade Route'},
{'Courtyard','Duke','Great Hall','Minion','Nobles','Scout','Wishing Well','Herbalist','Transmute','Vineyard'},
{'Bridge','Ironworks','Minion','Shanty Town','Steward','Upgrade','Fairgrounds','Harvest','Horse Traders','Young Witch',bane='Courtyard'},
{'Caravan','Embargo','Explorer','Fishing Village','Ghost Ship','Island','Lighthouse','Salvager','Treasury','Warehouse'},
{'Ghost Ship','Haven','Island','Lookout','Tactician','Bishop','Trade Route','Venture','Watchtower','Worker\'s Village'},
{'Bazaar','Cutpurse','Lookout','Pearl Diver','Salvager','Warehouse','Wharf','Apprentice','University','Vineyard'},
{'Bazaar','Embargo','Haven','Navigator','Warehouse','Wharf','Fortune Teller','Hamlet','Horn of Plenty','Hunting Party'},
{'Bank','Expand','Goons','Hoard','Mint','Monument','Peddler','Royal Seal','Talisman','Worker\'s Village'},
{'Bank','Goons','Hoard','Mint','Quarry','Vault','Watchtower','Apothecary','Apprentice','Transmute'},
{'Bishop','Grand Market','Loan','Monument','Peddler','Rabble','Farming Village','Horn of Plenty','Menagerie','Tournament'},
{'Cellar','Festival','Library','Market','Militia','Moneylender','Smithy','Thief','Throne Room','Woodcutter'},
{'Conspirator','Coppersmith','Duke','Great Hall','Harem','Pawn','Scout','Steward','Torturer','Upgrade'},
{'Adventurer','Bureaucrat','Council Room','Remodel','Workshop','Caravan','Ghost Ship','Merchant Ship','Native Village','Outpost'},
{'Chancellor','Festival','Moat','Witch','Woodcutter','Apprentice','Golem','Philosopher\'s Stone','University','Vineyard'},
{'Cellar','Council Room','Gardens','Thief','Village','Forge','Hoard','Loan','Rabble','Venture'},
{'Cellar','Feast','Laboratory','Mine','Workshop','Fairgrounds','Farming Village','Fortune Teller','Horn of Plenty','Menagerie'}
    }
  kingdomList( knd[ math.random(1,#knd) ] , {obj,color} )
end
function click_VanillaSets(obj, color)
  bcast('Setting up Base Game and Intrigue')
  useSets = {ref_cardSets[1].guid,ref_cardSets[2].guid}
  click_StartGame(obj,color)
end
function click_BasicGame(obj, color)
  bcast('Beginner Tutorial')
  newText({26.00, 0.96, 25.00},'THE GAME ENDS WHEN:\nAny 3 piles are empty or\nThe Province pile is empty.')
  newText({0.00, 0.96, 11.00},'On your turn you may play One ACTION.\nOnce you have finished playing actions you may play TREASURES.\nThen you may Buy One Card. ([i]Cards you play can change all these[/i])')
  local knd = {
    {'Cellar','Festival','Mine','Moat','Patrol','Poacher','Smithy','Village','Witch','Workshop'},
    {'Cellar','Market','Merchant','Militia','Mine','Moat','Remodel','Smithy','Village','Workshop'}}
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

function click_selectRandom(obj, color)
    local guid = obj.getGUID()
    if guid == ref_extraSupplyPiles[1].guid then
        if usePlatinum < 2 then
            usePlatinum = 1 + usePlatinum
            if usePlatinum == 1 then
                obj.highlightOn({0,1,0})
            else
                obj.highlightOn({1,0,0})
            end
        else
            usePlatinum = 0
            obj.highlightOff()
        end
    elseif guid == ref_extraSupplyPiles[5].guid then
        if useShelters < 2 then
            useShelters = 1 + useShelters
            if useShelters == 1 then
                obj.highlightOn({0,1,0})
            else
                obj.highlightOn({1,0,0})
            end
        else
            useShelters = 0
            obj.highlightOff()
        end
    end
end
function click_eventLimit(obj, color)
    local buttonIndex = nil
    for i, button in ipairs (obj.getButtons()) do
        if string.find(button.label, "Max Events: ") ~= nil then
            buttonIndex = button.index
        end
    end
    if eventMax < 4 then
        eventMax = eventMax + 1
    else
        eventMax = 0
    end
    obj.editButton{index = buttonIndex, label = "Max Events: " .. eventMax}
end
function click_blackMarketLimit(obj, color)
    local buttonIndex = nil
    for i, button in ipairs (obj.getButtons()) do
        if string.find(button.label, "Black Market") ~= nil then
            buttonIndex = button.index
        end
    end
    if blackMarketMax < 40 then
        blackMarketMax = blackMarketMax + 5
    else
        blackMarketMax = 10
    end
    obj.editButton{index = buttonIndex, label = "Black Market\nLimit: " .. blackMarketMax}
end
--function called when you click to start the game
function click_StartGame(obj, color)
    if not Player[color].admin then
        bcast("Only the host and promoted players can start the game.", {0.75,0.75,0.75}, color)
        return
    end
    if getPlayerCount() < 2 or getPlayerCount() > 6 then
        bcast("This game needs 2 to 6 players to start.", {0.75,0.75,0.75}, color)
        return
    end
    local summonException = false
    for i in ipairs(ref_eventSlots) do
        local summonCheck = getObjectFromGUID(ref_eventSlots[i].zone).getObjects()
        for j, v in ipairs(summonCheck) do
            if v.getName() == "Summon" then
                summonException = true
                break
            end
        end
    end
    local requireBane = false
    local requireBlackMarket = false
    local cardCount = 0
    for i in ipairs(ref_kingdomSlots) do
        local supplyZone = getObjectFromGUID(ref_kingdomSlots[i].zone)
        local supplyCheck = supplyZone.getObjects()
        for j in ipairs(supplyCheck) do
            local zoneObj = supplyCheck[j]
            if zoneObj.tag == "Card" then
                if zoneObj.getName() == "Young Witch" then
                    requireBane = true
                    local baneZone = getObjectFromGUID(ref_baneSlot.zone).getObjects()
                    for k in ipairs(baneZone) do
                        local baneObj = baneZone[k]
                        if baneObj.tag == "Card" and baneObj.getName() ~= "Bane pile" then
                            if getCost(baneObj.getName()) ~= "M2D0P0" and getCost(baneObj.getName()) ~= "M3D0P0" then
                                bcast("Bane card needs to cost 2 or 3 with no debt or potions.", {0.75,0.75,0.75}, color)
                                return
                            else
                                requireBane = false
                                break
                            end
                        end
                    end
                end
                if zoneObj.getName() == "Black Market" then
                    requireBlackMarket = true
                end
                cardCount = cardCount + 1
            end
        end
    end
    if not requireBane then
        for j, guid in ipairs(useSets) do
            local obj2 = getObjectFromGUID(guid)
            if obj2 ~= nil then
                for k, ref in ipairs (obj2.getObjects()) do
                    if ref.nickname == "Young Witch" then
                        requireBane = true
                    elseif ref.nickname == "Black Market" then
                        requireBlackMarket = true
                    end
                end
            end
        end
    end
    if cardCount == 10 and not requireBane and not requireBlackMarket then
        removeButtons()
        setupKingdom(summonException)
        gameState = 2
    elseif cardCount > 10 then
        bcast("You have too many already chosen kingdom cards.", {0.75,0.75,0.75}, color)
        return
    else
        local cardCount2 = 0
        for j, guid in ipairs(useSets) do
            local obj2 = getObjectFromGUID(guid)
            if obj2 ~= nil then
                cardCount2 = #obj2.getObjects() + cardCount2
            end
        end
        if cardCount2 < 11 - cardCount then
            bcast("You don't have enough cards selected to form a random kingdom.", {0.75,0.75,0.75}, color)
            return
        elseif requireBane then
            local deckCheck = false
            for j, guid in ipairs(useSets) do
                local obj2 = getObjectFromGUID(guid)
                for k, ref in ipairs (obj2.getObjects()) do
                    if getCost(ref.nickname) == "M2D0P0" or getCost(ref.nickname) == "M3D0P0" then
                        if ref.nickname ~= "Young Witch" then
                            deckCheck = true
                        end
                    end
                end
            end
            if not deckCheck then
                bcast("Selected cards need a valid possible Bane card.", {0.75,0.75,0.75}, color)
                return
            elseif cardCount2 < 12 - cardCount then
                bcast("You don't have enough cards selected to form a random kingdom.", {0.75,0.75,0.75}, color)
                return
            end
        elseif cardCount2 < 20 - cardCount and requireBlackMarket then
            bcast("You don't have enough cards selected to form a random kingdom.", {0.75,0.75,0.75}, color)
            return
        end
        -- random kingdom start
        removeButtons()
        setupKingdom(summonException)
        gameState = 2
    end
end
-- Function to remove all buttons
function removeButtons()
    local obj = getPile("Shelters")
    if obj ~= nil then obj.flip() end
    for i in ipairs(ref_cardSets) do
        local obj = getObjectFromGUID(ref_cardSets[i].guid)
        if obj ~= nil then
            obj.clearButtons()
        end
    end
    local obj = getObjectFromGUID(ref_startButton)
    if obj ~= nil then
        obj.clearButtons()
    end
    obj = getObjectFromGUID(ref_extraSupplyPiles[1].guid)
    if obj ~= nil then
        obj.clearButtons()
    end
    obj = getObjectFromGUID(ref_extraSupplyPiles[5].guid)
    if obj ~= nil then
        obj.clearButtons()
    end
end
-- Function to setup the Kingdom
function setupKingdom(summonException)
    -- first we delete all the not in use sets and group the remaining
    for i in ipairs(ref_cardSets) do
        local found = false
        local guid = ref_cardSets[i].guid
        local obj = getObjectFromGUID(guid)
        for j, guid2 in ipairs(useSets) do
            local obj2 = getObjectFromGUID(guid2)
            if obj == obj2 and obj ~= nil then
                obj.setPosition(ref_randomizer.pos)
                obj.flip()
                found = true
            end
        end
        local obj2 = nil
        if guid == ref_cardSets[10].guid then
            obj2 = getObjectFromGUID(ref_eventSets[1].guid)
        elseif guid == ref_cardSets[11].guid then
            obj2 = getObjectFromGUID(ref_eventSets[2].guid)
            local obj3 = getObjectFromGUID(ref_eventSets[3].guid)
            if obj3 ~= nil and found then
                obj3.setRotation({0,0,0})
                obj3.setPosition(ref_randomizer.pos)
                obj3.flip()
            elseif obj3 ~= nil and not found then obj3.destruct() end
        --Renaissance
        elseif guid == ref_cardSets[13].guid then
            obj2 = getObjectFromGUID(ref_eventSets[4].guid)
        --Promos
        elseif guid == ref_cardSets[14].guid and not summonException then
            obj2 = getObjectFromGUID(ref_eventSets[5].guid)
        --Adamabrams
        elseif guid == ref_cardSets[15].guid then
            obj2 = getObjectFromGUID(ref_eventSets[6].guid)
        end
        if obj2 ~= nil and found then
            obj2.setRotation({0,0,0})
            obj2.setPosition(ref_randomizer.pos)
            obj2.flip()
        elseif obj2 ~=nil and not found then obj2.destruct() end
        if not found and obj ~= nil then
            obj.destruct()
        end
    end
    function setupKingdomCoroutine()
        wait(2)
        local zone = getObjectFromGUID(ref_randomizer.zone).getObjects()
        local deck
        for i, v in ipairs(zone) do
            if v.tag == "Deck" then deck = v end
        end
        if deck ~= nil then
            deck.setRotation({0,180,180})
            deck.shuffle()
            deck.highlightOff()
        end
        wait(1)
        local events = {}
        for i in ipairs(ref_eventSlots) do
            zone = getObjectFromGUID(ref_eventSlots[i].zone).getObjects()
            for j, v in ipairs(zone) do
                if v.tag == "Card" then table.insert(events, v) end
            end
        end
        for i in ipairs(events) do
            events[i].setPosition(ref_eventSlots[i].pos)
        end
        eventCount = #events
        if deck ~= nil then
            for i in ipairs(ref_kingdomSlots) do
                card = false
                zone = getObjectFromGUID(ref_kingdomSlots[i].zone).getObjects()
                for j, v in ipairs(zone) do
                    if v.tag == "Card" then card = true end
                end
                while not card do
                    for j, v in pairs(deck.getObjects()) do
                        if v.description == "Event" or v.description == "Landmark" or v.description == "Project" then
                            if eventCount < eventMax then
                                eventCount = eventCount + 1
                                deck.takeObject({position = ref_eventSlots[eventCount].pos, index = v.index, callback = "setCallback", callback_owner = Global})
                                break
                            end
                        else
                            card = true
                            deck.takeObject({position = ref_kingdomSlots[i].pos, index = v.index, flip = true})
                            break
                        end
                    end
                end
            end
            wait(0.5)
            local blackMarket = false
            local requireBane = false
            for i in ipairs(ref_kingdomSlots) do
                zone = getObjectFromGUID(ref_kingdomSlots[i].zone).getObjects()
                for j, v in ipairs(zone) do
                    if v.tag == "Card" then
                        if v.getName() == "Young Witch" then
                            requireBane = true
                            break
                        elseif v.getName() == "Black Market" then
                            blackMarket = true
                        end
                    end
                end
            end
            if blackMarket then
                deck.setName("Black Market deck")
                local cleanDeck = false
                local deckAddPos = {deck.getPosition()[1],deck.getPosition()[2] + 2,deck.getPosition()[3]}
                while not cleanDeck do
                    cleanDeck = true
                    for i, v in ipairs(deck.getObjects()) do
                        if v.description == "Event" or v.description == "Landmark" then
                            coroutine.yield(0)
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Knight" then
                            coroutine.yield(0)
                            getPile("Knights pile").shuffle()
                            getPile("Knights pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Castles" then
                            coroutine.yield(0)
                            getPile("Castles pile").shuffle()
                            getPile("Castles pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Catapult / Rocks" then
                            coroutine.yield(0)
                            getPile("Catapult / Rocks pile").shuffle()
                            getPile("Catapult / Rocks pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Encampment / Plunder" then
                            coroutine.yield(0)
                            getPile("Encampment / Plunder pile").shuffle()
                            getPile("Encampment / Plunder pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Gladiator / Fortune" then
                            coroutine.yield(0)
                            getPile("Gladiator / Fortune pile").shuffle()
                            getPile("Gladiator / Fortune pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Patrician / Emporium" then
                            coroutine.yield(0)
                            getPile("Patrician / Emporium pile").shuffle()
                            getPile("Patrician / Emporium pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Settlers / Bustling Village" then
                            coroutine.yield(0)
                            getPile("Settlers / Bustling Village pile").shuffle()
                            getPile("Settlers / Bustling Village pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Sauna / Avanto" then
                            coroutine.yield(0)
                            getPile("Sauna / Avanto pile").shuffle()
                            getPile("Sauna / Avanto pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        end
                    end
                end
                wait(2)
                deck.shuffle()
                while #deck.getObjects() > blackMarketMax + 1 do
                    coroutine.yield(0)
                    deck.takeObject({index = 1}).destruct()
                end
                -- check for young witch
                for i, v in ipairs(deck.getObjects()) do
                    if v.nickname == "Young Witch" then
                        requireBane = true
                    end
                end
                if not requireBane then
                    deck.takeObject({index = 1}).destruct()
                end
            end
            local baneSet = false
            local blackMarket2Check = false
            if requireBane then
                zone = getObjectFromGUID(ref_baneSlot.zone).getObjects()
                for i, v in ipairs(zone) do
                    if v.tag == "Card" and v.getName() ~= "Bane pile" then
                        baneSet = true
                        if v.getName() == "Black Market" then
                            blackMarket2Check = true
                        end
                    end
                end
                if not baneSet then
                    for j, card in ipairs(deck.getObjects()) do
                        if card.description == "Event" or card.description == "Landmark" then
                        elseif getCost(card.nickname) == "M2D0P0" or getCost(card.nickname) == "M3D0P0" then
                            if card.nickname == "Black Market" then
                                blackMarket2Check = true
                            end
                            deck.takeObject({position = ref_baneSlot.pos, index = card.index, flip = true})
                            break
                        end
                    end
                end
            end
            if blackMarket2Check then
                deck.setName("Black Market deck")
                local cleanDeck = false
                local deckAddPos = {deck.getPosition()[1],deck.getPosition()[2] + 2,deck.getPosition()[3]}
                while not cleanDeck do
                    cleanDeck = true
                    for i, v in ipairs(deck.getObjects()) do
                        if v.description == "Event" or v.description == "Landmark" then
                            coroutine.yield(0)
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Knight" then
                            coroutine.yield(0)
                            getPile("Knights pile").shuffle()
                            getPile("Knights pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Castles" then
                            coroutine.yield(0)
                            getPile("Castles pile").shuffle()
                            getPile("Castles pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Catapult / Rocks" then
                            coroutine.yield(0)
                            getPile("Catapult / Rocks pile").shuffle()
                            getPile("Catapult / Rocks pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Encampment / Plunder" then
                            coroutine.yield(0)
                            getPile("Encampment / Plunder pile").shuffle()
                            getPile("Encampment / Plunder pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Gladiator / Fortune" then
                            coroutine.yield(0)
                            getPile("Gladiator / Fortune pile").shuffle()
                            getPile("Gladiator / Fortune pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Patrician / Emporium" then
                            coroutine.yield(0)
                            getPile("Patrician / Emporium pile").shuffle()
                            getPile("Patrician / Emporium pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Settlers / Bustling Village" then
                            coroutine.yield(0)
                            getPile("Settlers / Bustling Village pile").shuffle()
                            getPile("Settlers / Bustling Village pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        elseif v.nickname == "Sauna / Avanto" then
                            coroutine.yield(0)
                            getPile("Sauna / Avanto pile").shuffle()
                            getPile("Sauna / Avanto pile").takeObject({index = 1, position = deckAddPos, flip = true})
                            deck.takeObject({index = v.index}).destruct()
                            cleanDeck = false
                            break
                        end
                    end
                end
                wait(2)
                deck.shuffle()
                while #deck.getObjects() > blackMarketMax do
                    coroutine.yield(0)
                    deck.takeObject({index = 1}).destruct()
                end
            end
            if deck.getName() == "Black Market deck" then
                for i, card in ipairs(deck.getObjects()) do
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
    startLuaCoroutine(Global, "setupKingdomCoroutine")
end
-- Callback to fix the event position
function setCallback(obj)
    obj.setRotation({0,90,0})
end
-- Function to reorder the Kingdom
function reorderKingdom()
    --First create an array with all the card names plus the costs in it
    local sortedKingdom = {}
    for i in ipairs(ref_kingdomSlots) do
        local zone = getObjectFromGUID(ref_kingdomSlots[i].zone).getObjects()
        for j, v in ipairs(zone) do
            if v.tag == "Card" then
              --Error with Projects
                table.insert(sortedKingdom, getCost(v.getName()) .. v.getName())
            end
        end
    end
    --Then sort the list
    table.sort(sortedKingdom)
    --Finally, set the positions based on the new order
    for i, v in ipairs(sortedKingdom) do
        sortedKingdom[i] = string.sub(v, 7)
        for j in pairs(ref_kingdomSlots) do
            local zone = getObjectFromGUID(ref_kingdomSlots[j].zone).getObjects()
            for k, b in ipairs(zone) do
                if b.getName() == sortedKingdom[i] then
                    b.setPosition(ref_kingdomSlots[i].pos)
                end
            end
        end
    end
    --Do the same for events
    if eventCount > 0 then
        local sortedEvents = {}
        for i in ipairs(ref_eventSlots) do
            local zone = getObjectFromGUID(ref_eventSlots[i].zone).getObjects()
            for j, v in ipairs(zone) do
                if v.tag == "Card" then
                    table.insert(sortedEvents, getCost(v.getName()) .. v.getName())
                end
            end
        end
        table.sort(sortedEvents)
        for i, v in ipairs(sortedEvents) do
            sortedEvents[i] = string.sub(v, 7)
            for j in ipairs(ref_eventSlots) do
                local zone = getObjectFromGUID(ref_eventSlots[j].zone).getObjects()
                for k, b in ipairs(zone) do
                    if b.getName() == sortedEvents[i] then
                        b.setPosition(ref_eventSlots[i].pos)
                        b.setLock(true)
                    end
                end
            end
        end
    end
end
function check(v,n) return string.sub(v.getName(), 1, -6) == n end


local Use=setmetatable({' ',' '},
  {__call=function(t,s)local _,n=t[1]:gsub(s,s);if n>0 then return n end return false end})
function Use.Add(cardname)
    local n,s=0,''
    Use[2] = Use[2]..cardname
    --Costs
    if getCost(cardname):sub(-1) == "1" then s=s..'Potion 'end
    if not getCost(cardname):find("D0") then s=s..'Debt 'end
    --Types
    for _,t in pairs({'Looter','Reserve','Doom','Fate'}) do
        if getType(cardname):find(t) then s=s..t..' '
    end end
    --CardSpecific
    for i, v in pairs(ref_master)do
        if cardName == v.name then n=i
            if v.depend then
                s=s..v.depend..' '
            end break
    end end
    if n>100 and n<126 then s=s..'Platinum '
    elseif n>175 and n<225 then s=s..'Shelters 'end
    Use[1] = Use[1]..s
end
function cleanUp()
    --Checks
    for i,z in pairs(ref_kingdomSlots) do
        for j, v in ipairs(getObjectFromGUID(z.zone).getObjects()) do
            if v.tag == "Deck" then
                local name=string.sub(v.getName(), 1, -6)
                if name=="Knights"then Use.Add('Knight')else Use.Add(name)
    end end end end
    
    if Use('Bane')then
        for i, v in pairs(getObjectFromGUID(ref_baneSlot.zone).getObjects())do
            if v.tag == "Deck" then
                local name=string.sub(v.getName(), 1, -6)
                if name=="Knights"then Use.Add('Knight')else Use.Add(name)end end end
    else for i, v in pairs(getObjectFromGUID(ref_baneSlot.zone).getObjects())do v.destruct()end end
    
    if Use('BlackMarket')then
      for i, v in ipairs(getObjectFromGUID(ref_randomizer.zone).getObjects())do
        if v.getName()=='Black Market deck' then
          for i, v in pairs(blackMarketDeck.getObjects())do Use.Add(v.nickname)end
          v.setPosition(ref_randomizer.pos)
          v.setRotation({0,180,180})end end
    else for i, v in ipairs(getObjectFromGUID(ref_randomizer.zone).getObjects())do v.destruct()end end
    
    for _,z in pairs(ref_eventSlots) do
        for j, v in ipairs(getObjectFromGUID(z.zone).getObjects()) do
            if v.tag == "Card" then Use.Add(name)
    end end end
    --ProperCleanUp
    local sp=function(a,b)local _,c=Use[1]:gsub(b,b);if a~=1 then if c>9 or math.random(a,1+c-a*5)>0 then a=1;end end end
    sp(useShelters,'Shelters')
    sp(usePlatinum,'Platinum')
    if usePlatinum~=1 then
        getPile('Platinum pile').destruct()
        getPile('Colony pile').destruct()
        getPile('Gold pile').setPosition(ref_basicSlots[5].pos)
        getPile('Silver pile').setPosition(ref_basicSlots[4].pos)
        getPile('Copper pile').setPosition(ref_basicSlots[3].pos)
        getPile('Potion pile').setPosition(ref_basicSlots[2].pos)
        getPile('Ruins pile').setPosition(ref_basicSlots[6].pos)
        getObjectFromGUID(ref_basicSlots[1].guid).destruct()
        getObjectFromGUID(ref_basicSlots[7].guid).destruct()
    else getPile('Platinum pile').highlightOff()end
    
    if not Use('Potion') then
        getPile('Potion pile').destruct()
        if usePlatinum~=1 then
            getObjectFromGUID(ref_basicSlots[2].guid).destruct()
        else
            getObjectFromGUID(ref_basicSlots[1].guid).destruct()
        end
    end
    if not Use('Looter') then
        getPile('Ruins pile').destruct()
        if usePlatinum~=1 then
            getObjectFromGUID(ref_basicSlots[6].guid).destruct()
        else
            getObjectFromGUID(ref_basicSlots[7].guid).destruct()
        end
    end
    
    if Use('Fate')then getPile("Boon pile").shuffle()else getPile("Boon pile").destruct()end
    if Use('Doom')then getPile("Hex pile").shuffle()else getPile("Hex pile").destruct()end
    if Use('Doom')or Use('Fool')then getPile('States').destruct()end
    if Use('Zombie')==0 then getPile("Zombie pile").destruct()end
    
    for i in ipairs(ref_replacementPiles) do
        local pos = getObjectFromGUID(ref_replacementPiles[i].guid).getPosition()
        if pos[1] > 16 or pos[1] < -16 then
            getObjectFromGUID(ref_replacementPiles[i].guid).destruct()
        elseif pos[3] > 23 or pos[3] < 13 then
            getObjectFromGUID(ref_replacementPiles[i].guid).destruct()
        end
    end
    local sideSlots = {}
    local f = function(a,p)if a then table.insert(sideSlots,p)else getPile(p..' pile').destruct()end end
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
    f(Use('Bat'),'Bat')
    f(Use('Wish'),'Wish')
    f(Use('Hyde'),'Hyde')
    
    for i,v in ipairs(sideSlots)do
      getPile(v.." pile").setPosition(ref_sideSlots[i].pos)
    end
    
    if true then
      for i = #sideSlots + 1, #ref_sideSlots do
        getObjectFromGUID(ref_sideSlots[i].guid).destruct()
      end
    end
    
    for i in ipairs(ref_eventSlots) do
        local obj = getObjectFromGUID(ref_eventSlots[i].guid)
        local zone = getObjectFromGUID(ref_eventSlots[i].zone)
        for j, obj2 in ipairs(zone.getObjects()) do
            if obj2.tag == "Card" then
                
                Use.Add(obj2.getName())
                
                if string.find(getCost(obj2.getName()), "D0") == nil and string.find(getCost(obj2.getName()), "DX") == nil then
                    useDebt = true
                elseif string.find(getType(obj2.getName()), "Project") ~= nil then
                    useProject = true
                end
                if eventCount == 3 then
                    obj2.setPosition({obj2.getPosition()[1] + 3.5, obj2.getPosition()[2], obj2.getPosition()[3]})
                elseif eventCount == 2 then
                    obj2.setPosition({obj2.getPosition()[1] + 7, obj2.getPosition()[2], obj2.getPosition()[3]})
                elseif eventCount == 1 then
                    obj2.setPosition({obj2.getPosition()[1] + 10.5, obj2.getPosition()[2], obj2.getPosition()[3]})
                end
            end
        end
        if i > eventCount then
            obj.destruct()
        elseif eventCount == 3 then
            obj.setPosition({obj.getPosition()[1] + 3.5, obj.getPosition()[2], obj.getPosition()[3]})
        elseif eventCount == 2 then
            obj.setPosition({obj.getPosition()[1] + 7, obj.getPosition()[2], obj.getPosition()[3]})
        elseif eventCount == 1 then
            obj.setPosition({obj.getPosition()[1] + 10.5, obj.getPosition()[2], obj.getPosition()[3]})
        end
    end
    if Use('Baker') then
        for i, obj in ipairs(getAllObjects()) do
            if obj.getName() == "Coffers" and obj.getDescription() == "" then
                obj.call("baker")
            end
        end
    end
    if Use('Trade Route') then
        getObjectFromGUID(ref_tradeRoute.guid).destruct()
        for i, obj in ipairs(getAllObjects()) do
            if obj.getName() == "Coin Tokens" and obj.getDescription() == "Trade Route" then
                obj.destruct()
            end
        end
    end
    if not Use('TavernMat') then
        for i in pairs(ref_tavernMats) do
            getObjectFromGUID(ref_tavernMats[i]).destruct()
        end
    end
    if not Use('Island') then
        for i in pairs(ref_islands) do
            getObjectFromGUID(ref_islands[i]).destruct()
        end
    elseif not Use('TavernMat') then
        for i in pairs(ref_islands) do
            local obj = getObjectFromGUID(ref_islands[i])
            local pos = obj.getPosition()
            obj.setPosition({pos[1], pos[2], pos[3] - 7})
        end
    end
    if not Use('PirateShip') then
        for i in pairs(ref_pirateShips) do
            getObjectFromGUID(ref_pirateShips[i]).destruct()
        end
    elseif not Use('TavernMat') then
        for i in pairs(ref_pirateShips) do
            local obj = getObjectFromGUID(ref_pirateShips[i])
            local pos = obj.getPosition()
            obj.setPosition({pos[1], pos[2], pos[3] - 7})
        end
    end
    for i, obj in ipairs(getAllObjects()) do
        if obj.getName() == "Coin Tokens" and obj.getDescription() == "Pirate Ship" then
            if Use('PirateShip') and not Use('TavernMat') then
                local pos = obj.getPosition()
                obj.setPosition({pos[1], pos[2], pos[3] - 7})
            elseif not usePirateShip then
                obj.destruct()
            end
        end
    end
    if not Use('NativeVillage') then
        for i in pairs(ref_nativeVillages) do
            getObjectFromGUID(ref_nativeVillages[i]).destruct()
        end
    elseif not Use('TavernMat') then
        for i in pairs(ref_nativeVillages) do
            local obj = getObjectFromGUID(ref_nativeVillages[i])
            local pos = obj.getPosition()
            obj.setPosition({pos[1], pos[2], pos[3] - 7})
        end
    end
    local temp = {Use('PlusCard'), Use('PlusAction'), Use('TwoCost'), Use('PlusBuy'),
        Use('PlusCoin'), Use('MinusCoin'), Use('MinusCard'), Use('Trashing'), Use('Estate'),
        Use('Journey'), Use('Coffers'), Use('VP'), Use('Debt'), Use('Villager'), Use('Project')}
    local names = {"+1 Card token", "+1 Action token", "-2 Cost token",
        "+1 Buy token", "+1 Coin token", "-1 Coin token", "-1 Card token",
        "Trashing token", "Estate token", "Journey token", "Coffers",
        "VP Tokens", "Debt Tokens", "Villagers", "Owns Project"}
    for i, v in ipairs(temp)do if not v then
            for j, obj in ipairs(getAllObjects()) do
                if obj.getName() == names[i] then
                    if obj.getName() == "Coin Tokens" and obj.getDescription() == "Pirate Ship" then
                    elseif obj.getName() == "Coin Tokens" and obj.getDescription() == "Trade Route" then
                    elseif obj.getName() == "VP Tokens" and obj.getDescription() == "Landmark" then
                    else obj.destruct() end
                end
            end
        end
    end
    local toRemove = {}
    if getPlayerCount() ~= 6 then
      for i in pairs (ref_players) do
        local found = false
        for j = 1, #getSeatedPlayers() do
            local currentPlayer = getSeatedPlayers()[j]
            if currentPlayer == i and Player[currentPlayer].getHandCount() > 0 then
                found = true
            end
        end
        if not found then
            table.insert(toRemove, i)
        end
      end
    end
    for i, v in pairs (toRemove) do
        for j, obj in ipairs(getObjectFromGUID(ref_players[v].zone).getObjects()) do
            obj.destruct()
        end
    end
    function tokenCoroutine()
        wait(4)
        if useTradeRoute or useTax or useAqueduct or useDefiledShrine or useObelisk or useLandmarkSetup or useGathering then
            local obeliskPiles = {}
            for i, v in ipairs(ref_basicSlotZones) do
                for j, obj in ipairs(getObjectFromGUID(v).getObjects()) do
                    if obj.tag == "Deck" then
                        local pos = obj.getPosition()
                        if obj.getName() == "Ruins Pile" then
                            table.insert(obeliskPiles, obj)
                            if useDefiledShrine then
                                vpBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), 2}})
                            end
                        end
                        if string.find(obj.getObjects()[#obj.getObjects()].description, "Victory") ~= nil and useTradeRoute then
                            coinBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}})
                        end
                        if useTax then
                            debtBag.takeObject({position = {pos[1] - 0.9, pos[2] + 1, pos[3] - 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), 1}})
                        end
                        if obj.getName() == "Gold pile" or obj.getName() == "Silver pile" then
                            if useAqueduct then
                                vpBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), 8}})
                            end
                        end
                        break
                    end
                end
            end
            for i, v in ipairs(ref_kingdomSlots) do
                for j, obj in ipairs(getObjectFromGUID(v.zone).getObjects()) do
                    if obj.tag == "Deck" then
                        local pos = obj.getPosition()
                        if string.find(obj.getObjects()[#obj.getObjects()].description, "Action") ~= nil then
                            table.insert(obeliskPiles, obj)
                        end
                        if string.find(obj.getObjects()[#obj.getObjects()].description, "Victory") ~= nil and useTradeRoute and obj.getObjects()[#obj.getObjects()].nickname ~= "Dame Josephine" then
                            coinBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}})
                        end
                        if string.find(obj.getObjects()[#obj.getObjects()].description, "Gathering") ~= nil then
                            tokenMake(obj,'vp')
                        end
                        break
                    end
                end
            end
            for i, obj in ipairs(getObjectFromGUID(ref_baneSlot.zone).getObjects()) do
                if obj.tag == "Deck" then
                    local pos = obj.getPosition()
                    if string.find(obj.getObjects()[#obj.getObjects()].description, "Action") ~= nil then
                        table.insert(obeliskPiles, obj)
                    end
                    if string.find(obj.getObjects()[#obj.getObjects()].description, "Victory") ~= nil and useTradeRoute and obj.getObjects()[#obj.getObjects()].nickname ~= "Dame Josephine" then
                        coinBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}})
                    end
                    if string.find(obj.getObjects()[#obj.getObjects()].description, "Gathering") ~= nil then
                        vpBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), 0}})
                    end
                    if string.find(obj.getObjects()[#obj.getObjects()].description, "Action") ~= nil and useDefiledShrine then
                        if string.find(obj.getObjects()[#obj.getObjects()].description, "Gathering") ~= nil then
                        else
                            vpBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), 2}})
                        end
                    end
                    if useTax then
                        debtBag.takeObject({position = {pos[1] - 0.9, pos[2] + 1, pos[3] - 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), 1}})
                    end
                    break
                end
            end
            for i, v in ipairs(ref_eventSlots) do
                for j, obj in ipairs(getObjectFromGUID(v.zone).getObjects()) do
                    if obj.tag == "Card" then
                        local pos = obj.getPosition()
                        if obj.getName() == "Aqueduct" or obj.getName() == "Defiled Shrine" then
                            vpBag.takeObject({position = {pos[1] + 1.25, pos[2] + 1, pos[3] - 0.9}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), 0}})
                        end
                        if obj.getName() == "Arena" or obj.getName() == "Basilica" or obj.getName() == "Baths" or obj.getName() == "Battlefield" or obj.getName() == "Colonnade" or obj.getName() == "Labyrinth" then
                            vpBag.takeObject({position = {pos[1] + 1.25, pos[2] + 1, pos[3] - 0.9}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {obj.getName(), getPlayerCount() * 6}})
                        end
                        if obj.getName() == "Obelisk" then
                            local k = math.random(1, #obeliskPiles)
                            obj.highlightOn({1,0,1})
                            obeliskPiles[k].highlightOn({1,0,1})
                            obeliskTarget = string.sub(obeliskPiles[k].getName(), 1, -6)
                        end
                        break
                    end
                end
            end
        end
        if Use('BlackMarket')then
            local gathering = 0
            pos = blackMarketDeck.getPosition()
            for i, card in ipairs(blackMarketDeck.getObjects()) do
                if string.find(card.description, "Gathering") ~= nil then
                    gathering = gathering + 1
                    if gathering == 1 then
                        vpBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] + 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {card.nickname, 0}})
                    elseif gathering == 2 then
                        vpBag.takeObject({position = {pos[1] + 0.9, pos[2] + 1, pos[3] - 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {card.nickname, 0}})
                    else
                        vpBag.takeObject({position = {pos[1] - 0.9, pos[2] + 1, pos[3] - 1.25}, rotation = {0,180,0}, callback = "tokenCallback", callback_owner = Global, params = {card.nickname, 0}})
                    end
                end
            end
        end
        wait(1)
        coinBag.destruct()
        vpBag.destruct()
        debtBag.destruct()
        return 1
    end
    startLuaCoroutine(Global, "tokenCoroutine")
    if useShelters ~= 1 and getPile("Shelters") ~= nil then
        getPile("Shelters").destruct()
        setupBaseCardCount(false, false)
    else
        setupBaseCardCount(true, false)
    end
end
function createHeirlooms(check)
    local h = getObjectFromGUID("eb483b")
    for _,n in pairs({"Magic_Lamp","Haunted_Mirror","Pasture","Pouch","Cursed_Gold","Goat","Lucky_Coin","Rabbit","Jinxed_Jewel"}) do
        if check == name then
            getPile("Heirlooms").takeObject({
                position = h.getPosition(),
                guid = ref_heirlooms[card],
                flip = true})
            break
        end
    end
    h = h.getObjects()
    if h then group(h) end
end
function createPile()
    for i in pairs(ref_kingdomSlots) do
        local zone = getObjectFromGUID(ref_kingdomSlots[i].zone).getObjects()
        for j, v in ipairs(zone) do
            if v.tag == "Card" then
                --First we check for 2 player Castles
                local k = 1
                if getPlayerCount() == 2 and v.getName() == "Castles" then
                    v.destruct()
                    getPile("Castles pile").setPosition(ref_kingdomSlots[i].pos)
                    for k = 1, 4 do
                        for l, card in ipairs(getPile("Castles pile").getObjects()) do
                            if k == 1 and card.nickname == "Humble Castle" then
                                getPile("Castles pile").takeObject({index=card.index}).destruct()
                                break
                            elseif k == 2 and card.nickname == "Small Castle" then
                                getPile("Castles pile").takeObject({index=card.index}).destruct()
                                break
                            elseif k == 3 and card.nickname == "Opulent Castle" then
                                getPile("Castles pile").takeObject({index=card.index}).destruct()
                                break
                            elseif k == 4 and card.nickname == "King's Castle" then
                                getPile("Castles pile").takeObject({index=card.index}).destruct()
                                break
                            end
                        end
                    end
                --Then we do 3+ player Castles
                elseif v.getName() == "Castles" then
                    v.destruct()
                    getPile("Castles pile").setPosition(ref_kingdomSlots[i].pos)
                --If we have a victory card and 2 players, we make 8 copies
                elseif getPlayerCount() == 2 and string.find(v.getDescription(), "Victory") ~= nil then
                    while k < 8 do
                        v.clone({position=ref_kingdomSlots[i].pos})
                        k = k + 1
                    end
                    --If we have a victory card or the card is Port, we make 12 copies
                elseif string.find(v.getDescription(), "Victory") ~= nil or v.getName() == "Port" then
                    while k < 12 do
                        v.clone({position=ref_kingdomSlots[i].pos})
                        k = k + 1
                    end
                --If we have Rats, we get 20 copies
                elseif v.getName() == "Rats" then
                    while k < 20 do
                        v.clone({position=ref_kingdomSlots[i].pos})
                        k = k + 1
                    end
                --If we have Knights, we swap in the Knights pile
                elseif v.getName() == "Knight" then
                    v.destruct()
                    getPile("Knights pile").setPosition(ref_kingdomSlots[i].pos)
                    getPile("Knights pile").shuffle()
                elseif v.getName() == "Catapult / Rocks" then
                    v.destruct()
                    getPile("Catapult / Rocks pile").setPosition(ref_kingdomSlots[i].pos)
                elseif v.getName() == "Encampment / Plunder" then
                    v.destruct()
                    getPile("Encampment / Plunder pile").setPosition(ref_kingdomSlots[i].pos)
                elseif v.getName() == "Gladiator / Fortune" then
                    v.destruct()
                    getPile("Gladiator / Fortune pile").setPosition(ref_kingdomSlots[i].pos)
                elseif v.getName() == "Patrician / Emporium" then
                    v.destruct()
                    getPile("Patrician / Emporium pile").setPosition(ref_kingdomSlots[i].pos)
                elseif v.getName() == "Settlers / Bustling Village" then
                    v.destruct()
                    getPile("Settlers / Bustling Village pile").setPosition(ref_kingdomSlots[i].pos)
                elseif v.getName() == "Sauna / Avanto" then
                    v.destruct()
                    getPile("Sauna / Avanto pile").setPosition(ref_kingdomSlots[i].pos)
                --All other cards get 10 copies
                else
                    while k < 10 do
                        v.clone({position=ref_kingdomSlots[i].pos})
                        k = k + 1
                    end
                end
            end
        end
    end
    local removeBane = true
    for i, v in pairs(getObjectFromGUID(ref_baneSlot.zone).getObjects()) do
        if v.tag == "Card" and v.getName() ~= "Bane pile" then
            removeBane = false
            local k = 1
            if getPlayerCount() == 2 and v.getName() == "Castles" then
                v.destruct()
                getPile("Castles pile").setPosition(ref_baneSlot.pos)
                for k = 1, 4 do
                    for l, card in ipairs(castlesPile.getObjects()) do
                        if k == 1 and card.nickname == "Humble Castle" then
                            getPile("Castles pile").takeObject({index=card.index}).destruct()
                            break
                        elseif k == 2 and card.nickname == "Small Castle" then
                            getPile("Castles pile").takeObject({index=card.index}).destruct()
                            break
                        elseif k == 3 and card.nickname == "Opulent Castle" then
                            getPile("Castles pile").takeObject({index=card.index}).destruct()
                            break
                        elseif k == 4 and card.nickname == "King's Castle" then
                            getPile("Castles pile").takeObject({index=card.index}).destruct()
                            break
                        end
                    end
                end
            --Then we do 3+ player Castles
            elseif v.getName() == "Castles" then
                v.destruct()
                getPile("Castles pile").setPosition(ref_baneSlot.pos)
            --If we have a victory card and 2 players, we make 8 copies
            elseif getPlayerCount() == 2 and string.find(v.getDescription(), "Victory") ~= nil then
                while k < 8 do
                    v.clone({position=ref_baneSlot.pos})
                    k = k + 1
                end
                --If we have a victory card, we make 12 copies
            elseif string.find(v.getDescription(), "Victory") ~= nil then
                while k < 12 do
                    v.clone({position=ref_baneSlot.pos})
                    k = k + 1
                end
            --If we have Knights, we swap in the Knights pile
            elseif v.getName() == "Catapult / Rocks" then
                v.destruct()
                getPile("Catapult / Rocks pile").setPosition(ref_baneSlot.pos)
            elseif v.getName() == "Encampment / Plunder" then
                v.destruct()
                getPile("Encampment / Plunder pile").setPosition(ref_baneSlot.pos)
            elseif v.getName() == "Gladiator / Fortune" then
                v.destruct()
                getPile("Gladiator / Fortune pile").setPosition(ref_baneSlot.pos)
            elseif v.getName() == "Patrician / Emporium" then
                v.destruct()
                getPile("Patrician / Emporium pile").setPosition(ref_baneSlot.pos)
            elseif v.getName() == "Settlers / Bustling Village" then
                v.destruct()
                getPile("Settlers / Bustling Village pile").setPosition(ref_baneSlot.pos)
            --All other cards get 10 copies
            else
                while k < 10 do
                    v.clone({position=ref_baneSlot.pos})
                    k = k + 1
                end
            end
        end
    end
    --Coroutine names the piles after they form
    function createPileCoroutine()
        wait(1)
        if getPile("Heirlooms")then getPile("Heirlooms").destruct()end
        for i in pairs(ref_kingdomSlots) do
            local zone = getObjectFromGUID(ref_kingdomSlots[i].zone).getObjects()
            for j, v in ipairs(zone) do
                if v.tag == "Deck" then
                    if string.sub(v.getName(), -5) ~= " pile" then
                        v.setName(v.takeObject({position=v.getPosition()}).getName() .. " pile")
                    end
                end
            end
        end
        if not removeBane then
            for i, v in pairs(getObjectFromGUID(ref_baneSlot.zone).getObjects()) do
                if v.tag == "Deck" then
                    if string.sub(v.getName(), -5) ~= " pile" then
                        v.setName(v.takeObject({position=v.getPosition()}).getName() .. " pile")
                    end
                end
            end
        end
        cleanUp()
        return 1
    end
    startLuaCoroutine(Global, "createPileCoroutine")
end
--[[Function to get the cost of a card from the reference list
function getDepend(cardname)
  for i, v in pairs(ref_master) do
    if cardName == v.name then
      if v.depend then
        return v.depend
      end
      return ''
    end
  end
end]]
function getVP(cardName)
    for i, v in pairs(ref_master) do
        if cardName == v.name then
            if v.VP then
                return v.VP
            end return 0
end end end
function getCost(cardName)
    for i, v in pairs(ref_master) do
        if cardName == v.name then
            log(v.cost,v.name)return v.cost
end end end
function getType(cardName)
    for i, v in pairs(ref_master) do
        if cardName == v.name then
            return v.type
end end end
function getPile(pileName)
    for i in ipairs(ref_replacementPiles) do
        if pileName == ref_replacementPiles[i].name then
            return getObjectFromGUID(ref_replacementPiles[i].guid)
        end
    end
    for i in ipairs(ref_basicSupplyPiles) do
        if pileName == ref_basicSupplyPiles[i].name then
            return getObjectFromGUID(ref_basicSupplyPiles[i].guid)
        end
    end
    for i in ipairs(ref_extraSupplyPiles) do
        if pileName == ref_extraSupplyPiles[i].name then
            return getObjectFromGUID(ref_extraSupplyPiles[i].guid)
        end
    end
    for i in ipairs(ref_sidePiles) do
        if pileName == ref_sidePiles[i].name then
            return getObjectFromGUID(ref_sidePiles[i].guid)
        end
    end
end
-- Function to set the correct count of base cards
function setupBaseCardCount(useShelters, useHeirlooms)
    local useBigBox = false
    local pCount = getPlayerCount()
    --Starting Estates
    if useShelters and getPile("Shelters") ~= nil then
        removeFromPile(getPile("Estate pile"), 18)
    else
        removeFromPile(getPile("Estate pile"), 18 - (pCount * 3))
    end
    --Starting Curses
    removeFromPile(getPile("Curse pile"), 50 - ((pCount - 1) * 10))
    if getPile("Ruins pile") ~= nil then
        getPile("Ruins pile").shuffle()
        removeFromPile(getPile("Ruins pile"), 50 - ((pCount - 1) * 10))
    end
    --Starting Treasures
    if useBigBox and pCount > 4 then
        removeFromPile(getPile("Copper pile"), 40)
        removeFromPile(getPile("Silver pile"), 10)
        removeFromPile(getPile("Gold pile"), 12)
    elseif pCount < 5 then
        removeFromPile(getPile("Copper pile"), 60)
        removeFromPile(getPile("Silver pile"), 40)
        removeFromPile(getPile("Gold pile"), 30)
    end
    -- Remove Coppers when using Heirlooms
    if useHeirlooms then
        removeFromPile(getPile("Copper pile"), (pCount * 7))
    end
    --Starting Provinces
    if pCount == 5 then
        removeFromPile(getPile("Province pile"), 3)
    elseif pCount < 5 then
        removeFromPile(getPile("Province pile"), 6)
    end
    --2 Player Victory Card Setup
    if pCount == 2 then
        removeFromPile(getPile("Estate pile"), 4)
        removeFromPile(getPile("Duchy pile"), 4)
        removeFromPile(getPile("Province pile"), 4)
        if usePlatinum == 1 then
            removeFromPile(getPile("Colony pile"), 4)
        end
    end
    setupStartingDecks(useShelters, useHeirlooms)
end
-- Function to setup starting Decks
function setupStartingDecks(useShelters, useHeirlooms)
    --make a pile with used Heirlooms to copy
    local c, heirlooms = 0, getObjectFromGUID("eb483b").getObjects()
    if heirlooms and heirlooms[1] then
        heirlooms = heirlooms[1]
        if heirlooms.tag == "Deck" then
            c = #(heirlooms.getObjects())
            
        elseif heirlooms.tag == "Card" then
            c = 1
        else
            heirlooms = false
        end
    else
        heirlooms = false
    end
    
    --
    for i = 1, #getSeatedPlayers() do
        local coppers, currentPlayer = c, getSeatedPlayers()[i]
        if Player[currentPlayer].getHandCount() > 0 then
            if heirlooms then
                heirlooms.clone({position = ref_players[currentPlayer].deck})
            end
            
            while coppers < 7 do
                getPile("Copper pile").takeObject({position = ref_players[currentPlayer].deck, flip = true})
                coppers = coppers + 1
            end
            
            if useShelters and getPile("Shelters") ~= nil then
                getPile("Shelters").clone({position = ref_players[currentPlayer].deck, rotation = {0,180,180}})
            else
                local j = 0
                while j < 3 do
                    getPile("Estate pile").takeObject({position = ref_players[currentPlayer].deck, flip = true})
                    j = j + 1
                end
            end
        end
    end
    if useShelters and getPile("Shelters") ~= nil then
        getPile("Shelters").destruct()
    end
    dealStartingHands()
end
-- Function to deal starting hands
function dealStartingHands()
    function dealStartingHandsCoroutine()
        wait(2)
        for i, v in pairs (ref_players) do
            for j, b in pairs (getObjectFromGUID(v.deckZone).getObjects()) do
                if b.tag == "Deck" then
                    b.shuffle()
                end
            end
        end
        wait(0.5)
        for i, v in pairs (ref_players) do
            for j, b in pairs (getObjectFromGUID(v.deckZone).getObjects()) do
                if b.tag == "Deck" then
                    b.deal(5, i)
                end
            end
        end
        createEndButton()
        gameState = 3
        setNotes("[40e0d0][b][u]Dominion: Definitive Edition[/b][/u][ffffff]\n\nMake sure all cards are in each player's hand, deck, discard, Tavern mat, Island mat, or Native Village mat before pressing End Game. Any card outside of these areas will not be counted.")
        if math.random(0,1) then Turns.reverse_order = true end
        local t = getSeatedPlayers()
        local p = math.random(1,#t)
        Turns.turn_color = t[p]
        Turns.enable = true
        return 1
    end
    startLuaCoroutine(Global, "dealStartingHandsCoroutine")
end
function removeFromPile(pile, count)
    local total = pile.getQuantity() - count
    while pile.getQuantity() > total do
        pile.takeObject({}).destruct()
    end
end
-- Function to get a count of players sitting at the table with hands to be dealt to.
function getPlayerCount()
    local pCount = #getSeatedPlayers()
    for i = 1, #getSeatedPlayers() do
        if Player[getSeatedPlayers()[i]].getHandCount() < 1 then
            p = p - 1
        end
    end
    if pCount == 1 then pCount = 6 end
    return(pCount)
end
-- Function to wait during coroutines
function wait(time)
    local start = os.time()
    repeat coroutine.yield(0) until os.time() > start + time
end
--Shortcut broadcast function to shorten them when I call them in the code
function bcast(msg, tcolor, pcolor)
    if tcolor == nil then tcolor = {1,1,1} end
    if pcolor == nil then
        broadcastToAll(msg, tcolor)
    else
        Player[pcolor].broadcast(msg, tcolor)
    end
end
ref_tokenBag={coin="491d9b",debt="7624c9",vp="b935ba"}

function tokenCallback(obj, stuff)obj.call("setOwner", {stuff[1], stuff[2]})end
function tokenMake(obj,key,n)
    local p=obj.getPosition()
    local t={position={p[1]-0.9,p[2]+1,p[3]-1.25},rotation={0,180,0}}
    if n then
        t.callback="tokenCallback"
        t.callback_owner=Global
        t.params={obj.getName(),n}
    end getObjectFromGUID(ref_tokenBag[key]).takeObject(t)
end
-- Function to set uninteractible objects
function setUninteractible()
    local objectTable = {"377aaf", "563a61", "56dcad", "d516bd", "4b9597",
        "497478", "e700bc", "7cbaf0", "5acda1", "28c05c", "00d4cc", "f7a574",
        "b6ce05", "755720", "5e6695", "fb0663", "ea57b1", "08e74d", "3efdc8",
        "4e4e40", "4084c6", "901432", "5eb491", "1f42f9", "3d5008", "a6f52e",
        "7fb923", "4733fe", "bf7652", "6be6f9", "4ab1b9", "48b491", "03a180",
        "25f0bd", "2fad31", "e6fed4", "a96aef", "adb237", "e091ca", "bb3643",
        "1ff6fe", "6ca433", "06d4ed", "44425f", "0d6548", "954ec6", "017610",
        "36f9e6", "787ec5", "79374a", "4a393b", "3e9fe7", "333af8", "33ccc0",
        "e2dc84", "4402ed", "e3288c", "48d5fd", "753691", "3cf4d4", "a3859c",
        "a25f0c", "44a19a", "e1102c", "29d7df", "4e986c", "7e1e42", "596d36",
        "9eb71f", "af0d7b", "335c05", "8c7c5c", "40ad8f", "183cc0", "012eda",
        "7c01f4", "daf4ab", "eff725", "7ba0bf", "de9a73", "61ae8d", "8cf7ae",
        "d8a850", "3ba1c2", "bb0b4f", "25756f", "1e113a", "811c7b", "f0bd83",
        "fa020b", "eaf95e", "7535f5", "d5f986", "2ea60a", "bf9dda", "36fb6e"}
    for i = 1, #objectTable, 1 do
        obj = getObjectFromGUID(objectTable[i])
        if obj ~= nil then
            obj.interactable = false
        end
    end
end

ref_sideSlots = {
--Top Row
{pos = {-14.5, 1.3, 23.15}, guid = "7ba0bf"},
{pos = {-17.9, 1.3, 23.15}, guid = "de9a73"},
{pos = {-21.3, 1.3, 23.15}, guid = "61ae8d"},
{pos = {-24.7, 1.3, 23.15}, guid = "f7a574"},
--Middle Row
{pos = {-14.5, 1.3, 18.3}, guid = "bb0b4f"},
{pos = {-17.9, 1.3, 18.3}, guid = "25756f"},
{pos = {-21.3, 1.3, 18.3}, guid = "1e113a"},
{pos = {-24.7, 1.3, 18.3}, guid = "2ea60a"},
--Bottom Row
{pos = {-14.5, 1.3, 13.45}, guid = "8cf7ae"},
{pos = {-17.9, 1.3, 13.45}, guid = "d8a850"},
{pos = {-21.3, 1.3, 13.45}, guid = "3ba1c2"},
{pos = {-24.7, 1.3, 13.45}, guid = "d5f986"},
--Spirits
{pos = {-28.1, 1.3, 13.45}, guid = "f0bd83"},
{pos = {-28.1, 1.3, 18.3}, guid = "811c7b"},
{pos = {-28.1, 1.3, 23.15}, guid = "fa020b"},
--Bat Wishes
{pos = {-31.5, 1.3, 13.45}, guid = "a96aef"},
{pos = {-31.5, 1.3, 18.3}, guid = "5bd468"},
{pos = {-31.5, 1.3, 23.15}, guid = "e6fed4"},
--Empty
{pos = {-34.9, 1.3, 13.45}, guid = "5e6695"},
{pos = {-34.9, 1.3, 18.3}, guid = "fb0663"},
{pos = {-34.9, 1.3, 23.15}, guid = "755720"},
{pos = {-38.3, 1.3, 13.45}, guid = "bf7652"},
{pos = {-38.3, 1.3, 18.3}, guid = "b6ce05"},
{pos = {-38.3, 1.3, 23.15}, guid = "4733fe"},
{pos = {-41.7, 1.3, 13.45}, guid = "a6f52e"},
{pos = {-41.7, 1.3, 18.3}, guid = "7fb923"},
{pos = {-41.7, 1.3, 23.15}, guid = "bf9dda"},
{pos = {-45.1, 1.3, 13.45}, guid = "eaf95e"},
{pos = {-45.1, 1.3, 18.3}, guid = "7535f5"},
{pos = {-45.1, 1.3, 23.15}, guid = "adb237"}
}

ref_basicSlots = {
    {pos = {}, guid = "377aaf"},
    {pos = {-20, 1.3, 31.5}, guid = "563a61"},
    {pos = {-15, 1.3, 31.5}, guid = ""},
    {pos = {-10, 1.3, 31.5}, guid = ""},
    {pos = {-5, 1.3, 31.5}, guid = ""},
    {pos = {20, 1.3, 31.5}, guid = "28c05c"},
    {pos = {}, guid = "00d4cc"}
}

ref_eventSlots = {
    {pos = {-10.5, 1.25, 8.5}, zone = "f5e84d", guid = "e091ca"},
    {pos = {-3.5, 1.25, 8.5}, zone = "2ffd78", guid = "bb3643"},
    {pos = {3.5, 1.25, 8.5}, zone = "65aaf5", guid = "1ff6fe"},
    {pos = {10.5, 1.25, 8.5}, zone = "0c28db", guid = "6ca433"}
}

ref_heirlooms = {}

ref_basicSupplyPiles = {
    {name = "Copper pile", guid = "7660c1"},
    {name = "Silver pile", guid = "75009c"},
    {name = "Gold pile", guid = "029fa0"},
    {name = "Curse pile", guid = "8dc371"},
    {name = "Estate pile", guid = "f5b295"},
    {name = "Duchy pile", guid = "8b4c2a"},
    {name = "Province pile", guid = "b5ddd4"}
}

ref_extraSupplyPiles = {
    {name = "Platinum pile", guid = "984267"},
    {name = "Potion pile", guid = "a9a549"},
    {name = "Colony pile", guid = "d476e3"},
    {name = "Ruins pile", guid = "c62cfd"},
    {name = "Shelters", guid = "0815b9"},
    {name = "Heirlooms", guid = "4751d9"},
    {name = "Zombie pile", guid = "05733c"}
}

ref_sidePiles = {
    {name = "Hyde pile", guid = "59e1ca"},
    {name = "Artifacts", guid = "99658a"},
    {name = "States", guid = "34b255"},
    {name = "Boon pile", guid = "8c5446"},
    {name = "Hex pile", guid = "53dacd"},
    {name = "Wish pile", guid = "5e18d3"},
    {name = "Bat pile", guid = "d72486"},
    {name = "Will-o'-Wisp pile", guid = "2a05d7"},
    {name = "Imp pile", guid = "dff6fe"},
    {name = "Ghost pile", guid = "f5e244"},
    {name = "Prize pile", guid = "4e3544"},
    {name = "Madman pile", guid = "a93696"},
    {name = "Mercenary pile", guid = "aff324"},
    {name = "Spoils pile", guid = "eb4bd2"},
    {name = "Treasure Hunter pile", guid = "60b66d"},
    {name = "Warrior pile", guid = "5c1752"},
    {name = "Hero pile", guid = "0fd8c1"},
    {name = "Champion pile", guid = "dcb599"},
    {name = "Soldier pile", guid = "e3895e"},
    {name = "Fugitive pile", guid = "94e71b"},
    {name = "Disciple pile", guid = "dd6bc5"},
    {name = "Teacher pile", guid = "317b6e"},
}
ref_replacementPiles = {
    {name = "Knights pile", guid = "704e4f"},
    {name = "Sauna / Avanto pile", guid = "2ee7f2"},
    {name = "Castles pile", guid = "847cdb"},
    {name = "Catapult / Rocks pile", guid = "3486d4"},
    {name = "Encampment / Plunder pile", guid = "d4bf44"},
    {name = "Gladiator / Fortune pile", guid = "fad46e"},
    {name = "Patrician / Emporium pile", guid = "849ae3"},
    {name = "Settlers / Bustling Village pile", guid = "d53aae"}
}
ref_basicSlotZones = {"198948", "a5940e", "86fa0b", "810603", "0bd7f8",
    "2a639d", "67f21e", "b33712", "d484d7", "7f9e58", "378afe"}

ref_kingdomSlots = {
    {pos = {-10, 1.3, 22}, zone = "987e4a"},
    {pos = {-5, 1.3, 22}, zone = "816553"},
    {pos = {0, 1.3, 22}, zone = "7b20e5"},
    {pos = {5, 1.3, 22}, zone = "740c12"},
    {pos = {10, 1.3, 22}, zone = "fefd47"},
    {pos = {-10, 1.3, 14.5}, zone = "47d4f1"},
    {pos = {-5, 1.3, 14.5}, zone = "4a3f91"},
    {pos = {0, 1.3, 14.5}, zone = "9d12c3"},
    {pos = {5, 1.3, 14.5}, zone = "9e931d"},
    {pos = {10, 1.3, 14.5}, zone = "00770c"}
}
ref_baneSlot = {pos = {15, 1.3, 22}, zone = "5b9b18"}
ref_randomizer = {pos = {25, 1.3, 22}, zone ="fd0b1d"}
ref_startButton = "48b491"
ref_tradeRoute = {pos = {20, 1.14, 22}, guid = "1f42f9"}
ref_tavernMats = {Red = "e1102c", White = "44a19a", Orange = "29d7df", Green = "a25f0c", Yellow = "4e986c", Blue = "a3859c"}
ref_islands = {Red = "3e9fe7", White = "787ec5", Orange = "e2dc84", Green = "954ec6", Yellow = "48d5fd", Blue = "06d4ed"}
ref_pirateShips = {Red = "333af8", White = "79374a", Orange = "4402ed", Green = "017610", Yellow = "753691", Blue = "44425f"}
ref_nativeVillages = {Red = "33ccc0", White = "4a393b", Orange = "e3288c", Green = "36f9e6", Yellow = "3cf4d4", Blue = "0d6548"}

ref_players = {
    Red = {deck = {12, 1.3, -27}, discard = {7, 1.27, -27},
        deckZone = "8fc66b", discardZone = "58de65", zone = "ae55f2",
        coins = "ab5a25", vp = "566e76", debt = "190d40", island = "2ff1c9",
        tavern = "c8b2d7"},
    White = {deck = {-7, 1.3, -27}, discard = {-12, 1.27, -27},
        deckZone = "16fcb6", discardZone = "24e48a", zone = "b6f79d",
        coins = "b6bf41", vp = "924430", debt = "3d4844", island = "4d79d4",
        tavern = "d24813"},
    Orange = {deck = {31, 1.3, -27}, discard = {26, 1.27, -27},
        deckZone = "0c0478", discardZone = "1436d5", zone = "632a5e",
        coins = "4afc72", vp = "aafd0e", debt = "fe6400", island = "a8d77e",
        tavern = "2b4ca6"},
    Green = {deck = {-25.5, 1.3, -27}, discard = {-30.5, 1.27, -27},
        deckZone = "027aa8", discardZone = "073577", zone = "55c136",
        coins = "b91008", vp = "7cb6ee", debt = "357de0", island = "940fae",
        tavern = "b10a77"},
    Yellow = {deck = {50, 1.3, -27}, discard = {45, 1.27, -27},
        deckZone = "88dbf1", discardZone = "1d150a", zone = "4237c3",
        coins = "357898", vp = "c1c72a", debt = "11b3ae", island = "9d8478",
        tavern = "31f8ec"},
    Blue = {deck = {-44.5, 1.3, -27}, discard = {-49.5, 1.27, -27},
        deckZone = "f5c470", discardZone = "0b6997", zone = "93ac6d",
        coins = "250bfc", vp = "4caeb9", debt = "f83dc4", island = "f1c054",
        tavern = "d4e057"}
}
--All card sets/expansions
ref_cardSets = {
    {name = "Dominion", guid = "982436"},
    {name = "Intrigue", guid = "48bfb2"},
    {name = "Seaside", guid = "de6f34"},
    {name = "Alchemy", guid = "eacf53"},
    {name = "Prosperity", guid = "38b54d"},
    {name = "Cornucopia", guid = "bc2d26"},
    {name = "Hinterlands", guid = "fc48a8"},
    {name = "Dark Ages", guid = "780f15"},
    {name = "Guilds", guid = "df7239"},
    {name = "Adventures", guid = "1ae0ae"},
    {name = "Empires", guid = "1f81ef"},
    {name = "Nocturne", guid = "53ccb6"},
    {name = "Renaissance", guid = "042073"},--13
    {name = "Promos", guid = "c3d329"},--14
    {name = "Adamabrams", guid = "c0f629"},--15
    {name = "Dominion 1st Edition", guid = "60d7e0"},
    {name = "Intrigue 1st Edition", guid = "ac30ce"},
    {name = "Original Printing", guid = "a4a262"},
}
--All Events and Landmarks
ref_eventSets = {
    {name = "Adventures Events", guid = "746b6f"},
    {name = "Empires Events", guid = "012ab1"},
    {name = "Empires Landmarks", guid = "00805a"},
    {name = "Renaissance Projects", guid = "b79f00"},
    {name = "Promo Events", guid = "8e196f"},
    {name = "Adamabrams Extras", guid = "f28e0f"},
}
--Name of all cards along with costs, used for sorting
ref_master = {
    {cost="M0D0P0",name="Copper",type="Treasure"},
    {cost="M3D0P0",name="Silver",type="Treasure"},
    {cost="M6D0P0",name="Gold",type="Treasure"},
    {cost="M9D0P0",name="Platinum",type="Treasure"},
    {cost="M4D0P0",name="Potion",type="Treasure"},
    {cost="M0D0P0",name="Curse",type="Curse",VP=-1},
    {cost="M2D0P0",name="Estate",type="Victory",VP=1},
    {cost="M5D0P0",name="Duchy",type="Victory",VP=3},
    {cost="M8D0P0",name="Province",type="Victory",VP=6},
    {cost="MBD0P0",name="Colony",type="Victory",VP=10},
    {cost="M6D0P0",name="Artisan",type="Action"},
    {cost="M5D0P0",name="Bandit",type="Action - Attack"},
    {cost="M4D0P0",name="Bureaucrat",type="Action - Attack"},
    {cost="M2D0P0",name="Cellar",type="Action"},
    {cost="M2D0P0",name="Chapel",type="Action"},
    {cost="M5D0P0",name="Council Room",type="Action"},
    {cost="M5D0P0",name="Festival",type="Action"},
    {cost="M4D0P0",name="Gardens",type="Action",VP=function(t)return math.floor(t.amount/10)end},
    {cost="M3D0P0",name="Harbinger",type="Action"},
    {cost="M5D0P0",name="Laboratory",type="Action"},
    {cost="M5D0P0",name="Library",type="Action"},
    {cost="M5D0P0",name="Market",type="Action"},
    {cost="M3D0P0",name="Merchant",type="Action"},
    {cost="M4D0P0",name="Militia",type="Action - Attack"},
    {cost="M5D0P0",name="Mine",type="Action"},
    {cost="M2D0P0",name="Moat",type="Action - Reaction"},
    {cost="M4D0P0",name="Moneylender",type="Action"},
    {cost="M4D0P0",name="Poacher",type="Action"},
    {cost="M4D0P0",name="Remodel",type="Action"},
    {cost="M5D0P0",name="Sentry",type="Action"},
    {cost="M4D0P0",name="Smithy",type="Action"},
    {cost="M4D0P0",name="Throne Room",type="Action"},
    {cost="M3D0P0",name="Vassal",type="Action"},
    {cost="M3D0P0",name="Village",type="Action"},
    {cost="M5D0P0",name="Witch",type="Action - Attack"},
    {cost="M3D0P0",name="Workshop",type="Action"},
    {cost="M4D0P0",name="Baron",type="Action"},
    {cost="M4D0P0",name="Bridge",type="Action"},
    {cost="M4D0P0",name="Conspirator",type="Action"},
    {cost="M5D0P0",name="Courtier",type="Action"},
    {cost="M2D0P0",name="Courtyard",type="Action"},
    {cost="M4D0P0",name="Diplomat",type="Action - Reaction"},
    {cost="M5D0P0",name="Duke",type="Victory",VP=function(t)return t.deck["Duchy"] end},
    {cost="M6D0P0",name="Harem",type="Treasure - Victory",VP=2},
    {cost="M4D0P0",name="Ironworks",type="Action"},
    {cost="M2D0P0",name="Lurker",type="Action"},
    {cost="M3D0P0",name="Masquerade",type="Action"},
    {cost="M4D0P0",name="Mill",type="Action - Victory",VP=1},
    {cost="M4D0P0",name="Mining Village",type="Action"},
    {cost="M5D0P0",name="Minion",type="Action - Attack"},
    {cost="M6D0P0",name="Nobles",type="Action - Victory",VP=2},
    {cost="M5D0P0",name="Patrol",type="Action"},
    {cost="M2D0P0",name="Pawn",type="Action"},
    {cost="M5D0P0",name="Replace",type="Action - Attack"},
    {cost="M3D0P0",name="Steward",type="Action"},
    {cost="M3D0P0",name="Swindler",type="Action - Attack"},
    {cost="M3D0P0",name="Shanty Town",type="Action"},
    {cost="M4D0P0",name="Secret Passage",type="Action"},
    {cost="M5D0P0",name="Trading Post",type="Action"},
    {cost="M5D0P0",name="Torturer",type="Action - Attack"},
    {cost="M5D0P0",name="Upgrade",type="Action"},
    {cost="M3D0P0",name="Wishing Well",type="Action"},
    {cost="M3D0P0",name="Ambassador",type="Action - Attack"},
    {cost="M5D0P0",name="Bazaar",type="Action"},
    {cost="M4D0P0",name="Caravan",type="Action - Duration"},
    {cost="M4D0P0",name="Cutpurse",type="Action - Attack"},
    {cost="M2D0P0",name="Embargo",type="Action"},
    {cost="M5D0P0",name="Explorer",type="Action"},
    {cost="M3D0P0",name="Fishing Village",type="Action - Duration"},
    {cost="M5D0P0",name="Ghost Ship",type="Action - Attack"},
    {cost="M2D0P0",name="Haven",type="Action - Duration"},
    {cost="M4D0P0",name="Island",type="Action - Victory",depend='Island',VP=2},
    {cost="M2D0P0",name="Lighthouse",type="Action - Duration"},
    {cost="M3D0P0",name="Lookout",type="Action"},
    {cost="M5D0P0",name="Merchant Ship",type="Action - Duration"},
    {cost="M2D0P0",name="Native Village",type="Action",depend='NativeVillage'},
    {cost="M4D0P0",name="Navigator",type="Action"},
    {cost="M5D0P0",name="Outpost",type="Action - Duration"},
    {cost="M2D0P0",name="Pearl Diver",type="Action"},
    {cost="M4D0P0",name="Pirate Ship",type="Action - Attack",depend='Pirate Ship'},
    {cost="M4D0P0",name="Salvager",type="Action"},
    {cost="M4D0P0",name="Sea Hag",type="Action - Attack"},
    {cost="M3D0P0",name="Smugglers",type="Action"},
    {cost="M5D0P0",name="Tactician",type="Action - Duration"},
    {cost="M4D0P0",name="Treasure Map",type="Action"},
    {cost="M5D0P0",name="Treasury",type="Action"},
    {cost="M3D0P0",name="Warehouse",type="Action"},
    {cost="M5D0P0",name="Wharf",type="Action - Duration"},
    {cost="M3D0P1",name="Alchemist",type="Action"},
    {cost="M2D0P1",name="Apothecary",type="Action"},
    {cost="M5D0P0",name="Apprentice",type="Action"},
    {cost="M3D0P1",name="Familiar",type="Action - Attack"},
    {cost="M4D0P1",name="Golem",type="Action"},
    {cost="M2D0P0",name="Herbalist",type="Action"},
    {cost="M3D0P1",name="Philosopher's Stone",type="Treasure"},
    {cost="M6D0P1",name="Possession",type="Action"},
    {cost="M2D0P1",name="Scrying Pool",type="Action - Attack"},
    {cost="M0D0P1",name="Transmute",type="Action"},
    {cost="M2D0P1",name="University",type="Action"},
    {cost="M0D0P1",name="Vineyard",type="Victory",VP=function(t)return math.floor(t.actions/3) end},
    {cost="M7D0P0",name="Bank",type="Treasure"},--Prosperity
    {cost="M4D0P0",name="Bishop",type="Action",depend='VP'},
    {cost="M5D0P0",name="City",type="Action"},
    {cost="M5D0P0",name="Contraband",type="Treasure"},
    {cost="M5D0P0",name="Counting House",type="Action"},
    {cost="M7D0P0",name="Expand",type="Action"},
    {cost="M7D0P0",name="Forge",type="Action"},
    {cost="M6D0P0",name="Goons",type="Action - Attack",depend='VP'},
    {cost="M6D0P0",name="Grand Market",type="Action"},
    {cost="M6D0P0",name="Hoard",type="Treasure"},
    {cost="M7D0P0",name="King's Court",type="Action"},
    {cost="M3D0P0",name="Loan",type="Treasure"},
    {cost="M5D0P0",name="Mint",type="Action"},
    {cost="M4D0P0",name="Monument",type="Action",depend='VP'},
    {cost="M5D0P0",name="Mountebank",type="Action - Attack"},
    {cost="M8D0P0",name="Peddler",type="Action"},
    {cost="M4D0P0",name="Quarry",type="Treasure"},
    {cost="M5D0P0",name="Rabble",type="Action - Attack"},
    {cost="M5D0P0",name="Royal Seal",type="Treasure"},
    {cost="M4D0P0",name="Talisman",type="Treasure"},
    {cost="M3D0P0",name="Trade Route",type="Action",setup=function(o)if o.getObjects()[1].description:find('Victory')then tokenMake(o,'coin')end end},
    {cost="M5D0P0",name="Vault",type="Action"},
    {cost="M5D0P0",name="Venture",type="Treasure"},
    {cost="M3D0P0",name="Watchtower",type="Action - Reactopm"},
    {cost="M4D0P0",name="Worker's Village",type="Action"},
    {cost="M6D0P0",name="Fairgrounds",type="Victory",VP=function(t)return math.floor(t.unique/5) end},--Cornucopia
    {cost="M4D0P0",name="Farming Village",type="Action"},
    {cost="M3D0P0",name="Fortune Teller",type="Action - Attack"},
    {cost="M2D0P0",name="Hamlet",type="Action"},
    {cost="M5D0P0",name="Harvest",type="Action"},
    {cost="M5D0P0",name="Horn of Plenty",type="Treasure"},
    {cost="M4D0P0",name="Horse Traders",type="Action - Reaction"},
    {cost="M5D0P0",name="Hunting Party",type="Action"},
    {cost="M5D0P0",name="Jester",type="Action - Attack"},
    {cost="M3D0P0",name="Menagerie",type="Action"},
    {cost="M4D0P0",name="Remake",type="Action"},
    {cost="M4D0P0",name="Tournament",type="Action",depend='Prize'},
    {cost="M4D0P0",name="Young Witch",type="Action - Attack"},
    {cost="M0D0P0",name="Bag of Gold",type="Action - Prize"},
    {cost="M0D0P0",name="Diadem",type="Treasure - Prize"},
    {cost="M0D0P0",name="Followers",type="Action - Attack - Prize"},
    {cost="M0D0P0",name="Princess",type="Action - Prize"},
    {cost="M0D0P0",name="Trusty Steed",type="Action - Prize"},
    {cost="M6D0P0",name="Border Village",type="Action"},
    {cost="M5D0P0",name="Cache",type="Treasure"},
    {cost="M5D0P0",name="Cartographer",type="Action"},
    {cost="M2D0P0",name="Crossroads",type="Action"},
    {cost="M3D0P0",name="Develop",type="Action"},
    {cost="M2D0P0",name="Duchess",type="Action"},
    {cost="M5D0P0",name="Embassy",type="Action"},
    {cost="M6D0P0",name="Farmland",type="Victory",VP=2},
    {cost="M2D0P0",name="Fool's Gold",type="Treasure - Reaction"},
    {cost="M5D0P0",name="Haggler",type="Action"},
    {cost="M5D0P0",name="Highway",type="Action"},
    {cost="M5D0P0",name="Ill-Gotten Gains",type="Treasure"},
    {cost="M5D0P0",name="Inn",type="Action"},
    {cost="M4D0P0",name="Jack of All Trades",type="Action"},
    {cost="M5D0P0",name="Mandarin",type="Action"},
    {cost="M5D0P0",name="Margrave",type="Action - Attack"},
    {cost="M4D0P0",name="Noble Brigand",type="Action - Attack"},
    {cost="M4D0P0",name="Nomad Camp",type="Action"},
    {cost="M3D0P0",name="Oasis",type="Action"},
    {cost="M3D0P0",name="Oracle",type="Action - Attack"},
    {cost="M3D0P0",name="Scheme",type="Action"},
    {cost="M4D0P0",name="Silk Road",type="Victory",VP=function(t)return math.floor(t.victory/4) end},
    {cost="M4D0P0",name="Spice Merchant",type="Action"},
    {cost="M5D0P0",name="Stables",type="Action"},
    {cost="M4D0P0",name="Trader",type="Action - Reaction"},
    {cost="M3D0P0",name="Tunnel",type="Victory - Reaction",VP=2},
    {cost="M0D0P0",name="Abandoned Mine",type="Action - Ruins"},
    {cost="M0D0P0",name="Ruined Library",type="Action - Ruins"},
    {cost="M0D0P0",name="Ruined Market",type="Action - Ruins"},
    {cost="M0D0P0",name="Ruined Village",type="Action - Ruins"},
    {cost="M0D0P0",name="Survivors",type="Action - Ruins"},
    {cost="M6D0P0",name="Altar",type="Action"},--DarkAges
    {cost="M4D0P0",name="Armory",type="Action"},
    {cost="M5D0P0",name="Band of Misfits",type="Action"},
    {cost="M5D0P0",name="Bandit Camp",type="Action",depend='Spoils'},
    {cost="M2D0P0",name="Beggar",type="Action - Reaction"},
    {cost="M5D0P0",name="Catacombs",type="Action"},
    {cost="M5D0P0",name="Count",type="Action"},
    {cost="M5D0P0",name="Counterfeit",type="Treasure"},
    {cost="M5D0P0",name="Cultist",type="Action - Attack - Looter"},
    {cost="M4D0P0",name="Death Cart",type="Action - Looter"},
    {cost="M4D0P0",name="Feodum",type="Victory",VP=function(t)return math.floor((t.deck.Silver or 0)/4) end},
    {cost="M3D0P0",name="Forager",type="Action"},
    {cost="M4D0P0",name="Fortress",type="Action"},
    {cost="M5D0P0",name="Graverobber",type="Action"},
    {cost="M3D0P0",name="Hermit",type="Action",depend='Madman'},
    {cost="M6D0P0",name="Hunting Grounds",type="Action"},
    {cost="M4D0P0",name="Ironmonger",type="Action"},
    {cost="M5D0P0",name="Junk Dealer",type="Action"},
    {cost="M5D0P0",name="Knight",type="Action - Attack - Knight"},
    {cost="M4D0P0",name="Marauder",type="Action - Attack - Looter",depend='Spoils'},
    {cost="M3D0P0",name="Market Square",type="Action - Reaction"},
    {cost="M5D0P0",name="Mystic",type="Action"},
    {cost="M5D0P0",name="Pillage",type="Action - Attack",depend='Spoils'},
    {cost="M1D0P0",name="Poor House",type="Action"},
    {cost="M4D0P0",name="Procession",type="Action"},
    {cost="M4D0P0",name="Rats",type="Action"},
    {cost="M5D0P0",name="Rebuild",type="Action"},
    {cost="M5D0P0",name="Rogue",type="Action - Attack"},
    {cost="M3D0P0",name="Sage",type="Action"},
    {cost="M4D0P0",name="Scavenger",type="Action"},
    {cost="M2D0P0",name="Squire",type="Action"},
    {cost="M3D0P0",name="Storeroom",type="Action"},
    {cost="M3D0P0",name="Urchin",type="Action - Attack",depend='Mercenary'},
    {cost="M2D0P0",name="Vagrant",type="Action"},
    {cost="M4D0P0",name="Wandering Minstrel",type="Action"},
    {cost="M0D0P0",name="Madman",type="Action"},
    {cost="M0D0P0",name="Mercenary",type="Action - Attack"},
    {cost="M0D0P0",name="Spoils",type="Treasure"},
    {cost="M5D0P0",name="Dame Anna",type="Action - Attack - Knight"},
    {cost="M5D0P0",name="Dame Josephine",type="Action - Attack - Knight - Victory",VP=2},
    {cost="M5D0P0",name="Dame Molly",type="Action - Attack - Knight"},
    {cost="M5D0P0",name="Dame Natalie",type="Action - Attack - Knight"},
    {cost="M5D0P0",name="Dame Sylvia",type="Action - Attack - Knight"},
    {cost="M5D0P0",name="Sir Bailey",type="Action - Attack - Knight"},
    {cost="M5D0P0",name="Sir Destry",type="Action - Attack - Knight"},
    {cost="M4D0P0",name="Sir Martin",type="Action - Attack - Knight"},
    {cost="M5D0P0",name="Sir Michael",type="Action - Attack - Knight"},
    {cost="M5D0P0",name="Sir Vander",type="Action - Attack - Knight"},
    {cost="M1D0P0",name="Hovel",type="Reaction - Shelter"},
    {cost="M1D0P0",name="Necropolis",type="Action - Shelter"},
    {cost="M1D0P0",name="Overgrown Estate",type="Victory - Shelter"},
    {cost="M4D0P0",name="Advisor",type="Action"},--Guilds
    {cost="M5D0P0",name="Baker",type="Action",depend='Baker'},
    {cost="M5D0P0",name="Butcher",type="Action",depend='Coffers'},
    {cost="M2D0P0",name="Candlestick Maker",type="Action"},
    {cost="M3D0P0",name="Doctor",type="Action"},
    {cost="M4D0P0",name="Herald",type="Action"},
    {cost="M5D0P0",name="Journeyman",type="Action"},
    {cost="M3D0P0",name="Masterpiece",type="Treasure"},
    {cost="M5D0P0",name="Merchant Guild",type="Action"},
    {cost="M4D0P0",name="Plaza",type="Action"},
    {cost="M5D0P0",name="Soothsayer",type="Action - Attack"},
    {cost="M2D0P0",name="Stonemason",type="Action"},
    {cost="M4D0P0",name="Taxman",type="Action - Attack"},
    {cost="M3D0P0",name="Amulet",type="Action - Duration"},
    {cost="M5D0P0",name="Artificer",type="Action"},
    {cost="M5D0P0",name="Bridge Troll",type="Action - Attack - Duration",depend='MinusCoin'},
    {cost="M3D0P0",name="Caravan Guard",type="Action - Duration - Reaction"},
    {cost="M2D0P0",name="Coin of the Realm",type="Treasure - Reserve"},
    {cost="M5D0P0",name="Distant Lands",type="Action - Reserve - Victory"},
    {cost="M3D0P0",name="Dungeon",type="Action - Duration"},
    {cost="M4D0P0",name="Duplicate",type="Action - Reserve"},
    {cost="M3D0P0",name="Gear",type="Action - Duration"},
    {cost="M5D0P0",name="Giant",type="Action - Attack",depend='Journey'},
    {cost="M3D0P0",name="Guide",type="Action - Reserve"},
    {cost="M5D0P0",name="Haunted Woods",type="Action - Attack - Duration"},
    {cost="M6D0P0",name="Hireling",type="Action - Duration"},
    {cost="M5D0P0",name="Lost City",type="Action"},
    {cost="M4D0P0",name="Magpie",type="Action"},
    {cost="M4D0P0",name="Messenger",type="Action"},
    {cost="M4D0P0",name="Miser",type="Action",depend='TavernMat'},
    {cost="M2D0P0",name="Page",type="Action - Traveller"},
    {cost="M2D0P0",name="Peasant",type="Action - Traveller",depend='TavernMat PlusCard PlusAction PlusBuy PlusCoin'},
    {cost="M4D0P0",name="Port",type="Action"},
    {cost="M4D0P0",name="Ranger",type="Action"},
    {cost="M2D0P0",name="Ratcatcher",type="Action - Reserve"},
    {cost="M2D0P0",name="Raze",type="Action"},
    {cost="M5D0P0",name="Relic",type="Treasure - Attack",depend='MinusCard'},
    {cost="M5D0P0",name="Royal Carriage",type="Action - Reserve"},
    {cost="M5D0P0",name="Storyteller",type="Action"},
    {cost="M5D0P0",name="Swamp Hag",type="Action - Attack - Duration"},
    {cost="M4D0P0",name="Transmorgrify",type="Action - Reserve"},
    {cost="M5D0P0",name="Treasure Trove",type="Treasure"},
    {cost="M5D0P0",name="Wine Merchant",type="Action - Reserve"},
    {cost="M3D0P0",name="Treasure Hunter",type="Action - Traveller"},
    {cost="M4D0P0",name="Warrior",type="Action - Warrior - Traveller"},
    {cost="M5D0P0",name="Hero",type="Action - Traveller"},
    {cost="M6D0P0",name="Champion",type="Action - Duration"},
    {cost="M3D0P0",name="Soldier",type="Action - Attack - Traveller"},
    {cost="M4D0P0",name="Fugitive",type="Action - Traveller"},
    {cost="M5D0P0",name="Disciple",type="Action - Traveller"},
    {cost="M6D0P0",name="Teacher",type="Action - Reserve"},
    {cost="M0D0P0",name="Alms",type="Event"},
    {cost="M5D0P0",name="Ball",type="Event",depend='MinusCoin'},
    {cost="M3D0P0",name="Bonfire",type="Event"},
    {cost="M0D0P0",name="Borrow",type="Event",depend='MinusCard'},
    {cost="M3D0P0",name="Expedition",type="Event"},
    {cost="M3D0P0",name="Ferry",type="Event",depend='TwoCost'},
    {cost="M7D0P0",name="Inheritance",type="Event",depend='Estate'},
    {cost="M6D0P0",name="Lost Arts",type="Event",depend='PlusAction'},
    {cost="M4D0P0",name="Mission",type="Event"},
    {cost="M8D0P0",name="Pathfinding",type="Event",depend='PlusCard'},
    {cost="M4D0P0",name="Pilgrimage",type="Event",depend='Journey'},
    {cost="M3D0P0",name="Plan",type="Event",depend='Trashing'},
    {cost="M0D0P0",name="Quest",type="Event"},
    {cost="M5D0P0",name="Raid",type="Event",depend='MinusCard'},
    {cost="M1D0P0",name="Save",type="Event"},
    {cost="M2D0P0",name="Scouting Party",type="Event"},
    {cost="M5D0P0",name="Seaway",type="Event",depend='PlusBuy'},
    {cost="M5D0P0",name="Trade",type="Event"},
    {cost="M6D0P0",name="Training",type="Event",depend='PlusCoin'},
    {cost="M2D0P0",name="Traveling Fair",type="Event"},
    {cost="M5D0P0",name="Archive",type="Action - Duration"},
    {cost="M5D0P0",name="Capital",type="Treasure"},
    {cost="M3D0P0",name="Castles",type="Victory - Castle",depend='VP'},
    {cost="M3D0P0",name="Catapult / Rocks",type="Action - Attack"},
    {cost="M3D0P0",name="Chariot Race",type="Action",depend='VP'},
    {cost="M5D0P0",name="Charm",type="Treasure"},
    {cost="D8M0P0",name="City Quarter",type="Action"},
    {cost="M5D0P0",name="Crown",type="Action - Treasure"},
    {cost="M2D0P0",name="Encampment / Plunder",type="Action",depend='VP'},
    {cost="M3D0P0",name="Enchantress",type="Action - Attack - Duration"},
    {cost="D4M0P0",name="Engineer",type="Action"},
    {cost="M3D0P0",name="Farmers' Market",type="Action - Gathering"},
    {cost="M5D0P0",name="Forum",type="Action"},
    {cost="M3D0P0",name="Gladiator / Fortune",type="Action"},
    {cost="M5D0P0",name="Groundskeeper",type="Action",depend='VP'},
    {cost="M5D0P0",name="Legionary",type="Action - Attack"},
    {cost="M2D0P0",name="Patrician / Emporium",type="Action",depend='VP'},
    {cost="D8M0P0",name="Royal Blacksmith",type="Action"},
    {cost="D8M0P0",name="Overlord",type="Action"},
    {cost="M4D0P0",name="Sacrifice",type="Action",depend='VP'},
    {cost="M2D0P0",name="Settlers / Bustling Village",type="Action"},
    {cost="M4D0P0",name="Temple",type="Action - Gathering"},
    {cost="M4D0P0",name="Villa",type="Action"},
    {cost="M5D0P0",name="Wild Hunt",type="Action - Gathering"},
    {cost="M3D0P0",name="Humble Castle",type="Treasure - Victory - Castle",VP=function(t)return t.castles*1 end},
    {cost="M4D0P0",name="Crumbling Castle",type="Victory - Castle",VP=1},
    {cost="M5D0P0",name="Small Castle",type="Action - Victory - Castle",VP=2},
    {cost="M6D0P0",name="Haunted Castle",type="Victory - Castle",VP=2},
    {cost="M7D0P0",name="Opulent Castle",type="Action - Victory - Castle",VP=3},
    {cost="M8D0P0",name="Sprawling Castle",type="Victory - Castle",VP=4},
    {cost="M9D0P0",name="Grand Castle",type="Victory - Castle",VP=5},
    {cost="MAD0P0",name="King's Castle",type="Victory - Castle",VP=function(t)return t.castles*2 end},
    {cost="D03MP0",name="Catapult",type="Action - Attack"},
    {cost="D04MP0",name="Rocks",type="Treasure"},
    {cost="M2D0P0",name="Encampment",type="Action"},
    {cost="M5D0P0",name="Plunder",type="Treasure"},
    {cost="M3D0P0",name="Gladiator",type="Action"},
    {cost="D8M8P0",name="Fortune",type="Treasure"},
    {cost="M2D0P0",name="Patrician",type="Action"},
    {cost="M5D0P0",name="Emporium",type="Action"},
    {cost="M2D0P0",name="Settlers",type="Action"},
    {cost="M5D0P0",name="Bustling Village",type="Action"},
    {cost="M0D0P0",name="Advance",type="Event"},
    {cost="M0D8P0",name="Annex",type="Event"},
    {cost="M3D0P0",name="Banquet",type="Event"},
    {cost="M6D0P0",name="Conquest",type="Event",depend='VP'},
    {cost="M2D0P0",name="Delve",type="Event"},
    {cost="MED0P0",name="Dominate",type="Event",depend='VP'},
    {cost="M0D8P0",name="Donate",type="Event"},
    {cost="M4D0P0",name="Ritual",type="Event",depend='VP'},
    {cost="M4D0P0",name="Salt the Earth",type="Event",depend='VP'},
    {cost="M2D0P0",name="Tax",type="Event",depend='Debt',setup=function(o)if o.tag=='Deck'then tokenMake(o,'debt',n)end end},
    {cost="M0D5P0",name="Triumph",type="Event",depend='VP'},
    {cost="M4D3P0",name="Wedding",type="Event",depend='VP'},
    {cost="M5D0P0",name="Windfall",type="Event"},
    {cost="MXDXP0",name="Aqueduct",type="Landmark",depend='VP',setup=function(o)local n=o.getName()if n=='Gold pile'or n=='Silver pile'then tokenMake(o,'vp',n)elseif n=='Aqueduct'then tokenMake(o,'vp')end end},
    {cost="MXDXP0",name="Arena",type="Landmark",depend='VP',setup=function(o)if o.getName()=='Arena'then tokenMake(o,'vp',getPlayerCount()*6) end end},
    {cost="MXDXP0",name="Bandit Fort",type="Landmark",VP=function(t)return -((t.deck.Silver or 0)+(t.deck.Gold or 0)*2) end},
    {cost="MXDXP0",name="Basilica",type="Landmark",depend='VP',setup=function(o)if o.getName()=='Arena'then tokenMake(o,'vp',getPlayerCount()*6) end end},
    {cost="MXDXP0",name="Baths",type="Landmark",depend='VP',setup=function(o)if o.getName()=='Arena'then tokenMake(o,'vp',getPlayerCount()*6) end end},
    {cost="MXDXP0",name="Battlefield",type="Landmark",depend='VP',setup=function(o)if o.getName()=='Arena'then tokenMake(o,'vp',getPlayerCount()*6) end end},
    {cost="MXDXP0",name="Colonnade",type="Landmark",depend='VP',setup=function(o)if o.getName()=='Arena'then tokenMake(o,'vp',getPlayerCount()*6) end end},
    {cost="MXDXP0",name="Defiled Shrine",type="Landmark",depend='VP',setup=function(o)local t=o.getObjects()[1].description;if t:find('Action') and not t:find('Gathering')then tokenMake(o,'vp',2) end end},
    {cost="MXDXP0",name="Fountain",type="Landmark",VP=function(t)if t.deck.Copper>9 then return 15 end end},
    {cost="MXDXP0",name="Keep",type="Landmark"},
    {cost="MXDXP0",name="Labyrinth",type="Landmark",depend='VP',setup=function(o)if o.getName()=='Arena'then tokenMake(o,'vp',getPlayerCount()*6) end end},
    {cost="MXDXP0",name="Mountain Pass",type="Landmark",depend='VP Debt'},
    {cost="MXDXP0",name="Museum",type="Landmark",VP=function(t)return #t.deck*2 end},
    {cost="MXDXP0",name="Obelisk",type="Landmark",VP=function(t)if obeliskTarget=="Knights" then return t.knights*2 elseif obeliskTarget then return (t.deck[obeliskTarget] or 0)*2 end return 0 end},
    {cost="MXDXP0",name="Orchard",type="Landmark",VP=function(t)return t.orchard*4 end},
    {cost="MXDXP0",name="Palace",type="Landmark",VP=function(t)return math.min(t.deck.Copper or 0, t.deck.Silver or 0, t.deck.Gold or 0)*3 end},
    {cost="MXDXP0",name="Tomb",type="Landmark",depend='VP'},
    {cost="MXDXP0",name="Tower",type="Landmark",VP=function(t)
        end},
    {cost="MXDXP0",name="Triumphal Arch",type="Landmark",VP=function(t)local h,s=0,0;for card,c in pairs(t.deck)do if getType(card):find('Action')then if c>h then s=h;h=c elseif c>s then s=c end end end return s * 3 end},
    {cost="MXDXP0",name="Wall",type="Landmark",VP=function(t)return -(t.amount-15) end},
    {cost="MXDXP0",name="Wolf Den",type="Landmark",VP=function(t)return -t.wolf*3 end},
    {cost="M4D0P0",name="Envoy",type="Action"},
    {cost="M3D0P0",name="Black Market",type="Action"},
    {cost="M5D0P0",name="Stash",type="Treasure"},
    {cost="M4D0P0",name="Walled Village",type="Action"},
    {cost="M5D0P0",name="Governor",type="Action"},
    {cost="M8D0P0",name="Prince",type="Action"},
    {cost="M5D0P0",name="Summon",type="Event"},
    {cost="M4D0P0",name="Sauna / Avanto",type="Action"},
    {cost="M4D0P0",name="Sauna",type="Action"},
    {cost="M5D0P0",name="Avanto",type="Action"},
    {cost="M6D0P0",name="Adventurer",type="Action"},
    {cost="M3D0P0",name="Chancellor",type="Action"},
    {cost="M4D0P0",name="Feast",type="Action"},
    {cost="M4D0P0",name="Spy",type="Action - Attack"},
    {cost="M4D0P0",name="Thief",type="Action - Attack"},
    {cost="M3D0P0",name="Woodcutter",type="Action"},
    {cost="M4D0P0",name="Coppersmith",type="Action"},
    {cost="M3D0P0",name="Great Hall",type="Action - Victory",VP=1},
    {cost="M5D0P0",name="Saboteur",type="Action - Attack"},
    {cost="M4D0P0",name="Scout",type="Action"},
    {cost="M2D0P0",name="Secret Chamber",type="Action - Reaction"},
    {cost="M5D0P0",name="Tribute",type="Action"},
--Nocturne
    {cost="M4D0P0",name="Lucky Coin",type="Treasure - Heirloom"},
    {cost="M4D0P0",name="Cursed Gold",type="Treasure - Heirloom"},
    {cost="M2D0P0",name="Pasture",type="Treasure - Victory - Heirloom",
      VP=function(t)return t.estates*1 end},
    {cost="M2D0P0",name="Pouch",type="Treasure - Heirloom"},
    {cost="M2D0P0",name="Goat",type="Treasure - Heirloom"},
    {cost="M0D0P0",name="Magic Lamp",type="Treasure - Heirloom"},
    {cost="M0D0P0",name="Haunted Mirror",type="Treasure - Heirloom"},
    {cost="M0D0P0",name="Wish",type="Action"},
    {cost="M2D0P0",name="Bat",type="Night"},
    {cost="M0D0P0",name="Will-o'-Wisp",type="Action"},
    {cost="M2D0P0",name="Imp",type="Action"},
    {cost="M4D0P0",name="Ghost",type="Night - Duration - Spirit"},
    {cost="M6D0P0",name="Raider",type="Night - Duration - Attack"},
    {cost="M5D0P0",name="Werewolf",type="Action - Night - Attack - Doom"},
    {cost="M5D0P0",name="Cobbler",type="Night - Duration"},
    {cost="M5D0P0",name="Den of Sin",type="Night - Duration"},
    {cost="M5D0P0",name="Crypt",type="Night - Duration"},
    {cost="M5D0P0",name="Vampire",type="Night - Attack - Doom"},
    {cost="M4D0P0",name="Exorcist",type="Night"},
    {cost="M4D0P0",name="Devil's Workshop",type="Night"},
    {cost="M3D0P0",name="Ghost Town",type="Night - Duration"},
    {cost="M3D0P0",name="Night Watchman",type="Night"},
    {cost="M3D0P0",name="Changeling",type="Night"},
    {cost="M2D0P0",name="Guardian",type="Night - Duration"},
    {cost="M2D0P0",name="Monastery",type="Night"},
    {cost="M5D0P0",name="Idol",type="Treasure - Attack - Fate"},
    {cost="M5D0P0",name="Tormentor",type="Action - Attack - Doom"},
    {cost="M5D0P0",name="Cursed Village",type="Action - Doom"},
    {cost="M5D0P0",name="Sacred Grove",type="Action - Fate"},
    {cost="M5D0P0",name="Tragic Hero",type="Action"},
    {cost="M5D0P0",name="Pooka",type="Action",depend='Cursed_Gold'},
    {cost="M4D0P0",name="Cemetery",type="Victory",depend='Ghost Haunted_Mirror',VP=2},
    {cost="M4D0P0",name="Skulk",type="Action - Attack - Doom"},
    {cost="M4D0P0",name="Blessed Village",type="Action - Fate"},
    {cost="M4D0P0",name="Bard",type="Action - Fate"},
    {cost="M4D0P0",name="Necromancer",type="Action"},
    {cost="M4D0P0",name="Conclave",type="Action"},
    {cost="M4D0P0",name="Shepherd",type="Action",depend='Pasture'},
    {cost="M3D0P0",name="Secret Cave",type="Action - Duration",depend='Magic_Lamp'},
    {cost="M3D0P0",name="Fool",type="Action - Fate",depend='Lucky_Coin'},
    {cost="M3D0P0",name="Leprechaun",type="Action - Doom"},
    {cost="M2D0P0",name="Faithful Hound",type="Action - Reaction"},
    {cost="M2D0P0",name="Druid",type="Action - Fate"},
    {cost="M2D0P0",name="Tracker",type="Action - Fate",depend='Pouch'},
    {cost="M2D0P0",name="Pixie",type="Action - Fate",depend='Goat'},
--Renaissance
    {cost="M8D0P0",name="Citadel",type="Project"},
    {cost="M7D0P0",name="Canal",type="Project"},
    {cost="M6D0P0",name="Innovation",type="Project"},
    {cost="M6D0P0",name="Crop Rotation",type="Project"},
    {cost="M6D0P0",name="Barracks",type="Project"},
    {cost="M5D0P0",name="Road Network",type="Project"},
    {cost="M5D0P0",name="Piazza",type="Project"},
    {cost="M5D0P0",name="Guildhall",type="Project"},
    {cost="M5D0P0",name="Fleet",type="Project"},
    {cost="M5D0P0",name="Capitalism",type="Project"},
    {cost="M5D0P0",name="Academy",type="Project"},
    {cost="M4D0P0",name="Sinister Plot",type="Project"},
    {cost="M4D0P0",name="Silos",type="Project"},
    {cost="M4D0P0",name="Fair",type="Project"},
    {cost="M4D0P0",name="Exploration",type="Project"},
    {cost="M3D0P0",name="Star Chart",type="Project"},
    {cost="M3D0P0",name="Sewers",type="Project"},
    {cost="M3D0P0",name="Pageant",type="Project"},
    {cost="M3D0P0",name="City Gate",type="Project"},
    {cost="M3D0P0",name="Cathedral",type="Project"},
    {cost="M5D0P0",name="Spices",type="Treasure"},
    {cost="M5D0P0",name="Scepter",type="Treasure"},
    {cost="M5D0P0",name="Villain",type="Action - Attack"},
    {cost="M5D0P0",name="Old Witch",type="Action - Attack"},
    {cost="M5D0P0",name="Treasurer",type="Action"},
    {cost="M5D0P0",name="Swashbuckler",type="Action"},
    {cost="M5D0P0",name="Seer",type="Action"},
    {cost="M5D0P0",name="Sculptor",type="Action"},
    {cost="M5D0P0",name="Scholar",type="Action"},
    {cost="M5D0P0",name="Recruiter",type="Action"},
    {cost="M4D0P0",name="Research",type="Action - Duration"},
    {cost="M4D0P0",name="Patron",type="Action - Reaction"},
    {cost="M4D0P0",name="Silk Merchant",type="Action"},
    {cost="M4D0P0",name="Priest",type="Action"},
    {cost="M4D0P0",name="Mountain Village",type="Action"},
    {cost="M4D0P0",name="Inventor",type="Action"},
    {cost="M4D0P0",name="Hideout",type="Action"},
    {cost="M4D0P0",name="Flag Bearer",type="Action"},
    {cost="M3D0P0",name="Cargo Ship",type="Action - Duration"},
    {cost="M3D0P0",name="Improve",type="Action"},
    {cost="M3D0P0",name="Experiment",type="Action"},
    {cost="M3D0P0",name="Acting Troupe",type="Action"},
    {cost="M2D0P0",name="Ducat",type="Treasure"},
    {cost="M2D0P0",name="Lackeys",type="Action"},
    {cost="M2D0P0",name="Border Guard",type="Action"},
    {cost="M6D0P0",name="Captain",type="Action - Duration"},
    {cost="M3D0P0",name="Church",type="Action - Duration"},
--CustomCards
    {cost="M6D0P0",name="Mortgage",type="Project",depend='Debt'},
    {cost="M0D0P0",name="Lost Battle",type="Landmark",depend='VP'},
    {cost="M4D0P0",name="Cave",type="Night - Victory",VP=2},
    {cost="M4D0P0",name="Chisel",type="Action - Reserve"},
    {cost="M7D0P0",name="Knockout",type="Event"},
    {cost="M1D0P1",name="Migrant Village",type="Action",depend='Villager'},
    {cost="M4D0P0",name="Discretion",type="Action - Reserve",depend='VP Coffers Villager'},
    {cost="M4D0P0",name="Plot",type="Night",depend='VP'},
    {cost="M4D0P0",name="Investor",type="Action",depend='Debt'},
    {cost="M6D0P0",name="Contest",type="Action - Looter"},
    {cost="M6D0P0",name="Uneven Road",type="Action - Victory",depend='Estate',VP=3},
    {cost="M3D0P1",name="Jekyll",type="Action",depend='Hyde'},
    {cost="M4D0P1",name="Hyde",type="Night - Attack"},
    {cost="M5D0P0",name="Stormy Seas",type="Night",depend='Debt'},
    {cost="M0D4P0",name="Liquid Luck",type="Action"},
    {cost="M6D0P0",name="Cheque",type="Treasure - Command"},
    {cost="M2D0P0",name="Balance",type="Action - Reserve - Fate - Doom"},
    {cost="M0D0P0",name="Rabbit",type="Action - Treasure"},
    {cost="M5D0P0",name="Magician",type="Action",depend='Rabbit'},
    {cost="M4D0P0",name="Fishing Boat",type="Action - Duration"},
    {cost="M3D0P0",name="Drawbridge",type="Action - Reserve"},
    {cost="M4D0P0",name="Jinxed Jewel",type="Treasure - Night - Heirloom"},
    {cost="M0D0P0",name="-1 Card Token",type="Curse"},
    {cost="M0D0P0",name="TemplateCard",type="Curse",depend='Debt VP Coffers Villager Estate',setup=function(o)print('TEMPLATE')end,VP=function(t)return t.estates*0 end},
}