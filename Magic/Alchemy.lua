--Amuzet
local s,Obj,toggle=0.5,self,true;
self.addContextMenuItem('Test',function(a)Player[a].broadcast(a)self.clearContextMenu()end)
B=setmetatable({click_function='B',function_owner=self,position={0,0.51,0},scale={s,1,s},height=400,width=1000,font_size=150},{__call=function(b,l,p,t,f)b.label,b.position,b.tooltip=l,p,t or l;if f then b.click_function=f;else b.click_function='c_'..l:gsub('[%w ]+\n',''):gsub('%s','');end self.createButton(b)end});
function onDestroy()if Obj then Obj.highlightOff()end end
function onPlayerTurnStart(p)if Obj then Obj.highlightOff()self.setColorTint(stringColorToRGB(p))Obj.highlightOn(self.getColorTint())end end
function onCollisionEnter(o)if Obj then Obj.highlightOff()end Obj=o.collision_object;Obj.highlightOn(self.getColorTint())end
function onLoad()
  B('')
  end
function foundDeck()
  addContextMenuItem('Clear Context',function(c)if Player[c].admin then clearContextMenu()end end)
  self.clearButtons()
  for i,v in pairs({'Draft\nSpellbook','Card\nSeek'})do
    B(v,{(math.floor((i-1)/5)-0.5)*2.1*s,0.51,((i-1)%5-2)*s})
    local m=B.click_function:gsub('c_','m_')
    self.setVar(m,function(c)self.getVar(B.click_function)(nil,c)end)
    Obj.addContextMenuItem(v:gsub('\n',' '),self.getVar(m))end end

--Choose/Random
function addPerpetually()
  if random then handCardRandom()
  else handCardChoose() end
end
function handCardChoose()
  
end
function handCardRandom()
  
end
--In Hand
perpetually={
['Any']={},
['Party']={},
['Instant or Sorcery']={},
['Giant or Wizard']={},
['Creature']={},
['Dragon']={},
['greatest mana value']={},
['Custom']={},
}

--TablePIE
function deckRampW(ply)
  local deck = getDeckFromZone(data[ply]["libraryZone"])
  if deck==nil then return end
  for i,card in ipairs(deck.getObjects()) do
    local cname=card.name:lower():gsub('%p','')
    if cname:find('basic') and cname:find('land') and cname:find('plains') then
      local rot=deck.getRotation()
      local pos=deck.getPosition()
      local rig=deck.getTransformRight()
      rot[3]=0
      pos=pos+rig:scale(deckDirs[ply]*2.4)
      deck.takeObject({index=i-1,position=pos,rotation=rot})
      break
    end
  end
  Wait.time(function() deck.shuffle() end, 0.1, 5)
end

function getCMC(name,desc)
  for _,m in pairs({'(%d+) ?cmc','cmc ?(%d+)'})do
    if not cmc then cmc=name:lower():match(m)end
    if not cmc then cmc=desc:lower():match(m)end
  end
  isLand=name:match('Land')
  if (cmc==nil or cmc=='0') and isLand then
    cmc='-1'end
  if cmc==nil and (desc:lower():match('suspend') or name:lower():match('pact') or name:lower():match('evermind')) then
    cmc=0 end
  return cmc
end

--Seek
seekB={width=2500,height=200,font_size=180,color={0,0,0},font_color={1,1,1}}
function c_Seek(o,c,a)
  if Obj and Obj.type=='Deck'then
    Obj.clearButtons()
    seekB.position={0,2,-1}
    for k,_ in pairs(Seek)do
      seekB.label='Seek '..k
      seekB.position[3]=seekB.position[3]+0.2
      seekB.click_function='c_'..k:gsub(' ','_')
      
      self.setVar(seekB.click_function,function(o,c,a)
        local candidates={}
        for i,c in pairs(o.getObjects())do
          table.insert(candidates,Seek[k][1](c))end
        local g=Seek[k][2](candidates)
        if g then o.takeObject({
          position=,
          guid=g})
        else broadcastToAll('No card Found')end
        end)
      
      Obj.createButton(seekB)
    end
  else broadcastToColor('No Deck Found',c,Color.Red)end end


Seek={
['named']={''},
['non type']={''},
['this type']={''},
['with mana value exactly']={''},
['with mana value or less']={''},
['this type or that type']={function(c)
  
    end,function(c)end},
['most prevalent creature type']={function(c)
  if c.name:find('creature ')then
    local t=c.name:gsub('.+/n.+%- ',''):gsub(' %d+CMC','')
    c.types={}
    for s in t:gmatch('%S+')do table.insert(c.types,s)end
    return c else return nil end end,function(candidates)
  types={}
  for _,c in pairs(candidates)do
    for _,t in pairs(c.types)do
      types[t]=(types[t]or 0)+1
  end end
  --Find Max
  for k,v in pairs(types)do
    if previous then
      if v==math.max(types[previous],v)then
        previous=k end
    else previous=k end end
  --Get One
  for _,c in pairs(candidates)do
    if c.name:find(previous)then
      for _,t in pairs(c.types)do
        if t==previous then
          return c.guid
  end end end end end},
}
--Spellbooks
function c_Spellbook(o,c,a)
  if Obj and Obj.type then addNotebookTab({title=Obj.getGUID(),body=Obj.getJSON()})end end
