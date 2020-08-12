local delete,fData,pos,off,Data=false,'',-1,2.25,{EDH_Modular_Marchesa='servo\nback https://joestradingpost.weebly.com/uploads/1/2/6/3/126301603/published/sol-ring-exquisite.jpg\nhttps://deckstats.net/decks/99237/1048189-modular-marchesa/en'}
local B=setmetatable({label='UNDEFINED',click_function='',function_owner=self,height=400,width=5500,font_size=350,scale={0.1,0.1,0.1},position={0,0.6,0.55},
  },{__call=function(t,l,data)
      local inc,fn=0.1,function(o,c,a)
        if a then Player[c].broadcast('[b]This Button will execute these commands: [/b]\nScryfall '..data:gsub('\n','\nScryfall '),{0.7,1,1})return end
        for d in data:gmatch('[^\n]+')do passToImporter(o,c,a,d)end end
      --local inc,i,h=0.325,0,t.height
      --l:gsub('\n',function()t.height,inc,i=t.height+h,inc+0.1625,i+1 return'\n'end)
      t.label,t.tooltip,t.click_function,t.position=l,data,'cf_'..l:gsub('%s','_'),{0,0.5,t.position[3]+inc}
      self.setVar(t.click_function,fn)
      Data[t.click_function:gsub('cf_','')]=data
      self.createButton(t)
      log(Data)
      onSave()end})

function input_func(o,c,v,s)if not s then
  local _,l=v:gsub('\n','\n')
  if l<2 then Player[c].broadcast('No Commands were found!\nRemember the first line is just a nickname.')
  elseif l>4 then Player[c].broadcast('Too many commands were found!\nOnly three commands will be executed at once.',{1,0,1})
  elseif fData==v then
    Player[c].broadcast('When you`re done just Alt Click the black button to save.')
  else
    fData=v
    self.editButton({index=0,label='Alt Click: Create New Button\n'..v:match('[^\n]+')..'\n'})
    if #self.getButtons()<2 then Player[c].broadcast('The First Line will be the nickname of the button.\nIt will not be read as a command.',{0,1,1})end
  end end end
function help(o,c,a)if a and fData~=''then
    B(fData:match('[^\n]+'),fData:gsub('[^\n]+\n','',1))
    self.editButton({index=0,label='Waiting for New Commands'})
    self.editInput({index=0,value=''})
    fData=''
  elseif fData==''then
    self.editButton({index=0,tooltip='Alt Click: Save New Button',label='Waiting for New Commands'})
  else
    Player[c].broadcast('The First Line is what The Button will be named.\nThe Following lines seperated with the `enter` key are what is passed to the Card Importer 1.82 and Newer!\nAlt click will submit and save all these commands as a new Button')
  end end
function onSave()self.script_state=JSON.encode(Data)end
function onLoad(ssd)
  B.label='Help Button, How to Use. CLICK ME!'
  B.click_function='help'
  self.createButton(B)
  self.editButton({index=0,font_color={1,1,1},color={0,0,0},tooltip=''})
  self.createInput({
      label='EDH Modular Marchesa\n'..Data.EDH_Modular_Marchesa,
      input_function='input_func',function_owner=self,alignment=1,scale={0.1,0.1,0.1},font_size=120,validation=1,position={0,0.6,-0.6},width=B.width,height=B.height*2
    })
  if ssd~=''then Data=JSON.decode(ssd)end
  log(Data)
  for k,d in pairs(Data)do B(k:gsub('_',' '),d)end
end

function findImporter()
  for _,o in pairs(getAllObjects())do
    if o.getName():find('Card Importer')then
      return o end end return false end
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
    t.position[1]=t.position[1]+(pos*off)
    t.position[3]=t.position[3]+(pos*off)
    t.position[2]=t.position[2]+1
    if pos==1 then pos=-1 else pos=pos+1 end
    
    if t.mode then
      local m,n=Modes:lower():find(t.mode:lower())
      if m then
        t.mode=Modes:sub(m,n)
        t.name=t.name:lower():gsub(t.mode:lower(),'',1)
      else t.mode=nil end end
    
    if t.name:len()<1 or not t.name:find('[%w_]')then t.name='island'else t.name=t.name:gsub('%s','')end
    Importer.call('Importer',t)end end
--EOF