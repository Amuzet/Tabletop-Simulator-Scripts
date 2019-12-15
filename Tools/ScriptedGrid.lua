--By Amuzet
self.setRotation({0,0,0})
local bY,object = 0.5,false
Button = setmetatable({click_function='click',function_owner=self,label='+',position={0,bY,0},scale={0.45,0.45,0.45},width=400,height=400,font_size=380,tooltip='De Script'},{
    __call=function(t,tbl)
        if tbl then for k,v in pairs(tbl)do
            if k=='position' then t[k]={v[1]*0.3,v[2],v[3]*0.3}
            else t[k]=v end
        end end
        self.createButton(t)
    end})

function onCollisionEnter(info)
  local object = info.collision_object
  if object.tag ~= 'Surface' then
    object.highlightOn({0,1,0},100)
    local s,bnd = 1,object.getBounds().size
    if bnd.x > bnd.z then
      s=bnd.x
    else
      s=bnd.z
    end
    
    self.setScale({s/2,0.05,s/2})
  end
end

function dupe(x,z)

end

function click()
  self.setLock(true)
  local a,pos,size = 10,self.getPosition(),self.getBounds().size
  size.x = math.ceil( size.x*a )/a
  size.z = math.ceil( size.z*a )/a
  for i=pos.x, object.getPosition().x,
    
    local obj = self.clone({position={
          pos.x + size.x
          }})
    obj.setLuaScript('')
  end
  self.setLuaScript('')
  self.clearButtons()
end
--EOF