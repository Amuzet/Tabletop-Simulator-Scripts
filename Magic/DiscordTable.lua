function none()end local Tables,T,B,HelpText={},{
    --The color name must be exactly the same as the player hands
    --z=deck,u=untaparea,c=hexcolor,g=graveyard,d=instancedDeck
    White ={z='166036',u='8b3401',c='FFFFFF',g='4afe33',d=false},
    Yellow={z='2365d0',u='c20e3f',c='E6E42B',g='fd747d',d=false},
    Red   ={z='409503',u='7cffe1',c='DA1917',g='572da6',d=false},
    Purple={z='60bfe2',u='b63e9c',c='30B22A',g='bc9f0b',d=false},
    Blue  ={z='033b34',u='129eaa',c='9F1FEF',g='f2d8a4',d=false},
    Green ={z='c04462',u='56cd9d',c='1E87FF',g='51a780',d=false},
    --[[10 Player Table
    Brown ={z='c73837',u='e251e4',c='DA1917',g='9fbce4',d=false},
    Orange={z='59683d',u='981f1c',c='30B22A',g='3be8c4',d=false},
    Pink  ={z='4f664b',u='5d441f',c='9F1FEF',g='013729',d=false},
    Teal  ={z='1177d3',u='fc6e17',c='1E87FF',g='08704e',d=false},]]
    },
  setmetatable({function_owner=Global,position={0,-0.1,0},width=600,height=600,font_size=300,alignment=3,validation=2,value=0},
    {__call=function(b,o,l,t,p,f)b.position,b.label,b.tooltip,b.click_function=p or b.position,l,t or'',f or'none'o.createButton(b)end}),
[[ [b]These commands can be input into chat.
[i](10 can be any number)[/i][/b]

[854FD9][b]Scryfall help[/b][-]
Displays all commands for "Card Importer", extra detail in "SHelp" Tab.

[55af00][b]Everyone loses 10[/b][-]
Makes everyone lose that much life.                                                      

[55af00][b]Opponents lose 10[/b][-]
Makes everyone else lose that much life. [i]Even teammates[/i]                   

[55af00][b]Drain 10[/b][-]
You gain # life, everyone else loses that much life.                                              

[55af00][b]Extort 10[/b][-]
Everyone else loses that much life, you gain the life lost that way.                    

[55af00][b]Set Life 10[/b][-]
Sets your life total, and outputs the difference.                                                 

[55af00][b]Reset Life 10[/b][-]
SETS ALL PLAYERS LIFE TOTAL, used to restart the game without reloading.

[55af00][b]Double My Life 1[/b][-]
Doubles your life total.                                                                            ]]

Txt=setmetatable({type='3DText',position={0,2,0},rotation={90,0,0},previous=false},
  {__call=function(t,text,f)
      local o=spawnObject(t)
      o.TextTool.setValue(text)
      o.TextTool.setFontSize(f or 80)
      return function(s)if o then if s then o.TextTool.setValue(s)else o.destruct()t.previous=false end end end end})
