--Original http://steamcommunity.com/sharedfiles/filedetails/?id=674418352
--OgAuthor http://steamcommunity.com/profiles/76561197968345269
function onload()self.createButton({click_function='RB',tooltip='ROLL\n'..self.getName(),function_owner=self,scale={5,5,5}})end
function RB(o,p)local t,s=RF(o,p,self.getDescription())if s>0 then printToColor(p..' only: '..t,p,self.getColorTint())else printToAll(t,self.getColorTint())end end
function onChat(m,p)local n=self.getName()if m:find('^'..n)then local g=m:gsub('^'..n..' ?','')local t,s=RF(self,p.color,g)if s>0 then printToColor(p..' only: '..text,p,self.getColorTint())else printToAll(t,self.getColorTint())end end end

function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
['{rollAmount}']=function()return L end,
['{numPlayers}']=function()return #getSeatedPlayers()end,
['(%d+)D(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)D(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end