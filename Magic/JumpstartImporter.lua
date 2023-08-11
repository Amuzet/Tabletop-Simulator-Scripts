--By Amuzet
mod_name,version='Bag Importer',0.2
--BagImporter
local C=setmetatable({n=0,label='UNDEFINED',click_function='passDescription',function_owner=self,height=270,width=5000,font_size=190,scale={0.3,1,0.3},rotation={0,90,0},position={1.1,1,0},font_color=Color.Grey,color={0,0,0}},
  {__call=function(t,o)
      --local inc,i,h=0.325,0,t.height
      --l:gsub('\n',function()t.height,inc,i=t.height+h,inc+0.1625,i+1 return'\n'end)
      t.label,t.tooltip=o.getName(),o.getDescription()
      if t.tooltip then
        --ColorOfButton
        local clr='Grey'
        for _,k in pairs(Color.list)do
          if t.label:match(k)then clr=k break end end
        if clr=='White'then clr='Yellow'end
        if clr=='Black'then clr='Purple'end
        if Color[clr]then t.font_color=Color[clr]end

      end o.createButton(t)end})

function passDescription(o,c,a)
  local d=o.getDescription()
  if d=='deck'and o.script_state:len()>20 then
    addNotebookTab({title=o.getName(), body=RF(o,c,o.script_state) })end
  if a then Player[c].broadcast('Button will cardImport the description of '..o.getName())return end
  for d in o.getDescription():gmatch('[^\n]+')do passToImporter(o,c,a,d)end
end

function RE()self.reload()end
--TabletopCallbacks
function onLoad()
  self.addContextMenuItem('reload',RE)
  --WasSleepyMaking,CheckForErrors
  self.addContextMenuItem('Pick Unique',pickUnique)
  self.addContextMenuItem('Random Pack',randomPack)
  self.addContextMenuItem('From Category',fromCategory)
end

--JumpstartSpecific
local recentGUID='a1b2c3'
function onObjectLeaveContainer(c,o)if c==self then
  self.clearButtons();recentGUID=o.getGUID()end end
function onObjectDrop(p,o)if o.getGUID()==recentGUID then print(recentGUID)
  Wait.time(function()C(o)end,1)end end

local nC,nU,Category,Unique={},{},0,0
function SetupCat()
  self.interactable=false
  Unique,nU,nC={},0,0
  Category={
White={},Blue={},Black={},Red={},Green={},
Azorius={},Dimir={},Rakdos={},Gruul={},Selesnya={},
Orzov={},Izzet={},Golgari={},Boros={},Simic={}
}
  
  for _,o in pairs(self.getObjects())do
    for K in o.name:gmatch('[^-]+')do
      local k=K:gsub('%s+','')
      if Category[k]then
        table.insert(Category[k],o.guid)
      elseif Unique[k]then
        Category[k]={Unique[k],o.guid}
        Unique[k]=nil
      else
        Unique[k]=o.guid
  end end end
  
  local i=0
  for k,v in pairs(Unique)do i=i+1 end nU=i;i=0
  for k,v in pairs(Category)do i=i+1 end nC=i
  self.interactable=true
end
local B=setmetatable({n=0.2,j=0,label='UNDEFINED',click_function='',function_owner=self,height=250,width=1600,font_size=180,
    scale={0.3,1,0.3},position={1,4,0},font_color=Color.Grey,color={0,0,0}
    },{__call=function(t,l,g)
      t.label,t.tooltip,t.click_function=l,l,'cf_Grab_'..(g or l)
      --ColorOfButton
      local clr='Grey'
      for _,k in pairs(Color.list)do
        if t.label:match(k)then clr=k break end end
      if clr=='White'then clr='Yellow'end
      if clr=='Black'then clr='Purple'end
      if Color[clr]then t.font_color=Color[clr]end

      if t.j%5==0 then t.position[3]=t.position[3]+t.n end
      t.position[1]=1+t.j%5
      t.j=t.j+1

      self.createButton(t)
    end})
