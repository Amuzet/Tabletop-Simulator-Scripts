function updateSave()self.script_state=JSON.encode({['c']=count})end
function wait(t)local s=os.time()repeat coroutine.yield(0)until os.time()>s+t end
function sL(l,n)self.editButton({index=0,label='\n'..l..'\n'..(n or'')})end
function option(o,c,a)
  if c==owner or Player[c].host then
    if not display then display='On Turn'
    elseif display=='On Turn'then display='On Change'
    else display=false end
    Player[c].broadcast('Output: '..tostring(display))end end
function click_changeValue(obj, color, val)
  if color==owner or Player[color].admin then
  local C3=count
  count=count+val
  local C1=count
  function clickCoroutine()
    if C2==nil then C2=C3 end
    sL(count,(count-C2))
    wait(3)
    if C1==count and C2~=nil then
      local gl='lost'
      if C1>C2 then gl='gained'end
      if C1~=C2 then sL(count)local t=txt:format(gl,math.abs(count-C2))
        if display then printToAll(t,self.getColorTint())end log(t)end
      C2=nil end return 1 end
  if display~='On Turn'then startLuaCoroutine(self,'clickCoroutine')updateSave()
  else sL(count,count-JSON.decode(self.script_state).c)end
  end end
function onPlayerTurn()
  if display=='On Turn'then
    local gl,n='lost',count-JSON.decode(self.script_state).c
    if n>0 then gl='gained'end
    if n~=0 then printToAll('Last Turn, '..txt:format(gl,math.abs(n)))end
  end
  updateSave()
  sL(count)
end

local lCheck={
  ['_everyoneloses']=function(n,p)return count-n,'made everyone lose'end,
  ['_opponentslose']=function(n,p)if p.color~=owner then return count-n else return count,'opponents lost'end end,
  ['_resetlife']=function(n,p)return n,'reset Life totals to'end,
  ['_doublemylife']=function(n,p)if p.color==owner then return n*2,'doubled their life to'end end,
  ['_setlife']=function(n,p)if p.color==owner then return n,'Life total changed by '..math.abs(n-count)..'. Setting it to'end end,
  ['_drain']=function(n,p)if p.color==owner then return count+n,'drained everyone for'else return count-n,false,true end end,
  ['_extort']=function(n,y)if y.color==owner then for _,p in pairs(Player.getPlayers())do if p.seated and p.color~=owner then count=count+n end end return count,'extorted everyone for'else return count-n,false,true end end,
  ['_test']=function(n,p)return count end,

}

function onChat(msg,player)
  if msg:find(' %d+')then
    local m=msg:lower():gsub(' ','')
    local sl,t,n=false,'',tonumber(m:match('%d+'))
    m='_'..m
    for k,f in pairs(lCheck)do
      if m:find(k..'%d+')then
        count,t,sl=f(n,player)
        if sl then sL(count,n)end
        break end end
    
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
  txt=owner..' [888888]%s %s '..ref_type..'.[-]'
  local clr=stringColorToRGB(owner)
  self.setColorTint(clr)
  if s~=''then local ld=JSON.decode(s);count=ld.c else count=0 end
  self.createButton({click_function='option',function_owner=self,rotation={0,90,0},position={-1.1,0,0},scale={0.75,1,0.75},height=800,width=2200,font_size=2000,label='\n'..count..'\n',color={0.1,0.1,0.1},font_color=clr})
  for i,v in ipairs({{val=1,label='+',pos={0,0.2,0.7}},{val=-1,label='-',pos={0,0.2,-0.7}}})do local fn='valueChange'..i
    self.setVar(fn,function(o,c,a)local b=1 if a then b=5 end click_changeValue(o,c,v.val*b)end)
    self.createButton({tooltip='Right-click for '..v.label..'5',click_function=fn,function_owner=self,position=v.pos,height=500,width=500,label=v.label,font_size=1000,rotation={0,90,0},color={0,0,0,1},font_color=clr})
  end
  for i,v in pairs({{'^Exile^',0},{'^Deck^',4.2},{'^Graveyard^',8.3,250}})do
    self.createButton({label=v[1],position={-(16.4+v[2]),0,0},rotation={0,90,0},font_size=v[3]or 500,width=0,height=0,font_color=self.getColorTint(),click_function='none',function_owner=self})
end end
ref_type,owner,display,C2='Life','White',true,nil