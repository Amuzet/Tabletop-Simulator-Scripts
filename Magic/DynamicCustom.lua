--DynamicCustomCard
local data={name='Custom Card',type='Creature',text='Draw two cards.',pt='0/0',}
local input=setmetatable({input_function='input_func',function_owner=self,alignment=1,scale={0.5,0.5,0.5},label='Gold',font_size=100,validation=1,
  position={0,0.25,-1.3},width=1710,height=125},{__call=function(i,p,w,h,l)
      i.position[3]=p or i.position[3]
      i.width,i.height,i.label,i.value=w,h,l,data[l]
      i.input_function='input_'..l
      if l=='pt'then i.position[1],i.alignment=0.75,3 end
      self.createInput(i)
      if l=='pt'then i.position[1],i.alignment=0,1 end
    end})
function onSave(k,v,sE)
  if v and not sE then data[k]=v elseif sE then return self.script_state end
  return JSON.encode(data)end
function onLoad(d)
  if d~=''then data=JSON.decode(d)end
  input(-1.29,1710,125,'name')
  input( 0.28,1710,125,'type')
  input( 0.82,1715,810,'text')
  if data.type:find('Creature')or data.type:find('Vehicle')then input(1.3,300,125,'pt')end end

function input_name(o,c,i,sE)onSave('name',i,sE)end
function input_type(o,c,i,sE)onSave('type',i,sE)end
function input_text(o,c,i,sE)onSave('text',i,sE)end
function input_pt(o,c,i,sE)onSave('pt',i,sE)end

function setStatic()
  self.setLuaScript([[--StaticCustomCard
local B=setmetatable({click_function='none',function_owner=self,width=0,height=0,color={0,0,0,0},position={0,0.25,-1.3},font_size=100},{__call=function(b,p,l)b.label,b.position[3]=l,p;self.createButton(b)end})
function onLoad(d)if d~=''then data=JSON.decode(d)
  B(-1.29,data.name)B(0.28,data.type)B(0.82,data.text)
  if data.type:find('Creature')or data.type:find('Vehicle')then B.position[1]=0.75;B(1.3,data.pt)end
end end]])
  self.setDescription(data.text)
  local sT={json=getJSON(),position=self.getPosition()}
  for k,v in pairs(sT.position)do sT.position[k]=v+1 end
  sT.json:gsub('"Nickname": "[^"]+"',data.name..'\n'..data.type)
  spawnObject(sT)
end