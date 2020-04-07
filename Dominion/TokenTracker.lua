function updateSave()self.script_state=JSON.encode({['c']=count})end
function wait(t)local s=os.time()repeat coroutine.yield(0)until os.time()>s+t end
function baker()count=1 self.editButton({index=0,label=count})updateSave()end
function getCount()return count end
function onload(s)
  --Loads the tracking for if the game has started yet
  local y=0.05
  ref_type,owner=self.getName(),self.getDescription()
  if ref_type=='Pirate Ship Coins'or ref_type=='Villagers'then y=y*2
  elseif ref_type=='Owns Project'then y=1 end
  if s~=''then local ld=JSON.decode(s);count=ld.c else count=0 end

  self.createButton({click_function='none',function_owner=self,position={0,y+0.05,0},height=0,width=0,font_size=1500,label=count})

  for i,v in ipairs({{val=1,label='+',pos={0.8,y,-0.7}},{val=-1,label='-',pos={-0.8,y,0.7}}})do
    local fn='valueChange'..i
    self.setVar(fn,function(o,c)click_changeValue(o,c,v.val)end)
    self.createButton({click_function=fn,function_owner=self,position=v.pos,height=500,width=500,label=v.label,font_size=1000,color={1,1,1,1}})
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
      local txt,n=owner..' %s %s '..ref_type..'.',math.abs(count-C2)
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
ref_type,owner,C2='Test','White',nil