B.setP3=function(x)B.j,B.position[3]=0,-math.ceil(x/5)/2*B.n end
function grabGUID(c,g)self.takeObject({guid=g,position=Player[c].getHandTransform().position})end
function cf_Grab_Unique(o,c,a)
  self.clearButtons() 
  local i,r=0,math.random(1,nU)
  for k,g in pairs(Unique)do i=i+1
    if i==r then grabGUID(c,g)break end end end
function makeBtns(t)
  for k,v in pairs(t)do
    local g=v
    if type(v)=='table'then g=v[math.random(1,#v)]end
    B(k,g)
    if self.getVar(B.click_function)then else
      self.setVar(B.click_function,function(o,c,a)
          grabGUID(c,g)self.clearButtons()end)end end end

function randomPack(c,p,o)self.shuffle()self.takeObject({position=Player[c].getHandTransform().position})end
function pickUnique()  SetupCat()self.clearButtons()B.setP3(nU)makeBtns(Unique)end
function fromCategory()SetupCat()self.clearButtons()B.setP3(nC)makeBtns(Category)B('Unique')end

--QuickImporter
local lastKnownImporter=nil
function findImporter()
  if lastKnownImporter then return lastKnownImporter end
  for _,o in pairs(getAllObjects())do
    if o.getName():find('Card Importer')then
      lastKnownImporter=o return o end end return false end
function passToImporter(o,c,a,data)
  local Importer=findImporter()
  if not Importer then Player[c].broadcast('Card Importer not found!')return end
  local Modes=Importer.getVar('MODES')
  if not Modes then
    Player[c].broadcast('Card Importer does not support Quick Import!\nUpdate to 1.82 or Later!')
  elseif Importer then
    local t={position=o.getPosition(),
      player=Player[c].steam_id,
      color=Player[c].color,
      full=data,
      mode=data:gsub('(http%S+)',''):match('(%S+)'),
      name=data:gsub('(http%S+)',''):gsub(' ',''),
      url=data:match('(http%S+)')}
    
    if t.mode then
      local m,n=Modes:lower():find(t.mode:lower())
      if m then
        t.mode=Modes:sub(m,n)
        t.name=t.name:lower():gsub(t.mode:lower(),'',1)
      else t.mode=nil end end
    
    if t.name:len()<1 or not t.name:find('[%w_]')then t.name='island'else t.name=t.name:gsub('%s','')end
    Importer.call('Importer',t)end end

--RollFunctions
function RM(d,b,m)local r,n,f=0,tonumber(d),tonumber(b)for i=1,n do r=r+math.random(f)end return r+m end
function RD(d,b)local r,n,f='',tonumber(d),tonumber(b)for i=1,n do r=r..math.random(f)if i<n then r=r..', 'end end return r end
local L,RT=0,{
--{rollAmount}']=function()return L end,
--{numPlayers}']=function()return #getSeatedPlayers()end,
['(%d+)D(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)D(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)D(%d+)']=function(d,f)return RD(d,f)end,
['(%d+)d(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end for i=1,n do r=r..t[math.random(#t)]if i<n then r=r..', 'end end return r end,
['(%d+)e(%b{})']=function(d,b)local r,t,n='',{},tonumber(d)local f=b:gsub('^{',''):gsub('}$','')for c in f:gmatch('([^;]+)')do table.insert(t,c)end if n>#t then n=#t-1 end if n==1 then return''end for i=1,n do local z=math.random(2,#t);r=r..t[z];table.remove(t,z)if i<n then r=r..t[1]end end return r end,
['(%d+)d(%d+)%+(%d+)']=function(d,f,m)return RM(d,f,m)end,
['(%d+)d(%d+)%-(%d+)']=function(d,f,m)return RM(d,f,-m)end,
['(%d+)d(%d+)']=function(d,f)return RD(d,f)end,
--{randomPlayer}']=function()local t=getSeatedPlayers()return Player[t[math.random(#t)]].steam_name end,
}
function RF(o,p,r)L=L+1 local t=r for k,f in pairs(RT)do t=t:gsub(k,f)end return t:gsub('{secret}','')end
--EOF