--[[Discord Table Rewrite]]
function onload()
  local d,i='[%s]%s %s %s[-]',0
  for k,v in pairs(T)do
    local zone=getObjectFromGUID(v.z)
    if zone then if zone.tag~='Scripting'then
      print(d:format(v.c,v.z,k,zone.tag))
      else i=i+1 end end end
  Notes.editNotebookTab({index=0,title='Table Commands',body=HelpText:gsub('%s%s+\n','\n')})
  
  addContextMenuItem('Hand Counts',function(c)
      local s,g='Cards in Hands:',' [%s]%s[-]'
      for _,p in pairs(Player.getPlayers())do
        local n=#p.getHandObjects()
        if n<10 then n='0'..n end
        s=s..g:format(T[p.color].c,n)end
      Player[c].broadcast(s..'[-]',{0.7,0.7,0.7})end)
  
  addContextMenuItem('Have A Response',function(c)
      broadcastToAll(Player[c].steam_name..' Has A Response!',stringColorToRGB(c))end)
  
  addContextMenuItem('Could you not',function(c)
      broadcastToAll(Player[c].steam_name..' asks [999999]"Could you not"[-]',stringColorToRGB(c))end)
  
  addContextMenuItem('Table Commands',function(c)
      if Txt.previous then Txt.previous()end
      Txt.position=getObjectFromGUID(T[c].u).getPosition()
      Txt.position[3]=Txt.position[3]-(getObjectFromGUID(T[c].g).getPosition()[3]-Txt.position[3])
      Txt.rotation[2]=Player[c].getHandTransform().rotation[2]
      Txt.previous=Txt(HelpText:gsub('-]\n','-] '))end)
  
  Timer.create({function_name='surfaceSetup',identifier='surfaceLoad',delay=2})
  B.font_size=500
  for i,o in pairs(getAllObjects())do
    if o.getName():find('UNINTERACTABLE')then
      o.interactable=false
      if o.getName():find('Table%w+')then
        table.insert(Tables,o.getGUID())end end
    if o.getName():find('%d+ Commander Zone')then
      B.scale,B.color,B.font_color,B.width,B.height={0.5,1,0.5},{0,0,0},o.getColorTint(),700,400
      B(o,o.getName():match('%d+'),'Times Cast\nRight Click to set to Zero',{0,0.21,0.8},'edh')
    elseif o.getName():find('%d+ %w')then cnt(o)
    elseif o.getName():find('%w+ Draw')then enc(o,'Draw')
    elseif o.getName():find('%w+ Scry')then enc(o,'Scry')
end end end
function onObjectSpawn(o)
  if o.tag~='Card'and(o.getName():find('%d+ %w+ Mana')or o.getName():find('%d+ Damage'))then
    cnt(o)end end
function surfaceSetup()for i,g in pairs(Tables)do if i~=2 then surfaceMini(getObjectFromGUID(g))end end end
function surfaceMini(o)
  local n,p,q,f=o.getName():gsub(' U.*',''),{60,-5,0},{0,6,0},{0,0,0}
  if T.Pink then p[1]=95 end
  local i=0
  for line in o.getDescription():gmatch('{[^}]+}')do i=i+1
    if i==3 then local x,y,z=string.match(line,'([^,{]+), ([^,]+), ([^}]+)')
    o.setScale({tonumber(x),tonumber(y),tonumber(z)})
  end end
  local offset={0,1,0}
  offset[2]=o.getBounds().offset[2]
  if offset[2]==-9.75 then p[2]=-6.5;offset[2]=40 end
  o.setScale(o.getScale()*0.1)
  for i,g in pairs(Tables)do
    if g==o.getGUID()then
      p[3]=(i-2)*8
      o.setPosition(p)
      break end end
  B.scale,B.width={10,1,10},2600
  B(o,n,n..'\nSwap to this table',offset,'surfaceSwap')
end
function surfaceSwap(o,c,a)
  for _,g in pairs(Tables)do
    local j=getObjectFromGUID(g)
    if j.getPosition()[1]<1 then
      surfaceMini(j)break end end
  local i=0
  o.clearButtons()
  for line in o.getDescription():gmatch('{[^}]+}')do i=i+1
    local x,y,z=string.match(line,'([^,{]+), ([^,]+), ([^}]+)')
    local t={tonumber(x),tonumber(y),tonumber(z)}
    if i==1 then o.setPositionSmooth(t)
    elseif i==3 then o.setScale(t)
end end end
function cnt(o)
  o.clearButtons()
  local n,t=o.getName():match('(%d+)(.*)')
  B.color,B.font_color,B.scale,B.width,B.height={0,0,0},o.getColorTint(),{0.9,1,0.9},0,0
  B(o,n,nil,{0,0.1,0})
  B.width,B.height=500,500
  B(o,'@','[b]'..t..'[/b]\nLeft CLick Increase\nRight Click Decrease',{0,0,0},'cdi')
