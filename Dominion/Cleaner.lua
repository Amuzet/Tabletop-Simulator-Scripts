--By Amuzet
mod_name = 'Dominion Play Area'
version = 1
local previousTurn,currentTurn,playArea,currDebt='Black','Black',false,false
local option={Flag=false,Horn=false,autoHorn=false}
function onLoad(sData)
  if sData~=''then
    local o,p=sData:match('(w+) (w+)')
    o=getObjectFromGUID(o)
    if o then
      playArea,previousTurn=o,p
    else
      onSave()
    end
  end
  onDrop()
end

function onSave()if playArea then return playArea.getGUID()..' '..currentTurn end return''end
function onDrop()broadcastToAll('The Play Area will be set up when turns are turned on.\nOr a player passes the turn.',{0.9,0.9,0.9})end

function onChat(msg,player)
  if player.admin then
    if msg=='UNLOCK'then
      self.interactable=true
    elseif msg=='DELETEPLAYMAT'then
      self.destroy()
    elseif msg=='SIMULATE'then
      onPlayerTurn(player)
    end
  end
end

function onObjectEnterScriptingZone(z,o)
  if z==playArea and o.getDescription():find('Treasure')then
    local dToken=getObjectFromGUID(Global.getTable('ref_players')[currentTurn].debt)
    if dToken and not currDebt then
      local n=dToken.getVar('count')
      if n>0 then currDebt=n
        broadcastToAll(Player[currentTurn].steam_name..' has [ee1111]'..n..' Debt',stringColorToRGB(currentTurn))
end end end end
function onPlayerTurn(player)
  if Global.getTable('ref_players')and Global.getVar('gameState')==3 then
    currDebt=false
    if not playArea then
      setPlayArea()
    elseif Player[previousTurn]then
      --Find where to put them
      local zone = Global.getTable('ref_players')[previousTurn]
      local zDiscard = getObjectFromGUID( zone.discardZone )
      local pDiscard = zone.discardZone.getPosition()
      local oDiscard = zDiscard.getObjects()
      local zDeck = getObjectFromGUID( zone.deckZone )
      local pDeck = zone.deckZone.getPosition()
      local oDeck = zDeck.getObjects()
      if #oDiscard==2 then
        for _,v in pairs(oDiscard)do
          if v.tag=='Deck'and getObjectFromGUID(v.guid).is_face_down then
              for _,d in pairs(oDeck)do
                if v.tag=='Deck'and getObjectFromGUID(v.guid).is_face_down then
                  Player[previousTurn].broadcast('Fix your Deck/Discard area!',{})
                  return
              zone.discardZone = zDeck
              zone.deckZone = zDiscard
              zone.discard = pDeck
              zone.deck = pDiscard
            end end end
      else
        zone.discardZone = zDiscard
        zone.deckZone = zDeck
        zone.discard = pDiscard
        zone.deck = pDeck
      end
      zone.objs = getObjectFromGUID( zone.zone ).getObjects()
      
      --FlagHorn check
      local cards=5
      for i,v in ipairs(zone.objs)do
        if v.name=='Flag'then
          log()
          cards=cards+1
        elseif v.name=='Horn'and option.autoHorn then
          local tbl={position=zone.deck,rotation={0,0,0},1}
          for _,o in ipairs(playArea.getObjects())do
            if o.tag=='Deck'then
              for d,c in ipairs(o.getObjects())do
                if c.nickname=='Border Guard'then
                  tbl.index=d
                  tbl.bool=true
                  o.takeObject(tbl)
                  break
                end
              end
            end
            if tbl.bool then break end
            if o.tag=='Card'and o.getName()=='Border Guard'then
              o.putObject(getDeck(zone.deckZone.getObjects()))
              break
      end end end end
      --Put play area and hand in discard pile
      putDiscard( playArea.getObjects() , zone.discard )
      putDiscard( Player[previousTurn].getHandObjects() , zone.discard , true )
      --If we didnt draw a full hand
      delay('autoDrawCards',{draw=cards,zone=zone,color=previousTurn})
    end
  end
  currentTurn = player.color
  if not Player[currentTurn] then currentTurn = 'Black' end
  previousTurn = currentTurn
  --Set Play Mat tint darker
  local color = stringColorToRGB(currentTurn)
  for k,v in pairs( color ) do color[k] = (v * 0.6) + 0.1 end
  color.a = 1
  self.setColorTint( color )
