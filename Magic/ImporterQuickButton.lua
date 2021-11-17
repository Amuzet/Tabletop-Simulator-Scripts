--By Amuzet
mod_name,version='Quick Importer',0.3
local delete,fData,Data='','',{}
local B=setmetatable({n=0,label='UNDEFINED',click_function='',function_owner=self,height=250,width=3200,font_size=130,scale={0.2,0.2,0.2},position={0,-0.2,0},rotation={0,0,180},font_color=self.getColorTint(),color={0,0,0}},
  {__call=function(t,l,data)
      --local inc,i,h=0.325,0,t.height
      --l:gsub('\n',function()t.height,inc,i=t.height+h,inc+0.1625,i+1 return'\n'end)
      t.label,t.tooltip,t.click_function,t.position[3]=l,data,'cf_'..l:gsub('%s','_'),t.position[3]+0.1*(t.n%2)
      local cf=t.click_function:gsub('cf_','')
      if data then
        Data[cf]=data
        self.setVar(t.click_function,function(o,c,a)
            if a then
              if delete~=cf then delete=cf else Data[cf]=nil end
              Player[c].broadcast('Now Editing: '..cf,{0.7,1,1})
              self.editInput({index=0,value=l..'\n'..data})return end
          for d in data:gmatch('[^\n]+')do passToImporter(o,c,a,d)end end)log(Data)onSave()end
        local clr='Grey'
        for _,k in pairs(Color.list)do
          if l:match(k)then clr=k break end end
        if clr=='White'then clr='Yellow'end
        if clr=='Black'then clr='Purple'end
        if Color[clr]then t.font_color=Color[clr]end
        self.createButton(t)
        t.position[1]=-t.position[1]
        t.n=t.n+1
      end})

function input_func(o,c,v,s)if not s then
  local _,l=v:gsub('\n','\n')
  if l<1 then Player[c].broadcast('No Commands were found!\nRemember the first line is just a nickname.')
  elseif l>12 then Player[c].broadcast('Too many commands were found!\nOnly twelve commands can be saved per button.',{1,0,0})
  elseif fData==v then Player[c].broadcast('When you`re done just Right Click the black button to save.')
  else fData=v
    self.editButton({index=0,height=B.height*2,label='Right Click: Create New Button\n'..v:match('[^\n]+')})
    if #self.getButtons()<2 then Player[c].broadcast('The First Line will be the nickname of the button.\nIt will not be read as a command.',{0,1,1})end
end end end
function cf_How_To_Use_Quick_Importer(o,c,a)
  if a and fData~=''then
    B(fData:match('[^\n]+'),fData:gsub('[^\n]+\n','',1))
    self.editButton({index=0,label='Waiting for New Commands'})
    self.editInput({index=0,value=''})
    fData=''
  elseif fData==''then
    self.editButton({index=0,tooltip='Right Click: Create New Button'})
  else
    Player[c].broadcast('The First Line is what The Button will be named.\nThe Following lines seperated with the `enter` key are what is passed to the Card Importer 1.82+!\nRight click will submit and save all these commands as a new Button')
end end
function onDrop()self.setRotation({0,(self.getRotation()[2]+45)-((self.getRotation()[2]+45)%180),0})end
function onSave()self.script_state=JSON.encode(Data)end
function onCollisionEnter(t)
  local o=t.collision_object
  if o.getName():find(self.getName())then
    local d=JSON.decode(o.script_state)
    if d then
      self.setName(o.getName())
      Data=d
      o.destroy()
      onSave()
      self.reload()
end end end
function onLoad(ssd)
  self.createInput({
      label='Possible Commands\nrandom ?q=-t:creature+-t:land 10\nsearch set:lrw+command\nbooster lrw\nservo',
      input_function='input_func',function_owner=self,alignment=1,
      scale=B.scale,position={0,-0.1,-0.7},rotation=B.rotation,
      width=6500,height=1800,font_size=120,validation=1})
  
  B('How To Use Quick Importer')
  B.rotation=nil
  B.position={-0.7,0.1,-1.4}
  
  if ssd~=''then Data=JSON.decode(ssd)end
  log(Data)
  for k,d in pairs(Data)do B(k:gsub('_',' '),d)end
end
local lastKnownImporter,POS,Offset=nil,1,{{3.45,-3.2},{3.45,0},{3.45,3.2},{1.15,-3.2},{1.15,0},{1.15,3.2},{-1.15,-3.2},{-1.15,0},{-1.15,3.2},{-3.45,-3.2},{-3.45,0},{-3.45,3.2}}
function findImporter()
  if lastKnownImporter then return lastKnownImporter end
  for _,o in pairs(getAllObjects())do
    if o.getName():find('Card Importer')then
      lastKnownImporter=o return o end end return false end
function passToImporter(o,c,a,data)
  local Importer=findImporter()
  local Modes=Importer.getVar('MODES')
  if not Importer then
    Player[c].broadcast('Card Importer not found!')
  elseif not Modes then
    Player[c].broadcast('Card Importer does not support Quick Import!\nUpdate to 1.82 or Later!')
  elseif Importer then
    local t={position=self.getPosition(),
      player=Player[c].steam_id,
      color=Player[c].color,
      full=data,
      mode=data:gsub('(http%S+)',''):match('(%S+)'),
      name=data:gsub('(http%S+)',''):gsub(' ',''),
      url=data:match('(http%S+)')}
    t.position={
      t.position[1]+Offset[POS][1],
      t.position[2]+1,
      t.position[3]+Offset[POS][2]}
    if POS==#Offset then POS=1 else POS=POS+1 end
    
    if t.mode then
      local m,n=Modes:lower():find(t.mode:lower())
      if m then
        t.mode=Modes:sub(m,n)
        t.name=t.name:lower():gsub(t.mode:lower(),'',1)
      else t.mode=nil end end
    
    if t.name:len()<1 or not t.name:find('[%w_]')then t.name='island'else t.name=t.name:gsub('%s','')end
    Importer.call('Importer',t)end end
--EOF