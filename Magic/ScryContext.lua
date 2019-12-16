local btn={function_owner=self,rotation={0,0,180},font_size=120,width=250,height=250,alignment=3,validation=2,value=0,color={0,0,0}}
local Zn={White={z='166036',h='FFFFFF'},Yellow={z='2365d0',h='E6E42B'},Red={z='409503',h='DA1917'},Green={z='c04462',h='30B22A'},Purple={z='033b34',h='9F1FEF'},Blue={z='60bfe2',h='1E87FF'}}
function onLoad()
  addContextMenuItem('Get Hand Count',function(c)
      local s,g='Cards in Hands:',' [%s]%i[-]'
      for _,p in pairs(Player.getPlayers())do
        local n=#p.getHandObjects()
        if n<10 then n='_'..n end
        s=s..g:format(Zn[p.color].h,n)
      end
      Player[c].broadcast(s,{1,1,1})
      end)
end
function onObjectEnterScriptingZone(z,Obj)
  for k,v in pairs(Zn)do
    if type(v)=='table'and z.getGUID()==v.z then
end end end
--Context Object
function addContext(Obj)
  if Obj.tag=='Deck'and #Obj.getObjects()>30 then
    Obj.hide_when_face_down = false
    Obj.clearContextMenu()
    Obj.highlightOn(stringColorToRGB(k))
    Obj.addContextMenuItem('Scry 1',function(p)Obj.deal(1,p,2)end)
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
function cScry(o,p,a)local x=tonumber(o.getInputs()[1].value);o.deal(x,p,2)printToAll('Scry '..x,stringColorToRGB(p))cB(o)end
--Cascade
function iCascade(o,p,v,sE)if not sE then o.editButton({index=1,label='Cascade for '..v})end end
function cCascade(o,p,a)
  local x,deck,pos=o.getInputs()[1].value,o.getObjects(),o.getBounds()
  pos={o.getPosition().x-pos.size.x*1.2,pos.center.y,o.getPosition().z-pos.size.z*1.2}
  if deck[1].name:find('%s%d+CMC')then
    for i,v in ipairs(deck)do
      if v.name:match('(%d+)CMC')>x or v.name:find('Land')then else
        o.takeObject({position=pos,flip=true,guid=v.guid,
            callback_function=function()o.deal(i-1,p,2)end})
        break
      end
    end
  elseif deck[1].name:len()>2 then
    for i,v in ipairs(deck)do
      
    end
  else
    Player[p].broadcast('Cards not named!\nDeck cannot be Cascaded.')
  end
  cB(o)
end