end
function edh(o,c,a)local n=tonumber(o.getButtons()[1].label)+1 if a then n=0 end o.editButton({index=0,label=n})end
function dec(o,c,a)cng(o,a,-1,-5)end function inc(o,c,a)cng(o,a,1,5)end function cdi(o,c,a)cng(o,a,1,-1)end
function cng(o,a,x,y)local b=x if a then b=y end b=tonumber(o.getButtons()[1].label)+b;o.editButton({index=0,label=b})o.setName(o.getName():gsub('%-?%d+',b))end
function enc(o,s)
  local k=o.getName():match('%w+')
  o.setColorTint(stringColorToRGB(k))
  B.color,B.width,B.height={0,0,0,0},1600,1600
  B(o,'@',k,{0,-0.1,0},'cf_'..s)end
  
function cf_Draw(j,p)
  local c=j.getName():match('%w+')
  Player[p].broadcast('Press # keys on a deck to draw # cards\nExample: 3 will draw 3 cards\n 5,5 will draw 55 cards NOT 10')
  if T[c].d and false then
    local b,h,ot=1,0,getObjectFromGUID(T[c].z).getObjects()
    for i,o in pairs(ot)do
      if o.getPosition()[2]>h and(o.tag=='Card'or o.tag=='Deck')then
        b,h=i,o.getPosition()[2]end end
    if h==0 then elseif ot[b].tag=='Deck'then ot[b].deal(1,p)
    else ot[b].setPosition(Player[p].getHandTransform().position)end
end end
function cf_Scry(o,p)
  local c=o.getName():match('%w+')
  Player[c].broadcast('Quickly click and drag off the top of your deck cards to scry\nThen holding SHIFT+ALT you may look at the other side without revealing it.')
  if T[p].d and false then T[p].d.takeObject({index=0}).setPosition(Player[p].getHandTransform(2))end end
function onPlayerTurn(ply)if ply then
  for _,g in pairs(Tables)do
    if getObjectFromGUID(g)then
      getObjectFromGUID(g).setColorTint(stringColorToRGB(ply.color))
  end end
  local t={U='[b]Upkeep Triggers[/b]',
    d=0,D='[b]Damage During Upkeep[/b]',
    c=1,C='[b]Draw Step: %d [/b]',
    l=1,L='[b]Land Drop: %d [/b]'}
  
  for p,z in pairs(T)do
    for _,o in pairs(getObjectFromGUID(z.u).getObjects())do
      if o.tag=='Card'and not o.is_face_down then
        local m,d=o.getName():gsub('\n.*',''),o.getDescription()
        local n=m:lower():gsub('%A','')
        if d~=''then
          if d:find('Each player may play %w+ additional land%w? on each of')then t.l=t.l+1 end
          if d:find('You may play %w+ additional land%w? on each of your turns.')and p==ply.color then
            if d:find(' two ')then t.l=t.l+2 else t.l=t.l+1 end end
          if d:find('Players can\'t draw cards')then
            t.C=t.C:gsub('].+:',']Players cannot draw cards!')end
          if d:find('At the beginning of your[^u\n]+upkeep,')and p==ply.color then
            t.U=t.U..'; '..m end
          if d:find('At the beginning of each[^u\n]+upkeep,')then
            local check=d:match('At the beginning of each[^u\n]+upkeep, ([^\n]+)')
            if check:find('%d+ damage to that player')then
              if check:find('opponent')and p~=ply.color then
              t.d=t.d+tonumber(check:match('%d+  damage to that player'))end
            else t.U=t.U..'; '..m end end
          if d:find('At the beginning of each[^u\n]+draw step, ([^\n]+)')then
            local check=d:match('At the beginning of each[^u\n]+draw step, ([^\n]+)')
            if n=='wellofideas'and p==ply.color then t.c=t.c+2
            elseif check:find('an additional card')then t.c=t.c+1
            elseif check:find('two additional cards')then t.c=t.c+2
            else t.C=t.C..m end end
  end end end end
  
  t.C=t.C:format(t.c)
  t.L=t.L:format(t.l)
  local c=stringColorToRGB(ply.color)
  for k,v in pairs(t)do if type(v)=='string'and(v:find(';')or(k=='C'and not v:find(' 1 ')))then
    ply.broadcast(v,c)
  end end
end end
--Context Object
local M=setmetatable({function_owner=Global,position={0,-0.35,-0.7},color={0,0,0},rotation={0,0,180},width=900,height=250,font_size=120,alignment=3,validation=2,value=0},
    {__call=function(b,o,l,t,p,f)b.position,b.label,b.tooltip,b.click_function=p or b.position,l,t or'',f or'none'o.createButton(b)end})
