local B=setmetatable({label='UNDEFINED',click_function='',function_owner=self,height=400,width=2100,font_size=360,scale={0.4,0.4,0.4},position={0,0.28,-1.35},rotation={0,0,90},
  },{__call=function(t,l,data)
      local inc,i,h=0.325,0,B.height
      l:gsub('\n',function()t.height,inc,i=t.height+h,inc+0.1625,i+1 end)
      t.label,t.click_function,t.position=l,'f'..l:gsub('%s','_'),{0,0.5,t.position[3]+inc}
      o.setVar(t.click_function,function(o,c,a)
          if a then Player[c].broadcast('[b]This Button will execute these commands:[/b]\nScryfall'..data:gsub('\n','\nScryfall '),{0.7,1,1})return end
          for d in data:gmatch('[^\n]+')do passToImporter(o,c,a,d)end end)
      o.createButton(t)t.height=h
      if i % 2==1 then t.position[3]=t.position[3]+0.1625 end end})

function onLoad(d)
  B.label='How To Use\nClick Me!\nHelp Button'
  B.click_function='help'
  self.createButton(B)
  self.createInput({
      label='back https://joestradingpost.weebly.com/uploads/1/2/6/3/126301603/published/wpn-exquisite-event.jpg\nhttps://deckstats.net/decks/99237/1048189-modular-marchesa/en\nMountain',
      input_function='input_func',function_owner=self,alignment=1,scale={0.5,0.5,0.5},font_size=100,validation=1,position={0,0.25,-1.3},width=B.width,height=B.height
      })
  if d~=''then for k,v in pairs(JSON.decode(d))do
    B(k,v)
end end end

function input_func(o,p,v,s)
  if not s then
    local j,l=v:gsub('\n','\n')
    if l>3 then
      p.broadcast('Be aware that having more than 3 commands per button will overload the queue.\nOnly the final 3 commands will be executed.',{1,0,1})
    else
      p.broadcast('The First Line will be the nickname of the button.\nIt will not be read as a command.',{0,1,1})
    end
  end
end

function passToImporter(o,c,a,data)
  Importer=Global.getVar('Card Importer 1.78')
  if Importer then
    local t={position=self.getPosition(),
      player=Player[c].steam_id,
      color=Player[c].color,
      full=data,
      mode=data:gsub('(http%S+)',''):match('(%S+)'),
      name=data:gsub('(http%S+)',''):gsub(' ',''),
      url=data:match('(http%S+)')}
    
    t.position[2]=t.position[2]+1
    if t.mode then
      for k,v in pairs(Importer)do
        if t.mode:lower()==k:lower()and type(v)=='function'then
          t.mode,t.name=k,t.name:lower():gsub(k:lower(),'',1)
          break end end end
    
    if t.name:len()<1 or t.name==' 'then t.name='island'else t.name=t.name:gsub('%s','')end
    Importer.call('Importer',t)end end