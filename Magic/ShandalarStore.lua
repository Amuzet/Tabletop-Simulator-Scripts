--Generator Store
local Randomizer=[[
[i]Town will trade 1d{No;Any;Red;Blue;Black;Green;White} amulets for 2e{ and ;Red;Green;Blue;White;Black;Colorless} cards.[/i]

[b][u][i]  sell / cost  [/i]Market:       [/u]
0000/0000 Common
0000/0000 Uncommon
0000/0000 Rare
0000/0000 Mythics
0000/0000 Booster
[/b]
Amulets are traded at a rate of:
1 per two Commons
2 per two Uncommons
3 per two Rares
5 per two Mythics
]]
function Z()self.reload()end
function onLoad()self.addContextMenuItem('Reload',Z)
self.createButton({label='[b]Shop Generator[/b]\n[i]Generate a shop by\npulling out of the bag[/i]',position={0,0.01,0},font_size=250,scale={0.4,1,0.4},rotation={0,-90,0},width=0,height=0,click_function='Z',function_owner=self})end
function onObjectLeaveContainer(c,o)if c~=self then return end
  local price={[0]=RF(self,'_','9d9+9')}
  for i=1,5 do local k=(i-1)*2
    local a=RF(self,'_','2d'..price[k]..'+'..price[k])
    table.insert(price,a)
    a=RF(self,'_',price[k]..'d2+'..price[k])
    table.insert(price,a)
  end
  for i,p in ipairs(price)do local a=tonumber(p)
    if a<1000 then if a<100 then if a<10 then
        price[i]='___'..p
      else price[i]='__'..p
      end else price[i]='_'..p
  end end end
  local k=0
  local s=Randomizer:gsub('0000',function()k=k+1return price[k]end)
  o.setDescription(RF(self,nil,s))end
function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
['{rollAmount}']=function()return L end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n,1 do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n,1 do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end