end

function clean(s)
  return ([[--Dominion Play Area
self.setName('%s')
function bye(o) if o.getName():find('PLAY AREA') then self.destruct() end end
function onObjectDestroy(o) bye(o) end
function onObjectDrop(p,o) bye(o) end]]):format(s,s)
end

function getDeck( oTbl )
  for _,v in ipairs( oTbl ) do
    if v.tag == 'Deck' or v.tag == 'Card' then
      return v, v.tag
    end
  end
  return false, false
end

function putDiscard( oTbl , zPos , hand )
  for _,v in ipairs( oTbl ) do
    if v.getLock() == true then
    elseif v.getDescription():find('Boon') then
    elseif v.getDescription():find('Hex') then
    elseif v.getDescription():find('State') then
    elseif v.getDescription():find('Artifact') then
    elseif v.tag == 'Deck' or v.tag == 'Card' then
      v.setScale({1.88,1,1.88})
      v.setRotation({0,180,0})
      if hand then
        v.clone({position = zPos})
        v.destruct()
      else
        v.setPositionSmooth( zPos )
      end
    end
  end
end

function setPlayArea()
  self.interactable = false
  self.setLock(true)
  self.setPosition({0.00, 1.00, -2.30})
  self.setRotation({0,90,0})
  self.setScale({16.00, 0.20, 54.8})
  self.setName('playArea')
  self.setDescription('Cards played here and in your hand will be auto discarded once you end your turn. Make sure to keep any Duration cards off this play area untill they are ready to be discarded. A new 5 cards will be drawn automaticly once you end your turn.')

  local tZ = {
    type = 'ScriptingTrigger',
    scale = self.getBounds().size,
    position = self.getPosition(),
    callback_function = function(obj)
      playArea = obj
      onSave()
    end}
  
  tZ.scale.y = 2
  tZ.position.y = ( tZ.position[2] + tZ.scale[2] - ( tZ.scale.y / 2 ) )
  
  spawnObject( tZ ).setLuaScript( clean('playArea') )
end

function delay( fName , tbl )
  local timerParams={function_name=fName,identifier=fName..tbl.color..'Timer',parameters=tbl,delay=1}
  Timer.destroy(timerParams.identifier)
  Timer.create(timerParams)
end

function autoDrawCards( p )
  local deckCards,tag=p.zone.deckZone.getObjects(),false
  deckCards,tag=getDeck(deckCards)
  
  --Attempt to draw cards
  if tag=='Deck'and deckCards.getQuantity()>=p.draw then
    deckCards.deal(p.draw,p.color)
  else
    -- alert player this may take some time
    if tag=='Deck'then
      deckCards.deal(p.draw,p.color)
    elseif tag=='Card'and p.draw>0 then
      --Put that card in the hand
      deckCards.setRotation({0,180,0})
      deckCards.setPosition(Player[p.color].getHandTransform().position)
    end
    --Calculate Remaining
    p.deck=p.zone.deck
    p.zone=p.zone.discardZone
    delay('reshuffleDiscard',p)
end end
function reshuffleDiscard(p)
  p.draw=p.draw-#Player[p.color].getHandObjects()
  if p.draw>0 then
    local deckCards,tag=getDeck(p.zone.getObjects())
    p.zone=nil
    --Reshuffle Discard Pile
    if tag=='Deck'then
      deckCards.setRotation({180,0,0})
      deckCards.setPositionSmooth( p.deck )
      deckCards.shuffle()
      --Draw Remaining Cards
      broadcastToColor('Reshuffling deck, please wait...',p.color,{0.9, 0.9, 0.9})
      p.deck=deckCards
      delay('postDiscardDraw',p)
    elseif tag=='Card'then
      deckCards.setPosition(Player[p.color].getHandTransform().position)
    end
  end
end

function postDiscardDraw( p )
  p.deck.deal(p.draw,p.color)
end
--EOF