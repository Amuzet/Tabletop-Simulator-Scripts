local btn={function_owner=self,rotation={0,0,180},font_size=120,width=250,height=250,alignment=3,validation=2,value=0,color={0,0,0}}
local Zn={White={z='166036',h='FFFFFF'},Yellow={z='2365d0',h='E6E42B'},Red={z='409503',h='DA1917'},Green={z='c04462',h='30B22A'},Purple={z='033b34',h='9F1FEF'},Blue={z='60bfe2',h='1E87FF'}}
local player='White'
function onLoad()
  
  local d,i='[%s]%s %s %s[-]',0
  for k,v in pairs(Zn)do
    local zone=getObjectFromGUID(v.z)
    if zone then if zone.tag~='Scripting'then
      print(d:format(v.h,v.z,k,zone.tag))else i=i+1 end end end
  
  addContextMenuItem('Clear Context',function(c)if Player[c].admin then clearContextMenu()end end)
  addContextMenuItem('Get Hand Count',function(c)
      local s,g='[888888]Cards in Hands:',' [%s]%s[-]'
      for _,p in pairs(Player.getPlayers())do
        local n=#p.getHandObjects()
        if n<10 then n='0'..n end
        s=s..g:format(Zn[p.color].h,n)
      end
      Player[c].broadcast(s..'[-]',{1,1,1})
    end)
end
function onObjectEnterScriptingZone(z,o)
  if o.tag=='Deck'and #o.getObjects()>30 then for k,v in pairs(Zn)do if z.getGUID()==v.z then
      mtgContext(o,k)
end end end end
function onCollisionEnter(info)if info.collision_object.tag=='Deck'then mtgContext(info.collision_object)end end
function onDrop(p)player=p end
--Context Object
function mtgContext(Obj,p)
  Obj.hide_when_face_down=false
  Obj.clearContextMenu()
  Obj.highlightOn(stringColorToRGB(p or player))
  for _,s in pairs({'Scry','Cascade'})do
    Obj.addContextMenuItem(s..' X',function(p)
        local h=Obj.getBounds().size.y
        btn.font_color=stringColorToRGB(p)
        btn.width=900
        
        btn.label='Cancel '..s
        btn.click_function='cB'
        btn.position={0,-h/2,-0.7}
        Obj.createButton(btn)
        
        btn.label=s..' for 0'
        btn.click_function='c'..s
        btn.position[3]=0.7
        Obj.createButton(btn)
        
        local bfs=btn.font_size
        btn.label='0'
        btn.input_function='i'..s
        btn.position[3]=0
        btn.font_size=200
        btn.tooltip='Will search this deck for the first spell of this CMC or less.'
        btn.width=btn.height
        Obj.createInput(btn)
        btn.font_size=bfs end)
end end
function cB(o,p,a)o.clearButtons()if o.getInputs()then o.clearInputs()end end
--Scry
function iScry(o,p,v,sE)if not sE then o.editButton({index=1,label='Scry for '..v})end end
function cScry(o,P,a)
  o.setLock(true)
  local x,p,b,r,f,t=o.getInputs()[1].value,o.getPosition(),o.getBounds(),o.getTransformRight(),o.getTransformForward(),{}
  t.position={(b.size.x*(r.x+f.x))+p.x,b.center.y,(b.size.z*(r.z+f.z))+p.z}
  for i=1,x do o.takeObject(t)end
  printToAll('Scry '..x,stringColorToRGB(p))
  cB(o)end
--Cascade
function iCascade(o,p,v,sE)if not sE then o.editButton({index=1,label='Cascade for '..v})end end
function cCascade(o,P,a)
  o.setLock(true)
  local x,p,b,r,f,t=o.getInputs()[1].value,o.getPosition(),o.getBounds(),o.getTransformRight(),o.getTransformForward(),{flip=true}
  t.position={(b.size.x*(r.x+f.x))+p.x,b.center.y,(b.size.z*(r.z+f.z))+p.z}
  
  for i,v in ipairs(o.getObjects())do
    o.takeObject(t)
    if not v.name:find('CMC')then
      if v.name==''then
        Player[P].broadcast('Card not named!\nAuto Cascade Stopped.')
      else
        v.name=v.name:gsub('\n.*',''):gsub(' //.*','')
        Player[P].broadcast('Card not Costed!\nAuto Cascade Stopped.')
        --WebRequest.get()
      end
      break
    elseif v.name:find('%s%d+CMC')then
      if v.name:match('(%d+)CMC')<x and not v.name:find('Land')then break end
    end
  end
  o.setLock(false)
  cB(o)
end