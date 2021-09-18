--DynamicCustomCard
noencode=1
local d={nm='Custom Card',ty='Creature',tx='Draw two cards.'}
local I=setmetatable({input_function='input_func',function_owner=self,alignment=1,scale={0.5,0.5,0.5},label='Gold',validation=1,
  position={0,0.25,-1.3},width=1710,height=125,font_size=90},{__call=function(i,p,w,h,l,x)
      i.position[3]=p or i.position[3]
      i.width,i.height,i.label,i.value=w,23+(100*h),'i_'..l,d[l]or nil
      i.input_function=i.label
      self.setVar(i.label,function(o,c,v,s)onSave(l,v,s)end)
      if x then i.position[1],i.alignment=x,3 end
      self.createInput(i)
      if x then i.position[1],i.alignment=0,1 end
    end})
function onSave(k,v,sE)
  if v and not sE then
    d[k]=v:gsub('"','`')
    if k=='nm'then self.setName(d[k])
    elseif k=='ty'then tyic()
    elseif k=='tx'then self.setDescription(d[k])end
  elseif sE then return self.script_state end
  self.script_state=JSON.encode(d)end
function onDrop()Timer.create({function_name='tyic',identifier=self.getGUID(),delay=1})end
function onLoad(D)
  if D~=''then d=JSON.decode(D)end
  tyic()end
function tyic()
  self.clearInputs()
  self.addContextMenuItem('Finalize Card',setStatic)
  I(-0.85,1710,1,'img')
  I(-1.29,1710,1,'nm')
  I( 0.28,1710,1,'ty')
  I( 0.82,1715,8,'tx')
  if d.ty:find('Planeswalker')then I(1.3,300,1,'lt',-0.75)end
  if d.ty:find('Creature')or d.ty:find('Vehicle')then I(1.3,300,1,'pt',0.75)end
end
function g(a)return a and '\n[b]'..a..'[/b]'or''end
function setStatic()
  local s=[[--StaticCustomCard
local B=setmetatable({click_function='N',function_owner=self,width=0,height=0,position={0,0.25,-1.3},scale={0.3,1,0.3},font_size=150},{__call=function(b,p,l)b.label,b.position[3]=l,p;self.createButton(b)end})
noencode=1;function onLoad()if self.script_state~=''then self.clearButtons()d=JSON.decode(self.script_state)B(-1.27,d.nm)B(0.28,d.ty)B(0.82,d.tx)%send end function onDrop()Timer.create({function_name='onLoad',identifier=self.getGUID(),delay=1})end function N()end]]
  local m=''
  if d.pt~=''then m=m..'B.position[1]=0.75;B(1.3,d.pt)'end
  if d.lt~=''then m=m..'B.position[1],B.width,B.height=-0.75,200,200;B(1.3,d.lt)'end
  local sT={json=self.getJSON(),position=self.getPosition()}
  for k,v in pairs(sT.position)do sT.position[k]=v+1 end
  if d.img~=''then for _,s in pairs({'.jpg','.png','.webm','.mp4'})do
    if d.img:find(s)then sT.json=sT.json:gsub('"FrontURL": "[^"]+"','"FrontURL": "'..d.img..'"')
      break end end end
  sT.json=sT.json:gsub('"Description": "[^"]+','"Description": "'..d.tx..g(d.lt)..g(d.pt)..d.img,1)
  sT.json=sT.json:gsub('"Nickname": "[^"]+','"Nickname": "'..d.nm..'\n'..d.ty,1)
  spawnObjectJSON(sT).setLuaScript(s:format(m))
end