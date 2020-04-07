--By Amuzet
version,mod_name=1,'Dominion Play Area'
local playArea,currDebt,option=false,false,{Flag=false,Horn=false,autoHorn=false}
function onLoad(sData)
  if sData~=''then
    local o=sData:match('(w+)')
    o=getObjectFromGUID(o)
    if o then playArea=o else onSave()end end onDrop()end

function onSave()if playArea then return playArea.getGUID() end return''end
function onDrop()broadcastToAll('The Play Area will be set up when turns are turned on.\nOr a player passes the turn.',{0.9,0.9,0.9})end

function onChat(s,p)
  if p.admin then
    local m=s:lower()
    if m=='unlock'then self.interactable=true
    elseif m=='delete'then self.destroy()
    elseif m=='simulate'then onPlayerTurn(p)
end end end

function onObjectEnterScriptingZone(z,o)
  if z==playArea and o.getDescription():find('Treasure')then
    local dToken=getObjectFromGUID(Global.getTable('ref_players')[Turns.turn_color].debt)
    if dToken and not currDebt then
      local n=dToken.getVar('count')
      if n>0 then currDebt=n
        broadcastToAll(Player[Turns.turn_color].steam_name..' has [ee1111]'..n..' Debt',stringColorToRGB(Turns.turn_color))
end end end end
function onPlayerTurn(player)
  if Global.getTable('ref_players')and Global.getVar('gameState')==3 then currDebt=false
    if not playArea then setPlayArea()
    elseif Player[Turns.getPreviousTurnColor()]then
      --Find where to put them
      local t=Global.getTable('ref_players')[Turns.getPreviousTurnColor()]
      local zDd,zDk=getObjectFromGUID(t.discardZone),getObjectFromGUID(t.deckZone)
      local pDd,pDk=zDd.getPosition(),zDk.getPosition()
      t.discardZone,t.deckZone,t.discard,t.deck=zDd,zDk,pDd,pDk
      local dN,flip=0,false
      for _,v in pairs(zDd.getObjects())do
        if v.tag=='Deck'or v.tag=='Card'then dN=dN+1
          if getObjectFromGUID(v.guid).is_face_down then flip=true
            for _,d in pairs(zDk.getObjects())do
              if dN>1 or v.tag=='Deck'and getObjectFromGUID(v.guid).is_face_down then
                --Both Deck and Discard were facedown or two decks are in your discard!
                Player[Turns.getPreviousTurnColor()].broadcast('Fix your Deck/Discard area!',{1,0,1})
        end end end end if flip and dN<2 then
        t.discardZone,t.deckZone,t.discard,t.deck=zDk,zDd,pDk,pDd end end
      --FlagHorn check
      t.draw=5
      for _,v in pairs(getObjectFromGUID(t.zone).getObjects())do
        if v.getName()=='Flag'then t.draw=t.draw+1
        elseif v.getName()=='Horn'and option.autoHorn then
          local tbl={position=t.deck,rotation={0,0,0},1}
          for _,o in pairs(playArea.getObjects())do
            if o.tag=='Card'and o.getName()=='Border Guard'then
              o.putObject(getDeck(t.deckZone.getObjects()))break
            elseif o.tag=='Deck'then
              for d,c in pairs(o.getObjects())do
                if c.nickname=='Border Guard'then
                  tbl.index,tbl.bool=d,true
                  o.takeObject(tbl)break end end end
            if tbl.bool then break end end end end
      --Put play area and hand in discard pile
      putDiscard(playArea.getObjects(),t.discard)
      putDiscard(Player[Turns.getPreviousTurnColor()].getHandObjects(),t.discard,true)
      --If we didnt draw a full hand
      t.color=Turns.getPreviousTurnColor()
      delay('autoDrawCards',t)
    end
    --Set Play Mat tint darker
    local c=stringColorToRGB(Turns.turn_color)
    for k,v in pairs(c)do c[k]=(v*0.6)+0.1 end c[4]=1
    self.setColorTint(c)
  end
end

function setPlayArea()
  self.interactable=false
  self.setLock(true)
  self.setPosition({0,1,-2.2})
  self.setRotation({0,0,0})
  self.setScale({112,0.1,16.4})
  self.setName('playArea')
  self.setDescription('Cards played here and in your hand will be auto discarded once you end your turn. Make sure to keep any Duration cards off this play area untill they are ready to be discarded. A new 5 cards will be drawn automaticly once you end your turn.')

  local tZ={type='ScriptingTrigger',scale=self.getBounds().size,position=self.getPosition(),callback_function=function(obj)playArea=obj;onSave()end}
  tZ.scale.y=2;tZ.position.y=(tZ.position[2]+tZ.scale[2]-(tZ.scale.y/2))
  spawnObject(tZ).setLuaScript(clean('playArea'))
end
function autoDrawCards(p)
  local cDk=getDeck(p.deckZone.getObjects())
  --Attempt to draw cards
  if cDk and cDk.tag=='Deck'and cDk.getQuantity()>=p.draw then
    cDk.deal(p.draw,p.color)
  elseif cDk then
    -- alert player this may take some time
    if cDk.tag=='Deck'then
      cDk.deal(p.draw,p.color)
    elseif cDk.tag=='Card'and p.draw>0 then
      --Put that card in the hand
      cDk.setRotation({0,180,0})
      cDk.setPosition(Player[p.color].getHandTransform().position)
    end end delay('reshuffleDiscard',p)end
function reshuffleDiscard(p)
  --Calculate Remaining
  p.draw=p.draw-#Player[p.color].getHandObjects()
  if p.draw>0 then
    local cDk=getDeck(p.discardZone.getObjects())
    --Reshuffle Discard Pile
    if not cDk then broadcastToAll('Has something gone wrong?',p.color,{0.9,0.1,0.9})
    elseif cDk.tag=='Card'then cDk.setPosition(Player[p.color].getHandTransform().position)
    elseif cDk.tag=='Deck'then
      cDk.setRotation({180,0,0})
      cDk.setPositionSmooth(p.deck)
      cDk.shuffle()
      --Draw Remaining Cards
      broadcastToColor('Reshuffling deck, please wait...',p.color,{0.9, 0.9, 0.9})
      p.deck=cDk
      delay('postDiscardDraw',p)end end end
function postDiscardDraw(p)p.deck.deal(p.draw,p.color)end

function putDiscard(t,p,hand)
  for _,v in pairs(t)do
    if v.getLock()==true then
    elseif v.getDescription():find('Boon')then
    elseif v.getDescription():find('Hex')then
    elseif v.getDescription():find('State')then
    elseif v.getDescription():find('Artifact')then
    elseif v.tag=='Deck'or v.tag=='Card'then
      v.setScale({1.88,1,1.88})
      v.setRotation({0,180,0})
      if hand then
        v.clone({position=p})
        v.destruct()
      else
        v.setPositionSmooth(p)
end end end end
function delay(N,t)local p={function_name=N,identifier=N..t.color..'PA',parameters=t,delay=1}Timer.destroy(p.identifier)Timer.create(p)end
function getDeck(z)for _,v in pairs(z)do if v.tag=='Deck'or v.tag=='Card'then return v end end return false end
function clean(s)return('self.setName(\'%s\')function bye(o) if o.getName():find(\'PLAY AREA\')then self.destruct()end end function onObjectDestroy(o)bye(o)end function onObjectDrop(p,o)bye(o)end'):format(s,s)end
--EOF