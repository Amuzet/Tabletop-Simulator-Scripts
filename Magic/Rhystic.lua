--By Amuzet
mod_name,version='Rhystic Block',1
author = '76561198045776458'
self.setName(mod_name..' '..version)
count=1
B=setmetatable({function_owner=self,position={0,2,0},scale={1,1,0.5},width=1600,height=800,font_size=900,alignment=3,validation=2,value=0},
    {__call=function(b,l,t,p,f)b.position,b.label,b.tooltip,b.click_function=p or b.position,l,t or'',f or'none'self.createButton(b)end})
--function none(o,c,a)if 
function onPlayerTurn(p)self.setDescription(p.color)end
function onSave()self.script_state=JSON.encode({count})end
function onLoad(s)
  if s~=''then count=JSON.decode(s)[1]end
  B(count,'Increase Number\nRight Click\nDecrease Number',nil,'cng')
end
function onDrop(c)
  local color = self.getDescription()
  self.setColorTint(color)
  Player[color].broadcast(string.format('Did You Pay %d?',count),stringColorToRGB(c))
end
function cng(o,c,a)
  if a then count=count-1 else count=count+1 end
  self.editButton({index=0,label=count})
end