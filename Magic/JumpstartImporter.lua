--By Amuzet
mod_name,version='Bag Importer',0.1
--BagImporter
local C=setmetatable({n=0,label='UNDEFINED',click_function='',function_owner=self,height=270,width=5000,font_size=190,scale={0.3,1,0.3},rotation={0,90,0},position={1.1,1,0},font_color=Color.Grey,color={0,0,0}},
  {__call=function(t,o)
      --local inc,i,h=0.325,0,t.height
      --l:gsub('\n',function()t.height,inc,i=t.height+h,inc+0.1625,i+1 return'\n'end)
      t.label,t.tooltip,t.click_function=o.getName(),o.getDescription(),'cf_Card'..o.getGUID()
      if t.tooltip then
        --ColorOfButton
        local clr='Grey'
        for _,k in pairs(Color.list)do
          if t.label:match(k)then clr=k break end end
        if clr=='White'then clr='Yellow'end
        if clr=='Black'then clr='Purple'end
        if Color[clr]then t.font_color=Color[clr]end

        self.setVar(t.click_function,function(o,c,a)
            if a then Player[c].broadcast('Will cardImport the description of '..o.getName())return end
            for d in t.tooltip:gmatch('[^\n]+')do passToImporter(o,c,a,d)end
          end)end
        o.createButton(t)
      end})

function RE()self.reload()end
function onLoad()
  self.addContextMenuItem('reload',RE)
  --WasSleepyMaking,CheckForErrors
  self.addContextMenuItem('Pick Unique',pickUnique)
  self.addContextMenuItem('Random Pack',randomPack)
  self.addContextMenuItem('Rnd from Category',fromCategory)
  SetupCat()
end
--JumpstartSpecific
function onObjectLeaveContainer(c,o)if c==self and o.type=='Card'then self.clearButtons()C(o)SetupCat()end end
function onObjectEnterContainer(c,o)if c==self and o.type=='Card'then self.clearButtons()SetupCat()end end

local Unique,nU={},0
local Category,nC={},0
function SetupCat()
  self.interactable=false
  Unique,nU={},0
  Category,nC={White={},Blue={},Black={},Red={},Green={}},0
  
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
      end
    end
  end
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
function makeBtns(t)
  for k,v in pairs(t)do
    local g=v
    if type(v)=='table'then g=v[math.random(1,#v)]end
    B(k,g)
    if self.getVar(B.click_function)then else
      self.setVar(B.click_function,function(o,c,a)
          grabGUID(c,g)end)end end end

function randomPack(c,p,o)self.shuffle()self.takeObject({position=Player[c].getHandTransform().position})end
function pickUnique()  self.clearButtons()B.setP3(nU)makeBtns(Unique)end
function fromCategory()self.clearButtons()B.setP3(nC)makeBtns(Category)B('Unique')end
function cf_GrabGUID_Unique(o,c,a)
  local i,r=0,math.random(1,nU)
  for k,g in pairs(Unique)do i=i+1
    if i==r then grabGUID(c,g)break end end end

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
--EOF