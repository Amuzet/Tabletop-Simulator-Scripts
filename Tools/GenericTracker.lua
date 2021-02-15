--By Amuzet
mod_name,version='GenericTracker',1
author='76561198045776458'
function updateSave()self.script_state=JSON.encode({['c']=count})end
function wait(t)local s=os.time()repeat coroutine.yield(0)until os.time()>s+t end
function sL(l,n)self.editButton({index=0,label='\n'..l..'\n'..(n or'')})end
function option(o,c,a)
  local n=1
  if a then n=-n end
  click_changeValue(o,c,n)
end
function click_changeValue(obj, color, val)
  if color==owner or Player[color].admin then
  local C3=count
  count=count+val
  local C1=count
  function clickCoroutine()
    if not C2 then C2=C3 end
    sL(count,(count-C2))
    wait(3)
    if C2 and C1==count then
      local gl='lost'
      if C1>C2 then gl='gained'end
      if C1~=C2 then sL(count)local t=txt:format(gl,math.abs(count-C2),count)
        printToAll(t,self.getColorTint())log(t)end
      C2=nil end return 1 end
  startLuaCoroutine(self,'clickCoroutine')
  updateSave()
end end

local lCheck={
  ['everyone_loses_']=function(n,c)return count-n,'made everyone lose'end,
  ['opponents_lose_']=function(n,c)if c~=owner then return count-n else return count,'opponents lost'end end,
  ['reset_total_']=function(n,c)return n,'reset '..ref_type..'totals to'end,
  ['double_this_']=function(n,c)if c==owner then return math.floor(count*2^n),'doubled their '..ref_type..' this many times'end end,
  ['set_total_']=function(n,c)if c==owner then return n,ref_type..' total changed by '..math.abs(n-count)..'. From '..count..' to'end end,
  -- ['test_']=function(n,c)return count end,
}

function onChat(msg,player)
  if msg:find('[ _-]%d+')then
    local m=msg:lower():gsub(' ','_')
    local a,sl,t,n=false,false,'',tonumber(m:match('[-%.%d]+'))
    
    for k,f in pairs(lCheck)do
      if m:find(k..'[-%.%d]+')then
        a,t,sl=f(n,player.color)
        if a then if sl then sL(count,n)end count=a break
        else return msg end end end
    
    updateSave()
    if t and t~=''then
      printToAll(player.color..'[999999] '..t..' [-]'..n,self.getColorTint())
      sL(count,count-JSON.decode(self.script_state).c)
      return false end
end end
function onload(s)
  --Loads the tracking for if the game has started yet
  owner=self.getDescription()
  ref_type=self.getName():gsub('%s.+','')
  txt=owner..' [888888]%s %s '..ref_type..'.[-] |%s|'
  local clr=stringColorToRGB(owner)
  self.setColorTint(clr)
  if s~=''then local ld=JSON.decode(s);count=ld.c else count=0 end
  self.createButton({tooltip=ref_type..'\nClick to increase\nRight click to decrease',click_function='option',function_owner=self,label='\n'..count..'\n',
      position={-x,y,0},scale={0.60,1,0.60},height=800,width=2100,font_size=2000,color=g,font_color=clr})
  for i,v in ipairs({{n=1,l='+',p={0,y,-z}},{n=-1,l='-',p={0,y,z}}})do
    local fn='valueChange'..i
    self.setVar(fn,function(o,c,a)local b=1 if a then b=5 end click_changeValue(o,c,v.n*b)end)
    self.createButton({tooltip='Right-click for '..v.n*5,label=v.l,position=v.p,click_function=fn,function_owner=self,height=500,width=500,font_size=700,color=g,font_color=clr})
  end
  for k,_ in pairs(lCheck)do
    local m=k:gsub('_',' ')..'X'
    self.addContextMenuItem(m,function(p)if p~=owner then return end mode=k
        self.createInput({position={-x,y,-z*2},label=k:gsub('_.*',''),input_function='ipt',function_owner=self,tooltip=m..' Input\nOwner`s final edit will be used.',alignment=3,validation=2,width=1000,height=323,font_size=300,color=g,font_color=clr})
      end)end
end
function ipt(o,p,v,s)
  if not s and p==owner then
    onChat(mode..tonumber(v),{color=p})
    self.clearInputs()
  end
end
mode,ref_type,owner,x,y,z,g,C2='','','',2,0.2,0.7,{0.1,0.1,0.1},nil