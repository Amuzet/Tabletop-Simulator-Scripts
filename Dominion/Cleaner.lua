--By Amuzet
version,mod_name=2,'Dominion Play Area'
GITURL='https://raw.githubusercontent.com/Amuzet/Tabletop-Simulator-Scripts/master/Dominion/Cleaner.lua'
local Script,DISCONNECT,playArea,currDebt,option=false,false,false,false,{Flag=false,Horn=false,autoHorn=false}
function onLoad(sData)
  if not Script then
    Script=getObjectFromGUID('176e6a')
    if Script.script_code:len()<9 then
      Script=Global
  end end
  WebRequest.get(GITURL,function(wr)
    local v=wr.text:match('version,mod_name=(%d*%p?%d*)')
    if v then v=tonumber(v)
      if v>version then self.setLuaScript(wr.text)self.reload()end
    else broadcastToAll('Problems have occured! Attempt to contact Amuzet on TTSClub',{1,0,0.2})end end)
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
    local dToken=getObjectFromGUID(pt[Turns.turn_color].debt)
    if dToken and not currDebt then
      local n=dToken.getVar('count')
      if n>0 then currDebt=n
        broadcastToAll(Player[Turns.turn_color].steam_name..' has [ee1111]'..n..' Debt',stringColorToRGB(Turns.turn_color))
end end end end
function onPlayerDisconnect(player)
  DISCONNECT=player.color
  delay('dc',{color=DISCONNECT})
end function dc()DISCONNECT=false end
function wait(time)local start=os.time()repeat coroutine.yield(0)until os.time()>start+time end
function onPlayerTurn(player)
  local gs=Script.getVar('gameState')
  if gs==3 then
    currDebt=false
    if not playArea then
      setPlayArea()
      pt=Script.getTable('ref')['players']
      log(pt)
    elseif Player[Turns.getPreviousTurnColor()]and not DISCONNECT then
      --Find where to put them
      log(pt)
      local t=pt[Turns.getPreviousTurnColor()]
      local zDd,zDk=getObjectFromGUID(t.discardZone),getObjectFromGUID(t.deckZone)
      t.zoneDiscard,t.zoneDeck=zDd,zDk
      local dN,flip=0,false
      for _,v in pairs(zDd.getObjects())do
        if v.type=='Deck'or v.type=='Card'then dN=dN+1
          if getObjectFromGUID(v.guid).is_face_down then flip=true
            for _,d in pairs(zDk.getObjects())do
              if dN>1 or v.type=='Deck'and getObjectFromGUID(v.guid).is_face_down then
                --Both Deck and Discard were facedown or two decks are in your discard!
                Player[Turns.getPreviousTurnColor()].broadcast('Fix your Deck/Discard area!',{1,0,1})
      end end end end end
      --FlagHorn check
      t.draw=5
      for _,v in pairs(t.zoneDeck.getObjects())do
        if v.getName()=='-1 Card Token'then t.draw=t.draw-1
          local p=v.getPosition()
          v.setPosition({p[1],p[2],p[3]+5})end end
      for _,v in pairs(getObjectFromGUID(t.zone).getObjects())do
        if v.getName()=='Flag'then t.draw=t.draw+1
        elseif v.getName()=='Horn'and option.autoHorn then
          local tbl={position=t.deck,rotation={0,0,0},1}
          for _,o in pairs(playArea.getObjects())do
            if o.type=='Card'and o.getName()=='Border Guard'then
              o.putObject(getDeck(t.zoneDeck.getObjects()))break
            elseif o.type=='Deck'then
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
  self.setRotation({0,0,0})
  self.setName('playArea')
  self.setDescription('Cards played here and in your hand will be auto discarded once you end your turn. Make sure to keep any Duration cards off this play area untill they are ready to be discarded. A new 5 cards will be drawn automaticly once you end your turn.')

  local tZ={type='ScriptingTrigger',scale=self.getBounds().size,position=self.getPosition(),callback_function=function(obj)playArea=obj;onSave()end}
  tZ.scale.y=2;tZ.position.y=(tZ.position[2]+tZ.scale[2]-(tZ.scale.y/2))
  spawnObject(tZ).setLuaScript(clean('playArea'))
end
function autoDrawCards(p)
  local cDk=getDeck(p.zoneDeck.getObjects())
  --Attempt to draw cards
  if cDk and cDk.type=='Deck'and cDk.getQuantity()>=p.draw then
    cDk.deal(p.draw,p.color)
  elseif cDk then
    -- alert player this may take some time
    if cDk.type=='Deck'then
      cDk.deal(p.draw,p.color)
    elseif cDk.type=='Card'and p.draw>0 then
      --Put that card in the hand
      cDk.setRotation({0,180,0})
      cDk.setPosition(Player[p.color].getHandTransform().position)
    end end delay('reshuffleDiscard',p)end
function reshuffleDiscard(p)
  --Calculate Remaining
  p.draw=p.draw-#Player[p.color].getHandObjects()
  if p.draw>0 then
    local cDk=getDeck(p.zoneDiscard.getObjects())
    --Reshuffle Discard Pile
    if not cDk then broadcastToAll('Has something gone wrong?',p.color,{0.9,0.1,0.9})
    elseif cDk.type=='Card'then cDk.setPosition(Player[p.color].getHandTransform().position)
    elseif cDk.type=='Deck'then
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
    elseif v.type=='Deck'and v.name:find(' pile')then
      broadcastToAll('Pile found in play area!\nAssuming you bought 1 and only discarding 1',{1,0,1})
      v.setLock(true)
      local q=v.getPosition()
      q[2]=q[2]+3
      v.setPosition(q)
      v.takeObject({position=p})
    elseif v.type=='Deck'or v.type=='Card'then
      v.setScale({1.88,1,1.88})
      v.setRotation({0,180,0})
      if hand then
        v.clone({position=p})
        v.destruct()
      else
        v.setPositionSmooth(p)
end end end end
function delay(N,t)local p={function_name=N,identifier=N..t.color..'PA',parameters=t,delay=2}Timer.destroy(p.identifier)Timer.create(p)end
function getDeck(z)for _,v in pairs(z)do if v.type=='Deck'or v.type=='Card'then return v end end return false end
function clean(s)return('self.setName(\'%s\')function bye(o) if o.getName():find(\'PLAY AREA\')then self.destruct()end end function onObjectDestroy(o)bye(o)end function onObjectDrop(p,o)bye(o)end'):format(s,s)end
--EOF