function mtgContext(o,p)
  o.setName(Player[p].steam_name)
  o.hide_when_face_down=false
  o.clearContextMenu()
  o.highlightOn(stringColorToRGB(p))
  for k,v in pairs({Lands='Click to cycle modes.\nRight click to .',Scry='Takes the top X cards and places them in a pile.',Cascade='Will search this deck for the first nonland card with CMC less than X.'})do
    o.addContextMenuItem(k..' X',function(p)
        M.font_color=stringColorToRGB(p)
        M.tooltip=v
        
        M.position[3]=-0.7
        M(o,'Cancel '..k,nil,nil,'cB')
        
        M.position[3]=0.7
        M(o,k..' for 0',nil,nil,'c'..k)
        
        M.label='0'
        M.input_function='i'..k
        M.position[3]=0
        M.font_size=200
        M.width=M.height
        o.createInput(M)
        M.width=900
        M.font_size=120 end)end end
function cB(o,p,a)o.setLock(false)o.clearButtons()if o.getInputs()then o.clearInputs()end end
function oS(o)o.setLock(true)
  local p,b,r,f,t=o.getPosition(),o.getBounds().size,o.getTransformRight(),o.getTransformForward(),{flip=true}
  t.position={(b.x+0.1)*(r.x+f.x)+p.x,p.y,(b.z+0.1)*(r.z+f.z)+p.z}return o.getInputs()[1].value,t end
--Scry
function iScry(o,p,v,s)if not s then o.editButton({index=1,label='Scry for '..v})end end
function cScry(o,c,a)local x,t=oS(o);t.flip=false
  for i=1,x do o.takeObject(t)end
  printToAll('Scry '..x,stringColorToRGB(c))
cB(o)end
--Lands
function iLands(o,p,v,s)if not s then o.editButton({index=1,label='Lands for '..v})end end
function cLands(o,c,a)
  if a then
    local x,t=oS(o);t.flip,t.index=false,x
    o.takeObject(t)
    printToAll('NotImplemented'..o.getButtons()[2].label,stringColorToRGB(c))
  else
    
  end
cB(o)end
--Cascade
function iCascade(o,p,v,s)if not s then o.editButton({index=1,label='Cascade for '..v})end end
function cCascade(o,c,a)local x,t=oS(o)
  printToAll('Cascade for '..x,stringColorToRGB(c))
  for _,v in pairs(o.getObjects())do
    if not v.name:find('CMC')then cB(o)
      if v.name==''then
        Player[c].broadcast('Auto Cascade Stopped: Card not named!')
      else
        Player[c].broadcast('Auto Cascade Stopped: Spell not Costed!\nClick Button to make a decklist of your deck in a new notebook tab.\nRight click to dismiss.')
        M.label='Add CMC to Deck'
        M.click_function='cDeckList'
        M.tooltip='Click to make a decklist of your deck in a new notebook tab.\nRight click to dismiss.'
        M.position[3]=0
        o.createButton(M)
      end return true
    elseif not v.name:find('Land')and tonumber(v.name:match(' (%d+)CMC'))<tonumber(x) then t.flip=not t.flip break
    else o.takeObject(t)end end
    cB(o)o.takeObject(t)end
function cDeckList(o,c,a)
  if o.tag=='Deck'and not a then
    o.setLock(true)
    local t,p={title=o.getName()..' '..o.getGUID(),body=''},o.getPosition()
    p[3]=p[3]+3
    for _,d in pairs(o.getObjects())do
      if d.name~=''then
        local name=d.name:gsub('[\n].*','')
        o.takeObject({position=p})
        if t[name]then t[name]=t[name]+1 else t[name]=1 end end end
    for k,d in pairs(t)do if k~='title'or k~='body'then t.body=t.body..d..' '..k..'\n'end end
    addNotebookTab(t)
    Player[c].broadcast('Deck list in NotebookTab: '..t.title..'\n"Scryfall deck" to spawn deck with CMC',{0.8,0.8,0.8})end
cB(o)end