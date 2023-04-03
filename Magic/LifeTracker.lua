--By Amuzet
mod_name,version='LifeTracker',1
author='76561198045776458'
function updateSave()self.script_state=JSON.encode({['c']=count,['subs']=subs})end
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
      sL(count)local t=txt:format(gl,math.abs(count-C2),count)
      printToSome(t,self.getColorTint())log(t)
      C2=nil end return 1 end
  startLuaCoroutine(self,'clickCoroutine')
  updateSave()
end end

local lCheck={
  ['everyone_loses_']=function(n,c)return count-n,'made everyone lose'end,
  ['opponents_lose_']=function(n,c)if c~=owner then return count-n else return count,'opponents lost'end end,
  ['reset_life_']=function(n,c)return n,'reset Life totals to'end,
  ['double_my_life_']=function(n,c)if c==owner then return count*2^n,'doubled their life this many times'end end,
  ['set_life_']=function(n,c)if c==owner then return n,'Life total changed by '..math.abs(n-count)..'. Setting it to'end end,
  ['drain_']=function(n,c)if c==owner then return count+n,'drained everyone for'else return count-n,false,true end end,
  ['extort_']=function(n,c)if c==owner then for _,p in pairs(Player.getPlayers())do if p.seated and p.color~=owner and subs[p.color] then count=count+n end end return count,'extorted everyone for'else return count-n,false,true end end,
  -- ['test_']=function(n,c)return count end,
}

function colorToggleSubscribe(c)
  subs[c] = not subs[c]
  if subs[c] then printToColor(c..' subscribed to '..self.getDescription(), c) else printToColor(c..' unsubscribed from '..self.getDescription(), c) end
end
function printToSome(text,tint)
  for _, c in ipairs({'White','Blue','Red','Purple','Pink','Green','Orange','Yellow','Teal','Brown'}) do if subs[c] then printToColor(text,c,tint) end end
end
function onChat(msg,player)
  if msg:find('[ _]%d+')then
    if not subs[player.color] then return true end
    local m=msg:lower():gsub(' ','_')
    local a,sl,t,n=false,false,'',tonumber(m:match('%d+'))
    
    for k,f in pairs(lCheck)do
      if m:find(k..'%d+')then
        a,t,sl=f(n,player.color)
        if a then if sl then sL(count,n)end count=a break
        else return msg end end end
    
    updateSave()
    if t and t~=''then
      printToSome(player.color..'[999999] '..t..' [-]'..n,self.getColorTint())
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
  if s~=''then local ld=JSON.decode(s);count=ld.c;subs=ld.subs else count=0;subs={White=true,Blue=true,Red=true,Purple=true,Pink=true,Green=true,Orange=true,Yellow=true,Teal=true,Brown=true} end
  self.createButton({tooltip='Click to increase\nRight click to decrease',click_function='option',function_owner=self,label='\n'..count..'\n',
      position={-x,0,0},scale={0.60,1,0.60},height=800,width=2100,font_size=2000,rotation={0,90,0},color=g,font_color=clr})
  for i,v in ipairs({{n=1,l='+',p={0,y,z}},{n=-1,l='-',p={0,y,-z}}})do
    local fn='valueChange'..i
    self.setVar(fn,function(o,c,a)local b=1 if a then b=5 end click_changeValue(o,c,v.n*b)end)
    self.createButton({tooltip='Right-click for '..v.n*5,label=v.l,position=v.p,click_function=fn,function_owner=self,height=500,width=500,font_size=700,rotation={0,90,0},color=g,font_color=clr})
  end
  for i,v in pairs({{'^Exile^',0},{'^Deck^',4.2},{'^Graveyard^',8.3,250}})do
    self.createButton({label=v[1],position={-(16.4+v[2]),0,0},rotation={0,90,0},font_size=v[3]or 500,width=0,height=0,font_color=self.getColorTint(),click_function='none',function_owner=self})end
  for k,_ in pairs(lCheck)do
    local m=k:gsub('_',' ')..'X'
    self.addContextMenuItem(m,function(p)if p~=owner then return end mode=k
        self.createInput({position={-x*2,y,0},input_function='ipt',function_owner=self,tooltip=m..' Input\nOwner`s final edit will be used.',alignment=3,validation=2,width=500,height=323,font_size=300,rotation={0,90,0},color=g,font_color=clr})
      end)end
  self.addContextMenuItem('Toggle Life Alerts', colorToggleSubscribe, false)
end
function ipt(o,p,v,s)
  if not s and p==owner then
    onChat(mode..v,{color=p})
    self.clearInputs()
  end
end
mode,ref_type,owner,x,y,z,g,C2='','','',1.1,0.2,0.7,{0.1,0.1,0.1},nil