Spellbook={
['Arms Scavenger']={'Boots of Speed','Cliffhaven Kitesail','Colossus Hammer','Dueling Rapier','Spare Dagger','Tormentors Helm','Goldvein Pick','Jousting Lance','Mask of Immolation','Mirror Shield','Relic Axe','Rogues Gloves','Scavenged Blade','Shield of the Realm','Ceremonial Knife'},
['Break Expectations']={'Colossal Plow','Millstone','Whirlermaker','Magistrates Scepter','Replicating Ring','Raiders Karve','Weapon Rack','Relic Amulet','Orazca Relic','Fifty Feet of Rope','Pyre of Heroes','Treasure Chest','Leather Armor','Spiked Pit Trap','Gingerbrute'},
['Cursebound Witch']={'Witchs Cauldron','Witchs Vengeance','Witchs Oven','Witchs Cottage','Witchs Familiar','Curse of Leeches','Cauldron Familiar','Black Cat','Sorcerers Broom','Bloodhunter Bat','Unwilling Ingredient','Expanded Anatomy','Cruel Reality','Torment of Scarabs','Trespassers Curse'},
['Faithful Disciple']={'Anointed Procession','Cathars Crusade','Authority of the Consuls','Sigil of the Empty Throne','All That Glitters','Banishing Light','Divine Visitation','Duelists Heritage','Glorious Anthem','Gauntlets of Light','Teleportation Circle','Angelic Gift','Spectral Steel','Cleric Class','Angelic Exaltation'},
['Garruk, Wrath of the Wilds']={'Mosscoat Goriak','Sylvan Brushstrider','Murasa Rootgrazer','Dire Wolf Prowler','Ferocious Pup','Pestilent Wolf','Garruks Uprising','Dawntreader Elk','Nessian Hornbeetle','Territorial Scythecat','Trufflesnout','Wary Okapi','Scurrid Colony','Barkhide Troll','Underdark Basilisk'},
['Hinterland Chef']={'Almighty Brushwagg','Frilled Sandwalla','Moss Viper','Brushstrider','Highland Game','Ironshell Beetle','Lotus Cobra','Kazandu Nectarpot','Gilded Goose','Nessian Hornbettle','Scurrid Colony','Territorial Boar','Deathbonnet Sprout','Spore Crawler','Moldgraf Millipede'},
['Ishkana, Broodmother']={'Twin-Silk Spider','Drider','Brood Weaver','Glowstone Recluse','Gnottvold Recluse','Hatchery Spider','Mammoth Spider','Netcaster Spider','Sentinel Spider','Snarespinner','Sporecap Spider','Spidery Grasp','Spider Spawning','Prey Upon','Arachnoform'},
['Key to the Archive']={'Approach of the Second Sun','Day of Judgment','Time Warp','Counterspell','Demonic Tutor','Doom Blade','Lightning Bolt','Claim the Firstborn','Krosan Grip','Regrowth','Despark','Electrolyze','Growth Spiral','Lightning Helix','Putrefy'},
['Ominous Traveler']={'Dominationg Vampire','Vampire Socialite','Stromkirk Bloodthief','Falkenrath Pit Fighter','Wolfkin Outcast','Howlpack Piper','Tovolar, Dire Overloard','Patrician Geist','Shipwreck Sifters','Steelclad Spirit','Heron-Blessed Geist','Archghoul of Thraben','Champion of the Perished','Headless Rider','Bladestitched Skaab'},
['Slayers Bounty']={'Bounty Agent','Outflank','Bound in Gold','Bring to Trial','Glass Casket','Reprobation','Collar the Culprit','Compulsory Rest','Expel','Fairgrounds Warden','Iron Verdict','Luminous Bonds','Raise the Alarm','Seal Away','Summary Judgment'},
['Tibalt, Wicket Tormentor']={'Chained Brute','Charmbreaker Devils','Festival Crasher','Forge Devil','Frenzied Devils','Havoc Jester','Hellrider','Hobblefiend','Pitchburn Devils','Sin Prodder','Spiteful Prankster','Tibalts Rager','Torch Fiend','Brimstone Vandal','Devils Play'},
['Tireless Angler']={'Fleet Swallower','Moat Piranhas','Mystic Skyfish','Nadir Kraken','Pouncing Shoreshark','Sea-Dasher Octopus','Spined Megalodon','Stinging Lionfish','Voracious Greatshark','Archipelagore','Serprent of Yawning Depths','Wormhole Serpent','Sigiled Starfish','Riptide Turtle','Ruin Crab'}
}