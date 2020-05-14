function updateSave()self.script_state=JSON.encode({['c']=count})end
function wait(t)local s=os.time()repeat coroutine.yield(0)until os.time()>s+t end
function baker()count=1 self.editButton({index=0,label=count})updateSave()end
function getCount()return count end
function setOwner(params)
  owner,count=params[1],count+params[2]
  self.editButton({index=0,label=count})
  updateSave()
end
function onload(s)
  --Loads the tracking for if the game has started yet
  if s~=''then local ld=JSON.decode(s);count=ld.c else count=0 end
  rType,owner=self.getName(),self.getDescription()
  local a,b=0.9,{click_function='none',function_owner=self,label=count,position={0,0.1,0},scale={0.8,0.8,0.8},height=0,width=0,font_size=1500,color={0,0,0}}
  if rType=='Owns Project'then b.position[2]=0.7 else a,b.scale=1.3,{1.1,1.1,1.1}end

  self.createButton(b)
  b.height,b.width,b.font_size,b.font_color=450,600,1000,stringColorToRGB(owner)
  for i,v in pairs({{val=1,label='+',pos={0,b.position[2],-a}},{val=-1,label='-',pos={0,b.position[2],a}}})do
    b.click_function='valueChange'..i
    self.setVar(b.click_function,function(o,c)click_changeValue(o,c,v.val)end)
    b.position,b.label=v.pos,v.label
    self.createButton(b)
  end
end
function click_changeValue(obj, color, val)
  local C3=count
  if count+val>=0 then count=count+val else count=0 end
  local C1=count
  function clickCoroutine()
    if C2==nil then C2=C3 end
    wait(3)
    if C1==count and C2~=nil then
      local txt,n=owner..' %s %s '..rType..'.',math.abs(count-C2)
      if n~=1 then txt=txt:gsub('s%.','.')end
      if C1>C2 then
        txt=txt:format('gains',n)
      elseif C1<C2 then
        txt=txt:format('loses',n)end
      if C1~=C2 then printToAll(txt, {1,1,1})end
      C2=nil
    end return 1 end
  startLuaCoroutine(self,'clickCoroutine')
  self.editButton({index=0,label=count})
  updateSave()
end
p=self.getPosition()
self.setPosition({p[1],1.1,p[3]})
self.setRotation({0,180,0})
rType,owner,C2='Test','White',nil