function none()end local T,B={Red={z='409503',c='DA1917'},Yellow={z='2365d0',c='E6E42B'},White={z='166036',c='FFFFFF'},Green={z='60bfe2',c='30B22A'},Purple={z='033b34',c='9F1FEF'},Blue={z='c04462',c='1E87FF'}},
  setmetatable({function_owner=Global,position={0,-0.1,0},width=600,height=600,font_size=300,alignment=3,validation=2,value=0},
    {__call=function(b,o,l,t,p,f)b.position,b.label,b.tooltip,b.click_function=p or b.position,l,t or'',f or'none'o.createButton(b)end})
--Discord Table Rewrite
function onload()
  local d,i='[%s]%s %s %s[-]',0
  for k,v in pairs(T)do
    local zone=getObjectFromGUID(v.z)
    if zone then if zone.tag~='Scripting'then
      print(d:format(v.c,v.z,k,zone.tag))
      else i=i+1 end end end
  
  addContextMenuItem('Hand Counts',function(c)
      local s,g='Cards in Hands:',' [%s]%s[-]'
      for _,p in pairs(Player.getPlayers())do
        local n=#p.getHandObjects()
        if n<10 then n='0'..n end
        s=s..g:format(T[p.color].c,n)end
      Player[c].broadcast(s..'[-]',{0.7,0.7,0.7})end)
  
  for c,g in pairs(T)do
    self.setVar('Draw'..c,function(_,p)if T[p].d then T[p].d.deal(1,c)end end)
    self.setVar('Scry'..c,function(_,p)if T[p].d then T[p].d.takeObject({index=0}).setPosition(Player[p].getHandTransform(2))end end)end
  B.font_size,B.scale=1200,{0.5,1,0.5}
  for i,o in pairs(getAllObjects())do
    if o.getName()=='UNINTERACTABLE'then o.interactable=false
    elseif o.getName():find('%w+ Draw')then a(o,'Draw')
    elseif o.getName():find('%w+ Scry')then a(o,'Scry')
    elseif o.getName()=='Commander Zone'then
      B.color,B.font_color,B.width,B.height=o.getColorTint(),o.getColorTint(),1200,300
      B(o,'0\n\n','Times Cast\nRight Click to set to Zero',{0,0.21,0.8},'edh')
    elseif o.getName():find('%d+ %w')then
      local n=o.getName():match('%d+')
      B.color,B.font_color,B.scale,B.width,B.height={0,0,0},o.getColorTint(),{0.9,1,0.9},0,0
      B(o,n,nil,{0,0.1,0})
      B.scale,B.width,B.height={0.5,1,0.5},900,400
      B(o,'+','Right-click to Increase by 5',{0,0.1,-0.7},'inc')
      B(o,'-','Right-click to Decrease by 5',{0,0.1,0.7},'dec')
  end end
  B.position={0,-0.35,-0.7}
  B.rotation={0,0,180}
  B.scale={1,1,1}
  B.font_size=120
  B.height=250
  B.width=900
end
function edh(o,c,a)local n=tonumber(o.getButtons()[1].label)+1 if a then n=0 end o.editButton({index=0,label=n..'\n\n'})end
function dec(o,c,a)cng(o,a,-1,-5)end function inc(o,c,a)cng(o,a,1,5)end function cdi(o,c,a)cng(o,a,1,-1)end
function cng(o,a,x,y)local b=x if a then b=y end o.editButton({index=0,label=tonumber(o.getButtons()[1].label)+b})end
function a(o,s)
  local k=o.getName():match('%w+')
  o.setColorTint(stringColorToRGB(k))
  B.font_color,B.width,B.height=o.getColorTint(),600,600
  B(o,'@',s,{0,-0.1,0},s..k)end
function onObjectEnterScriptingZone(z,o)
  if o.tag=='Deck'and o.is_face_down then
    for k,c in pairs(T)do if z.getGUID()==c.z then
    mtgContext(o,k)T[k].d=o end end
end end
--Context Object
function mtgContext(o,p)
  o.setName(Player[p].steam_name)
  o.hide_when_face_down=false
  o.clearContextMenu()
  o.highlightOn(stringColorToRGB(p))
  for s,v in pairs({Lands='Click to cycle modes.\nRight click to .',Scry='Takes the top X cards and places them in a pile.',Cascade='Will search this deck for the first nonland card with CMC less than X.'})do
    o.addContextMenuItem(s..' X',function(p)
        B.font_color=stringColorToRGB(p)
        B.tooltip=v
        
        B.label='Cancel '..s
        B.click_function='cB'
        B.position[3]=-0.7
        o.createButton(B)
        
        B.label=s..' for 0'
        B.click_function='c'..s
        B.position[3]=0.7
        o.createButton(B)
        
        B.label='0'
        B.input_function='i'..s
        B.position[3]=0
        B.font_size=200
        B.width=B.height
        o.createInput(B)
        B.width=900
        B.font_size=120 end)end end
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
        B.label='Add CMC to Deck'
        B.click_function='cDeckList'
        B.tooltip='Click to make a decklist of your deck in a new notebook tab.\nRight click to dismiss.'
        B.position[3]=0
        o.createButton(B)
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